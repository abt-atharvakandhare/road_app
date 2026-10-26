import 'package:equatable/equatable.dart';
import 'package:road_mobile/data/model/account/account_self_response_model.dart';
import 'package:road_mobile/data/model/mobile_features/mobile_user_summary_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Flat hierarchy of needed fields - toMap() is used to pre-populate CC entry details
class AccountDetailsModel extends Equatable {
  // Account details
  final String accountId;
  final String name;
  final String email;

  final String? countryCode;
  final String? billingCurrency;
  final String? address;
  final String? addressLine2;
  final String? postalCode;
  final String? city;

  final String? firstName;
  final String? lastName;
  final String? phoneNo;
  final String? phoneCountryCode;

  // User details
  final String? userId;
  final String? mfaMethod;

  // Feature flags
  final bool hasCreditCard;
  final bool hasRfidCard;
  final bool canAddCreditCard;

  // Supported fields
  final String? customDomain;
  final String? termsOfServiceUrl;
  final String? privacyUrl;
  final String? helpAndSupportUrl;
  final String? aboutUsUrl;

  final bool emailVerificationEnabled;
  final bool mobileNumberVerificationEnabled;
  final bool isEmailVerified;
  final bool isMobileNumberVerified;

  // Remote session party IDs for charging station searches
  final List<String> remoteSessionEnabledPartyIds;

  static const idKey = 'id';
  static const emailKey = 'email';
  static const nameKey = 'name';
  static const countryCodeKey = 'countryCode';
  static const billingCurrencyKey = 'billingCurrency';
  static const addressKey = 'address';
  static const addressLine2Key = 'addressLine2';
  static const postalCodeKey = 'postalCode';
  static const cityKey = 'city';
  static const firstNameKey = 'firstName';
  static const lastNameKey = 'lastName';
  static const phoneNoKey = 'phoneNo';
  static const phoneCountryCodeKey = 'phoneCountryCode';
  static const userIdKey = 'userId';
  static const mfaMethodKey = 'mfaMethod';
  static const hasCreditCardKey = 'hasCreditCard';
  static const hasRfidCardKey = 'hasRfidCard';
  static const canAddCreditCardKey = 'canAddCreditCard';
  static const customDomainKey = 'customDomain';
  static const termsOfServiceUrlKey = 'termsOfServiceUrl';
  static const privacyUrlKey = 'privacyUrl';
  static const helpAndSupportUrlKey = 'helpAndSupportUrl';
  static const aboutUsUrlKey = 'aboutUsUrl';
  static const emailVerificationEnabledKey = 'emailVerificationEnabled';
  static const mobileNumberVerificationEnabledKey = 'mobileNumberVerificationEnabled';
  static const isEmailVerifiedKey = 'isEmailVerified';
  static const isMobileNumberVerifiedKey = 'isMobileNumberVerified';
  static const remoteSessionEnabledPartyIdsKey = 'remoteSessionEnabledPartyIds';

  const AccountDetailsModel({
    required this.accountId,
    required this.name,
    required this.email,
    this.countryCode,
    this.billingCurrency,
    this.address,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.firstName,
    this.lastName,
    this.phoneNo,
    this.phoneCountryCode,
    this.userId,
    this.mfaMethod,
    required this.hasCreditCard,
    required this.hasRfidCard,
    required this.canAddCreditCard,
    this.customDomain,
    this.termsOfServiceUrl,
    this.privacyUrl,
    this.helpAndSupportUrl,
    this.aboutUsUrl,
    required this.emailVerificationEnabled,
    required this.mobileNumberVerificationEnabled,
    required this.isEmailVerified,
    required this.isMobileNumberVerified,
    required this.remoteSessionEnabledPartyIds,
  });

