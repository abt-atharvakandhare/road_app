import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';

enum ChargeNowAnalyticsType {
  chargeFlowAppeared,
  findNearbyChargingStations,
  manualInputStationId,
  manualInputStationIdEntered,
  scanQrCode,
  scanQrCodeSuccess,
  scanQrCodeFailure,
  noNearbyStationFound,
  chargeStartRequestSentSuccess,
  chargeStartRequestSentError,
  chargeSessionStartFailed,
  chargeSessionStarted,
  chargeStopRequestSentSuccess,
  chargeStopRequestSentError,
  chargeSessionStopping,
  chargeSessionEnded,
  chargeCancelRequestSentSuccess,
  chargeCancelRequestSentError,
  chargeSessionCancelled;

  String get name {
    switch (this) {
      case ChargeNowAnalyticsType.chargeFlowAppeared:
        return 'charge_flow_appeared';
      case ChargeNowAnalyticsType.findNearbyChargingStations:
        return 'charge_find_nearby';
      case ChargeNowAnalyticsType.manualInputStationId:
        return 'charge_manual_input';
      case ChargeNowAnalyticsType.manualInputStationIdEntered:
        return 'charge_manual_input_entered';
      case ChargeNowAnalyticsType.scanQrCode:
        return 'charge_scan_qr_code';
      case ChargeNowAnalyticsType.scanQrCodeSuccess:
        return 'charge_scan_qr_code_success';
      case ChargeNowAnalyticsType.scanQrCodeFailure:
        return 'charge_scan_qr_code_failure';
      case ChargeNowAnalyticsType.noNearbyStationFound:
        return 'charge_no_nearby_station_found';
      case ChargeNowAnalyticsType.chargeStartRequestSentSuccess:
        return 'charge_start_request_sent_success';
      case ChargeNowAnalyticsType.chargeStartRequestSentError:
        return 'charge_start_request_sent_error';
      case ChargeNowAnalyticsType.chargeSessionStartFailed:
        return 'charge_session_start_failed';
      case ChargeNowAnalyticsType.chargeSessionStarted:
        return 'charge_session_started';
      case ChargeNowAnalyticsType.chargeStopRequestSentSuccess:
        return 'charge_stop_request_sent_success';
      case ChargeNowAnalyticsType.chargeStopRequestSentError:
        return 'charge_stop_request_sent_error';
      case ChargeNowAnalyticsType.chargeSessionStopping:
        return 'charge_session_stopping';
      case ChargeNowAnalyticsType.chargeSessionEnded:
        return 'charge_session_ended';
      case ChargeNowAnalyticsType.chargeCancelRequestSentSuccess:
        return 'charge_cancel_request_sent_success';
      case ChargeNowAnalyticsType.chargeCancelRequestSentError:
        return 'charge_cancel_request_sent_error';
      case ChargeNowAnalyticsType.chargeSessionCancelled:
        return 'charge_session_cancelled';
    }
  }
}

enum VerificationAnalyticsType {
  phoneCodeSent,
  phoneCodeResent,
  phoneVerificationSuccess,
  phoneVerificationFailure,
  phoneVerificationAbandoned,
  emailCodeSent,
  emailCodeResent,
  emailVerificationSuccess,
  emailVerificationFailure,
  emailVerificationAbandoned,
  ukPhoneExempted,
  rateLimitError,
  verificationApiError;

  String get name {
    switch (this) {
      case VerificationAnalyticsType.phoneCodeSent:
        return 'verification_phone_code_sent';
      case VerificationAnalyticsType.phoneCodeResent:
        return 'verification_phone_code_resent';
      case VerificationAnalyticsType.phoneVerificationSuccess:
        return 'verification_phone_success';
      case VerificationAnalyticsType.phoneVerificationFailure:
        return 'verification_phone_failure';
      case VerificationAnalyticsType.phoneVerificationAbandoned:
        return 'verification_phone_abandoned';
      case VerificationAnalyticsType.emailCodeSent:
        return 'verification_email_code_sent';
      case VerificationAnalyticsType.emailCodeResent:
        return 'verification_email_code_resent';
      case VerificationAnalyticsType.emailVerificationSuccess:
        return 'verification_email_success';
      case VerificationAnalyticsType.emailVerificationFailure:
        return 'verification_email_failure';
      case VerificationAnalyticsType.emailVerificationAbandoned:
        return 'verification_email_abandoned';
      case VerificationAnalyticsType.ukPhoneExempted:
        return 'verification_uk_phone_exempted';
      case VerificationAnalyticsType.rateLimitError:
        return 'verification_rate_limit_error';
      case VerificationAnalyticsType.verificationApiError:
        return 'verification_api_error';
    }
  }
}

