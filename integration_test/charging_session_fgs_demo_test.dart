import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/car_is_charging_widget.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/charge_session_ended_widget.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/select_card_widget.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/select_your_charge_station_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loading_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/scroll.dart';
import '_helpers/toggle.dart';

// Full charging-session flow, choreographed so the BrowserStack session video
// doubles as Google Play foreground-service declaration evidence: it must show
// the ongoing FGS notification (kWh + elapsed time) in the notification shade
// while the app is backgrounded, then the user stopping the session in-app.
//
// Flow: boot → log in → Charge Now → manual EVSE ID → select card → start
// charge → wait for the session to become active → ensure charging
// notifications are on (cycling the in-widget switch so the POST_NOTIFICATIONS
// permission is freshly requested and granted — the FGS is gated on both the
// `charging.session.live_update` topic AND the OS permission, and a fresh
// install always needs the runtime grant on Android 13+) → home → open the
// notification shade and linger ~10s → back into the app → end the session →
// session-ended screen.
//
// **PREREQUISITE: a staging EVSE connector with the charging simulator
// attached and auto-accepting remote starts.** Pass the 7-digit connector
// number via --dart-define=TEST_EVSE_ID=…; without it the test logSkips so the
// full-suite run stays green.
//
// **PREREQUISITE: an account with a saved payment card.** The card cannot be
// added by automation (native Checkout.com secure entry) — use the dedicated
// recordings account with the Checkout test card already saved.
//
// **WL flavors: pass E2E_PROVIDER_SLUG=e-flux.** Staging doesn't host most
// white-label provider slugs (they 404 on /1/providers/public/), so WL runs
// seed the provider override to log in against the E-Flux staging provider
// (see _helpers/reset.dart).
//
// NEVER pumpAndSettle — e2eConfig sets SettlePolicy.noSettle globally. While
// the app is BACKGROUNDED use Future.delayed, not pump (no frames are being
// produced, so a pump-based pause can hang — same pattern as
// invalidate_jwt_renews_test.dart).

const _testEvseId = String.fromEnvironment('TEST_EVSE_ID');

/// Remote start/stop round-trips go app → API → OCPP → simulator and back, so
/// session state changes can take minutes on staging.
const _sessionTransitionTimeout = Duration(minutes: 4);

