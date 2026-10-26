// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_sessions_available_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteSessionAvailableModel _$RemoteSessionAvailableModelFromJson(
  Map<String, dynamic> json,
) => RemoteSessionAvailableModel(
  id: json['id'] as String,
  locationId: json['locationId'] as String,
  status: json['status'] as String,
  uid: json['uid'] as String,
  authorizationTypes: (json['authorizationTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  connectors: (json['connectors'] as List<dynamic>)
      .map((e) => Connector.fromJson(e as Map<String, dynamic>))
      .toList(),
  geoLocation: GeoLocation.fromJson(
    json['geoLocation'] as Map<String, dynamic>,
  ),
  locationDetails: LocationDetails.fromJson(
    json['locationDetails'] as Map<String, dynamic>,
  ),
  capabilities: (json['capabilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RemoteSessionAvailableModelToJson(
  RemoteSessionAvailableModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'locationId': instance.locationId,
  'status': instance.status,
  'uid': instance.uid,
  'authorizationTypes': instance.authorizationTypes,
  'connectors': instance.connectors,
  'geoLocation': instance.geoLocation,
  'locationDetails': instance.locationDetails,
  'capabilities': instance.capabilities,
};

LocationDetails _$LocationDetailsFromJson(Map<String, dynamic> json) =>
    LocationDetails(
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      name: json['name'] as String,
      postalCode: json['postalCode'] as String,
    );

Map<String, dynamic> _$LocationDetailsToJson(LocationDetails instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'name': instance.name,
      'postalCode': instance.postalCode,
    };
