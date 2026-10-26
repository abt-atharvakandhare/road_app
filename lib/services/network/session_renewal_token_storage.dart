import 'dart:ui';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

/// Persists the biometric-gated session renewal token.
///
/// The token sits in a `biometric_storage` file with
/// `authenticationRequired: true` — every read triggers the OS biometric
/// prompt. A separate non-secret flag in [FlutterSecureStorage] lets us answer
/// "is one stored?" without prompting the user.
@lazySingleton
class SessionRenewalTokenStorage {
  /// Public (not private) because the e2e suite deletes this biometric_storage
  /// file directly to reset enrollment (integration_test/_helpers/biometric.dart)
  /// — importing it keeps a rename from silently breaking the tests.
  static const renewalFileName = 'session_renewal_token';

  /// Public for the same reason: the e2e suite preserves this key across its
  /// per-test state reset to reuse a logged-in session
  /// (integration_test/_helpers/reset.dart).
  static const presenceFlagKey = '_session_renewal_token_present';
  static const _iOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  static const _aOptions = AndroidOptions(resetOnError: true);

  final FlutterSecureStorage _flagStorage;
  final BiometricStorage _biometricStorage;
  // Cached as a `Future` (not a resolved value) so two concurrent callers
  // share the same `getStorage` invocation rather than racing on `??=`.
  Future<BiometricStorageFile>? _filePromise;

  AppLocalizations? _localizations;

  SessionRenewalTokenStorage(this._flagStorage, this._biometricStorage);

  /// Pushed from the widget bridge in `app.dart` (this service has no
  /// BuildContext). [_l10n] falls back to `lookupAppLocalizations` if the
  /// bridge hasn't run yet — that path loses Phrase OTA but is fine for
  /// boot-time strings.
  void updateLocalizations(AppLocalizations l10n) {
    _localizations = l10n;
  }

  AppLocalizations get _l10n {
    if (_localizations != null) return _localizations!;
    final locale = PlatformDispatcher.instance.locale;
    if (AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return lookupAppLocalizations(locale);
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  /// True when biometrics are available *and* a renewal token has been
  /// stored. Use this at app start before deciding whether to attempt silent
  /// renewal.
  Future<bool> isAvailable() async {
    final flag = await _flagStorage.read(key: presenceFlagKey, iOptions: _iOptions);
    if (flag != 'true') return false;
    final auth = await _biometricStorage.canAuthenticate();
    return auth == CanAuthenticateResponse.success;
  }

  /// Whether the device can store the renewal token at all (used at login
  /// time to decide whether to set `requestDeviceRefresh: true`).
  Future<bool> canStore() async {
    return await _biometricStorage.canAuthenticate() == CanAuthenticateResponse.success;
  }

  /// Reads the renewal token; triggers the OS biometric prompt.
  ///
  /// Throws [AuthException] on biometric cancel/failure. Returns `null` if
  /// no token has been stored.
  Future<String?> read({String? promptReason}) async {
    final file = await _openFile();
    return file.read(promptInfo: _promptInfo(promptReason ?? _l10n.biometricPromptReason));
  }

  Future<void> store(String token, {String? promptReason}) async {
    final file = await _openFile();
    // PromptInfo is required on Android — the Keystore key has
    // setUserAuthenticationRequired(true), so even writes need a recent
    // biometric auth, which the BiometricPrompt provides. iOS ignores
    // promptInfo on writes (SecItemAdd creates the keychain item with the
    // ACL attached; the prompt only fires on subsequent reads).
    await file.write(token, promptInfo: _promptInfo(promptReason ?? _l10n.biometricPromptReason));
    await _flagStorage.write(key: presenceFlagKey, value: 'true', iOptions: _iOptions, aOptions: _aOptions);
  }

  Future<void> clear() async {
    await _flagStorage.delete(key: presenceFlagKey, iOptions: _iOptions);
    // Always open and delete the underlying file, even if we haven't touched
    // it this session — otherwise a logout in a session that never read or
    // wrote leaves an orphaned biometric-protected keychain entry. iOS
    // keychain items survive reinstall by default, so the orphan could
    // outlive the app install.
    try {
      final file = await _openFile();
      await file.delete();
    } on AuthException {
      // Device biometrics may have been disabled or removed since the
      // entry was created. Presence flag is already cleared, which is
      // what callers rely on.
    } catch (_) {
      // Plugin-level failures (e.g. keychain access denied) — best-effort.
    }
  }

  Future<BiometricStorageFile> _openFile() {
    // `authenticationValidityDurationSeconds` defaults to -1, which is what
    // we want: Android binds a fresh cipher to each BiometricPrompt rather
    // than caching auth for N seconds. A non-negative value here would tell
    // the plugin to skip the cipher-binding path; writes then fail with
    // IllegalBlockSizeException ("Key user not authenticated") because the
    // plugin's auth fallback only catches UserNotAuthenticatedException,
    // not the keystore-level variant. iOS ignores this field — it uses
    // keychain ACLs (.biometryCurrentSet) rather than cipher binding.
    return _filePromise ??= _biometricStorage.getStorage(
      renewalFileName,
      options: StorageFileInitOptions(authenticationRequired: true),
    );
  }

  PromptInfo _promptInfo(String? reason) => PromptInfo(
        androidPromptInfo: reason != null
            ? AndroidPromptInfo(title: reason)
            : AndroidPromptInfo.defaultValues,
        iosPromptInfo: reason != null
            ? IosPromptInfo(accessTitle: reason, saveTitle: reason)
            : IosPromptInfo.defaultValues,
      );
}
