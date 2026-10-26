import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/notifications_settings_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/password_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/security_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/billing_address/billing_address_screen.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_option_row.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Navigation smoke test: boot onto staging, log in, open each in-app Account
// subscreen in turn, assert it mounted, tap the AppBar BackButton to return,
// then assert the Account list is back before proceeding.
//
// Covers: Notifications → Profile → Password & Authentication (→ Password) →
// Billing Address.
//
// Skipped rows (external — do not open an in-app screen):
//   Dashboard       — launchProviderUri (provider web portal)
//   Help & Support  — IntercomUtils.showIntercomMessenger / launchProviderUri
//   Cancel Subscription — launchProviderUri (e-flux.io form)  [eflux flavor only]
//   Remove Account  — RMDestructiveConfirmationSheet (destructive; separate test)
//   About Us        — launchProviderUri
//   Terms of Service — launchProviderUri
//   Privacy Statement — launchProviderUri
//
// Account prerequisite: any logged-in staging account works; no special data
// needed. Default account ray+uk3@road.io is fine.
// Credentials: --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…

void main() {
  e2eTest(
    'account links open: each in-app subscreen opens and closes cleanly',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // -----------------------------------------------------------------------
      // 1. Notifications
      // -----------------------------------------------------------------------
      // The Notifications row is near the top of the Personal Settings section.
      // It is usually visible without scrolling, but scrollIntoView is cheap and
      // correct — it no-ops if the target is already on screen.
      final notificationsLink = $(AccountLinkWidget).containing('Notifications');
      await scrollIntoView($, notificationsLink);
      await notificationsLink.tap();

      // NotificationsSettingsScreen mounts a shimmer loader during the initial
      // notification-preferences fetch. Wait on the screen type (exists in tree)
      // rather than waitUntilVisible: the Screen itself is a layout ancestor that
      // won't be hit-testable. Its mere presence means the route constructed
      // and the NotificationsCubit was created without error.
      await $(NotificationsSettingsScreen).waitUntilExists();
      expect(
        $(NotificationsSettingsScreen),
        findsOneWidget,
        reason: 'NotificationsSettingsScreen should open from the Notifications row',
      );

      // Back: tap the AppBar BackButton inserted automatically by the push route.
      // BackButton is the real Flutter widget type — more reliable than icon
      // finders which differ between iOS (arrow_back_ios) and Android (arrow_back).
      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for Account list to be back before tapping the next row.
      // AccountLinkWidget rows are gated behind isLoggedIn, so their presence
      // confirms we are back on the Account root.
      await $(AccountLinkWidget).waitUntilExists();

      // -----------------------------------------------------------------------
      // 2. Profile
      // -----------------------------------------------------------------------
      // Scope to AccountLinkWidget to avoid the 'Profile' heading text inside
      // the just-popped ProfileScreen (which may linger briefly in the tree).
      final profileLink = $(AccountLinkWidget).containing('Profile');
      await scrollIntoView($, profileLink);
      await profileLink.tap();

      await $(ProfileScreen).waitUntilExists();
      expect(
        $(ProfileScreen),
        findsOneWidget,
        reason: 'ProfileScreen should open from the Profile row',
      );

      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await $(AccountLinkWidget).waitUntilExists();

      // -----------------------------------------------------------------------
      // 3. Password & Authentication → Password
      // -----------------------------------------------------------------------
      final securityLink = $(AccountLinkWidget).containing('Password & Authentication');
      await scrollIntoView($, securityLink);
      await securityLink.tap();

      await $(SecurityScreen).waitUntilExists();
      expect(
        $(SecurityScreen),
        findsOneWidget,
        reason: 'SecurityScreen should open from the Password & Authentication row',
      );

      // The password form now lives one level deeper: the Password row on the
      // security screen (exact-text match — the screen heading is the longer
      // 'Password & Authentication' string, so it can't collide).
      await $(MfaOptionRow).containing('Password').tap();

      await $(PasswordScreen).waitUntilExists();
      expect(
        $(PasswordScreen),
        findsOneWidget,
        reason: 'PasswordScreen should open from the security screen Password row',
      );

      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await $(SecurityScreen).waitUntilExists();
      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await $(AccountLinkWidget).waitUntilExists();

      // -----------------------------------------------------------------------
      // 4. Billing Address
      // -----------------------------------------------------------------------
      // This row is in the Account Settings section, below the separator below
      // Password. scrollIntoView handles any below-the-fold position.
      final billingAddressLink = $(AccountLinkWidget).containing('Billing Address');
      await scrollIntoView($, billingAddressLink);
      await billingAddressLink.tap();

      await $(BillingAddressScreen).waitUntilExists();
      expect(
        $(BillingAddressScreen),
        findsOneWidget,
        reason: 'BillingAddressScreen should open from the Billing Address row',
      );

      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await $(AccountLinkWidget).waitUntilExists();
    },
  );
}
