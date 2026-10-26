import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:road_mobile/data/model/charging/current_charging_values_model.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';

/// Result from starting or updating an iOS live activity.
class LiveActivityResult {
  final LiveActivityStatus status;
  final String? activityId;
  final String? pushToken;
  final String? error;

  LiveActivityResult({
    required this.status,
    this.activityId,
    this.pushToken,
    this.error,
  });

  factory LiveActivityResult.fromMap(Map<dynamic, dynamic> map) {
    final statusString = map['status'] as String?;
    final status = switch (statusString) {
      'started' => LiveActivityStatus.started,
      'updated' => LiveActivityStatus.updated,
      'ended' => LiveActivityStatus.ended,
      'error' => LiveActivityStatus.error,
      _ => LiveActivityStatus.error,
    };

    return LiveActivityResult(
      status: status,
      activityId: map['activityId'] as String?,
      pushToken: map['pushToken'] as String?,
      error: map['error'] as String?,
    );
  }

  factory LiveActivityResult.disabled() => LiveActivityResult(status: LiveActivityStatus.disabled);

  factory LiveActivityResult.androidNotSupported() => LiveActivityResult(status: LiveActivityStatus.androidNotSupported);

  bool get isNewActivity => status == LiveActivityStatus.started;
  bool get needsRegistration => isNewActivity && pushToken != null;
}

enum LiveActivityStatus {
  started,
  updated,
  ended,
  error,
  disabled,
  androidNotSupported,
}

class LiveActivityDispatcher {
  final MethodChannel? _liveActivityChannel;
  final MethodChannel? _androidChargingServiceChannel;

  LiveActivityDispatcher()
      : _liveActivityChannel =
            Platform.isIOS ? const MethodChannel('io.e-flux.mobile/liveActivity') : null,
        _androidChargingServiceChannel =
            Platform.isAndroid ? const MethodChannel('io.e-flux.mobile/chargingService') : null;

  /// Flavor-driven branding passed through to the native side so the widget / notification
  /// can render the correct logo, name, and deep link on every white-label.
  Map<String, String> _brandingArgs() => {
        'brandName': F.appBrandName,
        'brandImageName': '${F.name}60',
        'deepLinkScheme': F.providerName,
      };

  /// Shows or updates a live activity with the current charging values.
  /// Returns a [LiveActivityResult] with the activity ID and push token if a new activity was started.
  Future<LiveActivityResult> showLiveActivity(
    CurrentChargingValues currentChargingValues, {
    required String activeSessionId,
    required bool liveUpdateNotificationsEnabled,
    String currency = 'EUR',
    String? locationName,
  }) async {
    if (kDebugMode) {
      log('┌─────────────────────────────────────────────────────────────');
      log('│ 📱 LIVE ACTIVITY UPDATE');
      log('├─────────────────────────────────────────────────────────────');
      log('│ State of Charge: ${currentChargingValues.stateOfCharge}%');
      log('│ Energy: ${currentChargingValues.energy} Wh (${currentChargingValues.energy / 1000} kWh)');
      log('│ Cost: ${currentChargingValues.costCurrentTotal} cents');
      log('│ Currency: $currency');
      log('│ Session Started: ${currentChargingValues.sessionStartedAt}');
      log('│ Enabled: ${Defines.liveActivitiesEnabled}');
      log('└─────────────────────────────────────────────────────────────');
    }

    if (!Defines.liveActivitiesEnabled) {
      log('LiveActivityDispatcher: Live activities disabled, skipping');
      return LiveActivityResult.disabled();
    }

    // Gate on the user's `charging.session.live_update` topic subscription. The BE
    // honours this for iOS pushes and we mirror it locally so the Android FGS doesn't
    // start either. Empty/false means the user has opted out.
    if (!liveUpdateNotificationsEnabled) {
      log('LiveActivityDispatcher: live update topic not enabled, skipping');
      return LiveActivityResult.disabled();
    }

    // Belt and braces: if the OS-level permission was revoked we still won't show
    // anything. (The topic subscription should already be off in that case, but
    // permission state can change out-of-band via system settings.)
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final authorised = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!authorised) {
      log('LiveActivityDispatcher: notifications not authorised (${settings.authorizationStatus.name}), skipping');
      return LiveActivityResult.disabled();
    }

