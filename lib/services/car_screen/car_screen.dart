import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/charging_connector_types.dart';
import 'package:road_mobile/data/evse_capabilties.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_cubit.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/car_screen_formatting.dart' as car_fmt;
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for highway mode preference (stores 'off', 'auto', 'on')
const String _kHighwayModeKey = 'car_screen_highway_mode';

@lazySingleton
class CarScreen {
  CarScreen() {
    developer.log('CarScreen: Initializing CarScreen service', name: 'CarPlay');
    _loadHighwayModePreference();
    _setupMethodChannel();
    _syncCarSessionStateFromNative();
  }

  /// Ask native whether a car session is already active. The push
  /// (carSystemStateChanged) can fire before our handler is registered — the
  /// engine-side channel buffer only holds one pending message, so a second
  /// early call on this channel would evict it. Pulling the state once we're
  /// ready makes session activation independent of that race.
  Future<void> _syncCarSessionStateFromNative() async {
    try {
      final isActive = await _nativeChannel.invokeMethod<bool>('getCarSessionState');
      developer.log('CarScreen: Pulled car session state from native: $isActive', name: 'CarPlay');
      if (isActive == true && !_isCarSystemActive) {
        _isCarSystemActive = true;
        _handleCarSystemActive();
      }
    } on MissingPluginException {
      // Native side without this method (e.g. iOS) — rely on the push.
    } on PlatformException catch (e) {
      developer.log('CarScreen: Error pulling car session state', name: 'CarPlay', error: e.message);
    }
  }

  AuthCubit? _authCubit;
  StreamSubscription<AuthState>? _authSubscription;
  FavouritesCubit? _favouritesCubit;
  StreamSubscription<FavouritesState>? _favouritesSubscription;

  /// Register the AuthCubit instance so CarScreen can react to auth changes
  /// (e.g. show/hide favourite buttons, update UI strings).
  void registerAuthCubit(AuthCubit authCubit) {
    _authCubit = authCubit;
    _authSubscription?.cancel();
    _authSubscription = authCubit.stream.listen((_) {
      if (_isCarSystemActive) {
        _sendUiStrings();
        _sendStationsToNative();
        _sendFavouritesToNative();
      }
    });
  }

  /// Register the FavouritesCubit instance so CarScreen can access and toggle favourites.
  void registerFavouritesCubit(FavouritesCubit favouritesCubit) {
    _favouritesCubit = favouritesCubit;
    _favouritesSubscription?.cancel();
    _favouritesSubscription = favouritesCubit.stream.listen((state) {
      _syncFavouriteIds();
      // Re-send stations so native gets updated isFavourite flags
      if (_isCarSystemActive) {
        _sendStationsToNative();
        _sendFavouritesToNative();
      }
    });
    // Sync initial state
    _syncFavouriteIds();
  }

  final _nativeChannel = const MethodChannel('io.e-flux.mobile/auto');
  NearestStationsCubit? _nearestStationsCubit;
  StreamSubscription<NearestStationsState>? _stateSubscription;
  bool _isCarSystemActive = false;

  /// Highway mode setting: off / auto / on (persisted to SharedPreferences)
  HighwayMode _highwayMode = HighwayMode.auto;

  /// Car screen filter toggle states — reset each session
  final Map<String, bool> _filterStates = {
    'available': false,
    'brandChargers': false,
    'dc': false,
    'remoteStart': false,
    // Power tier keys (mutually exclusive — singleChoice group)
    'powerSlow': false,
    'powerFast': false,
    'powerRapid': false,
    'powerUltra': false,
    // Connector type keys (multi-select — multipleChoice group)
    'connType1': false,
    'connType2': false,
    'connType3': false,
    'connChademo': false,
    'connDomestic': false,
    'connCombo': false,
  };

  /// Power tier keys — only one can be active at a time
  static const _powerKeys = {'powerSlow', 'powerFast', 'powerRapid', 'powerUltra'};

