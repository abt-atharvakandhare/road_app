// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      token: json['token'] as String?,
      mfaMethod: json['mfaMethod'] as String?,
      mfaRequired: json['mfaRequired'] as bool?,
      mfaToken: json['mfaToken'] as String?,
      mfaPhoneNumber: json['mfaPhoneNumber'] as String?,
      deviceToken: json['deviceToken'] as String?,
      sessionRenewalToken: json['sessionRenewalToken'] as String?,
      mfa: json['mfa'] == null
          ? null
          : MfaPendingChallengeModel.fromJson(
              json['mfa'] as Map<String, dynamic>,
            ),
      mfaEnrolment: json['mfaEnrolment'] == null
          ? null
          : MfaEnrolmentModel.fromJson(
              json['mfaEnrolment'] as Map<String, dynamic>,
            ),
      mfaVerifyEmail: json['mfaVerifyEmail'] == null
          ? null
          : MfaVerifyEmailModel.fromJson(
              json['mfaVerifyEmail'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'mfaMethod': instance.mfaMethod,
      'mfaRequired': instance.mfaRequired,
      'mfaToken': instance.mfaToken,
      'mfaPhoneNumber': instance.mfaPhoneNumber,
      'deviceToken': instance.deviceToken,
      'sessionRenewalToken': instance.sessionRenewalToken,
      'mfa': instance.mfa,
      'mfaEnrolment': instance.mfaEnrolment,
      'mfaVerifyEmail': instance.mfaVerifyEmail,
    };

MfaPendingChallengeModel _$MfaPendingChallengeModelFromJson(
  Map<String, dynamic> json,
) => MfaPendingChallengeModel(
  pendingId: json['pendingId'] as String,
  methods: (json['methods'] as List<dynamic>)
      .map(
        (e) =>
            $enumDecode(_$MfaMethodEnumMap, e, unknownValue: MfaMethod.unknown),
      )
      .toList(),
  preferred: $enumDecodeNullable(
    _$MfaMethodEnumMap,
    json['preferred'],
    unknownValue: MfaMethod.unknown,
  ),
  canUseRecoveryCode: json['canUseRecoveryCode'] as bool?,
);

Map<String, dynamic> _$MfaPendingChallengeModelToJson(
  MfaPendingChallengeModel instance,
) => <String, dynamic>{
  'pendingId': instance.pendingId,
  'methods': instance.methods.map((e) => _$MfaMethodEnumMap[e]!).toList(),
  'preferred': _$MfaMethodEnumMap[instance.preferred],
  'canUseRecoveryCode': instance.canUseRecoveryCode,
};

const _$MfaMethodEnumMap = {
  MfaMethod.passkey: 'passkey',
  MfaMethod.totp: 'totp',
  MfaMethod.sms: 'sms',
  MfaMethod.recoveryCode: 'recovery-code',
  MfaMethod.recoveryEmail: 'recovery-email',
  MfaMethod.unknown: 'unknown',
};

MfaEnrolmentModel _$MfaEnrolmentModelFromJson(Map<String, dynamic> json) =>
    MfaEnrolmentModel(
      enrolId: json['enrolId'] as String,
      mode: $enumDecode(
        _$MfaModeEnumMap,
        json['mode'],
        unknownValue: MfaMode.enforce,
      ),
      permittedMethods: (json['permittedMethods'] as List<dynamic>)
          .map(
            (e) => $enumDecode(
              _$MfaMethodEnumMap,
              e,
              unknownValue: MfaMethod.unknown,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$MfaEnrolmentModelToJson(MfaEnrolmentModel instance) =>
    <String, dynamic>{
      'enrolId': instance.enrolId,
      'mode': _$MfaModeEnumMap[instance.mode]!,
      'permittedMethods': instance.permittedMethods
          .map((e) => _$MfaMethodEnumMap[e]!)
          .toList(),
    };

const _$MfaModeEnumMap = {
  MfaMode.off: 'off',
  MfaMode.encourage: 'encourage',
  MfaMode.enforce: 'enforce',
};

MfaVerifyEmailModel _$MfaVerifyEmailModelFromJson(Map<String, dynamic> json) =>
    MfaVerifyEmailModel(pendingId: json['pendingId'] as String);

Map<String, dynamic> _$MfaVerifyEmailModelToJson(
  MfaVerifyEmailModel instance,
) => <String, dynamic>{'pendingId': instance.pendingId};
