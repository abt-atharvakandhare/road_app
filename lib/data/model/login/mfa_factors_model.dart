import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';

part 'mfa_factors_model.g.dart';

/// Lifecycle of an enrolled factor. [unknown] absorbs values this app version
/// doesn't know — treat them as not usable.
enum MfaFactorStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('disabled')
  disabled,
  unknown,
}

/// Non-secret view of one enrolled factor (`GET /1/users/me/mfa-factors`).
/// Factor types this app doesn't model (push, newer backend additions) parse
/// as [MfaMethod.unknown].
@JsonSerializable()
class MfaFactorModel {
  String id;
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  MfaMethod type;
  @JsonKey(unknownEnumValue: MfaFactorStatus.unknown)
  MfaFactorStatus status;
  String? hint;
  String? label;
  DateTime? createdAt;
  DateTime? lastUsedAt;

  /// Codes left in the set; recovery-code factors only.
  int? remainingCodes;

  /// WebAuthn relying-party ID; passkey factors only.
  String? rpId;

  MfaFactorModel({
    required this.id,
    required this.type,
    required this.status,
    this.hint,
    this.label,
    this.createdAt,
    this.lastUsedAt,
    this.remainingCodes,
    this.rpId,
  });

  /// Whether this factor can satisfy a sign-in challenge. Recovery codes and
  /// the recovery email are ways back in, never factors (spec §19).
  bool get isActiveLoginFactor =>
      status == MfaFactorStatus.active &&
      (type == MfaMethod.passkey || type == MfaMethod.totp || type == MfaMethod.sms);

  factory MfaFactorModel.fromJson(Map<String, dynamic> json) => _$MfaFactorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaFactorModelToJson(this);
}

/// Self-service MFA listing: enrolled factors plus what the Provider policy
/// permits. Drives the signup "Secure Sign-in" step (and, later, settings
/// factor management). Unknown [mode] parses as [MfaMode.off] — on this
/// surface the safe reading is "don't offer the step".
@JsonSerializable()
class MfaFactorsModel {
  List<MfaFactorModel> factors;
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  List<MfaMethod> permittedMethods;
  @JsonKey(unknownEnumValue: MfaMode.off)
  MfaMode mode;

  MfaFactorsModel({required this.factors, required this.permittedMethods, required this.mode});

  bool get hasActiveLoginFactor => factors.any((factor) => factor.isActiveLoginFactor);

  factory MfaFactorsModel.fromJson(Map<String, dynamic> json) => _$MfaFactorsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaFactorsModelToJson(this);
}

/// Response of `POST /1/users/me/mfa-factors/sms`: the staged factor plus how
/// long until another code may be requested (the send's resend spacing — it
/// belongs to the send, not the factor, so it only appears here).
@JsonSerializable()
class MfaEnrolledSmsFactorModel {
  String id;
  String? hint;
  int? nextSendAfterSeconds;

  MfaEnrolledSmsFactorModel({required this.id, this.hint, this.nextSendAfterSeconds});

  factory MfaEnrolledSmsFactorModel.fromJson(Map<String, dynamic> json) => _$MfaEnrolledSmsFactorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrolledSmsFactorModelToJson(this);
}

/// Response of `POST /1/users/me/mfa-factors/recovery-codes`: the recovery-code
/// factor plus its plaintext codes — shown exactly once; a new set replaces any
/// existing one immediately.
@JsonSerializable()
class MfaRecoveryCodesModel {
  String factorId;
  List<String> codes;

  MfaRecoveryCodesModel({required this.factorId, required this.codes});

  factory MfaRecoveryCodesModel.fromJson(Map<String, dynamic> json) => _$MfaRecoveryCodesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaRecoveryCodesModelToJson(this);
}
