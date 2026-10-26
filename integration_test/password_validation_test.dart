import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/password_screen.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/security_screen.dart';
import 'package:road_mobile/ui/utils/widgets/mfa_option_row.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Validation test for the Password screen — read-safe, never mutates the
// account password.
//
// PasswordScreen has two TextFormField widgets (rendered as TextField in the
// widget tree, scoped inside PasswordScreen):
//   index 0 — Current Password  (validator: non-empty)
//   index 1 — New Password      (validator: DataValidation.validatePassword)
//
// DataValidation.validatePassword returns false when the value is empty (or
// lacks ≥8 chars, uppercase, lowercase, digit, and special character).
//
// Strategy: supply a valid-looking current password so that field passes, but
// leave new password empty ("") — the new-password validator returns false
// ("passwordMustContain" localised string) AND the isPasswordValid guard in
// onPressed also fires (DataValidation.validatePassword("") == false), so the
// combined condition `_formKey.currentState!.validate() && isPasswordValid`
// is false and changePassword is never called.
//
// After tapping the save button we assert STRUCTURALLY (not on any Phrase
// runtime string) that:
//   1. PasswordScreen is still mounted — a successful save calls
//      Navigator.pop(), so its continued presence proves the save was blocked.
//   2. No AlertDialog appeared — the API error dialog would only appear if the
//      network call had been made; pure client-side validation must not surface
//      one.
//
// Account: ray+uk3 — read-only for this test; the password is never changed.

void main() {
  e2eTest(
    'password validation: empty new password blocks save and keeps screen mounted',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate Account → Password & Authentication → Password. The password
      // form lives on the security screen's Password row (exact-text match, so
      // it can't collide with the longer screen heading).
      final securityLink = $(AccountLinkWidget).containing('Password & Authentication');
      await scrollIntoView($, securityLink);
      await securityLink.tap();
      await $(SecurityScreen).waitUntilVisible();
      await $(MfaOptionRow).containing('Password').tap();
      await $(PasswordScreen).waitUntilVisible();

      // Wait for the first TextField (Current Password) to be visible before
      // interacting — it anchors readiness for both fields.
      final currentField = $(PasswordScreen).$(TextField).at(0);
      await currentField.waitUntilVisible();

      // Fill Current Password with a plausible value. The current-password
      // validator only checks non-empty, so any non-empty string will pass.
      // We deliberately do NOT use the real testPassword — the form never
      // reaches the API, so the value is never sent.
      await currentField.enterText('placeholder', settlePolicy: SettlePolicy.noSettle);

      // Wait for all TextFields to be present before indexing at(1).
      await $(PasswordScreen).$(TextField).waitUntilExists();
      final newField = $(PasswordScreen).$(TextField).at(1);

      // Leave New Password empty — empty string fails DataValidation.validatePassword
      // AND the synchronous form validator.
      await newField.enterText('', settlePolicy: SettlePolicy.noSettle);

      // Scroll "Update Password" (RMTextButton) into view and tap it.
      // The save handler runs two synchronous checks:
      //   isPasswordValid = DataValidation.validatePassword('') → false
      //   _formKey.currentState!.validate()                    → false (new-password field)
      // Both fail, so changePassword is never called.
      final saveButton = $(PasswordScreen).$(RMTextButton);
      await scrollIntoView($, saveButton);
      await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Give Flutter one frame to run Form.validate() and rebuild. The
      // validator is synchronous; no animation or network hop is needed.
      await $.tester.pump();

      // Primary assertion: PasswordScreen is still in the tree. A successful
      // save calls Navigator.pop() — the screen staying mounted is the
      // structural proof that the save was blocked.
      expect(
        $(PasswordScreen),
        findsOneWidget,
        reason: 'PasswordScreen must remain mounted when the new-password field is empty — a blocked save must not pop the screen',
      );

      // Secondary assertion: no AlertDialog should appear. Error dialogs are
      // only shown when the API call fails; because we never reached the API
      // call there must be no dialog.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'a pure client-side validation failure must not produce an error dialog',
      );
    },
  );
}
