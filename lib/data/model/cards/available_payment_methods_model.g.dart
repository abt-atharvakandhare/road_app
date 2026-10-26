// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_payment_methods_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailablePaymentMethodsResponseModel
_$AvailablePaymentMethodsResponseModelFromJson(Map<String, dynamic> json) =>
    AvailablePaymentMethodsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map(
            (e) =>
                AvailablePaymentMethodModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$AvailablePaymentMethodsResponseModelToJson(
  AvailablePaymentMethodsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

AvailablePaymentMethodModel _$AvailablePaymentMethodModelFromJson(
  Map<String, dynamic> json,
) => AvailablePaymentMethodModel(
  id: json['id'] as String,
  paymentType: json['paymentType'] as String,
  paymentMethod: json['paymentMethod'] as String,
);

Map<String, dynamic> _$AvailablePaymentMethodModelToJson(
  AvailablePaymentMethodModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'paymentType': instance.paymentType,
  'paymentMethod': instance.paymentMethod,
};
