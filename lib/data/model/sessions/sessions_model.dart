import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';

part 'sessions_model.g.dart';

@JsonSerializable()
class SessionsResponseModel {
  SessionsResponseModel({
    required this.data,
    required this.meta,
  });

  factory SessionsResponseModel.fromJson(Map<String, dynamic> json) => _$SessionsResponseModelFromJson(json);

  final List<SessionModel> data;
  final Meta meta;

  Map<String, dynamic> toJson() => _$SessionsResponseModelToJson(this);
}

@JsonSerializable()
class Meta {
  int limit;
  int skip;
  int total;
  SessionStats? stats;

  Meta({
    required this.limit,
    required this.skip,
    required this.total,
    this.stats,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}

@JsonSerializable()
class SessionStats {
  final double? totalKwh;
  final double? totalCosts;
  final double? totalDurationSeconds;
  final String currency;

  SessionStats({
    this.totalKwh,
    this.totalCosts,
    this.totalDurationSeconds,
    required this.currency,
  });

  factory SessionStats.fromJson(Map<String, dynamic> json) => _$SessionStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatsToJson(this);
}

@JsonSerializable()
class SessionModel {
  SessionModel({
    this.id,
    this.externalCalculatedPrice,
    required this.kwh,
    this.location,
    this.mspLocation,
    required this.currency,
    this.durationSeconds,
    required this.startedAt,
    this.endedAt,
    this.vatInfo,
    this.status,
    this.chargePointId,
    this.physicalReference,
  });

  final String? id;
  final double? externalCalculatedPrice;
  final double kwh;
  SessionLocation? location;
  final MspLocation? mspLocation;
  String currency;
  double? durationSeconds;
  DateTime startedAt;
  DateTime? endedAt; // Null if session is still active
  VatInfo? vatInfo;
  String? status;
  final String? chargePointId;

  /// CPO-supplied physical reference (e.g. "AMS-0629") for the EVSE used in this session.
  /// Available on the detail endpoint when the matching evse on the MspLocation has one.
  final String? physicalReference;

  /// True when this model was parsed from /1/active-sessions/mine. Active and
  /// completed sessions share an id namespace from the model's perspective but
  /// live in different Mongo collections, so the detail screen has to know
  /// which list endpoint to refetch from.
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isActiveListEntry = false;

  /// Preferred display id for the charge point: the CPO-friendly physicalReference
  /// when available, otherwise the canonical chargePointId (e.g. "NL-GFX-EA…").
  String? get displayChargePointId => physicalReference ?? chargePointId;

  /// Location name from the MSP Location (populated on detail endpoint), falling back to address.
  String? get locationName => mspLocation?.name ?? location?.name ?? location?.address;

  /// Lat/lng from the MSP Location's geoLocation (populated on the completed
  /// session detail endpoint), falling back to the embedded location which on
  /// active sessions carries OCPI-shape coordinates.
  double? get lat => mspLocation?.lat ?? location?.lat;
  double? get lng => mspLocation?.lng ?? location?.lng;

  String? get finalBillingString {
    if (externalCalculatedPrice == null) {
      return null;
    }

    var totalPrice = externalCalculatedPrice!;
    if (vatInfo?.vatPercentage != null) {
      totalPrice = totalPrice * (1 + (vatInfo!.vatPercentage / 100.0));
    }

    final currencyFormat = NumberFormat.simpleCurrency(name: currency);
    return currencyFormat.formatRoundingMidUp(totalPrice);
  }

  String get formattedKwhString {
    return '${kwh.toStringAsFixed(2)} kWh';
  }

  bool get isActive => (endedAt == null && status?.toLowerCase() == 'active');

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);
}

@JsonSerializable()
class VatInfo {
  VatInfo({
    required this.vatPercentage,
  });

  double vatPercentage;

  factory VatInfo.fromJson(Map<String, dynamic> json) => _$VatInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VatInfoToJson(this);
}

@JsonSerializable()
class SessionLocation {
  SessionLocation({
    this.name,
    this.address,
    this.geoLocation,
    this.coordinates,
  });

  factory SessionLocation.fromJson(Map<String, dynamic> json) => _$SessionLocationFromJson(json);

  final String? name;
  final String? address;
  final GeoLocation? geoLocation;

  /// Active-session payloads carry coords in OCPI shape (string lat/lng under
  /// `coordinates`) rather than the GeoJSON `geoLocation` shape that completed
  /// sessions use. Falling through here lets the screen render either source.
  final ActiveLocationCoordinates? coordinates;

  double? get lat => geoLocation?.lat ?? coordinates?.lat;
  double? get lng => geoLocation?.lng ?? coordinates?.lng;

  Map<String, dynamic> toJson() => _$SessionLocationToJson(this);
}

@JsonSerializable()
class ActiveLocationCoordinates {
  ActiveLocationCoordinates({this.latitude, this.longitude});

  factory ActiveLocationCoordinates.fromJson(Map<String, dynamic> json) =>
      _$ActiveLocationCoordinatesFromJson(json);

  final String? latitude;
  final String? longitude;

  double? get lat => latitude == null ? null : double.tryParse(latitude!);
  double? get lng => longitude == null ? null : double.tryParse(longitude!);

  Map<String, dynamic> toJson() => _$ActiveLocationCoordinatesToJson(this);
}

@JsonSerializable()
class MspLocation {
  MspLocation({
    this.id,
    this.name,
    this.geoLocation,
  });

  factory MspLocation.fromJson(Map<String, dynamic> json) => _$MspLocationFromJson(json);

  final String? id;
  final String? name;
  final GeoLocation? geoLocation;

  double? get lat => geoLocation?.lat;
  double? get lng => geoLocation?.lng;

  Map<String, dynamic> toJson() => _$MspLocationToJson(this);
}

@JsonSerializable()
class GeoLocation {
  GeoLocation({this.type, this.coordinates});

  factory GeoLocation.fromJson(Map<String, dynamic> json) => _$GeoLocationFromJson(json);

  final String? type;
  final List<double>? coordinates;

  double? get lng => coordinates != null && coordinates!.isNotEmpty ? coordinates![0] : null;
  double? get lat => coordinates != null && coordinates!.length > 1 ? coordinates![1] : null;

  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);
}
