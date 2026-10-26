// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_individual_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupIndividualModel _$SignupIndividualModelFromJson(
  Map<String, dynamic> json,
) => SignupIndividualModel(
  email: json['email'] as String?,
  password: json['password'] as String?,
  contact: json['contact'] == null
      ? null
      : Contact.fromJson(json['contact'] as Map<String, dynamic>),
  newsletter: json['newsletter'] as bool?,
  acceptedTerms: json['acceptedTerms'] as bool?,
  acceptedPrivacy: json['acceptedPrivacy'] as bool?,
  countryCode: json['countryCode'] as String?,
  defaultLangCode: json['defaultLangCode'] as String?,
  timeZone: json['timeZone'] as String?,
  accountType: json['accountType'] as String?,
  journey: json['journey'] as String? ?? 'generic',
  platform: json['platform'] as String? ?? 'mobile',
);

Map<String, dynamic> _$SignupIndividualModelToJson(
  SignupIndividualModel instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'contact': instance.contact,
  'newsletter': instance.newsletter,
  'acceptedTerms': instance.acceptedTerms,
  'acceptedPrivacy': instance.acceptedPrivacy,
  'countryCode': instance.countryCode,
  'defaultLangCode': instance.defaultLangCode,
  'timeZone': instance.timeZone,
  'accountType': instance.accountType,
  'journey': instance.journey,
  'platform': instance.platform,
};

Billing _$BillingFromJson(Map<String, dynamic> json) => Billing(
  address: json['address'] as String?,
  addressLine2: json['addressLine2'] as String?,
  postalCode: json['postalCode'] as String?,
  city: json['city'] as String?,
  countryCode: json['countryCode'] as String?,
);

Map<String, dynamic> _$BillingToJson(Billing instance) => <String, dynamic>{
  'address': instance.address,
  'addressLine2': instance.addressLine2,
  'postalCode': instance.postalCode,
  'city': instance.city,
  'countryCode': instance.countryCode,
};

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phoneNo: json['phoneNo'] as String,
  phoneCountryCode: json['phoneCountryCode'] as String,
);

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNo': instance.phoneNo,
  'phoneCountryCode': instance.phoneCountryCode,
};
