import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/charging/current_charging_values_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_cubit.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/direct_user_to_notification_settings.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';
import 'session_payment_display_widget.dart';

class CarIsChargingWidget extends StatelessWidget {
  const CarIsChargingWidget(
      {super.key,
      required this.isStarting,
      required this.session,
      required this.card,
      required this.chargingValues,
      this.attemptedStartTime});

  final bool isStarting;
  final ChargingSessionModel session;
  final UnifiedPaymentCard? card;
  final CurrentChargingValues? chargingValues;
  final DateTime? attemptedStartTime;

  @override
  Widget build(BuildContext context) {
    bool canCancelStart =
        (attemptedStartTime != null && DateTime.now().difference(attemptedStartTime!) >= const Duration(minutes: 2));

    // Prefer the live `current-charging-values` energy (same source feeding the Live
    // Activity) so the in-app value matches what the user sees on the lock screen.
    // Falls back to the session-level kwh field if the live poll hasn't returned yet.
    final kwhDisplay = chargingValues != null
        ? '${(chargingValues!.energy / 1000).toStringAsFixed(1)} kWh'
        : session.activeSessionkwhUsed;

    return RMContentBox(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Lottie.asset(isStarting ? 'assets/lottie/session_starting.json' : 'assets/lottie/session_charging.json'),
          const SizedBox(height: 20),
          Text(isStarting
              ? AppLocalizations.of(context)!.sessionStarting
              : AppLocalizations.of(context)!.yourCarIsCharging),
          const SizedBox(height: 40),
          // SoC progress bar is only shown when the API actually reports a percentage —
          // typically only on DC chargers. AC sessions return null and we fall back to
          // showing kWh as the primary metric instead of a misleading "0%".
          if (chargingValues?.stateOfCharge != null) ...[
            Text('${chargingValues!.stateOfCharge!}%', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(colors: const [
                    RMColors.progressBarGradientStart,
                    RMColors.progressBarGradientEnd,
                    RMColors.progressBarBackground,
                  ], stops: [
                    0,
                    chargingValues!.stateOfCharge!.toDouble().clamp(0, 100) / 100.0,
                    chargingValues!.stateOfCharge!.toDouble().clamp(0, 100) / 100.0,
                  ])),
              child: const SizedBox(height: 16),
            ),
            const SizedBox(height: 28),
            Text(kwhDisplay, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
          ] else ...[
            Text(kwhDisplay, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
          ],
          Text(
              session.activeSession?.startedAt.timeElapsed(context, session.stopRequestedAt) ??
                  AppLocalizations.of(context)!.hAndMin(0, 0),
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 30),
          const RMSeparator(),
          const SizedBox(height: 22),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(session.location?.address ?? AppLocalizations.of(context)!.unknownAddress,
                  style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 20),
          if (session.externalPayment?.paymentMethod != null && session.externalPayment?.displayIdentifier != null)
            SessionPaymentDisplayWidget(
              paymentMethod: session.externalPayment!.paymentMethod!,
              displayIdentifier: session.externalPayment!.displayIdentifier!,
            )
          else if (card != null)
            RMCardDisplayWidget(paymentInstrument: card),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.sendNotifications, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      Platform.isIOS
                          ? AppLocalizations.of(context)!.chargingUpdatesSubtitleIOS
                          : AppLocalizations.of(context)!.chargingUpdatesSubtitleAndroid,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  return Switch.adaptive(
                      // Treat this as a single global "all charging notifications" switch.
                      // Every notification topic is charging-related so there's no value
                      // exposing finer-grained toggles here — the dedicated settings screen
                      // already does that for users who want it.
                      value: state.isAnyItemOn,
                      onChanged: (value) async {
                        final cubit = BlocProvider.of<NotificationsCubit>(context);
                        if (value) {
                          final directToSettings =
                              await cubit.turnNotificationsOn(const NotificationsChangeItem.allItems());
                          if (directToSettings && context.mounted) {
                            directUserToNotificationSettings(context);
                          }
                          // Either way, re-check status: if permission was already granted
                          // we just need to start the live activity / FGS now rather than
                          // wait for the next poll.
                          if (context.mounted) {
                            BlocProvider.of<ChargeNowBloc>(context)
                                .add(const ChargeNowEvent.checkChargingStatus());
                          }
                        } else {
                          await cubit.turnNotificationsOff(const NotificationsChangeItem.allItems());
                          // Bloc setter will tear down the live activity / FGS as soon as
                          // the BlocListener fires the new (false) state through.
                        }
                      });
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          const RMSeparator(),
          const SizedBox(height: 40),
          BlocBuilder<ChargeNowBloc, ChargeNowState>(
            builder: (context, state) {
              final isLoading = state.flow.isLoading;
              return RMTextButton(
                  isLoading: isLoading,
                  onPressed: isStarting
                      ? null
                      : () {
                          BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.stopCharging(session));
                        },
                  text: AppLocalizations.of(context)!.endSession);
            },
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: canCancelStart
                  ? TextButton(
                      onPressed: () {
                        BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.cancelStartCharge(session));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancelSession,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.destructiveRed),
                      ))
                  : const SizedBox()),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.modalFlowDismissed());
              },
              child: Text(AppLocalizations.of(context)!.close,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor)))
        ],
      ),
    ));
  }
}
