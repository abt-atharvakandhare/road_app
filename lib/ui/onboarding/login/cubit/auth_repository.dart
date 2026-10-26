import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/account/account_self_response_model.dart';
import 'package:road_mobile/data/model/login/auth_refresh_response_model.dart';
import 'package:road_mobile/data/model/login/auth_renew_response_model.dart';
import 'package:road_mobile/data/model/login/login_2fa_verify_model.dart';
import 'package:road_mobile/data/model/login/login_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_session_model.dart';
import 'package:road_mobile/data/model/mobile_features/mobile_user_summary_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/signup/signup_individual_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/services/network/api_service.dart';

import '../model/login_user_request.dart';

@lazySingleton
class AuthRepository {
  final ApiService apiService;
  const AuthRepository(this.apiService);

  Future<ProviderResponseModel> getProvider(String provider) async {
    final providerResponse = await apiService.get('/1/providers/public/$provider');
    final providerData = ProviderResponseDataModel.fromJson(providerResponse.data);
    return providerData.data;
  }

  Future<LoginResponseModel> login(String email, {required String password}) async {
    LoginUserRequest request = LoginUserRequest(email: email, password: password);
    Response response = await apiService.post('/1/auth/login', data: request.toJson());
    return LoginResponseModel.fromJson(response.data['data']);
  }

  /// Arms a passwordless passkey sign-in (spec §6): usernameless — the OS
  /// picks the account from the credentials it holds for the rpId. Returns
  /// the single-use [MfaChallengeResponseModel.ceremonyId] and the WebAuthn
  /// request-options JSON to hand verbatim to the platform authenticator.
  Future<MfaChallengeResponseModel> beginPasskeyLogin({required String providerId}) async {
    final response = await apiService.post('/1/auth/passkey/challenge', data: {'providerId': providerId});
    return MfaChallengeResponseModel.fromJson(response.data['data']);
  }

  /// Completes a passwordless passkey sign-in. A passkey is inherently
  /// multi-factor, so this returns a full session — no further challenge.
  Future<MfaSessionModel> completePasskeyLogin(
      {required String ceremonyId, required Map<String, dynamic> response}) async {
    final apiResponse = await apiService.post('/1/auth/passkey/login', data: {
      'ceremonyId': ceremonyId,
      'response': response,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(apiResponse.data['data']);
  }

  Future<AuthRefreshResponseModel> refreshToken() async {
    final response = await apiService.post('/1/auth/refresh');
    return AuthRefreshResponseModel.fromJson(response.data['data']);
  }

  Future<AuthRenewResponseModel> renewSession(String renewalToken) async {
    // The Authorization header here carries the renewal token, not the user
    // JWT — the interceptor yields to a caller-set Authorization, so it
    // won't overwrite this. X-Device-Id and Provider go through normally.
    final response = await apiService.post(
      '/1/auth/renew',
      headers: {'Authorization': 'Bearer $renewalToken'},
    );
    return AuthRenewResponseModel.fromJson(response.data['data']);
  }

  Future<Login2FaVerifyModel> verify2faCode(String code) async {
    final response = await apiService.post('/1/mfa/verify', data: {'code': code});
    return Login2FaVerifyModel.fromJson(response.data);
  }

  Future<void> send2faCode() async {
    await apiService.post('/1/mfa/send-code');
  }

  Future<ProfileResponseModel> getMyProfile() async {
    final profileResponse = await apiService.get('/1/users/me');
    return ProfileResponseModel.fromJson(profileResponse.data);
  }

  Future<AccountSelfModel> getMyAccount() async {
    final accountResponse = await apiService.get('/1/accounts/self');
    final account = AccountSelfResponseModel.fromJson(accountResponse.data);
    return account.data;
  }

  Future<MobileUserSummaryModel> getMobileFeatures() async {
    final mobileFeaturesResponse = await apiService.get('/1/mobile/user/summary');
    final mobileFeatures = MobileUserSummaryResponseModel.fromJson(mobileFeaturesResponse.data);
    return mobileFeatures.data;
  }

  Future<void> updateAccountDetails(
      String address, String addressLine2, String postalCode, String city, String countryCode) {
    final billing = Billing(
      address: address,
      addressLine2: addressLine2,
      postalCode: postalCode,
      city: city,
      countryCode: countryCode,
    );

    return apiService.patch('/1/accounts/self/billing', data: {
      'billing': billing,
    });
  }

  /// Null phone fields are left out of the payload entirely:
  /// `PATCH /1/users/me` is MFA step-up gated when the body touches the
  /// phone, so an unchanged phone must not be sent along with a name edit.
  Future<void> updateProfile(String firstName, String lastName,
      {String? phoneCountryCode, String? phoneNumber}) async {
    final data = {
      'contact': {
        'firstName': firstName,
        'lastName': lastName,
        'phoneCountryCode': ?phoneCountryCode,
        'phoneNo': ?phoneNumber,
      }
    };

    await apiService.patch('/1/users/me', data: data);
  }

  Future<void> deleteAccount() async {
    return await apiService.post('/1/accounts/request-removal', data: {});
  }
}
