// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginUserRequest _$LoginUserRequestFromJson(Map<String, dynamic> json) =>
    LoginUserRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      requestDeviceRefresh: json['requestDeviceRefresh'] as bool? ?? true,
    );

Map<String, dynamic> _$LoginUserRequestToJson(LoginUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'requestDeviceRefresh': instance.requestDeviceRefresh,
    };
