import 'package:flutter/material.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/date_time_extensions.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

class SessionItemWidget extends StatelessWidget {
  const SessionItemWidget({super.key, required this.session, required this.onPressed});

  final SessionModel session;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final billingString = session.finalBillingString ?? AppLocalizations.of(context)!.priceUnknown;

    var chargingDurationString = session.durationSeconds?.toInt().toDaysHoursMinutesString(context);

    // Active session will be missing durationSeconds. Use the startedAt time instead.
    if (session.isActive) {
      chargingDurationString ??=
          DateTime.now().difference(session.startedAt).inSeconds.toDaysHoursMinutesString(context);
    }

    var kwhAndDurationString = session.formattedKwhString;
    if (chargingDurationString != null) {
      kwhAndDurationString += ' • $chargingDurationString';
    }

    return RMInkwellButton(
        padding: const EdgeInsets.symmetric(vertical: 0),
        onPressed: onPressed,
        icon: Row(
          children: [
            session.isActive
                ? Container(
                    decoration: BoxDecoration(
                      color: RMColors.activeChargeBlueText,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      child: Text(AppLocalizations.of(context)!.active,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ))
                : Text(billingString,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: RMColors.rmPrimaryColor,
            )
          ],
        ),
        iconPadding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.location?.address ?? '-', style: Theme.of(context).textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                kwhAndDurationString,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(session.startedAt.toLocal().monthDayTime24h, style: Theme.of(context).textTheme.bodySmall),
          ],
        ));
  }
}
