import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:road_mobile/ui/utils/step_up/step_up_sheet.dart';

import 'auth.dart';
import 'reset.dart';
import 'scenario.dart';
import 'totp.dart';

/// The staging provider's `mfaPolicy.freshnessWindow`, in seconds. Step-up
/// only fires on a session whose last MFA proof is older than this, and a
/// password+TOTP login stamps the session as proven at creation, so a test
/// can only provoke a step-up by outliving the window. The API default is
/// 15 min, far too long for a test; the e-flux staging provider is expected
/// to run the schema minimum (1 min). Pass
/// `--dart-define=TEST_STEP_UP_FRESHNESS_SECONDS=…` if it is set differently.
const testStepUpFreshnessSeconds = int.fromEnvironment('TEST_STEP_UP_FRESHNESS_SECONDS', defaultValue: 60);

/// The most a test will idle to let the session go stale before giving up
/// with a pointer at the provider setting.
const _maxStaleWait = Duration(seconds: 150);

/// Idles until the current session's last MFA proof is older than
/// [testStepUpFreshnessSeconds] (plus a small margin for clock skew between
/// the device stamp and the server's `mfaVerifiedAt`), so the next gated
/// write is refused with MFA_STEP_UP_REQUIRED. Fails fast when the wait
/// would exceed [_maxStaleWait], which means the staging provider's window
/// is longer than this build assumes.
Future<void> awaitStepUpStale(PatrolIntegrationTester $) async {
  final stamp = await sessionMfaStamp();
  if (stamp == null) {
    fail('no session MFA stamp found; log in via loginAsStagingUser before calling awaitStepUpStale');
  }
  final staleAt = stamp.add(Duration(seconds: testStepUpFreshnessSeconds + 10));
  final wait = staleAt.difference(DateTime.now());
  if (wait <= Duration.zero) return;
  if (wait > _maxStaleWait) {
    fail('session would need ${wait.inSeconds}s more to go MFA-stale. Set the staging provider '
        'mfaPolicy.freshnessWindow to 1 minute, or pass --dart-define=TEST_STEP_UP_FRESHNESS_SECONDS '
        'to match its actual value (currently assumed $testStepUpFreshnessSeconds).');
  }
  // ignore: avoid_print
  print('awaitStepUpStale: idling ${wait.inSeconds}s for the session to outlive the MFA freshness window');
  await pause($, wait.inMilliseconds);
}

/// Waits for the MFA step-up sheet to appear (a gated write was refused with
/// MFA_STEP_UP_REQUIRED), types the computed TOTP code and waits for the
/// sheet to close. With one active factor the sheet opens straight on code
/// entry; the pin field auto-submits on the sixth digit and success pops the
/// sheet with `true`, after which the caller's action is retried by
/// `runWithStepUp`.
Future<void> answerStepUpWithTotp(PatrolIntegrationTester $) async {
  requireTotpSecret();
  await $(StepUpSheet).$(TextField).waitUntilVisible();
  while (totpSecondsRemaining() < 4) {
    await $.tester.pump(const Duration(milliseconds: 250));
  }
  await $(StepUpSheet).$(TextField).enterText(totpCode(testTotpSecret), settlePolicy: SettlePolicy.noSettle);
  await waitUntilGone($, $(StepUpSheet));
  expect($(StepUpSheet), findsNothing, reason: 'the step-up sheet should close after a correct TOTP code');
  // The server re-stamped the session; record it so a later step-up test on
  // the reused session knows to wait the window out again.
  await stampSessionLogin();
}

/// Backs out of the step-up sheet by tapping the modal barrier above it. The
/// sheet resolves null, `runWithStepUp` rethrows the original refusal and the
/// gated write is abandoned. Barrier tap rather than a back press so it
/// behaves the same on both platforms.
Future<void> dismissStepUpSheet(PatrolIntegrationTester $) async {
  await $(StepUpSheet).waitUntilVisible();
  final size = $.tester.view.physicalSize / $.tester.view.devicePixelRatio;
  await $.tester.tapAt(Offset(size.width / 2, 40));
  await waitUntilGone($, $(StepUpSheet));
  expect($(StepUpSheet), findsNothing, reason: 'tapping the barrier should dismiss the step-up sheet');
}
