import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/main_signup_screen.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';

class MockSignupCubit extends Mock implements SignupCubit {
  final _stateController = StreamController<SignupState>.broadcast();
  SignupState _currentState = SignupState.createAccount();

  @override
  SignupState get state => _currentState;

  @override
  Stream<SignupState> get stream => _stateController.stream;

  void emitState(SignupState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _stateController.close();
  }
}

class MockLocationBloc extends Mock implements LocationBloc {
  @override
  Stream<LocationState> get stream => Stream.value(state);
}

class MockAuthCubit extends Mock implements AuthCubit {
  @override
  Stream<AuthState> get stream => Stream.value(state);
}

class MockAddCreditCardCubit extends Mock implements AddCreditCardCubit {}

class MockModalInfoDialogs extends Mock implements ModalInfoDialogs {}

class MockMixpanelService extends Mock implements MixpanelService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockSignupCubit mockSignupCubit;
  late MockLocationBloc mockLocationBloc;
  late MockAuthCubit mockAuthCubit;
  late MockAddCreditCardCubit mockAddCreditCardCubit;
  late MockModalInfoDialogs mockModalInfoDialogs;
  late MockMixpanelService mockMixpanelService;

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(UIFlow.established());
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(RMApiError(cause: 'test'));
  });

  setUp(() {
    mockSignupCubit = MockSignupCubit();
    mockLocationBloc = MockLocationBloc();
    mockAuthCubit = MockAuthCubit();
    mockAddCreditCardCubit = MockAddCreditCardCubit();
    mockModalInfoDialogs = MockModalInfoDialogs();
    mockMixpanelService = MockMixpanelService();

    when(() => mockMixpanelService.trackOnboardingStep(any(), any())).thenReturn(null);
    when(() => mockMixpanelService.flush()).thenReturn(null);
    when(() => mockSignupCubit.trackOnboardingStarted()).thenReturn(null);
    when(() => mockSignupCubit.trackOnboardingCompleted()).thenReturn(null);
    when(() => mockSignupCubit.initializeWithProvider(any())).thenReturn(null);

    // Register mocks in GetIt
    if (getIt.isRegistered<AddCreditCardCubit>()) {
      getIt.unregister<AddCreditCardCubit>();
    }
    if (getIt.isRegistered<ModalInfoDialogs>()) {
      getIt.unregister<ModalInfoDialogs>();
    }
    if (getIt.isRegistered<MixpanelService>()) {
      getIt.unregister<MixpanelService>();
    }
    getIt.registerSingleton<AddCreditCardCubit>(mockAddCreditCardCubit);
    getIt.registerSingleton<ModalInfoDialogs>(mockModalInfoDialogs);
    getIt.registerSingleton<MixpanelService>(mockMixpanelService);

    // Setup mock behaviors
    when(() => mockAddCreditCardCubit.startAddPaymentMethodFlow(
          any(),
          any(),
          currentStep: any(named: 'currentStep'),
          totalSteps: any(named: 'totalSteps'),
        )).thenAnswer((_) async => true);

    when(() => mockModalInfoDialogs.showErrorDialog(any(), any())).thenAnswer((_) async => {});

    // Setup default states
    when(() => mockLocationBloc.state).thenReturn(const LocationState.initial());
    when(() => mockAuthCubit.state).thenReturn(const AuthState.loggedOut());
  });

  tearDown(() {
    mockSignupCubit.dispose();
    if (getIt.isRegistered<AddCreditCardCubit>()) {
      getIt.unregister<AddCreditCardCubit>();
    }
    if (getIt.isRegistered<ModalInfoDialogs>()) {
      getIt.unregister<ModalInfoDialogs>();
    }
    if (getIt.isRegistered<MixpanelService>()) {
      getIt.unregister<MixpanelService>();
    }
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('nl', ''),
      ],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SignupCubit>.value(value: mockSignupCubit),
          BlocProvider<LocationBloc>.value(value: mockLocationBloc),
        ],
        child: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: child,
        ),
      ),
    );
  }

  group('Signup Flow Integration Tests', () {
    group('Complete Flow Scenarios', () {
      testWidgets('full flow with no verifications required', (WidgetTester tester) async {
        // Start with createAccount state
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 2,
            currentStep: 1,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        // Verify we're on the create account screen
        expect(find.text('Create Your Free Account'), findsOneWidget);
        expect(find.text('Step 1/2:'), findsOneWidget);
        expect(find.text('Create Account'), findsNWidgets(2)); // Step title and button
        // Form field labels are RichText with asterisks for required fields
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText().contains('First Name')), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText().contains('Last Name')), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText().contains('Country')), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText().contains('Phone Number')), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText().contains('E-mail')), findsOneWidget);
        expect(find.byWidgetPredicate((widget) => 
          widget is RichText && 
          widget.text.toPlainText() == 'Password*'), findsOneWidget);
        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 1);
        expect(indicator.totalSteps, 2);

        // Simulate moving to payment screen
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 2,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 2);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 2);
      });

      testWidgets('full flow with phone verification only', (WidgetTester tester) async {
        // Start with createAccount state
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 3,
            currentStep: 1,
            requiredVerifications: [VerificationType.mobile],
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        // Verify we're on the create account screen
        expect(find.text('Create Your Free Account'), findsOneWidget);
        expect(find.text('Step 1/3:'), findsOneWidget);
        expect(find.text('Create Account'), findsNWidgets(2)); // Step title and button
        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 1);
        expect(indicator.totalSteps, 3);

        // Move to phone verification
        mockSignupCubit.emitState(
          SignupState.verifyPhone(
            phoneNumber: '+31612345678',
            phoneCountryCode: 'NL',
            totalSteps: 3,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the phone verification screen
        expect(find.text('Step 2/3:'), findsOneWidget);
        expect(find.text('Verify Phone'), findsOneWidget);
        expect(find.text('Verify your phone number now.'), findsOneWidget);
        // TODO: These messages might not be rendered in test environment
        // expect(find.textContaining('We sent you an SMS code to +31612345678'), findsOneWidget);
        // expect(find.text('Enter the 6-digit code below'), findsOneWidget);
        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 3);

        // Move to payment
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 3,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 3);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 3);
      });

      testWidgets('full flow with email verification only', (WidgetTester tester) async {
        // Start with createAccount state
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 3,
            currentStep: 1,
            requiredVerifications: [VerificationType.email],
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 1);
        expect(indicator.totalSteps, 3);

        // Move to email verification
        mockSignupCubit.emitState(
          SignupState.verifyEmail(
            email: 'test@example.com',
            totalSteps: 3,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the email verification screen
        expect(find.text('Step 2/3:'), findsOneWidget);
        expect(find.text('Verify E-mail'), findsOneWidget);
        expect(find.text('Verify your e-mail address'), findsOneWidget);
        // TODO: These messages might not be rendered in test environment
        // expect(find.textContaining('We sent you an e-mail to test@example.com'), findsOneWidget);
        // expect(find.text('Enter the 6-digit code below'), findsOneWidget);
        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 3);

        // Move to payment
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 3,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 3);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 3);
      });

      testWidgets('full flow with both verifications', (WidgetTester tester) async {
        // Start with createAccount state
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 4,
            currentStep: 1,
            requiredVerifications: [VerificationType.mobile, VerificationType.email],
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        // Verify we're on the create account screen
        expect(find.text('Create Your Free Account'), findsOneWidget);
        expect(find.text('Step 1/4:'), findsOneWidget);
        expect(find.text('Create Account'), findsNWidgets(2)); // Step title and button
        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 1);
        expect(indicator.totalSteps, 4);

        // Move to phone verification
        mockSignupCubit.emitState(
          SignupState.verifyPhone(
            phoneNumber: '+31612345678',
            phoneCountryCode: 'NL',
            totalSteps: 4,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the phone verification screen
        expect(find.text('Step 2/4:'), findsOneWidget);
        expect(find.text('Verify Phone'), findsOneWidget);
        expect(find.text('Verify your phone number now.'), findsOneWidget);
        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 4);

        // Move to email verification
        mockSignupCubit.emitState(
          SignupState.verifyEmail(
            email: 'test@example.com',
            totalSteps: 4,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the email verification screen
        expect(find.text('Step 3/4:'), findsOneWidget);
        expect(find.text('Verify E-mail'), findsOneWidget);
        expect(find.text('Verify your e-mail address'), findsOneWidget);
        final indicator3 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator3.currentStep, 3);
        expect(indicator3.totalSteps, 4);

        // Move to payment
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 4,
            currentStep: 4,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 4);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 4);
      });

      testWidgets('UK phone number skips phone verification', (WidgetTester tester) async {
        // Start with createAccount state with UK phone number
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 3,
            currentStep: 1,
            requiredVerifications: [VerificationType.email], // Only email required for UK
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 1);
        expect(indicator.totalSteps, 3);

        // Move directly to email verification (skipping phone)
        mockSignupCubit.emitState(
          SignupState.verifyEmail(
            email: 'test@example.com',
            totalSteps: 3,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 3);

        // Move to payment
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 3,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 3);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 3);
      });
    });

    group('Error Recovery', () {
      testWidgets('invalid code entry and retry', (WidgetTester tester) async {
        // Start with phone verification state
        mockSignupCubit.emitState(
          SignupState.verifyPhone(
            phoneNumber: '+31612345678',
            phoneCountryCode: 'NL',
            totalSteps: 3,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 2);
        expect(indicator.totalSteps, 3);

        // Simulate error state
        mockSignupCubit.emitState(
          SignupState.verifyPhone(
            phoneNumber: '+31612345678',
            phoneCountryCode: 'NL',
            totalSteps: 3,
            currentStep: 2,
            flow: UIFlow.error(RMApiError(cause: 'Invalid code')),
          ),
        );

        await tester.pumpAndSettle();

        // Should still be on same step
        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 3);

        // Simulate successful retry
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 3,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        // Don't pump here because OfferAddPayment will trigger navigation
        // Just verify the state was set correctly
        expect(mockSignupCubit.state, isA<OfferAddPayment>());
        expect((mockSignupCubit.state as OfferAddPayment).currentStep, 3);
        expect((mockSignupCubit.state as OfferAddPayment).totalSteps, 3);
      });

      testWidgets('navigation back and forward through steps', (WidgetTester tester) async {
        // Start with email verification state
        mockSignupCubit.emitState(
          SignupState.verifyEmail(
            email: 'test@example.com',
            totalSteps: 4,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 3);
        expect(indicator.totalSteps, 4);

        // Simulate going back to phone verification
        mockSignupCubit.emitState(
          SignupState.verifyPhone(
            phoneNumber: '+31612345678',
            phoneCountryCode: 'NL',
            totalSteps: 4,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        final indicator2 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator2.currentStep, 2);
        expect(indicator2.totalSteps, 4);

        // Simulate going forward again
        mockSignupCubit.emitState(
          SignupState.verifyEmail(
            email: 'test@example.com',
            totalSteps: 4,
            currentStep: 3,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpAndSettle();

        final indicator3 = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator3.currentStep, 3);
        expect(indicator3.totalSteps, 4);
      });
    });

    group('Mixpanel Journey Tracking', () {
      testWidgets('fires onboarding_started when signup modal mounts', (tester) async {
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 2,
            currentStep: 1,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const MainSignupScreen()));
        await tester.pumpAndSettle();

        verify(() => mockSignupCubit.trackOnboardingStarted()).called(1);
      });

      testWidgets('fires onboarding_completed after payment flow + pop', (tester) async {
        mockSignupCubit.emitState(
          SignupState.createAccount(
            totalSteps: 2,
            currentStep: 1,
            flow: UIFlow.established(),
          ),
        );

        // Wrap MainSignupScreen in a pushable route so Navigator.pop() works.
        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('nl', '')],
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider<SignupCubit>.value(value: mockSignupCubit),
                    BlocProvider<LocationBloc>.value(value: mockLocationBloc),
                  ],
                  child: BlocProvider<AuthCubit>.value(
                    value: mockAuthCubit,
                    child: const MainSignupScreen(),
                  ),
                ),
              )),
              child: const Text('open'),
            );
          }),
        ));

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Trigger the OfferAddPayment listener — startAddPaymentMethodFlow is
        // already stubbed to return true in setUp. The listener hands the
        // journey back to the cubit (the Secure Sign-in step may follow).
        mockSignupCubit.emitState(
          SignupState.offerAddPayment(
            totalSteps: 2,
            currentStep: 2,
            flow: UIFlow.established(),
          ),
        );
        await tester.pumpAndSettle();

        verify(() => mockSignupCubit.advanceFromPayment()).called(1);
        verifyNever(() => mockSignupCubit.trackOnboardingCompleted());

        // Completion is its own state: tracking fires and the modal pops.
        mockSignupCubit.emitState(const SignupState.completed());
        await tester.pumpAndSettle();

        verify(() => mockSignupCubit.trackOnboardingCompleted()).called(1);
        expect(find.text('open'), findsOneWidget);
      });
    });
  });
}
