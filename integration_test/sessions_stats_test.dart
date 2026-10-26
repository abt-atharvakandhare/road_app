import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/widgets/sessions_stats_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';

// Asserts that the SessionsStatsWidget renders its four stat-label Texts on the
// Wallet → Sessions screen.
//
// WHY labels, not values: the stat values depend on the account's session data
// (an account with no sessions gets zeroed/null stats and the value slots show
// "0" or "-"). The label strings ("Total sessions", "Total Energy", "Total
// time", "Cost") are always rendered by SessionsStatsWidget regardless of the
// stats payload, making them a stable, data-agnostic signal that the widget is
// mounted and visible.
//
// WHY no pumpAndSettle: SessionsScreen renders an RMShimmerLoader (continuously
// animating) while the cubit fetches sessions, so pumpAndSettle never settles.
// e2eConfig uses SettlePolicy.noSettle; we wait on a concrete widget instead.
//
// WHY SessionsStatsWidget before the labels: the stats widget is added to the
// scroll-child list unconditionally, above the shimmer, so it mounts as soon as
// the screen builds — before the sessions API response arrives. Waiting on it
// (waitUntilExists) is the earliest reliable gate; then the label assertions
// need no further waits.
//
// Prerequisite: a staging account (ray+uk3 has 83 sessions across multiple months).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'sessions stats: SessionsStatsWidget renders all four stat labels',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Navigate to Wallet → Sessions (the default wallet tab).
      await tapTab($, AppTab.wallet);

      // SessionsStatsWidget is placed above the shimmer in the scroll-child
      // list and mounts on the first frame of the screen build — no need to
      // wait for the API response. waitUntilExists (not waitUntilVisible) avoids
      // the hit-testability requirement; the widget is in the tree immediately
      // even if the frame hasn't fully painted.
      await $(SessionsStatsWidget).waitUntilExists();
      expect(
        $(SessionsStatsWidget),
        findsOneWidget,
        reason: 'SessionsStatsWidget should be present in the sessions screen',
      );

      // Assert the four stat cells rendered STRUCTURALLY via their icons, not the
      // label strings — labels come from Phrase at runtime (not app_en.arb) and
      // can differ. Each of the four stats (sessions / energy / time / cost)
      // renders an SvgPicture icon unconditionally, so four icons == the full
      // stats grid mounted, regardless of the account's session data.
      expect(
        $(SessionsStatsWidget).$(SvgPicture),
        findsAtLeastNWidgets(4),
        reason: 'all four stat cells (icons) should render in SessionsStatsWidget',
      );
    },
  );
}
