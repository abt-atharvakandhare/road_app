
import '_helpers/biometric.dart';
import '_helpers/scenario.dart';
import '_helpers/session.dart';

// Organic 401 → silent renewal: invalidating the JWT makes the next
// authenticated request 401, which the network INTERCEPTOR recovers from by
// renewing (biometric) and transparently retrying the request — the user never
// sees a logout. The reactive-401 redesign moved recovery into the interceptor
// (in-zone, retry-on-success), so unlike the old PlatformDispatcher path this
// is now reachable under Patrol. Requires Device Cloud Pro.
//
// Trigger: background→foreground fires AuthCubit._refreshAccountDetails(), which
// hits several authed endpoints at once — a reliable way to provoke the 401s
// (opening a screen was flaky; some screens don't fetch on open). The
// concurrent 401s collapse to a single renewal via the renewer's single-flight.
//
//   ./scripts/run_browserstack_android.sh --biometric \
//     --target integration_test/invalidate_jwt_renews_test.dart --wait
void main() {
  e2eTest(
    'invalidate JWT: organic 401 silently renews and stays logged in',
    ($) async {
      requireCredentials();

      await bootLoginEnrolled($, enroll: BioResponse.pass);

      await tapInvalidateJwt($);
      // Let the fire-and-forget token write land before we trigger a fetch.
      // (Plain pump, not pumpAndSettle — the screen may animate forever.)
      await $.pump(const Duration(seconds: 1));

      // Background → foreground → _refreshAccountDetails() → authed 401s.
      await $.native2.pressHome();
      await Future<void>.delayed(const Duration(seconds: 2));
      await $.native2.openApp();

      // Android: read + write prompts; iOS: read only.
      await respondToRenewal($, readOutcome: BioResponse.pass);

      await expectLoggedIn($);
    },
  );
}
