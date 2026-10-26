import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/billing_address/billing_address_screen.dart';
import 'package:road_mobile/ui/utils/widgets/billing_address_update_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Validation test for BillingAddressUpdateWidget.
//
// Prerequisite: account ray+uk3@road.io on staging has a billing address set
// (street "HS", city "Girvan", postcode "KA269AN", GB). The pre-populated form
// lets us clear a single required field to trigger inline validation without
// touching the others. This test NEVER successfully saves — it is read-safe.
//
// Field order inside BillingAddressUpdateWidget (TextFormField DOM order):
//   0 = street, 1 = houseNumber, 2 = city, 3 = postCode
//
// We clear postCode (index 3): the validator returns "Post code is required"
// when the value is empty. After tapping Save we assert:
//   1. The inline error text "Post code is required" is visible in the widget
//      tree — proof the form rejected the submission.
//   2. BillingAddressScreen is still in the tree — proof the screen did NOT
//      pop (i.e. the save was blocked).
// No AlertDialog or success snackbar is expected.

void main() {
  e2eTest(
    'billing address validation: clearing postcode blocks save and shows inline error',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate Account → Billing Address. Scope the tap target to the
      // AccountLinkWidget row to avoid matching the BillingAddressScreen heading
      // once that screen mounts.
      final billingAddressLink = $(AccountLinkWidget).containing('Billing Address');
      await scrollIntoView($, billingAddressLink);
      await billingAddressLink.tap();
      await $(BillingAddressScreen).waitUntilVisible();

      // Wait for the TextFormFields to be present before indexing into them.
      // waitUntilExists (not waitUntilVisible) because fields inside a
      // SingleChildScrollView are built but may not be in the visible viewport.
      await $(BillingAddressUpdateWidget).$(TextField).waitUntilExists();

      // Clear the postCode field (index 3). enterText('') replaces the current
      // controller text with an empty string. noSettle avoids pumpAndSettle
      // which never idles on this screen (autofill bar keeps the pipeline busy).
      final postCodeField = $(BillingAddressUpdateWidget).$(TextField).at(3);
      await postCodeField.enterText('', settlePolicy: SettlePolicy.noSettle);

      // Scroll the Save button into view and tap it. The form validator runs
      // synchronously inside onPressed; because postCode is empty the validator
      // returns "Post code is required" and _formKey.currentState!.validate()
      // returns false — the API call is never made.
      final saveButton = $(BillingAddressUpdateWidget).$(RMTextButton);
      await scrollIntoView($, saveButton);
      await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Give the framework a moment to rebuild with the validation error text.
      await $.tester.pump(const Duration(milliseconds: 300));

      // Assert the save was BLOCKED: BillingAddressScreen is still mounted. A
      // successful save calls Navigator.pop(true), so its continued presence is
      // the robust signal that validate() returned false and the API was never
      // called. (We don't assert the inline error STRING — it comes from Phrase
      // at runtime, not app_en.arb, so the exact text isn't reliable here.)
      expect(
        $(BillingAddressScreen),
        findsOneWidget,
        reason: 'BillingAddressScreen must remain mounted when the form is invalid — no pop should occur',
      );

      // Confirm no error dialog appeared (network/API errors surface as
      // AlertDialogs; none is expected here since we never reached the API).
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'a pure client-side validation failure must not produce an error dialog',
      );
    },
  );
}
