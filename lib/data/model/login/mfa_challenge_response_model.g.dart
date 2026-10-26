// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_challenge_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaChallengeResponseModel _$MfaChallengeResponseModelFromJson(
  Map<String, dynamic> json,
) => MfaChallengeResponseModel(
  type: $enumDecodeNullable(
    _$MfaMethodEnumMap,
    json['type'],
    unknownValue: MfaMethod.unknown,
  ),
  hint: json['hint'] as String?,
  nextSendAfterSeconds: (json['nextSendAfterSeconds'] as num?)?.toInt(),
  ceremonyId: json['ceremonyId'] as String?,
  options: json['options'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MfaChallengeResponseModelToJson(
  MfaChallengeResponseModel instance,
) => <String, dynamic>{
  'type': _$MfaMethodEnumMap[instance.type],
  'hint': instance.hint,
  'nextSendAfterSeconds': instance.nextSendAfterSeconds,
  'ceremonyId': instance.ceremonyId,
  'options': instance.options,
};

const _$MfaMethodEnumMap = {
  MfaMethod.passkey: 'passkey',
  MfaMethod.totp: 'totp',
  MfaMethod.sms: 'sms',
  MfaMethod.recoveryCode: 'recovery-code',
  MfaMethod.recoveryEmail: 'recovery-email',
  MfaMethod.unknown: 'unknown',
};
