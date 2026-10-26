import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/password_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/security_screen.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_option_row.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Shape: logged-in sub-flow, read-only.
//
// Account → Password & Authentication renders the sign-in factor listing
// (fetched from /1/auth/mfa/factors) as MfaOptionRow cards: Password,
// Authenticator app, SMS, Passkeys, Backup codes, Recovery email. Asserts:
//
//   1. The listing loads: at least those six rows mount (the spinner shows
//      until the fetch returns).
//   2. The authenticator row reflects the account's ACTIVE factor: its trailing
//      control is the destructive "Remove" MfaRowActionButton, not "Set up".
//      (Structural: never tapped — removing the factor would lock the suite
//      out of the account.)
//   3. The Password row opens PasswordScreen; back twice returns to Account.
//
// Row labels come from the LIVE AppLocalizations instance so Phrase OTA
// changes don't break the finders.

void main() {
  e2eTest(
    'security screen smoke: factor listing loads, authenticator is active, password row opens',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      final securityLink = $(AccountLinkWidget).containing('Password & Authentication');
      await scrollIntoView($, securityLink);
      await securityLink.tap();
      await $(SecurityScreen).waitUntilVisible();
      final l10n = AppLocalizations.of($.tester.element(find.byType(SecurityScreen)))!;

      // ── 1. Listing loaded ──────────────────────────────────────────────
      final deadline = DateTime.now().add(e2eConfig.existsTimeout);
      while ($(MfaOptionRow).evaluate().length < 6 && DateTime.now().isBefore(deadline)) {
        await $.tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        $(MfaOptionRow).evaluate().length,
        greaterThanOrEqualTo(6),
        reason: 'the factor listing should render Password, authenticator, SMS, passkeys, backup codes and recovery email rows',
      );

      // ── 2. Authenticator factor is active ──────────────────────────────
      final authenticatorAction = $(MfaOptionRow).containing(l10n.mfaSetupAuthenticatorTitle).$(MfaRowActionButton);
      await authenticatorAction.waitUntilExists();
      final action = authenticatorAction.evaluate().single.widget as MfaRowActionButton;
      expect(
        action.destructive,
        isTrue,
        reason: 'the authenticator row should offer Remove (active factor), not Set up',
      );

      // ── 3. Password row → PasswordScreen → back → back ─────────────────
      final passwordRow = $(MfaOptionRow).containing(l10n.password);
      await scrollIntoView($, passwordRow);
      await passwordRow.tap();
      await $(PasswordScreen).waitUntilVisible();
      expect($(PasswordScreen), findsOneWidget, reason: 'the Password row should open PasswordScreen');

      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await waitUntilGone($, $(PasswordScreen));
      await $(SecurityScreen).waitUntilVisible();
      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await waitUntilGone($, $(SecurityScreen));
      await $(AccountLinkWidget).waitUntilExists();
      expect($(SecurityScreen), findsNothing, reason: 'backing out twice should return to the Account tab');
    },
  );
}
