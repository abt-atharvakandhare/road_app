import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/debug_controls_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';

import 'nav.dart';
import 'scroll.dart';

/// Taps the debug "Force session renewal (Face ID test)" button.
///
/// Requires debug controls enabled (seeded by `bootApp`) and the Account tab
/// visible. Deletes the JWT, shows splash, and re-enters `moveToInitialAppState`,
/// which finds the stored renewal token and fires the biometric renewal: read
/// prompt (+ write prompt on Android). Settle is left to the caller via the
/// biometric helpers — taps noSettle because the prompt blocks the app.
///
/// The debug buttons sit at the very bottom of the Account screen (below
/// Logout), so use scrollIntoView, not scrollTo: a gesture drag flings under iOS
/// BouncingScrollPhysics and overshoots past them (see scroll.dart).
Future<void> tapForceSessionRenewal(PatrolIntegrationTester $) async {
  final btn = $(DebugControlsWidget).$('Force session renewal (Face ID test)');
  await scrollIntoView($, btn);
  await btn.tap(settlePolicy: SettlePolicy.noSettle);
}

/// Taps the debug "Invalidate JWT token" button (writes a dummy token). The
/// next authenticated request 401s → global handler → silent renewal attempt.
Future<void> tapInvalidateJwt(PatrolIntegrationTester $) async {
  final btn = $(DebugControlsWidget).$('Invalidate JWT token');
  await scrollIntoView($, btn);
  await btn.tap(settlePolicy: SettlePolicy.noSettle);
}

/// Asserts the app is logged IN by switching to the Account tab and confirming
/// the logged-out SignupNow CTA is absent. [SignupNowWidget] renders only when
/// logged out, so its absence on the Account tab is the logged-in sentinel.
Future<void> expectLoggedIn(PatrolIntegrationTester $) async {
  await tapTab($, AppTab.account);
  // Don't pumpAndSettle — the Account screen can keep animating and it would
  // throw at the settleTimeout. Wait for a logged-in-only widget instead: the
  // AccountLinkWidget rows (Profile etc.) render only when logged in, so their
  // presence confirms the logged-in state. Use waitUntilExists, not
  // waitUntilVisible: after an organic renewal a transient loading overlay (e.g.
  // _refreshAccountDetails) can leave the rows in the tree but not hit-testable,
  // and existence alone is the logged-in signal.
  await $(AccountLinkWidget).waitUntilExists();
  expect(
    $(SignupNowWidget),
    findsNothing,
    reason: 'expected to be logged in (no SignupNow CTA on the Account tab)',
  );
  // Linger on the Account tab so the BrowserStack video ends on a frame that
  // visibly shows the logged-in state (no SignupNow CTA).
  await $.pump(const Duration(seconds: 2));
}

/// Asserts the app is logged OUT by switching to the Account tab and confirming
/// the SignupNow CTA is shown.
Future<void> expectLoggedOut(PatrolIntegrationTester $) async {
  await tapTab($, AppTab.account);
  // waitUntilExists, not waitUntilVisible: SignupNowWidget renders only when
  // logged out, so its presence is the signal; a transient overlay could leave
  // it in the tree but not hit-testable.
  await $(SignupNowWidget).waitUntilExists();
  expect(
    $(SignupNowWidget),
    findsOneWidget,
    reason: 'expected to be logged out (SignupNow CTA visible on Account tab)',
  );
  // Linger on the Account tab so the BrowserStack video ends on a frame that
  // visibly shows the logged-out state (the SignupNow CTA).
  await $.pump(const Duration(seconds: 2));
}
