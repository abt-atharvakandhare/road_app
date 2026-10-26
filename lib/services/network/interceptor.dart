import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../environment/environment.dart';
import 'api_error.dart';
import 'app_check_token_provider.dart';
import 'auth_lifecycle_bus.dart';
import 'auth_storage.dart';
import 'renew_outcome.dart';
import 'token_status_bus.dart';

class DioLogger {
  static List<String> collectedLogs = [];
  static List<String> errorLogs = [];
  static bool collectLogs = false;
  static bool isLogOn = false;

  static void onSuccess(Response response) {
    if (DioLogger.isLogOn) {
      _printResponse(response);
    }
  }

  static void onError(DioException error) {
    if (DioLogger.isLogOn) {
      log('### ON ERROR ###');
      if (null != error.response) {
        _printResponse(error.response!);
      } else {
        log('Error without response: $error ');
      }
    }
  }

  static void _printResponse(Response response) async {
    String curlRequest = 'curl ';

    for (final header in response.requestOptions.headers.keys) {
      curlRequest += '-H "$header: ${response.requestOptions.headers[header]}" ';
    }

    String queryParameters = '';
    if (response.requestOptions.method == 'GET') {
      bool firstItem = true;
      for (final queryParam in response.requestOptions.queryParameters.keys) {
        queryParameters += '${firstItem ? '?' : '&'}$queryParam=${response.requestOptions.queryParameters[queryParam]}';
        firstItem = false;
      }
    }

    curlRequest += '-X ${response.requestOptions.method} "${response.requestOptions.path}$queryParameters" ';
    if (response.requestOptions.data != null && (response.requestOptions.data is! FormData)) {
      final dataMap = json.encode(response.requestOptions.data);
      final escapedDatamap = dataMap.replaceAll('"', '\\"');
      curlRequest += '-d "$escapedDatamap"';
    }

    log('Request: $curlRequest');

    if (response.requestOptions.data != null) {
      log('RequestBody: ${response.requestOptions.data.toString()} \n');
    }

    final responseData = response.data.toString();

    log('Response: ${responseData.substring(0, math.min(responseData.length, 1000))} \n');

    if (collectLogs) {
      collectedLogs.add(curlRequest);
      collectedLogs.add(response.data.toString());
    }

    if ((response.statusCode ?? 0) >= 400) {
      errorLogs.add(curlRequest);
      errorLogs.add(response.data.toString());
    }
  }
}

// enum AuthenticationType {
//   bearer('Bearer '),
//   basic('Basic anonymous:bSHV1L2qtj');

//   final String value;

//   const AuthenticationType(this.value);
// }

/// Marks a retried request so a second 401 on the same request doesn't loop
/// back into recovery — it falls through to logout instead.
const _retriedFlag = '__sessionRetried';

/// A plain [Interceptor], NOT a [QueuedInterceptor]: the recovery path retries
/// the original request via `dio.fetch` from inside [onError], and a queued
/// error pipeline would deadlock if that retry 401s again (the retry's onError
/// would queue behind the onError still awaiting it). A plain interceptor runs
/// onError concurrently; "renew once" is guaranteed by the renewer's own
/// single-flight, not by queue serialization.
class ApiServiceInterceptor extends Interceptor {
  final AuthStorage storage;
  final Dio dio;
  final TokenStatusBus? tokenStatusBus;
  final AuthLifecycleBus? lifecycleBus;
  /// Nullable here, non-nullable in [ApiService]: tests construct the
  /// interceptor bare, while DI-wired production code always supplies one.
  final AppCheckTokenProvider? appCheckTokenProvider;
  StreamController<ApiError>? errorStream;

  /// Renews the session (→ `AuthSessionRenewer.tryRenew`, single-flight).
  /// Registered post-construction to avoid a network↔auth construction cycle
  /// and to keep the biometric stack out of this layer (we hold a function,
  /// not the renewer).
  Future<RenewOutcome> Function()? _recover;

  ApiServiceInterceptor(
    StageTarget stageTarget,
    this.storage,
    this.dio, {
    this.tokenStatusBus,
    this.lifecycleBus,
    this.appCheckTokenProvider,
    this.errorStream,
  }) : super() {
    if (stageTarget != StageTarget.production || kDebugMode) {
      DioLogger.isLogOn = true;
    }
  }

  // Nullable: `ApiService.setStageTarget` rebuilds the interceptor and
  // re-applies the stored callback, which is legitimately null before
  // `main()` registers it at startup (recovery is simply inert until then).
  // The public `ApiService.setRecover` entry point is non-nullable.
  void setRecover(Future<RenewOutcome> Function()? recover) => _recover = recover;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll({
      'Referer': 'https://dashboard.e-flux.dev/',
    });

    String? token;
    String? providerId;
    String? deviceToken;
    try {
      final results = await Future.wait<String?>([
        storage.readAuthToken().catchError((_) => null),
        storage.readProviderId().catchError((_) => null),
        storage.readDeviceToken().catchError((_) => null),
      ]);
      token = results[0];
      providerId = results[1];
      deviceToken = results[2];
    } catch (_) {
      // Swallow — individual reads already fall back to null above.
    }

    // Yield to a caller-provided Authorization header — /auth/renew sets
    // its own with the renewal token rather than the user JWT.
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (deviceToken != null) {
      options.headers['X-Device-Id'] = deviceToken;
    }

