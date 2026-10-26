// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  message: json['message'] as String,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  status: (json['status'] as num?)?.toInt(),
  defaultErrorMessage: json['defaultErrorMessage'] as bool? ?? false,
  details: (json['details'] as List<dynamic>?)
      ?.map((e) => ErrorDetails.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'statusCode': instance.statusCode,
  'status': instance.status,
  'defaultErrorMessage': instance.defaultErrorMessage,
  'details': instance.details,
};

ApiErrorDTO _$ApiErrorDTOFromJson(Map<String, dynamic> json) => ApiErrorDTO(
  responseDetail: json['responseDetail'] as String,
  responseCode: (json['responseCode'] as num?)?.toInt(),
  success: json['success'] as bool?,
);

Map<String, dynamic> _$ApiErrorDTOToJson(ApiErrorDTO instance) =>
    <String, dynamic>{
      'responseDetail': instance.responseDetail,
      'responseCode': instance.responseCode,
      'success': instance.success,
    };
