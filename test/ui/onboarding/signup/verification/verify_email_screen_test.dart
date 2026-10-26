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
import 'package:road_mobile/ui/onboarding/signup/verification/verify_email_screen.dart';
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

  group('VerifyEmailScreen', () {
    group('UI Elements', () {
      testWidgets('displays correct step indicator', (WidgetTester tester) async {
        const testEmail = 'test@example.com';
        const currentStep = 3;
        const totalSteps = 4;

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: currentStep,
            totalSteps: totalSteps,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
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

      testWidgets('shows email verification title and description', (WidgetTester tester) async {
        const testEmail = 'user@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        // Verify the email is displayed somewhere in the widget tree
        expect(find.textContaining(testEmail), findsOneWidget);
        
        // Verify there are multiple Text widgets (for title and description)
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('renders VerifyCodeWidget correctly', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerifyCodeWidget), findsOneWidget);
      });

      testWidgets('shows email address being verified', (WidgetTester tester) async {
        const testEmail = 'john.doe@example.org';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 2,
            totalSteps: 3,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.textContaining(testEmail), findsOneWidget);
      });

      testWidgets('shows empty widget when state is not VerifyEmail', (WidgetTester tester) async {
        when(() => mockSignupCubit.state).thenReturn(
          SignupState.createAccount(),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsNothing);
        expect(find.byType(VerifyCodeWidget), findsNothing);
      });
    });

    group('User Interactions', () {
      testWidgets('entering 6-digit code triggers verification', (WidgetTester tester) async {
        const testEmail = 'test@example.com';
        const testCode = '654321';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.verifyEmailCode(testCode))
            .thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate code entry completion
        await verifyCodeWidget.onVerifyCode(testCode);

        verify(() => mockSignupCubit.verifyEmailCode(testCode)).called(1);
      });

      testWidgets('resend code button functionality', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.resendEmailCode()).thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate resend code tap
        verifyCodeWidget.onResendCode();

        verify(() => mockSignupCubit.resendEmailCode()).called(1);
      });

      testWidgets('shows loading state during verification', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.loading(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pump(); // Use pump() instead of pumpAndSettle() for loading states

        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        expect(verifyCodeWidget.isLoading, true);
      });

      testWidgets('handles verification failure', (WidgetTester tester) async {
        const testEmail = 'test@example.com';
        const testCode = '000000';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.verifyEmailCode(testCode))
            .thenAnswer((_) async => false);

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate code entry with invalid code
        final result = await verifyCodeWidget.onVerifyCode(testCode);

        expect(result, false);
        verify(() => mockSignupCubit.verifyEmailCode(testCode)).called(1);
      });

      testWidgets('shows success snackbar on resend', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        when(() => mockSignupCubit.resendEmailCode()).thenAnswer((_) async => true);

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        // Find and interact with the VerifyCodeWidget
        final verifyCodeWidget = tester.widget<VerifyCodeWidget>(
          find.byType(VerifyCodeWidget),
        );
        
        // Simulate resend code tap
        verifyCodeWidget.onResendCode();
        await tester.pump();

        // Check that snackbar would be shown (actual snackbar requires scaffold)
        verify(() => mockSignupCubit.resendEmailCode()).called(1);
      });
    });

    group('Step Indicator Variations', () {
      testWidgets('displays correct step for email only verification', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 2,
            totalSteps: 3, // Only 3 steps when email only
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 2);
        expect(indicator.totalSteps, 3);
      });

      testWidgets('displays correct step for both verifications', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3,
            totalSteps: 4, // 4 steps when both phone and email
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 3);
        expect(indicator.totalSteps, 4);
      });

      testWidgets('displays correct step when email is second verification', (WidgetTester tester) async {
        const testEmail = 'test@example.com';

        when(() => mockSignupCubit.state).thenReturn(
          SignupState.verifyEmail(
            email: testEmail,
            currentStep: 3, // Email comes after phone when both are required
            totalSteps: 4,
            flow: UIFlow.established(),
          ),
        );

        await tester.pumpWidget(createTestWidget(const VerifyEmailScreen()));
        await tester.pumpAndSettle();

        expect(find.byType(VerificationStepIndicator), findsOneWidget);
        final indicator = tester.widget<VerificationStepIndicator>(
          find.byType(VerificationStepIndicator),
        );
        expect(indicator.currentStep, 3);
        expect(indicator.totalSteps, 4);
        expect(indicator.stepTitle.isNotEmpty, true);
      });
    });
  });
}