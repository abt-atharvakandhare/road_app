import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

class MockSignupRepository extends Mock implements SignupRepository {}

class MockVerificationRepository extends Mock implements VerificationRepository {}

class MockMfaFactorsRepository extends Mock implements MfaFactorsRepository {}

class MockAuthCubit extends Mock implements AuthCubit {
  AuthState _state = const AuthState.showSplash();
  
  @override
  Stream<AuthState> get stream => Stream.value(_state);
  
  @override
  AuthState get state => _state;
  
  void setState(AuthState newState) {
    _state = newState;
  }
}

class MockTimezoneService extends Mock implements TimezoneService {}

class MockPasskeyService extends Mock implements PasskeyService {}

class MockAnalytics extends Mock implements Analytics {}

class MockMixpanelService extends Mock implements MixpanelService {}

class FakeSignupIndividualModel extends Fake implements SignupIndividualModel {}

class FakeSignupDataResponseModel extends Fake implements SignupDataResponseModel {}

/// Signup issues a session and the cubit completes it with no pending
/// verifications — the common starting point for post-signup walk tests.
void _stubLoggedInSession(MockSignupRepository mockRepository, MockAuthCubit mockAuthCubit) {
  const accountDetails = AccountDetailsModel(
    accountId: 'test-account',
    name: 'Test User',
    email: 'test@example.com',
    hasCreditCard: false,
    hasRfidCard: false,
    canAddCreditCard: true,
    emailVerificationEnabled: false,
    mobileNumberVerificationEnabled: false,
    isEmailVerified: true,
    isMobileNumberVerified: true,
    remoteSessionEnabledPartyIds: ['EFL'],
  );
  when(() => mockRepository.signup(any())).thenAnswer((_) async =>
      SignupDataResponseModel(data: SignupResponseModel(userId: 'user-1', token: 'signup-token')));
  when(() => mockAuthCubit.completeSignupSession(
      token: any(named: 'token'),
      deviceToken: any(named: 'deviceToken'),
      email: any(named: 'email'))).thenAnswer((_) async {
    mockAuthCubit.setState(const AuthState.loggedIn(accountDetails, 'signup-token'));
    return true;
  });
}

SignupScreenData _signupData() => SignupScreenData(
      email: 'test@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      phoneNumber: '1234567890',
      residenceCountry: Country.tryParse('US')!,
      phoneCountry: Country.tryParse('US')!,
      acceptTos: true,
      acceptProcessData: true,
      iWantToReceiveNews: false,
    );

