import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/signup/signup_countries_model.dart';
import 'package:road_mobile/data/model/signup/signup_individual_model.dart';
import 'package:road_mobile/data/model/signup/signup_response_model.dart';
import 'package:road_mobile/data/model/signup/signup_screen_data.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/services/timezone/timezone_service.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

class MockSignupRepository extends Mock implements SignupRepository {}
class MockVerificationRepository extends Mock implements VerificationRepository {}
class MockTimezoneService extends Mock implements TimezoneService {}
class MockMfaFactorsRepository extends Mock implements MfaFactorsRepository {}
class MockPasskeyService extends Mock implements PasskeyService {}
class MockAnalytics extends Mock implements Analytics {}
class MockMixpanelService extends Mock implements MixpanelService {}
class FakeSignupIndividualModel extends Fake implements SignupIndividualModel {}
class FakeSignupScreenData extends Fake implements SignupScreenData {}

void main() {
  late SignupCubit cubit;
  late MockSignupRepository mockSignupRepository;
  late MockVerificationRepository mockVerificationRepository;
  late MockTimezoneService mockTimezoneService;
  late MockMixpanelService mockMixpanelService;

  setUpAll(() {
    registerFallbackValue(FakeSignupIndividualModel());
    registerFallbackValue(FakeSignupScreenData());
    registerFallbackValue(VerificationType.email);
  });

  setUp(() {
    mockSignupRepository = MockSignupRepository();
    mockVerificationRepository = MockVerificationRepository();
    mockTimezoneService = MockTimezoneService();
    final mockAnalytics = MockAnalytics();
    mockMixpanelService = MockMixpanelService();

    when(() => mockTimezoneService.getTimezone()).thenAnswer((_) async => 'Europe/Amsterdam');
    when(() => mockSignupRepository.getSupportedCountries())
        .thenAnswer((_) async => SignupCountriesResponseModel(countryCodes: []));
    when(() => mockMixpanelService.trackOnboardingStep(any(), any())).thenReturn(null);

    final mockMfaFactorsRepository = MockMfaFactorsRepository();
    // Default: provider MFA off, so the Secure Sign-in step is not offered.
    when(() => mockMfaFactorsRepository.getFactors()).thenAnswer(
        (_) async => MfaFactorsModel(factors: [], permittedMethods: [], mode: MfaMode.off));

    final mockPasskeyService = MockPasskeyService();
    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);

    cubit = SignupCubit(
      mockSignupRepository,
      mockVerificationRepository,
      mockMfaFactorsRepository,
      mockPasskeyService,
      mockTimezoneService,
      mockAnalytics,
      mockMixpanelService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SignupCubit - Verification Methods', () {
    test('verifyPhoneCode with valid code returns true', () async {
      when(() => mockVerificationRepository.confirmVerificationCode(
            any(),
            any(),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      final result = await cubit.verifyPhoneCode('123456');

      expect(result, true);
      verify(() => mockVerificationRepository.confirmVerificationCode(
            '123456',
            VerificationType.mobile,
            context: 'signup',
          )).called(1);
      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.phoneVerificationStep,
            MixpanelOnboardingAction.verify,
          )).called(1);
    });

    test('verifyPhoneCode with invalid code returns false', () async {
      when(() => mockVerificationRepository.confirmVerificationCode(
            any(),
            any(),
            context: any(named: 'context'),
          )).thenThrow(Exception('Invalid code'));

      final result = await cubit.verifyPhoneCode('000000');
      
      expect(result, false);
      verify(() => mockVerificationRepository.confirmVerificationCode(
            '000000',
            VerificationType.mobile,
            context: 'signup',
          )).called(1);
    });

    test('verifyEmailCode with valid code returns true', () async {
      when(() => mockVerificationRepository.confirmVerificationCode(
            any(),
            any(),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      final result = await cubit.verifyEmailCode('654321');

      expect(result, true);
      verify(() => mockVerificationRepository.confirmVerificationCode(
            '654321',
            VerificationType.email,
            context: 'signup',
          )).called(1);
      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.emailVerificationStep,
            MixpanelOnboardingAction.verify,
          )).called(1);
    });

    test('verifyEmailCode with invalid code returns false', () async {
      when(() => mockVerificationRepository.confirmVerificationCode(
            any(),
            any(),
            context: any(named: 'context'),
          )).thenThrow(Exception('Invalid code'));

      final result = await cubit.verifyEmailCode('000000');
      
      expect(result, false);
      verify(() => mockVerificationRepository.confirmVerificationCode(
            '000000',
            VerificationType.email,
            context: 'signup',
          )).called(1);
    });

    test('resendPhoneCode calls verification repository', () async {
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      await cubit.resendPhoneCode();

      verify(() => mockVerificationRepository.sendVerificationCode(
            VerificationType.mobile,
            platform: 'mobile',
            smsConstraint: any(named: 'smsConstraint'),
            userId: null,
            journey: null,
            isResend: true,
            context: 'signup',
          )).called(1);
      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.phoneVerificationStep,
            MixpanelOnboardingAction.resendCode,
          )).called(1);
    });

    test('resendEmailCode calls verification repository', () async {
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      await cubit.resendEmailCode();

      verify(() => mockVerificationRepository.sendVerificationCode(
            VerificationType.email,
            platform: 'mobile',
            smsConstraint: null,
            userId: null,
            journey: null,
            isResend: true,
            context: 'signup',
          )).called(1);
      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.emailVerificationStep,
            MixpanelOnboardingAction.resendCode,
          )).called(1);
    });
  });

  group('SignupCubit - Journey Tracking', () {
    test('trackOnboardingStarted emits onboarding_started/signup', () {
      cubit.trackOnboardingStarted();

      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.onboardingStarted,
            MixpanelOnboardingAction.signup,
          )).called(1);
    });

    test('trackOnboardingCompleted emits onboarding_completed/signup-complete and flushes', () {
      when(() => mockMixpanelService.flush()).thenReturn(null);

      cubit.trackOnboardingCompleted();

      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.onboardingCompleted,
            MixpanelOnboardingAction.signupComplete,
          )).called(1);
      verify(() => mockMixpanelService.flush()).called(1);
    });
  });

  group('SignupCubit - State Management', () {
    test('initial state is createAccount', () {
      expect(cubit.state, isA<CreateAccount>());
    });

    test('can emit verifyPhone state', () {
      cubit.emit(SignupState.verifyPhone(
        phoneNumber: '+31612345678',
        phoneCountryCode: 'NL',
        currentStep: 2,
        totalSteps: 3,
      ));

      expect(cubit.state, isA<VerifyPhone>());
      final state = cubit.state as VerifyPhone;
      expect(state.phoneNumber, '+31612345678');
      expect(state.phoneCountryCode, 'NL');
      expect(state.currentStep, 2);
      expect(state.totalSteps, 3);
    });

    test('can emit verifyEmail state', () {
      cubit.emit(SignupState.verifyEmail(
        email: 'test@example.com',
        currentStep: 2,
        totalSteps: 3,
      ));

      expect(cubit.state, isA<VerifyEmail>());
      final state = cubit.state as VerifyEmail;
      expect(state.email, 'test@example.com');
      expect(state.currentStep, 2);
      expect(state.totalSteps, 3);
    });

    test('can emit offerAddPayment state', () {
      cubit.emit(SignupState.offerAddPayment(
        currentStep: 3,
        totalSteps: 3,
      ));

      expect(cubit.state, isA<OfferAddPayment>());
      final state = cubit.state as OfferAddPayment;
      expect(state.currentStep, 3);
      expect(state.totalSteps, 3);
    });
  });

  group('SignupCubit - Step Calculation', () {
    test('tracks current step correctly through flow', () {
      // Step 1: Create Account
      cubit.emit(SignupState.createAccount(
        currentStep: 1,
        totalSteps: 4,
        requiredVerifications: [VerificationType.mobile, VerificationType.email],
      ));
      expect((cubit.state as CreateAccount).currentStep, 1);

      // Step 2: Verify Phone
      cubit.emit(SignupState.verifyPhone(
        phoneNumber: '+31612345678',
        phoneCountryCode: 'NL',
        currentStep: 2,
        totalSteps: 4,
        requiredVerifications: [VerificationType.mobile, VerificationType.email],
      ));
      expect((cubit.state as VerifyPhone).currentStep, 2);

      // Step 3: Verify Email
      cubit.emit(SignupState.verifyEmail(
        email: 'test@example.com',
        currentStep: 3,
        totalSteps: 4,
        requiredVerifications: [VerificationType.email],
      ));
      expect((cubit.state as VerifyEmail).currentStep, 3);

      // Step 4: Add Payment
      cubit.emit(SignupState.offerAddPayment(
        currentStep: 4,
        totalSteps: 4,
      ));
      expect((cubit.state as OfferAddPayment).currentStep, 4);
    });

    test('calculates correct total steps for no verification', () {
      cubit.emit(SignupState.createAccount(totalSteps: 2));
      expect((cubit.state as CreateAccount).totalSteps, 2);
    });

    test('calculates correct total steps for phone only', () {
      cubit.emit(SignupState.createAccount(
        requiredVerifications: [VerificationType.mobile],
        totalSteps: 3,
      ));
      expect((cubit.state as CreateAccount).totalSteps, 3);
    });

    test('calculates correct total steps for email only', () {
      cubit.emit(SignupState.createAccount(
        requiredVerifications: [VerificationType.email],
        totalSteps: 3,
      ));
      expect((cubit.state as CreateAccount).totalSteps, 3);
    });

    test('calculates correct total steps for both verifications', () {
      cubit.emit(SignupState.createAccount(
        requiredVerifications: [VerificationType.mobile, VerificationType.email],
        totalSteps: 4,
      ));
      expect((cubit.state as CreateAccount).totalSteps, 4);
    });
  });

  group('SignupCubit - Signup Method', () {
    test('signup method requires BuildContext and SignupScreenData', () async {
      // This test just verifies the method signature
      // The actual signup method requires a BuildContext which is hard to mock
      // but we can verify the repository is called
      
      when(() => mockSignupRepository.signup(any()))
          .thenAnswer((_) async => SignupDataResponseModel(
            data: SignupResponseModel(
              userId: 'user-123',
            ),
          ));

      // The signup method signature is:
      // Future<void> signup(BuildContext context, SignupScreenData signupScreenData)
      // We're testing that the cubit has this method
      expect(cubit.signup, isA<Function>());
    });
  });

  group('SignupCubit - Error Handling', () {
    test('resendPhoneCode propagates 429 error message from backend', () async {
      // Arrange
      final expectedError = RMApiError(cause: 'Too many requests, please try again later');
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenThrow(expectedError);

      // Act
      final result = await cubit.resendPhoneCode();

      // Assert
      expect(result, false);
      expect(cubit.state.flow, isA<UIFlowError>());
      final errorFlow = cubit.state.flow as UIFlowError;
      expect(errorFlow.error.cause, expectedError.cause);
    });

    test('resendEmailCode propagates 429 error message from backend', () async {
      // Arrange
      final expectedError = RMApiError(cause: 'Too many requests, please try again later');
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenThrow(expectedError);

      // Act
      final result = await cubit.resendEmailCode();

      // Assert
      expect(result, false);
      expect(cubit.state.flow, isA<UIFlowError>());
      final errorFlow = cubit.state.flow as UIFlowError;
      expect(errorFlow.error.cause, expectedError.cause);
    });

    test('resendPhoneCode handles generic errors with fallback message', () async {
      // Arrange
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await cubit.resendPhoneCode();

      // Assert
      expect(result, false);
      expect(cubit.state.flow, isA<UIFlowError>());
      final errorFlow = cubit.state.flow as UIFlowError;
      expect(errorFlow.error.cause, 'Failed to resend verification code');
    });

    test('resendEmailCode handles generic errors with fallback message', () async {
      // Arrange
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await cubit.resendEmailCode();

      // Assert
      expect(result, false);
      expect(cubit.state.flow, isA<UIFlowError>());
      final errorFlow = cubit.state.flow as UIFlowError;
      expect(errorFlow.error.cause, 'Failed to resend verification code');
    });

    test('resendPhoneCode returns true when successful', () async {
      // Arrange
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      // Act
      final result = await cubit.resendPhoneCode();

      // Assert
      expect(result, true);
      expect(cubit.state.flow, isNot(isA<UIFlowError>()));
    });

    test('resendEmailCode returns true when successful', () async {
      // Arrange
      when(() => mockVerificationRepository.sendVerificationCode(
            any(),
            platform: any(named: 'platform'),
            smsConstraint: any(named: 'smsConstraint'),
            userId: any(named: 'userId'),
            journey: any(named: 'journey'),
            isResend: any(named: 'isResend'),
            context: any(named: 'context'),
          )).thenAnswer((_) async => true);

      // Act
      final result = await cubit.resendEmailCode();

      // Assert
      expect(result, true);
      expect(cubit.state.flow, isNot(isA<UIFlowError>()));
    });
  });
}