// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderResponseDataModel _$ProviderResponseDataModelFromJson(
  Map<String, dynamic> json,
) => ProviderResponseDataModel(
  data: ProviderResponseModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderResponseDataModelToJson(
  ProviderResponseDataModel instance,
) => <String, dynamic>{'data': instance.data};

ProviderResponseModel _$ProviderResponseModelFromJson(
  Map<String, dynamic> json,
) => ProviderResponseModel(
  id: json['id'] as String,
  customDomain: json['customDomain'] as String?,
  supportUrl: json['supportUrl'] as String?,
  tosUrl: json['tosUrl'] as String?,
  privacyUrl: json['privacyUrl'] as String?,
  csuiAboutUrl: json['csuiAboutUrl'] as String?,
  csuiSupportUrl: json['csuiSupportUrl'] as String?,
  enableVerifications: (json['enableVerifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ProviderResponseModelToJson(
  ProviderResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'customDomain': instance.customDomain,
  'supportUrl': instance.supportUrl,
  'tosUrl': instance.tosUrl,
  'privacyUrl': instance.privacyUrl,
  'csuiAboutUrl': instance.csuiAboutUrl,
  'csuiSupportUrl': instance.csuiSupportUrl,
  'enableVerifications': instance.enableVerifications,
};
