import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/signup/signup_response_model.dart';

/// Test fixtures for verification feature tests
class VerificationTestFixtures {
  /// Provider with both phone and email verification enabled
  static ProviderResponseModel providerWithBothVerifications() {
    return ProviderResponseModel(
      id: '5e7cc9a30cfce30010cae097',
      customDomain: 'https://e-flux.io',
      supportUrl: 'https://help.road.io/',
      tosUrl: 'https://www.e-flux.io/terms-conditions',
      privacyUrl: 'https://www.e-flux.io/privacy',
      enableVerifications: ['phone', 'email'],
    );
  }

  /// Provider with phone verification only
  static ProviderResponseModel providerWithPhoneOnly() {
    return ProviderResponseModel(
      id: '5e7cc9a30cfce30010cae097',
      customDomain: 'https://e-flux.io',
      supportUrl: 'https://help.road.io/',
      enableVerifications: ['phone'],
    );
  }

  /// Provider with email verification only
  static ProviderResponseModel providerWithEmailOnly() {
    return ProviderResponseModel(
      id: '5e7cc9a30cfce30010cae097',
      customDomain: 'https://e-flux.io',
      supportUrl: 'https://help.road.io/',
      enableVerifications: ['email'],
    );
  }

  /// Provider with no verification requirements
  static ProviderResponseModel providerWithNoVerification() {
    return ProviderResponseModel(
      id: '5e7cc9a30cfce30010cae097',
      customDomain: 'https://e-flux.io',
      supportUrl: 'https://help.road.io/',
      enableVerifications: [],
    );
  }

  /// Account details for new user with unverified email and phone
  static AccountDetailsModel newUserUnverified() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'Test User',
      email: 'test@example.com',
      isEmailVerified: false,
      emailVerificationEnabled: true,
      phoneNo: '+31612345678',
      phoneCountryCode: 'NL',
      isMobileNumberVerified: false,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: false,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Account details for new user with verified email, unverified phone
  static AccountDetailsModel newUserEmailVerified() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'Test User',
      email: 'test@example.com',
      isEmailVerified: true,
      emailVerificationEnabled: true,
      phoneNo: '+31612345678',
      phoneCountryCode: 'NL',
      isMobileNumberVerified: false,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: false,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Account details for new user with verified phone, unverified email
  static AccountDetailsModel newUserPhoneVerified() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'Test User',
      email: 'test@example.com',
      isEmailVerified: false,
      emailVerificationEnabled: true,
      phoneNo: '+31612345678',
      phoneCountryCode: 'NL',
      isMobileNumberVerified: true,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: false,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Account details for new user with both verified
  static AccountDetailsModel newUserFullyVerified() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'Test User',
      email: 'test@example.com',
      isEmailVerified: true,
      emailVerificationEnabled: true,
      phoneNo: '+31612345678',
      phoneCountryCode: 'NL',
      isMobileNumberVerified: true,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: false,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Account details for UK user (phone verification exempted)
  static AccountDetailsModel ukUserUnverified() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'UK User',
      email: 'test@example.co.uk',
      isEmailVerified: false,
      emailVerificationEnabled: true,
      phoneNo: '+447911123456',
      phoneCountryCode: 'GB',
      isMobileNumberVerified: false,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: false,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Account details for existing user (not a new signup)
  static AccountDetailsModel existingUser() {
    return const AccountDetailsModel(
      accountId: 'acc-123',
      name: 'Existing User',
      email: 'existing@example.com',
      isEmailVerified: false,
      emailVerificationEnabled: true,
      phoneNo: '+31612345678',
      phoneCountryCode: 'NL',
      isMobileNumberVerified: false,
      mobileNumberVerificationEnabled: true,
      hasCreditCard: true,
      hasRfidCard: false,
      canAddCreditCard: true,
      remoteSessionEnabledPartyIds: ['EFL'],
    );
  }

  /// Successful signup response
  static SignupDataResponseModel successfulSignupResponse() {
    return SignupDataResponseModel(
      data: SignupResponseModel(
        userId: 'user-123',
      ),
    );
  }

  /// Test verification codes
  static const String validVerificationCode = '123456';
  static const String invalidVerificationCode = '000000';
  
  /// Test phone numbers
  static const String nlPhoneNumber = '+31612345678';
  static const String ukPhoneNumber = '+447911123456';
  
  /// Test emails
  static const String testEmail = 'test@example.com';
  static const String testEmailUk = 'test@example.co.uk';
}