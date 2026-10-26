import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';

// Template: a "form-submit" test. Boot straight onto staging, log in, open a
// form screen, change a field, submit, and assert the save persisted.
//
// Prerequisite: a staging account that is logged in (handled by
// bootLoginEnrolled, which leaves the app on the Account tab).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// We read the CURRENT first name and bump a trailing ordinal ("QA Test 7" →
// "QA Test 8") so every run writes a genuinely NEW value — otherwise a fixed
// value would already be set from the prior run and "it persists" would prove
// nothing. The ordinal just grows; harmless on staging.

void main() {
  e2eTest(
    'profile edit: change first name, save, and it persists',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Account → Profile. The Account screen is a scrolling list of
      // AccountLinkWidget rows; scope to the one whose label is 'Profile' and
      // scroll it into view before tapping. ('Profile' alone is ambiguous — the
      // ProfileScreen itself also renders that word — so we match the row
      // widget, not the bare text.)
      final profileLink = $(AccountLinkWidget).containing('Profile');
      await profileLink.scrollTo();
      await profileLink.tap();
      await $(ProfileScreen).waitUntilVisible();

      // The first-name field is the first TextFormField in the form (it renders
      // as a TextField). Scope to ProfileScreen so we don't catch fields on
      // screens behind it.
      final firstNameField = $(ProfileScreen).$(TextField).at(0);
      await firstNameField.waitUntilVisible();

      // Read the CURRENT value and bump its trailing ordinal so we always write a
      // new, different value (makes the persistence assertion meaningful).
      final current =
          (firstNameField.evaluate().single.widget as TextField).controller?.text ?? '';
      final ordinal = int.tryParse(RegExp(r'(\d+)\s*$').firstMatch(current)?.group(1) ?? '') ?? 0;
      final newFirstName = 'QA Test ${ordinal + 1}';

      // noSettle: the field carries an AutofillHint (givenName), so on a real
      // iOS device the QuickType / autofill bar animates and the screen never
      // settles — a default enterText would pumpAndSettle and burn ~10s. We
      // don't need the screen quiet between actions.
      await firstNameField.enterText(newFirstName, settlePolicy: SettlePolicy.noSettle);

      // Save: the 'Update Profile' button is an RMTextButton below the fold, so
      // scroll it in first. On success the AuthCubit.updateProfile call pops the
      // screen and shows a success snackbar; on failure a ModalInfoDialogs
      // AlertDialog appears instead.
      final saveButton = $(ProfileScreen).$(RMTextButton);
      await saveButton.scrollTo();
      await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Primary success assertion: no error dialog surfaced. (updateProfile only
      // shows an AlertDialog on failure; the happy path pops + snackbars.)
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should appear on a successful profile save',
      );

      // Saving pops ProfileScreen back to the Account tab, so wait for the
      // screen to leave the tree — that's the in-app signal the save completed.
      // PatrolFinder has no waitUntilGone, so poll evaluate() until empty (the
      // same pattern loginAsStagingUser uses to wait out the login modal).
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while ($(ProfileScreen).evaluate().isNotEmpty &&
          DateTime.now().isBefore(deadline)) {
        await $.tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        $(ProfileScreen),
        findsNothing,
        reason: 'a successful save pops ProfileScreen back to the Account tab',
      );

      // Persistence: re-open Profile and confirm the first-name field is
      // pre-populated with the value we saved (initState reads it back from the
      // refreshed profile in AuthCubit).
      final profileLinkAgain = $(AccountLinkWidget).containing('Profile');
      await profileLinkAgain.scrollTo();
      await profileLinkAgain.tap();
      await $(ProfileScreen).waitUntilVisible();

      final reopenedFirstName = $(ProfileScreen).$(TextField).at(0);
      await reopenedFirstName.waitUntilVisible();
      final controllerText =
          (reopenedFirstName.evaluate().single.widget as TextField).controller?.text;
      expect(
        controllerText,
        newFirstName,
        reason: 'the newly saved first name should persist and pre-populate on reopen',
      );
    },
  );
}
