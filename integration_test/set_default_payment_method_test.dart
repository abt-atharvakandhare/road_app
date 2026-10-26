import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/widgets/select_card_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/tick_radio_list_tile.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Navigates to the charge-now payment-picker and moves the default card
// selection from card[0] to card[1], then asserts the picker's
// TickRadioListTile list re-renders with ≥ 2 rows (confirming the selection
// was accepted by the bloc without error) and that the outer
// StartChargingSessionWidget still shows exactly one RMCardDisplayWidget (the
// new selected card).
//
// PRECONDITIONS:
//   • ≥ 2 saved payment methods on the account (credit cards and/or RFID cards).
//   • A valid staging EVSE connector ID to reach the StartChargingSession step.
//
// IMPORTANT: this test mutates in-memory state only — it changes the selected
// card inside ChargeNowBloc.StartChargingSession but does NOT start a real
// charging session. setDefaultCard() (which writes to SharedPreferences) is
// only called after a real charge starts; that side-effect is intentionally
// out-of-scope for this UI-layer test. The "default indicator" asserted here
// is the TickRadioListTile selection inside the charge-now payment picker.
//
// RUN WITH:
//   --dart-define=RUN_PAYMENT_MUTATIONS=true
//   --dart-define=TEST_EMAIL=…
//   --dart-define=TEST_PASSWORD=…
//   --dart-define=TEST_EVSE_ID=…   (7-digit connector number on staging)

const _testEvseId = String.fromEnvironment('TEST_EVSE_ID');

