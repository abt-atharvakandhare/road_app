part of 'step_up_cubit.dart';

/// Steps of the step-up sheet. With several usable factors the picker is the
/// hub; with exactly one the cubit goes straight to its code entry.
@freezed
sealed class StepUpState with _$StepUpState {
  /// [factors] is null while the initial listing load is in flight.
  const factory StepUpState.methodPick({
    @Default(UIFlow.established()) UIFlow flow,
    List<MfaFactorModel>? factors,
  }) = StepUpMethodPick;

  /// Enter the 6-digit code for [method]. For SMS, [hint] is the masked
  /// number and [nextSendAfterSeconds] the resend spacing (also set when the
  /// first arm was refused with a wait — an earlier code may still verify,
  /// so the entry stays usable).
  const factory StepUpState.codeEntry({
    @Default(UIFlow.established()) UIFlow flow,
    required MfaMethod method,
    String? hint,
    int? nextSendAfterSeconds,
    @Default(false) bool canPickAnother,
  }) = StepUpCodeEntry;

  /// Verify with a passkey. The widget auto-starts one ceremony and offers a
  /// retry button — every attempt re-arms (ceremony ids are single-use).
  /// [noCredential] flags that a ceremony already failed because this device
  /// holds no passkey for the account — the widget swaps in dead-end copy
  /// (step-up has no recovery-code path).
  const factory StepUpState.passkey({
    @Default(UIFlow.established()) UIFlow flow,
    @Default(false) bool noCredential,
    @Default(false) bool canPickAnother,
  }) = StepUpPasskey;

  /// The account's only sign-in factors can't be driven by this app (e.g.
  /// passkey-only on a device without passkey support). Step-up has no
  /// recovery-code path — the user must use the web portal.
  const factory StepUpState.deadEnd({
    @Default(UIFlow.established()) UIFlow flow,
  }) = StepUpDeadEnd;
}
