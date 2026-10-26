// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charging_authorizations_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentInstrumentsResponseModel _$PaymentInstrumentsResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentInstrumentsResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => PaymentInstrumentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentInstrumentsResponseModelToJson(
  PaymentInstrumentsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

PaymentInstrumentModel _$PaymentInstrumentModelFromJson(
  Map<String, dynamic> json,
) => PaymentInstrumentModel(
  id: json['id'] as String,
  psp: json['psp'] as String,
  pspReference: json['pspReference'] as String,
  status: json['status'] as String,
  tokenId: json['tokenId'] as String?,
  type: json['type'] as String,
  card: json['card'] == null
      ? null
      : CreditCardModel.fromJson(json['card'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentInstrumentModelToJson(
  PaymentInstrumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'psp': instance.psp,
  'pspReference': instance.pspReference,
  'status': instance.status,
  'tokenId': instance.tokenId,
  'type': instance.type,
  'card': instance.card,
};

CreditCardModel _$CreditCardModelFromJson(Map<String, dynamic> json) =>
    CreditCardModel(
      last4Digits: json['last4Digits'] as String,
      scheme: json['scheme'] as String,
    );

Map<String, dynamic> _$CreditCardModelToJson(CreditCardModel instance) =>
    <String, dynamic>{
      'last4Digits': instance.last4Digits,
      'scheme': instance.scheme,
    };
