// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_renew_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRenewResponseModel _$AuthRenewResponseModelFromJson(
  Map<String, dynamic> json,
) => AuthRenewResponseModel(
  token: json['token'] as String,
  sessionRenewalToken: json['sessionRenewalToken'] as String,
);

Map<String, dynamic> _$AuthRenewResponseModelToJson(
  AuthRenewResponseModel instance,
) => <String, dynamic>{
  'token': instance.token,
  'sessionRenewalToken': instance.sessionRenewalToken,
};
