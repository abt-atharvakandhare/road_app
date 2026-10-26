import 'package:json_annotation/json_annotation.dart';

part 'login_user_request.g.dart';

@JsonSerializable()
class LoginUserRequest {
  String email;
  String password;
  bool requestDeviceRefresh;

  LoginUserRequest({
    required this.email,
    required this.password,
    this.requestDeviceRefresh = true,
  });

  factory LoginUserRequest.fromJson(Map<String, dynamic> json) => _$LoginUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserRequestToJson(this);
}
