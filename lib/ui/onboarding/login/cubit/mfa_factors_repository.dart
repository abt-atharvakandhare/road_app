import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/mfa_code_sent_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_totp_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

/// Client for the in-session, Bearer-authenticated factor-management surface
/// (`/1/users/me/mfa-factors/*`) — the settings-side counterpart of the
/// login-time [MfaRepository] handles. Used by the signup "Secure Sign-in"
/// step and settings factor management.
///
/// First-factor enrolment (TOTP/SMS begin while the user holds no active
/// sign-in factor) is gated on a live email proof —
/// `MFA_ENROL_EMAIL_PROOF_REQUIRED` routes through [sendEmailProof] /
/// [verifyEmailProof], which share the login-time proof's per-user budget.
@lazySingleton
class MfaFactorsRepository {
  final ApiService apiService;
  const MfaFactorsRepository(this.apiService);

  Future<MfaFactorsModel> getFactors() async {
    final response = await apiService.get('/1/users/me/mfa-factors');
    return MfaFactorsModel.fromJson(response.data['data']);
  }

  Future<MfaCodeSentModel> sendEmailProof() async {
    final response = await apiService.post('/1/users/me/mfa-factors/email-proof', data: {});
    return MfaCodeSentModel.fromJson(response.data['data']);
  }

  Future<void> verifyEmailProof({required String code}) async {
    await apiService.post('/1/users/me/mfa-factors/email-proof/verify', data: {'code': code});
  }

  Future<MfaEnrolTotpBeginModel> beginTotp() async {
    final response = await apiService.post('/1/users/me/mfa-factors/totp', data: {});
    return MfaEnrolTotpBeginModel.fromJson(response.data['data']);
  }

  /// Wrong codes return `MFA_TOTP_INVALID_CODE` (verifies against the pending
  /// factor's own secret — unthrottled, unlike challenge codes).
  Future<MfaFactorModel> activateTotp({required String factorId, required String code}) async {
    final response = await apiService.post('/1/users/me/mfa-factors/$factorId/activate', data: {'code': code});
    return MfaFactorModel.fromJson(response.data['data']);
  }

  /// Stages the factor and texts a code to the account phone; activation is
  /// [verifySms]'s job even for an already-verified number. Calling again
  /// resends, subject to the send budget.
  Future<MfaEnrolledSmsFactorModel> enrolSms() async {
    final response = await apiService.post('/1/users/me/mfa-factors/sms', data: {});
    return MfaEnrolledSmsFactorModel.fromJson(response.data['data']);
  }

  Future<MfaFactorModel> verifySms({required String factorId, required String code}) async {
    final response = await apiService.post('/1/users/me/mfa-factors/sms/$factorId/verify', data: {'code': code});
    return MfaFactorModel.fromJson(response.data['data']);
  }

  /// Begins in-session passkey registration (step-up + email-proof gated):
  /// returns the WebAuthn creation-options JSON to hand verbatim to the
  /// platform authenticator. Each call begins a fresh single-use ceremony,
  /// so re-begin on every attempt.
  Future<Map<String, dynamic>> registerPasskey() async {
    final response = await apiService.post('/1/users/me/mfa-factors/passkey/register', data: {});
    return Map<String, dynamic>.from(response.data['data']);
  }

  /// Completes passkey registration with the authenticator's attestation JSON
  /// (verbatim); the factor is active immediately.
  Future<MfaFactorModel> verifyPasskeyRegistration(
      {required Map<String, dynamic> response, String? label}) async {
    final apiResponse = await apiService.post('/1/users/me/mfa-factors/passkey/register/verify', data: {
      'response': response,
      'label': ?label,
    });
    return MfaFactorModel.fromJson(apiResponse.data['data']);
  }

  /// Removes a factor of any type and status. Even the last active sign-in
  /// factor may be removed — under enforce the user re-enrols at next login.
  Future<void> removeFactor({required String factorId}) async {
    await apiService.delete('/1/users/me/mfa-factors/$factorId');
  }

  Future<MfaFactorModel> renameFactor({required String factorId, required String label}) async {
    final response = await apiService.patch('/1/users/me/mfa-factors/$factorId', data: {'label': label});
    return MfaFactorModel.fromJson(response.data['data']);
  }

  /// Mints a fresh set of backup codes, active immediately and replacing any
  /// existing set. The plaintext codes are returned exactly this once.
  Future<MfaRecoveryCodesModel> generateRecoveryCodes() async {
    final response = await apiService.post('/1/users/me/mfa-factors/recovery-codes', data: {});
    return MfaRecoveryCodesModel.fromJson(response.data['data']);
  }

  /// Stages a recovery-email factor and mails a code to [email]; activation is
  /// [verifyRecoveryEmail]'s job. The address must differ from the account
  /// email — `MFA_RECOVERY_EMAIL_SAME_AS_ACCOUNT` otherwise.
  Future<MfaFactorModel> beginRecoveryEmail({required String email}) async {
    final response = await apiService.post('/1/users/me/mfa-factors/recovery-email', data: {'email': email});
    return MfaFactorModel.fromJson(response.data['data']);
  }

  Future<MfaFactorModel> verifyRecoveryEmail({required String factorId, required String code}) async {
    final response =
        await apiService.post('/1/users/me/mfa-factors/recovery-email/$factorId/verify', data: {'code': code});
    return MfaFactorModel.fromJson(response.data['data']);
  }
}
