import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

import '_helpers/scenario.dart';
import '_helpers/scroll.dart';

// Template: a "logged-in action + assert" test. Boot straight onto staging,
// log in, then log out from the Account tab, and assert the app is in the
// logged-out state (SignupNowWidget visible).
//
// Canary for AuthCubit logged-out guards: if any guard emits after the cubit
// is torn down this test will surface the resulting StateError.
//
// Prerequisite: any staged-in account; no special state required — the default
// ray+uk3@road.io account works out of the box.
// Credentials via --dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=….
//
// No confirmation dialog: logout calls AuthCubit.logout() directly with no
// RMDestructiveConfirmationSheet. The logout RMInkwellButton is below the fold
// on a scrolling Account screen, so we scrollTo() it before tapping.

void main() {
  e2eTest(
    'logout: tap logout on Account tab, app returns to logged-out state',
    ($) async {
      requireCredentials();
      await bootLoginEnrolled($);

      // bootLoginEnrolled leaves us on the Account tab. The tab content is a
      // SingleChildScrollView; the Logout RMInkwellButton is near the bottom,
      // below many link rows + 35px gaps. The button is the only RMInkwellButton
      // on the Account screen that contains the text 'Logout'.
      //
      // Use scrollIntoView (programmatic, momentum-free) rather than scrollTo:
      // gesture drags fling under iOS BouncingScrollPhysics and overshoot past
      // the button (see _helpers/scroll.dart).
      final logoutButton = $(RMInkwellButton).containing('Logout');
      await scrollIntoView($, logoutButton);
      await logoutButton.tap(settlePolicy: SettlePolicy.noSettle);

      // Logout calls AuthCubit.logout() synchronously from the button's
      // onPressed. The AuthCubit transitions to LoggedOut, which causes
      // _AccountRootScreen to rebuild and replace the logged-in list with
      // SignupNowWidget.
      //
      // Use waitUntilExists, not waitUntilVisible: we tapped Logout at the bottom
      // of the scrolled list, so the rebuilt logged-out view's SignupNowWidget is
      // off-screen (above the current scroll offset) and not hit-testable. Its
      // mere presence in the tree is the definitive logged-out signal — it only
      // renders when !isLoggedIn.
      await $(SignupNowWidget).waitUntilExists();
      expect(
        $(SignupNowWidget),
        findsOneWidget,
        reason:
            'after logout the Account tab should show SignupNowWidget (logged-out state)',
      );

      // Also confirm the Logout button itself is gone — it only renders when
      // isLoggedIn is true, so its absence guards against a partial logout.
      expect(
        $(RMInkwellButton).containing('Logout'),
        findsNothing,
        reason: 'the Logout button should not be visible when logged out',
      );

      // Sanity: the AccountLinkWidget rows (Profile, Notifications, etc.) that
      // are gated behind isLoggedIn should also have disappeared.
      expect(
        $(AccountLinkWidget).containing('Profile'),
        findsNothing,
        reason: 'logged-in-only rows should not be visible after logout',
      );
    },
  );
}
