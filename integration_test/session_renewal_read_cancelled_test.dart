
import '_helpers/biometric.dart';
import '_helpers/scenario.dart';
import '_helpers/session.dart';

// Cancelling the READ prompt aborts the renewal before any network call, so the
// user is not renewed and ends up logged out. Requires Device Cloud Pro.
//
//   ./scripts/run_browserstack_android.sh --biometric \
//     --target integration_test/session_renewal_read_cancelled_test.dart --wait
void main() {
  e2eTest(
    'session renewal: cancelling the read prompt logs the user out',
    ($) async {
      requireCredentials();

      // Skip locally: cancelling a REAL Face ID prompt isn't deterministic on a
      // physical device (staring at it passes the prompt). This path is driven on
      // BrowserStack via the injected dialog's CANCEL button — runs there
      // (BIOMETRIC_INJECTED_DIALOG defaults true), skips here when it's false.
      if (!expectInjectedBiometricDialog) {
        logSkip('read_cancelled needs the BrowserStack injected dialog to cancel deterministically');
        return;
      }

      await bootLoginEnrolled($, enroll: BioResponse.pass);

      await tapForceSessionRenewal($);

      // Cancel the read prompt → userCancelled → no /auth/renew → no write
      // prompt. The app falls through to the logged-out state.
      await respondToRenewal($, readOutcome: BioResponse.cancel);

      await expectLoggedOut($);
    },
  );
}
