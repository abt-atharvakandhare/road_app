import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../../data/model/locations/map_locations_response_model.dart';
import 'icon_label_row.dart';

class RMEvseDetailsWidget extends StatelessWidget {
  const RMEvseDetailsWidget({super.key, required this.evse, required this.connector});

  final Evse evse;
  final Connector connector;

  @override
  Widget build(BuildContext context) {
    final evseMaxPower = evse.maxPower?.maxPowerKwFormattedString ?? AppLocalizations.of(context)!.unknownKW;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      IconLabelRow(
        icon: SvgPicture.asset('assets/icons/lightning_bolt_small.svg'),
        label: evse.evseId ?? '',
      ),
      IconLabelRow(
        icon: RMChargingPortStatusIcon(chargePortStatus: evse.chargingPortAvailability),
        label: '${evse.chargingPortAvailability.humanString(context)}, $evseMaxPower',
      ),
      if (evse.connectors.isNotEmpty) ...[
        IconLabelRow(
          icon: SvgPicture.asset(connector.svgAssetPath),
          label: connector.humanConnectorDetails,
          type: IconLabelRowType.medium,
        ),
        IconLabelRow(
          icon: SvgPicture.asset('assets/icons/invoice_small.svg'),
          label: AppLocalizations.of(context)!.pricing,
          type: IconLabelRowType.medium,
        ),
      ],
    ]);
  }
}
