// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_enrol_sms_begin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaEnrolSmsBeginModel _$MfaEnrolSmsBeginModelFromJson(
  Map<String, dynamic> json,
) => MfaEnrolSmsBeginModel(
  kind: json['kind'] as String?,
  factorId: json['factorId'] as String?,
  hint: json['hint'] as String?,
  nextSendAfterSeconds: (json['nextSendAfterSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$MfaEnrolSmsBeginModelToJson(
  MfaEnrolSmsBeginModel instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'factorId': instance.factorId,
  'hint': instance.hint,
  'nextSendAfterSeconds': instance.nextSendAfterSeconds,
};
