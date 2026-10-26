import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';

part 'mfa_challenge_response_model.g.dart';

/// Response of `POST /1/auth/mfa/challenge` and
/// `POST /1/auth/step-up/challenge` (arming a factor).
///
/// SMS arming texts the code and returns a masked-number [hint] plus
/// [nextSendAfterSeconds] (disable the resend control for that long); TOTP
/// arming returns just the type. Passkey arming begins a fresh single-use
/// WebAuthn ceremony: [ceremonyId] is echoed back on verify and [options] is
/// the request-options JSON handed verbatim to the platform authenticator
/// (WebAuthn shapes are deliberately not modelled).
@JsonSerializable()
class MfaChallengeResponseModel {
  @JsonKey(unknownEnumValue: MfaMethod.unknown)
  MfaMethod? type;
  String? hint;
  int? nextSendAfterSeconds;
  String? ceremonyId;
  Map<String, dynamic>? options;

  MfaChallengeResponseModel({this.type, this.hint, this.nextSendAfterSeconds, this.ceremonyId, this.options});

  factory MfaChallengeResponseModel.fromJson(Map<String, dynamic> json) => _$MfaChallengeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MfaChallengeResponseModelToJson(this);
}
