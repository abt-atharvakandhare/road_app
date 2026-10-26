import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

enum ChargingPortAvailability {
  notAvailable,
  available,
  charging;

  String humanString(BuildContext context) {
    switch (this) {
      case ChargingPortAvailability.notAvailable:
        return AppLocalizations.of(context)!.notAvailable;
      case ChargingPortAvailability.available:
        return AppLocalizations.of(context)!.available;
      case ChargingPortAvailability.charging:
        return AppLocalizations.of(context)!.charging;
    }
  }

  factory ChargingPortAvailability.fromString(String? status) {
    if (status == 'AVAILABLE') {
      return ChargingPortAvailability.available;
    }

    if (status == 'CHARGING') {
      return ChargingPortAvailability.charging;
    }

    return ChargingPortAvailability.notAvailable;
  }
}
