import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/signup/signup_screen_data.dart';
import 'package:road_mobile/data/model/signup/signup_individual_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/services/timezone/timezone_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'signup_state.dart';
part 'signup_cubit.freezed.dart';

@injectable
class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._repo, this._verificationRepo, this._mfaFactorsRepo, this._passkeyService, this._timezoneService, this._analytics, this._mixpanelService) : super(const SignupState.createAccount()) {
    _loadSupportedCountriesFuture = loadSupportedCountries();
  }

  final SignupRepository _repo;
  final VerificationRepository _verificationRepo;
  final MfaFactorsRepository _mfaFactorsRepo;
  final PasskeyService _passkeyService;
  final TimezoneService _timezoneService;
  final Analytics _analytics;
  final MixpanelService _mixpanelService;
  late final Future<void> _loadSupportedCountriesFuture;

  // Store signup data for verification flow
  SignupScreenData? _signupData;

  /// The address the account was created with — the MFA email-proof step
  /// names it as where the code went.
  String? get signupEmail => _signupData?.email;
  List<VerificationType> _requiredVerifications = [];
  ProviderResponseModel? _providerModel;

  /// Whether the "Secure Sign-in" step is part of this journey. Frozen once,
  /// right after the session is established and BEFORE the verification steps
  /// — phone verification auto-enrols an SMS factor, and re-evaluating later
  /// would make the step vanish underneath the user (spec §19 "decide once").
  bool _offerMfaSetup = false;

  /// Initialize with provider model to calculate correct total steps
  void initializeWithProvider(ProviderResponseModel? providerModel) {
    _providerModel = providerModel;
    if (state case CreateAccount createAccount) {
      final totalSteps = _calculateTotalStepsFromProvider(providerModel);
      emit(createAccount.copyWith(totalSteps: totalSteps));
    }
  }

  /// Fire the `onboarding_started` journey-step when the signup modal opens.
  void trackOnboardingStarted() {
    _mixpanelService.trackOnboardingStep(
      MixpanelOnboardingStep.onboardingStarted,
      MixpanelOnboardingAction.signup,
    );
  }

  /// Fire the `onboarding_completed` journey-step when the signup modal closes.
  /// Caller is responsible for deciding when "completed" applies (e.g. after
  /// the add-payment step finishes and the modal pops).
  void trackOnboardingCompleted() {
    _mixpanelService.trackOnboardingStep(
      MixpanelOnboardingStep.onboardingCompleted,
      MixpanelOnboardingAction.signupComplete,
    );
    _mixpanelService.flush();
  }

  /// Calculate total steps based on provider's verification settings
  int _calculateTotalStepsFromProvider(ProviderResponseModel? providerModel) {
    if (providerModel == null ||
        providerModel.enableVerifications == null ||
        providerModel.enableVerifications!.isEmpty) {
      return 2; // Just create account + payment
    }

    int steps = 2; // Base: create account + payment
    if (providerModel.enableVerifications!.contains('email')) {
      steps++;
    }
    if (providerModel.enableVerifications!.contains('phone')) {
      steps++;
    }
    return steps;
  }

  /// Centralized method for calculating total steps based on actual verifications
  int _calculateTotalSteps(List<VerificationType> verifications) {
    // create account + verifications + payment (+ the Secure Sign-in step)
    return 2 + verifications.length + (_offerMfaSetup ? 1 : 0);
  }

  /// Spec §19 decide-once: whether to add the "Secure Sign-in" step, evaluated
  /// while the user is still factorless. Passkey counts as an offerable method
  /// only when this device can run a ceremony. A failed fetch (or capability
  /// check) skips the step — it must never block signup.
  Future<void> _freezeMfaSetupOffer() async {
    try {
      bool passkeySupported = false;
      try {
        passkeySupported = await _passkeyService.isSupported();
      } catch (_) {
        // An unanswerable capability check reads as "can't do passkeys".
      }
      final factors = await _mfaFactorsRepo.getFactors();
      _offerMfaSetup = factors.mode != MfaMode.off &&
          factors.permittedMethods.usableOnMobile(passkeySupported: passkeySupported).isNotEmpty &&
          !factors.hasActiveLoginFactor;
    } catch (e) {
      log('MFA factors fetch failed; skipping the signup MFA step: $e');
      _offerMfaSetup = false;
    }
    if (_offerMfaSetup) {
      _mixpanelService.trackOnboardingStep(
        MixpanelOnboardingStep.mfaSetupStep,
        MixpanelOnboardingAction.offered,
      );
    }
  }

  /// Called by the screen once the add-payment flow returns: the journey
  /// continues into the Secure Sign-in step when it was frozen in, and
  /// completes otherwise.
  void advanceFromPayment() {
    if (isClosed) return;
    if (_offerMfaSetup) {
      final totalSteps = _calculateTotalSteps(_requiredVerifications);
      emit(SignupState.offerMfaSetup(currentStep: totalSteps, totalSteps: totalSteps));
    } else {
      emit(const SignupState.completed());
    }
  }

  /// From the Secure Sign-in step: Continue after enrolling, or Skip for now.
  void completeMfaSetup({required bool skipped}) {
    if (isClosed) return;
    _mixpanelService.trackOnboardingStep(
      MixpanelOnboardingStep.mfaSetupStep,
      skipped ? MixpanelOnboardingAction.skip : MixpanelOnboardingAction.enrolled,
    );
    emit(const SignupState.completed());
  }

  /// Determines which verifications are pending based on provider config and user state
  /// This uses data already fetched during login, avoiding redundant API calls
  List<VerificationType> _calculatePendingVerifications(AccountDetailsModel accountDetails) {
    final pendingVerifications = <VerificationType>[];

    // Check email verification
    if (accountDetails.emailVerificationEnabled && !accountDetails.isEmailVerified) {
      pendingVerifications.add(VerificationType.email);
    }

    // Check phone verification
    if (accountDetails.mobileNumberVerificationEnabled && !accountDetails.isMobileNumberVerified) {
      // TODO: Remove this UK exemption once SMS to UK numbers is fixed
      // This is a temporary workaround for SMS delivery issues to UK numbers
      if (accountDetails.phoneCountryCode != 'GB') {
        pendingVerifications.add(VerificationType.mobile);
      } else {
        // Log UK phone exemption
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.ukPhoneExempted,
          verificationType: 'mobile',
          context: 'signup',
          isUkPhone: true,
        );
      }
    }

    return pendingVerifications;
  }

  Future<void> loadSupportedCountries() async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final response = await _repo.getSupportedCountries();
      // Use provider model if available to set correct total steps
      final totalSteps = _providerModel != null ? _calculateTotalStepsFromProvider(_providerModel) : 2;
      emit(SignupState.createAccount(
        supportedCountries: response.countryCodes,
        flow: const UIFlow.established(),
        totalSteps: totalSteps,
      ));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<Country?> provideUserLocation(UserLocation location) async {
    try {
      // Wait for the initial loadSupportedCountries call to complete
      await _loadSupportedCountriesFuture;

      final nearbyPlaces = await Geocoding().placemarkFromCoordinates(location.latitude, location.longitude);

      Country? currentCountry;

      for (final place in nearbyPlaces) {
        if (place.isoCountryCode != null && place.isoCountryCode!.isNotEmpty) {
          final newCountry = Country.tryParse(place.isoCountryCode!);
          if (newCountry != null) {
            if (state case CreateAccount(:final supportedCountries)) {
              if (supportedCountries.contains(newCountry.countryCode)) {
                currentCountry = newCountry;
                break;
              }
            }
          }
        }
      }

      return currentCountry;
    } catch (e) {
      log('Error while getting user location: $e');
      return null;
    }
  }

  Future<void> signup(BuildContext context, SignupScreenData signupScreenData) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);

    try {
      final Locale appLocale = Localizations.localeOf(context);
      final languageCode = appLocale.languageCode;
      final timeZone = await _timezoneService.getTimezone();

      SignupIndividualModel signupData =
          SignupIndividualModel.fromScreenData(signupScreenData, languageCode, timeZone, 'individual');

      emit(state.copyWith(flow: const UIFlow.loading()));

      final response = await _repo.signup(signupData);

      // Track successful signup
      _mixpanelService.trackSignupCompleted();
      _mixpanelService.trackOnboardingStep(
        MixpanelOnboardingStep.accountCreated,
        MixpanelOnboardingAction.createAccount,
      );
      _mixpanelService.flush();

      // Prefer the session signup itself issued: a password re-login can be
      // interposed by the MFA decision engine (enrolment/verify-email holds),
      // which this flow can't render.
      final session = response.data;
      final sessionToken = session?.token;
      final didLogin = sessionToken != null
          ? await authCubit.completeSignupSession(
              token: sessionToken, deviceToken: session?.deviceToken, email: signupScreenData.email)
          : await authCubit.performLogin(signupScreenData.email, signupScreenData.password);

      if (!didLogin) {
        // Stop here: the verification and payment steps assume a signed-in
        // user, and the account exists — the user can sign in normally.
        if (!isClosed) {
          emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to login'))));
        }
        return;
      }

      // Store signup data for verification flow
      _signupData = signupScreenData;

      // Freeze the Secure Sign-in offer while the user is still factorless —
      // the phone-verification step below can auto-enrol an SMS factor.
      await _freezeMfaSetupOffer();
      if (isClosed) return;

      // Get provider config from auth state (already loaded during login)
      final authState = authCubit.state;
      if (authState is LoggedIn) {
        final accountDetails = authState.profile;

        // Calculate pending verifications using data from login - no additional API call needed
        _requiredVerifications = _calculatePendingVerifications(accountDetails);
      } else {
        // Fallback if not logged in (shouldn't happen)
        _requiredVerifications = [];
      }

      // Calculate total steps using centralized method
      final totalSteps = _calculateTotalSteps(_requiredVerifications);

      // Navigate to appropriate screen based on verifications
      if (_requiredVerifications.isEmpty) {
        // No verifications required, go to payment
        emit(SignupState.offerAddPayment(
          currentStep: 2,
          totalSteps: totalSteps,
        ));
      } else if (_requiredVerifications.contains(VerificationType.mobile)) {
        // Phone verification required
        emit(SignupState.verifyPhone(
          phoneNumber: signupScreenData.phoneNumber,
          phoneCountryCode: signupScreenData.phoneCountry.phoneCode,
          requiredVerifications: _requiredVerifications,
          currentStep: 2,
          totalSteps: totalSteps,
        ));
      } else if (_requiredVerifications.contains(VerificationType.email)) {
        // Email verification required
        emit(SignupState.verifyEmail(
          email: signupScreenData.email,
          requiredVerifications: _requiredVerifications,
          currentStep: 2,
          totalSteps: totalSteps,
        ));
      }

      // Send initial verification code
      if (_requiredVerifications.contains(VerificationType.mobile)) {
        await _verificationRepo.sendVerificationCode(VerificationType.mobile, context: 'signup');
      } else if (_requiredVerifications.contains(VerificationType.email)) {
        await _verificationRepo.sendVerificationCode(VerificationType.email, context: 'signup');
      }
    } on RMApiError catch (e) {
      // Track failed signup
      _mixpanelService.trackSignupFailed(e.cause);
      emit(state.copyWith(flow: UIFlow.error(e)));
    } catch (e) {
      // Track failed signup
      _mixpanelService.trackSignupFailed(e.toString());
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: e.toString()))));
    }
  }

  // Phone verification methods
  Future<bool> verifyPhoneCode(String code) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final success = await _verificationRepo.confirmVerificationCode(code, VerificationType.mobile, context: 'signup');
      
      if (success) {
        // Log successful verification
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.phoneVerificationSuccess,
          verificationType: 'mobile',
          context: 'signup',
        );
        _mixpanelService.trackOnboardingStep(
          MixpanelOnboardingStep.phoneVerificationStep,
          MixpanelOnboardingAction.verify,
        );

        // Move to next verification or payment
        await _navigateToNextStep();
        return true;
      } else {
        // Log verification failure
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.phoneVerificationFailure,
          verificationType: 'mobile',
          context: 'signup',
          errorMessage: 'Invalid code',
        );
        emit(state.copyWith(flow: const UIFlow.established()));
        return false;
      }
    } catch (e) {
      // Log verification failure
      _analytics.logVerificationEvent(
        VerificationAnalyticsType.phoneVerificationFailure,
        verificationType: 'mobile',
        context: 'signup',
        errorMessage: e.toString(),
      );
      // Incorrect code shown as inline error in UI.
      emit(state.copyWith(flow: const UIFlow.established()));
      return false;
    }
  }

  Future<bool> resendPhoneCode() async {
    try {
      final success = await _verificationRepo.sendVerificationCode(VerificationType.mobile, isResend: true, context: 'signup');
      if (success) {
        _mixpanelService.trackOnboardingStep(
          MixpanelOnboardingStep.phoneVerificationStep,
          MixpanelOnboardingAction.resendCode,
        );
      }
      return success;
    } on RMApiError catch (e) {
      log('Failed to resend phone code: $e');
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    } catch (e) {
      log('Failed to resend phone code: $e');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to resend verification code'))));
      return false;
    }
  }

  // Email verification methods
  Future<bool> verifyEmailCode(String code) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final success = await _verificationRepo.confirmVerificationCode(code, VerificationType.email, context: 'signup');
      
      if (success) {
        // Log successful verification
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.emailVerificationSuccess,
          verificationType: 'email',
          context: 'signup',
        );
        _mixpanelService.trackOnboardingStep(
          MixpanelOnboardingStep.emailVerificationStep,
          MixpanelOnboardingAction.verify,
        );

        // Move to next verification or payment
        await _navigateToNextStep();
        return true;
      } else {
        // Log verification failure
        _analytics.logVerificationEvent(
          VerificationAnalyticsType.emailVerificationFailure,
          verificationType: 'email',
          context: 'signup',
          errorMessage: 'Invalid code',
        );
        emit(state.copyWith(flow: const UIFlow.established()));
        return false;
      }
    } catch (e) {
      // Log verification failure
      _analytics.logVerificationEvent(
        VerificationAnalyticsType.emailVerificationFailure,
        verificationType: 'email',
        context: 'signup',
        errorMessage: e.toString(),
      );
      // Incorrect code shown as inline error in UI.
      emit(state.copyWith(flow: const UIFlow.established()));
      return false;
    }
  }

  Future<bool> resendEmailCode() async {
    try {
      final success = await _verificationRepo.sendVerificationCode(VerificationType.email, isResend: true, context: 'signup');
      if (success) {
        _mixpanelService.trackOnboardingStep(
          MixpanelOnboardingStep.emailVerificationStep,
          MixpanelOnboardingAction.resendCode,
        );
      }
      return success;
    } on RMApiError catch (e) {
      log('Failed to resend email code: $e');
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    } catch (e) {
      log('Failed to resend email code: $e');
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Failed to resend verification code'))));
      return false;
    }
  }

  // Navigation helper
  Future<void> _navigateToNextStep() async {
    final signupData = _signupData;
    if (signupData == null) {
      log('Signup data is null during navigation');
      return;
    }

    final currentState = state;

    if (currentState is VerifyPhone) {
      // Check if email verification is also required
      if (_requiredVerifications.contains(VerificationType.email)) {
        emit(SignupState.verifyEmail(
          email: signupData.email,
          requiredVerifications: _requiredVerifications,
          currentStep: currentState.currentStep + 1,
          totalSteps: currentState.totalSteps,
        ));

        // Send email verification code when transitioning to email verification
        try {
          await _verificationRepo.sendVerificationCode(VerificationType.email);
        } catch (e) {
          log('Failed to send email verification code: $e');
        }
      } else {
        // Go to payment - all verifications complete
        emit(SignupState.offerAddPayment(
          currentStep: currentState.currentStep + 1,
          totalSteps: currentState.totalSteps,
        ));
      }
    } else if (currentState is VerifyEmail) {
      // Email is always after phone (if both required), so go to payment
      // All verifications complete
      emit(SignupState.offerAddPayment(
        currentStep: currentState.currentStep + 1,
        totalSteps: currentState.totalSteps,
      ));
    }
  }
}
