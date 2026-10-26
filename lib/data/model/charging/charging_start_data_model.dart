import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';

import '../locations/tariff_model.dart';

part 'charging_start_data_model.g.dart';

/// Meta data for the "Start charging" screen
/// Unified model to keep this flow clean
class StartChargingLocationMetadata {
  String locationId;
  String evseId;
  String evseUid;
  String connectorId;
  LatLng latLng;
  String name;
  String address;
  ChargingPortAvailability status;
  double? maxPower;
  String powerType;
  TariffModel? tariffModel;
  List<UserSpecialTariff>? userSpecialTariffs;
  bool supportsRemoteRfidCardCharging;
  bool supportsCreditCardCharging;
  List<String> capabilities;
  LatLng? searchLocation;
  String? physicalReference;

  StartChargingLocationMetadata({
    required this.locationId,
    required this.evseId,
    required this.evseUid,
    required this.connectorId,
    required this.latLng,
    required this.name,
    required this.address,
    required this.status,
    required this.maxPower,
    required this.powerType,
    required this.tariffModel,
    required this.userSpecialTariffs,
    required this.supportsRemoteRfidCardCharging,
    required this.supportsCreditCardCharging,
    required this.capabilities,
    this.searchLocation,
    this.physicalReference,
  });

  String get displayId => physicalReference ?? evseId;

  static List<StartChargingLocationMetadata> fromLocationsResponse(MapLocationsResponseModel locations) {
    return locations.data.expand((location) {
      return location.evses.expand((evse) {
        return evse.connectors.map((connector) {
          return StartChargingLocationMetadata(
            locationId: location.id ?? '',
            evseId: evse.evseId ?? '',
            evseUid: evse.uid ?? '',
            connectorId: connector.id ?? '',
            latLng: location.geoLocation?.latLng ?? const LatLng(0, 0),
            name: location.name ?? '',
            address: location.address ?? '',
            status: ChargingPortAvailability.fromString(evse.status),
            maxPower: connector.maxPower,
            powerType: connector.powerType ?? '',
            tariffModel: TariffModel.fromTariff(connector.tariff),
            userSpecialTariffs: evse.userSpecialTariffs,
            supportsRemoteRfidCardCharging: evse.stationSupportsRfidCharging,
            supportsCreditCardCharging: evse.stationSupportsCreditCardCharging,
            capabilities: evse.capabilities ?? [],
            physicalReference: evse.physicalReference,
          );
        });
      });
    }).toList();
  }
}

extension FindBestTariff on StartChargingLocationMetadata {
  TariffModel? getBestTariff(String? rfidTokenVisualNumber) {
    if (rfidTokenVisualNumber == null || userSpecialTariffs == null || userSpecialTariffs!.isEmpty) {
      return tariffModel;
    }

    final userSpecialTariff = userSpecialTariffs!
        .firstWhereOrNull((element) => element.eligibleIdentifiers?.contains(rfidTokenVisualNumber) ?? false);
    if (userSpecialTariff == null) {
      return tariffModel;
    }

    return TariffModel.fromTariff(userSpecialTariff.tariff);
  }
}

extension SortStartChargingLocationMetadata on List<StartChargingLocationMetadata> {
  void sortByClosestTo(UserLocation userLocation) {
    sort((a, b) {
      final aUserLoc = UserLocation(latitude: a.latLng.latitude, longitude: a.latLng.longitude, accuracy: 1);
      final bUserLoc = UserLocation(latitude: b.latLng.latitude, longitude: b.latLng.longitude, accuracy: 1);

      final aDistance = aUserLoc.distanceToOtherLocation(userLocation);
      final bDistance = bUserLoc.distanceToOtherLocation(userLocation);

      return aDistance.compareTo(bDistance);
    });
  }
}

/// Just the data required to start a charging session
@JsonSerializable(includeIfNull: false)
class StartChargingParameters {
  // Required every time
  String paymentType; // TOKEN || PSP_PREAUTH
  String locationId;
  String evseUid;
  String connectorId;

  // For TOKEN paymentType
  String? tokenId;

  // For PSP_PREAUTH paymentType
  String? paymentInstrumentId;

  // For PSP_PREAUTH paymentType
  int? preauthAmount;
  String? currency;

  StartChargingParameters({
    required this.paymentType,
    required this.locationId,
    required this.evseUid,
    required this.connectorId,
    required this.preauthAmount,
    required this.currency,
    required this.tokenId,
    required this.paymentInstrumentId,
  });

  factory StartChargingParameters.fromJson(Map<String, dynamic> json) => _$StartChargingParametersFromJson(json);

  Map<String, dynamic> toJson() => _$StartChargingParametersToJson(this);
}
