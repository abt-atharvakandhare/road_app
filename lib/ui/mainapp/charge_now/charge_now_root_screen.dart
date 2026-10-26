import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_cubit.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_navigation_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';

import 'widgets/car_is_charging_widget.dart';
import 'widgets/charge_session_ended_widget.dart';
import 'widgets/initial_charge_flow_widget.dart';
import 'widgets/detect_location_widget.dart';
import 'widgets/is_this_you_widget.dart';
import 'widgets/manual_evse_id_input_widget.dart';
import 'widgets/qr_scanner_widget.dart';
import 'widgets/select_card_widget.dart';
import 'widgets/select_your_charge_station_widget.dart';

class ChargeNowRootScreen extends StatelessWidget {
  const ChargeNowRootScreen({super.key, this.postAuthEvent});

  final ChargeNowEvent? postAuthEvent;
  static final GlobalKey _presentationKey = GlobalKey();

  /// Requires a LocationBloc and ChargeNowBloc to be available in the context.
  /// Supply a postAuthEvent to be added to the ChargeNowBloc after the user has logged in, or immediately if the
  /// user is already logged in.
  static void pushAsModal(BuildContext context, {ChargeNowEvent? chargeEvent}) {
    if (chargeEvent != null) {
      if (BlocProvider.of<AuthCubit>(context).state case LoggedIn()) {
        BlocProvider.of<ChargeNowBloc>(context).add(chargeEvent);
      }
    }

    if (_presentationKey.currentContext != null) {
      return;
    }

    // Track Charge Now page view
    getIt<MixpanelService>().trackPageView(MixpanelPageUrl.chargeNow);

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: ((routeContext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: BlocProvider.of<ChargeNowBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<LocationBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<MainAppRootNavigationCubit>(context)),
              BlocProvider.value(value: BlocProvider.of<MapBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<MapOverlayBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<AuthCubit>(context)),
              BlocProvider(create: (context) => getIt<AddCreditCardCubit>()),
            ],
            child: ChargeNowRootScreen(key: _presentationKey, postAuthEvent: chargeEvent),
          );
        }),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        final wasLoggedOut = switch (previous) {
          LoggedOut() => true,
          _ => false,
        };
        final isLoggedIn = switch (current) {
          LoggedIn() => true,
          _ => false,
        };
        return wasLoggedOut && isLoggedIn;
      },
      listener: (context, state) {
        if (postAuthEvent != null) {
          BlocProvider.of<ChargeNowBloc>(context).add(postAuthEvent!);
        }
      },
      builder: (context, state) {
        return switch (state) {
          LoggedIn(profile: _, token: _, flow: _) => _buildChargeNowRootScreen(context),
          _ => LoginScreen(isModal: false),
        };
      },
    );
  }

  Widget _buildChargeNowRootScreen(BuildContext context) {
    return BlocConsumer<AddCreditCardCubit, AddCreditCardState>(
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      },
      builder: (context, addCreditCardState) {
        return BlocConsumer<ChargeNowBloc, ChargeNowState>(
          listener: (context, state) {
            if (state.flow.isError) {
              getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
            }
          },
          builder: (context, state) {
            final canGoBack = BlocProvider.of<ChargeNowBloc>(context).canGoBackInState(state);
            return PopScope(
              canPop: !canGoBack,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.backButtonTapped());
                } else {
                  BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.modalFlowDismissed());
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leading: BlocProvider.of<ChargeNowBloc>(context).canGoBackInState(state)
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.backButtonTapped());
                          },
                        )
                      : null,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                body: _buildBody(context, state),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ChargeNowState state) {
    final body = switch (state) {
      ConnectYourCar() => const InitialChargeFlowWidget(),
      Location(userLocation: final location, evseLocations: final locations) =>
        DetectLocationWidget(searchLocation: location, searchLocations: locations),
      IsThisYou(evseLocation: final location) => IsThisYouWidget(selectedLocation: location),
      SelectYourChargeStation(evseLocations: final evseLocations) =>
        SelectYourChargeStationWidget(nearbyLocations: evseLocations),
      ManualEvseIdInput() => const ManualEvseIdInputWidget(),
      ScanningQrCode() => const QrScannerWidget(),
      StartChargingSession(
        chargingStartMetadata: final locationMetadata,
        cards: final availableCards,
        selectedCard: final selectedCard,
        preAuthLimits: final preAuthLimits,
      ) =>
        StartChargingSessionWidget(
          locationMetadata: locationMetadata,
          availablePaymentInstruments: availableCards,
          selectedPaymentInstrument: selectedCard,
          preAuthLimits: preAuthLimits,
        ),
      ChargeSessionStarting(session: final session, card: final card, attemptedStartTime: final attemptedStartTime) =>
        CarIsChargingWidget(
          isStarting: true,
          session: session,
          card: card,
          chargingValues: null,
          attemptedStartTime: attemptedStartTime,
        ),
      CarIsCharging(session: final session, card: final card, currentChargingValues: final chargingValues) =>
        CarIsChargingWidget(
          isStarting: false,
          session: session,
          card: card,
          chargingValues: chargingValues,
        ),
      ChargeSessionStopping(session: final session, card: final card) =>
        ChargeSessionEndedWidget(isStopping: true, session: session, card: card),
      ChargeSessionEnded(session: final session, card: final card) =>
        ChargeSessionEndedWidget(isStopping: false, session: session, card: card),
    };

    return BlocProvider(
      create: (context) => getIt<NotificationsCubit>(),
      // Mirror the user's `charging.session.live_update` topic subscription into the
      // bloc so its dispatcher gate can skip the live activity / FGS when off. This
      // listener fires once per cubit emission (including the initial load), keeping
      // the bloc's flag in sync without it needing to know about the cubit.
      child: BlocListener<NotificationsCubit, NotificationsState>(
        listener: (context, notificationsState) {
          BlocProvider.of<ChargeNowBloc>(context)
              .setLiveUpdateNotificationsEnabled(notificationsState.isLiveUpdateEnabled);
        },
        child: body,
      ),
    );
  }
}
