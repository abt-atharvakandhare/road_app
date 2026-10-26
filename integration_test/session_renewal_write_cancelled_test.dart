import 'dart:io' show Platform;


import '_helpers/biometric.dart';
import '_helpers/scenario.dart';
import '_helpers/session.dart';

// Android-only. Pins the 2026-06-02 fix: if the renewal-token WRITE prompt is
// cancelled *after* /auth/renew already returned a new JWT, the session is live
// (JWT stored) so the user must stay logged in — the renewer reports `renewed`
// and only clears the now-stale presence flag. (iOS doesn't prompt on write, so
// this scenario can't occur there.)
//
//   ./scripts/run_browserstack_android.sh --biometric \
//     --target integration_test/session_renewal_write_cancelled_test.dart --wait
void main() {
  e2eTest(
    'session renewal: cancelling the write prompt still keeps the user logged in',
    ($) async {
      requireCredentials();

      // No write prompt exists on iOS — nothing to assert there.
      if (!Platform.isAndroid) return;

      await bootLoginEnrolled($, enroll: BioResponse.pass);

      await tapForceSessionRenewal($);

      // Pass the read prompt (so /auth/renew runs and the new JWT is stored),
      // then cancel the write prompt.
      await respondToRenewal(
        $,
        readOutcome: BioResponse.pass,
        writeOutcome: BioResponse.cancel,
      );

      // Today's fix: the JWT was already persisted, so we stay logged in.
      await expectLoggedIn($);
    },
  );
}
