// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationsResponseModel _$LocationsResponseModelFromJson(
  Map<String, dynamic> json,
) => LocationsResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => Location.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationsResponseModelToJson(
  LocationsResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

Meta _$MetaFromJson(Map<String, dynamic> json) => Meta(
  limit: (json['limit'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'limit': instance.limit,
  'skip': instance.skip,
  'total': instance.total,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  id: json['id'] as String,
  name: json['name'] as String?,
  address: json['address'] as String?,
  geoLocation: GeoLocation.fromJson(
    json['geoLocation'] as Map<String, dynamic>,
  ),
  evses: (json['evses'] as List<dynamic>)
      .map((e) => Evse.fromJson(e as Map<String, dynamic>))
      .toList(),
  cdrAdditionalCharges: (json['cdrAdditionalCharges'] as List<dynamic>?)
      ?.map((e) => CdrAdditionalCharge.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'geoLocation': instance.geoLocation,
  'evses': instance.evses,
  'cdrAdditionalCharges': instance.cdrAdditionalCharges,
};

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
  coordinates: (json['coordinates'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{'coordinates': instance.coordinates};

Evse _$EvseFromJson(Map<String, dynamic> json) =>
    Evse(
        evseId: json['evse_id'] as String?,
        uid: json['uid'] as String?,
        status: json['status'] as String?,
        capabilities: (json['capabilities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        connectors: (json['connectors'] as List<dynamic>)
            .map((e) => Connector.fromJson(e as Map<String, dynamic>))
            .toList(),
        physicalReference: json['physicalReference'] as String?,
      )
      ..authorizationTypes = (json['authorizationTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$EvseToJson(Evse instance) => <String, dynamic>{
  'evse_id': instance.evseId,
  'uid': instance.uid,
  'status': instance.status,
  'capabilities': instance.capabilities,
  'connectors': instance.connectors,
  'authorizationTypes': instance.authorizationTypes,
  'physicalReference': instance.physicalReference,
};

Connector _$ConnectorFromJson(Map<String, dynamic> json) => Connector(
  id: json['id'] as String?,
  oldPowerType: json['power_type'] as String?,
  newPowerType: json['powerType'] as String?,
  maxPower: (json['maxPower'] as num?)?.toDouble(),
  tariff: json['tariff'] == null
      ? null
      : Tariff.fromJson(json['tariff'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConnectorToJson(Connector instance) => <String, dynamic>{
  'id': instance.id,
  'power_type': instance.oldPowerType,
  'powerType': instance.newPowerType,
  'maxPower': instance.maxPower,
  'tariff': instance.tariff,
};
