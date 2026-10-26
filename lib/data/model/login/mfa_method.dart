import 'package:json_annotation/json_annotation.dart';

/// Factor types of the MFA decision engine (`/1/auth/mfa/*`).
///
/// [unknown] absorbs factor types this app version doesn't know; treat it as
/// unusable rather than failing to parse the login response.
enum MfaMethod {
  @JsonValue('passkey')
  passkey,
  @JsonValue('totp')
  totp,
  @JsonValue('sms')
  sms,
  @JsonValue('recovery-code')
  recoveryCode,
  @JsonValue('recovery-email')
  recoveryEmail,
  unknown;

  String get wireName {
    switch (this) {
      case MfaMethod.passkey:
        return 'passkey';
      case MfaMethod.totp:
        return 'totp';
      case MfaMethod.sms:
        return 'sms';
      case MfaMethod.recoveryCode:
        return 'recovery-code';
      case MfaMethod.recoveryEmail:
        return 'recovery-email';
      case MfaMethod.unknown:
        throw ArgumentError('MfaMethod.unknown cannot be sent to the backend');
    }
  }
}

extension UsableMfaMethods on List<MfaMethod> {
  /// Factor types this app can drive natively. [passkeySupported] gates
  /// passkey on runtime device capability (`PasskeyService.isSupported`):
  /// the backend offers `passkey` whenever the account or policy allows it,
  /// but the device may be unable to run a ceremony (old Android, no
  /// credential provider). Surfaces that don't drive passkey ceremonies pass
  /// false. [MfaMethod.unknown] is a factor type from a newer backend.
  List<MfaMethod> usableOnMobile({required bool passkeySupported}) => where((method) =>
      method == MfaMethod.totp ||
      method == MfaMethod.sms ||
      (passkeySupported && method == MfaMethod.passkey)).toList();
}

/// Provider MFA mode. The login response's `mfaEnrolment.mode` only ever
/// carries encourage/enforce (its unknown fallback is [enforce] so the skip
/// affordance stays hidden); the self-service factors listing
/// (`GET /1/users/me/mfa-factors`) can also report [off].
enum MfaMode {
  @JsonValue('off')
  off,
  @JsonValue('encourage')
  encourage,
  @JsonValue('enforce')
  enforce,
}
