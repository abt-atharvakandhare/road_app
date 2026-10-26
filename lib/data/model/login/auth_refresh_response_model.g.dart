// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_refresh_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRefreshResponseModel _$AuthRefreshResponseModelFromJson(
  Map<String, dynamic> json,
) => AuthRefreshResponseModel(
  token: json['token'] as String,
  deviceToken: json['deviceToken'] as String?,
);

Map<String, dynamic> _$AuthRefreshResponseModelToJson(
  AuthRefreshResponseModel instance,
) => <String, dynamic>{
  'token': instance.token,
  'deviceToken': instance.deviceToken,
};
