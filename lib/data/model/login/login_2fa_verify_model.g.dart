// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_2fa_verify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login2FaVerifyModel _$Login2FaVerifyModelFromJson(Map<String, dynamic> json) =>
    Login2FaVerifyModel(
      data: Login2FaVerifyData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Login2FaVerifyModelToJson(
  Login2FaVerifyModel instance,
) => <String, dynamic>{'data': instance.data};

Login2FaVerifyData _$Login2FaVerifyDataFromJson(Map<String, dynamic> json) =>
    Login2FaVerifyData(
      token: json['token'] as String,
      deviceToken: json['deviceToken'] as String?,
      sessionRenewalToken: json['sessionRenewalToken'] as String?,
    );

Map<String, dynamic> _$Login2FaVerifyDataToJson(Login2FaVerifyData instance) =>
    <String, dynamic>{
      'token': instance.token,
      'deviceToken': instance.deviceToken,
      'sessionRenewalToken': instance.sessionRenewalToken,
    };
