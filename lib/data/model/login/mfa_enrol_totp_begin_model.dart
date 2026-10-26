import 'package:json_annotation/json_annotation.dart';

part 'mfa_enrol_totp_begin_model.g.dart';

/// Response of `POST /1/auth/mfa/enrol/totp/begin`. [factorId] must be echoed
/// on the activate call; [otpauthUri] renders as a QR, [secret] as the
/// manual-entry key.
@JsonSerializable()
class MfaEnrolTotpBeginModel {
  String factorId;
  String otpauthUri;
  String secret;

  MfaEnrolTotpBeginModel({required this.factorId, required this.otpauthUri, required this.secret});

  factory MfaEnrolTotpBeginModel.fromJson(Map<String, dynamic> json) => _$MfaEnrolTotpBeginModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrolTotpBeginModelToJson(this);
}
