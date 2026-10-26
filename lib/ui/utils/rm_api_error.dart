import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/network/api_error_details.dart';

class RMApiError implements Exception {
  final String cause;
  final List<ErrorDetails>? details;
  final bool defaultErrorMessage;

  RMApiError({required this.cause, this.details, this.defaultErrorMessage = false});

  /// Client-synthesized coded errors for failed passkey ceremonies. The
  /// [cause] is only ever a log-facing fallback — the code drives the
  /// localized [causeString] branch.
  RMApiError.passkeyVerificationFailed()
      : this(cause: 'Passkey verification failed', details: [ErrorDetails(code: 'MFA_PASSKEY_VERIFICATION_FAILED')]);

  RMApiError.passkeyChallengeMissing()
      : this(cause: 'No passkey challenge provided', details: [ErrorDetails(code: 'MFA_PASSKEY_NO_CHALLENGE')]);

  RMApiError.passkeyCreationFailed()
      : this(cause: 'Passkey creation failed', details: [ErrorDetails(code: 'PASSKEY_CREATE_FAILED')]);

  RMApiError.passkeyAlreadyOnDevice()
      : this(
            cause: 'A passkey for this account already exists on this device',
            details: [ErrorDetails(code: 'PASSKEY_EXCLUDED_CREDENTIAL_EXISTS')]);

  RMApiError.passkeyNoneOnDevice()
      : this(cause: 'No passkey was found on this device', details: [ErrorDetails(code: 'PASSKEY_NONE_ON_DEVICE')]);

  /// The attestation-guarded endpoints (login, signup, password reset) return
  /// this 401 when the provider enforces device attestation and the request
  /// carried no App Check token — i.e. this build can no longer attest.
  /// [causeString] renders it as an "update the app" message, not a
  /// credentials error.
  bool get isAppUpgradeRequired => details?.firstOrNull?.code == 'APP_UPGRADE_REQUIRED';

  /// Remaining seconds of a rate-limit wait, when the backend sent one
  /// (the MFA 429 codes). Null otherwise.
  int? get retryAfterSeconds => details?.firstOrNull?.retryAfterSeconds;

  /// A recovery-email enrolment was refused because the address equals the
  /// account email; [causeString] renders it as a localized instruction.
  bool get isRecoveryEmailSameAsAccount => details?.firstOrNull?.code == 'MFA_RECOVERY_EMAIL_SAME_AS_ACCOUNT';

  /// A passkey challenge/verify round failed — sent by the backend, or
  /// synthesized client-side when a ceremony fails for an integrity reason;
  /// [causeString] renders it as a localized retry instruction.
  bool get isPasskeyVerificationFailed => details?.firstOrNull?.code == 'MFA_PASSKEY_VERIFICATION_FAILED';

  /// A passkey arm/challenge response carried no ceremony to run.
  bool get isPasskeyChallengeMissing => details?.firstOrNull?.code == 'MFA_PASSKEY_NO_CHALLENGE';

  /// Client-synthesized: a passkey registration ceremony failed on this
  /// device (integrity error, no provider); [causeString] localizes it.
  bool get isPasskeyCreationFailed => details?.firstOrNull?.code == 'PASSKEY_CREATE_FAILED';

  /// Client-synthesized: registration was refused because this device already
  /// holds a passkey for the account (`excludeCredentials` match).
  bool get isPasskeyAlreadyOnDevice => details?.firstOrNull?.code == 'PASSKEY_EXCLUDED_CREDENTIAL_EXISTS';

  /// Client-synthesized: a passwordless sign-in found no passkey on this
  /// device; [causeString] steers back to email and password.
  bool get isPasskeyNoneOnDevice => details?.firstOrNull?.code == 'PASSKEY_NONE_ON_DEVICE';

  @override
  String toString() {
    return cause;
  }

  /// The user-facing message. Error codes that warrant a different message
  /// than the server's are resolved here, localized, so every surface that
  /// renders an [RMApiError] gets them without per-call-site handling.
  String causeString(BuildContext context) {
    if (isAppUpgradeRequired) {
      return AppLocalizations.of(context)!.appUpdateRequiredError;
    }
    if (isRecoveryEmailSameAsAccount) {
      return AppLocalizations.of(context)!.mfaRecoveryEmailSameAsAccount;
    }
    if (isPasskeyVerificationFailed) {
      return AppLocalizations.of(context)!.mfaPasskeyVerificationFailed;
    }
    if (isPasskeyChallengeMissing) {
      return AppLocalizations.of(context)!.mfaPasskeyChallengeMissing;
    }
    if (isPasskeyCreationFailed) {
      return AppLocalizations.of(context)!.mfaPasskeyCreateFailed;
    }
    if (isPasskeyAlreadyOnDevice) {
      return AppLocalizations.of(context)!.mfaPasskeyAlreadyOnDevice;
    }
    if (isPasskeyNoneOnDevice) {
      return AppLocalizations.of(context)!.passkeyLoginNoCredential;
    }
    if (defaultErrorMessage) {
      return AppLocalizations.of(context)!.somethingWentWrongPleaseTryAgainLater;
    }
    return cause;
  }
}

/// A JWT-rejected 401. Recovery (renew + retry, or logout) is owned by the
/// network interceptor — by the time this surfaces to a caller, recovery has
/// already been handled out-of-band. It [extends RMApiError] so the ubiquitous
/// `on RMApiError catch` blocks absorb it gracefully (rather than letting it
/// propagate uncaught and pollute Crashlytics); `AuthSessionRenewer` still
/// catches the more specific type for the `/auth/renew` call to branch on
/// [expired] / [deviceRevoked].
class RMApiErrorJwtRejected extends RMApiError {
  final bool expired;
  final bool deviceRevoked;

  RMApiErrorJwtRejected({required super.cause, this.expired = false, this.deviceRevoked = false});
}
