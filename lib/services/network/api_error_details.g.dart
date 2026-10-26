// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetails _$ErrorDetailsFromJson(Map<String, dynamic> json) => ErrorDetails(
  message: json['message'] as String?,
  code: json['code'] as String?,
  retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$ErrorDetailsToJson(ErrorDetails instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'retryAfterSeconds': instance.retryAfterSeconds,
    };
