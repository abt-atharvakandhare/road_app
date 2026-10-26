import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_code_sent_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_email_proof_verify_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_sms_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_totp_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/data/model/login/mfa_session_model.dart';
import 'package:road_mobile/services/network/api_service.dart';

/// Client for the MFA decision-engine endpoints (`/1/auth/mfa/*`).
///
/// None of these calls carry an `Authorization` header — the single-use
/// `pendingId` / `enrolId` handle in the body is the credential. Every
/// session-completing call requests a renewal token, matching the
/// unconditionally-true `requestDeviceRefresh` of the login call.
@lazySingleton
class MfaRepository {
  final ApiService apiService;
  const MfaRepository(this.apiService);

  // ── Verify an existing factor (pendingId) ──

  /// Arms a challenge for [method]. SMS arming sends the code; re-arm to resend.
  Future<MfaChallengeResponseModel> armChallenge({required String pendingId, required MfaMethod method}) async {
    final response = await apiService.post('/1/auth/mfa/challenge', data: {
      'pendingId': pendingId,
      'method': method.wireName,
    });
    return MfaChallengeResponseModel.fromJson(response.data['data']);
  }

  /// Completes the passkey ceremony armed by [armChallenge]. [ceremonyId] is
  /// single-use — a retry needs a fresh arm. [response] is the platform
  /// authenticator's assertion JSON, passed verbatim.
  Future<MfaSessionModel> verifyPasskey(
      {required String pendingId, required String ceremonyId, required Map<String, dynamic> response}) async {
    final apiResponse = await apiService.post('/1/auth/mfa/passkey/verify', data: {
      'pendingId': pendingId,
      'ceremonyId': ceremonyId,
      'response': response,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(apiResponse.data['data']);
  }

  Future<MfaSessionModel> verifyTotp({required String pendingId, required String code}) =>
      _completeWithCode('/1/auth/mfa/totp/verify', handleKey: 'pendingId', handle: pendingId, code: code);

  Future<MfaSessionModel> verifySms({required String pendingId, required String code}) =>
      _completeWithCode('/1/auth/mfa/sms/verify', handleKey: 'pendingId', handle: pendingId, code: code);

  Future<MfaSessionModel> verifyRecoveryCode({required String pendingId, required String code}) =>
      _completeWithCode('/1/auth/mfa/recovery-code/verify', handleKey: 'pendingId', handle: pendingId, code: code);

  // ── Email-verification step-up (pendingId, own handle namespace) ──

  Future<MfaCodeSentModel> sendVerifyEmail({required String pendingId}) async {
    final response = await apiService.post('/1/auth/mfa/verify-email/send', data: {'pendingId': pendingId});
    return MfaCodeSentModel.fromJson(response.data['data']);
  }

  Future<MfaSessionModel> verifyEmailCode({required String pendingId, required String code}) =>
      _completeWithCode('/1/auth/mfa/verify-email/verify', handleKey: 'pendingId', handle: pendingId, code: code);

  // ── Enrol a first factor (enrolId) ──

  Future<MfaCodeSentModel> sendEnrolmentEmailProof({required String enrolId}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/email-proof/send', data: {'enrolId': enrolId});
    return MfaCodeSentModel.fromJson(response.data['data']);
  }

  Future<MfaEnrolEmailProofVerifyModel> verifyEnrolmentEmailProof(
      {required String enrolId, required String code}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/email-proof/verify', data: {
      'enrolId': enrolId,
      'code': code,
    });
    return MfaEnrolEmailProofVerifyModel.fromJson(response.data['data']);
  }

  Future<MfaEnrolTotpBeginModel> beginTotpEnrolment({required String enrolId}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/totp/begin', data: {'enrolId': enrolId});
    return MfaEnrolTotpBeginModel.fromJson(response.data['data']);
  }

  Future<MfaSessionModel> activateTotpEnrolment(
      {required String enrolId, required String factorId, required String code}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/totp/activate', data: {
      'enrolId': enrolId,
      'factorId': factorId,
      'code': code,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(response.data['data']);
  }

  /// Texts a code to the account's phone — an already-verified phone still
  /// has to prove possession. Calling again is the resend (a code still in
  /// flight is handed back without sending). The session comes from
  /// [verifySmsEnrolment], which is why there is no `requestDeviceRefresh`.
  Future<MfaEnrolSmsBeginModel> beginSmsEnrolment({required String enrolId}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/sms/begin', data: {
      'enrolId': enrolId,
    });
    return MfaEnrolSmsBeginModel.fromJson(response.data['data']);
  }

  Future<MfaSessionModel> verifySmsEnrolment(
      {required String enrolId, required String factorId, required String code}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/sms/verify', data: {
      'enrolId': enrolId,
      'factorId': factorId,
      'code': code,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(response.data['data']);
  }

  /// Begins passkey enrolment: returns the WebAuthn creation-options JSON to
  /// hand verbatim to the platform authenticator. Each call begins a fresh
  /// single-use ceremony, so re-begin on every attempt. The session comes
  /// from [verifyPasskeyEnrolment], which is why there is no
  /// `requestDeviceRefresh`.
  Future<Map<String, dynamic>> beginPasskeyEnrolment({required String enrolId}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/passkey/begin', data: {'enrolId': enrolId});
    return Map<String, dynamic>.from(response.data['data']);
  }

  /// Completes passkey enrolment with the authenticator's attestation JSON
  /// (verbatim) and issues the session.
  Future<MfaSessionModel> verifyPasskeyEnrolment(
      {required String enrolId, required Map<String, dynamic> response, String? label}) async {
    final apiResponse = await apiService.post('/1/auth/mfa/enrol/passkey/verify', data: {
      'enrolId': enrolId,
      'response': response,
      'label': ?label,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(apiResponse.data['data']);
  }

  /// Encourage mode only; enforce rejects this with `MFA_ENROL_REQUIRED`.
  Future<MfaSessionModel> skipEnrolment({required String enrolId}) async {
    final response = await apiService.post('/1/auth/mfa/enrol/skip', data: {
      'enrolId': enrolId,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(response.data['data']);
  }

  Future<MfaSessionModel> _completeWithCode(String path,
      {required String handleKey, required String handle, required String code}) async {
    final response = await apiService.post(path, data: {
      handleKey: handle,
      'code': code,
      'requestDeviceRefresh': true,
    });
    return MfaSessionModel.fromJson(response.data['data']);
  }
}
