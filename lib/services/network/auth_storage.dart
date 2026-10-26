import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// A single cached secure-storage value. [loaded] distinguishes "not yet read"
/// from "read and found absent" (null is a valid stored value).
class _Cached {
  String? value;
  bool loaded = false;
}

@lazySingleton
class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage(this._storage);

  /// Public (not private) because the e2e suite preserves these keys across
  /// its per-test state reset to reuse a logged-in session
  /// (integration_test/_helpers/reset.dart) — importing them keeps a rename
  /// from silently breaking the tests.
  static const authTokenKey = '_auth_token';
  static const providerIdKey = '_provider_id';
  static const deviceTokenKey = '_device_token';

  static const _iOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  static const _aOptions = AndroidOptions(resetOnError: true);

  // The interceptor reads these three on every request. AuthStorage is the
  // only gateway that reads or writes these keys, so an in-memory cache stays
  // authoritative for the app's lifetime and spares the keychain/Keystore a
  // read per request. Writes and deletes update the cache in lock-step.
  final _authToken = _Cached();
  final _providerId = _Cached();
  final _deviceToken = _Cached();

  Future<String?> _read(String key, _Cached cache) async {
    if (cache.loaded) return cache.value;
    cache.value = await _storage.read(key: key, iOptions: _iOptions);
    cache.loaded = true;
    return cache.value;
  }

  Future<void> _write(String key, String? value, _Cached cache) async {
    await _storage.write(key: key, value: value, iOptions: _iOptions, aOptions: _aOptions);
    cache.value = value;
    cache.loaded = true;
  }

  Future<void> _delete(String key, _Cached cache) async {
    await _storage.delete(key: key, iOptions: _iOptions);
    cache.value = null;
    cache.loaded = true;
  }

  Future<String?> readAuthToken() => _read(authTokenKey, _authToken);

  Future<String?> readProviderId() => _read(providerIdKey, _providerId);

  Future<void> storeAuthToken(String? token) => _write(authTokenKey, token, _authToken);

  Future<void> storeProviderId(String? providerId) => _write(providerIdKey, providerId, _providerId);

  Future<void> deleteAuthToken() => _delete(authTokenKey, _authToken);

  Future<String?> readFcmToken() async {
    return await _storage.read(key: '_fcm_token', iOptions: _iOptions);
  }

  Future<void> storeFcmToken(String token) async {
    await _storage.write(key: '_fcm_token', value: token, iOptions: _iOptions, aOptions: _aOptions);
  }

  Future<void> deleteFcmToken() async {
    await _storage.delete(key: '_fcm_token', iOptions: _iOptions);
  }

  /// Opaque device identity issued by the API. Sent as the `X-Device-Id`
  /// header on every request; persists across logins. Only cleared when the
  /// device itself is revoked (`DEVICE_NOT_FOUND` from renewal) or the user
  /// reinstalls the app.
  Future<String?> readDeviceToken() => _read(deviceTokenKey, _deviceToken);

  Future<void> storeDeviceToken(String token) => _write(deviceTokenKey, token, _deviceToken);

  Future<void> deleteDeviceToken() => _delete(deviceTokenKey, _deviceToken);
}
