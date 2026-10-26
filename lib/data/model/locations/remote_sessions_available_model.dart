import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart';

part 'remote_sessions_available_model.g.dart';

@JsonSerializable()
class RemoteSessionAvailableModel {
  final String id;
  final String locationId;
  final String status;
  final String uid;
  final List<String> authorizationTypes;
  final List<Connector> connectors;
  final GeoLocation geoLocation;
  final LocationDetails locationDetails;
  final List<String> capabilities;

  const RemoteSessionAvailableModel({
    required this.id,
    required this.locationId,
    required this.status,
    required this.uid,
    required this.authorizationTypes,
    required this.connectors,
    required this.geoLocation,
    required this.locationDetails,
    required this.capabilities,
  });

  bool get supportsRemoteRfidCardCharging => authorizationTypes.contains('REMOTE_RFID');
  bool get supportsCreditCardCharging => authorizationTypes.contains('REMOTE_PAYMENT_CARD');

  factory RemoteSessionAvailableModel.fromJson(Map<String, dynamic> json) =>
      _$RemoteSessionAvailableModelFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteSessionAvailableModelToJson(this);
}

@JsonSerializable()
class LocationDetails {
  final String address;
  final String city;
  final String country;
  final String name;
  final String postalCode;

  const LocationDetails({
    required this.address,
    required this.city,
    required this.country,
    required this.name,
    required this.postalCode,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) => _$LocationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailsToJson(this);
}
