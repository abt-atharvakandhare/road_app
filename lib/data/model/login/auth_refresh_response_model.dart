import 'package:json_annotation/json_annotation.dart';

part 'auth_refresh_response_model.g.dart';

/// Response from `POST /1/auth/refresh`.
///
/// The session is unchanged. The `token` always rotates; `deviceToken` only
/// appears when the server issued a new device identity (rare on refresh).
@JsonSerializable()
class AuthRefreshResponseModel {
  String token;
  String? deviceToken;

  AuthRefreshResponseModel({required this.token, this.deviceToken});

  factory AuthRefreshResponseModel.fromJson(Map<String, dynamic> json) => _$AuthRefreshResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRefreshResponseModelToJson(this);
}
