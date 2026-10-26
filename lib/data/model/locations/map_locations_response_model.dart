import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/charging_connector_types.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

part 'map_locations_response_model.g.dart';

///
///  Used to populate the charging station details within the map overlay.
///
@JsonSerializable()
class MapLocationsResponseModel {
  MapLocationsResponseModel({required this.data});

  factory MapLocationsResponseModel.fromJson(Map<String, dynamic> json) => _$MapLocationsResponseModelFromJson(json);

  final List<MapLocationV2> data;

  Map<String, dynamic> toJson() => _$MapLocationsResponseModelToJson(this);

  String get availabilityCountString {
    int availableCount = 0;
    int chargingCount = 0;
    int notAvailableCount = 0;

    for (final location in data) {
      for (final evse in location.evses) {
        switch (evse.chargingPortAvailability) {
          case ChargingPortAvailability.available:
            availableCount++;
          case ChargingPortAvailability.charging:
            chargingCount++;
          case ChargingPortAvailability.notAvailable:
            notAvailableCount++;
        }
      }
    }

    final total = availableCount + chargingCount + notAvailableCount;

    if (availableCount == 0 || availableCount == total) {
      return '$total';
    }

    return '$availableCount / $total';
  }

  ChargingPortAvailability get chargingStatus {
    int chargingCount = 0;

    for (final location in data) {
      for (final evse in location.evses) {
        switch (evse.chargingPortAvailability) {
          case ChargingPortAvailability.available:
            return ChargingPortAvailability.available;
          case ChargingPortAvailability.charging:
            chargingCount++;
          case ChargingPortAvailability.notAvailable:
            break;
        }
      }
    }

    if (chargingCount > 0) {
      return ChargingPortAvailability.charging;
    } else {
      return ChargingPortAvailability.notAvailable;
    }
  }

  List<MapLocationV2> itemsSortedNearestTo(LatLng latLng) {
    final targetLatLng = maps_toolkit.LatLng(latLng.latitude, latLng.longitude);
    return data.sortedBy((element) {
      final sElementLatLng = maps_toolkit.LatLng(
        element.geoLocation?.coordinates[1] ?? 0,
        element.geoLocation?.coordinates[0] ?? 0,
      );
      return maps_toolkit.SphericalUtil.computeDistanceBetween(sElementLatLng, targetLatLng);
    });
  }

  String get locationAddress {
    for (final location in data) {
      if (location.address != null && location.address!.isNotEmpty) {
        return location.address ?? '';
      }
    }

    return 'No address available';
  }

  GeoLocation? get geoLocation {
    for (final location in data) {
      if (location.geoLocation != null && location.geoLocation!.coordinates.length == 2) {
        return location.geoLocation;
      }
    }

    return null;
  }
}

@JsonSerializable()
class MapLocationV2 {
  MapLocationV2({
    this.id,
    this.name,
    this.city,
    this.address,
    this.subOperator,
    required this.evses,
    this.facilities,
    this.infraProviderId,
    this.customNote,
    this.geoLocation,
    this.cdrAdditionalCharges,
    this.images,
  });

  final String? id;
  final String? name;
  final String? city;
  final String? address;
  final Suboperator? subOperator;
  final List<Evse> evses;
  final List<String>? facilities;
  final String? infraProviderId;
  final String? customNote;
  final GeoLocation? geoLocation;
  final List<CdrAdditionalCharge>? cdrAdditionalCharges;
  final List<LocationImage>? images;

  factory MapLocationV2.fromJson(Map<String, dynamic> json) => _$MapLocationV2FromJson(json);

  Map<String, dynamic> toJson() => _$MapLocationV2ToJson(this);

  bool get isEfluxLocation {
    return infraProviderId != null && infraProviderId!.endsWith(InfraProviderIdPostfix.eFlux);
  }

  String availabilityString({bool alwaysShowFraction = false}) {
    int availableCount = 0;
    int chargingCount = 0;
    int notAvailableCount = 0;

    for (final evse in evses) {
      switch (evse.chargingPortAvailability) {
        case ChargingPortAvailability.available:
          availableCount++;
        case ChargingPortAvailability.charging:
          chargingCount++;
        case ChargingPortAvailability.notAvailable:
          notAvailableCount++;
      }
    }

    final total = availableCount + chargingCount + notAvailableCount;

    if (alwaysShowFraction) {
      return '$availableCount/$total';
    }

    if (availableCount == 0 || availableCount == total) {
      return '$total';
    }

    return '$availableCount / $total';
  }

  // Keep the original getter for backward compatibility
  String get availabilityCountString => availabilityString();

  // New getter specifically for nearest stations display - always shows with total
  String get availabilityWithTotal => availabilityString(alwaysShowFraction: true);

