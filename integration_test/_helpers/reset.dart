import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure-storage keys that together carry a reusable logged-in session:
/// the JWT + provider + device identity the network interceptor reads
/// (see AuthStorage), the renewal-token presence flag (SessionRenewalTokenStorage
/// — the token itself lives in biometric_storage, which this reset never
/// touches), and the e2e login stamp below.
const _sessionKeys = [
  AuthStorage.authTokenKey,
  AuthStorage.providerIdKey,
  AuthStorage.deviceTokenKey,
  SessionRenewalTokenStorage.presenceFlagKey,
  loginStampKey,
];

/// Written by `loginAsStagingUser` after a successful login (epoch millis).
/// Only a session younger than [_sessionMaxAge] is reused. Token *expiry* is
/// checked directly against the JWT's `exp` claim (see [_jwtOutlivesNextTest]);
/// this stamp additionally bounds server-side session-state drift that `exp`
/// can't capture (revocation, provider sessionTTL changes mid-run).
const loginStampKey = '_e2e_login_at';
const _sessionMaxAge = Duration(minutes: 30);

// Storage options mirroring AuthStorage/SessionRenewalTokenStorage, so the
// values written back land where the app reads them.
const _iOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
const _aOptions = AndroidOptions(resetOnError: true);

/// Clears persisted app state so a test starts from the same clean state on
/// every platform. Neither platform wipes package data between tests (Android
/// runs the orchestrator with `clearPackageData: "false"`; iOS has no
/// equivalent), so this is THE per-test isolation mechanism — but note it does
/// not touch biometric_storage (see `clearBiometricRenewalToken`) or non-pref
/// files.
///
/// [preserveSession] keeps the [_sessionKeys] across the wipe so the test can
/// reuse the previous test's login instead of burning another password attempt
/// (the API throttles login per-account; a poisoned counter locks the shared
/// staging account for up to an hour — see tasks/todo-e2e-session-reuse.md).
/// The session is only kept when it's plausible AND fresh: JWT present,
/// renewal-token flag set (bootLoginEnrolled promises an enrolled session),
/// and logged in less than [_sessionMaxAge] ago. Anything less → full wipe,
/// and the caller's normal login path re-establishes everything.
///
/// Must run BEFORE `app.main()`, which reads this state during DI setup —
/// that's also why the keep-or-wipe decision lives here and not after boot:
/// deciding pre-launch means the app always boots directly into the intended
/// state and never needs a second `app.main()`.
Future<void> resetAppState({bool preserveSession = false}) async {
  const storage = FlutterSecureStorage();
  final prefs = await SharedPreferences.getInstance();

  // A logged-in boot needs BOTH halves: the secure-storage tokens AND the
  // accountDetails SharedPreferences blob — moveToInitialAppState treats a
  // token without the blob as logged out. Round-trip the blob through the
  // model's own (de)serialization so new fields never silently go missing.
  final kept = <String, String>{};
  AccountDetailsModel? keptAccount;
  if (preserveSession) {
    for (final key in _sessionKeys) {
      final value = await storage.read(key: key, iOptions: _iOptions, aOptions: _aOptions);
      if (value != null) kept[key] = value;
    }
    keptAccount = AccountDetailsModel.fromSharedPrefs(prefs);
    if (keptAccount == null || !_isReusable(kept)) {
      kept.clear();
      keptAccount = null;
    }
  }

  await storage.deleteAll();
  for (final entry in kept.entries) {
    await storage.write(
      key: entry.key,
      value: entry.value,
      iOptions: _iOptions,
      aOptions: _aOptions,
    );
  }

  await prefs.clear();
  keptAccount?.saveToSharedPrefs(prefs);
}

/// Records "this session just satisfied MFA" (epoch millis under
/// [loginStampKey]): a real login, or a step-up verify on the reused session.
/// Arms session reuse for subsequent tests and lets the step-up tests judge
/// how stale the session is (see `awaitStepUpStale`). Written via the same
/// options as the preserved keys so [resetAppState] reads it back reliably.
Future<void> stampSessionLogin() async {
  await const FlutterSecureStorage().write(
    key: loginStampKey,
    value: DateTime.now().millisecondsSinceEpoch.toString(),
    iOptions: _iOptions,
    aOptions: _aOptions,
  );
}

bool _isReusable(Map<String, String> session) {
  final jwt = session[AuthStorage.authTokenKey];
  if (jwt == null || !_jwtOutlivesNextTest(jwt)) return false;
  if (session[SessionRenewalTokenStorage.presenceFlagKey] != 'true') return false;
  final stampMillis = int.tryParse(session[loginStampKey] ?? '');
  if (stampMillis == null) return false;
  final age = DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(stampMillis));
  return age >= Duration.zero && age < _sessionMaxAge;
}

/// True when the JWT's `exp` claim is comfortably beyond one test's runtime.
/// `moveToInitialAppState` trusts a stored token without validating it, so an
/// expired (or about-to-expire) JWT would boot "logged in" and then hit a
/// 401 → biometric renewal prompt mid-test that nothing answers. The margin
/// covers a test's full duration; a token that can't be parsed or lacks `exp`
/// is treated as not reusable (falls back to a real login).
bool _jwtOutlivesNextTest(String jwt) {
  const margin = Duration(minutes: 5);
  try {
    final payload = jwt.split('.')[1];
    final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))));
    final expSeconds = claims['exp'];
    if (expSeconds is! int) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
    return expiry.isAfter(DateTime.now().add(margin));
  } catch (_) {
    return false;
  }
}

/// Seeds the debug-controls prefs so the app boots straight onto the staging
/// backend, skipping the debug-controls UI dance (`switchToStaging`).
///
/// We write [DebugControlsRepo]'s pref keys directly because DI — and the
/// repo — don't exist before `app.main()`. They're `persist:`-prefixed so the
/// app's own logout-wipe leaves them intact.
///
/// `DebugControlsRepo` reads these in its constructor during DI setup, and
/// `Stage` then adopts the staging target — so the very first `ApiService` call
/// already points at staging. Call after [resetAppState] (which wipes prefs)
/// and before `app.main()`.
Future<void> seedStagingPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(DebugControlsRepo.debugControlsEnabledKey, true);
  await prefs.setString(DebugControlsRepo.debugStageTargetKey, StageTarget.staging.name);
  if (_providerSlugOverride.isNotEmpty) {
    await prefs.setString(DebugControlsRepo.debugProviderSlugKey, _providerSlugOverride);
  }
}

/// Provider slug seeded alongside the stage target when
/// `--dart-define=E2E_PROVIDER_SLUG=…` is set. Staging only hosts a subset of
/// the white-label provider slugs, so WL-flavor runs pass `e-flux` here to log
/// in against a provider that exists there. Unset = the flavor's own slug.
const _providerSlugOverride = String.fromEnvironment('E2E_PROVIDER_SLUG');

/// When the current session last satisfied MFA per [stampSessionLogin], or
/// null if no stamp survived (fresh install, reuse rejected).
Future<DateTime?> sessionMfaStamp() async {
  final raw = await const FlutterSecureStorage().read(key: loginStampKey, iOptions: _iOptions, aOptions: _aOptions);
  final millis = int.tryParse(raw ?? '');
  return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
}
