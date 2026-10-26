import 'package:json_annotation/json_annotation.dart';

part 'mfa_code_sent_model.g.dart';

/// Response of the MFA `…/send` endpoints (`verify-email/send`,
/// `enrol/email-proof/send`): a code went out; disable the resend control
/// for [nextSendAfterSeconds].
@JsonSerializable()
class MfaCodeSentModel {
  int? nextSendAfterSeconds;

  MfaCodeSentModel({this.nextSendAfterSeconds});

  factory MfaCodeSentModel.fromJson(Map<String, dynamic> json) => _$MfaCodeSentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaCodeSentModelToJson(this);
}
