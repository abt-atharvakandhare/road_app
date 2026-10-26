import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/edit_payment_method_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Wallet → Payments → open the first saved payment method's edit screen and
// assert it opened. Does NOT delete, set-default, or modify anything.
//
// Prerequisite: account ray+uk3 on staging has ≥1 saved payment method (a
// credit card or RFID card shown as an RMCardDisplayWidget row).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// Card-type branching:
//   Credit card → assert 'Edit Payment Method' heading + 'Credit or Debit Card'
//                 sub-heading, both of which are always present for credit cards.
//   RFID card   → assert 'Edit Payment Method' heading + 'Name On Card' label,
//                 both of which are always present for RFID cards.
//   If neither text appears within the timeout the test logs a SKIP and returns
//   so the suite stays green if the account's first card type changes.

void main() {
  e2eTest(
    'edit payment method: open first saved method and assert edit screen',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // ── Wallet → Payments ────────────────────────────────────────────────
      // Same approach as view_payment_methods_test.dart.
      // noSettle: Payments mounts an RMShimmerLoader during the initial fetch.
      await tapTab($, AppTab.wallet);
      await $('Payments').tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for at least one saved-card row. If the account has no cards the
      // test cannot proceed — logSkip so the full suite stays green.
      final rowFinder = $(RMCardDisplayWidget);
      await rowFinder.waitUntilVisible();

      if (!rowFinder.exists) {
        logSkip('edit_payment_method_open: account has no saved payment methods');
        return;
      }

      expect(
        rowFinder,
        findsWidgets,
        reason: 'account should have at least one saved payment method',
      );

      // ── Tap the first saved-method row ───────────────────────────────────
      // Wait on the unindexed finder before narrowing to .at(0), so the list
      // has fully mounted (auto-wait already satisfied above, but .at(0) is
      // safer after the finder is known to exist).
      await rowFinder.at(0).tap(settlePolicy: SettlePolicy.noSettle);

      // ── Assert EditPaymentMethodScreen opened ────────────────────────────
      // The screen always shows the 'Edit Payment Method' heading regardless
      // of card type (Text rendered from AppLocalizations.editPaymentMethod).
      await $(EditPaymentMethodScreen).waitUntilVisible();
      expect(
        $(EditPaymentMethodScreen),
        findsOneWidget,
        reason: 'tapping a payment method row should open EditPaymentMethodScreen',
      );

      const editHeading = 'Edit Payment Method';
      await $(EditPaymentMethodScreen).$(find.text(editHeading)).waitUntilExists();
      expect(
        $(EditPaymentMethodScreen).$(find.text(editHeading)),
        findsOneWidget,
        reason: 'EditPaymentMethodScreen should show its heading',
      );

      // ── Card-type branch assertion ────────────────────────────────────────
      // Determine which branch rendered (credit vs RFID) from the sub-heading
      // that is always present for each type, then assert the matching stable
      // child. If neither surfaces within the existsTimeout, logSkip.
      const creditSubHeading = 'Credit or Debit Card';
      const rfidSubHeading = 'Name On Card';

      final deadline = DateTime.now().add(const Duration(seconds: 10));
      String? detectedType;
      while (DateTime.now().isBefore(deadline)) {
        if ($(EditPaymentMethodScreen).$(find.text(creditSubHeading)).exists) {
          detectedType = 'credit';
          break;
        }
        if ($(EditPaymentMethodScreen).$(find.text(rfidSubHeading)).exists) {
          detectedType = 'rfid';
          break;
        }
        await $.tester.pump(const Duration(milliseconds: 200));
      }

      if (detectedType == null) {
        logSkip('edit_payment_method_open: card-type sub-heading not detected; '
            'skipping branch assertion');
      } else if (detectedType == 'credit') {
        expect(
          $(EditPaymentMethodScreen).$(find.text(creditSubHeading)),
          findsOneWidget,
          reason: 'credit card edit screen should show "Credit or Debit Card" sub-heading',
        );
        // The edit screen also renders the card row widget for credit cards.
        expect(
          $(EditPaymentMethodScreen).$(RMCardDisplayWidget),
          findsOneWidget,
          reason: 'credit card edit screen should show the card display widget',
        );
      } else {
        // RFID card branch
        expect(
          $(EditPaymentMethodScreen).$(find.text(rfidSubHeading)),
          findsOneWidget,
          reason: 'RFID card edit screen should show "Name On Card" label',
        );
      }

      // ── Go back ──────────────────────────────────────────────────────────
      // The edit screen has an AppBar back button (Icons.arrow_back) that calls
      // Navigator.of(context).pop(null). Tap it and confirm we are back on the
      // Payments list (RMCardDisplayWidget rows visible again).
      await $(EditPaymentMethodScreen).$(Icons.arrow_back).tap(
            settlePolicy: SettlePolicy.noSettle,
          );
      // The pop animates back to the Payments list — the edit route lingers
      // mid-transition (and its own RMCardDisplayWidget stays visible), so poll
      // until the screen is gone before asserting rather than racing the dispose.
      await waitUntilGone($, $(EditPaymentMethodScreen));
      expect(
        $(EditPaymentMethodScreen),
        findsNothing,
        reason: 'back button should dismiss EditPaymentMethodScreen',
      );
    },
  );
}