enum PushNotificationAnalyticsType {
  foregroundReceived,
  foregroundShowFailed,
  backgroundHandlerRegistrationFailed,
  // Fires for every tap on a remote-push-triggered notification, regardless
  // of payload — parent event for measuring total tap rate. Live activity
  // taps are excluded (not a discrete push). tapOpenedUrl / tapOpenUrlFailed
  // remain as sub-events for the open_url action specifically.
  tapped,
  tapOpenedUrl,
  tapOpenUrlFailed;

  String get name {
    switch (this) {
      case PushNotificationAnalyticsType.foregroundReceived:
        return 'push_foreground_received';
      case PushNotificationAnalyticsType.foregroundShowFailed:
        return 'push_foreground_show_failed';
      case PushNotificationAnalyticsType.backgroundHandlerRegistrationFailed:
        return 'push_background_handler_registration_failed';
      case PushNotificationAnalyticsType.tapped:
        return 'push_tapped';
      case PushNotificationAnalyticsType.tapOpenedUrl:
        return 'push_tap_opened_url';
      case PushNotificationAnalyticsType.tapOpenUrlFailed:
        return 'push_tap_open_url_failed';
    }
  }
}

@injectable
class Analytics {
  // For testing
  void logNetworkCall({required String method, required String url, dynamic data, required int retries}) {
    Map<String, Object>? parameters = {
      'method': method,
      'url': url,
      'retries': retries,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      if (dataMap.length > 100) {
        dataMap = dataMap.substring(0, 100);
      }
      parameters['data'] = dataMap;
    }

    FirebaseAnalytics.instance.logEvent(name: "network_call", parameters: parameters);

    final crash = FirebaseCrashlytics.instance;
    String logString = 'API_CALL URL: $url retries: $retries, timestamp: ${DateTime.now().millisecondsSinceEpoch}';

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      logString += ', data: $dataMap';
    }

    // Network calls are normal operations, log as breadcrumb only
    crash.log(logString);

