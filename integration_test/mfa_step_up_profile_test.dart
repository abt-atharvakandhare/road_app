import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/utils/step_up/step_up_sheet.dart';

import '_helpers/auth.dart';
import '_helpers/profile.dart';
import '_helpers/scenario.dart';
import '_helpers/step_up.dart';

// Shape: logged-in sub-flow, MFA step-up verified, then freshness.
//
// See mfa_step_up_cancel_test for why a phone change is the trigger and how
// the session is made MFA-stale first. This test takes the happy path:
//
//   1. Login (reused session), wait out the freshness window, Profile, flip
//      the last phone digit, Update Profile → StepUpSheet.
//   2. Answer with the computed TOTP → the sheet pops true, runWithStepUp
//      retries the PATCH, the save lands: ProfileScreen pops, no dialog.
//   3. Reopen Profile: the field shows the new number (persisted).
//   4. Revert to the original number and save again. The session is now
//      MFA-fresh (re-stamped by the verify), so this gated write must go through WITHOUT
//      a sheet — asserted by failing the moment a StepUpSheet appears while
//      waiting for the pop. Reopen and confirm the original is back.
//
// Mutating but self-reverting; the account's phone is restored whether or not
// step 4's assertion holds (the revert save is attempted first).

void main() {
  e2eTest(
    'mfa step up profile: phone change prompts step-up, TOTP verifies, revert is fresh',
    ($) async {
      // Gated: step-up only fires once the session outlives the provider's
      // freshnessWindow, and staging's e-flux provider runs the 15-minute
      // default (changing it needs cross-team sign-off, 2026-08-21). Without
      // a 1-minute window this test can't provoke the sheet, so it is opt-in.
      if (!const bool.fromEnvironment('RUN_MFA_STEP_UP')) {
        logSkip('mfa_step_up_profile: needs --dart-define=RUN_MFA_STEP_UP and a provider freshnessWindow of 1 minute.');
        return;
      }
      requireCredentials();
      requireTotpSecret();
      await bootLoginEnrolled($);
      await awaitStepUpStale($);
      await openProfile($);

      final original = phoneFieldText($);
      requirePhoneNumber(original);
      final changed = flipLastDigit(original);

      // ── 1+2. Change → step-up → verify → saved ──────────────────────────
      await savePhone($, changed);
      await $(StepUpSheet).waitUntilVisible();
      await answerStepUpWithTotp($);

      await waitUntilGone($, $(ProfileScreen), timeout: const Duration(seconds: 20));
      expect(
        $(ProfileScreen),
        findsNothing,
        reason: 'after a verified step-up the retried save should pop ProfileScreen',
      );
      expect($(AlertDialog), findsNothing, reason: 'no error dialog expected on the verified save');

      // ── 3. Persisted ───────────────────────────────────────────────────
      await $(AccountLinkWidget).waitUntilExists();
      await openProfile($);
      expect(phoneFieldText($), changed, reason: 'the step-up-gated phone change should persist');

      // ── 4. Revert inside the freshness window: no sheet ─────────────────
      await savePhone($, original);
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while ($(ProfileScreen).evaluate().isNotEmpty && DateTime.now().isBefore(deadline)) {
        if ($(StepUpSheet).evaluate().isNotEmpty) {
          // Keep the account clean before failing: answer it so the revert lands.
          await answerStepUpWithTotp($);
          await waitUntilGone($, $(ProfileScreen));
          fail('a second gated write inside the MFA freshness window prompted for step-up again');
        }
        await $.tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        $(ProfileScreen),
        findsNothing,
        reason: 'the revert should save without a step-up (session is MFA-fresh)',
      );

      await $(AccountLinkWidget).waitUntilExists();
      await openProfile($);
      expect(phoneFieldText($), original, reason: 'the phone number should be back to its original value');
      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await waitUntilGone($, $(ProfileScreen));
    },
  );
}
