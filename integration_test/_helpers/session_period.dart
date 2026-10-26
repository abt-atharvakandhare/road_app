import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_screen.dart';
import 'package:road_mobile/ui/utils/widgets/rm_month_picker.dart';
import 'package:road_mobile/ui/utils/widgets/rm_year_picker.dart';

/// The known-seeded historical period that session-list tests filter to.
///
/// SessionsCubit starts unfiltered (full paginated history, DRI-946), so the
/// default list does show rows for any account with sessions. Tests still
/// filter to this fixed period (see [filterSessionsToTestPeriod]) so that row
/// counts, the active-filter subtitle and the stats grid are deterministic and
/// independent of whatever the account charged most recently.
///
/// Defaults to July 2026: the default staging test account
/// (ray+automation@road.io) has charging sessions there. Override for a
/// differently-seeded account via
/// --dart-define=TEST_SESSION_YEAR=… --dart-define=TEST_SESSION_MONTH=… (1-12).
const testSessionYear = int.fromEnvironment('TEST_SESSION_YEAR', defaultValue: 2026);
const testSessionMonth = int.fromEnvironment('TEST_SESSION_MONTH', defaultValue: 7);

// English month names, matching the picker grid (short) and the active-filter
// subtitle (full). English-only, like the suite's other string finders.
const _shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _fullMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// The month label shown in the RmMonthPicker grid, e.g. 'Nov'.
String get testSessionShortMonth => _shortMonths[testSessionMonth - 1];

/// The active-filter subtitle shown after applying, e.g. 'November 2025'.
String get testSessionPeriodSubtitle => '${_fullMonths[testSessionMonth - 1]} $testSessionYear';

/// Filters the Sessions list to [testSessionYear]/[testSessionMonth].
///
/// Requires the Wallet tab (Sessions sub-tab, the default) to be current. Steps:
///
/// - The filter IconButton is the only IconButton in the SessionsScreen subtree
///   at rest — the cost-stat tooltip trigger is a GestureDetector, and its
///   IconButton only exists inside the (closed) tooltip popup. It renders
///   immediately, independent of the cubit fetch, so it doubles as the
///   "tab is ready" signal.
/// - With both feature-flagged dropdowns (Defines.showChargeCardFilter /
///   showPaymentMethodFilter) off, the only two dropdown selectors are Year
///   (index 0) and Month (index 1); each carries an Icons.expand_more_rounded
///   chevron that opens its picker.
/// - The filter screen's AppBar close button applies the selection
///   (applyFilters → re-query) and pops back to the list.
///
/// On return the list is re-querying behind a shimmer — callers should wait on
/// SessionItemWidget (NOT pumpAndSettle; the shimmer never settles).
Future<void> filterSessionsToTestPeriod(PatrolIntegrationTester $) async {
  await $(SessionsScreen).$(IconButton).waitUntilVisible();
  await $(SessionsScreen).$(IconButton).tap();
  await $(SessionsFilterScreen).waitUntilVisible();

  await $(SessionsFilterScreen).$(Icons.expand_more_rounded).waitUntilVisible();
  await $(SessionsFilterScreen).$(Icons.expand_more_rounded).at(0).tap();
  await $(RmYearPicker).waitUntilVisible();
  await $('$testSessionYear').tap();
  await $('OK').tap();

  await $(SessionsFilterScreen).$(Icons.expand_more_rounded).at(1).tap();
  await $(RmMonthPicker).waitUntilVisible();
  await $(testSessionShortMonth).tap();
  await $('OK').tap();

  await $(SessionsFilterScreen).$(IconButton).$(Icons.close).tap();
}