  static AccountDetailsModel? fromSharedPrefs(SharedPreferences prefs) {
    String? id = prefs.getString(idKey);
    String? name = prefs.getString(nameKey);
    String? email = prefs.getString(emailKey);
    if (id == null || name == null || email == null) {
      return null;
    }

    return AccountDetailsModel(
      accountId: id,
      name: name,
      email: email,
      countryCode: prefs.getString(countryCodeKey),
      billingCurrency: prefs.getString(billingCurrencyKey),
      address: prefs.getString(addressKey),
      addressLine2: prefs.getString(addressLine2Key),
      postalCode: prefs.getString(postalCodeKey),
      city: prefs.getString(cityKey),
      firstName: prefs.getString(firstNameKey),
      lastName: prefs.getString(lastNameKey),
      phoneNo: prefs.getString(phoneNoKey),
      phoneCountryCode: prefs.getString(phoneCountryCodeKey),
      userId: prefs.getString(userIdKey),
      mfaMethod: prefs.getString(mfaMethodKey),
      hasCreditCard: prefs.getBool(hasCreditCardKey) ?? false,
      hasRfidCard: prefs.getBool(hasRfidCardKey) ?? false,
      canAddCreditCard: prefs.getBool(canAddCreditCardKey) ?? false,
      customDomain: prefs.getString(customDomainKey),
      termsOfServiceUrl: prefs.getString(termsOfServiceUrlKey),
      privacyUrl: prefs.getString(privacyUrlKey),
      helpAndSupportUrl: prefs.getString(helpAndSupportUrlKey),
      aboutUsUrl: prefs.getString(aboutUsUrlKey),
      emailVerificationEnabled: prefs.getBool(emailVerificationEnabledKey) ?? false,
      mobileNumberVerificationEnabled: prefs.getBool(mobileNumberVerificationEnabledKey) ?? false,
      isEmailVerified: prefs.getBool(isEmailVerifiedKey) ?? false,
      isMobileNumberVerified: prefs.getBool(isMobileNumberVerifiedKey) ?? false,
      remoteSessionEnabledPartyIds: prefs.getStringList(remoteSessionEnabledPartyIdsKey) ?? ['EFL'],
    );
  }

  static AccountDetailsModel fromAccountSelfModel(
    String loginEmail,
    AccountSelfModel accountSelfModel,
    ProfileResponseModel profileResponseModel,
    MobileUserSummaryModel? mobileUserSummaryModel,
    ProviderResponseModel? providerResponseModel,
  ) {
    final creditCardCount = mobileUserSummaryModel?.totalPaymentInstrumentsByIntent?.mspRemoteSession;
    final rfidCardCount = mobileUserSummaryModel?.totalMspCards;

    final defaultFeatureState = mobileUserSummaryModel != null;

    return AccountDetailsModel(
      accountId: accountSelfModel.id,
      name: profileResponseModel.data.name,
      email: loginEmail,
      countryCode: accountSelfModel.billing?.countryCode,
      billingCurrency: accountSelfModel.billingCurrency,
      address: accountSelfModel.billing?.address,
      addressLine2: accountSelfModel.billing?.addressLine2,
      postalCode: accountSelfModel.billing?.postalCode,
      city: accountSelfModel.billing?.city,
      firstName: profileResponseModel.data.contact?.firstName ?? accountSelfModel.contact?.firstName,
      lastName: profileResponseModel.data.contact?.lastName ?? accountSelfModel.contact?.lastName,
      phoneNo: profileResponseModel.data.contact?.phoneNo ?? accountSelfModel.contact?.phoneNo,
      phoneCountryCode:
          profileResponseModel.data.contact?.phoneCountryCode ?? accountSelfModel.contact?.phoneCountryCode,
      userId: profileResponseModel.data.id,
      mfaMethod: profileResponseModel.data.mfaMethod,
      hasCreditCard: creditCardCount != null ? creditCardCount > 0 : defaultFeatureState,
      hasRfidCard: rfidCardCount != null ? rfidCardCount > 0 : defaultFeatureState,
      canAddCreditCard: mobileUserSummaryModel?.canAddPaymentInstruments ?? defaultFeatureState,
      customDomain: providerResponseModel?.customDomain,
      termsOfServiceUrl: providerResponseModel?.tosUrl,
      privacyUrl: providerResponseModel?.privacyUrl,
      helpAndSupportUrl: providerResponseModel?.supportUrl ?? providerResponseModel?.csuiSupportUrl,
      aboutUsUrl: providerResponseModel?.csuiAboutUrl,
      emailVerificationEnabled: providerResponseModel?.enableVerifications?.contains('email') ?? false,
      mobileNumberVerificationEnabled: providerResponseModel?.enableVerifications?.contains('phone') ?? false,
      isEmailVerified: profileResponseModel.data.emailVerifiedAt != null,
      isMobileNumberVerified: profileResponseModel.data.contact?.phoneNoVerifiedAt != null,
      remoteSessionEnabledPartyIds: mobileUserSummaryModel?.remoteSessionEnabledPartyIds ?? ['EFL'],
    );
  }

