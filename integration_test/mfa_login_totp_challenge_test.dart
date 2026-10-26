import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/onboarding/login/mfa_code_entry_widget.dart';

import '_helpers/app_launch.dart';
import '_helpers/auth.dart';
import '_helpers/biometric.dart';
import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/totp.dart';

// Shape: login flow, MFA challenge (authenticator app).
//
// Prerequisite: the TEST_EMAIL account has an authenticator-app factor and
// TEST_TOTP_SECRET carries its base32 secret (the normal suite setup since
// 2026-08-21). Every other test answers this challenge implicitly inside
// loginAsStagingUser; this one drives it explicitly so a regression in the
// challenge UI is diagnosed here, not as 40 generic login timeouts.
//
// Flow:
//   1. Boot logged out (no session reuse: the challenge only shows on a real
//      password login) and submit credentials.
//   2. Assert the TOTP code entry is what the decision engine shows (not the
//      method picker, an SMS step or the enrolment interstitial).
//   3. Type a code that differs from the live one → the card shows the inline
//      "incorrect code" error and the modal stays up. ONE wrong guess only:
//      guesses count against the per-user limit and a lockout would take the
//      rest of the run down with it.
//   4. Type the computed code → the card auto-submits, the session is issued,
//      the modal closes (finishLogin also answers the Android enrolment prompt
//      and re-arms session reuse for the tests after this one).
//
// The error string is resolved from the LIVE AppLocalizations on the widget
// tree, so it follows Phrase OTA rather than the baked-in ARB.

void main() {
  e2eTest(
    'mfa login totp challenge: wrong code shows inline error, computed code completes login',
    ($) async {
      requireCredentials();
      requireTotpSecret();
      await bootApp($, preserveSession: false);
      await tapTab($, AppTab.account);
      await submitLoginCredentials($, testEmail, testPassword);

      // The challenge screen. A different step here is a change in the
      // account's factors or the decision engine, not a UI regression.
      final shown = await waitForWidget($, totpCodeEntry($), timeout: const Duration(seconds: 20));
      expect(
        shown,
        isTrue,
        reason: 'the login should land on the authenticator-app code entry '
            '(account must have TOTP as its only non-passkey factor)',
      );

      // Wrong code → inline error, modal still up.
      await enterTotpCode($, wrongTotpCode());
      final l10n = AppLocalizations.of($.tester.element(find.byType(MfaCodeEntryWidget)))!;
      await $(MfaCodeEntryWidget).$(l10n.codeEnteredIsIncorrect).waitUntilVisible();
      expect(
        $(LoginScreen),
        findsOneWidget,
        reason: 'a wrong code must not complete the login',
      );

      // Correct code: typing replaces the rejected one; the card auto-submits
      // on the sixth digit. Don't type into a window that is about to roll.
      while (totpSecondsRemaining() < 4) {
        await $.tester.pump(const Duration(milliseconds: 250));
      }
      await enterTotpCode($, totpCode(testTotpSecret));
      await finishLogin($, enroll: BioResponse.pass);
      expect(
        $(LoginScreen),
        findsNothing,
        reason: 'the computed TOTP code should complete the login and close the modal',
      );
    },
  );
}
