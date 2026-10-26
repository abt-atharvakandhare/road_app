import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/billing_address/billing_address_screen.dart';
import 'package:road_mobile/ui/utils/widgets/billing_address_update_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Template: a "form-submit" test. Boot straight onto staging, log in, open the
// Billing Address screen from the Account tab, edit the city field, save, and
// assert the save succeeded.
//
// Prerequisite: a staging account that already has a billing address set (so
// the form pre-populates valid street/house/postcode/country values and only
// the city field needs to be overwritten). If the account has NO address, the
// street, house-number, and post-code fields will be empty and the form will
// reject the save — fill those fields first or use an account that already has
// an address. Default test account ray+uk3@road.io is assumed to have an
// address.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// We read the CURRENT city and bump a trailing ordinal ('QA City 7' → 'QA City
// 8') so every run writes a genuinely NEW value — otherwise a fixed value would
// already be set from the prior run and "it persists" would prove nothing. The
// ordinal just grows; harmless on staging. (Same approach as profile_edit_test.)
//
// RISK: this mutates real staging account data (the city field). The written
// value ('QA City N') is harmless but visible in the account until changed again.

void main() {
  e2eTest(
    'billing address edit: change city, save, and it persists',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Account → Billing Address. The Account screen is a scrolling list of
      // AccountLinkWidget rows; scope to the one whose label is 'Billing Address'
      // and scroll it into view before tapping. ('Billing Address' alone could
      // be ambiguous once BillingAddressScreen is mounted — scope to the row
      // widget, not the bare string, to avoid matching the screen's own heading.)
      final billingAddressLink = $(AccountLinkWidget).containing('Billing Address');
      await scrollIntoView($, billingAddressLink);
      await billingAddressLink.tap();
      await $(BillingAddressScreen).waitUntilVisible();

      // The city field is TextFormField index 2 inside BillingAddressUpdateWidget
      // (DOM order: street=0, houseNumber=1, city=2, postCode=3). Scoping to
      // BillingAddressUpdateWidget avoids picking up any fields from screens
      // behind it. TextFormField renders as a TextField in the widget tree.
      final cityField = $(BillingAddressUpdateWidget).$(TextField).at(2);
      await cityField.waitUntilVisible();

      // Read the CURRENT value and bump its trailing ordinal so we always write a
      // new, different value (makes the persistence assertion meaningful).
      final current =
          (cityField.evaluate().single.widget as TextField).controller?.text ?? '';
      final ordinal = int.tryParse(RegExp(r'(\d+)\s*$').firstMatch(current)?.group(1) ?? '') ?? 0;
      final newCity = 'QA City ${ordinal + 1}';

      // noSettle: the field carries autofillHints (addressCity), which on a real
      // iOS device triggers the QuickType / autofill bar and keeps the frame
      // pipeline busy. We don't need the screen quiet between actions.
      await cityField.enterText(newCity, settlePolicy: SettlePolicy.noSettle);

      // Save: the 'Update Billing Information' button is an RMTextButton below
      // the fold; scroll it in before tapping. On success the screen calls
      // Navigator.pop(true) and shows a 'Billing address successfully updated'
      // snackbar. On failure (e.g. invalid postcode) an AlertDialog appears
      // instead, or the form shows inline errors — no pop occurs.
      final saveButton = $(BillingAddressUpdateWidget).$(RMTextButton);
      await scrollIntoView($, saveButton);
      await saveButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Primary success assertion: no error dialog surfaced. BillingAddressScreen
      // only shows an AlertDialog on a network/API error; the happy path pops +
      // snackbars.
      expect(
        $(AlertDialog),
        findsNothing,
        reason: 'no error dialog should appear on a successful billing address save',
      );

      // Saving calls Navigator.pop(true), so wait for BillingAddressScreen to
      // leave the tree — that's the in-app signal the save completed.
      // PatrolFinder has no waitUntilGone, so poll evaluate() until empty (the
      // same pattern used in profile_edit_test.dart).
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while ($(BillingAddressScreen).evaluate().isNotEmpty &&
          DateTime.now().isBefore(deadline)) {
        await $.tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        $(BillingAddressScreen),
        findsNothing,
        reason: 'a successful save pops BillingAddressScreen back to the Account tab',
      );

      // Persistence: re-open Billing Address and confirm the city field is
      // pre-populated with the value we saved (initState reads it back from the
      // refreshed profile in AuthCubit).
      final billingAddressLinkAgain = $(AccountLinkWidget).containing('Billing Address');
      await scrollIntoView($, billingAddressLinkAgain);
      await billingAddressLinkAgain.tap();
      await $(BillingAddressScreen).waitUntilVisible();

      final reopenedCityField = $(BillingAddressUpdateWidget).$(TextField).at(2);
      await reopenedCityField.waitUntilVisible();
      final controllerText =
          (reopenedCityField.evaluate().single.widget as TextField).controller?.text;
      expect(
        controllerText,
        newCity,
        reason: 'the newly saved city should persist and pre-populate on reopen',
      );
    },
  );
}
