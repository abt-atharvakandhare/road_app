import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/network/api_error.dart';
import 'package:road_mobile/services/network/app_check_token_provider.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/renew_outcome.dart';
import 'package:road_mobile/services/network/token_status_bus.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import '../analytics/analytics.dart';
import '../environment/environment.dart';
import 'interceptor.dart';

@lazySingleton
class ApiService {
  late String baseUrl;
  final Dio dio;
  late ApiServiceInterceptor interceptor;
  final Stage _stage;
  final Analytics? _analytics;
  final AuthStorage _authStorage;
  final TokenStatusBus _tokenStatusBus;
  final AuthLifecycleBus _lifecycleBus;
  final AppCheckTokenProvider _appCheckTokenProvider;

  // Held so it survives interceptor rebuilds in [setStageTarget]. Registered at
  // startup by main.dart (→ AuthSessionRenewer.tryRenew).
  Future<RenewOutcome> Function()? _recover;

  ApiService(this.dio, this._stage, this._analytics, this._authStorage, this._tokenStatusBus, this._lifecycleBus,
      this._appCheckTokenProvider)
      : interceptor = ApiServiceInterceptor(_stage.target, _authStorage, dio,
            tokenStatusBus: _tokenStatusBus, lifecycleBus: _lifecycleBus, appCheckTokenProvider: _appCheckTokenProvider) {
    setStageTarget(_stage.target);
  }

  Stage? get stage => _stage;

  /// Registers the recovery callback used by the interceptor to renew on a
  /// JWT-rejected 401. Persisted so it's re-applied across stage switches.
  void setRecover(Future<RenewOutcome> Function() recover) {
    _recover = recover;
    interceptor.setRecover(recover);
  }

  void setStageTarget(StageTarget target) {
    if (target == StageTarget.localdev) {
      baseUrl = 'http://localhost:2300';
    } else if (target == StageTarget.staging) {
      baseUrl = 'https://api.e-flux.dev';
    } else {
      baseUrl = 'https://api.e-flux.nl';
    }

    final existing = dio.interceptors.firstWhereOrNull((element) => element is ApiServiceInterceptor);
    if (existing != null) {
      dio.interceptors.remove(existing);
    }

    interceptor = ApiServiceInterceptor(target, _authStorage, dio,
        tokenStatusBus: _tokenStatusBus, lifecycleBus: _lifecycleBus, appCheckTokenProvider: _appCheckTokenProvider);
    interceptor.setRecover(_recover); // re-apply across stage switches

    dio.interceptors.add(interceptor);
  }

