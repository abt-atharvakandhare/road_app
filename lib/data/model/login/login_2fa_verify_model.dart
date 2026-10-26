import 'package:json_annotation/json_annotation.dart';

part 'login_2fa_verify_model.g.dart';

@JsonSerializable()
class Login2FaVerifyModel {
  Login2FaVerifyData data;

  Login2FaVerifyModel({required this.data});

  factory Login2FaVerifyModel.fromJson(Map<String, dynamic> json) => _$Login2FaVerifyModelFromJson(json);

  Map<String, dynamic> toJson() => _$Login2FaVerifyModelToJson(this);
}

@JsonSerializable()
class Login2FaVerifyData {
  String token;
  String? deviceToken;
  String? sessionRenewalToken;

  Login2FaVerifyData({required this.token, this.deviceToken, this.sessionRenewalToken});

  factory Login2FaVerifyData.fromJson(Map<String, dynamic> json) => _$Login2FaVerifyDataFromJson(json);

  Map<String, dynamic> toJson() => _$Login2FaVerifyDataToJson(this);
}
