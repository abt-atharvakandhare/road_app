import 'dart:async';
import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/auth_refresh_response_model.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/single_flight.dart';
import 'package:road_mobile/services/network/token_status_bus.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart';

/// Drives the `X-Token-Status`-based lifecycle:
///
/// - `refresh` → debounced background `POST /1/auth/refresh`
/// - `ending` → emit a `SessionEnding` event for the UI
/// - on `/auth/refresh` 401 → hand off to the renewer registered via
///   [setRenewer]
///
/// The refresher does not directly construct the renewer to avoid a
/// construction cycle and to keep the biometric stack off this code path.
@lazySingleton
class AuthTokenRefresher {
  final AuthRepository _repository;
  final AuthStorage _storage;
  final TokenStatusBus _statusBus;
  final AuthLifecycleBus _lifecycleBus;

  StreamSubscription<String>? _busSub;
  final _refreshFlight = SingleFlight<void>();
  Future<bool> Function()? _tryRenew;

  AuthTokenRefresher(this._repository, this._storage, this._statusBus, this._lifecycleBus) {
    _busSub = _statusBus.stream.listen(_handleStatus);
  }

  /// Provided by the renewer at startup. Returns `true` if renewal succeeded
  /// and the user is now logged in with a fresh token.
  void setRenewer(Future<bool> Function() tryRenew) {
    _tryRenew = tryRenew;
  }

  void _handleStatus(String status) {
    switch (status) {
      case 'refresh':
        _scheduleRefresh();
      case 'ending':
        _lifecycleBus.publish(const SessionEnding());
    }
  }

  /// Triggers a refresh now (or returns the in-flight one).
  Future<void> _scheduleRefresh() => _refreshFlight.run(_runRefresh);

  Future<void> _runRefresh() async {
    try {
      final AuthRefreshResponseModel result = await _repository.refreshToken();
      await _storage.storeAuthToken(result.token);
      if (result.deviceToken != null) {
        await _storage.storeDeviceToken(result.deviceToken!);
      }
      _lifecycleBus.publish(TokenRotated(result.token));
    } catch (e) {
      log('Token refresh failed: $e');
      // Most likely a 401 from /auth/refresh — try silent renewal before
      // giving up. If renewal fails too, fall through; the next request will
      // hit the global 401 handler which logs the user out.
      final renew = _tryRenew;
      if (renew != null) {
        await renew();
      } else {
        // Should never fire in normal DI ordering — AuthSessionRenewer's
        // constructor wires itself in. Logged defensively so a future DI
        // refactor that breaks the wiring surfaces in dev logs rather than
        // silently disabling the renewal fallback.
        log('AuthTokenRefresher: renewer not registered; no renewal fallback after refresh failure');
      }
    }
  }

  @disposeMethod
  void dispose() {
    _busSub?.cancel();
  }
}
