import 'package:json_annotation/json_annotation.dart';

part 'mfa_enrol_sms_begin_model.g.dart';

/// Response of `POST /1/auth/mfa/enrol/sms/begin`: a code was texted to the
/// masked [hint] number — verify it with [factorId] via `enrol/sms/verify`,
/// which issues the session. An already-verified phone still does the code
/// round-trip. Calling begin again is the resend: while a code is in flight
/// it returns the same staged factor without sending; [nextSendAfterSeconds]
/// says how long to disable the resend control.
@JsonSerializable()
class MfaEnrolSmsBeginModel {
  String? kind;
  String? factorId;
  String? hint;
  int? nextSendAfterSeconds;

  MfaEnrolSmsBeginModel({
    this.kind,
    this.factorId,
    this.hint,
    this.nextSendAfterSeconds,
  });

  factory MfaEnrolSmsBeginModel.fromJson(Map<String, dynamic> json) => _$MfaEnrolSmsBeginModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnrolSmsBeginModelToJson(this);
}
