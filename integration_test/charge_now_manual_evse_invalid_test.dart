import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/manual_evse_id_input_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Edge-case validation test: Charge Now → manual EVSE ID input → too-short input
// leaves the Continue button disabled (client-side gate), the flow does NOT advance
// to StartChargingSession, and no backend charge is initiated.
//
// Shape: boot → log in → AppTab.explore (opens ChargeNowRootScreen modal) →
// tap "Manually input station ID" → enter a 6-char string (one short of the
// required minimum 7) → assert Continue is disabled and the widget tree has not
// advanced past ManualEvseIdInputWidget.
//
// Client-side validation gate:
//   ManualEvseIdInputWidget passes `onPressed: null` to RMTextButton whenever
//   the controller text length is < 7 (lib/ui/mainapp/charge_now/widgets/
//   manual_evse_id_input_widget.dart, line ~90). No ARB error string is shown
//   inline — the only observable effect is a disabled Continue button (rendered
//   at 50 % opacity) and the flow not advancing. A 6-char input ("123456") is
//   therefore purely client-side invalid: zero network requests are made.
//
// Prerequisite: a logged-in staging account.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…
// Default account: ray+uk3@road.io. No special data needed beyond login.
//
// NEVER pumpAndSettle — e2eConfig sets SettlePolicy.noSettle globally (see
// _helpers/scenario.dart). Readiness is asserted on concrete widgets.

void main() {
  e2eTest(
    'charge now manual EVSE: too-short ID keeps Continue disabled and does not start a charge',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Open Charge Now. AppTab.explore maps to the centre lightning-bolt tab
      // which calls ChargeNowRootScreen.pushAsModal — a fullscreenDialog route.
      // The modal always opens on InitialChargeFlowWidget (ConnectYourCar state).
      await tapTab($, AppTab.explore);

      // Wait on the 'Charge Now' title Text inside the modal — it is a concrete
      // hit-testable leaf rendered immediately from the idle bloc state. Avoids
      // waitUntilVisible on a container widget (not hit-testable).
      await $(ChargeNowRootScreen).$('Charge Now').waitUntilVisible();
      expect(
        $(ChargeNowRootScreen),
        findsOneWidget,
        reason: 'ChargeNowRootScreen must be mounted after tapping the explore tab',
      );

      // Tap "Manually input station ID". This dispatches
      // ChargeNowEvent.manualEvseIdInputTapped and transitions the bloc to the
      // ManualEvseIdInput state, swapping in ManualEvseIdInputWidget as the body.
      await $('Manually input station ID').waitUntilVisible();
      await $('Manually input station ID').tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for ManualEvseIdInputWidget's TextField to be present.
      // ManualEvseIdInputWidget is a StatefulWidget inside a SingleChildScrollView;
      // it is built immediately once the bloc emits ManualEvseIdInput.
      await $(ManualEvseIdInputWidget).$(TextField).waitUntilVisible();

      // Enter a 6-character string — one short of the 7-char minimum.
      // ManualEvseIdInputWidget sets RMTextButton.onPressed to null when
      // _controller.text.length < 7, so this input is client-side invalid with
      // zero network activity. The numeric keyboard type accepts digits; "123456"
      // is a well-formed but too-short EVSE identifier.
      await $(ManualEvseIdInputWidget).$(TextField).enterText(
        '123456',
        settlePolicy: SettlePolicy.noSettle,
      );

      // Give Flutter one frame to rebuild the widget with the updated controller
      // text so the RMTextButton's onPressed state reflects the new length.
      await $.tester.pump();

      // ── Assertion 1: Continue button is present but disabled ──────────────────
      // RMTextButton renders as a TextButton whose onPressed is null when the
      // input is too short. The button is visible (opacity 0.5) and the text
      // "Continue" is in the tree, but it will not respond to taps.
      // waitUntilExists (not waitUntilVisible) because RMTextButton is a
      // container that may not register as hit-testable when disabled.
      await $(ManualEvseIdInputWidget).$(RMTextButton).waitUntilExists();
      expect(
        $(ManualEvseIdInputWidget).$('Continue'),
        findsOneWidget,
        reason:
            'the Continue button text must still be visible with a 6-char input '
            '(the button is disabled, not hidden)',
      );

      // Verify the underlying TextButton has onPressed == null (disabled).
      // Flutter renders TextButton(onPressed: null) — WidgetTester exposes this
      // so we can confirm the client-side gate is actually engaged.
      final textButton = $.tester.widget<TextButton>(
        find.descendant(
          of: find.byType(ManualEvseIdInputWidget),
          matching: find.byType(TextButton),
        ),
      );
      expect(
        textButton.onPressed,
        isNull,
        reason:
            'TextButton.onPressed must be null for a 6-char EVSE ID — the '
            'client-side length guard in ManualEvseIdInputWidget requires ≥ 7 chars',
      );

      // ── Assertion 2: flow has NOT advanced ────────────────────────────────────
      // ManualEvseIdInputWidget must still be in the tree; a successful submission
      // would have replaced it with StartChargingSessionWidget.
      expect(
        $(ManualEvseIdInputWidget),
        findsOneWidget,
        reason:
            'ManualEvseIdInputWidget must remain mounted — the disabled Continue '
            'button must not dispatch ChargeNowEvent.manualEvseIdSubmitted',
      );

      // The StartChargingSession step renders a "Pay with" label at the top of
      // the payment section. Its absence confirms the flow did not advance.
      expect(
        $('Pay with'),
        findsNothing,
        reason:
            'the StartChargingSession "Pay with" label must be absent — the flow '
            'must not have advanced past ManualEvseIdInputWidget',
      );

      // ── Assertion 3: no error dialog ──────────────────────────────────────────
      // ModalInfoDialogs.showErrorDialog surfaces as an AlertDialog. With a
      // client-side-blocked submission no API call is made, so no error dialog
      // should appear.
      expect(
        $(AlertDialog),
        findsNothing,
        reason:
            'no AlertDialog must appear — a client-side disabled button produces '
            'no network request and therefore no error response',
      );
    },
  );
}
