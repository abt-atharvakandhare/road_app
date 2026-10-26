import 'package:patrol/patrol.dart';

/// Bottom-navigation tabs, keyed by their visible label
/// (see main_app_root_screen.dart). `explore` is the centre charge button,
/// which pushes the Charge Now modal rather than switching tabs.
///
/// FOLLOW-UP: these labels are English strings, so they're locale-fragile (the
/// same applies to other string finders like `$('Notifications')` in tests).
/// Centralising them here is the organising step; the proper fix is adding
/// `Semantics(identifier: 'rm-tab-…')` keys to the nav items and matching on
/// those instead. Tracked in tasks/todo-e2e-test-suite-plan.md (infra step 2).
enum AppTab {
  home('Home'),
  map('Map'),
  explore('Explore'),
  wallet('Wallet'),
  account('Account');

  const AppTab(this.label);
  final String label;
}

/// Taps a bottom-navigation [tab] by its label. The bar hides labels visually
/// but keeps them as semantic labels, so the label finder still resolves.
///
/// Uses `noSettle` and does NOT pumpAndSettle: a destination tab can mount a
/// continuously-animating loader (e.g. Wallet → Sessions renders an
/// RMShimmerLoader during the cubit fetch; the map never settles), which would
/// hang pumpAndSettle until the settleTimeout. The caller should wait on a
/// specific destination widget instead (Patrol finders auto-wait), which is the
/// correct, non-flaky way to know the tab is ready.
Future<void> tapTab(PatrolIntegrationTester $, AppTab tab) async {
  await $(tab.label).tap(settlePolicy: SettlePolicy.noSettle);
}
