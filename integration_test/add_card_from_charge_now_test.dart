import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/add_address_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/select_card_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Revenue-critical entry-point test: open the Charge Now modal, navigate to the
// "select card" step via manual EVSE ID, assert the add-payment-method entry is
// present (the path distinct from Wallet → Payments → Add), and open it.
//
// **PREREQUISITE: account with NO saved payment method.**
// With a card already saved the select-card step renders an `RMCardDisplayWidget`
// row instead of the "No cards available" / "Add payment method" inline button.
// `ray+uk3@road.io` already HAS a card — it is NOT suitable for this test.
// Use a fresh staging account (no payment instrument) set up for the qa-no-card
// fixture (see tasks/todo-e2e-test-suite-plan.md).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…
//
// **PREREQUISITE: a valid staging EVSE connector ID.**
// Reaching the select-card step requires the ChargeNow bloc to look up a real EVSE
// connector on the staging API. Pass the 7-digit connector number via
// --dart-define=TEST_EVSE_ID=…  (e.g. the staging E-Flux test fixture connector).
//
// **CHECKOUT.COM FLOW SDK NATIVE BOUNDARY.**
// The add-card UI beyond the button tap is the native Checkout.com Flow SDK
// (iOS: CheckoutFlow.xcframework / Android: checkout-sdk-flow). Patrol cannot
// drive native SDK views. This test therefore asserts up to one of two boundaries:
//   a) AddAddressScreen — pushed by AddCreditCardCubit when the account has no
//      billing address on file (the common case for fresh accounts).
//   b) The add-payment-method TextButton being present and tappable — reached
//      immediately when address is already complete; the next action is a native
//      MethodChannel call that opens the Checkout Flow SDK outside Flutter's
//      widget tree.
// In either case the test documents the observable boundary and stops there.

const _testEvseId = String.fromEnvironment('TEST_EVSE_ID');

void main() {
  e2eTest(
    'add card from Charge Now: select-card step shows add-payment-method entry',
    ($) async {
      requireCredentials();
      if (_testEvseId.isEmpty) {
        // Skip (not fail) when unconfigured: this test needs BOTH a no-card
        // account and a staging connector id, neither of which the shared
        // full-suite run has. Keeps the suite green; run it explicitly with
        // --dart-define=TEST_EVSE_ID=… and a no-card TEST_EMAIL.
        logSkip('add_card: needs --dart-define=TEST_EVSE_ID and a no-card account.');
        return;
      }

      await bootLoginEnrolled($);

      // Open Charge Now. AppTab.explore is the centre lightning-bolt button; it
      // calls ChargeNowRootScreen.pushAsModal — no tab switch, just a modal push.
      // The modal always opens on the InitialChargeFlowWidget (ConnectYourCar state).
      await tapTab($, AppTab.explore);
      await $(ChargeNowRootScreen).waitUntilVisible();

      // Choose "Manually input station ID" to get to the StartChargingSession step
      // without requiring GPS / location permission. This is the most deterministic
      // path through the flow in a test harness.
      await $('Manually input station ID').waitUntilVisible();
      await $('Manually input station ID').tap();

      // ManualEvseIdInputWidget: enter the staging connector number and submit.
      // The TextField accepts a 7-digit numeric ID (the suffix of the full EVSE ID).
      await $(TextField).waitUntilVisible();
      await $(TextField).enterText(_testEvseId);

      // "Continue" button enables once the input has ≥7 chars.
      await $('Continue').waitUntilVisible();
      await $('Continue').tap();

      // Wait for StartChargingSessionWidget. The bloc makes two API calls
      // (getChargingLocationsWithSearchId + getMyPaymentCards + getPreAuthLimits),
      // each of which can take a few seconds on staging.
      // The widget renders a "Pay with" label at the top of the payment section —
      // that's the first visible sign that the bloc has emitted StartChargingSession.
      await $('Pay with').waitUntilVisible();
      expect(
        $(StartChargingSessionWidget),
        findsOneWidget,
        reason: 'the manual EVSE ID should resolve to the StartChargingSession step',
      );

      // The "No cards available" label is only present when the account has zero
      // payment instruments (the qa-no-card fixture). If this assertion fails the
      // most likely cause is that the account has a saved card — use the correct
      // fixture account.
      await $('No cards available').waitUntilVisible();
      expect(
        $('No cards available'),
        findsOneWidget,
        reason: 'account must have no saved payment method (qa-no-card fixture)',
      );

      // The _AddCardButton TextButton is rendered inline below the "No cards available"
      // label whenever AuthState.canAddCreditCard is true (the default for new accounts).
      // Its text is '+ Add payment method' (the ARB key `addPaymentMethod` run through
      // String.capitalized: first char upper, rest lower).
      await $('+ Add payment method').waitUntilVisible();
      expect(
        $('+ Add payment method'),
        findsOneWidget,
        reason: '_AddCardButton should be visible when the account can add a card',
      );

      // Tap the button. AddCreditCardCubit.startAddPaymentMethodFlow is called.
      // What happens next depends on the account's billing address:
      //   - Address MISSING → AddAddressScreen is pushed (a full-screen Flutter
      //     route — assertable below).
      //   - Address PRESENT → the cubit immediately invokes the native MethodChannel
      //     ('addPaymentCard') and opens the Checkout Flow SDK. Patrol cannot drive
      //     the native SDK UI; the test stops here at that boundary.
      await $('+ Add payment method').tap();

      // Assert the add-card entry point opened. For a fresh account (no address),
      // AddAddressScreen is the expected landing. If the account already has an
      // address the next screen is the native Checkout SDK (outside Flutter's
      // widget tree) — in that case this wait will time out, which is the signal
      // that the SDK boundary was hit. Document that outcome in the test run.
      await $(AddAddressScreen).waitUntilVisible();
      expect(
        $(AddAddressScreen),
        findsOneWidget,
        reason:
            'tapping "Add payment method" from Charge Now should open AddAddressScreen '
            '(for accounts without a billing address on file); if this fails the '
            'account already has an address and the Checkout SDK boundary was hit instead',
      );
    },
  );
}
