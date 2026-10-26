// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charging_start_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartChargingParameters _$StartChargingParametersFromJson(
  Map<String, dynamic> json,
) => StartChargingParameters(
  paymentType: json['paymentType'] as String,
  locationId: json['locationId'] as String,
  evseUid: json['evseUid'] as String,
  connectorId: json['connectorId'] as String,
  preauthAmount: (json['preauthAmount'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  tokenId: json['tokenId'] as String?,
  paymentInstrumentId: json['paymentInstrumentId'] as String?,
);

Map<String, dynamic> _$StartChargingParametersToJson(
  StartChargingParameters instance,
) => <String, dynamic>{
  'paymentType': instance.paymentType,
  'locationId': instance.locationId,
  'evseUid': instance.evseUid,
  'connectorId': instance.connectorId,
  'tokenId': ?instance.tokenId,
  'paymentInstrumentId': ?instance.paymentInstrumentId,
  'preauthAmount': ?instance.preauthAmount,
  'currency': ?instance.currency,
};
