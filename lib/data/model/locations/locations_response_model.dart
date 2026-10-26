import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';

part 'locations_response_model.g.dart';

///
/// v1 of the API. Used to populate custom searches, such as by searchId.
///
@JsonSerializable()
class LocationsResponseModel {
  List<Location> data;
  Meta meta;

  LocationsResponseModel({
    required this.data,
    required this.meta,
  });

  static Future<LocationsResponseModel> computeFromJson(Map<String, dynamic> json) async {
    return await compute(LocationsResponseModel.fromJson, json);
  }

  factory LocationsResponseModel.fromJson(Map<String, dynamic> json) => _$LocationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationsResponseModelToJson(this);

  LatLngBounds allLocationBounds() {
    List<LatLng> latLngs = [];
    for (var element in data) {
      if (element.geoLocation.latLng != null) {
        latLngs.add(element.geoLocation.latLng!);
      }
    }

    if (latLngs.isEmpty) {
      return LatLngBounds(southwest: const LatLng(85, 175), northeast: const LatLng(-85, -175));
    }

    var firstLatLng = latLngs.first;
    var s = firstLatLng.latitude, n = firstLatLng.latitude, w = firstLatLng.longitude, e = firstLatLng.longitude;
    for (var i = 1; i < latLngs.length; i++) {
      var latlng = latLngs[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }

    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }
}

@JsonSerializable()
class Meta {
  int limit;
  int skip;
  int total;

  Meta({
    required this.limit,
    required this.skip,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable()
class Location extends Equatable {
  final String id;
  final String? name;
  final String? address;
  final GeoLocation geoLocation;
  final List<Evse> evses;
  final List<CdrAdditionalCharge>? cdrAdditionalCharges;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.geoLocation,
    required this.evses,
    this.cdrAdditionalCharges,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  ChargingPortAvailability get chargingPortAvailability {
    if (evses.isEmpty) {
      return ChargingPortAvailability.notAvailable;
    }

    bool havePortCurrentlyCharging = false;
    for (final evse in evses) {
      if (evse.status == 'AVAILABLE') {
        return ChargingPortAvailability.available;
      }

      if (evse.status == 'CHARGING') {
        havePortCurrentlyCharging = true;
      }
    }

    return havePortCurrentlyCharging ? ChargingPortAvailability.charging : ChargingPortAvailability.notAvailable;
  }

  /// Returns available / total
  List<int> get availabilityCountString {
    int total = 0;
    int available = 0;
    for (final evse in evses) {
      total += evse.connectors.length;
      if (evse.chargingPortAvailability == ChargingPortAvailability.available) {
        available += evse.connectors.length;
      }
    }

    return [available, total];
  }

  @override
  List<Object?> get props => [id];
}

@JsonSerializable()
class GeoLocation {
  List<double> coordinates;

  GeoLocation({
    required this.coordinates,
  });

  LatLng? get latLng {
    if (coordinates.length < 2) {
      return null;
    }
    return LatLng(coordinates[1], coordinates[0]);
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) => _$GeoLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);
}

@JsonSerializable()
class Evse {
  @JsonKey(name: 'evse_id')
  String? evseId;
  String? uid;
  String? status;

  List<String>? capabilities;
  List<Connector> connectors;
  List<String>? authorizationTypes;
  final String? physicalReference;

  Evse({
    this.evseId,
    this.uid,
    this.status,
    this.capabilities,
    required this.connectors,
    this.physicalReference,
  });

  factory Evse.fromJson(Map<String, dynamic> json) => _$EvseFromJson(json);

  Map<String, dynamic> toJson() => _$EvseToJson(this);

  ChargingPortAvailability get chargingPortAvailability {
    if (status == 'AVAILABLE') {
      return ChargingPortAvailability.available;
    }

    if (status == 'CHARGING') {
      return ChargingPortAvailability.charging;
    }

    // UNKNOWN, OUTOFORDER, BLOCKED

    return ChargingPortAvailability.notAvailable;
  }

  String uniqueEvseConnectorStringFor(Connector connector) {
    if (connectors.length == 1) {
      return evseId ?? '-';
    }

    return '${evseId ?? '-'}*${connector.id}';
  }

  bool get supportsRemoteRfidCardCharging {
    return authorizationTypes?.contains('REMOTE_RFID') ?? false;
  }

  bool get supportsCreditCardCharging {
    return authorizationTypes?.contains('REMOTE_PAYMENT_CARD') ?? false;
  }
}

@JsonSerializable()
class Connector {
  String? id;

  // ToDo - unify once BE unifies
  @JsonKey(name: 'power_type')
  String? oldPowerType;

  @JsonKey(name: 'powerType')
  String? newPowerType;

  double? maxPower;

  Tariff? tariff;

  Connector({
    this.id,
    this.oldPowerType,
    this.newPowerType,
    this.maxPower,
    this.tariff,
  });

  factory Connector.fromJson(Map<String, dynamic> json) => _$ConnectorFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectorToJson(this);

  String get powerType => newPowerType ?? oldPowerType ?? '';
}
