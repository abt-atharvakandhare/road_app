import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_item_widget.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_filter_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/sessions_screen.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/session_period.dart';

// Shape: logged-in sub-flow / filter → clear.
//
// Prerequisite: a staging account with sessions in the seeded test period
// (TEST_SESSION_YEAR / TEST_SESSION_MONTH, see _helpers/session_period.dart).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// Flow:
//   1. Boot, log in, navigate to Wallet → Sessions.
//   2. Apply the seeded year + month. Assert rows are present and the
//      active-filter subtitle shows the period.
//   3. Reopen filter. Assert "Clear Filters" is visible (it only renders when
//      _hasActiveFilters). Tap it to null out the local selections, then apply
//      via the AppBar close (Icons.close).
//   4. Wait for the unfiltered list to render rows, then reopen the filter
//      screen and assert "Clear Filters" is ABSENT: it is built from the
//      cubit's hasActiveFilters, so its absence proves selectedYear and
//      selectedMonth are null after the round-trip.
//
// Why not assert on the subtitle text disappearing: the active-filter subtitle
// and the unfiltered list's month-year section headers are both Text widgets
// in the same "Month YYYY" format. When the seeded period is also the
// account's most recent month the two collide, so a findsNothing on the
// subtitle string is ambiguous. The filter screen's button is unambiguous and
// reads the cubit state at the moment it opens, so there is no stale-frame
// race either.

void main() {
  e2eTest(
    'sessions clear filters: apply year filter then clear, list returns to unfiltered state',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate to Wallet → Sessions. The filter IconButton is present
      // immediately (independent of the cubit fetch), so its visibility is our
      // "tab is ready" signal.
      await tapTab($, AppTab.wallet);
      await $(SessionsScreen).$(IconButton).waitUntilVisible();

      // ── Step 1: Apply the seeded period ──────────────────────────────────

      await filterSessionsToTestPeriod($);

      // With year+month both set, the list skips per-section month headers, so
      // the period string appears ONLY as the active-filter subtitle.
      await $(SessionItemWidget).waitUntilVisible();
      expect(
        $(SessionItemWidget),
        findsWidgets,
        reason: '$testSessionPeriodSubtitle sessions should be present for this account',
      );
      expect(
        $(testSessionPeriodSubtitle),
        findsOneWidget,
        reason: 'the applied filter subtitle should show "$testSessionPeriodSubtitle"',
      );

      // ── Step 2: Reopen filter, clear, apply ──────────────────────────────

      await $(SessionsScreen).$(IconButton).tap();
      await $(SessionsFilterScreen).waitUntilVisible();

      // "Clear Filters" TextButton only renders when _hasActiveFilters; its
      // presence here also confirms the filter state survived the round-trip.
      await $('Clear Filters').waitUntilVisible();
      await $('Clear Filters').tap();

      // After _clearFilters(), local _selectedYear/_selectedMonth are null, so
      // _hasActiveFilters is false and the TextButton disappears. Apply via
      // the AppBar close, which calls applyFilters(year: null, month: null).
      await $(SessionsFilterScreen).$(IconButton).$(Icons.close).tap();

      // ── Step 3: Assert unfiltered state ──────────────────────────────────

      // The unfiltered query returns all sessions, most-recent first; the list
      // re-renders behind a shimmer, so wait for rows rather than settling.
      await waitUntilGone($, $(SessionsFilterScreen));
      await $(SessionItemWidget).waitUntilVisible();
      expect(
        $(SessionItemWidget),
        findsWidgets,
        reason: 'unfiltered list should have session rows',
      );

      // Reopening the filter screen reads the cubit state fresh: no active
      // filters → no "Clear Filters" button.
      await $(SessionsScreen).$(IconButton).tap();
      await $(SessionsFilterScreen).waitUntilVisible();
      expect(
        $('Clear Filters'),
        findsNothing,
        reason: 'after clear+apply the filter screen must not offer Clear Filters (selectedYear/selectedMonth == null)',
      );
      await $(SessionsFilterScreen).$(IconButton).$(Icons.close).tap();
      await waitUntilGone($, $(SessionsFilterScreen));
    },
  );
}