    log('### LOGGED NETWORK CALL ###');
  }

  void logNetworkError(
      {required String method,
      required String url,
      dynamic data,
      required int retries,
      int? statusCode,
      required String errorResponse}) {
    Map<String, Object>? parameters = {
      'method': method,
      'url': url,
      'retries': retries.toString(),
      'errorResponse': errorResponse,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      if (dataMap.length > 100) {
        dataMap = dataMap.substring(0, 100);
      }
      parameters['data'] = dataMap;
    }

    if (url == '/1/auth/login') {
      parameters['data'] = '***';
    }

    if (statusCode != null) {
      parameters['statusCode'] = statusCode;
    }

    FirebaseAnalytics.instance.logEvent(name: "network_error", parameters: parameters);

    final crash = FirebaseCrashlytics.instance;
    String logString =
        'API_ERROR URL: $method $url, retries: $retries, timestamp: ${DateTime.now().millisecondsSinceEpoch}, errorResponse: $errorResponse';

    if (statusCode != null) {
      logString += ', statusCode: $statusCode';
    }

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      logString += ', data: $dataMap';
    }

    // Determine if this is an expected network error vs an unexpected one
    bool isExpectedError = false;
    
    if (statusCode != null) {
      // Client errors and rate limiting are expected
      if (statusCode >= 400 && statusCode < 500) {
        isExpectedError = true;
      }
    }
    
    // Check for common network errors that aren't crashes
    final errorLower = errorResponse.toLowerCase();
    if (errorLower.contains('bad file descriptor') ||
        errorLower.contains('network') ||
        errorLower.contains('timeout') ||
        errorLower.contains('connection') ||
        errorLower.contains('socket') ||
        errorLower.contains('host lookup') ||
        errorLower.contains('no internet')) {
      isExpectedError = true;
    }
    
    if (isExpectedError) {
      // Log as breadcrumb only - these are normal network issues
      crash.log(logString);
      log('### LOGGED NETWORK ERROR AS BREADCRUMB ###');
    } else {
      // Server errors (5xx) or unexpected errors - record for investigation
      final exception = Exception(logString);
      crash.recordError(exception, null, printDetails: true, fatal: false);
      log('### LOGGED NETWORK ERROR AS NON-FATAL ###');
    }
  }

  void logMapDataLoadError({required int? responseCode, dynamic data, required String response}) {
    Map<String, Object>? parameters = {'timestamp': DateTime.now().millisecondsSinceEpoch, 'response': response};

    if (responseCode != null) {
      parameters['responseCode'] = responseCode;
    }

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      if (dataMap.length > 100) {
        dataMap = dataMap.substring(0, 100);
      }
      parameters['data'] = dataMap;
    }

    FirebaseAnalytics.instance.logEvent(name: "map_data_load_error", parameters: parameters);

    final crash = FirebaseCrashlytics.instance;
    String logString = 'MAP_API_CALL_ERROR timestamp: ${DateTime.now().millisecondsSinceEpoch}';

    if (data != null && (data is! FormData)) {
      String dataMap = json.encode(data);
      logString += ', data: $dataMap';
    }

    logString += ', response: $response';

    // Map data load errors are typically network or data issues, not crashes
    // Only record as error if it's a server error
    if (responseCode != null && responseCode >= 500) {
      final exception = Exception(logString);
      crash.recordError(exception, null, printDetails: true, fatal: false);
      log('### LOGGED MAP ERROR AS NON-FATAL ###');
    } else {
      // Client errors, network issues, or parsing errors - log as breadcrumb
      crash.log(logString);
      log('### LOGGED MAP ERROR AS BREADCRUMB ###');
    }
  }

  void logErrorDialogShown(String errorMessage) {
    if (errorMessage.length > 100) {
      errorMessage = errorMessage.substring(0, 100);
    }

    FirebaseAnalytics.instance.logEvent(
        name: "error_dialog_shown",
        parameters: {'errorMessage': errorMessage, 'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  void logErrorEvent(String name, String message) {
    if (message.length > 100) {
      message = message.substring(0, 100);
    }

    FirebaseAnalytics.instance
        .logEvent(name: name, parameters: {'message': message, 'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  void logChargeNowEvent(
    ChargeNowAnalyticsType eventType, {
    String? paymentType,
    String? locationId,
    String? evseUid,
    String? sessionId,
    String? connectorId,
    String? message,
  }) {
    Map<String, String> parameters = {};
    if (paymentType != null) {
      parameters['payment_type'] = paymentType;
    }
    if (locationId != null) {
      parameters['location_id'] = locationId;
    }
    if (evseUid != null) {
      parameters['evse_uid'] = evseUid;
    }
    if (sessionId != null) {
      parameters['session_id'] = sessionId;
    }
    if (message != null) {
      parameters['message'] = message;
    }
    if (connectorId != null) {
      parameters['connector_id'] = connectorId;
    }

    FirebaseAnalytics.instance.logEvent(name: eventType.name, parameters: parameters);
    log('LOGGING CHARGE EVENT: ${eventType.name}, parameters: $parameters');
  }

  void logQrCodeScanResult({
    required bool success,
    required String qrContent,
    String? extractedEvseId,
  }) {
    if (success) {
      // Log successful QR scan
      logChargeNowEvent(
        ChargeNowAnalyticsType.scanQrCodeSuccess,
        evseUid: extractedEvseId,
      );
    } else {
      // Log failed QR scan
      logChargeNowEvent(
        ChargeNowAnalyticsType.scanQrCodeFailure,
        message: qrContent.length > 100 ? qrContent.substring(0, 100) : qrContent,
      );
      
      // Also log detailed failure info for unsupported QR codes
      if (qrContent.startsWith('http://') || qrContent.startsWith('https://')) {
        final uri = Uri.tryParse(qrContent);
        if (uri != null) {
          final domain = uri.host;
          final path = uri.path.isEmpty ? '/' : uri.path;
          
          FirebaseAnalytics.instance.logEvent(
            name: 'unsupported_qr_prefix',
            parameters: {
              'domain': domain.length > 100 ? domain.substring(0, 100) : domain,
              'path': path.length > 100 ? path.substring(0, 100) : path,
              'full_url': qrContent.length > 200 ? qrContent.substring(0, 200) : qrContent,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          );
          log('LOGGING UNSUPPORTED QR: domain: $domain, path: $path');
        }
      } else {
        // Non-URL QR code
        FirebaseAnalytics.instance.logEvent(
          name: 'unsupported_qr_content',
          parameters: {
            'content_type': 'non_url',
            'content': qrContent.length > 200 ? qrContent.substring(0, 200) : qrContent,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
        log('LOGGING UNSUPPORTED QR: non-URL content');
      }
    }
  }
  
  // Keep deprecated method for backward compatibility
  @Deprecated('Use logQrCodeScanResult instead')
  void logUnsupportedQrPrefix(String qrContent) {
    logQrCodeScanResult(success: false, qrContent: qrContent);
  }

  void logPushNotificationEvent(
    PushNotificationAnalyticsType eventType, {
    String? title,
    String? errorMessage,
    String? url,
  }) {
    Map<String, Object> parameters = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (title != null) {
      parameters['title'] = title.length > 100 ? title.substring(0, 100) : title;
    }
    if (errorMessage != null) {
      parameters['error_message'] = errorMessage.length > 100 ? errorMessage.substring(0, 100) : errorMessage;
    }
    if (url != null) {
      parameters['url'] = url.length > 200 ? url.substring(0, 200) : url;
    }

    FirebaseAnalytics.instance.logEvent(name: eventType.name, parameters: parameters);
    log('LOGGING PUSH EVENT: ${eventType.name}, parameters: $parameters');
  }

  void logVerificationEvent(
    VerificationAnalyticsType eventType, {
    String? verificationType,
    String? context,
    String? errorMessage,
    String? statusCode,
    bool? isUkPhone,
    bool? isResend,
  }) {
    Map<String, Object> parameters = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (verificationType != null) {
      parameters['verification_type'] = verificationType;
    }
    if (context != null) {
      parameters['context'] = context; // 'signup' or 'profile'
    }
    if (errorMessage != null) {
      parameters['error_message'] = errorMessage.length > 100 ? errorMessage.substring(0, 100) : errorMessage;
    }
    if (statusCode != null) {
      parameters['status_code'] = statusCode;
    }
    if (isUkPhone != null) {
      parameters['is_uk_phone'] = isUkPhone;
    }
    if (isResend != null) {
      parameters['is_resend'] = isResend;
    }

    FirebaseAnalytics.instance.logEvent(name: eventType.name, parameters: parameters);
    log('LOGGING VERIFICATION EVENT: ${eventType.name}, parameters: $parameters');
  }

  void logVerificationError({
    required String action,
    required String errorMessage,
    String? verificationType,
    String? context,
    int? statusCode,
  }) {
    final crash = FirebaseCrashlytics.instance;
    String logString = 'VERIFICATION_ERROR action: $action, type: ${verificationType ?? 'unknown'}, '
        'context: ${context ?? 'unknown'}, timestamp: ${DateTime.now().millisecondsSinceEpoch}, '
        'error: $errorMessage';
    
    if (statusCode != null) {
      logString += ', statusCode: $statusCode';
    }
    
    // Determine if this is an expected error that should only be logged as a breadcrumb
    // vs an unexpected error that should be recorded as a non-fatal exception
    bool isExpectedError = false;
    
    if (statusCode != null) {
      // These are expected user/network errors, not crashes
      if (statusCode == 400 || // Bad request (invalid code)
          statusCode == 401 || // Unauthorized
          statusCode == 403 || // Forbidden
          statusCode == 404 || // Not found
          statusCode == 429) { // Rate limited
        isExpectedError = true;
      }
    }
    
    // Check for expected error messages
    if (errorMessage.toLowerCase().contains('invalid code') ||
        errorMessage.toLowerCase().contains('expired') ||
        errorMessage.toLowerCase().contains('rate limit') ||
        errorMessage.toLowerCase().contains('too many requests') ||
        errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('timeout')) {
      isExpectedError = true;
    }
    
    if (isExpectedError) {
      // Log as breadcrumb only - won't show as crash/error
      crash.log(logString);
      log('### LOGGED VERIFICATION AS BREADCRUMB ###');
    } else {
      // Unexpected error - record as non-fatal for investigation
      final exception = Exception(logString);
      crash.recordError(exception, null, printDetails: true, fatal: false);
      log('### LOGGED VERIFICATION ERROR AS NON-FATAL ###');
    }
  }
}
