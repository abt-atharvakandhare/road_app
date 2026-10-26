import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:injectable/injectable.dart';

/// Supplies Firebase App Check limited-use attestation tokens for the guarded
/// auth endpoints. Limited-use tokens are short-lived, never cached, and
/// eligible for server-side replay protection. Returns null when no token is
/// available.
abstract class AppCheckTokenProvider {
  Future<String?> getLimitedUseToken();
}

@LazySingleton(as: AppCheckTokenProvider)
class FirebaseAppCheckTokenProvider implements AppCheckTokenProvider {
  /// The backend records each token's `jti` and rejects replays, so every
  /// guarded call (login, signup, password reset) must present a fresh token —
  /// limited-use tokens guarantee this: the SDK never serves them from cache.
  @override
  Future<String?> getLimitedUseToken() =>
      FirebaseAppCheck.instance.getLimitedUseToken();
}