  void saveToSharedPrefs(SharedPreferences prefs) {
    prefs.setString(idKey, accountId);
    prefs.setString(nameKey, name);
    prefs.setString(emailKey, email);
    if (countryCode != null) prefs.setString(countryCodeKey, countryCode!);
    if (billingCurrency != null) prefs.setString(billingCurrencyKey, billingCurrency!);
    if (address != null) prefs.setString(addressKey, address!);
    if (addressLine2 != null) prefs.setString(addressLine2Key, addressLine2!);
    if (postalCode != null) prefs.setString(postalCodeKey, postalCode!);
    if (city != null) prefs.setString(cityKey, city!);
    if (firstName != null) prefs.setString(firstNameKey, firstName!);
    if (lastName != null) prefs.setString(lastNameKey, lastName!);
    if (phoneNo != null) prefs.setString(phoneNoKey, phoneNo!);
    if (phoneCountryCode != null) prefs.setString(phoneCountryCodeKey, phoneCountryCode!);
    if (userId != null) prefs.setString(userIdKey, userId!);
    if (mfaMethod != null) prefs.setString(mfaMethodKey, mfaMethod!);
    prefs.setBool(hasCreditCardKey, hasCreditCard);
    prefs.setBool(hasRfidCardKey, hasRfidCard);
    prefs.setBool(canAddCreditCardKey, canAddCreditCard);
    if (customDomain != null) prefs.setString(customDomainKey, customDomain!);
    if (termsOfServiceUrl != null) prefs.setString(termsOfServiceUrlKey, termsOfServiceUrl!);
    if (privacyUrl != null) prefs.setString(privacyUrlKey, privacyUrl!);
    if (helpAndSupportUrl != null) prefs.setString(helpAndSupportUrlKey, helpAndSupportUrl!);
    if (aboutUsUrl != null) prefs.setString(aboutUsUrlKey, aboutUsUrl!);
    prefs.setBool(emailVerificationEnabledKey, emailVerificationEnabled);
    prefs.setBool(mobileNumberVerificationEnabledKey, mobileNumberVerificationEnabled);
    prefs.setBool(isEmailVerifiedKey, isEmailVerified);
    prefs.setBool(isMobileNumberVerifiedKey, isMobileNumberVerified);
    prefs.setStringList(remoteSessionEnabledPartyIdsKey, remoteSessionEnabledPartyIds);
  }

  // For pre-populating CC entry details
  Map<String, String> toMapForCreditCard() {
    return {
      idKey: accountId,
      nameKey: name,
      emailKey: email,
      countryCodeKey: ?countryCode,
      addressKey: ?address,
      addressLine2Key: ?addressLine2,
      postalCodeKey: ?postalCode,
      cityKey: ?city,
      firstNameKey: ?firstName,
      lastNameKey: ?lastName,
      phoneNoKey: ?phoneNo,
      phoneCountryCodeKey: ?phoneCountryCode,
    };
  }

  bool get isMissingAddressDetails {
    // addressLine2 is optional; most users won't have one, so don't treat its
    // absence as a missing address.
    return (address ?? '').isEmpty || (postalCode ?? '').isEmpty || (city ?? '').isEmpty;
  }

  @override
  List<Object?> get props => [
    accountId,
    name,
    email,
    countryCode,
    billingCurrency,
    address,
    addressLine2,
    postalCode,
    city,
    firstName,
    lastName,
    phoneNo,
    phoneCountryCode,
    userId,
    mfaMethod,
    hasCreditCard,
    hasRfidCard,
    canAddCreditCard,
    customDomain,
    termsOfServiceUrl,
    privacyUrl,
    helpAndSupportUrl,
    aboutUsUrl,
    emailVerificationEnabled,
    mobileNumberVerificationEnabled,
    isEmailVerified,
    isMobileNumberVerified,
    remoteSessionEnabledPartyIds,
  ];
}
