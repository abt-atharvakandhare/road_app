import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_item_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/session_period.dart';

// Template: a "logged-in sub-flow / filter" test. Boot onto staging, log in,
// open a list screen's filter, pick values, apply, and assert the list
// re-queries. This is the third core shape (after view+assert and form-submit)
// and unlocks the filter/pagination gaps.
//
// We filter to a *fixed historical period* rather than asserting on the
// default view — see _helpers/session_period.dart for the rationale, the
// period's data prerequisites, and the TEST_SESSION_YEAR / TEST_SESSION_MONTH
// overrides.
//
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'sessions filter: pick year + month, apply, list re-queries',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Wallet → Sessions (the first/default tab of the wallet TabBar), then
      // drive the filter flow (year picker → month picker → apply-on-close).
      await tapTab($, AppTab.wallet);
      await filterSessionsToTestPeriod($);

      // The re-query renders behind the shimmer again, so wait for rows rather
      // than pumpAndSettle. With year+month both set the list skips its
      // per-section month/year headers, so "<Month> <year>" appears only as the
      // active-filter subtitle — its presence proves the filter took effect.
      await $(SessionItemWidget).waitUntilVisible();
      expect(
        $(SessionItemWidget),
        findsWidgets,
        reason: '$testSessionPeriodSubtitle should have at least one session for this account',
      );
      expect(
        $(testSessionPeriodSubtitle),
        findsOneWidget,
        reason: 'applying the year+month filter should show its subtitle and re-query',
      );
    },
  );
}
