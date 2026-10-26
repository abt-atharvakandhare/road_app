import 'dart:async';
import 'dart:developer';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/auth_renew_response_model.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/auth_token_refresher.dart';
import 'package:road_mobile/services/network/renew_outcome.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/services/network/single_flight.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

// Re-exported so existing importers (main.dart, AuthCubit) keep getting
// RenewOutcome from here; the enum itself lives in renew_outcome.dart to avoid
// an import cycle with the network interceptor.
export 'package:road_mobile/services/network/renew_outcome.dart';

/// Drives the biometric-gated `POST /1/auth/renew` flow.
///
/// Consulted in three places:
///
/// 1. App start: if no user token but a renewal token is stored,
///    [tryRenew] before showing the login screen.
/// 2. `/auth/refresh` returns 401: the refresher asks the renewer to try a
///    silent renewal before giving up.
/// 3. Global error handler: when any API call returns a JWT-rejected 401,
///    the handler can call [tryRenew] before dispatching the logout.
@lazySingleton
class AuthSessionRenewer {
  final AuthRepository _repository;
  final AuthStorage _authStorage;
  final SessionRenewalTokenStorage _renewalStorage;
  final AuthLifecycleBus _lifecycleBus;

  final _singleFlight = SingleFlight<RenewOutcome>();

  AuthSessionRenewer(
    this._repository,
    this._authStorage,
    this._renewalStorage,
    this._lifecycleBus,
    AuthTokenRefresher refresher,
  ) {
    refresher.setRenewer(() async {
      final outcome = await tryRenew();
      return outcome == RenewOutcome.renewed;
    });
  }

  /// Attempts a silent renewal. Single-flight: concurrent callers share the
  /// same outcome. The first caller's [promptReason] wins for the shared run.
  Future<RenewOutcome> tryRenew({String? promptReason}) {
    return _singleFlight.run(() => _run(promptReason));
  }

  Future<RenewOutcome> _run(String? promptReason) async {
    if (!await _renewalStorage.isAvailable()) {
      return RenewOutcome.notAvailable;
    }

    final String? renewalToken;
    try {
      renewalToken = await _renewalStorage.read(promptReason: promptReason);
    } on AuthException catch (e) {
      log('Biometric prompt cancelled or failed: ${e.code}');
      return RenewOutcome.userCancelled;
    } catch (e) {
      // Other biometric/keychain failures that aren't surfaced as AuthException
      // — notably iOS Face ID permission DENIED, which throws a
      // PlatformException(SecurityError, -25293), plus lockouts and other
      // platform-channel errors. We can't read the token, so renewal isn't
      // possible: fall through to login. Critically, never let this escape —
      // it would propagate out of the interceptor and hang the request.
      // userCancelled (not rejected) so we don't wipe a still-valid token over
      // a transient permission state.
      log('Biometric read failed (non-AuthException): $e');
      return RenewOutcome.userCancelled;
    }

    if (renewalToken == null) {
      await _renewalStorage.clear();
      return RenewOutcome.notAvailable;
    }

    final AuthRenewResponseModel result;
    try {
      result = await _repository.renewSession(renewalToken);
    } on RMApiErrorJwtRejected catch (e) {
      // The renewal token itself was rejected (revoked/expired/device gone).
      // Clear it and fall through to login.
      await _renewalStorage.clear();
      if (e.deviceRevoked) {
        await _authStorage.deleteDeviceToken();
      }
      return RenewOutcome.rejected;
    } catch (e) {
      // Transient: no connectivity, timeout, 5xx, etc. The renewal token is
      // still valid server-side, so keep it — don't punish a flaky connection
      // with a forced logout.
      log('Session renewal failed with transient error: $e');
      return RenewOutcome.transientError;
    }

    // Network renewal succeeded, so the renewal token we just sent is now
    // consumed server-side and `result.sessionRenewalToken` is its rotated
    // replacement. Persist the new user token first — that alone makes the
    // session live.
    await _authStorage.storeAuthToken(result.token);

    // Storing the rotated renewal token triggers a biometric *write* prompt on
    // Android (the Keystore key requires fresh auth per op). If that write
    // fails — e.g. the user cancels this second prompt — the session is still
    // live (the JWT is stored), so we must NOT report failure and log them
    // out. But the old renewal token is already consumed and the new one
    // didn't persist, so silent renewal can't work again until the next full
    // login: clear the presence flag so we don't retry a dead token.
    try {
      await _renewalStorage.store(result.sessionRenewalToken);
    } catch (e, st) {
      log('Renewed session but failed to store rotated renewal token: $e', error: e, stackTrace: st);
      await _renewalStorage.clear();
    }

    _lifecycleBus.publish(SessionRenewed(result.token));
    return RenewOutcome.renewed;
  }
}
