// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_enrol_email_proof_verify_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaEnrolEmailProofVerifyModel _$MfaEnrolEmailProofVerifyModelFromJson(
  Map<String, dynamic> json,
) => MfaEnrolEmailProofVerifyModel(
  permittedMethods: (json['permittedMethods'] as List<dynamic>)
      .map(
        (e) =>
            $enumDecode(_$MfaMethodEnumMap, e, unknownValue: MfaMethod.unknown),
      )
      .toList(),
);

Map<String, dynamic> _$MfaEnrolEmailProofVerifyModelToJson(
  MfaEnrolEmailProofVerifyModel instance,
) => <String, dynamic>{
  'permittedMethods': instance.permittedMethods
      .map((e) => _$MfaMethodEnumMap[e]!)
      .toList(),
};

const _$MfaMethodEnumMap = {
  MfaMethod.passkey: 'passkey',
  MfaMethod.totp: 'totp',
  MfaMethod.sms: 'sms',
  MfaMethod.recoveryCode: 'recovery-code',
  MfaMethod.recoveryEmail: 'recovery-email',
  MfaMethod.unknown: 'unknown',
};