  ChargingPortAvailability get chargingStatus {
    int chargingCount = 0;

    for (final evse in evses) {
      switch (evse.chargingPortAvailability) {
        case ChargingPortAvailability.available:
          return ChargingPortAvailability.available;
        case ChargingPortAvailability.charging:
          chargingCount++;
        case ChargingPortAvailability.notAvailable:
          break;
      }
    }

    if (chargingCount > 0) {
      return ChargingPortAvailability.charging;
    } else {
      return ChargingPortAvailability.notAvailable;
    }
  }
}

/// An OCPI location image, e.g. a photo of the site (matches the API's MspLocationImage).
@JsonSerializable()
class LocationImage {
  LocationImage({
    required this.url,
    this.category,
    this.type,
    this.thumbnail,
    this.width,
    this.height,
  });

  final String url;
  final String? category;
  final String? type;
  final String? thumbnail;
  final int? width;
  final int? height;

  factory LocationImage.fromJson(Map<String, dynamic> json) => _$LocationImageFromJson(json);

  Map<String, dynamic> toJson() => _$LocationImageToJson(this);
}

@JsonSerializable()
class Suboperator {
  String? name;

  Suboperator({this.name});

  factory Suboperator.fromJson(Map<String, dynamic> json) => _$SuboperatorFromJson(json);

  Map<String, dynamic> toJson() => _$SuboperatorToJson(this);
}

enum CannotRemoteStartReason { noRemoteCharging, onlyRFIDTagCharging, onlyCreditCardCharging }

@JsonSerializable()
class Evse {
  Evse({
    this.evseId,
    this.uid,
    this.maxPower,
    this.status,
    this.capabilities,
    this.authorizationTypes,
    required this.connectors,
    this.userSpecialTariffs,
    this.physicalReference,
  });

  factory Evse.fromJson(Map<String, dynamic> json) => _$EvseFromJson(json);

  String? evseId;
  String? uid;
  double? maxPower;
  String? status;
  final List<String>? capabilities;
  List<String>? authorizationTypes;
  final List<Connector> connectors;
  final List<UserSpecialTariff>? userSpecialTariffs;
  final String? physicalReference;

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

  bool get stationSupportsRfidCharging {
    return authorizationTypes != null && authorizationTypes!.contains('REMOTE_RFID');
  }

  bool get stationSupportsCreditCardCharging {
    return authorizationTypes != null && authorizationTypes!.contains('REMOTE_PAYMENT_CARD');
  }

  bool get stationSupportsRemoteStartStop {
    return stationSupportsRfidCharging || stationSupportsCreditCardCharging;
  }

  CannotRemoteStartReason? remoteStartStopNotAvailableReason(bool haveRfidCard, bool haveOrCanAddCreditCard) {
    if (!stationSupportsRfidCharging && !stationSupportsCreditCardCharging) {
      return CannotRemoteStartReason.noRemoteCharging;
    }

    if (stationSupportsCreditCardCharging && haveOrCanAddCreditCard) {
      return null;
    }

    if (stationSupportsRfidCharging && haveRfidCard) {
      return null;
    }

    // No remote start charging is possible.

    if (stationSupportsRfidCharging && !stationSupportsCreditCardCharging) {
      return CannotRemoteStartReason.onlyRFIDTagCharging;
    }

    if (!stationSupportsRfidCharging && stationSupportsCreditCardCharging) {
      return CannotRemoteStartReason.onlyCreditCardCharging;
    }

    assert(stationSupportsRfidCharging && stationSupportsCreditCardCharging && !haveOrCanAddCreditCard);

    return CannotRemoteStartReason.onlyRFIDTagCharging;
  }

  String uniqueEvseConnectorStringFor(Connector connector) {
    if (connectors.length == 1) {
      return evseId ?? '';
    }

    return '$evseId*${connector.id}';
  }
}

@JsonSerializable()
class UserSpecialTariff {
  UserSpecialTariff({this.eligibleIdentifiers, this.tariff, this.billingPlanDetails});

  factory UserSpecialTariff.fromJson(Map<String, dynamic> json) => _$UserSpecialTariffFromJson(json);

  final List<String>? eligibleIdentifiers;
  final Tariff? tariff;
  final BillingPlanDetails? billingPlanDetails;

  Map<String, dynamic> toJson() => _$UserSpecialTariffToJson(this);

  String? getTariffNameForLanguage(String language) {
    if (billingPlanDetails == null || billingPlanDetails?.detailsTranslation == null) {
      return null;
    }

    final details = billingPlanDetails!.detailsTranslation?.firstWhereOrNull((element) => element.language == language);

    if (details != null) {
      return details.name;
    }

    // Default to 'en', which is always present.
    return billingPlanDetails!.detailsTranslation?.firstWhereOrNull((element) => element.language == 'en')?.name;
  }
}

