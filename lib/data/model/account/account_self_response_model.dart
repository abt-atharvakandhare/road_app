import 'package:json_annotation/json_annotation.dart';

part 'account_self_response_model.g.dart';

@JsonSerializable()
class AccountSelfResponseModel {
  final AccountSelfModel data;

  AccountSelfResponseModel(this.data);

  factory AccountSelfResponseModel.fromJson(Map<String, dynamic> json) => _$AccountSelfResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSelfResponseModelToJson(this);
}

@JsonSerializable()
class AccountSelfModel {
  final String id;
  final BillingModel? billing;
  final ContactModel? contact;
  final String? billingCurrency;

  AccountSelfModel(this.id, this.billing, this.contact, this.billingCurrency);

  factory AccountSelfModel.fromJson(Map<String, dynamic> json) => _$AccountSelfModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSelfModelToJson(this);
}

@JsonSerializable()
class BillingModel {
  final String? countryCode;
  final String? address;
  final String? addressLine2;
  final String? postalCode;
  final String? city;

  BillingModel(this.countryCode, this.address, this.addressLine2, this.postalCode, this.city);

  factory BillingModel.fromJson(Map<String, dynamic> json) => _$BillingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillingModelToJson(this);
}

@JsonSerializable()
class ContactModel {
  final String? firstName;
  final String? lastName;
  final String? phoneNo;
  final String? phoneCountryCode;

  ContactModel(this.firstName, this.lastName, this.phoneNo, this.phoneCountryCode);

  factory ContactModel.fromJson(Map<String, dynamic> json) => _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
}
