// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_code_sent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaCodeSentModel _$MfaCodeSentModelFromJson(Map<String, dynamic> json) =>
    MfaCodeSentModel(
      nextSendAfterSeconds: (json['nextSendAfterSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MfaCodeSentModelToJson(MfaCodeSentModel instance) =>
    <String, dynamic>{'nextSendAfterSeconds': instance.nextSendAfterSeconds};
