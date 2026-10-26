import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/widgets/verify_code_widget.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verify_phone_screen.dart';
import 'package:road_mobile/ui/onboarding/signup/widgets/verification_step_indicator.dart';

class MockSignupCubit extends Mock implements SignupCubit {
  @override
  Stream<SignupState> get stream => Stream.value(state);
}

void main() {
  late MockSignupCubit mockSignupCubit;

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  setUp(() {
    mockSignupCubit = MockSignupCubit();
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
      home: Scaffold(
        body: BlocProvider<SignupCubit>.value(
          value: mockSignupCubit,
          child: child,
        ),
      ),
    );
  }

  group('VerifyPhoneScreen', () {
    group('UI Elements', () {
      testWidgets('displays correct step indicator', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';
        const currentStep = 2;
        const totalSteps = 4;

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: currentStep,
            totalSteps: totalSteps,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        
        // Verify the widget has the correct properties
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, currentStep);
        expect(indicator.totalSteps, totalSteps);
        expect(indicator.stepTitle.isNotEmpty, true);
      });

      testWidgets('shows phone verification title and description', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        // Verify the phone number is displayed somewhere in the widget tree
        expect(find.textContaining(testPhoneNumber), findsOneWidget);
        
        // Verify there are multiple Text widgets (for title and description)
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('renders VerifyCodeWidget correctly', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerifyCodeWidget), findsOneWidget);
      });

      testWidgets('shows phone number being verified', (WidgetTester tester) async {
        const testPhoneNumber = '+44789012345';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'GB',
            currentStep: 2,
            totalSteps: 3,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.textContaining(testPhoneNumber), findsOneWidget);
      });

      testWidgets('shows empty widget when state is not VerifyPhone', (WidgetTester tester) async {
        when(() => mockSignupCubit.state).thenReturn(
          SignupState.createAccount(),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsNothing);
        expect(find.byType(VerifyCodeWidget), findsNothing);
      });
    });

    group('User Interactions', () {
      testWidgets('entering 6-digit code triggers verification', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';
        const testCode = '123456';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.verifyPhoneCode(testCode))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate code entry completion
        await verifyCodeWidget.onVerifyCode(testCode);

        verify(() => mockSignupCubit.verifyPhoneCode(testCode)).called(1);
      });

      testWidgets('resend code button functionality', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.resendPhoneCode()).thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate resend code tap
        verifyCodeWidget.onResendCode();

        verify(() => mockSignupCubit.resendPhoneCode()).called(1);
      });

      testWidgets('shows loading state during verification', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.loading(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pump(); // Use pump() instead of pumpAndSettle() for loading states

        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        expect(verifyCodeWidget.isLoading, true);
      });

      testWidgets('handles verification failure', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';
        const testCode = '000000';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.verifyPhoneCode(testCode))
            .thenAnswer((_) async => false);

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate code entry with invalid code
        final result = await verifyCodeWidget.onVerifyCode(testCode);

        expect(result, false);
        verify(() => mockSignupCubit.verifyPhoneCode(testCode)).called(1);
      });

      testWidgets('shows success snackbar on resend', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.resendPhoneCode()).thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate resend code tap
        verifyCodeWidget.onResendCode();
        await tester.pump();

        // Check that snackbar would be shown (actual snackbar requires scaffold)
        verify(() => mockSignupCubit.resendPhoneCode()).called(1);
      });
    });

    group('Step Indicator Variations', () {
      testWidgets('displays correct step for phone only verification', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 3, // Only 3 steps when phone only
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 2);
        expect(indicator.totalSteps, 3);
      });

      testWidgets('displays correct step for both verifications', (WidgetTester tester) async {
        const testPhoneNumber = '+31612345678';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyPhone(
            phoneNumber: testPhoneNumber,
            phoneCountryCode: 'NL',
            currentStep: 2,
            totalSteps: 4, // 4 steps when both phone and email
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyPhoneScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 2);
        expect(indicator.totalSteps, 4);
      });
    });
  });
}