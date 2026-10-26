import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/edit_payment_method_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_destructive_confirmation_sheet.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Destructive test: deletes the first saved payment method and asserts the
// card-row count drops by one.
//
// GATING: This test is skipped by default and only runs when
//   --dart-define=RUN_PAYMENT_MUTATIONS=true
// is passed at launch, together with an account that has ≥2 saved payment
// methods (credit cards). Deleting with only one card would strand the account
// without a payment method.
//
// Prerequisite account: ≥2 credit cards saved on the staging account supplied
// via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// DELETE FLOW:
//   1. Wallet → Payments: count RMCardDisplayWidget rows (initialCount).
//   2. Tap the first card row → EditPaymentMethodScreen opens.
//   3. Tap the "Remove Card" TextButton → RMDestructiveConfirmationSheet appears.
//   4. Tap the RMTextButton (red confirm button) inside the sheet.
//   5. The cubit deletes the card; Navigator.pop(true) closes the edit screen.
//   6. Back on Payments: wait for the list to refresh; assert row count == initialCount - 1.
//
// CONFIRMATION STRATEGY:
//   Tap RMTextButton (the sole red confirm button inside
//   RMDestructiveConfirmationSheet) rather than a runtime-localised string.
//   The cancel path uses a plain TextButton — RMTextButton is unambiguous.
//
// ROW COUNT STRATEGY:
//   $(RMCardDisplayWidget).evaluate().length before and after. The Payments list
//   always uses RMCardDisplayWidget for every credit-card row (one per card, no
//   duplicates — the edit screen's own RMCardDisplayWidget is only in scope while
//   EditPaymentMethodScreen is mounted, which is gone by assertion time).

void main() {
  e2eTest(
    'delete payment method: card count drops by one',
    ($) async {
      requireCredentials();

      // ── Gate ──────────────────────────────────────────────────────────────
      // Default-off: protects the test account from accidental deletion and
      // keeps the default suite green. Pass --dart-define=RUN_PAYMENT_MUTATIONS=true
      // with a multi-card staging account to opt in.
      if (!const bool.fromEnvironment('RUN_PAYMENT_MUTATIONS')) {
        logSkip(
          'delete_payment_method: set --dart-define=RUN_PAYMENT_MUTATIONS=true '
          'with an account that has >=2 cards (destructive)',
        );
        return;
      }

      await bootLoginEnrolled($);

      // ── Wallet → Payments ─────────────────────────────────────────────────
      // noSettle: the Payments tab mounts an RMShimmerLoader during the initial
      // fetch; pumpAndSettle would hang. Wait for a concrete card row instead.
      await tapTab($, AppTab.wallet);
      await $('Payments').tap(settlePolicy: SettlePolicy.noSettle);

      final rowFinder = $(RMCardDisplayWidget);
      await rowFinder.waitUntilVisible();

      final initialCount = rowFinder.evaluate().length;

      // Guard: require ≥2 cards so deleting one doesn't strand the account.
      if (initialCount < 2) {
        logSkip(
          'delete_payment_method: account has $initialCount saved card(s); '
          'need >=2 to safely delete one (destructive)',
        );
        return;
      }

      // ── Open the first card's edit screen ─────────────────────────────────
      // Wait on the unindexed finder (satisfied above) before narrowing to
      // .at(0) — safer than indexing into an unsettled list.
      await rowFinder.at(0).tap(settlePolicy: SettlePolicy.noSettle);

      await $(EditPaymentMethodScreen).waitUntilVisible();
      expect(
        $(EditPaymentMethodScreen),
        findsOneWidget,
        reason: 'tapping a payment method row should open EditPaymentMethodScreen',
      );

      // ── Tap the "Remove Card" TextButton ──────────────────────────────────
      // The remove button is a TextButton whose child has destructive-red colour
      // (RMColors.destructiveRed). Rather than matching on the runtime-localised
      // label, we locate it by widget type inside EditPaymentMethodScreen and
      // rely on there being exactly one TextButton at this point in the screen
      // (the back-navigation uses an IconButton, not a TextButton).
      final removeButton = $(EditPaymentMethodScreen).$(TextButton);
      await removeButton.waitUntilVisible();
      await removeButton.tap(settlePolicy: SettlePolicy.noSettle);

      // ── Confirm via RMDestructiveConfirmationSheet ────────────────────────
      // The confirmation sheet appears as a modal bottom sheet. Wait for the
      // sheet widget itself, then tap RMTextButton (the red confirm button).
      // The cancel path uses a plain TextButton — RMTextButton is unambiguous.
      await $(RMDestructiveConfirmationSheet).waitUntilVisible();
      expect(
        $(RMDestructiveConfirmationSheet),
        findsOneWidget,
        reason: 'tapping Remove Card should show the destructive confirmation sheet',
      );

      final confirmButton = $(RMDestructiveConfirmationSheet).$(RMTextButton);
      await confirmButton.waitUntilVisible();
      await confirmButton.tap(settlePolicy: SettlePolicy.noSettle);

      // ── Wait for EditPaymentMethodScreen to dismiss ───────────────────────
      // After confirming, the cubit deletes the card and Navigator.pop(true)
      // closes the edit screen. The route lingers during the pop animation, so
      // poll until it's fully gone before counting rows to avoid catching the
      // still-mounted edit screen's own RMCardDisplayWidget in the count.
      await waitUntilGone($, $(EditPaymentMethodScreen));
      expect(
        $(EditPaymentMethodScreen),
        findsNothing,
        reason: 'edit screen should dismiss after successful delete',
      );

      // ── Assert card count dropped by one ─────────────────────────────────
      // Wait for the Payments list to re-render after the cubit refresh.
      // The list always shows ≥1 row (we required ≥2 before deleting), so
      // waiting for the first visible row confirms the list has settled.
      await rowFinder.waitUntilVisible();

      final finalCount = rowFinder.evaluate().length;
      expect(
        finalCount,
        initialCount - 1,
        reason: 'card count should drop from $initialCount to ${initialCount - 1} '
            'after deleting one card',
      );
    },
  );
}
