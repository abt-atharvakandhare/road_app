// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_factors_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaFactorModel _$MfaFactorModelFromJson(Map<String, dynamic> json) =>
    MfaFactorModel(
      id: json['id'] as String,
      type: $enumDecode(
        _$MfaMethodEnumMap,
        json['type'],
        unknownValue: MfaMethod.unknown,
      ),
      status: $enumDecode(
        _$MfaFactorStatusEnumMap,
        json['status'],
        unknownValue: MfaFactorStatus.unknown,
      ),
      hint: json['hint'] as String?,
      label: json['label'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      remainingCodes: (json['remainingCodes'] as num?)?.toInt(),
      rpId: json['rpId'] as String?,
    );

Map<String, dynamic> _$MfaFactorModelToJson(MfaFactorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MfaMethodEnumMap[instance.type]!,
      'status': _$MfaFactorStatusEnumMap[instance.status]!,
      'hint': instance.hint,
      'label': instance.label,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'remainingCodes': instance.remainingCodes,
      'rpId': instance.rpId,
    };

const _$MfaMethodEnumMap = {
  MfaMethod.passkey: 'passkey',
  MfaMethod.totp: 'totp',
  MfaMethod.sms: 'sms',
  MfaMethod.recoveryCode: 'recovery-code',
  MfaMethod.recoveryEmail: 'recovery-email',
  MfaMethod.unknown: 'unknown',
};

const _$MfaFactorStatusEnumMap = {
  MfaFactorStatus.pending: 'pending',
  MfaFactorStatus.active: 'active',
  MfaFactorStatus.disabled: 'disabled',
  MfaFactorStatus.unknown: 'unknown',
};

MfaFactorsModel _$MfaFactorsModelFromJson(
  Map<String, dynamic> json,
) => MfaFactorsModel(
  factors: (json['factors'] as List<dynamic>)
      .map((e) => MfaFactorModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  permittedMethods: (json['permittedMethods'] as List<dynamic>)
      .map(
        (e) =>
            $enumDecode(_$MfaMethodEnumMap, e, unknownValue: MfaMethod.unknown),
      )
      .toList(),
  mode: $enumDecode(_$MfaModeEnumMap, json['mode'], unknownValue: MfaMode.off),
);

Map<String, dynamic> _$MfaFactorsModelToJson(MfaFactorsModel instance) =>
    <String, dynamic>{
      'factors': instance.factors,
      'permittedMethods': instance.permittedMethods
          .map((e) => _$MfaMethodEnumMap[e]!)
          .toList(),
      'mode': _$MfaModeEnumMap[instance.mode]!,
    };

const _$MfaModeEnumMap = {
  MfaMode.off: 'off',
  MfaMode.encourage: 'encourage',
  MfaMode.enforce: 'enforce',
};

MfaEnrolledSmsFactorModel _$MfaEnrolledSmsFactorModelFromJson(
  Map<String, dynamic> json,
) => MfaEnrolledSmsFactorModel(
  id: json['id'] as String,
  hint: json['hint'] as String?,
  nextSendAfterSeconds: (json['nextSendAfterSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$MfaEnrolledSmsFactorModelToJson(
  MfaEnrolledSmsFactorModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'hint': instance.hint,
  'nextSendAfterSeconds': instance.nextSendAfterSeconds,
};

MfaRecoveryCodesModel _$MfaRecoveryCodesModelFromJson(
  Map<String, dynamic> json,
) => MfaRecoveryCodesModel(
  factorId: json['factorId'] as String,
  codes: (json['codes'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$MfaRecoveryCodesModelToJson(
  MfaRecoveryCodesModel instance,
) => <String, dynamic>{'factorId': instance.factorId, 'codes': instance.codes};
