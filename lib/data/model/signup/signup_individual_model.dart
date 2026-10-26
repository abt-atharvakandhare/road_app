import 'package:json_annotation/json_annotation.dart';
import 'package:road_mobile/data/model/signup/signup_screen_data.dart';

part 'signup_individual_model.g.dart';

@JsonSerializable()
class SignupIndividualModel {
  SignupIndividualModel({
    this.email,
    this.password,
    this.contact,
    this.newsletter,
    this.acceptedTerms,
    this.acceptedPrivacy,
    this.countryCode,
    this.defaultLangCode,
    this.timeZone,
    this.accountType,
    this.journey = 'generic',
    this.platform = 'mobile',
  });

  SignupIndividualModel.fromScreenData(
      SignupScreenData firstScreenData, this.defaultLangCode, this.timeZone, this.accountType)
      : email = firstScreenData.email,
        password = firstScreenData.password,
        contact = Contact(
            firstName: firstScreenData.firstName,
            lastName: firstScreenData.lastName,
            email: firstScreenData.email,
            phoneNo: firstScreenData.phoneNumber,
            phoneCountryCode: firstScreenData.phoneCountry.countryCode),
        newsletter = firstScreenData.iWantToReceiveNews,
        acceptedTerms = firstScreenData.acceptTos,
        acceptedPrivacy = firstScreenData.acceptProcessData,
        countryCode = firstScreenData.residenceCountry.countryCode,
        journey = 'generic',
        platform = 'mobile';

  final String? email;
  final String? password;
  final Contact? contact;
  final bool? newsletter;
  final bool? acceptedTerms;
  final bool? acceptedPrivacy;
  final String? countryCode;
  final String? defaultLangCode;
  final String? timeZone;
  final String? accountType;
  final String journey; // For tracking
  final String platform; // For tracking

  factory SignupIndividualModel.fromJson(Map<String, dynamic> json) => _$SignupIndividualModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupIndividualModelToJson(this);
}

@JsonSerializable()
class Billing {
  Billing({this.address, this.addressLine2, this.postalCode, this.city, this.countryCode});

  final String? address;
  final String? addressLine2;
  final String? postalCode;
  final String? city;
  final String? countryCode;

  factory Billing.fromJson(Map<String, dynamic> json) => _$BillingFromJson(json);

  Map<String, dynamic> toJson() => _$BillingToJson(this);
}

@JsonSerializable()
class Contact {
  Contact({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.phoneCountryCode,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String phoneCountryCode;

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}
