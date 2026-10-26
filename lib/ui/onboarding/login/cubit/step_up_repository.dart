import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/network/api_service.dart';

/// Client for the in-session re-verification surface (`/1/auth/step-up/*`,
/// spec §13). A gated request 403s with `MFA_STEP_UP_REQUIRED`; verifying
/// here refreshes the session's MFA freshness server-side — no new token is
/// minted, so nothing needs storing on success.
///
/// The challenge/verify budgets are shared with login-time MFA (same phone,
/// inbox and authenticator), so the 429 codes carry `retryAfterSeconds`
/// exactly like [MfaRepository]'s do.
@lazySingleton
class StepUpRepository {
  final ApiService apiService;
  const StepUpRepository(this.apiService);

  /// Arms a factor. SMS sends the text and returns a masked-number hint plus
  /// the resend spacing; TOTP needs no arm at all — codes come from the
  /// user's authenticator.
  Future<MfaChallengeResponseModel> challenge(MfaMethod method) async {
    final response = await apiService.post('/1/auth/step-up/challenge', data: {'method': method.wireName});
    return MfaChallengeResponseModel.fromJson(response.data['data']);
  }

  /// Completes the passkey ceremony armed by [challenge]. [ceremonyId] is
  /// single-use — a retry needs a fresh arm. [response] is the platform
  /// authenticator's assertion JSON, passed verbatim. Success is a bare 204.
  Future<void> verifyPasskey({required String ceremonyId, required Map<String, dynamic> response}) async {
    await apiService.post('/1/auth/step-up/passkey/verify', data: {
      'ceremonyId': ceremonyId,
      'response': response,
    });
  }

  Future<void> verifyTotp({required String code}) async {
    await apiService.post('/1/auth/step-up/totp/verify', data: {'code': code});
  }

  Future<void> verifySms({required String code}) async {
    await apiService.post('/1/auth/step-up/sms/verify', data: {'code': code});
  }
}
