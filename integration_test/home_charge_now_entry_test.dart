import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/initial_charge_flow_widget.dart';
import 'package:road_mobile/ui/mainapp/home/home_root_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_action_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Revenue-critical entry-point test: tap "Charge Now" on the Home tab, verify
// the Charge Now modal opens on its initial screen, then close it WITHOUT
// starting a charge.
//
// Shape: boot onto staging → log in → tap Home tab → assert readiness on the
// "Charge Now" CTA → tap the CTA → assert ChargeNowRootScreen modal opened on
// InitialChargeFlowWidget → tap the close (×) button → assert modal dismissed.
//
// Prerequisite: logged-in staging account. Credentials via
// --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…
// Default account: ray+uk3@road.io. No special data needed.
//
// ──────────────────────────────────────────────────────────────────────────────
// NO pumpAndSettle — EVER (read before modifying this test)
// ──────────────────────────────────────────────────────────────────────────────
// The home screen hosts a NearestStationsScreen loader and a HomeScreenMapWidget
// that animate continuously. noSettle is active globally via e2eConfig
// (SettlePolicy.noSettle). Never pumpAndSettle here — it will hang to
// settleTimeout every time.
// ──────────────────────────────────────────────────────────────────────────────
//
// The "Charge Now" CTA is RMDecoratedActionButton → the text 'Charge Now' is
// scoped inside HomeRootScreen to avoid matching the same string rendered as the
// modal title inside InitialChargeFlowWidget.
//
// The modal renders ChargeNowRootScreen (via MaterialPageRoute fullscreenDialog).
// Its initial body is InitialChargeFlowWidget, which shows a 'Charge Now' title
// text plus three option rows (Find nearby EV stations / Manually input station
// ID / Scan station QR code). Readiness is asserted on the 'Charge Now' title
// text inside ChargeNowRootScreen — a concrete, hit-testable Text leaf rendered
// immediately from ChargeNowBloc's ConnectYourCar (idle) state.
//
// Dismissal: the AppBar's close IconButton (Icons.close) pops the modal route
// without touching any charging flow.

void main() {
  e2eTest(
    'home charge now entry: modal opens on initial screen and closes without starting a charge',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // bootLoginEnrolled lands on the Account tab. Switch to Home.
      // tapTab uses noSettle — do NOT pumpAndSettle; the home screen has
      // continuously-animating widgets.
      await tapTab($, AppTab.home);

      // Wait for readiness: the 'Charge Now' Text inside HomeRootScreen is
      // rendered immediately by ChargeNowBloc's idle (ConnectYourCar) state. It
      // needs no network fetch. Scoping to HomeRootScreen avoids false-positive
      // matches on 'Charge Now' text in any other widget tree position.
      await $(HomeRootScreen).$('Charge Now').waitUntilVisible();

      // Verify the CTA widget is present before tapping.
      expect(
        $(HomeRootScreen).$(RMDecoratedActionButton),
        findsOneWidget,
        reason: 'RMDecoratedActionButton (Charge Now) should be present on the home screen',
      );

      // Tap the Charge Now CTA. This calls ChargeNowRootScreen.pushAsModal which
      // pushes a fullscreenDialog MaterialPageRoute. Using noSettle — the modal
      // may open with an animation that never reaches idle.
      await $(HomeRootScreen).$('Charge Now').tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for the modal to appear. ChargeNowRootScreen is the widget at the
      // root of the pushed route. Its 'Charge Now' title text (inside
      // InitialChargeFlowWidget) is a concrete hit-testable leaf — use it as the
      // readiness signal rather than waitUntilVisible on the container (which
      // would fail because layout containers are not hit-testable themselves).
      await $(ChargeNowRootScreen).$('Charge Now').waitUntilVisible();

      // Assert the modal root is present.
      expect(
        $(ChargeNowRootScreen),
        findsOneWidget,
        reason: 'ChargeNowRootScreen should be mounted after tapping the Charge Now CTA',
      );

      // Assert the initial body is InitialChargeFlowWidget (ConnectYourCar state).
      // This is a layout container, not hit-testable — use waitUntilExists + findsOneWidget.
      expect(
        $(ChargeNowRootScreen).$(InitialChargeFlowWidget),
        findsOneWidget,
        reason:
            'InitialChargeFlowWidget should be the initial body of the modal '
            '(ChargeNowBloc starts in the ConnectYourCar state)',
      );

      // Verify the three option rows that InitialChargeFlowWidget always renders.
      // These are hit-testable Text leaves — no network fetch is needed for them.
      expect(
        $(ChargeNowRootScreen).$('Find nearby EV stations'),
        findsOneWidget,
        reason: 'Find nearby EV stations option should be visible in the initial charge flow',
      );
      expect(
        $(ChargeNowRootScreen).$('Manually input station ID'),
        findsOneWidget,
        reason: 'Manually input station ID option should be visible in the initial charge flow',
      );
      expect(
        $(ChargeNowRootScreen).$('Scan station QR code'),
        findsOneWidget,
        reason: 'Scan station QR code option should be visible in the initial charge flow',
      );

      // No error dialog should be present. ModalInfoDialogs.showErrorDialog wraps
      // content in a standard Material AlertDialog. An error here would indicate
      // ChargeNowBloc threw an auth/network error on entry.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should be present on opening the Charge Now modal',
      );

      // Close the modal WITHOUT starting a charge. The AppBar always shows a
      // close IconButton (Icons.close) in its actions list — tapping it calls
      // Navigator.of(context).pop() and sends ChargeNowEvent.modalFlowDismissed.
      await $(ChargeNowRootScreen).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);

      // The modal pops with a fullscreen-dialog transition, so the route lingers
      // mid-animation — poll until it's gone before asserting (an immediate
      // findsNothing races the dispose).
      await waitUntilGone($, $(ChargeNowRootScreen));
      expect(
        $(ChargeNowRootScreen),
        findsNothing,
        reason: 'ChargeNowRootScreen should be gone after tapping the close button',
      );
      await $(HomeRootScreen).$('Charge Now').waitUntilVisible();

      // Confirm we are back on the home screen with no error dialog.
      expect(
        $(HomeRootScreen),
        findsOneWidget,
        reason: 'HomeRootScreen should still be present after dismissing the modal',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should be present after closing the modal',
      );
    },
  );
}
