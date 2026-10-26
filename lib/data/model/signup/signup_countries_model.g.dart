// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_countries_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupCountriesResponseModel _$SignupCountriesResponseModelFromJson(
  Map<String, dynamic> json,
) => SignupCountriesResponseModel(
  countryCodes: (json['countryCodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$SignupCountriesResponseModelToJson(
  SignupCountriesResponseModel instance,
) => <String, dynamic>{'countryCodes': instance.countryCodes};
