import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_countries_model.g.dart';

@JsonSerializable()
class SignupCountriesResponseModel {
  SignupCountriesResponseModel({
    required this.countryCodes,
  });

  final List<String> countryCodes;

  factory SignupCountriesResponseModel.fromJson(Map<String, dynamic> json) => _$SignupCountriesResponseModelFromJson({
        'countryCodes': json['data'],
      });

  Map<String, dynamic> toJson() => _$SignupCountriesResponseModelToJson(this);
}
