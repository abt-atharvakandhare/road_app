
import '_helpers/biometric.dart';
import '_helpers/scenario.dart';
import '_helpers/session.dart';

// Headline happy path: a biometric session renewal succeeds and the user stays
// logged in. Requires BrowserStack Device Cloud Pro (`--biometric`).
//
//   ./scripts/run_browserstack_android.sh --biometric \
//     --target integration_test/session_renewal_success_test.dart --wait
void main() {
  e2eTest(
    'session renewal: biometric pass keeps the user logged in',
    ($) async {
      requireCredentials();

      await bootLoginEnrolled($, enroll: BioResponse.pass);

      // Force a renewal (deletes JWT → moveToInitialAppState → silent renew).
      await tapForceSessionRenewal($);

      // Android: read prompt (PASS) then write prompt (PASS). iOS: read only.
      await respondToRenewal($, readOutcome: BioResponse.pass);

      // Still logged in — the renewal succeeded, no fall-through to login.
      await expectLoggedIn($);
    },
  );
}
