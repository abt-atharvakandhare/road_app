import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/billing_address/billing_address_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/notifications_settings_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/security_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/explore_root_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';
import 'package:road_mobile/ui/mainapp/home/home_root_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/invoices_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/payment_methods_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_action_button.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Layout sweep: walk the app's main surfaces under the two longest-string
// locales and let DEBUG MODE do the asserting. A debug build turns any
// RenderFlex overflow into a FlutterError, which Patrol's exception gatherer
// promotes to a test failure — so simply *rendering* every screen under es/fr
// is a layout regression test. This is how the home-screen (es, 20px), action-
// button (fr, 16px) and power-slider (14px) overflows were caught.
//
// The only explicit expectations here are navigation sanity checks (screen
// mounted before moving on); the real assertion is implicit and global.
//
// ──────────────────────────────────────────────────────────────────────────────
// COVERAGE & LIMITS
// ──────────────────────────────────────────────────────────────────────────────
// Visited: Account root (scrolled to the bottom row so the whole list lays
// out) → Notifications / Profile / Password / Billing Address subscreens →
// Wallet tabs (Sessions, Payments, Invoices) → Map + filter screen → Home +
// Charge Now modal. That is every top-level surface with an established,
// locale-safe navigation pattern in this suite.
//
// Locales: es and fr — measurably the longest translations of this app's
// strings (es headline +120% vs en, fr subtitle +65%). A regression that only
// overflows in de/it/nl but not es/fr is possible but unlikely; extend _locales
// if one ever slips through.
//
// Width coverage comes from the DEVICE list, not the test: 360dp-wide devices
// (Galaxy S24) are the tight case — keep one in the fleet when running this.
//
// Lazy lists (sessions rows etc.) only lay out what scrolls into view, so
// data-dependent list interiors are NOT swept — deliberate, to keep this test
// free of data prerequisites beyond a logged-in account.
//
// ──────────────────────────────────────────────────────────────────────────────
// LOCALE-SAFE NAVIGATION
// ──────────────────────────────────────────────────────────────────────────────
// Bottom-nav labels are hardcoded English (main_app_root_screen.dart), so
// tapTab works under any injected locale. Login is fully structural
// (TextField indexes + RMTextButton). Account rows and wallet tabs ARE
// localized — their finders below use the LIVE AppLocalizations instance from
// the widget tree, so they follow the injected locale (and Phrase OTA)
// automatically. Never hardcode a translation in this file.
//
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

const _locales = ['es', 'fr'];

void main() {
  for (final code in _locales) {
    e2eTest(
      'layout sweep $code: all main screens render without overflow',
      ($) async {
        requireCredentials();

        // Inject the device locale BEFORE boot (same mechanism as
        // locale_resolution_test.dart).
        final dispatcher = $.tester.binding.platformDispatcher;
        dispatcher.localeTestValue = Locale(code);
        dispatcher.localesTestValue = [Locale(code)];

        await bootLoginEnrolled($);

        // Live l10n instance — resolves to the injected locale.
        await $(AccountLinkWidget).waitUntilExists();
        final l10n = AppLocalizations.of(
          $.tester.element(find.byType(AccountLinkWidget).first),
        )!;

        // ── 1. Account root, fully laid out ─────────────────────────────────
        //
        // The rows below the fold only lay out when scrolled to. Scroll to the
        // BOTTOM row (Remove Account) so every row renders once, then back to
        // the top row (Notifications) to continue. No taps — just layout.
        await scrollIntoView($, $(AccountLinkWidget).containing(l10n.removeAccount));
        await scrollIntoView($, $(AccountLinkWidget).containing(l10n.notifications));

        // ── 2. Account subscreens ───────────────────────────────────────────
        //
        // Same open → wait → BackButton → wait cycle as account_links_open_test,
        // with l10n-driven row labels. The password form sits one level below
        // the security screen; this sweep covers the Account-level hop only.
        final subscreens = <(String, Type)>[
          (l10n.notifications, NotificationsSettingsScreen),
          (l10n.profile, ProfileScreen),
          (l10n.passwordAndAuthentication, SecurityScreen),
          (l10n.billingAddress, BillingAddressScreen),
        ];
        for (final (label, screenType) in subscreens) {
          final link = $(AccountLinkWidget).containing(label);
          await scrollIntoView($, link);
          await link.tap();
          await $(screenType).waitUntilExists();
          expect($(screenType), findsOneWidget,
              reason: '$screenType should open from its Account row ($code)');
          await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
          await $(AccountLinkWidget).waitUntilExists();
        }

        // ── 3. Wallet tabs ──────────────────────────────────────────────────
        await tapTab($, AppTab.wallet);
        await $(SessionsScreen).$(IconButton).waitUntilVisible();

        await $(l10n.payments).tap(settlePolicy: SettlePolicy.noSettle);
        await $(PaymentMethodsScreen).waitUntilExists();

        if (F.showInvoices) {
          await $(l10n.invoices).tap(settlePolicy: SettlePolicy.noSettle);
          await $(InvoicesScreen).waitUntilExists();
        }

        // ── 4. Map + filter screen ──────────────────────────────────────────
        //
        // The filter screen body is a SingleChildScrollView, so ALL its content
        // (only-show toggles, power slider, network + connector sections) lays
        // out on open — no scrolling needed for overflow coverage.
        await tapTab($, AppTab.map);
        await $(ExploreRootScreen).waitUntilVisible();
        await $(InitialWidget).$(TextField).waitUntilVisible();
        await $(InitialWidget).$(IconButton).at(1).tap();
        await $(MapFilterScreen).waitUntilVisible();
        await $(MapFilterScreen).$(Switch).waitUntilVisible();
        await $(MapFilterScreen).$(IconButton).$(Icons.close).tap();
        await waitUntilGone($, $(MapFilterScreen));

        // ── 5. Home + Charge Now modal ──────────────────────────────────────
        await tapTab($, AppTab.home);
        await $(HomeRootScreen).$(RMDecoratedActionButton).waitUntilVisible();
        await $(HomeRootScreen).$(RMDecoratedActionButton).tap(settlePolicy: SettlePolicy.noSettle);
        await $(ChargeNowRootScreen).waitUntilExists();
        await $(ChargeNowRootScreen).$(IconButton).$(Icons.close).tap(settlePolicy: SettlePolicy.noSettle);
        await waitUntilGone($, $(ChargeNowRootScreen));
      },
    );
  }
}
