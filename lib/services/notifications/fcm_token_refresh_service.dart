import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_repo.dart';

@lazySingleton
class FcmTokenRefreshService {
  final NotificationsRepo _notificationsRepo;
  final AuthStorage _authStorage;

  StreamSubscription<String>? _tokenRefreshSubscription;

  FcmTokenRefreshService(this._notificationsRepo, this._authStorage);

  void startListening() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(onTokenRefresh);
  }

  void stopListening() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  @visibleForTesting
  Future<void> onTokenRefresh(String newToken) async {
    try {
      final oldToken = await _authStorage.readFcmToken();

      if (oldToken == null || oldToken == newToken) {
        // First time or token hasn't actually changed — stored by finally block.
        return;
      }

      // 1. Fetch the old subscription's topics.
      List<String> oldTopics = [];
      try {
        final oldSettings = await _notificationsRepo.getNotificationSettings(oldToken);
        oldTopics = oldSettings.topics;
      } catch (e) {
        // Old subscription may not exist (e.g. 404). Proceed without topics.
        log('FCM token refresh: could not fetch old subscription topics: $e');
      }

      // 2. Create a new subscription with the new token.
      String localeName = Platform.localeName;
      if (localeName.contains('_')) {
        localeName = localeName.replaceAll('_', '-');
      }
      await _notificationsRepo.createNotificationSubscription(newToken, localeName);

      // 3. Copy topics from old subscription to new one.
      if (oldTopics.isNotEmpty) {
        await _notificationsRepo.updateNotificationSettings(newToken, oldTopics, true);
      }

      // 4. Delete the old subscription.
      try {
        await _notificationsRepo.deleteNotificationSubscription(oldToken);
      } catch (e) {
        log('FCM token refresh: could not delete old subscription: $e');
      }

      log('FCM token refresh: migrated subscription from old token to new token');
    } catch (e) {
      log('FCM token refresh: failed to migrate subscription: $e');
    } finally {
      // Always store the new token so subsequent refreshes reference the correct one.
      await _authStorage.storeFcmToken(newToken);
    }
  }
}
