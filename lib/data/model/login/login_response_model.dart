import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';

part 'login_response_model.g.dart';

/// The union of the login outcomes: a session ([token] set), the legacy MFA
/// challenge ([mfaToken] set), or one of the decision-engine holds ([mfa],
/// [mfaEnrolment] or [mfaVerifyEmail] set).
@JsonSerializable()
class LoginResponseModel {
  String? token;
  String? mfaMethod;
  bool? mfaRequired;
  String? mfaToken;
  String? mfaPhoneNumber;
  String? deviceToken;
  String? sessionRenewalToken;
  MfaPendingChallengeModel? mfa;
  MfaEnrolmentModel? mfaEnrolment;
  MfaVerifyEmailModel? mfaVerifyEmail;

  LoginResponseModel({
    this.token,
    this.mfaMethod,
    this.mfaRequired,
    this.mfaToken,
    this.mfaPhoneNumber,
    this.deviceToken,
    this.sessionRenewalToken,
    this.mfa,
    this.mfaEnrolment,
    this.mfaVerifyEmail,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

/// Decision-engine outcome: verify an existing factor. [pendingId] is the
/// single-use handle of the withheld sign-in (~10 min TTL).
@JsonSerializable()
class MfaPendingChallengeModel {
  String pendingId;
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  List<MfaMethod> methods;
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  MfaMethod? preferred;

  /// Whether the user holds recovery codes — gates the lost-factor fallback.
  /// Recovery is never listed in [methods].
  bool? canUseRecoveryCode;

  MfaPendingChallengeModel({
    required this.pendingId,
    required this.methods,
    this.preferred,
    this.canUseRecoveryCode,
  });

  factory MfaPendingChallengeModel.fromJson(Map<String, dynamic> json) => _$MfaPendingChallengeModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaPendingChallengeModelToJson(this);
}

/// Decision-engine outcome: enrol a first factor. [enrolId] is the single-use
/// handle of the withheld sign-in (~15 min TTL).
@JsonSerializable()
class MfaEnrolmentModel {
  String enrolId;
  @JsonKey(unknownEnumValue: MfaMode.enforce)
  MfaMode mode;
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  List<MfaMethod> permittedMethods;

  MfaEnrolmentModel({required this.enrolId, required this.mode, required this.permittedMethods});

  factory MfaEnrolmentModel.fromJson(Map<String, dynamic> json) => _$MfaEnrolmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrolmentModelToJson(this);
}

/// Decision-engine outcome: prove control of the account email before the
/// session is issued (no factor enrolled). Own handle namespace — this
/// [pendingId] is only valid on the `/1/auth/mfa/verify-email/*` endpoints.
@JsonSerializable()
class MfaVerifyEmailModel {
  String pendingId;

  MfaVerifyEmailModel({required this.pendingId});

  factory MfaVerifyEmailModel.fromJson(Map<String, dynamic> json) => _$MfaVerifyEmailModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaVerifyEmailModelToJson(this);
}
