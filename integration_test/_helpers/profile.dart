import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

import 'scroll.dart';

/// Account tab → Profile, waiting until the form's first field is usable.
Future<void> openProfile(PatrolIntegrationTester $) async {
  final profileLink = $(AccountLinkWidget).containing('Profile');
  await scrollIntoView($, profileLink);
  await profileLink.tap();
  await $(ProfileScreen).waitUntilVisible();
  await $(ProfileScreen).$(TextField).at(0).waitUntilVisible();
}

/// The phone-number field: the only phone-keyboard TextField on the form, so
/// it is matched by type rather than by index (the disabled email field is
/// still a TextField and would shift indexes).
PatrolFinder phoneField(PatrolIntegrationTester $) => $(ProfileScreen).$(find.byWidgetPredicate(
      (widget) => widget is TextField && widget.keyboardType == TextInputType.phone,
    ));

/// Current text of [phoneField].
String phoneFieldText(PatrolIntegrationTester $) =>
    (phoneField($).evaluate().single.widget as TextField).controller?.text ?? '';

/// [phone] with its last digit changed: still the same length and country, so
/// it passes the form's validator, yet differs from the stored value so the
/// PATCH carries the phone fields and hits the step-up gate.
String flipLastDigit(String phone) {
  final last = int.parse(phone[phone.length - 1]);
  return phone.substring(0, phone.length - 1) + ((last + 1) % 10).toString();
}

/// Types [phone] into the phone field and taps Update Profile (below the fold).
Future<void> savePhone(PatrolIntegrationTester $, String phone) async {
  await scrollIntoView($, phoneField($));
  await phoneField($).enterText(phone, settlePolicy: SettlePolicy.noSettle);
  final saveButton = $(ProfileScreen).$(RMTextButton);
  await scrollIntoView($, saveButton);
  await saveButton.tap(settlePolicy: SettlePolicy.noSettle);
}

/// Fails unless the account has a phone number with at least one digit to
/// flip; the step-up tests cannot run against an empty phone field.
void requirePhoneNumber(String phone) {
  if (phone.isEmpty || int.tryParse(phone[phone.length - 1]) == null) {
    fail('the test account needs a numeric phone number on its profile (found "$phone")');
  }
}
