import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/app_links/cubit/app_links_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

const _channelId = 'charging_updates';
const _channelName = 'Charging Updates';
const _notificationIcon = '@mipmap/notification_icon';
const _largeIcon = '@mipmap/launcher_icon';

// Push-data action keys. Backend sends e.g. {action: "open_url", url: "https://..."}
// or {action: "open_charging"} for active-session pushes, or
// {action: "open_wallet_sessions"} for the `charging.session.ended` push (lands on
// the wallet's Sessions list instead of the now-empty charging status screen).
const _dataKeyAction = 'action';
const _dataKeyUrl = 'url';
const _actionOpenUrl = 'open_url';
const _actionOpenCharging = 'open_charging';
const _actionOpenWalletSessions = 'open_wallet_sessions';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

enum NotificationChannelIds {
  localNotifications,
  liveActivity,
}

@injectable
class IncomingNotificationHandler {
  void initializeNotificationHandler() {
    const initializationSettingsAndroid = AndroidInitializationSettings(_notificationIcon);
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestProvisionalPermission: false,
      requestCriticalPermission: false,
    );

    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      // Fires when the user taps a notification we displayed via this plugin
      // (Android foreground path). Two sources land here:
      //  - Local notifications mirrored from a foreground FCM push (id =
      //    localNotifications) — payload is the JSON-encoded FCM data map.
      //  - The Android local "live activity" notification (id = liveActivity)
      //    — no payload; tap should open the charging status screen.
      onDidReceiveNotificationResponse: (response) {
        if (response.id == NotificationChannelIds.liveActivity.index) {
          getIt<AppLinksCubit>().requestOpenCharging();
          return;
        }
        getIt<Analytics>().logPushNotificationEvent(PushNotificationAnalyticsType.tapped);
        _handleNotificationData(_decodePayload(response.payload));
      },
    );

    // On Android, foreground notifications must be shown manually via flutter_local_notifications.
    // Background/terminated notifications are auto-displayed by FCM.
    if (Platform.isAndroid) {
      const androidPlatformChannelSpecifics = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
      );

      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      androidPlugin?.createNotificationChannel(androidPlatformChannelSpecifics);
      // Clean up legacy channel from previous versions.
      androidPlugin?.deleteNotificationChannel(channelId: '0');

      final androidLiveActivityChannel = AndroidNotificationChannel(
        '${NotificationChannelIds.liveActivity.index}',
        'Live Activity',
        importance: Importance.max,
      );
      androidPlugin?.createNotificationChannel(androidLiveActivityChannel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (await _handleIntercomPush(message)) return;
        final title = _titleFrom(message);
        final body = _bodyFrom(message);
        getIt<Analytics>().logPushNotificationEvent(PushNotificationAnalyticsType.foregroundReceived, title: title);
        try {
          _showLocalNotification(title, body, message.data);
        } catch (e) {
          getIt<Analytics>().logPushNotificationEvent(PushNotificationAnalyticsType.foregroundShowFailed, title: title, errorMessage: e.toString());
        }
      });

      try {
        FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
      } catch (e) {
        log('Failed to register onBackgroundMessage: $e');
        getIt<Analytics>().logPushNotificationEvent(PushNotificationAnalyticsType.backgroundHandlerRegistrationFailed, errorMessage: e.toString());
      }
    }

    // Tap on a push that opened the app from background (both platforms).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    // Tap on a push that launched the app from terminated state (both platforms).
    // On Android, FirebaseMessaging.getInitialMessage() intermittently returns
    // null on cold-starts because the background isolate consumes the message
    // before the main isolate can read it. When that happens we read the FCM
    // data extras directly off the launching Intent via LaunchIntentProcessor
    // as a defensive fallback. Fire-and-forget — internal paths are guarded.
    unawaited(_resolveColdStartTap());

    // Show notifications on iOS when app is in the foreground.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS Live Activity tap: SceneDelegate receives the widgetURL and invokes
    // `onLiveActivityTapped` on this channel. Listening unconditionally is
    // safe — Android never sends to this channel.
    if (Platform.isIOS) {
      const liveActivityChannel = MethodChannel('io.e-flux.mobile/liveActivity');
      liveActivityChannel.setMethodCallHandler((call) async {
        if (call.method == 'onLiveActivityTapped') {
          getIt<AppLinksCubit>().requestOpenCharging();
        }
      });
    }
  }

  static void showLocalLiveActivity() async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        '${NotificationChannelIds.liveActivity.index}',
        'Live Activity',
        largeIcon: DrawableResourceAndroidBitmap(_largeIcon),
        playSound: false,
        enableVibration: false,
        channelShowBadge: false,
        showProgress: true,
        silent: true,
        ongoing: true,
        maxProgress: 100,
        progress: 50,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
        presentBadge: false,
        presentBanner: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
        id: NotificationChannelIds.liveActivity.index,
        title: 'Charging in progress',
        body: 'Tap to open the app',
        notificationDetails: notificationDetails);
  }

  static void endLocalLiveActivity() async {
    await flutterLocalNotificationsPlugin.cancel(id: NotificationChannelIds.liveActivity.index);
  }
}