void main() {
  e2eTest(
    'set default payment method: selection moves from card 0 to card 1 in picker',
    ($) async {
      requireCredentials();

      // ── Mutation gate ────────────────────────────────────────────────────
      // Off by default so the shared suite (ray+uk3, possibly only 1 card)
      // stays green. Enable only when the account has ≥ 2 cards and a staging
      // EVSE connector is available.
      if (!const bool.fromEnvironment('RUN_PAYMENT_MUTATIONS')) {
        logSkip(
          'set_default_payment_method: set --dart-define=RUN_PAYMENT_MUTATIONS=true '
          'with an account that has >=2 cards',
        );
        return;
      }

      if (_testEvseId.isEmpty) {
        logSkip(
          'set_default_payment_method: set --dart-define=TEST_EVSE_ID=<connector> '
          'to reach the payment picker',
        );
        return;
      }

      await bootLoginEnrolled($);

      // ── Open the Charge Now flow ─────────────────────────────────────────
      // The Explore tab pushes ChargeNowRootScreen as a modal. It opens on
      // the InitialChargeFlowWidget (ConnectYourCar step) regardless of
      // location permission state.
      await tapTab($, AppTab.explore);
      await $(ChargeNowRootScreen).waitUntilVisible();

      // ── Navigate to the StartChargingSession step ────────────────────────
      // Manual EVSE entry bypasses GPS / location permission.
      await $('Manually input station ID').waitUntilVisible();
      await $('Manually input station ID').tap();

      await $(TextField).waitUntilVisible();
      await $(TextField).enterText(_testEvseId);

      await $('Continue').waitUntilVisible();
      await $('Continue').tap();

      // The bloc calls getChargingLocationsWithSearchId, getMyPaymentCards, and
      // getPreAuthLimits before emitting StartChargingSession. "Pay with" is
      // the first Text that appears in the payment section of
      // StartChargingSessionWidget — wait on it as the readiness signal.
      await $('Pay with').waitUntilVisible();
      expect(
        $(StartChargingSessionWidget),
        findsOneWidget,
        reason: 'the staging connector should resolve to StartChargingSessionWidget',
      );

      // ── Confirm ≥ 2 payment methods ──────────────────────────────────────
      // StartChargingSessionWidget shows a single RMCardDisplayWidget for the
      // default card (selectedPaymentInstrument), plus a tap target to open the
      // picker. Open the picker to enumerate the available cards.
      final selectedCardDisplay =
          $(StartChargingSessionWidget).$(RMCardDisplayWidget);
      await selectedCardDisplay.waitUntilVisible();

      // Tap the displayed card to open the payment-instrument picker sheet.
      await selectedCardDisplay.first.tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for the picker's TickRadioListTile rows to mount.
      final pickerRows = $(TickRadioListTile);
      await pickerRows.waitUntilVisible();

      final rowCount = pickerRows.evaluate().length;
      if (rowCount < 2) {
        logSkip(
          'set_default_payment_method: account has $rowCount card(s); '
          'need >=2 to test default movement',
        );
        return;
      }

      expect(
        pickerRows,
        findsWidgets,
        reason: 'payment picker should show at least 2 saved cards',
      );
      await pause($); // observe: picker open — card[0] is the default (ticked)

      // TickRadioListTile exposes `checked` (value == groupValue) → the selected
      // tile. Read it directly to PROVE the selection moves (not merely that rows
      // exist). The helper re-evaluates the finder each call so it reflects the
      // picker rebuilding after the selection change.
      bool checkedAt(int i) =>
          ($(TickRadioListTile).at(i).evaluate().single.widget as TickRadioListTile).checked;

      expect(checkedAt(0), isTrue, reason: 'card[0] is the default initially (ticked)');
      expect(checkedAt(1), isFalse, reason: 'card[1] is not selected initially');

      // ── Move the selection to the non-default card (index 1) ─────────────
      await $(TickRadioListTile).at(1).tap(settlePolicy: SettlePolicy.noSettle);
      await pause($); // observe: the tick moves from card[0] to card[1]

      // PROVE the selection moved: card[1] is now ticked, card[0] is not.
      await $(TickRadioListTile).waitUntilVisible();
      expect(checkedAt(1), isTrue, reason: 'card[1] is now selected — the default moved');
      expect(checkedAt(0), isFalse, reason: 'card[0] is no longer selected');

      // ── Close the picker and assert the outer widget reflects card[1] ─────
      // The picker's close IconButton, scoped through the modal BottomSheet
      // (the picker widget itself is private): unscoped, Icons.close would also
      // match the ChargeNowRootScreen AppBar close behind the sheet.
      await $(BottomSheet).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);

      // After the sheet pops, StartChargingSessionWidget should still be
      // visible and show exactly one RMCardDisplayWidget — the newly-selected
      // card (index 1). The widget is re-rendered by the bloc state update
      // that carried the new selectedCard.
      await $(StartChargingSessionWidget).waitUntilVisible();
      expect(
        $(StartChargingSessionWidget),
        findsOneWidget,
        reason: 'StartChargingSessionWidget should still be present after closing picker',
      );

      // The outer "Pay with" card display: exactly one RMCardDisplayWidget
      // scoped inside StartChargingSessionWidget in the non-picker section.
      // (The picker is dismissed so there are no picker-row widgets in tree.)
      final outerCard =
          $(StartChargingSessionWidget).$(RMCardDisplayWidget);
      await outerCard.waitUntilVisible();
      expect(
        outerCard,
        findsOneWidget,
        reason:
            'after closing the picker, StartChargingSessionWidget should show '
            'exactly one RMCardDisplayWidget (the newly-selected card)',
      );

      // ── Reopen the picker; the moved selection persisted (card[1] ticked) ─
      await outerCard.first.tap(settlePolicy: SettlePolicy.noSettle);
      await $(TickRadioListTile).waitUntilVisible();
      await pause($); // observe: reopened picker — card[1] still ticked
      expect(checkedAt(1), isTrue,
          reason: 'reopened picker shows card[1] still selected — the change stuck');

      // ── Revert: re-select the original default (index 0) so the in-memory
      // selection ends as it started. (SharedPreferences.defaultCardId is NOT
      // written here — that only happens after a real charge starts — so there's
      // no persistent side-effect to undo.)
      await $(TickRadioListTile).at(0).tap(settlePolicy: SettlePolicy.noSettle);
      await pause($); // observe: selection reverted to card[0]
      await $(BottomSheet).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);
    },
  );
}
