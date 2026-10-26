part of 'notifications_cubit.dart';

enum StateOfChargeNotificationItem {
  chargingSessionStarted,
  chargingSessionEnded,
  chargingSessionStateOver80,
  chargingSessionCharging,
  chargingSessionsSuspendedEv,
  chargingSessionsSuspendedEvse,
  chargingSessionLiveUpdate,
}

class StateOfChargeNotificationItemState {
  final StateOfChargeNotificationItem item;
  final bool value;

  StateOfChargeNotificationItemState(this.item, this.value);

  static List<StateOfChargeNotificationItemState> allItemsInState(bool state) =>
      StateOfChargeNotificationItem.values.map((item) => StateOfChargeNotificationItemState(item, state)).toList();
}

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState.notifications({
    required bool allNotifications,
    required List<StateOfChargeNotificationItemState> items,
    @Default(false) bool initialLoading,
    @Default(UIFlow.established()) UIFlow flow,
  }) = Notifications;
}

extension AnyNotificationOn on NotificationsState {
  bool get isAnyItemOn => items.any((element) => element.value);

  /// Whether the user has subscribed to the live charging update topic. This gates the
  /// live activity (iOS) / ongoing notification (Android) pipeline — without it the BE
  /// stops pushing and we don't start a local activity.
  bool get isLiveUpdateEnabled => items.any(
        (element) =>
            element.item == StateOfChargeNotificationItem.chargingSessionLiveUpdate && element.value,
      );
}
