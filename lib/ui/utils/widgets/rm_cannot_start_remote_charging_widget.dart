import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

class RMCannotStartRemoteChargingWidget extends StatelessWidget {
  const RMCannotStartRemoteChargingWidget({required this.reason, super.key});

  final CannotRemoteStartReason reason;

  @override
  Widget build(BuildContext context) {
    String text;

    switch (reason) {
      case CannotRemoteStartReason.noRemoteCharging:
        text = AppLocalizations.of(context)!.stationDoesntSupportSessions;
        break;
      case CannotRemoteStartReason.onlyRFIDTagCharging:
        text = AppLocalizations.of(context)!.stationOnlySupportsRfidCards;
        break;
      case CannotRemoteStartReason.onlyCreditCardCharging:
        text = AppLocalizations.of(context)!.stationOnlySupportsCreditCards;
        break;
    }

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
            color: RMColors.warningBlueBackground,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: RMColors.warningBlueBorder)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(width: 16),
          SvgPicture.asset('assets/icons/warning_triangle.svg'),
          const SizedBox(width: 10),
          Flexible(child: Text(text, style: Theme.of(context).textTheme.labelMedium)),
          const SizedBox(width: 12),
        ]));
  }
}
