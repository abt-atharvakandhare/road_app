import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/direct_user_to_notification_settings.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';

import 'cubit/notifications_cubit.dart';
import 'widgets/switch_item.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  static void pushAsModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<NotificationsCubit>(),
          child: const NotificationsSettingsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildSwitchItems(context, state),
              Column(
                children: [
                  const Spacer(),
                  BottomLoadingWidget(isLoading: state.flow.isLoading),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchItems(BuildContext context, NotificationsState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.notifications, style: Theme.of(context).textTheme.bodyMedium),
            Text(AppLocalizations.of(context)!.manageYourNotifications, style: Theme.of(context).textTheme.bodySmall),
            RMShimmerLoader(
              isLoading: state.initialLoading,
              child: Column(children: [
                SwitchItem(
                  title: AppLocalizations.of(context)!.allNotifications,
                  value: state.allNotifications,
                  onChanged: (value) async {
                    if (value) {
                      final directToSettings = await BlocProvider.of<NotificationsCubit>(context)
                          .turnNotificationsOn(const NotificationsChangeItem.allItems());
                      if (directToSettings && context.mounted) {
                        final userDidGoToSettings = await directUserToNotificationSettings(context);
                        if (userDidGoToSettings && context.mounted) {
                          await BlocProvider.of<NotificationsCubit>(context)
                              .turnNotificationsOn(const NotificationsChangeItem.allItems());
                        }
                      }
                    } else {
                      BlocProvider.of<NotificationsCubit>(context)
                          .turnNotificationsOff(const NotificationsChangeItem.allItems());
                    }
                  },
                ),
                const SizedBox(height: 16),
                const RMSeparator(),
                const SizedBox(height: 16),
                ...state.items.map((item) {
                  return SwitchItem(
                    title: item.item.title(context),
                    subtitle: item.item.subtitle(context),
                    value: item.value,
                    onChanged: (value) async {
                      if (value) {
                        final directToSettings = await BlocProvider.of<NotificationsCubit>(context)
                            .turnNotificationsOn(NotificationsChangeItem.singleItem(item.item));
                        if (directToSettings && context.mounted) {
                          final userDidGoToSettings = await directUserToNotificationSettings(context);
                          if (userDidGoToSettings && context.mounted) {
                            await BlocProvider.of<NotificationsCubit>(context)
                                .turnNotificationsOn(NotificationsChangeItem.singleItem(item.item));
                          }
                        }
                      } else {
                        await BlocProvider.of<NotificationsCubit>(context)
                            .turnNotificationsOff(NotificationsChangeItem.singleItem(item.item));
                      }
                    },
                  );
                })
              ]),
            )
          ],
        ),
      ),
    );
  }
}

extension StateOfChargeNotificationText on StateOfChargeNotificationItem {
  String title(BuildContext context) {
    switch (this) {
      case StateOfChargeNotificationItem.chargingSessionStarted:
        return AppLocalizations.of(context)!.chargingStartedTitle;
      case StateOfChargeNotificationItem.chargingSessionEnded:
        return AppLocalizations.of(context)!.chargingSessionEndedTitle;
      case StateOfChargeNotificationItem.chargingSessionStateOver80:
        return AppLocalizations.of(context)!.chargingSessionStateOver80Title;
      case StateOfChargeNotificationItem.chargingSessionCharging:
        return AppLocalizations.of(context)!.chargingSessionChargingTitle;
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEv:
        return AppLocalizations.of(context)!.chargingSessionSuspendedEvTitle;
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEvse:
        return AppLocalizations.of(context)!.chargingSessionSuspendedEvseTitle;
      case StateOfChargeNotificationItem.chargingSessionLiveUpdate:
        return AppLocalizations.of(context)!.chargingSessionLiveUpdateTitle;
    }
  }

  String? subtitle(BuildContext context) {
    switch (this) {
      case StateOfChargeNotificationItem.chargingSessionStarted:
        return AppLocalizations.of(context)!.chargingSessionStartedSubtitle;
      case StateOfChargeNotificationItem.chargingSessionEnded:
        return AppLocalizations.of(context)!.chargingSessionEndedSubtitle;
      case StateOfChargeNotificationItem.chargingSessionStateOver80:
        return AppLocalizations.of(context)!.chargingSessionStateOver80Subtitle;
      case StateOfChargeNotificationItem.chargingSessionCharging:
        return AppLocalizations.of(context)!.chargingSessionChargingSubtitle;
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEv:
        return AppLocalizations.of(context)!.chargingSessionSuspendedEvSubtitle;
      case StateOfChargeNotificationItem.chargingSessionsSuspendedEvse:
        return AppLocalizations.of(context)!.chargingSessionSuspendedEvseSubtitle;
      case StateOfChargeNotificationItem.chargingSessionLiveUpdate:
        return Platform.isIOS
            ? AppLocalizations.of(context)!.chargingSessionLiveUpdateSubtitleIOS
            : AppLocalizations.of(context)!.chargingSessionLiveUpdateSubtitleAndroid;
    }
  }
}