  /// Maps connector filter keys to API enum values
  static const _connectorApiValues = {
    'connType1': ['IEC_62196_T1'],
    'connType2': ['IEC_62196_T2'],
    'connType3': ['IEC_62196_T3A'],
    'connChademo': ['CHADEMO'],
    'connDomestic': ['DOMESTIC_F', 'DOMESTIC_E', 'DOMESTIC_B'],
    'connCombo': ['IEC_62196_T1_COMBO', 'IEC_62196_T2_COMBO'],
  };

  /// Highway mode setting (for external access if needed)
  HighwayMode get highwayMode => _highwayMode;

  @disposeMethod
  void dispose() {
    _stateSubscription?.cancel();
    _authSubscription?.cancel();
    _favouritesSubscription?.cancel();
    _nearestStationsCubit?.close();
  }

  // MARK: - Favourites Support

  /// Sync current favourite location IDs from FavouritesCubit to NearestStationsCubit
  void _syncFavouriteIds() {
    final ids = _favouritesCubit?.state.stationIds.toSet() ?? {};
    _nearestStationsCubit?.setFavouriteLocationIds(ids);
  }

  /// Handle a favourite toggle request from native UI
  Future<void> _handleToggleFavourite(String locationId) async {
    developer.log('CarScreen: Toggling favourite for location: $locationId', name: 'CarPlay');
    await _favouritesCubit?.toggleFavourite(locationId);
    // Reload full favourite data (toggle only updates stationIds, not the stations list)
    _favouritesCubit?.loadFavourites();
  }

