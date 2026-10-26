import 'package:road_mobile/ui/utils/rm_api_error.dart';

/// Machine-readable error codes of the MFA decision engine, carried in
/// `details[0].code`. Branch on these, never on the error message.
///
/// Wrong codes are unified: every channel (TOTP, SMS, email proof, recovery
/// code) returns [challengeInvalidCode]. The 429 codes carry
/// `retryAfterSeconds` alongside the code in `details[0]`
/// ([RMApiError.retryAfterSeconds]).
enum MfaErrorCode {
  pendingLoginNotFound('MFA_PENDING_LOGIN_NOT_FOUND'),
  pendingEnrolmentNotFound('MFA_PENDING_ENROLMENT_NOT_FOUND'),
  methodNotAvailable('MFA_METHOD_NOT_AVAILABLE'),
  methodNotPermitted('MFA_METHOD_NOT_PERMITTED'),

  /// Wrong code, any channel. The handle and the code survive — retry inline.
  challengeInvalidCode('MFA_CHALLENGE_INVALID_CODE'),

  /// A sent code dies after 3 wrong guesses; the 4th attempt returns this.
  /// Retrying is pointless — steer the user to request a new code.
  challengeExhausted('MFA_CHALLENGE_EXHAUSTED'),

  /// The code in the user's hand outlived its lifetime — request a new one.
  challengeExpired('MFA_CHALLENGE_EXPIRED'),

  /// Verify called with no code in flight — send one first.
  challengeNotArmed('MFA_CHALLENGE_NOT_ARMED'),

  /// 429: send allowance spent for this channel (per user, not per handle —
  /// restarting the sign-in does not refill it). A code already sent can
  /// still verify, so keep the code input usable while the wait runs.
  challengeLimitReached('MFA_CHALLENGE_LIMIT_REACHED'),

  /// 429: a code went out moments ago — not a limit; disable the resend
  /// control until the wait lapses.
  challengeTooSoon('MFA_CHALLENGE_TOO_SOON'),

  /// 429: too many wrong attempts at a factor that sends nothing (TOTP,
  /// recovery code). Per user, shared with step-up; only waiting helps.
  guessLimitReached('MFA_GUESS_LIMIT_REACHED'),

  /// Wrong code when *activating* a newly enrolled authenticator — verifies
  /// against the pending factor's own secret, not a challenge; unthrottled.
  totpInvalidCode('MFA_TOTP_INVALID_CODE'),
  totpNotPending('MFA_TOTP_NOT_PENDING'),
  smsNoPhone('MFA_SMS_NO_PHONE'),
  smsNotEnrolled('MFA_SMS_NOT_ENROLLED'),
  smsNotPending('MFA_SMS_NOT_PENDING'),
  passkeyNoChallenge('MFA_PASSKEY_NO_CHALLENGE'),
  passkeyOriginNotAllowed('MFA_PASSKEY_ORIGIN_NOT_ALLOWED'),
  passkeyUnknownCredential('MFA_PASSKEY_UNKNOWN_CREDENTIAL'),
  passkeyVerificationFailed('MFA_PASSKEY_VERIFICATION_FAILED'),
  passkeyNotPermitted('MFA_PASSKEY_NOT_PERMITTED'),
  recoveryEmailNotPending('MFA_RECOVERY_EMAIL_NOT_PENDING'),
  recoveryEmailSameAsAccount('MFA_RECOVERY_EMAIL_SAME_AS_ACCOUNT'),
  enrolEmailUnverified('MFA_ENROL_EMAIL_UNVERIFIED'),

  /// In-session (settings) enrolment counterpart of [enrolEmailUnverified]:
  /// a factorless user must complete `/1/users/me/mfa-factors/email-proof`
  /// before starting factor enrolment there.
  enrolEmailProofRequired('MFA_ENROL_EMAIL_PROOF_REQUIRED'),
  enrolNoEmail('MFA_ENROL_NO_EMAIL'),
  enrolMethodNotPermitted('MFA_ENROL_METHOD_NOT_PERMITTED'),
  enrolRequired('MFA_ENROL_REQUIRED'),

  /// 403 on a sensitive in-session action: re-authenticate via
  /// `/1/auth/step-up/*` first.
  stepUpRequired('MFA_STEP_UP_REQUIRED');

  const MfaErrorCode(this.code);

  final String code;

  static MfaErrorCode? fromError(RMApiError error) {
    final code = error.details?.firstOrNull?.code;
    if (code == null) {
      return null;
    }
    for (final value in values) {
      if (value.code == code) {
        return value;
      }
    }
    return null;
  }

  /// Wrong code entered — the handle survives, let the user retry inline.
  bool get isWrongCode => this == challengeInvalidCode || this == totpInvalidCode;

  /// The code the user holds can never verify — steer to resend, not retry.
  bool get needsFreshCode => this == challengeExhausted || this == challengeExpired || this == challengeNotArmed;

  /// A send was refused with a wait (`retryAfterSeconds`) — update the resend
  /// countdown; nothing was sent and nothing already sent was invalidated.
  bool get isSendThrottled => this == challengeLimitReached || this == challengeTooSoon;

  /// The withheld sign-in expired or is unknown — restart from the login form.
  bool get isExpiredHandle => this == pendingLoginNotFound || this == pendingEnrolmentNotFound;
}
