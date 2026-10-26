
import '_helpers/app_launch.dart';
import '_helpers/auth.dart';
import '_helpers/biometric.dart';
import '_helpers/nav.dart';
import '_helpers/scenario.dart';
import '_helpers/session.dart';

// From-scratch enrollment: with no prior renewal token, logging in fires the
// biometric enrollment (write) prompt. Passing it must actually store a usable
// renewal token — proven by forcing a renewal afterwards and seeing it succeed.
// Requires Device Cloud Pro.
//
//   ./scripts/run_browserstack_android.sh --biometric \
//     --target integration_test/login_enrollment_test.dart --wait
void main() {
  e2eTest(
    'login enrollment: passing the prompt stores a usable renewal token',
    ($) async {
      requireCredentials();

      await bootApp($);

      // Guarantee a clean slate: resetAppState() (in bootApp) clears secure
      // storage + prefs but NOT the biometric keystore entry, so wipe any
      // lingering renewal token from a prior run.
      await clearBiometricRenewalToken();

      await tapTab($, AppTab.account);

      // Log in, passing the enrollment prompt → renewal token should be stored.
      await loginAsStagingUser($, testEmail, testPassword, enroll: BioResponse.pass);
      await expectLoggedIn($);

      // Prove the token was really stored: a forced renewal should find it and
      // succeed (rather than fall through to login for lack of a token).
      await tapForceSessionRenewal($);
      await respondToRenewal($, readOutcome: BioResponse.pass);
      await expectLoggedIn($);
    },
  );
}
