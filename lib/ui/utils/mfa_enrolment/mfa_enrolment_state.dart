part of 'mfa_enrolment_cubit.dart';

/// Steps of factor enrolment/management over `/1/users/me/mfa-factors/*`.
/// The method list is the hub; sub-flows return to it. The signup "Secure
/// Sign-in" step uses the first four states; the settings security screen
/// additionally drives the recovery-codes and recovery-email states.
@freezed
sealed class MfaEnrolmentState with _$MfaEnrolmentState {
  /// [factors] is null while the initial load is in flight; a load failure
  /// leaves it null with an error flow — the host's own affordances stay
  /// live.
  const factory MfaEnrolmentState.methodList({
    @Default(UIFlow.established()) UIFlow flow,
    MfaFactorsModel? factors,
  }) = MfaSetupMethodList;

  /// First-factor gate: prove control of the account email, then continue
  /// into [pendingMethod]'s enrolment.
  const factory MfaEnrolmentState.emailProof({
    @Default(UIFlow.established()) UIFlow flow,
    required MfaMethod pendingMethod,
    int? nextSendAfterSeconds,
  }) = MfaSetupEmailProof;

  /// Scan/enter the authenticator secret, then confirm with a code.
  const factory MfaEnrolmentState.totpSetup({
    @Default(UIFlow.established()) UIFlow flow,
    required MfaEnrolTotpBeginModel totp,
  }) = MfaSetupTotp;

  /// A code was texted to the account phone ([hint]); confirm to activate.
  const factory MfaEnrolmentState.smsVerify({
    @Default(UIFlow.established()) UIFlow flow,
    required String factorId,
    String? hint,
    int? nextSendAfterSeconds,
  }) = MfaSetupSmsVerify;

  /// A freshly minted set of backup codes — plaintext is shown exactly this
  /// once, so leaving is gated on the user acknowledging they saved them.
  const factory MfaEnrolmentState.recoveryCodes({
    @Default(UIFlow.established()) UIFlow flow,
    required List<String> codes,
  }) = MfaSetupRecoveryCodes;

  /// Enter the address for a new recovery email; it must differ from the
  /// account email.
  const factory MfaEnrolmentState.recoveryEmailEntry({
    @Default(UIFlow.established()) UIFlow flow,
  }) = MfaSetupRecoveryEmailEntry;

  /// A code was mailed to [email]; confirm to activate the staged factor.
  const factory MfaEnrolmentState.recoveryEmailVerify({
    @Default(UIFlow.established()) UIFlow flow,
    required String factorId,
    required String email,
    int? nextSendAfterSeconds,
  }) = MfaSetupRecoveryEmailVerify;
}
