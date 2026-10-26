// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_and_store_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleSuccessResponseModel _$SimpleSuccessResponseModelFromJson(
  Map<String, dynamic> json,
) => SimpleSuccessResponseModel(
  data: SimpleSuccessResponseDataModel.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SimpleSuccessResponseModelToJson(
  SimpleSuccessResponseModel instance,
) => <String, dynamic>{'data': instance.data};

SimpleSuccessResponseDataModel _$SimpleSuccessResponseDataModelFromJson(
  Map<String, dynamic> json,
) => SimpleSuccessResponseDataModel(success: json['success'] as bool);

Map<String, dynamic> _$SimpleSuccessResponseDataModelToJson(
  SimpleSuccessResponseDataModel instance,
) => <String, dynamic>{'success': instance.success};
