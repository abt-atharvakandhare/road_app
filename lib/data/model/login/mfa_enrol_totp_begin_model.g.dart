// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_enrol_totp_begin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaEnrolTotpBeginModel _$MfaEnrolTotpBeginModelFromJson(
  Map<String, dynamic> json,
) => MfaEnrolTotpBeginModel(
  factorId: json['factorId'] as String,
  otpauthUri: json['otpauthUri'] as String,
  secret: json['secret'] as String,
);

Map<String, dynamic> _$MfaEnrolTotpBeginModelToJson(
  MfaEnrolTotpBeginModel instance,
) => <String, dynamic>{
  'factorId': instance.factorId,
  'otpauthUri': instance.otpauthUri,
  'secret': instance.secret,
};
