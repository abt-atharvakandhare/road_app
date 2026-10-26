import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../../data/model/locations/map_locations_response_model.dart';
import 'label_value_row.dart';

class RMLocationDetailsWidget extends StatelessWidget {
  const RMLocationDetailsWidget(
      {super.key, required this.location, required this.locationAvailability, required this.availabilityCountString});

  final MapLocationV2 location;
  final ChargingPortAvailability locationAvailability;
  final String availabilityCountString;

  @override
  Widget build(BuildContext context) {
    final stationName = location.name ?? '';
    final subOperator = location.subOperator?.name;
    final localizedTypeAndFacilities = location.localizedTypeAndFacilities(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (stationName.isNotEmpty)
        LabelValueRow(
            label: AppLocalizations.of(context)!.name,
            value: Expanded(child: Text(stationName, style: Theme.of(context).textTheme.labelMedium))),
      LabelValueRow(
          label: AppLocalizations.of(context)!.status,
          value: Row(children: [
            RMChargingPortStatusIcon(chargePortStatus: locationAvailability),
            const SizedBox(width: 10),
            Text('$availabilityCountString ${locationAvailability.humanString(context)}',
                style: Theme.of(context).textTheme.labelMedium),
          ])),
      if (subOperator != null && subOperator.isNotEmpty)
        LabelValueRow(
            label: AppLocalizations.of(context)!.operatorKey,
            value: Expanded(child: Text(subOperator, style: Theme.of(context).textTheme.labelMedium))),
      if (localizedTypeAndFacilities != null && localizedTypeAndFacilities.isNotEmpty)
        LabelValueRow(
          label: AppLocalizations.of(context)!.availableFacilities,
          value: Expanded(child: Text(localizedTypeAndFacilities, style: Theme.of(context).textTheme.labelMedium)),
        ),
    ]);
  }
}
