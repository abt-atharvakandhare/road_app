import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/account_link_widget.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';

import 'app_launch.dart';
import 'auth.dart';
import 'biometric.dart';
import 'nav.dart';

/// Staging credentials, injected at build time so they never land in source.
/// Run with `--dart-define=TEST_EMAIL=… --dart-define=TEST_PASSWORD=…`.
const testEmail = String.fromEnvironment('TEST_EMAIL');
const testPassword = String.fromEnvironment('TEST_PASSWORD');

/// Base32 secret of the account's authenticator-app (TOTP) factor, when the
/// account has MFA enabled: `--dart-define=TEST_TOTP_SECRET=…`. Optional; the
/// login helper only needs it when the API actually issues an MFA challenge.
const testTotpSecret = String.fromEnvironment('TEST_TOTP_SECRET');

/// Shared Patrol config for the whole e2e suite.
///
/// `settlePolicy: noSettle` is the important bit. Several screens in this app
/// keep the frame pipeline busy (animated loaders, shimmers), so the default
/// `trySettle` makes every un-annotated tap run a `pumpAndSettle` that never
/// reaches idle and gives up only at `settleTimeout` — i.e. ~10s of dead wait
/// per tap. `noSettle` returns immediately; tests wait for specific target
/// widgets instead (Patrol finders auto-wait up to `existsTimeout`). The
/// remaining role of `settleTimeout` is a backstop for any *explicit*
/// `pumpAndSettle`, kept modest.
const e2eConfig = PatrolTesterConfig(
  settlePolicy: SettlePolicy.noSettle,
  settleTimeout: Duration(seconds: 10),
  existsTimeout: Duration(seconds: 20),
  printLogs: true,
);

/// Seconds to linger on each test's final screen so it's visible manually / on
/// the recording. Default 2s; `--dart-define=E2E_END_LINGER_SECONDS=0` disables
/// it, at the cost of end states no longer being visible on session videos
/// (it adds N×2s to a full run). The BrowserStack scripts forward the
/// `E2E_END_LINGER_SECONDS` env var when set and keep the 2s default otherwise.
const _endLingerSeconds = int.fromEnvironment('E2E_END_LINGER_SECONDS', defaultValue: 2);

/// Use this instead of `patrolTest` for every e2e test. It applies [e2eConfig]
/// and, after the body, lingers on the final screen (pumping frames so it
/// actually renders) — this MUST run inside the test body, because `addTearDown`
/// runs only after the app is already torn down (you'd just see "test finished").
void e2eTest(
  String description,
  Future<void> Function(PatrolIntegrationTester) body,
) {
  patrolTest(
    description,
    config: e2eConfig,
    ($) async {
      await body($);
      for (var i = 0; i < _endLingerSeconds * 10; i++) {
        await $.pump(const Duration(milliseconds: 100));
      }
    },
  );
}

/// Brief visible pause (pumps frames for [ms]) so a step is observable manually
/// or on the recording — handy for demoing/debugging a flow. NOT for
/// synchronisation (use `waitUntilVisible`/`waitUntilExists` for that).
Future<void> pause(PatrolIntegrationTester $, [int ms = 700]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await $.tester.pump(const Duration(milliseconds: 50));
  }
}

/// Logs a SKIP reason so it's visible in the run output. patrolTest has no
/// native skip, so a graceful skip is "logSkip(...) + return" — the test shows
/// as a 0s pass. Use for tests whose precondition (special account, data, or the
/// BrowserStack biometric dialog) isn't met, so the full suite stays green and
/// only real regressions show red.
void logSkip(String reason) {
  // ignore: avoid_print
  print('SKIP: $reason');
}

/// Polls until [finder] exists in the widget tree or [timeout] elapses.
/// Returns true if the widget appeared, false if it timed out.
///
/// Unlike `waitUntilExists`, this never throws — use it when a widget's
/// appearance is a *branch condition* (e.g. "did the sheet open, or should we
/// skip?") rather than an assertion.
Future<bool> waitForWidget(
  PatrolIntegrationTester $,
  PatrolFinder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.exists) return true;
    await $.tester.pump(const Duration(milliseconds: 100));
  }
  return false;
}

/// Polls until [finder] is no longer in the widget tree, then returns.
///
/// PatrolFinder has `waitUntilVisible`/`waitUntilExists` but no "wait until
/// gone". After popping a route the popped screen lingers in the tree for the
/// duration of the transition animation, so an immediate `findsNothing` races
/// the dispose. Use this before asserting a screen/route is gone.
///
/// Returns silently if [timeout] elapses with the widget still present — this
/// is a settling aid, not an assertion. Always follow it with an explicit
/// `findsNothing`-style check.
Future<void> waitUntilGone(
  PatrolIntegrationTester $,
  PatrolFinder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.exists && DateTime.now().isBefore(deadline)) {
    await $.tester.pump(const Duration(milliseconds: 100));
  }
}

/// Fails fast (with a useful message) if the credential defines are missing.
void requireCredentials() {
  if (testEmail.isEmpty || testPassword.isEmpty) {
    throw StateError(
      'Pass --dart-define=TEST_EMAIL and --dart-define=TEST_PASSWORD',
    );
  }
}

/// Shared preamble for most tests: boot (straight onto staging via seeded
/// prefs) → Account tab → logged in and biometric-enrolled. Leaves the app
/// logged in on staging.
///
/// Reuses the previous test's session when one survived `resetAppState`'s
/// plausibility check (see reset.dart) — the API throttles login per-account,
/// so a password login per test can lock the shared staging account out for
/// the rest of the run. The reuse branch requires the default [enroll] (Pass):
/// answering the enrollment prompt with Fail/Cancel is itself the point of a
/// test that passes those, so such a test always gets the full fresh flow.
///
/// If the app boots logged out anyway (first test of a run, a predecessor
/// logged out or de-enrolled, stale session aged out), this falls through to
/// the normal password login — which is also what re-arms reuse for the tests
/// after it.
Future<void> bootLoginEnrolled(
  PatrolIntegrationTester $, {
  BioResponse enroll = BioResponse.pass,
}) async {
  final reuse = enroll == BioResponse.pass;
  await bootApp($, preserveSession: reuse);
  await tapTab($, AppTab.account);
  if (reuse && await _bootedLoggedIn($)) return;
  await loginAsStagingUser($, testEmail, testPassword, enroll: enroll);
}

/// Distinguishes the Account tab's two states after boot. [AccountLinkWidget]
/// rows exist in BOTH (Support/About rows render logged out too), so row
/// presence only signals "the tab has rendered" — the verdict comes from
/// [SignupNowWidget], which renders exactly when logged out, in the same
/// build as the rows (no gap where rows exist but SignupNow hasn't mounted
/// yet). An inconclusive timeout reports logged OUT, sending the caller down
/// the real-login path — logging in from a half-rendered state is
/// recoverable, whereas skipping login on a broken session fails the test.
Future<bool> _bootedLoggedIn(PatrolIntegrationTester $) async {
  // The tab normally renders in a frame or two, so the deadline only bites
  // when the app is wedged.
  final deadline = DateTime.now().add(e2eConfig.existsTimeout);
  while (DateTime.now().isBefore(deadline)) {
    if ($(AccountLinkWidget).exists) return !$(SignupNowWidget).exists;
    await $.tester.pump(const Duration(milliseconds: 100));
  }
  return false;
}
