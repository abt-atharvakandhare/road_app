import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Validates the first-name required-field guard on the Profile screen.
//
// Steps:
//   1. Boot → log in → Account tab (same preamble as profile_edit_test).
//   2. Navigate to ProfileScreen.
//   3. Clear the first-name field.
//   4. Tap "Update Profile".
//   5. Assert the inline validation error "First name is required" is visible.
//   6. Assert ProfileScreen is still present (save was blocked, screen did not pop).
//
// This test never calls updateProfile on the server — the Form validator fires
// synchronously and returns early before any network request is made.
//
// Account: ray+uk3 (firstName pre-populated as "QA Test").

void main() {
  e2eTest(
    'profile validation: clearing first name blocks save and shows inline error',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate Account → Profile (same finder as profile_edit_test).
      final profileLink = $(AccountLinkWidget).containing('Profile');
      await scrollIntoView($, profileLink);
      await profileLink.tap();
      await $(ProfileScreen).waitUntilVisible();

      // The first-name field is the first TextFormField in the form.
      // Wait for it to be visible before interacting.
      final firstNameField = $(ProfileScreen).$(TextField).at(0);
      await firstNameField.waitUntilVisible();

      // Clear the field by entering an empty string.
      // settlePolicy: noSettle — the autofillHints (givenName) can keep the
      // frame pipeline busy on a real device, same as profile_edit_test.
      await firstNameField.enterText('', settlePolicy: SettlePolicy.noSettle);

      // Tap "Update Profile". The button is below the fold in a
      // SingleChildScrollView, so use scrollIntoView (momentum-free) rather
      // than scrollTo, which can overshoot under iOS BouncingScrollPhysics.
      final saveButton = $(ProfileScreen).$(RMTextButton);
      await scrollIntoView($, saveButton);
      await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Give Flutter one frame to run Form.validate() and rebuild the field
      // with its inline error text. A single pump is sufficient — the validator
      // is synchronous and no network request is made.
      await $.tester.pump();

      // Primary assertion: the inline validation error is visible.
      // TextFormField renders the validator return value as a Text widget below
      // the field; it lives inside the form's subtree.
      const expectedError = 'First name is required';
      expect(
        $(ProfileScreen).$(expectedError),
        findsOneWidget,
        reason: 'the inline "First name is required" error should appear under the first-name field',
      );

      // Secondary assertion: the screen did NOT pop. ProfileScreen stays in
      // the tree because _formKey.currentState!.validate() returned false and
      // the onPressed handler returned early before calling updateProfile.
      expect(
        $(ProfileScreen),
        findsOneWidget,
        reason: 'ProfileScreen must still be present — a blocked save must not pop the screen',
      );

      // No AlertDialog should surface either — the form guard is synchronous
      // and prevents the API call that could trigger an error dialog.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should appear when the form validator blocks the save',
      );
    },
  );
}
