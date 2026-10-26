import 'package:country_picker/country_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_screen_data.freezed.dart';

@freezed
abstract class SignupScreenData with _$SignupScreenData {
  factory SignupScreenData({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
    required Country residenceCountry,
    required Country phoneCountry,
    required bool acceptTos,
    required bool acceptProcessData,
    required bool iWantToReceiveNews,
  }) = _SignupScreenData;
}
