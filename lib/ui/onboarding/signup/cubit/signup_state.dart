part of 'signup_cubit.dart';

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState.createAccount({
    @Default(UIFlow.established()) UIFlow flow,
    @Default([]) List<String> supportedCountries,
    @Default([]) List<VerificationType> requiredVerifications,
    @Default(1) int currentStep,
    @Default(4) int totalSteps,
  }) = CreateAccount;

  const factory SignupState.verifyPhone({
    @Default(UIFlow.established()) UIFlow flow,
    required String phoneNumber,
    required String phoneCountryCode,
    @Default([]) List<VerificationType> requiredVerifications,
    @Default(2) int currentStep,
    @Default(4) int totalSteps,
  }) = VerifyPhone;

  const factory SignupState.verifyEmail({
    @Default(UIFlow.established()) UIFlow flow,
    required String email,
    @Default([]) List<VerificationType> requiredVerifications,
    @Default(2) int currentStep,
    @Default(4) int totalSteps,
  }) = VerifyEmail;

  const factory SignupState.offerAddPayment({
    @Default(UIFlow.established()) UIFlow flow,
    @Default(4) int currentStep,
    @Default(4) int totalSteps,
  }) = OfferAddPayment;

  /// The §19 "Secure Sign-in" step (after payment, matching web's order).
  /// Offered only when the decide-once check froze true at signup time.
  const factory SignupState.offerMfaSetup({
    @Default(UIFlow.established()) UIFlow flow,
    @Default(5) int currentStep,
    @Default(5) int totalSteps,
  }) = OfferMfaSetup;

  /// Terminal: the screen pops the modal and shows the welcome snackbar.
  const factory SignupState.completed({
    @Default(UIFlow.established()) UIFlow flow,
  }) = SignupCompleted;
}
