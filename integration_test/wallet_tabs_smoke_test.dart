// Shape: boot → log in → open Wallet → switch tabs → assert each screen mounts.
// Prerequisite: staging account (credentials via
// --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…).
// Account ray+uk3@road.io has sessions + a payment method but NO invoices, so
// InvoicesScreen shows an empty-state — we assert the screen exists, not rows.
// Run with: flutter test integration_test/wallet_tabs_smoke_test.dart
//   --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/invoices_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/payment_methods_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_screen.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

void main() {
  e2eTest(
    'wallet tabs smoke: Sessions, Payments, Invoices screens all mount',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Open the Wallet tab. The TabBar defaults to Sessions (index 0).
      await tapTab($, AppTab.wallet);

      // ── Sessions tab (default, already active) ──────────────────────────────
      // The Sessions header Text is emitted as the first child of _buildScrollChildren
      // unconditionally, so it renders before any cubit fetch completes.
      // The scoped filter IconButton is also always present. Both signals are
      // independent of data, so they work with an empty-month account too.
      await $(SessionsScreen).$(IconButton).waitUntilVisible();
      expect(
        $(SessionsScreen),
        findsOneWidget,
        reason: 'Sessions tab: SessionsScreen should be mounted',
      );

      // ── Payments tab ────────────────────────────────────────────────────────
      // Tapping the label text selects the tab. noSettle avoids hanging on the
      // RMShimmerLoader that fires while PaymentMethodsCubit fetches.
      await $('Payments').tap(settlePolicy: SettlePolicy.noSettle);

      // PaymentMethodsScreen is a StatelessWidget — it mounts synchronously.
      // waitUntilExists (not waitUntilVisible) handles the case where it may
      // render partially behind an animating shimmer.
      await $(PaymentMethodsScreen).waitUntilExists();
      expect(
        $(PaymentMethodsScreen),
        findsOneWidget,
        reason: 'Payments tab: PaymentMethodsScreen should be mounted',
      );

      // ── Invoices tab ─────────────────────────────────────────────────────────
      // F.showInvoices is true for the eflux flavor. The tab label is 'Invoices'.
      // This account has no invoices — InvoicesScreen renders an empty-state
      // list; we assert the screen itself, not InvoiceItemWidget rows.
      await $('Invoices').tap(settlePolicy: SettlePolicy.noSettle);

      await $(InvoicesScreen).waitUntilExists();
      expect(
        $(InvoicesScreen),
        findsOneWidget,
        reason:
            'Invoices tab: InvoicesScreen should be mounted (empty-state is fine)',
      );
    },
  );
}