void main() {
  e2eTest(
    'charging session FGS demo (start charge, ongoing notification, stop)',
    ($) async {
      requireCredentials();
      if (_testEvseId.isEmpty) {
        logSkip('fgs_demo: needs --dart-define=TEST_EVSE_ID with the SIM attached.');
        return;
      }

      await bootLoginEnrolled($);

      // Open Charge Now (the centre lightning-bolt tab pushes it as a modal,
      // always opening on the initial ConnectYourCar state).
      await tapTab($, AppTab.explore);
      await $(ChargeNowRootScreen).$('Charge Now').waitUntilVisible();

      await $('Manually input station ID').waitUntilVisible();
      await $('Manually input station ID').tap();

      await $(TextField).waitUntilVisible();
      await $(TextField).enterText(_testEvseId);
      await $('Continue').waitUntilVisible();
      await $('Continue').tap();

      // A multi-connector EVSE (4185044 exposes C1 + C2) inserts the "Select
      // your charge station" step here; tap the first connector row. A
      // single-connector EVSE goes straight to the StartChargingSession step,
      // so the step is a branch, not an assertion.
      final connectorRow = $(SelectYourChargeStationWidget).$(RMLoadingInkwellButton);
      final selectDeadline = DateTime.now().add(const Duration(seconds: 60));
      while (DateTime.now().isBefore(selectDeadline)) {
        if ($('Pay with').exists) break;
        if (connectorRow.exists) {
          // The row can unmount between the exists check and the tap (the bloc
          // may advance the step on its own) — treat a failed tap as "state
          // moved on" and keep polling rather than hard-failing.
          try {
            await connectorRow.first.tap(settlePolicy: SettlePolicy.noSettle);
            break;
          } catch (_) {
            continue;
          }
        }
        await $.tester.pump(const Duration(milliseconds: 100));
      }

      // StartChargingSession step: the bloc resolves the EVSE, cards, and
      // pre-auth limits against staging first — allow well over the default
      // existsTimeout.
      await $('Pay with').waitUntilVisible(timeout: const Duration(seconds: 60));
      expect($(StartChargingSessionWidget), findsOneWidget);

      // The account's default card is preselected by the bloc; if the account
      // has cards but no default, pick the first one from the picker sheet.
      final selectedCard = $(StartChargingSessionWidget).$(RMCardDisplayWidget);
      if (!selectedCard.exists) {
        await $(StartChargingSessionWidget).$(RMInkwellButton).tap();
        final cardRow = $(RMCardDisplayWidget);
        await cardRow.waitUntilVisible();
        await cardRow.first.tap();
        // Scope to the sheet: ChargeNowRootScreen (a fullscreen dialog route)
        // has its own Icons.close, and an unscoped tap would dismiss the whole
        // flow. The picker is the only BottomSheet up at this point.
        await $(BottomSheet).$(Icons.close).tap();
        await selectedCard.waitUntilExists();
      }

      // Start the charge. The button sits at the bottom of the scrollable
      // content and is only enabled when a card is selected AND the connector
      // reports Available — if this stays disabled, the SIM isn't attached or
      // the connector is occupied.
      final startButton = $(StartChargingSessionWidget).$(RMTextButton);
      await scrollIntoView($, startButton);
      await startButton.tap();

      await $(CarIsChargingWidget).waitUntilExists(timeout: _sessionTransitionTimeout);

      // Wait for the session to become ACTIVE (not just starting): the
      // end-session button is the structural signal — CarIsChargingWidget
      // passes onPressed: null while isStarting.
      final endButton = $(CarIsChargingWidget).$(RMTextButton);
      final deadline = DateTime.now().add(_sessionTransitionTimeout);
      var sessionActive = false;
      while (DateTime.now().isBefore(deadline)) {
        final matches = endButton.evaluate();
        if (matches.isNotEmpty) {
          final button = matches.first.widget as RMTextButton;
          if (button.onPressed != null && !button.isLoading) {
            sessionActive = true;
            break;
          }
        }
        await $.tester.pump(const Duration(milliseconds: 250));
      }
      expect(
        sessionActive,
        isTrue,
        reason: 'the charging session should become active within '
            '${_sessionTransitionTimeout.inMinutes} minutes — check the SIM is '
            'attached to $_testEvseId and delivering energy',
      );

      // Ensure the FGS actually starts: cycle the charging-notifications
      // switch OFF → ON. The account-level topic may already be on, but on a
      // fresh install the OS permission is not — and the dispatcher skips the
      // FGS silently in that case. Re-enabling requests POST_NOTIFICATIONS
      // (granted via the native dialog) and re-fires checkChargingStatus,
      // which starts the service.
      final notifSwitch = $(CarIsChargingWidget).$(Switch);
      await notifSwitch.waitUntilExists();
      if (readSwitch(notifSwitch) == true) {
        await setSwitch($, notifSwitch, on: false);
      }
      await setSwitch($, notifSwitch, on: true, grantsPermissionWhenEnabled: true);

      // Let the in-app session screen (kWh + elapsed time) register on the
      // video, and give the FGS a beat to post its notification.
      await pause($, 3000);

      // The money shot for the Play declaration: app backgrounded, shade open,
      // FGS notification ticking. Real delays only — no frames while
      // backgrounded.
      await $.native2.pressHome();
      await Future<void>.delayed(const Duration(seconds: 2));
      await $.native2.openNotifications();
      await Future<void>.delayed(const Duration(seconds: 10));
      await $.native2.pressBack();
      await Future<void>.delayed(const Duration(seconds: 1));
      await $.native2.openApp();

      // End the session and wait for the ended screen (another remote
      // round-trip). The FGS tears down with it.
      await $(CarIsChargingWidget).waitUntilExists();
      await scrollIntoView($, endButton);
      await endButton.tap();
      await $(ChargeSessionEndedWidget).waitUntilExists(timeout: _sessionTransitionTimeout);
      expect($(ChargeSessionEndedWidget), findsOneWidget);
    },
  );
}