  /// Load the highway mode preference from SharedPreferences.
  /// Defaults to HighwayMode.auto if no preference has been saved yet.
  Future<void> _loadHighwayModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kHighwayModeKey);
      if (stored != null) {
        _highwayMode = HighwayMode.values.firstWhere(
          (m) => m.name == stored,
          orElse: () => HighwayMode.auto,
        );
      }
      developer.log('CarScreen: Loaded highway mode preference: $_highwayMode', name: 'CarPlay');
    } catch (e) {
      developer.log(
        'CarScreen: Error loading highway mode preference, using default (auto)',
        name: 'CarPlay',
        error: e,
      );
      _highwayMode = HighwayMode.auto;
    }
  }

  /// Save the highway mode preference to SharedPreferences
  Future<void> _saveHighwayModePreference(HighwayMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHighwayModeKey, mode.name);
      developer.log('CarScreen: Saved highway mode preference: $mode', name: 'CarPlay');
    } catch (e) {
      developer.log('CarScreen: Error saving highway mode preference', name: 'CarPlay', error: e);
    }
  }

  /// Cycle through highway modes: auto → on → off → auto
  Future<void> cycleHighwayMode() async {
    _highwayMode = switch (_highwayMode) {
      HighwayMode.auto => HighwayMode.on,
      HighwayMode.on => HighwayMode.off,
      HighwayMode.off => HighwayMode.auto,
    };
    developer.log('CarScreen: Cycled highway mode to: $_highwayMode', name: 'CarPlay');

    // Persist the preference
    await _saveHighwayModePreference(_highwayMode);

    // Update the cubit if it exists and is not closed
    if (_nearestStationsCubit?.isClosed == false) {
      _nearestStationsCubit?.setHighwayMode(_highwayMode);
      // Send updated state to native immediately
      _sendStationsToNative();
    }
  }

  // MARK: - Filter Support

  /// Latest Phrase-wrapped AppLocalizations, pushed in from the widget tree.
  /// Needed because this service has no BuildContext and otherwise can't reach
  /// Phrase's OTA-updated strings (lookupAppLocalizations returns baked-in ARB
  /// strings only — it bypasses the PhraseLocalizations delegate).
  AppLocalizations? _localizations;

  /// Resolve the current platform locale into an AppLocalizations instance.
  /// Falls back to English if the device locale is not supported.
  AppLocalizations get _l10n {
    if (_localizations != null) return _localizations!;
    final locale = PlatformDispatcher.instance.locale;
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return lookupAppLocalizations(locale);
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  /// Called from the widget tree whenever AppLocalizations changes
  /// (locale change, Phrase OTA update). Caches the instance and forwards
  /// to the nearest stations cubit so station formatting uses fresh strings.
  /// Re-pushes any currently-displayed data to native.
  ///
  /// The identity check guards against MaterialApp.builder rebuilds caused
  /// by unrelated state (theme changes, ancestor rebuilds) — without it,
  /// four async method-channel calls would fire on every rebuild.
  void updateLocalizations(AppLocalizations l10n) {
    if (identical(l10n, _localizations)) return;
    _localizations = l10n;
    _nearestStationsCubit?.updateLocalizations(l10n);
    if (_isCarSystemActive) {
      _sendUiStrings();
      _sendFilterDefinitions();
      _sendStationsToNative();
      _sendFavouritesToNative();
    }
  }

  /// Build filter definitions list to send to native.
  /// Supports three types: toggle, singleChoice, multipleChoice.
  List<Map<String, dynamic>> _buildFilterDefinitions() {
    final l10n = _l10n;
    final definitions = <Map<String, dynamic>>[];

    // --- Toggle filters ---
    final toggles = <String, String>{
      'available': l10n.available,
      'brandChargers': l10n.brandnameChargers.replaceAll('--brandname--', F.appBrandName),
      'remoteStart': l10n.supportsRemoteCharge,
      'dc': l10n.dCChargers,
    };

    // Hide brandChargers toggle for showBrandOnly flavors (e.g. Elexon, Opcharge)
    final hiddenKeys = <String>{
      if (F.mapBrandFilterType == MapBrandFilterType.showBrandOnly) 'brandChargers',
    };

    for (final entry in toggles.entries) {
      if (hiddenKeys.contains(entry.key)) continue;
      definitions.add({
        'key': entry.key,
        'label': entry.value,
        'type': 'toggle',
        'enabled': _filterStates[entry.key] ?? false,
      });
    }

    // --- Charging Power (singleChoice) ---
    final powerChildren = <Map<String, dynamic>>[
      {'key': 'powerSlow', 'label': l10n.carScreenPowerSlow, 'selected': _filterStates['powerSlow'] ?? false},
      {'key': 'powerFast', 'label': l10n.carScreenPowerFast, 'selected': _filterStates['powerFast'] ?? false},
      {'key': 'powerRapid', 'label': l10n.carScreenPowerRapid, 'selected': _filterStates['powerRapid'] ?? false},
      {'key': 'powerUltra', 'label': l10n.carScreenPowerUltra, 'selected': _filterStates['powerUltra'] ?? false},
    ];
    final selectedPower = powerChildren.where((c) => c['selected'] == true).toList();
    final powerSelectedLabel = selectedPower.isEmpty
        ? l10n.carScreenAll
        : selectedPower.first['label'] as String;

    definitions.add({
      'key': 'chargingPower',
      'label': l10n.carScreenChargingPower,
      'type': 'singleChoice',
      'selectedLabel': powerSelectedLabel,
      'children': powerChildren,
    });

    // --- Connector Type (multipleChoice) ---
    final connectorChildren = <Map<String, dynamic>>[
      {'key': 'connType1', 'label': ChargingConnectorTypes.humanReadableNameFor('IEC_62196_T1'), 'selected': _filterStates['connType1'] ?? false},
      {'key': 'connType2', 'label': ChargingConnectorTypes.humanReadableNameFor('IEC_62196_T2'), 'selected': _filterStates['connType2'] ?? false},
      {'key': 'connType3', 'label': ChargingConnectorTypes.humanReadableNameFor('IEC_62196_T3A'), 'selected': _filterStates['connType3'] ?? false},
      {'key': 'connChademo', 'label': ChargingConnectorTypes.humanReadableNameFor('CHADEMO'), 'selected': _filterStates['connChademo'] ?? false},
      {'key': 'connDomestic', 'label': ChargingConnectorTypes.humanReadableNameFor('DOMESTIC_F'), 'selected': _filterStates['connDomestic'] ?? false},
      {'key': 'connCombo', 'label': ChargingConnectorTypes.humanReadableNameFor('IEC_62196_T2_COMBO'), 'selected': _filterStates['connCombo'] ?? false},
    ];
    final selectedConnectors = connectorChildren.where((c) => c['selected'] == true).toList();
    final connectorSelectedLabel = selectedConnectors.isEmpty
        ? l10n.carScreenAll
        : selectedConnectors.length == 1
            ? selectedConnectors.first['label'] as String
            : l10n.carScreenCountSelected(selectedConnectors.length);

    definitions.add({
      'key': 'connectorType',
      'label': l10n.connectorType,
      'type': 'multipleChoice',
      'selectedLabel': connectorSelectedLabel,
      'children': connectorChildren,
    });

    return definitions;
  }

  /// Build and send all UI chrome strings to native so it can render
  /// localised text without hardcoding English.
  Future<void> _sendUiStrings() async {
    final l10n = _l10n;
    final uiStrings = <String, String>{
      'fastChargersAhead': l10n.carScreenFastChargersAhead,
      'nearbyStations': l10n.nearbyStations,
      'highway': l10n.carScreenHighway,
      'highwayAuto': l10n.carScreenHighwayAuto,
      'highwayOff': l10n.carScreenHighwayOff,
      'highwayOn': l10n.carScreenHighwayOn,
      'navigate': l10n.carScreenNavigate,
      'showDetails': l10n.carScreenShowDetails,
      'filters': l10n.filters,
      'filterOn': l10n.carScreenFilterOn,
      'filterOff': l10n.carScreenFilterOff,
      'searchingStations': l10n.carScreenSearchingStations,
      'noStationsFound': l10n.carScreenNoStationsFound,
      'navigationNotAvailable': l10n.carScreenNavigationNotAvailable,
      'navigationError': l10n.carScreenNavigationError,
      'navigateOnPhone': l10n.carScreenNavigateOnPhone,
      'noFiltersAvailable': l10n.carScreenNoFiltersAvailable,
      'tabMap': l10n.carScreenTabMap,
      'tabFilters': l10n.carScreenTabFilters,
      'tabFavourites': l10n.carScreenTabFavourites,
      'noFavourites': (_authCubit?.state.isLoggedIn ?? false)
          ? l10n.carScreenNoFavourites
          : l10n.carScreenLoginToSaveFavourites,
      'save': l10n.carScreenSave,
      'saved': l10n.carScreenSaved,
      'all': l10n.carScreenAll,
    };

    developer.log('CarScreen: Sending UI strings to native: ${uiStrings.keys}', name: 'CarPlay');

    try {
      await _nativeChannel.invokeMethod('sendUiStrings', uiStrings);
    } on PlatformException catch (e) {
      developer.log('CarScreen: Error sending UI strings', name: 'CarPlay', error: e.message);
    }
  }

  /// Send current filter definitions to native
  Future<void> _sendFilterDefinitions() async {
    final definitions = _buildFilterDefinitions();
    developer.log('CarScreen: Sending filter definitions to native: $definitions', name: 'CarPlay');

    try {
      await _nativeChannel.invokeMethod('sendFilterDefinitions', {
        'filters': definitions,
      });
    } on PlatformException catch (e) {
      developer.log('CarScreen: Error sending filter definitions', name: 'CarPlay', error: e.message);
    }
  }

  /// Handle a filter toggle from native UI
  void _handleFilterToggle(String key, bool enabled) {
    if (!_filterStates.containsKey(key)) {
      developer.log('CarScreen: Unknown filter key: $key', name: 'CarPlay');
      return;
    }

    developer.log('CarScreen: Filter toggled - $key: $enabled', name: 'CarPlay');

    // Power tiers are mutually exclusive — turn off siblings when one is turned on
    if (enabled && _powerKeys.contains(key)) {
      for (final powerKey in _powerKeys) {
        _filterStates[powerKey] = (powerKey == key);
      }
    } else {
      _filterStates[key] = enabled;
    }

    // Convert toggle states to API filter map
    final apiFilters = _buildApiFiltersFromState();

    // Update cubit with new filters (triggers re-fetch)
    if (_nearestStationsCubit?.isClosed == false) {
      _nearestStationsCubit?.setCarScreenFilters(apiFilters.isEmpty ? null : apiFilters);
    }

    // Send updated filter definitions back to native so UI reflects current state
    _sendFilterDefinitions();
  }

  /// Convert current filter toggle states to API filter parameters
  /// Uses the same format as ChargingLocationFilters.apiMap
  Map<String, dynamic> _buildApiFiltersFromState() {
    final data = <String, dynamic>{};

    if (_filterStates['available'] == true) {
      data['status'] = ['AVAILABLE'];
    }

    if (_filterStates['brandChargers'] == true ||
        F.mapBrandFilterType == MapBrandFilterType.showBrandOnly) {
      data['restrictToProvider'] = true;
    }

    if (_filterStates['dc'] == true) {
      data['powerType'] = 'dc';
    }

    if (_filterStates['remoteStart'] == true) {
      data['capabilities'] = [EvseCapabilities.remoteStartStopCapable];
      data['partyIds'] = _authCubit?.state.remoteSessionEnabledPartyIds ?? const ['EFL'];
      data['restrictToProvider'] = F.restrictMapCallsToProvider;
    }

    // Power tiers (mutually exclusive — only one can be active)
    if (_filterStates['powerSlow'] == true) {
      data['minPower'] = 3;
    } else if (_filterStates['powerFast'] == true) {
      data['minPower'] = 23;
    } else if (_filterStates['powerRapid'] == true) {
      data['minPower'] = 100;
    } else if (_filterStates['powerUltra'] == true) {
      data['minPower'] = 200;
    }

    // Connector types (multi-select — combine into one array)
    final connectorTypes = <String>[];
    for (final entry in _connectorApiValues.entries) {
      if (_filterStates[entry.key] == true) {
        connectorTypes.addAll(entry.value);
      }
    }
    if (connectorTypes.isNotEmpty) {
      data['connectorTypes'] = connectorTypes;
    }

    return data;
  }

  /// Reset all filter states to off (called on each new session)
  void _resetFilters() {
    _filterStates.updateAll((key, value) => false);
  }

  void _handleCarSystemInactive() {
    developer.log('CarScreen: Car system inactive - disposing cubit to stop backend calls', name: 'CarPlay');
    // Dispose the cubit entirely to stop all location processing and backend calls
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _nearestStationsCubit?.close();
    _nearestStationsCubit = null;
  }

  void _handleCarSystemActive() {
    developer.log('CarScreen: Car system active - initializing cubit', name: 'CarPlay');

    // Reset filters for new session
    _resetFilters();

    // Send localised UI strings to native before any UI is rendered
    _sendUiStrings();

    // Initialize the cubit when car system becomes active
    _initializeCubitIfNeeded();
    if (_nearestStationsCubit != null) {
      triggerLocationUpdate();
      // Send filter definitions to native once cubit is ready
      _sendFilterDefinitions();
    }

    // Send current favourites to native for the Favourites tab
    _sendFavouritesToNative();
  }

  void _initializeCubitIfNeeded() {
    // Create the cubit if car system is active
    if (_nearestStationsCubit == null && _isCarSystemActive) {
      developer.log(
        'CarScreen: Initializing NearestStationsCubit for CarPlay/Android Auto (highwayMode: $_highwayMode)',
        name: 'CarPlay',
      );
      _nearestStationsCubit = GetIt.instance<NearestStationsCubit>(
        param1: NearestStationsConfig(
          // CPPointOfInterestTemplate on iOS supports max 12 POIs
          stationLimit: 12,
          mode: NearestStationsMode.carScreen,
          highwayMode: _highwayMode,
        ),
      );
      // Forward any already-cached localizations so the cubit formats its
      // first batch of stations with Phrase OTA strings rather than the
      // ARB fallback. Without this, an immediate _sendStationsToNative()
      // below can race ahead of the widget-tree bridge's next rebuild.
      if (_localizations != null) {
        _nearestStationsCubit!.updateLocalizations(_localizations!);
      }
      // Sync current favourite IDs to the new cubit
      _syncFavouriteIds();
      _setupCubitListener();
    }
  }

  void _setupCubitListener() {
    if (_nearestStationsCubit == null) {
      developer.log('CarScreen: Cannot setup listener - cubit not initialized', name: 'CarPlay');
      return;
    }

    developer.log('CarScreen: Setting up listener for NearestStationsCubit', name: 'CarPlay');

    _stateSubscription = _nearestStationsCubit!.stream.listen((state) {
      if (state.flow.isError) {
        developer.log('CarScreen: Error from cubit - ${state.flow.error}', name: 'CarPlay');
        // Send empty list to clear any previous stations
        _sendLocationsWithModeState([], isHighwayModeActive: false);
      } else if (!state.flow.isLoading && state.stations.isNotEmpty) {
        developer.log(
          'CarScreen: Received ${state.stations.length} stations from cubit (highwayModeActive: ${state.isHighwayModeActive})',
          name: 'CarPlay',
        );
        _sendStationsToNative();
      }
    });

    // Check current state
    final currentState = _nearestStationsCubit!.state;
    if (!currentState.flow.isLoading && currentState.stations.isNotEmpty) {
      developer.log('CarScreen: Using current stations from cubit', name: 'CarPlay');
      _sendStationsToNative();
    }
  }

  void _sendStationsToNative() {
    if (_nearestStationsCubit == null || _nearestStationsCubit!.isClosed) {
      developer.log('CarScreen: Cannot send stations - cubit not initialized or closed', name: 'CarPlay');
      return;
    }

    final isLoggedIn = _authCubit?.state.isLoggedIn ?? false;
    final formattedLocations = _nearestStationsCubit!.getFormattedLocationsForCarScreen(isLoggedIn: isLoggedIn);
    final isHighwayModeActive = _nearestStationsCubit!.state.isHighwayModeActive;

    // An empty list is only meaningful once a fetch has concluded (established
    // with zero results, or error). Before that — e.g. auth/favourites stream
    // events firing while the first fetch is still loading — sending it would
    // make native show "no stations found" instead of the searching state.
    final flow = _nearestStationsCubit!.state.flow;
    if (formattedLocations.isEmpty && !flow.isEstablished && !flow.isError) {
      developer.log('CarScreen: Skipping empty station send - no fetch concluded yet', name: 'CarPlay');
      return;
    }

    developer.log(
      'CarScreen: Sending ${formattedLocations.length} formatted stations to native platform (highwayModeActive: $isHighwayModeActive, highwayMode: $_highwayMode)',
      name: 'CarPlay',
    );

    _sendLocationsWithModeState(formattedLocations, isHighwayModeActive: isHighwayModeActive);
  }

  Future<void> _sendLocationsWithModeState(
    List<Map<String, dynamic>> locations, {
    required bool isHighwayModeActive,
  }) async {
    developer.log('CarScreen: Sending ${locations.length} charging stations to native platform', name: 'CarPlay');

    // Log first few locations for debugging
    if (locations.isNotEmpty) {
      final preview = locations
          .take(3)
          .map((loc) => '{lat: ${loc['lat']}, lng: ${loc['lng']}, title: ${loc['title']}}')
          .join(', ');
      developer.log('CarScreen: First stations: $preview', name: 'CarPlay');
    }

    try {
      // Send locations along with mode state
      await _nativeChannel.invokeMethod('sendLocations', {
        'locations': locations,
        'isHighwayModeActive': isHighwayModeActive,
        'highwayMode': _highwayMode.name,
      });
      developer.log('CarScreen: Successfully sent locations to native platform', name: 'CarPlay');
    } on PlatformException catch (e) {
      developer.log(
        'CarScreen: ERROR - Failed to send locations via method channel',
        name: 'CarPlay',
        error: e.message,
        stackTrace: e.stacktrace is StackTrace ? e.stacktrace as StackTrace : null,
      );

      // Log all platform errors to Crashlytics for monitoring
      FirebaseCrashlytics.instance.recordError(
        e,
        e.stacktrace is StackTrace ? e.stacktrace as StackTrace : null,
        reason: 'CarPlay method channel error: ${e.code}',
        fatal: false,
      );
    }
  }

  // MARK: - Favourites Tab Support

  /// Send formatted favourite stations to native for the Favourites tab
  Future<void> _sendFavouritesToNative() async {
    final state = _favouritesCubit?.state;
    // Filter stations to only those still in the stationIds list
    // (toggle updates stationIds immediately but stations list can be stale)
    final stationIds = state?.stationIds.toSet() ?? {};
    final stations = (state?.stations ?? []).where((s) => stationIds.contains(s.id)).toList();
    final formattedFavourites = _formatStationsForCarScreen(stations, allAreFavourites: true);

    developer.log('CarScreen: Sending ${formattedFavourites.length} favourites to native', name: 'CarPlay');

    try {
      await _nativeChannel.invokeMethod('sendFavourites', {
        'favourites': formattedFavourites,
      });
    } on PlatformException catch (e) {
      developer.log('CarScreen: Error sending favourites', name: 'CarPlay', error: e.message);
    }
  }

  /// Format a list of MapLocationV2 objects for native car screen display.
  /// Uses the same output format as NearestStationsCubit.getFormattedLocationsForCarScreen().
  List<Map<String, dynamic>> _formatStationsForCarScreen(
    List<MapLocationV2> stations, {
    bool allAreFavourites = false,
  }) {
    final l10n = _l10n;
    final favouriteIds = _favouritesCubit?.state.stationIds.toSet() ?? {};

    return stations.map((location) {
      int availableCount = 0;
      int chargingCount = 0;
      int totalCount = location.evses.length;
      for (final evse in location.evses) {
        if (evse.chargingPortAvailability == ChargingPortAvailability.available) {
          availableCount++;
        } else if (evse.chargingPortAvailability == ChargingPortAvailability.charging) {
          chargingCount++;
        }
      }

      final maxPowerKw = location.evses.fold<double>(0, (max, evse) {
        final power = evse.maxPower ?? 0;
        return power > max ? power : max;
      });

      final title = location.subOperator?.name ?? location.name ?? location.id ?? '';
      final powerText = '${maxPowerKw.toInt()} kW';
      final availabilityText = l10n.carScreenAvailabilityCount(availableCount, totalCount);
      final priceText = car_fmt.extractPriceText(location, l10n);
      final connectorRows = car_fmt.buildConnectorRows(location, l10n);
      final city = location.city;
      final address = location.address ?? '';
      final addressText = (city != null && city.isNotEmpty && !address.contains(city)) ? '$address, $city' : address;
      final availabilityInfo = '$powerText - $availabilityText';
      final subtitle = addressText.isNotEmpty ? '$addressText · $availabilityInfo' : availabilityInfo;
      final summary = priceText;
      final detailSubtitle = '$availabilityText - $powerText';
      final detailSummary = location.address ?? '';

      final locationId = location.id ?? '';
      final isFavourite = allAreFavourites || favouriteIds.contains(locationId);
      final isLoggedIn = _authCubit?.state.isLoggedIn ?? false;
      final favouriteButtonLabel = isLoggedIn ? (isFavourite ? l10n.removeFromFavourites : l10n.addToFavourites) : '';

      return {
        'lat': location.geoLocation?.coordinates[1] ?? 0,
        'lng': location.geoLocation?.coordinates[0] ?? 0,
        'locationId': locationId,
        'evseId': location.evses.isNotEmpty ? (location.evses.first.evseId ?? '') : '',
        'availableCount': availableCount,
        'chargingCount': chargingCount,
        'totalCount': totalCount,
        'title': title,
        'subtitle': subtitle,
        'summary': summary,
        'detailSubtitle': detailSubtitle,
        'detailSummary': detailSummary,
        'connectorRows': connectorRows,
        'priceText': priceText,
        'addressText': addressText,
        'isFavourite': isFavourite,
        'favouriteButtonLabel': favouriteButtonLabel,
      };
    }).toList();
  }

  /// Manual trigger for debugging CarPlay charging station issues
  Future<void> triggerLocationUpdate() async {
    developer.log('CarScreen: DEBUG - Manually triggering location update', name: 'CarPlay');

    if (_nearestStationsCubit == null || _nearestStationsCubit!.isClosed) {
      developer.log('CarScreen: Cannot trigger update - cubit not initialized or closed', name: 'CarPlay');
      return;
    }

    // Use the cubit's refresh method with a limit of 3 for CarPlay
    await _nearestStationsCubit!.refresh();
  }

  void _setupMethodChannel() {
    developer.log('CarScreen: Setting up method channel for CarPlay events', name: 'CarPlay');

    _nativeChannel.setMethodCallHandler((call) async {
      developer.log('CarScreen: Received method call: ${call.method}', name: 'CarPlay');

      switch (call.method) {
        case 'carSystemStateChanged':
          final bool isActive = call.arguments as bool;
          final String stateDescription = isActive ? 'active' : 'inactive';
          developer.log('CarScreen: Car system state changed to: $stateDescription', name: 'CarPlay');

          final bool previousState = _isCarSystemActive;
          _isCarSystemActive = isActive;

          // Handle redundant messages gracefully
          if (previousState == isActive) {
            developer.log('CarScreen: Car system state unchanged (already $stateDescription)', name: 'CarPlay');
            return 'OK';
          }

          if (isActive) {
            _handleCarSystemActive();
          } else {
            _handleCarSystemInactive();
          }
          return 'OK';

        case 'locationPermissionChanged':
          // The car screen's native permission prompt was answered. Geolocator
          // has no callback for runtime permission grants and the headless
          // engine gets no foreground event, so re-run the service check to
          // unblock the location pipeline.
          developer.log('CarScreen: Location permission changed - rechecking service status', name: 'CarPlay');
          GetIt.instance<LocationBloc>().add(const LocationEvent.checkServiceStatus());
          return 'OK';

        case 'toggleHighwayMode':
          developer.log('CarScreen: Received toggleHighwayMode from native', name: 'CarPlay');
          await cycleHighwayMode();
          return 'OK';

        case 'toggleCarScreenFilter':
          final args = call.arguments as Map;
          final key = args['key'] as String;
          final enabled = args['enabled'] as bool;
          developer.log('CarScreen: Received toggleCarScreenFilter from native - $key: $enabled', name: 'CarPlay');
          _handleFilterToggle(key, enabled);
          return 'OK';

        case 'toggleFavourite':
          final args = call.arguments as Map;
          final locationId = args['locationId'] as String;
          developer.log('CarScreen: Received toggleFavourite from native - $locationId', name: 'CarPlay');
          _handleToggleFavourite(locationId);
          return 'OK';

        default:
          developer.log('CarScreen: Unknown method call: ${call.method}', name: 'CarPlay');
          throw PlatformException(code: 'NOT_IMPLEMENTED', message: 'Method ${call.method} not implemented');
      }
    });
  }
}
