import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/password_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Password change integration test — GATED and DESTRUCTIVE.
//
// Shape: Account → Password screen → fill current + new password → save →
// assert success (PasswordScreen pops) → reopen → fill reversed passwords →
// save → assert success. The revert step restores testPassword so the account
// is left in the exact same state it started in across any number of runs.
//
// WARNING: this test mutates the login credential of the shared staging
// account. A mid-test failure after the first save will leave the account with
// the altered password (_altPassword). If that happens, log in manually using
// _altPassword and change it back, or run the test again with both the old
// TEST_PASSWORD set to _altPassword (temporarily) so the revert leg completes.
//
// PREREQUISITE: a staging account whose current password equals TEST_PASSWORD.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
// Ideally use a dedicated, non-shared account for this test.
//
// GATING: disabled by default; enable with:
//   --dart-define=RUN_PASSWORD_CHANGE=true
// Omitting the flag (or setting it to false) causes the test to log-skip and
// exit immediately so the default full-suite run stays safe.

// A deterministic alternate password that always satisfies the validation rule:
// ≥8 chars, ≥1 uppercase, ≥1 lowercase, ≥1 digit, ≥1 special character.
// It is intentionally NOT derived from testPassword so it is always valid
// regardless of what TEST_PASSWORD is set to.
const _altPassword = 'QaTest1!Alt';

/// Waits for [screen] to pop off the tree, then asserts it is gone.
Future<void> _waitForScreenPop(PatrolIntegrationTester $, Type screenType) async {
  await waitUntilGone($, $(screenType), timeout: const Duration(seconds: 20));
  expect(
    $(screenType),
    findsNothing,
    reason: 'a successful save pops $screenType back to the Account tab',
  );
}

/// Opens the Password screen from the Account tab, fills [currentPw] and
/// [newPw], taps the save button, and asserts the save succeeded by waiting
/// for PasswordScreen to pop. The Account tab must already be visible.
Future<void> _changePassword(
  PatrolIntegrationTester $,
  String currentPw,
  String newPw,
) async {
  // Scroll the 'Password' AccountLinkWidget into view and tap it. We scope to
  // AccountLinkWidget to avoid matching the bare string 'Password' that also
  // appears as a heading on the Account screen itself.
  final passwordLink = $(AccountLinkWidget).containing('Password');
  await scrollIntoView($, passwordLink);
  await passwordLink.tap();
  await $(PasswordScreen).waitUntilVisible();

  // PasswordScreen has exactly 2 TextFormField widgets (both render as TextField
  // in the widget tree):
  //   index 0 — Current Password  (autofillHint: password)
  //   index 1 — New Password      (autofillHint: newPassword)
  // There is no confirm-password field. Scope to PasswordScreen so we don't
  // accidentally pick up fields from screens behind it in the Navigator stack.
  final currentField = $(PasswordScreen).$(TextField).at(0);
  await currentField.waitUntilVisible();
  await currentField.enterText(currentPw, settlePolicy: SettlePolicy.noSettle);

  // Wait for all fields to be in the tree (unindexed wait) before indexing at(1).
  await $(PasswordScreen).$(TextField).waitUntilExists();
  final newField = $(PasswordScreen).$(TextField).at(1);
  await newField.enterText(newPw, settlePolicy: SettlePolicy.noSettle);

  // The 'Update Password' RMTextButton may be below the fold on small screens.
  final saveButton = $(PasswordScreen).$(RMTextButton);
  await scrollIntoView($, saveButton);
  await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

  // On failure the PasswordCubit emits UIFlow.error and ModalInfoDialogs shows
  // an AlertDialog. Asserting no dialog surfaced is the primary failure signal.
  expect(
    $(AlertDialog),
    findsNothing,
    reason: 'no error dialog should appear on a successful password change',
  );

  // On success the screen calls Navigator.pop() then shows a snackbar. Wait for
  // the screen to leave the tree (PatrolFinder has no waitUntilGone).
  await _waitForScreenPop($, PasswordScreen);
}

void main() {
  e2eTest(
    'password change: update password then revert - idempotent, gated',
    ($) async {
      requireCredentials();

      // GATE: skip by default so the full-suite run is safe. Opt in with
      // --dart-define=RUN_PASSWORD_CHANGE=true, ideally with a dedicated account.
      if (!const bool.fromEnvironment('RUN_PASSWORD_CHANGE')) {
        logSkip(
          'password_change: set --dart-define=RUN_PASSWORD_CHANGE=true '
          '(ideally with a dedicated account) — it mutates the login password.',
        );
        return;
      }

      await bootLoginEnrolled($);

      // Step 1: change testPassword → _altPassword.
      await _changePassword($, testPassword, _altPassword);

      // Step 2: revert _altPassword → testPassword so the account is restored.
      // Re-open the Password screen from the Account tab (we're back there after
      // the first pop).
      await _changePassword($, _altPassword, testPassword);
    },
  );
}
