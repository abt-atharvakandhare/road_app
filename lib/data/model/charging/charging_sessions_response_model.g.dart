// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charging_sessions_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChargingSessionsResponseModel _$ChargingSessionsResponseModelFromJson(
  Map<String, dynamic> json,
) => ChargingSessionsResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => ChargingSessionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChargingSessionsResponseModelToJson(
  ChargingSessionsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

ChargingSessionModel _$ChargingSessionModelFromJson(
  Map<String, dynamic> json,
) => ChargingSessionModel(
  json['id'] as String,
  json['location'] == null
      ? null
      : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
  json['locationId'] as String?,
  json['status'] as String?,
  DateTime.parse(json['createdAt'] as String),
  json['stopRequestedAt'] == null
      ? null
      : DateTime.parse(json['stopRequestedAt'] as String),
  json['mspSession'] == null
      ? null
      : MspSessionModel.fromJson(json['mspSession'] as Map<String, dynamic>),
  json['tokenId'] as String?,
  json['activeSession'] == null
      ? null
      : ActiveSession.fromJson(json['activeSession'] as Map<String, dynamic>),
  json['externalPayment'] == null
      ? null
      : ExternalPaymentModel.fromJson(
          json['externalPayment'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ChargingSessionModelToJson(
  ChargingSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'location': instance.location,
  'locationId': instance.locationId,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'stopRequestedAt': instance.stopRequestedAt?.toIso8601String(),
  'mspSession': instance.mspSession,
  'tokenId': instance.tokenId,
  'activeSession': instance.activeSession,
  'externalPayment': instance.externalPayment,
};

ExternalPaymentModel _$ExternalPaymentModelFromJson(
  Map<String, dynamic> json,
) => ExternalPaymentModel(
  paymentMethod: json['paymentMethod'] as String?,
  displayIdentifier: json['displayIdentifier'] as String?,
);

Map<String, dynamic> _$ExternalPaymentModelToJson(
  ExternalPaymentModel instance,
) => <String, dynamic>{
  'paymentMethod': instance.paymentMethod,
  'displayIdentifier': instance.displayIdentifier,
};

ActiveSession _$ActiveSessionFromJson(Map<String, dynamic> json) =>
    ActiveSession(
      json['id'] as String,
      (json['kwh'] as num).toDouble(),
      DateTime.parse(json['startedAt'] as String),
      json['status'] as String,
    );

Map<String, dynamic> _$ActiveSessionToJson(ActiveSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kwh': instance.kwh,
      'startedAt': instance.startedAt.toIso8601String(),
      'status': instance.status,
    };

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(json['id'] as String, json['address'] as String);

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{'id': instance.id, 'address': instance.address};

MspSessionModel _$MspSessionModelFromJson(Map<String, dynamic> json) =>
    MspSessionModel(
      json['currency'] as String,
      (json['durationSeconds'] as num).toDouble(),
      (json['kwh'] as num).toDouble(),
      json['priceWithFX'] == null
          ? null
          : PriceWithFX.fromJson(json['priceWithFX'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MspSessionModelToJson(MspSessionModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'durationSeconds': instance.durationSeconds,
      'kwh': instance.kwh,
      'priceWithFX': instance.priceWithFX,
    };

PriceWithFX _$PriceWithFXFromJson(Map<String, dynamic> json) => PriceWithFX(
  json['originalCurrency'] as String,
  (json['originalAmountWithVAT'] as num).toDouble(),
);

Map<String, dynamic> _$PriceWithFXToJson(PriceWithFX instance) =>
    <String, dynamic>{
      'originalCurrency': instance.originalCurrency,
      'originalAmountWithVAT': instance.originalAmountWithVAT,
    };
