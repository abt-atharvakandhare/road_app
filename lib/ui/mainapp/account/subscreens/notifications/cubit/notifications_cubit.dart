import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_mobile/data/model/notifications/notifications_response_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_repo.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'notifications_state.dart';
part 'notifications_cubit.freezed.dart';

extension on StateOfChargeNotificationItem {
  String get topicIdentifier {
    switch (this) {
      case StateOfChargeNotificationItem.chargingSessionStarted:
        return 'charging.session.started';
      case StateOfChargeNotificationItem.chargingSessionEnded:
        return 'charging.session.ended';
      case StateOfChargeNotificationItem.chargingSessionStateOver80:
        return 'charging.session.stateofcharge.over80percent';
      case StateOfChargeNotificationItem.chargingSessionCharging:
        return 'charging.session.charging';
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEv:
        return 'charging.session.suspendedev';
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEvse:
        return 'charging.session.suspendedevse';
      case StateOfChargeNotificationItem.chargingSessionLiveUpdate:
        return 'charging.session.live_update';
    }
  }
}

@freezed
sealed class NotificationsChangeItem with _$NotificationsChangeItem {
  const factory NotificationsChangeItem.allItems() = AllItems;
  const factory NotificationsChangeItem.singleItem(StateOfChargeNotificationItem item) = SingleItem;

