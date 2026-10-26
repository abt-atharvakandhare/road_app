// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupDataResponseModel _$SignupDataResponseModelFromJson(
  Map<String, dynamic> json,
) => SignupDataResponseModel(
  data: json['data'] == null
      ? null
      : SignupResponseModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SignupDataResponseModelToJson(
  SignupDataResponseModel instance,
) => <String, dynamic>{'data': instance.data};

SignupResponseModel _$SignupResponseModelFromJson(Map<String, dynamic> json) =>
    SignupResponseModel(
      userId: json['userId'] as String?,
      token: json['token'] as String?,
      deviceToken: json['deviceToken'] as String?,
    );

Map<String, dynamic> _$SignupResponseModelToJson(
  SignupResponseModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'token': instance.token,
  'deviceToken': instance.deviceToken,
};
