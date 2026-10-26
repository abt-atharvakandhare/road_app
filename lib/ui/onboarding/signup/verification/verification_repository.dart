import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/cards/verify_and_store_response_model.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/network/api_error.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:sms_autofill/sms_autofill.dart';

enum VerificationType {
  email('email'),
  mobile('mobile');

  final String value;
  const VerificationType(this.value);
}

@injectable
class VerificationRepository {
  final ApiService _apiService;
  final Analytics _analytics;

  VerificationRepository(this._apiService, this._analytics);

  /// Send verification code to user's email or phone
  /// @param type - The type of verification (email or mobile)
  /// @param platform - 'mobile' for mobile app (only used for email)
  /// @param smsConstraint - Optional SMS constraint for mobile verification
  /// @param userId - Optional user ID (used in profile email verification)
  /// @param journey - Optional journey parameter (used in profile email verification)
  /// @return true if successful, false otherwise
  Future<bool> sendVerificationCode(
    VerificationType type, {
    String platform = 'mobile',
    String? smsConstraint,
    String? userId,
    String? journey,
    bool isResend = false,
    String? context,
  }) async {
    try {
      final body = <String, dynamic>{};

      // For mobile verification on Android, get SMS constraint for auto-detection
      if (type == VerificationType.mobile && Platform.isAndroid) {
        try {
          final signature = await SmsAutoFill().getAppSignature;
          body['smsConstraint'] = signature;
        } catch (e) {
          // If getting signature fails, continue without it
          // This ensures backward compatibility
        }
      } else if (smsConstraint != null) {
        // Use provided smsConstraint if explicitly passed
        body['smsConstraint'] = smsConstraint;
      }

      // Add email-specific parameters
      if (type == VerificationType.email) {
        body['platform'] = platform;
        if (userId != null) {
          body['userId'] = userId;
        }
        if (journey != null) {
          body['journey'] = journey;
        }
      }

      final result = await _apiService.post(
        '/1/users/me/verification/${type.value}',
        data: body,
        retries: 0, // Skip retries for rate-limited verification endpoints
      );

      final response = SimpleSuccessResponseModel.fromJson(result.data);

      // Log successful code send
      if (response.data.success) {
        if (isResend) {
          _analytics.logVerificationEvent(
            type == VerificationType.email
                ? VerificationAnalyticsType.emailCodeResent
                : VerificationAnalyticsType.phoneCodeResent,
            verificationType: type.value,
            context: context,
          );
        } else {
          _analytics.logVerificationEvent(
            type == VerificationType.email
                ? VerificationAnalyticsType.emailCodeSent
                : VerificationAnalyticsType.phoneCodeSent,
            verificationType: type.value,
            context: context,
          );
        }
      }

      return response.data.success;
    } on ApiError catch (e) {
      // Check for rate limiting error
      if (e.statusCode == 429 || (e.message.toLowerCase().contains('rate'))) {
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.rateLimitError,
          verificationType: type.value,
          errorMessage: e.message,
          statusCode: e.statusCode?.toString(),
          context: context,
        );
      } else {
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.verificationApiError,
          verificationType: type.value,
          errorMessage: e.message,
          statusCode: e.statusCode?.toString(),
          context: context,
        );
      }

      // Log to Crashlytics
      _analytics.logVerificationError(
        action: isResend ? 'resend_code' : 'send_code',
        errorMessage: e.message,
        verificationType: type.value,
        context: context,
        statusCode: e.statusCode,
      );

      rethrow;
    } catch (e) {
      _analytics.logVerificationEvent(
        VerificationAnalyticsType.verificationApiError,
        verificationType: type.value,
        errorMessage: e.toString(),
        context: context,
      );

      _analytics.logVerificationError(
        action: isResend ? 'resend_code' : 'send_code',
        errorMessage: e.toString(),
        verificationType: type.value,
        context: context,
      );

      rethrow;
    }
  }

  /// Confirm verification code
  /// @param code - 6-digit verification code
  /// @param type - The type of verification (email or mobile)
  /// @param context - Optional context ('signup' or 'profile')
  /// @return true if successful, false otherwise
  Future<bool> confirmVerificationCode(
    String code,
    VerificationType type, {
    String? context,
  }) async {
    try {
      final endpoint = type == VerificationType.email
          ? '/1/users/me/verification/email/confirm'
          : '/1/users/me/verification/mobile/confirm';

      final result = await _apiService.post(
        endpoint,
        data: {'code': code},
      );

      final response = SimpleSuccessResponseModel.fromJson(result.data);

      // Analytics is logged by the calling cubit (SignupCubit or AuthCubit)
      // since they know the success/failure context better

      return response.data.success;
    } on ApiError catch (e) {
      // Log API error
      _analytics.logVerificationEvent(
        VerificationAnalyticsType.verificationApiError,
        verificationType: type.value,
        errorMessage: e.message,
        statusCode: e.statusCode?.toString(),
        context: context,
      );

      _analytics.logVerificationError(
        action: 'confirm_code',
        errorMessage: e.message,
        verificationType: type.value,
        context: context,
        statusCode: e.statusCode,
      );

      rethrow;
    } catch (e) {
      _analytics.logVerificationEvent(
        VerificationAnalyticsType.verificationApiError,
        verificationType: type.value,
        errorMessage: e.toString(),
        context: context,
      );

      _analytics.logVerificationError(
        action: 'confirm_code',
        errorMessage: e.toString(),
        verificationType: type.value,
        context: context,
      );

      rethrow;
    }
  }

  // Note: getPendingVerifications has been removed to avoid redundant API calls.
  // Verification status is now determined from AccountDetailsModel which is
  // already fetched during login. See SignupCubit._calculatePendingVerifications()
}
