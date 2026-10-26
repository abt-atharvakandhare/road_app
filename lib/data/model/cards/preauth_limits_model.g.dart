// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preauth_limits_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreauthLimitsResponseModel _$PreauthLimitsResponseModelFromJson(
  Map<String, dynamic> json,
) => PreauthLimitsResponseModel(
  data: PreauthLimitsModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PreauthLimitsResponseModelToJson(
  PreauthLimitsResponseModel instance,
) => <String, dynamic>{'data': instance.data};

PreauthLimitsModel _$PreauthLimitsModelFromJson(Map<String, dynamic> json) =>
    PreauthLimitsModel(
      currency: json['currency'] as String,
      defaultAmount: (json['default'] as num).toInt(),
    );

Map<String, dynamic> _$PreauthLimitsModelToJson(PreauthLimitsModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'default': instance.defaultAmount,
    };
