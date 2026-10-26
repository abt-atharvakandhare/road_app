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

// Shape: logged-in sub-flow, MFA step-up declined.
//
// A phone change puts PATCH /1/users/me behind the step-up gate (other
// profile fields don't — which is why profile_edit_test never sees a sheet).
// Step-up freshness is per API session: a password+TOTP login stamps the
// session as MFA-proven at creation, and so does every step-up verify, so a
// gated write only prompts once the session has outlived the provider's
// freshnessWindow. awaitStepUpStale idles until that is true (see
// _helpers/step_up.dart for the window assumption), regardless of what ran
// before on the reused session.
//
// Flow:
//   1. Fresh login, Account → Profile, flip the last digit of the phone.
//   2. Update Profile → the API refuses with MFA_STEP_UP_REQUIRED and the
//      StepUpSheet opens (straight on code entry: one active factor).
//   3. Dismiss the sheet via its barrier. runWithStepUp rethrows, the screen
//      swallows that silently: ProfileScreen stays mounted, no error dialog,
//      nothing written.
//   4. Back out; nothing to revert.

void main() {
  e2eTest(
    'mfa step up cancel: dismissing the step-up sheet abandons the phone change',
    ($) async {
      // Gated: step-up only fires once the session outlives the provider's
      // freshnessWindow, and staging's e-flux provider runs the 15-minute
      // default (changing it needs cross-team sign-off, 2026-08-21). Without
      // a 1-minute window this test can't provoke the sheet, so it is opt-in.
      if (!const bool.fromEnvironment('RUN_MFA_STEP_UP')) {
        logSkip('mfa_step_up_cancel: needs --dart-define=RUN_MFA_STEP_UP and a provider freshnessWindow of 1 minute.');
        return;
      }
      requireCredentials();
      requireTotpSecret();
      await bootLoginEnrolled($);
      await awaitStepUpStale($);
      await openProfile($);

      final original = phoneFieldText($);
      requirePhoneNumber(original);
      await savePhone($, flipLastDigit(original));

      await $(StepUpSheet).waitUntilVisible();
      await dismissStepUpSheet($);

      // Give the rethrow a frame to settle, then assert the abandoned save.
      await $.tester.pump(const Duration(milliseconds: 300));
      expect(
        $(ProfileScreen),
        findsOneWidget,
        reason: 'a declined step-up must leave ProfileScreen mounted (nothing was saved)',
      );
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'a declined step-up is not an error: no dialog expected',
      );

      await $(BackButton).tap(settlePolicy: SettlePolicy.noSettle);
      await waitUntilGone($, $(ProfileScreen));
      await $(AccountLinkWidget).waitUntilExists();
      expect($(ProfileScreen), findsNothing, reason: 'backing out should return to the Account tab');
    },
  );
}
