import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/mainapp/report_problem/widgets/report_problem_entry_link.dart';
import 'package:road_mobile/ui/utils/widgets/rm_card_display_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';
import 'session_payment_display_widget.dart';

class ChargeSessionEndedWidget extends StatelessWidget {
  const ChargeSessionEndedWidget({
    super.key,
    required this.isStopping,
    required this.session,
    required this.card,
  });

  final bool isStopping;
  final ChargingSessionModel session;
  final UnifiedPaymentCard? card;

  @override
  Widget build(BuildContext context) {
    final finalBillingStringWithFx = session.mspSession?.priceWithFX?.totalWithVat;

    return RMContentBox(
        child: SingleChildScrollView(
      child: Column(children: [
        Lottie.asset(isStopping ? 'assets/lottie/session_stopping.json' : 'assets/lottie/session_ended.json',
            key: ValueKey<bool>(isStopping), repeat: isStopping),
        const SizedBox(height: 20),
        Text(isStopping ? AppLocalizations.of(context)!.sessionEnded : AppLocalizations.of(context)!.sessionCompleted),
        if (isStopping) ...[
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.youAreReadyToGo, style: Theme.of(context).textTheme.headlineSmall),
        ],
        const SizedBox(height: 40),
        Text(session.activeSessionkwhUsed, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 10),
        Text(
            session.activeSession?.startedAt.timeElapsed(context, session.stopRequestedAt) ??
                session.mspSession?.durationSeconds.hoursAndMinutesStringFromSeconds(context) ??
                AppLocalizations.of(context)!.hAndMin(0, 0),
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 20),
        const SizedBox(width: 40, child: RMSeparator()),
        const SizedBox(height: 20),
        if (finalBillingStringWithFx != null) ...[
          Text(finalBillingStringWithFx, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 21)),
          const SizedBox(height: 40),
        ] else ...[
          Text(AppLocalizations.of(context)!.noteWeAreStillProcessing,
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 30),
        ],
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
        else
          RMCardDisplayWidget(paymentInstrument: card),
        const SizedBox(height: 40),
        RMTextButton(
            onPressed: () {
              Navigator.of(context).pop();
              BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.modalFlowDismissed());
            },
            text: AppLocalizations.of(context)!.close),
        if (session.location?.id != null || session.locationId != null) ...[
          const SizedBox(height: 24),
          ReportProblemEntryLink(
            prompt: ReportProblemPrompt.sessionEnded,
            locationId: session.location?.id ?? session.locationId!,
          ),
        ],
      ]),
    ));
  }
}