  const NotificationsChangeItem._();
}

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepo _notificationsRepo;
  final AuthStorage _authStorage;

  /// One-time upgrade marker: when an existing user (who already has at least one
  /// charging notification topic enabled) opens the app for the first time after
  /// `charging.session.live_update` was introduced, we auto-subscribe them so the
  /// live activity / ongoing notification pipeline works without them having to
  /// hunt for a switch. After this flag flips, we never auto-subscribe again — the
  /// user is in full control. Flag can be removed after a few months of adoption.
  ///
  /// Prefixed with `persist:` so it survives `_prefs.clearUserScoped()` on logout
  /// (see [PersistentPrefs] for the convention).
  static const liveUpdateMigrationDoneKey = 'persist:notifications.live_update_migration_done';

  NotificationsCubit(this._notificationsRepo, this._authStorage)
      : super(const NotificationsState.notifications(
            allNotifications: false, items: [], initialLoading: true, flow: UIFlow.loading())) {
    _getDeviceNotificationPermissions();
  }

  void _getDeviceNotificationPermissions() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        _getNotificationTopicStates();
        break;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.deniedPermanently:
      case AuthorizationStatus.notDetermined:
        if (!isClosed) {
          emit(NotificationsState.notifications(
              allNotifications: false, items: StateOfChargeNotificationItemState.allItemsInState(false)));
        }
        return;
    }
  }

  Future<void> _getNotificationTopicStates() async {
    NotificationsResponse notificationsResponse;
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        log('FCM token is null');
        if (!isClosed) {
          emit(NotificationsState.notifications(
              allNotifications: false, items: StateOfChargeNotificationItemState.allItemsInState(false)));
        }
        return;
      }

      notificationsResponse = await _notificationsRepo.getNotificationSettings(fcmToken);
    } catch (e) {
      // 404 error is none of the topics are enabled
      log('Error getting notification settings: $e');
      notificationsResponse = NotificationsResponse(topics: []);
      await _createNotificationSubscription();
    }

    try {
      // One-time upgrade for users updating from a build that pre-dates the
      // `charging.session.live_update` topic: if they already have any charging
      // topic on, auto-enable live updates so the live activity / ongoing
      // notification works without them needing to hunt for a switch.
      await _maybeMigrateLiveUpdateTopic(notificationsResponse);

      final List<StateOfChargeNotificationItemState> notificationItems = [];
      var allTopicsAreOn = true;
      for (var item in StateOfChargeNotificationItem.values) {
        final isEnabled =
            notificationsResponse.topics.firstWhereOrNull((element) => element == item.topicIdentifier) != null;
        notificationItems.add(StateOfChargeNotificationItemState(item, isEnabled));
        if (!isEnabled) {
          allTopicsAreOn = false;
        }
      }

      if (!isClosed) emit(NotificationsState.notifications(allNotifications: allTopicsAreOn, items: notificationItems));
    } on RMApiError catch (e) {
      if (!isClosed) emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Returns the (possibly mutated) [response] with the live-update topic added if
  /// migration just ran. Mutating the response in-place keeps the loop below simple.
  Future<void> _maybeMigrateLiveUpdateTopic(NotificationsResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(liveUpdateMigrationDoneKey) ?? false) return;

    const liveUpdateTopic = 'charging.session.live_update';
    final hasAnyTopic = response.topics.isNotEmpty;
    final alreadySubscribed = response.topics.contains(liveUpdateTopic);

    if (hasAnyTopic && !alreadySubscribed) {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          log('Live update migration: no FCM token, skipping for now.');
          return;
        }
        await _notificationsRepo.updateNotificationSettings(fcmToken, [liveUpdateTopic], true);
        response.topics.add(liveUpdateTopic);
        log('Live update migration: subscribed user to $liveUpdateTopic');
      } catch (e) {
        log('Live update migration failed: $e — will retry on next load.');
        return;
      }
    }
    // Mark migration done either way: if the user had no topics on, we don't auto-subscribe
    // (their first opt-in will turn on everything anyway). If they were already subscribed,
    // there's nothing to do.
    await prefs.setBool(liveUpdateMigrationDoneKey, true);
  }

  /// Returns true if we should direct the user to settings to enable notifications
  Future<bool> turnNotificationsOn(NotificationsChangeItem changeItem) async {
    try {
      var settings = await FirebaseMessaging.instance.getNotificationSettings();

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          final previousState = _emitOptimisticState(changeItem, true);
          _syncNotificationSetting(changeItem, true, previousState);
          return false;
        case AuthorizationStatus.denied:
          if (Platform.isIOS) {
            return true;
          } else {
            // Android requires us to track if the user has already been asked for permissions
            await FirebaseMessaging.instance.requestPermission();
          }
        case AuthorizationStatus.deniedPermanently:
          // The OS will not show the permission prompt again; only system settings can re-enable.
          return true;
        case AuthorizationStatus.notDetermined:
          await FirebaseMessaging.instance.requestPermission();
          break;
      }

      settings = await FirebaseMessaging.instance.getNotificationSettings();

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          try {
            await _createNotificationSubscription();
          } catch (e) {
            // This can already exist if the user manually disabled notifications and we are re-enabling them
            log('Error creating notification subscription: $e');
          }
          final previousState = _emitOptimisticState(changeItem, true);
          _syncNotificationSetting(changeItem, true, previousState);
          return false;
        case AuthorizationStatus.denied:
        case AuthorizationStatus.deniedPermanently:
          return true;
        case AuthorizationStatus.notDetermined:
          if (!isClosed) emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Notifications status is still not determined'))));
          return false;
      }
    } on RMApiError catch (e) {
      if (!isClosed) emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<void> turnNotificationsOff(NotificationsChangeItem changeItem) async {
    final previousState = _emitOptimisticState(changeItem, false);
    _syncNotificationSetting(changeItem, false, previousState);
  }

  Future<void> _createNotificationSubscription() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        log('FCM token is null');
        return;
      }

      String localeName = Platform.localeName;
      if (localeName.contains('_')) {
        localeName = localeName.replaceAll('_', '-');
      }

      await _notificationsRepo.createNotificationSubscription(fcmToken, localeName);
      await _authStorage.storeFcmToken(fcmToken);
    } on RMApiError catch (e) {
      if (!isClosed) emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Computes and emits an optimistic state based on the change item and enabled flag.
  /// Returns the previous state so it can be reverted on failure.
  NotificationsState _emitOptimisticState(NotificationsChangeItem changeItem, bool enabled) {
    final previousState = state;

    final newItems = state.items.map((itemState) {
      final shouldUpdate = switch (changeItem) {
        AllItems() => true,
        SingleItem(:final item) => itemState.item == item,
      };
      return shouldUpdate ? StateOfChargeNotificationItemState(itemState.item, enabled) : itemState;
    }).toList();

    final allOn = newItems.every((item) => item.value);

    if (!isClosed) emit(state.copyWith(allNotifications: allOn, items: newItems));
    return previousState;
  }

  /// Sends the notification setting to the backend and re-fetches state.
  /// On failure, reverts to [previousState] and emits an error.
  Future<void> _syncNotificationSetting(
      NotificationsChangeItem changeItem, bool enabled, NotificationsState previousState) async {
    try {
      await _sendNotificationSettingToBackend(changeItem, enabled);
      await _getNotificationTopicStates();
    } on RMApiError catch (e) {
      if (!isClosed) emit(previousState.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<void> _sendNotificationSettingToBackend(NotificationsChangeItem changeItem, bool enabled) async {
    String? fcmToken;

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      log('Can\'t get the token');
      if (!isClosed) emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'FCM token is unavailable: ${e.toString()}'))));
      return;
    }

    if (fcmToken == null) {
      log('FCM token is null');
      if (!isClosed) emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'FCM token is unavailable.'))));
      return;
    }

    await switch (changeItem) {
      AllItems() => _notificationsRepo.updateNotificationSettings(
          fcmToken, StateOfChargeNotificationItem.values.map((e) => e.topicIdentifier).toList(), enabled),
      SingleItem(:final item) =>
        _notificationsRepo.updateNotificationSettings(fcmToken, [item.topicIdentifier], enabled),
    };
  }
}
