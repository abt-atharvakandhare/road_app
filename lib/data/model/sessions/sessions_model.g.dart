// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionsResponseModel _$SessionsResponseModelFromJson(
  Map<String, dynamic> json,
) => SessionsResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionsResponseModelToJson(
  SessionsResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  limit: (json['limit'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  stats: json['stats'] == null
      ? null
      : SessionStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'limit': instance.limit,
  'skip': instance.skip,
  'total': instance.total,
  'stats': instance.stats,
};

SessionStats _$SessionStatsFromJson(Map<String, dynamic> json) => SessionStats(
  totalKwh: (json['totalKwh'] as num?)?.toDouble(),
  totalCosts: (json['totalCosts'] as num?)?.toDouble(),
  totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toDouble(),
  currency: json['currency'] as String,
);

Map<String, dynamic> _$SessionStatsToJson(SessionStats instance) =>
    <String, dynamic>{
      'totalKwh': instance.totalKwh,
      'totalCosts': instance.totalCosts,
      'totalDurationSeconds': instance.totalDurationSeconds,
      'currency': instance.currency,
    };

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String?,
  externalCalculatedPrice: (json['externalCalculatedPrice'] as num?)
      ?.toDouble(),
  kwh: (json['kwh'] as num).toDouble(),
  location: json['location'] == null
      ? null
      : SessionLocation.fromJson(json['location'] as Map<String, dynamic>),
  mspLocation: json['mspLocation'] == null
      ? null
      : MspLocation.fromJson(json['mspLocation'] as Map<String, dynamic>),
  currency: json['currency'] as String,
  durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  vatInfo: json['vatInfo'] == null
      ? null
      : VatInfo.fromJson(json['vatInfo'] as Map<String, dynamic>),
  status: json['status'] as String?,
  chargePointId: json['chargePointId'] as String?,
  physicalReference: json['physicalReference'] as String?,
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'externalCalculatedPrice': instance.externalCalculatedPrice,
      'kwh': instance.kwh,
      'location': instance.location,
      'mspLocation': instance.mspLocation,
      'currency': instance.currency,
      'durationSeconds': instance.durationSeconds,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'vatInfo': instance.vatInfo,
      'status': instance.status,
      'chargePointId': instance.chargePointId,
      'physicalReference': instance.physicalReference,
    };

VatInfo _$VatInfoFromJson(Map<String, dynamic> json) =>
    VatInfo(vatPercentage: (json['vatPercentage'] as num).toDouble());

Map<String, dynamic> _$VatInfoToJson(VatInfo instance) => <String, dynamic>{
  'vatPercentage': instance.vatPercentage,
};

SessionLocation _$SessionLocationFromJson(Map<String, dynamic> json) =>
    SessionLocation(
      name: json['name'] as String?,
      address: json['address'] as String?,
      geoLocation: json['geoLocation'] == null
          ? null
          : GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
      coordinates: json['coordinates'] == null
          ? null
          : ActiveLocationCoordinates.fromJson(
              json['coordinates'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SessionLocationToJson(SessionLocation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'geoLocation': instance.geoLocation,
      'coordinates': instance.coordinates,
    };

ActiveLocationCoordinates _$ActiveLocationCoordinatesFromJson(
  Map<String, dynamic> json,
) => ActiveLocationCoordinates(
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
);

Map<String, dynamic> _$ActiveLocationCoordinatesToJson(
  ActiveLocationCoordinates instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

MspLocation _$MspLocationFromJson(Map<String, dynamic> json) => MspLocation(
  id: json['id'] as String?,
  name: json['name'] as String?,
  geoLocation: json['geoLocation'] == null
      ? null
      : GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MspLocationToJson(MspLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'geoLocation': instance.geoLocation,
    };

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
  type: json['type'] as String?,
  coordinates: (json['coordinates'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
