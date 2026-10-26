// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaSessionModel _$MfaSessionModelFromJson(Map<String, dynamic> json) =>
    MfaSessionModel(
      token: json['token'] as String,
      deviceToken: json['deviceToken'] as String?,
      sessionRenewalToken: json['sessionRenewalToken'] as String?,
    );

Map<String, dynamic> _$MfaSessionModelToJson(MfaSessionModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'deviceToken': instance.deviceToken,
      'sessionRenewalToken': instance.sessionRenewalToken,
    };