@JsonSerializable()
class BillingPlanDetails {
  BillingPlanDetails({this.detailsTranslation});

  factory BillingPlanDetails.fromJson(Map<String, dynamic> json) => _$BillingPlanDetailsFromJson(json);

  final List<DetailsTranslation>? detailsTranslation;

  Map<String, dynamic> toJson() => _$BillingPlanDetailsToJson(this);
}

@JsonSerializable()
class DetailsTranslation {
  DetailsTranslation({this.language, this.name});

  factory DetailsTranslation.fromJson(Map<String, dynamic> json) => _$DetailsTranslationFromJson(json);

  final String? language;
  final String? name;

  Map<String, dynamic> toJson() => _$DetailsTranslationToJson(this);
}

@JsonSerializable()
class Connector {
  Connector({this.id, this.maxPower, this.powerType, this.standard, this.tariff});

  factory Connector.fromJson(Map<String, dynamic> json) => _$ConnectorFromJson(json);

  final String? id;
  final double? maxPower;
  final String? powerType;
  final String? standard;
  final Tariff? tariff;

  Map<String, dynamic> toJson() => _$ConnectorToJson(this);

  String? get humanPowerTypeString {
    switch (powerType) {
      case 'AC_1_PHASE':
        return 'AC';
      case 'AC_3_PHASE':
        return 'AC x 3';
      default:
        return powerType;
    }
  }

  String get humanConnectorDetails {
    final connectorTypeString = standard != null ? ChargingConnectorTypes.humanReadableNameFor(standard!) : '-';

    return '$connectorTypeString, ${humanPowerTypeString ?? '-'}';
  }

  String get svgAssetPath => ChargingConnectorTypes.svgAssetPathFor(standard);
}

@JsonSerializable()
class Tariff {
  Tariff({required this.currency, required this.elements});

  factory Tariff.fromJson(Map<String, dynamic> json) => _$TariffFromJson(json);

  String? currency;
  List<TariffElementModel>? elements;

  Map<String, dynamic> toJson() => _$TariffToJson(this);
}

@JsonSerializable()
class TariffElementModel {
  TariffElementModel({this.priceComponentsCamelCase, this.priceComponentsSnakeCase, this.restrictions});

  factory TariffElementModel.fromJson(Map<String, dynamic> json) => _$TariffElementModelFromJson(json);

  @JsonKey(name: 'priceComponents')
  final List<PriceComponent>? priceComponentsCamelCase;
  @JsonKey(name: 'price_components')
  final List<PriceComponent>? priceComponentsSnakeCase;

  List<PriceComponent>? get priceComponents {
    return priceComponentsCamelCase ?? priceComponentsSnakeCase;
  }

  final Restrictions? restrictions;

  Map<String, dynamic> toJson() => _$TariffElementModelToJson(this);
}

@JsonSerializable()
class PriceComponent {
  PriceComponent({required this.price, this.stepSizeCamelCase, this.stepSizeSnakeCase, required this.type, this.vat});

  factory PriceComponent.fromJson(Map<String, dynamic> json) => _$PriceComponentFromJson(json);

  final double price;

  @JsonKey(name: 'stepSize')
  final double? stepSizeCamelCase;
  @JsonKey(name: 'step_size')
  final double? stepSizeSnakeCase;
  final String type;
  final double? vat;

  double? get stepSize {
    return stepSizeCamelCase ?? stepSizeSnakeCase;
  }

  Map<String, dynamic> toJson() => _$PriceComponentToJson(this);
}

@JsonSerializable()
class Restrictions {
  Restrictions({
    this.endDate,
    this.endTime,
    this.startDate,
    this.startTime,
    this.dayOfWeek,
    this.minDuration,
    this.maxDuration,
  });

  factory Restrictions.fromJson(Map<String, dynamic> json) => _$RestrictionsFromJson(json);

  final String? endDate;
  final String? endTime;
  final String? startDate;
  final String? startTime;
  final List<String>? dayOfWeek;
  final int? minDuration;
  final int? maxDuration;

  Map<String, dynamic> toJson() => _$RestrictionsToJson(this);
}

@JsonSerializable()
class CdrAdditionalCharge {
  CdrAdditionalCharge({required this.vat, required this.price, this.currency});

  factory CdrAdditionalCharge.fromJson(Map<String, dynamic> json) => _$CdrAdditionalChargeFromJson(json);

  final double vat;
  final double price;
  final String? currency;

  Map<String, dynamic> toJson() => _$CdrAdditionalChargeToJson(this);
}

extension ListOfMapLocationV2s on List<MapLocationV2> {
  String get valueKeyString {
    return map((e) => e.id).join(',');
  }
}
