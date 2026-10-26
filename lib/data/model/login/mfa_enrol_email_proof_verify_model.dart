import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';

part 'mfa_enrol_email_proof_verify_model.g.dart';

/// Response of `POST /1/auth/mfa/enrol/email-proof/verify` — the email proof
/// passed; these are the factor types the user may now enrol.
@JsonSerializable()
class MfaEnrolEmailProofVerifyModel {
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  List<MfaMethod> permittedMethods;

  MfaEnrolEmailProofVerifyModel({required this.permittedMethods});

  factory MfaEnrolEmailProofVerifyModel.fromJson(Map<String, dynamic> json) =>
      _$MfaEnrolEmailProofVerifyModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrolEmailProofVerifyModelToJson(this);
}