void main() {
  late SignupCubit cubit;
  late MockSignupRepository mockRepository;
  late MockVerificationRepository mockVerificationRepository;
  late MockAuthCubit mockAuthCubit;
  late MockTimezoneService mockTimezoneService;
  late MockMfaFactorsRepository mockMfaFactorsRepository;
  late MockPasskeyService mockPasskeyService;
  late MockMixpanelService mockMixpanelService;
  late BuildContext testContext;

  setUpAll(() {
    registerFallbackValue(FakeSignupIndividualModel());
    registerFallbackValue(FakeSignupDataResponseModel());
    registerFallbackValue(VerificationType.email);
  });

  setUp(() {
    mockRepository = MockSignupRepository();
    mockVerificationRepository = MockVerificationRepository();
    mockAuthCubit = MockAuthCubit();
    mockTimezoneService = MockTimezoneService();
    mockMfaFactorsRepository = MockMfaFactorsRepository();
    mockPasskeyService = MockPasskeyService();
    mockMixpanelService = MockMixpanelService();

    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);

    // Default: provider MFA off, so the Secure Sign-in step is not offered.
    when(() => mockMfaFactorsRepository.getFactors()).thenAnswer(
        (_) async => MfaFactorsModel(factors: [], permittedMethods: [], mode: MfaMode.off));

    // Set up mock responses before initializing cubit
    when(() => mockRepository.getSupportedCountries())
        .thenAnswer((_) async => SignupCountriesResponseModel(countryCodes: []));
    when(() => mockRepository.signup(any())).thenAnswer((_) async => SignupDataResponseModel());
    when(() => mockAuthCubit.performLogin(any(), any())).thenAnswer((_) async => true);
    when(() => mockTimezoneService.getTimezone()).thenAnswer((_) async => 'UTC');
    when(() => mockVerificationRepository.sendVerificationCode(any()))
        .thenAnswer((_) async => true);

    // Set up Mixpanel mock
    when(() => mockMixpanelService.trackSignupCompleted()).thenReturn(null);
    when(() => mockMixpanelService.trackSignupFailed(any())).thenReturn(null);
    when(() => mockMixpanelService.trackOnboardingStep(any(), any())).thenReturn(null);
    when(() => mockMixpanelService.flush()).thenReturn(null);
  });

  Future<void> setupTestWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: Builder(
            builder: (context) {
              testContext = context;
              return Container();
            },
          ),
        ),
      ),
    );
    final mockAnalytics = MockAnalytics();
    cubit = SignupCubit(mockRepository, mockVerificationRepository, mockMfaFactorsRepository, mockPasskeyService,
        mockTimezoneService, mockAnalytics, mockMixpanelService);
    await tester.pump(); // Wait for widget to build
  }

  group('SignupCubit', () {
    testWidgets('initial state is createAccount with empty supported countries', (WidgetTester tester) async {
      await setupTestWidget(tester);
      await tester.pump(); // Wait for initial loadSupportedCountries to complete

      expect(cubit.state, isA<SignupState>());
      expect(cubit.state.flow, const UIFlow.established());
      expect(
          switch (cubit.state) {
            CreateAccount(:final supportedCountries) => supportedCountries,
            _ => [],
          },
          isEmpty);
    });

    testWidgets('loadSupportedCountries loads supported countries successfully', (WidgetTester tester) async {
      await setupTestWidget(tester);
      final response = SignupCountriesResponseModel(countryCodes: ['US', 'GB']);
      when(() => mockRepository.getSupportedCountries()).thenAnswer((_) async => response);

      await cubit.loadSupportedCountries();
      await tester.pumpAndSettle(); // Wait for all animations and async operations

      expect(
          switch (cubit.state) {
            CreateAccount(:final supportedCountries) => supportedCountries,
            _ => [],
          },
          ['US', 'GB']);
      expect(cubit.state.flow, const UIFlow.established());
    });

    testWidgets('loadSupportedCountries handles error when loading supported countries', (WidgetTester tester) async {
      await setupTestWidget(tester);
      when(() => mockRepository.getSupportedCountries()).thenThrow(RMApiError(cause: 'Failed to load countries'));

      await cubit.loadSupportedCountries();
      await tester.pumpAndSettle(); // Wait for all animations and async operations

      expect(cubit.state.flow.isError, isTrue);
      expect(
          switch (cubit.state.flow) {
            UIFlowError(:final error) => error.cause,
            _ => null,
          },
          'Failed to load countries');
    });

    testWidgets('signup signs up successfully and transitions to offerAddPayment', (WidgetTester tester) async {
      await setupTestWidget(tester);
      
      // Mock the auth state to be logged in with no pending verifications
      final mockAccountDetails = const AccountDetailsModel(
        accountId: 'test-account',
        name: 'Test User',
        email: 'test@example.com',
        hasCreditCard: false,
        hasRfidCard: false,
        canAddCreditCard: true,
        emailVerificationEnabled: false, // No email verification required
        mobileNumberVerificationEnabled: false, // No phone verification required
        isEmailVerified: true,
        isMobileNumberVerified: true,
        remoteSessionEnabledPartyIds: ['EFL'],
      );
      
      // Set the auth state to logged in after performLogin is called
      when(() => mockAuthCubit.performLogin(any(), any())).thenAnswer((_) async {
        mockAuthCubit.setState(AuthState.loggedIn(mockAccountDetails, 'test-token'));
        return true;
      });
      
      final signupData = SignupScreenData(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        residenceCountry: Country.tryParse('US')!,
        phoneCountry: Country.tryParse('US')!,
        acceptTos: true,
        acceptProcessData: true,
        iWantToReceiveNews: false,
      );

      await cubit.signup(testContext, signupData);
      await tester.pumpAndSettle(); // Wait for all animations and async operations

      expect(cubit.state, isA<SignupState>());
      expect(
          switch (cubit.state) {
            OfferAddPayment() => true,
            _ => false,
          },
          true);

      // Verify Mixpanel trackSignupCompleted was called
      verify(() => mockMixpanelService.trackSignupCompleted()).called(1);
      // Verify the account_created journey-step was emitted
      verify(() => mockMixpanelService.trackOnboardingStep(
            MixpanelOnboardingStep.accountCreated,
            MixpanelOnboardingAction.createAccount,
          )).called(1);
      // Verify flush was called after trackSignupCompleted
      verify(() => mockMixpanelService.flush()).called(1);
    });

    testWidgets('signup uses the signup-issued session and skips the password re-login', (WidgetTester tester) async {
      await setupTestWidget(tester);

      final mockAccountDetails = const AccountDetailsModel(
        accountId: 'test-account',
        name: 'Test User',
        email: 'test@example.com',
        hasCreditCard: false,
        hasRfidCard: false,
        canAddCreditCard: true,
        emailVerificationEnabled: false,
        mobileNumberVerificationEnabled: false,
        isEmailVerified: true,
        isMobileNumberVerified: true,
        remoteSessionEnabledPartyIds: ['EFL'],
      );

      when(() => mockRepository.signup(any())).thenAnswer((_) async => SignupDataResponseModel(
          data: SignupResponseModel(userId: 'user-1', token: 'signup-token', deviceToken: 'device-1')));
      when(() => mockAuthCubit.completeSignupSession(
          token: any(named: 'token'),
          deviceToken: any(named: 'deviceToken'),
          email: any(named: 'email'))).thenAnswer((_) async {
        mockAuthCubit.setState(AuthState.loggedIn(mockAccountDetails, 'signup-token'));
        return true;
      });

      final signupData = SignupScreenData(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        residenceCountry: Country.tryParse('US')!,
        phoneCountry: Country.tryParse('US')!,
        acceptTos: true,
        acceptProcessData: true,
        iWantToReceiveNews: false,
      );

      await cubit.signup(testContext, signupData);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<OfferAddPayment>());
      verify(() => mockAuthCubit.completeSignupSession(
          token: 'signup-token', deviceToken: 'device-1', email: 'test@example.com')).called(1);
      verifyNever(() => mockAuthCubit.performLogin(any(), any()));
    });

    testWidgets('signup stays on the form when the sign-in does not complete', (WidgetTester tester) async {
      await setupTestWidget(tester);

      // Token-less signup response falls back to performLogin, which can be
      // held by the MFA decision engine (returns false without a session).
      when(() => mockAuthCubit.performLogin(any(), any())).thenAnswer((_) async => false);

      final signupData = SignupScreenData(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        residenceCountry: Country.tryParse('US')!,
        phoneCountry: Country.tryParse('US')!,
        acceptTos: true,
        acceptProcessData: true,
        iWantToReceiveNews: false,
      );

      await cubit.signup(testContext, signupData);
      await tester.pumpAndSettle();

      expect(cubit.state.flow.isError, isTrue);
      expect(cubit.state, isNot(isA<OfferAddPayment>()));
      expect(cubit.state, isA<CreateAccount>());
    });

    testWidgets('MFA-off signup completes straight after the payment step', (WidgetTester tester) async {
      await setupTestWidget(tester);
      _stubLoggedInSession(mockRepository, mockAuthCubit);

      await cubit.signup(testContext, _signupData());
      await tester.pumpAndSettle();
      expect(cubit.state, isA<OfferAddPayment>());

      cubit.advanceFromPayment();

      expect(cubit.state, isA<SignupCompleted>());
    });

    testWidgets('factorless user under encourage gets the Secure Sign-in step after payment',
        (WidgetTester tester) async {
      await setupTestWidget(tester);
      _stubLoggedInSession(mockRepository, mockAuthCubit);
      // Frozen while factorless — the step must survive the SMS auto-enrolment
      // that phone verification performs later in the journey.
      when(() => mockMfaFactorsRepository.getFactors()).thenAnswer((_) async => MfaFactorsModel(
          factors: [], permittedMethods: [MfaMethod.totp, MfaMethod.sms], mode: MfaMode.encourage));

      await cubit.signup(testContext, _signupData());
      await tester.pumpAndSettle();
      expect(cubit.state, isA<OfferAddPayment>());
      // No verifications: create + payment + Secure Sign-in.
      expect((cubit.state as OfferAddPayment).totalSteps, 3);

      cubit.advanceFromPayment();
      expect(cubit.state, isA<OfferMfaSetup>());
      expect((cubit.state as OfferMfaSetup).currentStep, 3);

      cubit.completeMfaSetup(skipped: true);
      expect(cubit.state, isA<SignupCompleted>());
    });

    testWidgets('an already-factored user is not offered the step', (WidgetTester tester) async {
      await setupTestWidget(tester);
      _stubLoggedInSession(mockRepository, mockAuthCubit);
      when(() => mockMfaFactorsRepository.getFactors()).thenAnswer((_) async => MfaFactorsModel(
          factors: [
            MfaFactorModel(id: 'f1', type: MfaMethod.sms, status: MfaFactorStatus.active),
          ],
          permittedMethods: [MfaMethod.totp, MfaMethod.sms],
          mode: MfaMode.encourage));

      await cubit.signup(testContext, _signupData());
      await tester.pumpAndSettle();

      cubit.advanceFromPayment();

      expect(cubit.state, isA<SignupCompleted>());
    });

    testWidgets('a failed factors fetch skips the step instead of blocking signup',
        (WidgetTester tester) async {
      await setupTestWidget(tester);
      _stubLoggedInSession(mockRepository, mockAuthCubit);
      when(() => mockMfaFactorsRepository.getFactors()).thenThrow(RMApiError(cause: 'network'));

      await cubit.signup(testContext, _signupData());
      await tester.pumpAndSettle();
      expect(cubit.state, isA<OfferAddPayment>());

      cubit.advanceFromPayment();

      expect(cubit.state, isA<SignupCompleted>());
    });

    testWidgets('signup handles error during signup', (WidgetTester tester) async {
      await setupTestWidget(tester);
      final signupData = SignupScreenData(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '1234567890',
        residenceCountry: Country.tryParse('US')!,
        phoneCountry: Country.tryParse('US')!,
        acceptTos: true,
        acceptProcessData: true,
        iWantToReceiveNews: false,
      );

      when(() => mockRepository.signup(any())).thenThrow(RMApiError(cause: 'Signup failed'));

      await cubit.signup(testContext, signupData);
      await tester.pumpAndSettle(); // Wait for all animations and async operations

      expect(cubit.state.flow.isError, isTrue);
      expect(
          switch (cubit.state.flow) {
            UIFlowError(:final error) => error.cause,
            _ => null,
          },
          'Signup failed');

      // Verify Mixpanel trackSignupFailed was called with the error message
      verify(() => mockMixpanelService.trackSignupFailed('Signup failed')).called(1);
    });
  });
}
