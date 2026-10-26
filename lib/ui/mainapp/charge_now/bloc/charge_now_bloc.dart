import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/cards/preauth_limits_model.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/charging/charging_connector.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/data/model/charging/current_charging_values_model.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/locations/remote_sessions_available_model.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/bloc_transforms/droppable_with_last.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/payment/three_ds_service.dart';
import 'package:road_mobile/ui/mainapp/charge_now/live_activity/live_activity_dispatcher.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart' as map_locations_response_model;

import 'charge_now_repository.dart';

part 'charge_now_state.dart';
part 'charge_now_event.dart';
part 'charge_now_bloc.freezed.dart';

enum NoSessionExistsAction { resetToStart, resetToStartWithStartChargingError, remainOnCurrentScreen }

@injectable
class ChargeNowBloc extends Bloc<ChargeNowEvent, ChargeNowState> {
  ChargeNowBloc(
    this._chargeNowRepository,
    this._analytics,
    this._threeDsService, {
    @factoryParam required bool isInitiallyLoggedIn,
  }) : super(const ChargeNowState.chargeFlowInitialScreen()) {
    on<CheckChargingStatus>(_checkChargingStatus, transformer: droppable());
    on<ReceivedLocation>(_getNearestChargingLocations, transformer: droppableWithLast());
    on<ShowMoreChargingStationsTapped>(_showMoreChargingStationsTapped);
    on<ManualEvseIdInputTapped>(_manualEvseIdInputTapped);
    on<ScanQrCodeTapped>(_scanQrCodeTapped);
    on<ManualEvseIdSubmitted>(_manualEvseIdSubmitted);
    on<InvalidQrCode>(_invalidQrCode);
    on<SelectChargingStation>(_selectChargingStation);
    on<ChargingStationSelected>(_chargingStationSelected);
    on<ReloadPaymentCards>(_reloadPaymentCards);
    on<SelectNewPaymentCard>(_selectNewPaymentCard);
    on<StartCharging>(_startCharging);
    on<CancelCharging>(_cancelCharging);
    on<StopCharging>(_stopCharging);
    on<BackButtonTapped>(_backButtonTapped);
    on<ModalFlowDismissed>(_modalFlowDismissed);
    on<ChargingStationSelectedFromMap>(_chargingStationSelectedFromMap);
    on<ChargingLoggedOut>(_loggedOut);

    log('ChargeNowBloc created');

    if (isInitiallyLoggedIn) {
      add(const ChargeNowEvent.checkChargingStatus());
    }

    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      if (event == FGBGType.foreground) {
        add(const ChargeNowEvent.checkChargingStatus());
      }
    });
  }

  final ChargeNowRepository _chargeNowRepository;
  final Analytics _analytics;
  final ThreeDsService _threeDsService;

  Timer? _chargingStatusTimer;
  int? _currentTimerInterval;
  DateTime? _lastStartChargeAttemptTime;
  Completer<void>? _checkChargingStatusCompleter;

  // Set true while a successful cancel is in-flight, so the follow-up status
  // check (which finds no session) can distinguish an intentional cancel from
  // a genuine start failure. Consumed exactly once in _handleNoActiveSessionFound.
  bool _isCancelling = false;

  UserLocation? _lastUserLocation;
  StartChargingLocationMetadata? _isThisYouLocation;
  List<StartChargingLocationMetadata>? _showMoreLocationsResponse;
  List<StartChargingLocationMetadata>? _manualEvseIdEnteredResponse;
  ChargeStationSelectionSource? _manualEvseIdEnteredSource; // Track if entry was from QR or manual

  UnifiedPaymentCards? _unifiedPaymentCards; // Cached cards list
  StreamSubscription<FGBGType>? _fgbgSubscription;

  final _liveActivityDispatcher = LiveActivityDispatcher();

  /// Mirrors the user's `charging.session.live_update` topic subscription. Set by the
  /// charge-now UI via [setLiveUpdateNotificationsEnabled] so the bloc doesn't have to
  /// reach into [NotificationsCubit] directly. Defaults to false; until the listener
  /// fires we skip the live activity rather than show one the user hasn't asked for.
  bool _liveUpdateNotificationsEnabled = false;

  /// Updates the live-update topic flag the bloc uses to gate live activity dispatch.
  /// Called by `BlocListener<NotificationsCubit>` in the charge-now screen tree.
  ///
  /// On a state transition we react symmetrically:
  /// - true → false: tear down the running live activity / FGS so it doesn't linger.
  /// - false → true: re-fire `checkChargingStatus` so the activity is started right away.
  ///   (Doing this here rather than relying solely on the UI's check fires it through the
  ///   bloc's normal event pipeline, so it doesn't race with the polling timer's
  ///   `droppable()` transformer.)
  void setLiveUpdateNotificationsEnabled(bool enabled) {
    final wasEnabled = _liveUpdateNotificationsEnabled;
    _liveUpdateNotificationsEnabled = enabled;
    if (wasEnabled == enabled) return;

    if (!enabled) {
      _liveActivityDispatcher.endLiveActivity();
    } else {
      add(const ChargeNowEvent.checkChargingStatus());
    }
  }

  @override
  Future<void> close() {
    log('ChargeNowBloc closing...');
    _chargingStatusTimer?.cancel();
    _chargingStatusTimer = null;
    _currentTimerInterval = null;
    _fgbgSubscription?.cancel();
    _fgbgSubscription = null;
    return super.close();
  }

  void _loggedOut(ChargeNowEvent event, Emitter<ChargeNowState> emit) {
    _chargingStatusTimer?.cancel();
    _chargingStatusTimer = null;
    _currentTimerInterval = null;

    emit(const ChargeNowState.chargeFlowInitialScreen());
  }

  void _backButtonTapped(ChargeNowEvent event, Emitter<ChargeNowState> emit) async {
    ChargeNowState? backState = _backStateForState(state);
    if (backState != null) {
      emit(backState);
    }
  }

  void _modalFlowDismissed(ChargeNowEvent event, Emitter<ChargeNowState> emit) async {
    final maintainState = switch (state) {
      ChargeSessionStarting() => true,
      CarIsCharging() => true,
      _ => false,
    };

    if (maintainState) {
      return;
    }

    // Allow screen to fully dismiss before we reset the state.
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const ChargeNowState.chargeFlowInitialScreen());
    _showMoreLocationsResponse = null;
    _manualEvseIdEnteredResponse = null;
    _manualEvseIdEnteredSource = null;
    _isThisYouLocation = null;
  }

  bool canGoBackInState(ChargeNowState state) {
    return _backStateForState(state) != null;
  }

  ChargeNowState? _backStateForState(ChargeNowState currentState) {
    return switch (currentState) {
      Location() => const ChargeNowState.chargeFlowInitialScreen(),
      IsThisYou() => const ChargeNowState.chargeFlowInitialScreen(),
      SelectYourChargeStation(:final directFromInitialScreen, :final source) => _getBackStateForSelectYourChargeStation(
        directFromInitialScreen,
        source,
      ),
      StartChargingSession() => _getBackStateForStartChargingSession(),
      ManualEvseIdInput() => const ChargeNowState.chargeFlowInitialScreen(),
      ScanningQrCode() => const ChargeNowState.chargeFlowInitialScreen(),
      _ => null,
    };
  }

  ChargeNowState? _getBackStateForSelectYourChargeStation(
    bool directFromInitialScreen,
    ChargeStationSelectionSource source,
  ) {
    // If we came directly from initial screen, go back to it
    if (directFromInitialScreen) {
      return const ChargeNowState.chargeFlowInitialScreen();
    }

    // If we came from QR code scanning, go back to it
    if (source == ChargeStationSelectionSource.qrCode) {
      return const ChargeNowState.scanningQrCode();
    }

    // Otherwise, determine based on what location data we have
    if (_isThisYouLocation != null) {
      return ChargeNowState.isThisYou(_isThisYouLocation!);
    }

    if (_showMoreLocationsResponse != null) {
      return const ChargeNowState.chargeFlowInitialScreen();
    }

    if (_manualEvseIdEnteredResponse != null) {
      return const ChargeNowState.manualEvseIdInput();
    }

    // No valid back state found
    return null;
  }

  ChargeNowState? _getBackStateForStartChargingSession() {
    // If we have nearby locations from "show more" action
    if (_showMoreLocationsResponse != null) {
      return ChargeNowState.selectYourChargeStation(
        _showMoreLocationsResponse!,
        false,
        source: ChargeStationSelectionSource.nearbySearch,
      );
    }

    // If we have locations from manual EVSE ID entry
    if (_manualEvseIdEnteredResponse != null) {
      // Single result: go back to QR scanner if from QR, otherwise manual input
      if (_manualEvseIdEnteredResponse!.length == 1) {
        return _manualEvseIdEnteredSource == ChargeStationSelectionSource.qrCode
            ? const ChargeNowState.scanningQrCode()
            : const ChargeNowState.manualEvseIdInput();
      }
      return ChargeNowState.selectYourChargeStation(
        _manualEvseIdEnteredResponse!,
        false,
        source: _manualEvseIdEnteredSource ?? ChargeStationSelectionSource.manual,
      );
    }

    // If we have "is this you" location
    if (_isThisYouLocation != null) {
      return ChargeNowState.isThisYou(_isThisYouLocation!);
    }

    // No valid back state found
    return null;
  }

  Future<void> _checkChargingStatus(ChargeNowEvent event, Emitter<ChargeNowState> emit) async {
    _checkChargingStatusCompleter ??= Completer<void>();
    try {
      final sessionsResponse = await _chargeNowRepository.listRemoteSessions();
      final ChargingSessionModel? activeSession = sessionsResponse.pendingOrActiveSession;

      if (activeSession == null) {
        log('No active session found');
        await _handleNoActiveSessionFound(sessionsResponse, emit);
        await _liveActivityDispatcher.endLiveActivity();
        return;
      }

      log('Found active charging session, status: ${activeSession.status}');
      await _handleActiveSessionFound(activeSession, emit);
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    } finally {
      _checkChargingStatusCompleter?.complete();
      _checkChargingStatusCompleter = null;
    }
  }

  Future<void> _handleNoActiveSessionFound(
    ChargingSessionsResponseModel sessionsResponse,
    Emitter<ChargeNowState> emit,
  ) async {
    _chargingStatusTimer?.cancel();
    _chargingStatusTimer = null;
    _currentTimerInterval = null;

    NoSessionExistsAction resetAction;

    switch (state) {
      case ChargeSessionStarting(:final session):
        if (_isCancelling) {
          _isCancelling = false;
          resetAction = NoSessionExistsAction.resetToStart;
        } else {
          _analytics.logChargeNowEvent(
            ChargeNowAnalyticsType.chargeSessionStartFailed,
            sessionId: session.id,
            locationId: session.locationId,
          );
          resetAction = NoSessionExistsAction.resetToStartWithStartChargingError;
        }

      case CarIsCharging(:final session, :final card):
        final completedSession = sessionsResponse.sessionWithId(session.id);
        if (completedSession == null) {
          resetAction = NoSessionExistsAction.resetToStart;
        } else {
          emit(ChargeNowState.chargeSessionStopping(completedSession, card));
          _analytics.logChargeNowEvent(ChargeNowAnalyticsType.chargeSessionStopping, sessionId: session.id);
          resetAction = NoSessionExistsAction.remainOnCurrentScreen;
        }

      case ChargeSessionStopping(:final session, :final card):
        final completedSession = sessionsResponse.sessionWithId(session.id);
        if (completedSession == null) {
          resetAction = NoSessionExistsAction.resetToStart;
        } else if (completedSession.status == 'COMPLETED') {
          emit(ChargeNowState.chargeSessionEnded(completedSession, card));
          _analytics.logChargeNowEvent(ChargeNowAnalyticsType.chargeSessionEnded, sessionId: session.id);
          resetAction = NoSessionExistsAction.remainOnCurrentScreen;
        } else {
          resetAction = NoSessionExistsAction.remainOnCurrentScreen;
        }

      case _:
        resetAction = NoSessionExistsAction.remainOnCurrentScreen;
    }

    switch (resetAction) {
      case NoSessionExistsAction.resetToStart:
        emit(const ChargeNowState.chargeFlowInitialScreen());
        break;
      case NoSessionExistsAction.resetToStartWithStartChargingError:
        emit(
          ChargeNowState.chargeFlowInitialScreen(
            flow: UIFlow.error(RMApiError(cause: 'Unable to start a charging session. Please try again later.')),
          ),
        );
        break;
      case NoSessionExistsAction.remainOnCurrentScreen:
        emit(state.copyWith(flow: const UIFlow.established()));
        break;
    }
  }

  Future<void> _handleActiveSessionFound(ChargingSessionModel activeSession, Emitter<ChargeNowState> emit) async {
    _unifiedPaymentCards ??= (await _chargeNowRepository.getMyPaymentCards(true, true));

    final activeSessionId = activeSession.activeSession?.id;
    log('Active session ID: $activeSessionId (status: ${activeSession.status}, activeSession null: ${activeSession.activeSession == null})');

    CurrentChargingValues? currentChargingValues;
    if (activeSessionId != null) {
      if (Defines.currentChargingValuesEndpointEnabled) {
        currentChargingValues = await _chargeNowRepository.getCurrentChargingValues(activeSessionId);
        log('Current charging values: ${currentChargingValues != null ? 'received' : 'null'}');
      } else {
        log('Current charging values: endpoint disabled by kill switch (Defines.currentChargingValuesEndpointEnabled)');
      }

      // Only drive the live activity locally when we have an absolute session start
      // time. Otherwise we'd push durationMinutes=0 + startedAt=nil into the widget,
      // which makes the auto-counting timer reset to 0 (bug observed when re-opening
      // the activity from the lock screen during transitional session states).
      // BE pushes will continue to update the activity in the background regardless.
      final sessionStartedAt = activeSession.activeSession?.startedAt;
      if (sessionStartedAt != null) {
        // Live activity source-of-truth selection:
        //  - endpoint on: trust `currentChargingValues` (has cost + SoC + Wh energy).
        //  - endpoint off: synthesise from `activeSession.kwh` (× 1000 → Wh) so the
        //    Dart push and the BE push are reading the same field — no more racing
        //    zero placeholders clobbering each other on the lock screen.
        final liveActivityKwh = activeSession.activeSession?.kwh ?? 0;
        final valuesForLiveActivity = (currentChargingValues ??
                CurrentChargingValues(costCurrentTotal: 0, energy: (liveActivityKwh * 1000).round()))
            .withSessionStartedAt(sessionStartedAt);

        final liveActivityResult = await _liveActivityDispatcher.showLiveActivity(
          valuesForLiveActivity,
          activeSessionId: activeSessionId,
          liveUpdateNotificationsEnabled: _liveUpdateNotificationsEnabled,
          currency: activeSession.mspSession?.currency ?? 'EUR',
          locationName: activeSession.location?.address,
        );
        log('Live activity result: status=${liveActivityResult.status}, needsRegistration=${liveActivityResult.needsRegistration}, pushToken=${liveActivityResult.pushToken != null}');

        // Register new live activity with backend for push updates
        if (liveActivityResult.needsRegistration) {
          log('Registering live activity with backend: activityId=${liveActivityResult.activityId}');
          await _chargeNowRepository.registerLiveActivity(
            activeSessionId: activeSessionId,
            apnToken: liveActivityResult.pushToken!,
            liveActivityId: liveActivityResult.activityId!,
            providerSlug: F.providerName,
          );
        }
      } else {
        log('Skipping live activity update — no sessionStartedAt yet (session likely transitioning).');
      }
    }

    // Resolve a stored card for RFID / legacy card-tokenisation sessions. PayBridge
    // sessions are displayed straight off `session.externalPayment` in the widgets,
    // so `activeCard` will be null for them and that's fine.
    UnifiedPaymentCard? activeCard = _unifiedPaymentCards?.getCardWithTokenId(
      tokenId: activeSession.tokenId,
    );

    if (activeSession.status == 'STOPPING') {
      emit(ChargeNowState.chargeSessionStopping(activeSession, activeCard));
    } else if (activeSession.status == 'STARTING' || activeSession.status == 'PENDING') {
      // Active session is neither stopping nor completed - this means it's charging.
      _lastStartChargeAttemptTime ??= DateTime.now();
      emit(ChargeNowState.chargeSessionStarting(activeSession, activeCard, _lastStartChargeAttemptTime!));
    } else if (activeSession.status == 'ACTIVE') {
      switch (state) {
        case ChargeSessionStarting(:final session) when session.id == activeSession.id:
          _analytics.logChargeNowEvent(ChargeNowAnalyticsType.chargeSessionStarted, sessionId: session.id);
        case _:
          break;
      }
      // Active session is neither stopping nor completed - this means it's charging.
      emit(ChargeNowState.carIsCharging(activeSession, activeCard, currentChargingValues));
    }

    int idealTimerInterval = activeSession.idealTimerPollInterval;

    if (_currentTimerInterval != idealTimerInterval) {
      _chargingStatusTimer?.cancel();
      _chargingStatusTimer = null;
      log('Setting charge polling interval to $idealTimerInterval seconds');
    }

    _currentTimerInterval = idealTimerInterval;
    _chargingStatusTimer ??= Timer.periodic(Duration(seconds: idealTimerInterval), (timer) async {
      if (isClosed) {
        timer.cancel();
        return;
      }
      add(const ChargeNowEvent.checkChargingStatus());
    });
  }

  void _getNearestChargingLocations(ReceivedLocation event, Emitter<ChargeNowState> emit) async {
    final eventLocation = event.location;
    _lastUserLocation = event.location;

    if (eventLocation == null) {
      // No location available, but we want to start the flow anyway
      emit(const ChargeNowState.location(null, []));
      return null;
    }

    final lastLocation = switch (state) {
      Location(:final userLocation) => userLocation,
      _ => null,
    };

    if (lastLocation != null) {
      if (lastLocation.distanceToOtherLocation(eventLocation) < 2) {
        log('Location has not changed enough to update');
        return null;
      }
    }

    final chargingStations = await _getLocationsFromApi(eventLocation, event.partyIds, emit);
    if (chargingStations == null) {
      // Error already emitted
      return;
    }

    if (chargingStations.isNotEmpty) {
      chargingStations.sortByClosestTo(eventLocation);
      final userLatLng = LatLng(eventLocation.latitude, eventLocation.longitude);
      for (final station in chargingStations) {
        station.searchLocation = userLatLng;
      }
      _isThisYouLocation = chargingStations.first;
      emit(ChargeNowState.isThisYou(chargingStations.first));
    } else {
      // Send status but we cannot yet proceed.
      emit(ChargeNowState.location(event.location, []));
      _analytics.logChargeNowEvent(ChargeNowAnalyticsType.noNearbyStationFound);
    }
  }

  // When Charge now -> Find nearby station
  void _showMoreChargingStationsTapped(ShowMoreChargingStationsTapped event, Emitter<ChargeNowState> emit) async {
    final searchLocation = event.location ?? _lastUserLocation;

    if (searchLocation == null) {
      log('No location available');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No location available'))));
      return;
    }

    _analytics.logChargeNowEvent(ChargeNowAnalyticsType.findNearbyChargingStations);
    final chargingStations = await _getLocationsFromApi(searchLocation, event.partyIds, emit);
    if (chargingStations == null) {
      // Error already emitted in _getLocationsFromApi
      return;
    }

    chargingStations.sortByClosestTo(searchLocation);

    final userLatLng = LatLng(searchLocation.latitude, searchLocation.longitude);
    for (final station in chargingStations) {
      station.searchLocation = userLatLng;
    }

    _showMoreLocationsResponse = chargingStations;
    _manualEvseIdEnteredResponse = null;
    _manualEvseIdEnteredSource = null;
    emit(
      ChargeNowState.selectYourChargeStation(
        chargingStations,
        event.directFromInitialScreen,
        source: ChargeStationSelectionSource.nearbySearch,
      ),
    );
  }

  void _manualEvseIdInputTapped(ManualEvseIdInputTapped event, Emitter<ChargeNowState> emit) {
    _analytics.logChargeNowEvent(ChargeNowAnalyticsType.manualInputStationId);
    emit(const ChargeNowState.manualEvseIdInput());
  }

  void _scanQrCodeTapped(ScanQrCodeTapped event, Emitter<ChargeNowState> emit) {
    _analytics.logChargeNowEvent(ChargeNowAnalyticsType.scanQrCode);
    emit(const ChargeNowState.scanningQrCode());
  }

  void _invalidQrCode(InvalidQrCode event, Emitter<ChargeNowState> emit) {
    emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: event.errorMessage))));
  }

  Future<void> _manualEvseIdSubmitted(ManualEvseIdSubmitted event, Emitter<ChargeNowState> emit) async {
    if (_checkChargingStatusCompleter != null) {
      // Wait for any running CheckChargingStatus to complete. This will only happen when the user has opened
      // the app from a link. They might also have logged in. We need the initial status call to complete to
      // avoid a race condition in the flow.
      await _checkChargingStatusCompleter!.future;
    }

    switch (state) {
      case ChargeSessionStarting():
      case CarIsCharging():
        // App links may call this method while charging.
        log('Cannot start charging with manual EVSE ID while charging');
        return;
      case _:
        break;
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));

      _analytics.logChargeNowEvent(ChargeNowAnalyticsType.manualInputStationIdEntered);

      final locationsResponse = await _chargeNowRepository.getChargingLocationsWithSearchId(
        event.evseId,
        event.partyIds,
      );

      if (locationsResponse.data.isEmpty) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No location with that ID found'))));
        return;
      }

      final locationIds = locationsResponse.data.map((l) => l.id).toList();
      final locationDetails = (await _chargeNowRepository.getChargingLocationsDetails(locationIds)).data;

      final userLatLng = event.userLocation != null
          ? LatLng(event.userLocation!.latitude, event.userLocation!.longitude)
          : null;

      final locations = locationsResponse.data
          .expand(
            (l) => l.evses.expand(
              (e) => e.connectors.map(
                (c) => StartChargingLocationMetadata(
                  locationId: l.id,
                  evseId: e.evseId ?? '',
                  evseUid: e.uid ?? '',
                  connectorId: c.id ?? '',
                  latLng: l.geoLocation.latLng ?? const LatLng(0, 0),
                  name: l.name ?? 'Name unknown',
                  address: l.address ?? 'Address unknown',
                  status: ChargingPortAvailability.fromString(e.status),
                  maxPower: c.maxPower,
                  powerType: c.powerType,
                  tariffModel: TariffModel.fromTariff(c.tariff, additionalCharges: l.cdrAdditionalCharges),
                  userSpecialTariffs: locationDetails
                      .firstWhereOrNull((d) => d.id == l.id)
                      ?.evses
                      .firstWhereOrNull((d) => d.evseId == e.evseId)
                      ?.userSpecialTariffs,
                  supportsRemoteRfidCardCharging: e.supportsRemoteRfidCardCharging,
                  supportsCreditCardCharging: e.supportsCreditCardCharging,
                  capabilities: e.capabilities ?? [],
                  searchLocation: userLatLng,
                  physicalReference: e.physicalReference,
                ),
              ),
            ),
          )
          .toList();

      final filteredLocations = locations
          .where(
            (l) =>
                l.evseId.isNotEmpty &&
                l.evseUid.isNotEmpty &&
                l.connectorId.isNotEmpty &&
                l.evseId.contains(event.evseId),
          )
          .toList();

      _manualEvseIdEnteredResponse = filteredLocations;
      // Store the source for back navigation
      _manualEvseIdEnteredSource = state is ScanningQrCode
          ? ChargeStationSelectionSource.qrCode
          : ChargeStationSelectionSource.manual;

      if (filteredLocations.length == 1) {
        await _moveToSelectPaymentCard(filteredLocations.first, emit);
      } else {
        _showMoreLocationsResponse = null;
        _isThisYouLocation = null;
        emit(ChargeNowState.selectYourChargeStation(filteredLocations, false, source: _manualEvseIdEnteredSource!));
      }
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<List<StartChargingLocationMetadata>?> _getLocationsFromApi(
    UserLocation eventLocation,
    List<String> partyIds,
    Emitter<ChargeNowState> emit,
  ) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));

      final locationsResponse = await _chargeNowRepository.getAvailableChargingLocations(
        eventLocation: eventLocation,
        partyIds: partyIds,
      );

      emit(state.copyWith(flow: const UIFlow.established()));

      return locationsResponse;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return null;
    }
  }

  void _selectChargingStation(SelectChargingStation event, Emitter<ChargeNowState> emit) {
    switch (state) {
      case IsThisYou(:final evseLocation):
        _isThisYouLocation = evseLocation;
        emit(ChargeNowState.isThisYou(evseLocation));
      default:
        break;
    }
  }

  Future<void> _chargingStationSelectedFromMap(
    ChargingStationSelectedFromMap event,
    Emitter<ChargeNowState> emit,
  ) async {
    if (state is CarIsCharging) {
      log('Ignoring charging station selection from map while charging');
      return;
    }

    final evseUid = event.evse.uid;
    if (evseUid == null) {
      log('Cannot start charging without EVSE UID');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Cannot start charging without EVSE UID'))));
      return;
    }

    // Do not allow back button.
    _isThisYouLocation = null;
    _showMoreLocationsResponse = null;

    final connectorId = event.connector.id;
    if (connectorId == null) {
      log('Cannot start charging without EVSE connector ID');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Cannot start charging without EVSE connector ID'))));
      return;
    }

    final evseId = event.evse.evseId;
    if (evseId == null) {
      log('Cannot start charging without EVSE ID');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Cannot start charging without EVSE ID'))));
      return;
    }

    final locationId = event.location.id;
    if (locationId == null) {
      log('Cannot start charging without location ID');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Cannot start charging without location ID'))));
      return;
    }

    final location = event.location;
    final evse = event.evse;
    final connector = event.connector;

    final userLatLng = _lastUserLocation != null
        ? LatLng(_lastUserLocation!.latitude, _lastUserLocation!.longitude)
        : null;

    final locationMetadata = StartChargingLocationMetadata(
      locationId: locationId,
      evseId: evseId,
      evseUid: evseUid,
      connectorId: connectorId,
      latLng: event.location.geoLocation?.latLng ?? const LatLng(0, 0),
      name: location.name ?? '',
      address: location.address ?? '',
      status: evse.chargingPortAvailability,
      maxPower: connector.maxPower,
      powerType: connector.humanConnectorDetails,
      tariffModel: TariffModel.fromTariff(connector.tariff, additionalCharges: location.cdrAdditionalCharges),
      userSpecialTariffs: evse.userSpecialTariffs,
      supportsRemoteRfidCardCharging: evse.stationSupportsRfidCharging,
      supportsCreditCardCharging: evse.stationSupportsCreditCardCharging,
      capabilities: evse.capabilities ?? [],
      searchLocation: userLatLng,
      physicalReference: evse.physicalReference,
    );

    return _moveToSelectPaymentCard(locationMetadata, emit);
  }

  Future<void> _chargingStationSelected(ChargingStationSelected event, Emitter<ChargeNowState> emit) async {
    // For SelectYourChargeStation state, track which station is loading
    if (state case SelectYourChargeStation(:final evseLocations, :final directFromInitialScreen, :final source)) {
      emit(
        SelectYourChargeStation(
          evseLocations,
          directFromInitialScreen,
          source: source,
          flow: const UIFlow.loading(),
          loadingEvseId: event.location.evseId,
        ),
      );
    }
    await _moveToSelectPaymentCard(event.location, emit);
  }

  // Called after the use has added a new credit card in the middle of the flow
  Future<bool> _reloadPaymentCards(ReloadPaymentCards event, Emitter<ChargeNowState> emit) async {
    switch (state) {
      case StartChargingSession(:final chargingStartMetadata):
        await _moveToSelectPaymentCard(chargingStartMetadata, emit);
        return true;
      default:
        log('Cannot reload payment cards in current state: $state');
        return false;
    }
  }

  Future<void> _moveToSelectPaymentCard(
    StartChargingLocationMetadata startChargingMetaData,
    Emitter<ChargeNowState> emit,
  ) async {
    // Only emit loading if not already loading (e.g., from SelectYourChargeStation with loadingEvseId)
    if (!state.flow.isLoading) {
      emit(state.copyWith(flow: const UIFlow.loading()));
    }

    try {
      final allUnifiedPaymentCards = await _chargeNowRepository.getMyPaymentCards(
        startChargingMetaData.supportsRemoteRfidCardCharging,
        startChargingMetaData.supportsCreditCardCharging,
      );

      final filteredUnifiedPaymentCards = allUnifiedPaymentCards.filteredByActive;
      _unifiedPaymentCards = filteredUnifiedPaymentCards;

      final preauthLimitsModel = await _chargeNowRepository.getPreAuthLimits(
        startChargingMetaData.locationId,
        startChargingMetaData.evseUid,
        startChargingMetaData.connectorId,
      );

      emit(
        ChargeNowState.startChargingSession(
          startChargingMetaData,
          filteredUnifiedPaymentCards,
          filteredUnifiedPaymentCards.defaultCard,
          preauthLimitsModel.data,
        ),
      );
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Called when the user selects a new payment method.
  Future<void> _selectNewPaymentCard(SelectNewPaymentCard event, Emitter<ChargeNowState> emit) async {
    switch (state) {
      case StartChargingSession(:final chargingStartMetadata, :final cards, :final preAuthLimits):
        emit(ChargeNowState.startChargingSession(chargingStartMetadata, cards, event.newCard, preAuthLimits));
      default:
        log('Cannot select new payment card in current state: $state');
    }
  }

  void _startCharging(StartCharging event, Emitter<ChargeNowState> emit) async {
    try {
      // Clear any stale cancel flag from a previous attempt that didn't reach
      // the consume-site (e.g. status check happened while not in ChargeSessionStarting).
      _isCancelling = false;
      emit(state.copyWith(flow: const UIFlow.loading()));

      final params = StartChargingParameters(
        paymentType: event.paymentCard.underlyingCardType.chargePaymentType,
        locationId: event.startChargingMetadata.locationId,
        evseUid: event.startChargingMetadata.evseUid,
        connectorId: event.startChargingMetadata.connectorId,
        preauthAmount: event.preauthLimits.defaultAmount,
        currency: event.preauthLimits.currency,
        tokenId: event.paymentCard.startChargeTokenId,
        paymentInstrumentId: event.paymentCard.startChargePaymentInstrumentId,
      );

      _lastStartChargeAttemptTime = DateTime.now();
      final sessionResponse = await _chargeNowRepository.startRemoteSession(params: params);

      if (sessionResponse.requiresThreeDs) {
        final threeDsOutcome = await _threeDsService.performThreeDs(sessionResponse.threeDsRedirectUrl!);
        if (threeDsOutcome.result == ThreeDsResult.cancelled) {
          emit(state.copyWith(flow: const UIFlow.established()));
          return;
        }
        // For error/success we proceed — webhooks handle the backend side.
        // The Checkout SDK may report an error (404) even when the 3DS challenge
        // completed successfully, because it tries to extract a token that doesn't
        // exist in the payment-session flow.
      }

      add(const ChargeNowEvent.checkChargingStatus());

      _unifiedPaymentCards?.setDefaultCard(event.paymentCard);

      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeStartRequestSentSuccess,
        paymentType: params.paymentType,
        locationId: params.locationId,
        evseUid: params.evseUid,
        connectorId: params.connectorId,
      );
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeStartRequestSentError,
        paymentType: event.paymentCard.underlyingCardType.chargePaymentType,
        locationId: event.startChargingMetadata.locationId,
        evseUid: event.startChargingMetadata.evseUid,
        connectorId: event.startChargingMetadata.connectorId,
      );
    } on PlatformException catch (e) {
      if (e.code == 'paymentCanceled') {
        log('User cancelled payment');
        emit(state.copyWith(flow: const UIFlow.established()));
      } else {
        log('Failed to start charging: $e');
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: e.message ?? 'No message provided'))));
        _analytics.logChargeNowEvent(
          ChargeNowAnalyticsType.chargeStartRequestSentError,
          paymentType: event.paymentCard.underlyingCardType.chargePaymentType,
          locationId: event.startChargingMetadata.locationId,
          evseUid: event.startChargingMetadata.evseUid,
          connectorId: event.startChargingMetadata.connectorId,
        );
      }
    } catch (e) {
      log('Failed to start charging: $e');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to start charging: $e'))));
      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeStartRequestSentError,
        paymentType: event.paymentCard.underlyingCardType.chargePaymentType,
        locationId: event.startChargingMetadata.locationId,
        evseUid: event.startChargingMetadata.evseUid,
        connectorId: event.startChargingMetadata.connectorId,
      );
    }
  }

  void _cancelCharging(CancelCharging event, Emitter<ChargeNowState> emit) async {
    final currentState = state;

    if (currentState is! ChargeSessionStarting) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Can only cancel charging when starting'))));
      return;
    }

    emit(state.copyWith(flow: const UIFlow.loading()));

    try {
      bool didCancel = await _chargeNowRepository.cancelRemoteSession(event.chargingSession.id);

      if (didCancel) {
        _isCancelling = true;
        _analytics.logChargeNowEvent(
          ChargeNowAnalyticsType.chargeCancelRequestSentSuccess,
          sessionId: event.chargingSession.id,
        );
      } else {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to cancel charging'))));
        _analytics.logChargeNowEvent(
          ChargeNowAnalyticsType.chargeCancelRequestSentError,
          sessionId: event.chargingSession.id,
        );
      }

      // Wait a few seconds so BE can transition to at least STOPPING
      await Future.delayed(const Duration(seconds: 3));

      add(const ChargeNowEvent.checkChargingStatus());
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeCancelRequestSentError,
        sessionId: event.chargingSession.id,
      );
    }
  }

  void _stopCharging(StopCharging event, Emitter<ChargeNowState> emit) async {
    final currentState = state;

    final ChargingSessionModel chargingSessionModel;
    final UnifiedPaymentCard? card;

    if (currentState is CarIsCharging) {
      chargingSessionModel = currentState.session;
      card = currentState.card;
    } else {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No active charging session'))));
      return;
    }

    emit(state.copyWith(flow: const UIFlow.loading()));

    try {
      // This is either a success, or we catch the API error below.
      await _chargeNowRepository.stopRemoteSession(event.chargingSession.id);
      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeStopRequestSentSuccess,
        sessionId: chargingSessionModel.id,
      );

      final ChargingSessionsResponseModel sessionsResponse = await _chargeNowRepository.listRemoteSessions();
      final ChargingSessionModel? completedSession = sessionsResponse.sessionWithId(chargingSessionModel.id);

      if (completedSession == null) {
        log('Failed to find completed session in list of sessions');
        emit(ChargeNowState.chargeSessionStopping(chargingSessionModel, card));
      } else {
        emit(ChargeNowState.chargeSessionStopping(completedSession, card));
      }

      await _liveActivityDispatcher.endLiveActivity();

      // Wait a few seconds so BE can transition to at least STOPPING
      await Future.delayed(const Duration(seconds: 3));

      add(const ChargeNowEvent.checkChargingStatus());
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      _analytics.logChargeNowEvent(
        ChargeNowAnalyticsType.chargeStopRequestSentError,
        sessionId: chargingSessionModel.id,
      );
    }
  }
}
