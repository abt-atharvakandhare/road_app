import 'package:json_annotation/json_annotation.dart';

part 'mfa_session_model.g.dart';

/// The session issued by every MFA-completing call (verify, enrol activation,
/// verify-email, skip). Same shape as a plain login session.
@JsonSerializable()
class MfaSessionModel {
  String token;
  String? deviceToken;
  String? sessionRenewalToken;

  MfaSessionModel({required this.token, this.deviceToken, this.sessionRenewalToken});

  factory MfaSessionModel.fromJson(Map<String, dynamic> json) => _$MfaSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaSessionModelToJson(this);
}
