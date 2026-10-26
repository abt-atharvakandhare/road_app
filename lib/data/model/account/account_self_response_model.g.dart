// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_self_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountSelfResponseModel _$AccountSelfResponseModelFromJson(
  Map<String, dynamic> json,
) => AccountSelfResponseModel(
  AccountSelfModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AccountSelfResponseModelToJson(
  AccountSelfResponseModel instance,
) => <String, dynamic>{'data': instance.data};

AccountSelfModel _$AccountSelfModelFromJson(Map<String, dynamic> json) =>
    AccountSelfModel(
      json['id'] as String,
      json['billing'] == null
          ? null
          : BillingModel.fromJson(json['billing'] as Map<String, dynamic>),
      json['contact'] == null
          ? null
          : ContactModel.fromJson(json['contact'] as Map<String, dynamic>),
      json['billingCurrency'] as String?,
    );

Map<String, dynamic> _$AccountSelfModelToJson(AccountSelfModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billing': instance.billing,
      'contact': instance.contact,
      'billingCurrency': instance.billingCurrency,
    };

BillingModel _$BillingModelFromJson(Map<String, dynamic> json) => BillingModel(
  json['countryCode'] as String?,
  json['address'] as String?,
  json['addressLine2'] as String?,
  json['postalCode'] as String?,
  json['city'] as String?,
);

Map<String, dynamic> _$BillingModelToJson(BillingModel instance) =>
    <String, dynamic>{
      'countryCode': instance.countryCode,
      'address': instance.address,
      'addressLine2': instance.addressLine2,
      'postalCode': instance.postalCode,
      'city': instance.city,
    };

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) => ContactModel(
  json['firstName'] as String?,
  json['lastName'] as String?,
  json['phoneNo'] as String?,
  json['phoneCountryCode'] as String?,
);

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNo': instance.phoneNo,
      'phoneCountryCode': instance.phoneCountryCode,
    };
