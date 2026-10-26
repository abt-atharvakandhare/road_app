// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_tokenization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreTokenizationResponseModel _$StoreTokenizationResponseModelFromJson(
  Map<String, dynamic> json,
) => StoreTokenizationResponseModel(
  data: StoreTokenizationDataModel.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$StoreTokenizationResponseModelToJson(
  StoreTokenizationResponseModel instance,
) => <String, dynamic>{'data': instance.data};

StoreTokenizationDataModel _$StoreTokenizationDataModelFromJson(
  Map<String, dynamic> json,
) => StoreTokenizationDataModel(
  id: json['id'] as String,
  paymentType: json['paymentType'] as String,
  paymentMethod: json['paymentMethod'] as String,
  displayIdentifier: json['displayIdentifier'] as String,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$StoreTokenizationDataModelToJson(
  StoreTokenizationDataModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'paymentType': instance.paymentType,
  'paymentMethod': instance.paymentMethod,
  'displayIdentifier': instance.displayIdentifier,
  'expiresAt': instance.expiresAt,
};