    if (Platform.isIOS) {
      try {
        final arguments = {
          ...currentChargingValues.toDictionary(),
          ..._brandingArgs(),
          'currency': currency,
          'activeSessionId': activeSessionId,
          if (locationName != null && locationName.isNotEmpty) 'locationName': locationName,
        };
        log('LiveActivityDispatcher: Sending to iOS: $arguments');
        final result = await _liveActivityChannel?.invokeMethod('showLiveActivity', arguments);

        if (result is Map) {
          final liveActivityResult = LiveActivityResult.fromMap(result);
          if (kDebugMode) {
            log('┌─────────────────────────────────────────────────────────────');
            log('│ ✅ LIVE ACTIVITY RESULT');
            log('├─────────────────────────────────────────────────────────────');
            log('│ Status: ${liveActivityResult.status.name}');
            log('│ Activity ID: ${liveActivityResult.activityId}');
            log('│ Push Token: ${liveActivityResult.pushToken != null ? '${liveActivityResult.pushToken!.substring(0, 20)}...' : 'null'}');
            log('│ Error: ${liveActivityResult.error}');
            log('└─────────────────────────────────────────────────────────────');
          }
          return liveActivityResult;
        }

        return LiveActivityResult(
          status: LiveActivityStatus.error,
          error: 'Unexpected response: $result',
        );
      } on PlatformException catch (e) {
        log('LiveActivityDispatcher: Platform exception: ${e.message}');
        return LiveActivityResult(
          status: LiveActivityStatus.error,
          error: e.message,
        );
      } on MissingPluginException {
        log('LiveActivityDispatcher: No native live activity handler registered, skipping show');
        return LiveActivityResult.disabled();
      }
    } else if (Platform.isAndroid) {
      try {
        final arguments = {
          ...currentChargingValues.toDictionary(),
          ..._brandingArgs(),
          'currency': currency,
          'activeSessionId': activeSessionId,
          if (locationName != null && locationName.isNotEmpty) 'locationName': locationName,
        };
        log('LiveActivityDispatcher: Sending to Android service: $arguments');
        await _androidChargingServiceChannel?.invokeMethod('showLiveActivity', arguments);
      } on PlatformException catch (e) {
        log('LiveActivityDispatcher: Android service exception: ${e.message}');
      } on MissingPluginException {
        log('LiveActivityDispatcher: No native charging service handler registered, skipping show');
      }
      return LiveActivityResult.androidNotSupported();
    }

    return LiveActivityResult(status: LiveActivityStatus.error, error: 'Unsupported platform');
  }

  Future<void> endLiveActivity() async {
    if (!Defines.liveActivitiesEnabled) {
      return;
    }

    if (Platform.isIOS) {
      try {
        await _liveActivityChannel?.invokeMethod('endLiveActivity');
        log('LiveActivityDispatcher: Activity ended');
      } on PlatformException catch (e) {
        log('LiveActivityDispatcher: Failed to end activity: ${e.message}');
      } on MissingPluginException {
        log('LiveActivityDispatcher: No native live activity handler registered, skipping end');
      }
    } else if (Platform.isAndroid) {
      try {
        await _androidChargingServiceChannel?.invokeMethod('endLiveActivity');
        log('LiveActivityDispatcher: Android charging service stopped');
      } on PlatformException catch (e) {
        log('LiveActivityDispatcher: Failed to stop Android service: ${e.message}');
      } on MissingPluginException {
        log('LiveActivityDispatcher: No native charging service handler registered, skipping stop');
      }
    }
  }
}