    // Send the provider ID to all endpoints except the provider endpoint
    if (providerId != null && !options.path.contains('/1/providers/public/')) {
      options.headers['Provider'] = providerId;
    }

    if (appCheckTokenProvider != null && _attestedPaths.contains(options.uri.path)) {
      // Best-effort: on any App Check failure the request proceeds without the
      // header — the backend's attestation mode decides what happens then.
      try {
        final appCheckToken =
            await appCheckTokenProvider!.getLimitedUseToken().timeout(_appCheckTimeout);
        if (appCheckToken != null) {
          options.headers['X-Firebase-AppCheck'] = appCheckToken;
        }
      } catch (e) {
        log('Failed to obtain App Check token: $e');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    DioLogger.onSuccess(response);
    _publishTokenStatus(response.requestOptions, response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    DioLogger.onError(err);
    if (err.response != null) {
      _publishTokenStatus(err.requestOptions, err.response!.headers);
    }

    final options = err.requestOptions;
    final apiError = err.apiError;
    final recover = _recover;

    // Only JWT-rejected 401s on non-auth endpoints are recoverable.
    // /auth/renew and /auth/refresh are handled by their own flows; recovering
    // them here would loop.
    final recoverable =
        recover != null && apiError != null && apiError.isJwtRejected && !_isAuthEndpoint(options.path);
    if (!recoverable) {
      handler.next(err);
      return;
    }

    // Retried once and still rejected → genuinely unrecoverable. Log out.
    if (options.extra[_retriedFlag] == true) {
      lifecycleBus?.publish(SessionRevoked(expired: apiError.isJwtExpired));
      handler.next(err);
      return;
    }

    // If the token already rotated since this request was sent — a concurrent
    // request already renewed — skip renewal (no second biometric prompt) and
    // go straight to retry.
    final sentToken = _bearerOf(options);
    final currentToken = await storage.readAuthToken().catchError((_) => null);
    final alreadyRotated = currentToken != null && currentToken != sentToken;

    final RenewOutcome outcome;
    try {
      outcome = alreadyRotated ? RenewOutcome.renewed : await recover();
    } catch (e) {
      // recover() must never leave a request hanging. Any unexpected throw
      // (e.g. a biometric/keychain platform error the renewer didn't map)
      // is treated as an unrecoverable session: log out and surface the
      // original error so the request completes instead of stalling forever.
      lifecycleBus?.publish(SessionRevoked(expired: apiError.isJwtExpired));
      handler.next(err);
      return;
    }

    switch (outcome) {
      case RenewOutcome.renewed:
        try {
          handler.resolve(await _retry(options));
        } catch (e) {
          handler.next(e is DioException ? e : err);
        }
      case RenewOutcome.transientError:
        // Network blip — keep the session, surface the error to the caller.
        handler.next(err);
      case RenewOutcome.notAvailable:
      case RenewOutcome.userCancelled:
      case RenewOutcome.rejected:
        lifecycleBus?.publish(SessionRevoked(expired: apiError.isJwtExpired));
        handler.next(err);
    }
  }

  /// Re-sends the original request with a fresh token. Clears the stale
  /// `Authorization` header so [onRequest] re-adds the new one (its
  /// `!containsKey` guard would otherwise keep the rejected token), and marks
  /// the request so a repeat 401 can't loop back into recovery.
  Future<Response<dynamic>> _retry(RequestOptions options) {
    options.headers.remove('Authorization');
    options.extra[_retriedFlag] = true;
    return dio.fetch(options);
  }

  /// The endpoints guarded by device attestation. Matched on the exact URI
  /// path so query strings can't widen or dodge the match. Mirrors the
  /// backend's guarded set (its trusted-client middleware); drift is visible
  /// in the backend's attestation monitor logs as mobile traffic with
  /// `missing` tokens on a guarded path.
  static const _attestedPaths = {
    '/1/auth/login',
    '/1/auth/request-password',
    '/1/signup',
  };

  /// Generous enough for cold-start attestation (first launch, slow network).
  /// Timing out only drops the header, but once the backend enforces, giving
  /// up early turns a slow-but-successful attestation into a rejected login.
  static const _appCheckTimeout = Duration(seconds: 8);

  // Auth endpoints own their own token flows (renew/refresh/login), so a 401
  // there must NOT trigger reactive recovery — that would loop. `contains` over
  // the `/1/auth/` namespace rather than `endsWith` on each path: precise to
  // our API and unaffected by any trailing query string.
  static bool _isAuthEndpoint(String path) => path.contains('/1/auth/');

  static String? _bearerOf(RequestOptions options) {
    final auth = options.headers['Authorization'];
    return (auth is String && auth.startsWith('Bearer ')) ? auth.substring('Bearer '.length) : null;
  }

  void _publishTokenStatus(RequestOptions options, Headers headers) {
    if (tokenStatusBus == null) return;
    // /auth/refresh and /auth/renew update the token out-of-band. Publishing
    // their X-Token-Status would cause a refresh loop — the refresher would
    // see "refresh" on its own refresh response and fire again.
    if (options.path.endsWith('/auth/refresh') || options.path.endsWith('/auth/renew')) return;
    final status = headers.value('x-token-status');
    if (status == null || status == 'ok') return;
    tokenStatusBus!.publish(status);
  }
}
