import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../data/model/locations/map_locations_response_model.dart';

extension LocationTypeLocalizations on MapLocationV2 {
  String? localizedTypeAndFacilities(BuildContext context) {
    final localizedFacilities = this.localizedFacilities(context);

    if (localizedFacilities == null) {
      return null;
    }

    var fullString = '';

    if (localizedFacilities.isNotEmpty) {
      if (fullString.isNotEmpty) {
        fullString += ', ';
      }

      fullString += localizedFacilities.join(', ');
    }

    return fullString;
  }

  List<String>? localizedFacilities(BuildContext context) {
    if (facilities == null || facilities!.isEmpty) {
      return null;
    }

    List<String> localizedFacilities = [];

    for (var facility in facilities!) {
      final localizedFacility = localizedStringForTypeOrFacility(context, facility);

      if (localizedFacility != null) {
        localizedFacilities.add(localizedFacility);
      }
    }

    return localizedFacilities;
  }

  String? localizedStringForTypeOrFacility(BuildContext context, String type) {
    switch (type) {
      //
      //  Types
      //
      case 'ALONG_MOTORWAY':
        return AppLocalizations.of(context)!.alongMotorway;
      case 'PARKING_GARAGE':
        return AppLocalizations.of(context)!.parkingGarage;
      case 'PARKING_LOT':
        return AppLocalizations.of(context)!.parkingLot;
      case 'ON_DRIVEWAY':
        return AppLocalizations.of(context)!.onDriveway;
      case 'ON_STREET':
        return AppLocalizations.of(context)!.onStreet;
      case 'UNDERGROUND_GARAGE':
        return AppLocalizations.of(context)!.undergroundGarage;
      case 'FUEL_STATION':
        return AppLocalizations.of(context)!.fuelStation;
      case 'UNKNOWN':
        return null;

      //
      //  Facilities
      //
      case 'HOTEL':
        return AppLocalizations.of(context)!.hotel;
      case 'RESTAURANT':
        return AppLocalizations.of(context)!.restaurant;
      case 'CAFE':
        return AppLocalizations.of(context)!.cafe;
      case 'MALL':
        return AppLocalizations.of(context)!.mall;
      case 'SUPERMARKET':
        return AppLocalizations.of(context)!.supermarket;
      case 'SPORT':
        return AppLocalizations.of(context)!.sport;
      case 'RECREATION_AREA':
        return AppLocalizations.of(context)!.recreationArea;
      case 'NATURE':
        return AppLocalizations.of(context)!.nature;
      case 'MUSEUM':
        return AppLocalizations.of(context)!.museum;
      case 'BIKE_SHARING':
        return AppLocalizations.of(context)!.bikeSharing;
      case 'BUS_STOP':
        return AppLocalizations.of(context)!.busStop;
      case 'TAXI_STAND':
        return AppLocalizations.of(context)!.taxiStand;
      case 'TRAM_STOP':
        return AppLocalizations.of(context)!.tramStop;
      case 'METRO_STATION':
        return AppLocalizations.of(context)!.metroStation;
      case 'TRAIN_STATION':
        return AppLocalizations.of(context)!.trainStation;
      case 'AIRPORT':
        return AppLocalizations.of(context)!.airport;
      case 'CARPOOL_PARKING':
        return AppLocalizations.of(context)!.carpoolParking;
      case 'WIFI':
        return AppLocalizations.of(context)!.wifi;
      default:
        return type;
    }
  }
}
