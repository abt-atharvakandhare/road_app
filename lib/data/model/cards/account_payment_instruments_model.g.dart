// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_payment_instruments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPaymentInstrumentsResponseModel
_$AccountPaymentInstrumentsResponseModelFromJson(Map<String, dynamic> json) =>
    AccountPaymentInstrumentsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map(
            (e) => AccountPaymentInstrumentModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$AccountPaymentInstrumentsResponseModelToJson(
  AccountPaymentInstrumentsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

AccountPaymentInstrumentModel _$AccountPaymentInstrumentModelFromJson(
  Map<String, dynamic> json,
) => AccountPaymentInstrumentModel(
  id: json['id'] as String,
  paymentProvider: json['paymentProvider'] as String,
  paymentType: json['paymentType'] as String,
  paymentMethod: json['paymentMethod'] as String,
  displayIdentifier: json['displayIdentifier'] as String,
);

Map<String, dynamic> _$AccountPaymentInstrumentModelToJson(
  AccountPaymentInstrumentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'paymentProvider': instance.paymentProvider,
  'paymentType': instance.paymentType,
  'paymentMethod': instance.paymentMethod,
  'displayIdentifier': instance.displayIdentifier,
};
