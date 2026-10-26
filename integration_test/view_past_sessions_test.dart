import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_details_screen.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/session_item_widget.dart';

import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/session_period.dart';

// Template: a "logged-in view + assert" test. Boot straight onto staging,
// log in, navigate to a list screen, assert it loads, open a detail.
//
// Prerequisite: a staging account with at least one session in the seeded
// test period (see _helpers/session_period.dart — we filter to the seeded
// period so the rows asserted on are deterministic).
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….

void main() {
  e2eTest(
    'view past sessions: list loads and a row opens details',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // Wallet → Sessions (the first/default tab of the wallet TabBar), then
      // filter to the seeded period so the rows we open are the known ones.
      await tapTab($, AppTab.wallet);
      await filterSessionsToTestPeriod($);

      // The sessions list renders behind a continuously-animating shimmer
      // (RMShimmerLoader) during SessionsCubit's fetch, so a default
      // pumpAndSettle would hit the settleTimeout. Wait for the rows to mount
      // instead.
      await $(SessionItemWidget).waitUntilVisible();
      expect(
        $(SessionItemWidget),
        findsWidgets,
        reason: '$testSessionPeriodSubtitle should have at least one session for this account',
      );

      // Open the first session — the row is an RMInkwellButton whose onPressed
      // does SessionDetailsScreen.push.
      await $(SessionItemWidget).at(0).tap();
      await $(SessionDetailsScreen).waitUntilVisible();
      expect(
        $(SessionDetailsScreen),
        findsOneWidget,
        reason: 'tapping a session row should open its details screen',
      );
    },
  );
}