  Future<dynamic> get(String url,
      {Map<String, dynamic>? queryParameters,
      int retries = 2,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? extra}) async {
    try {
      final options = (headers != null || extra != null) ? Options(headers: headers, extra: extra) : null;
      final response = await dio.get(baseUrl + url, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      final apiError = e.apiError;
      if (apiError == null) {
        throw RMApiError(cause: '', defaultErrorMessage: true);
      } else if (apiError.isJwtRejected) {
        throw RMApiErrorJwtRejected(
            cause: apiError.message, expired: apiError.isJwtExpired, deviceRevoked: apiError.isDeviceRevoked);
      } else {
        final statusCode = e.response?.statusCode;
        _analytics?.logNetworkError(
            method: 'GET', url: url, retries: retries, statusCode: statusCode, errorResponse: apiError.message);

        if (retries > 0 && shouldRetryFor(statusCode: statusCode, apiError: apiError)) {
          await Future.delayed(const Duration(seconds: 2));
          return get(url, queryParameters: queryParameters, retries: retries - 1, headers: headers, extra: extra);
        } else {
          throw RMApiError(cause: apiError.message, details: apiError.details);
        }
      }
    } catch (e) {
      throw RMApiError(cause: 'Server error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String url,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      int retries = 2,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? extra}) async {
    try {
      final options = (headers != null || extra != null) ? Options(headers: headers, extra: extra) : null;
      final response = await dio.post(baseUrl + url, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      final apiError = e.apiError;
      if (apiError == null) {
        throw RMApiError(cause: '', defaultErrorMessage: true);
      } else if (apiError.isJwtRejected) {
        throw RMApiErrorJwtRejected(
            cause: apiError.message, expired: apiError.isJwtExpired, deviceRevoked: apiError.isDeviceRevoked);
      } else {
        final statusCode = e.response?.statusCode;

        _analytics?.logNetworkError(
            method: 'POST',
            url: url,
            data: data,
            retries: retries,
            statusCode: statusCode,
            errorResponse: apiError.message);

        if (retries > 0 && shouldRetryFor(statusCode: statusCode, apiError: apiError)) {
          await Future.delayed(const Duration(seconds: 2));
          return post(url,
              data: data, queryParameters: queryParameters, retries: retries - 1, headers: headers, extra: extra);
        } else {
          throw RMApiError(cause: apiError.message, details: apiError.details);
        }
      }
    } catch (e) {
      throw RMApiError(cause: 'Server error: ${e.toString()}');
    }
  }

  Future<dynamic> put(String url,
      {dynamic data, int retries = 2, Map<String, dynamic>? headers, Map<String, dynamic>? extra}) async {
    try {
      final options = (headers != null || extra != null) ? Options(headers: headers, extra: extra) : null;
      final response = await dio.put(baseUrl + url, data: data, options: options);
      return response;
    } on DioException catch (e) {
      final apiError = e.apiError;
      if (apiError == null) {
        throw RMApiError(cause: '', defaultErrorMessage: true);
      } else if (apiError.isJwtRejected) {
        throw RMApiErrorJwtRejected(
            cause: apiError.message, expired: apiError.isJwtExpired, deviceRevoked: apiError.isDeviceRevoked);
      } else {
        final statusCode = e.response?.statusCode;

        _analytics?.logNetworkError(
            method: 'PUT',
            url: url,
            data: data,
            retries: retries,
            statusCode: statusCode,
            errorResponse: apiError.message);

        if (retries > 0 && shouldRetryFor(statusCode: statusCode, apiError: apiError)) {
          await Future.delayed(const Duration(seconds: 2));
          return put(url, data: data, retries: retries - 1, headers: headers, extra: extra);
        } else {
          throw RMApiError(cause: apiError.message, details: apiError.details);
        }
      }
    } catch (e) {
      throw RMApiError(cause: 'Server error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String url,
      {dynamic data, int retries = 2, Map<String, dynamic>? headers, Map<String, dynamic>? extra}) async {
    try {
      final options = (headers != null || extra != null) ? Options(headers: headers, extra: extra) : null;
      final response = await dio.delete(baseUrl + url, data: data, options: options);
      return response;
    } on DioException catch (e) {
      final apiError = e.apiError;
      if (apiError == null) {
        throw RMApiError(cause: '', defaultErrorMessage: true);
      } else if (apiError.isJwtRejected) {
        throw RMApiErrorJwtRejected(
            cause: apiError.message, expired: apiError.isJwtExpired, deviceRevoked: apiError.isDeviceRevoked);
      } else {
        final statusCode = e.response?.statusCode;

        _analytics?.logNetworkError(
            method: 'DELETE',
            url: url,
            data: data,
            retries: retries,
            statusCode: statusCode,
            errorResponse: apiError.message);

        if (retries > 0 && shouldRetryFor(statusCode: statusCode, apiError: apiError)) {
          await Future.delayed(const Duration(seconds: 2));
          return delete(url, data: data, retries: retries - 1, headers: headers, extra: extra);
        } else {
          throw RMApiError(cause: apiError.message, details: apiError.details);
        }
      }
    } catch (e) {
      throw RMApiError(cause: 'Server error: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String url,
      {dynamic data, int retries = 2, Map<String, dynamic>? headers, Map<String, dynamic>? extra}) async {
    try {
      final options = (headers != null || extra != null) ? Options(headers: headers, extra: extra) : null;
      final response = await dio.patch(baseUrl + url, data: data, options: options);
      return response;
    } on DioException catch (e) {
      final apiError = e.apiError;
      if (apiError == null) {
        throw RMApiError(cause: '', defaultErrorMessage: true);
      } else if (apiError.isJwtRejected) {
        throw RMApiErrorJwtRejected(
            cause: apiError.message, expired: apiError.isJwtExpired, deviceRevoked: apiError.isDeviceRevoked);
      } else {
        final statusCode = e.response?.statusCode;

        _analytics?.logNetworkError(
            method: 'PATCH',
            url: url,
            data: data,
            retries: retries,
            statusCode: statusCode,
            errorResponse: apiError.message);

        if (retries > 0 && shouldRetryFor(statusCode: statusCode, apiError: apiError)) {
          await Future.delayed(const Duration(seconds: 2));
          return patch(url, data: data, retries: retries - 1, headers: headers, extra: extra);
        } else {
          throw RMApiError(cause: apiError.message, details: apiError.details);
        }
      }
    } catch (e) {
      throw RMApiError(cause: 'Server error: ${e.toString()}');
    }
  }

  bool shouldRetryFor({int? statusCode, ApiError? apiError}) {
    // A null response (and thus null status code) means we didn't get a response from the server. This seems
    // to usually be connection issues, so we retry.
    if (statusCode == null) {
      return true;
    }

    // Budget-aware 429s (the MFA rate limits) must reach the caller
    // immediately: they carry a running `retryAfterSeconds` countdown that a
    // blind retry can never outwait, and each replayed request spends more of
    // the same budget.
    final detail = apiError?.details?.firstOrNull;
    if (detail != null && (detail.retryAfterSeconds != null || detail.code?.startsWith('MFA_') == true)) {
      return false;
    }

    return statusCode == 429 || statusCode >= 500;
  }
}
