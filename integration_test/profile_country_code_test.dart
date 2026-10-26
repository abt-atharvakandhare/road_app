import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/profile/profile_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_country_widget.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Tests the phone country-code picker on the Profile screen.
//
// Steps:
//   1. Boot → log in (account ray+uk3, country GB / +44).
//   2. Navigate Account → Profile.
//   3. Tap the RMCountryPickerWidget to open the country-picker bottom sheet.
//   4. Use the search TextField (inside the bottom sheet) to filter to "Germany"
//      and tap the Germany row (InkWell containing the text "Germany").
//   5. Assert the bottom sheet dismissed (BottomSheet widget gone from tree) and
//      RMCountryPickerWidget now shows "DE" instead of "GB".
//   6. Navigate back WITHOUT saving — the AppBar back button pops the screen
//      before updateProfile is ever called.
//
// No mutation: updateProfile is not called; the country change is _ProfileScreenState
// local state only (_phoneCountry) and is discarded on pop.
//
// Account: ray+uk3 (country GB, +44). DE is in the RMCountryPickerWidget
// favourites list ['NL','BE','DE','FR','GB'] so it appears near the top even
// without a search filter — but we search anyway to make the row tap unambiguous.
//
// Picker anatomy (country_picker 2.0.28):
//   showCountryPicker → showModalBottomSheet (a BottomSheet widget in the tree)
//   └─ CountryListView (internal, not exported)
//      ├─ TextField (search bar, showSearch: true by default)
//      └─ ListView
//         └─ InkWell  ← one per country row, contains Text(country.name)
//
// CountryListView is NOT exported from country_picker's public API
// (only CustomFlagBuilder is). We therefore anchor on BottomSheet (the
// Material widget showModalBottomSheet injects) to detect open/close, and
// scope the search field and country rows to $(BottomSheet) to avoid
// colliding with ProfileScreen's own TextFields.

void main() {
  e2eTest(
    'profile country code: open picker, select Germany DE, assert selection reflected - no save',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate Account → Profile.
      final profileLink = $(AccountLinkWidget).containing('Profile');
      await scrollIntoView($, profileLink);
      await profileLink.tap();
      await $(ProfileScreen).waitUntilVisible();

      // Wait for the first-name field to be visible — that confirms the form
      // is fully built including the country picker row below it.
      final firstNameField = $(ProfileScreen).$(TextField).at(0);
      await firstNameField.waitUntilVisible();

      // The country picker button is the RMCountryPickerWidget inside
      // ProfileScreen. In shortVersion mode it renders:
      //   Text('${country.flagEmoji} ${country.countryCode} +${country.phoneCode}  ')
      // For ray+uk3 (GB) that is "🇬🇧 GB +44  ". Scroll it into view, then tap.
      final countryPickerButton = $(ProfileScreen).$(RMCountryPickerWidget);
      await scrollIntoView($, countryPickerButton);
      await countryPickerButton.tap(settlePolicy: SettlePolicy.noSettle);

      // showCountryPicker → showModalBottomSheet inserts a BottomSheet widget
      // into the overlay. Wait for it to exist before interacting.
      await $(BottomSheet).waitUntilExists();

      // The picker's search TextField is the only TextField inside the
      // BottomSheet (ProfileScreen's own TextFields are behind the overlay).
      final searchField = $(BottomSheet).$(TextField);
      await searchField.waitUntilVisible();

      // Filter the list to "Germany" so the row tap is unambiguous.
      await searchField.enterText('Germany', settlePolicy: SettlePolicy.noSettle);

      // One frame for the ListView to filter and rebuild.
      await $.tester.pump();

      // Each country row is an InkWell containing a Text with the country name.
      // After tapping, the picker calls Navigator.pop(context) → BottomSheet
      // dismisses and the onSelect callback fires → _ProfileScreenState.setState
      // updates _phoneCountry to DE.
      final germanyRow = $(BottomSheet).$(InkWell).containing('Germany');
      await germanyRow.waitUntilExists();
      await germanyRow.tap(settlePolicy: SettlePolicy.noSettle);

      // Wait for the BottomSheet to leave the overlay tree (dismissed).
      await waitUntilGone($, $(BottomSheet));

      // Primary assertion: RMCountryPickerWidget now shows Germany. The button's
      // shortVersion renders a SINGLE Text "🇩🇪 DE +49  " (flag + code + dial code),
      // so an exact-text finder ('DE') misses — match the dial code as a substring
      // via RegExp (Patrol maps RegExp → find.textContaining). "+49" = Germany;
      // "+44" (GB, the original) must be gone.
      await $(ProfileScreen).$(RMCountryPickerWidget).waitUntilExists();

      expect(
        $(ProfileScreen).$(RegExp(r'DE \+49')),
        findsOneWidget,
        reason: 'country picker must show Germany (DE +49) after selecting it',
      );
      expect(
        $(ProfileScreen).$(RegExp(r'GB \+44')),
        findsNothing,
        reason: 'country picker must no longer show GB (+44) after selecting Germany',
      );

      // Discard: tap the AppBar back button to pop ProfileScreen without saving.
      // updateProfile is never called so the account is unchanged.
      final backButton = $(ProfileScreen).$(BackButton);
      await backButton.tap(settlePolicy: SettlePolicy.noSettle);
      await waitUntilGone($, $(ProfileScreen));

      expect(
        $(ProfileScreen),
        findsNothing,
        reason: 'ProfileScreen must be gone after navigating back without saving',
      );
    },
  );
}