const _launchIntentChannel = MethodChannel('io.e-flux.mobile/launchIntent');
const _googleMessageIdKey = 'google.message_id';

/// Resolves the push (if any) that launched the app from terminated state.
///   1. [FirebaseMessaging.getInitialMessage] — the standard FCM path.
///   2. The launching Intent's FCM extras via [LaunchIntentProcessor] — a
///      defensive fallback for the rare case where (1) returns null but the
///      tap intent still carries the FCM payload.
Future<void> _resolveColdStartTap() async {
  final message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    await _handleNotificationOpened(message);
    return;
  }
  if (!Platform.isAndroid) return;

  final fcmIntentData = await _readLaunchIntentFcmData();
  if (fcmIntentData == null || fcmIntentData.isEmpty) return;
  final id = fcmIntentData[_googleMessageIdKey] as String?;
  if (!claimMessageId(_handledMessageIds, id)) return;
  getIt<Analytics>().logPushNotificationEvent(
    PushNotificationAnalyticsType.tapped,
    title: fcmIntentData['title'] as String?,
  );
  await _handleNotificationData(fcmIntentData);
}

Future<Map<String, dynamic>?> _readLaunchIntentFcmData() async {
  try {
    final result = await _launchIntentChannel.invokeMethod<Map<dynamic, dynamic>>('getFcmExtras');
    return result?.cast<String, dynamic>();
  } catch (e) {
    log('Failed to read launch intent FCM extras: $e');
    return null;
  }
}

Future<bool> _handleIntercomPush(RemoteMessage message) async {
  if (!Defines.intercomEnabled || !F.useIntercomForHelp) return false;

  if (await Intercom.instance.isIntercomPush(message.data)) {
    await Intercom.instance.handlePush(message.data);
    return true;
  }
  return false;
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Intercom pushes should not be shown as local notifications — the Intercom SDK
  // handles display natively. We can't call Intercom.instance here (background isolate),
  // so we check the message data directly.
  if (_isIntercomMessage(message.data)) return;

  // Legacy notification+data payloads: FCM auto-displays the notification when
  // the app is in background/terminated, so showing our own would duplicate it.
  // Data-only payloads (new shape) skip FCM's auto-display and rely on us.
  if (message.notification != null) return;

  _showLocalNotification(_titleFrom(message), _bodyFrom(message), message.data);
}

/// Push title — prefers the `notification` block (legacy + iOS), falls back to
/// `data.title` for data-only Android payloads.
String _titleFrom(RemoteMessage message) =>
    message.notification?.title ?? (message.data['title'] as String?) ?? '';

/// Push body — see [_titleFrom] for source preference.
String _bodyFrom(RemoteMessage message) =>
    message.notification?.body ?? (message.data['body'] as String?) ?? '';

bool _isIntercomMessage(Map<String, dynamic> data) {
  return data.containsKey('intercom_push_type');
}

/// Encodes a tap-time action payload from the FCM data block. We only keep the
/// keys the tap handler dispatches on so we don't accidentally round-trip
/// sensitive backend fields through SharedPreferences (flutter_local_notifications
/// persists tap payloads on Android).
String? _encodeTapPayload(Map<String, dynamic> data) {
  final action = data[_dataKeyAction];
  if (action is! String) return null;
  final url = data[_dataKeyUrl];
  return jsonEncode({
    _dataKeyAction: action,
    if (url is String) _dataKeyUrl: url,
  });
}

