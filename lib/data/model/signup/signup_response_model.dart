import 'package:json_annotation/json_annotation.dart';

part 'signup_response_model.g.dart';

@JsonSerializable()
class SignupDataResponseModel {
  final SignupResponseModel? data;
  SignupDataResponseModel({this.data});

  factory SignupDataResponseModel.fromJson(Map<String, dynamic> json) => _$SignupDataResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupDataResponseModelToJson(this);
}

/// `POST /1/signup` issues a session directly: registration itself is the
/// proof of identity, so [token] signs the new user in without a follow-up
/// password login (which the MFA decision engine could otherwise interpose).
@JsonSerializable()
class SignupResponseModel {
  final String? userId;
  final String? token;
  final String? deviceToken;
  SignupResponseModel({this.userId, this.token, this.deviceToken});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) => _$SignupResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupResponseModelToJson(this);
}
