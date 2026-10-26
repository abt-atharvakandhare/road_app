import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMChargingPortStatusIcon extends StatelessWidget {
  const RMChargingPortStatusIcon({
    super.key,
    required this.chargePortStatus,
  });

  final ChargingPortAvailability chargePortStatus;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (chargePortStatus) {
      case ChargingPortAvailability.charging:
        color = RMColors.chargingUnavailable;
        break;
      case ChargingPortAvailability.notAvailable:
        color = RMColors.chargingUnknown;
        break;
      case ChargingPortAvailability.available:
        color = RMColors.chargingAvailable;
        break;
    }

    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