Map<String, dynamic> _decodePayload(String? payload) {
  if (payload == null || payload.isEmpty) return const {};
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : const {};
  } catch (_) {
    return const {};
  }
}

void _showLocalNotification(String title, String body, Map<String, dynamic> data) {
  // Safety: never post a blank notification. Some FCM data-only messages arrive with no
  // notification block (e.g. payloads aimed at the app rather than the user); rendering
  // them as empty banners is just visual spam.
  if (title.isEmpty && body.isEmpty) {
    log('Skipping local notification — both title and body are empty.');
    return;
  }
  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      icon: _notificationIcon,
      largeIcon: DrawableResourceAndroidBitmap(_largeIcon),
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentBanner: true,
    ),
  );
  flutterLocalNotificationsPlugin.show(
      id: NotificationChannelIds.localNotifications.index,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: _encodeTapPayload(data));
}

/// IDs of messages we've already dispatched in this isolate. `firebase_messaging`
/// on Android fires both [FirebaseMessaging.getInitialMessage] and
/// [FirebaseMessaging.onMessageOpenedApp] for the same cold-start tap, which
/// would otherwise call `launchUrl` twice (the second call queues while we
/// background, then fires when the user returns to the app).
final _handledMessageIds = <String>{};

/// Tries to mark [id] as handled in [handled]. Returns `true` if the caller
/// should proceed with dispatch — either the id is fresh, or it's null (no
/// identifier means dedup isn't possible, so we err on the side of acting).
/// Returns `false` for duplicates the caller should skip.
@visibleForTesting
bool claimMessageId(Set<String> handled, String? id) {
  if (id == null) return true;
  return handled.add(id);
}

/// Dispatches a push the user just tapped: lets Intercom claim it first, then
/// runs our own data-action handling (currently just open_url).
Future<void> _handleNotificationOpened(RemoteMessage message) async {
  if (!claimMessageId(_handledMessageIds, message.messageId)) return;
  getIt<Analytics>().logPushNotificationEvent(
    PushNotificationAnalyticsType.tapped,
    title: message.notification?.title,
  );
  if (await _handleIntercomPush(message)) return;
  await _handleNotificationData(message.data);
}

/// Acts on a push payload's `data` block. Today the only supported action is
/// `open_url`, which launches the URL in the system browser.
///
/// Trust model: we currently send these directly from the Firebase console and
/// have no per-topic opt-out — every user with notifications enabled receives
/// the message. When the marketing topic ships, gate this on the topic and
/// add a backend allowlist on the URL.
Future<void> _handleNotificationData(Map<String, dynamic> data) async {
  switch (data[_dataKeyAction]) {
    case _actionOpenUrl:
      await _openExternalUrl(_urlFromData(data));
    case _actionOpenCharging:
      getIt<AppLinksCubit>().requestOpenCharging();
    case _actionOpenWalletSessions:
      getIt<AppLinksCubit>().requestOpenSessions();
  }
}

String? _urlFromData(Map<String, dynamic> data) {
  final url = data[_dataKeyUrl];
  return url is String ? url : null;
}

Future<void> _openExternalUrl(String? urlString) async {
  if (urlString == null || urlString.isEmpty) return;

  final uri = Uri.tryParse(urlString);
  // Silently ignore non-URL payloads — e.g. legacy/empty payloads from notifications
  // that aren't open_url actions.
  if (uri == null || !uri.hasScheme) return;

  if (uri.scheme != 'https') {
    getIt<Analytics>().logPushNotificationEvent(
      PushNotificationAnalyticsType.tapOpenUrlFailed,
      url: urlString,
      errorMessage: 'unsupported scheme: ${uri.scheme}',
    );
    return;
  }

  // launchUrl can throw a PlatformException — for example, on Android configurations
  // with no app registered to handle the URL.
  bool launched;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    getIt<Analytics>().logPushNotificationEvent(
      PushNotificationAnalyticsType.tapOpenUrlFailed,
      url: uri.toString(),
      errorMessage: 'launchUrl threw: $e',
    );
    return;
  }

  getIt<Analytics>().logPushNotificationEvent(
    launched ? PushNotificationAnalyticsType.tapOpenedUrl : PushNotificationAnalyticsType.tapOpenUrlFailed,
    url: uri.toString(),
    errorMessage: launched ? null : 'launchUrl returned false',
  );
}
