import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import 'api_error_details.dart';

part 'api_error.g.dart';

extension DioErrorExtension on DioException {
  ApiError? get apiError {
    if (response?.data != null) {
      if (response!.data is Map) {
        final providedError = response!.data?['error'];
        return ApiError.fromJson(providedError);
      } else {
        return ApiError(message: response!.data);
      }
    }

    if (error != null) {
      return ApiError(message: error.toString());
    }

    return null;
  }
}

@JsonSerializable()
class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final int? status;
  final bool defaultErrorMessage;
  final List<ErrorDetails>? details;
  ApiError({required this.message, this.statusCode, this.status, this.defaultErrorMessage = false, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  /// True when a 401 response carries a token/session error code, indicating
  /// the JWT the client sent is no longer acceptable. A 401 with no code
  /// (or a non-token code, e.g. login `INVALID_CREDENTIALS`) is NOT
  /// classified here — those need to surface as normal errors to the caller.
  ///
  /// Code names match the BE Mobile Authentication Guide. The codes after
  /// `FORCE_LOGOUT` only come back from `/auth/renew` but are classified
  /// here so the renewer can branch on [isDeviceRevoked].
  bool get isJwtRejected =>
      status == 401 &&
      switch (details?.firstOrNull?.code) {
        'NO_TOKEN' ||
        'INVALID_KEY' ||
        'INVALID_SIGNATURE' ||
        'TOKEN_EXPIRED' ||
        'TOKEN_NOT_ALLOWED' ||
        'SESSION_REVOKED' ||
        'SESSION_EXPIRED' ||
        'SUBJECT_NOT_FOUND' ||
        'CREDENTIAL_DISABLED' ||
        'TOKEN_INVALIDATED' ||
        'FORCE_LOGOUT' ||
        'DEVICE_NOT_FOUND' ||
        'SESSION_RENEWAL_TOKEN_REVOKED' ||
        'ACTION_TOKEN_REVOKED' ||
        'ACTION_TOKEN_EXPIRED' =>
          true,
        _ => false,
      };

  /// True when the 401 specifically means "session/token has aged out", as
  /// opposed to other forms of rejection (revoked, signature bad, user
  /// deleted). Drives the "Session expired" notice on the login screen.
  bool get isJwtExpired =>
      status == 401 &&
      switch (details?.firstOrNull?.code) {
        'TOKEN_EXPIRED' || 'SESSION_EXPIRED' || 'ACTION_TOKEN_EXPIRED' => true,
        _ => false,
      };

  /// True when a 401 specifically signals the device has been revoked
  /// server-side. Only surfaces from `/auth/renew`; tells the renewer to
  /// also clear the stored `deviceToken`.
  bool get isDeviceRevoked =>
      status == 401 && details?.firstOrNull?.code == 'DEVICE_NOT_FOUND';
}

@JsonSerializable()
class ApiErrorDTO {
  final String responseDetail;
  final int? responseCode;
  final bool? success;
  ApiErrorDTO({required this.responseDetail, this.responseCode, this.success});

  factory ApiErrorDTO.fromJson(Map<String, dynamic> json) => _$ApiErrorDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorDTOToJson(this);
}
