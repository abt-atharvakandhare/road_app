import 'package:json_annotation/json_annotation.dart';

part 'auth_renew_response_model.g.dart';

/// Response from `POST /1/auth/renew`.
///
/// Starts a new session via the biometric-gated session renewal token. The
/// renewal token is always rotated on use — store the new one and discard the
/// old.
@JsonSerializable()
class AuthRenewResponseModel {
  String token;
  String sessionRenewalToken;

  AuthRenewResponseModel({required this.token, required this.sessionRenewalToken});

  factory AuthRenewResponseModel.fromJson(Map<String, dynamic> json) => _$AuthRenewResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRenewResponseModelToJson(this);
}
