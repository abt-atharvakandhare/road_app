import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';

void main() {
  group('MixpanelService', () {
    late MixpanelService service;

    setUp(() {
      service = MixpanelService();
    });

    group('when not initialized', () {
      test('isEnabled returns false', () {
        expect(service.isEnabled, isFalse);
      });

      test('trackPageView does not throw', () {
        expect(() => service.trackPageView('/home'), returnsNormally);
      });

      test('trackButtonClick does not throw', () {
        expect(() => service.trackButtonClick('/login'), returnsNormally);
      });

      test('trackSignupCompleted does not throw', () {
        expect(() => service.trackSignupCompleted(), returnsNormally);
      });

      test('trackSignupFailed does not throw', () {
        expect(() => service.trackSignupFailed('Error message'), returnsNormally);
      });

      test('trackOnboardingStep does not throw', () {
        expect(
          () => service.trackOnboardingStep(
            MixpanelOnboardingStep.onboardingStarted,
            MixpanelOnboardingAction.signup,
          ),
          returnsNormally,
        );
      });

      test('identify does not throw', () {
        expect(() => service.identify('user-123', email: 'test@example.com'), returnsNormally);
      });

      test('reset does not throw', () {
        expect(() => service.reset(), returnsNormally);
      });
    });

    group('server URL', () {
      test('points at the EU data residency endpoint', () {
        expect(MixpanelService.serverUrl, 'https://api-eu.mixpanel.com');
      });
    });

    group('MixpanelEvents constants', () {
      test('event names are correctly defined', () {
        expect(MixpanelEvents.pageViewed, 'Page Viewed');
        expect(MixpanelEvents.buttonClicked, 'Button Clicked');
        expect(MixpanelEvents.signupCompleted, 'Signup Completed');
        expect(MixpanelEvents.signupFailed, 'Signup Failed');
        expect(MixpanelEvents.onboardingJourneyStep, 'onboarding.journey-step');
      });
    });

    group('MixpanelPageUrl constants', () {
      test('page URLs are correctly defined', () {
        expect(MixpanelPageUrl.home, '/home');
        expect(MixpanelPageUrl.map, '/map');
        expect(MixpanelPageUrl.chargeNow, '/charge-now');
        expect(MixpanelPageUrl.wallet, '/wallet');
        expect(MixpanelPageUrl.cardOrder, '/card-order');
        expect(MixpanelPageUrl.account, '/account');
      });
    });

    group('MixpanelButtonName constants', () {
      test('button names are correctly defined', () {
        expect(MixpanelButtonName.nearbyStations, '/nearby-stations');
        expect(MixpanelButtonName.mapSearch, '/map-search');
        expect(MixpanelButtonName.chargeNow, '/charge-now');
        expect(MixpanelButtonName.wallet, '/wallet');
        expect(MixpanelButtonName.evseIdInput, '/evse-id-input');
        expect(MixpanelButtonName.paymentMethods, '/payment-methods');
        expect(MixpanelButtonName.sessions, '/sessions');
        expect(MixpanelButtonName.invoices, '/invoices');
        expect(MixpanelButtonName.dashboard, '/dashboard');
        expect(MixpanelButtonName.help, '/help');
        expect(MixpanelButtonName.login, '/login');
        expect(MixpanelButtonName.signup, '/signup');
        expect(MixpanelButtonName.forgotPassword, '/forgot-password');
        expect(MixpanelButtonName.highwayMode, '/highway-mode');
      });
    });

    group('MixpanelPropertyKeys constants', () {
      test('property keys are correctly defined', () {
        expect(MixpanelPropertyKeys.pageUrl, 'Page URL');
        expect(MixpanelPropertyKeys.buttonName, 'Button Name');
        expect(MixpanelPropertyKeys.errorType, 'Error Type');
        expect(MixpanelPropertyKeys.user, 'User');
        expect(MixpanelPropertyKeys.step, 'Step');
      });
    });

    group('MixpanelUserState constants', () {
      test('user states are correctly defined', () {
        expect(MixpanelUserState.loggedIn, '/logged-in');
        expect(MixpanelUserState.loggedOut, '/logged-out');
      });
    });

    group('MixpanelOnboardingStep constants', () {
      test('step values are correctly defined', () {
        expect(MixpanelOnboardingStep.onboardingStarted, 'onboarding_started');
        expect(MixpanelOnboardingStep.accountCreated, 'account_created');
        expect(MixpanelOnboardingStep.phoneVerificationStep, 'phone_verification_step');
        expect(MixpanelOnboardingStep.emailVerificationStep, 'email_verification_step');
        expect(MixpanelOnboardingStep.onboardingCompleted, 'onboarding_completed');
      });
    });

    group('MixpanelOnboardingAction constants', () {
      test('action slugs are correctly defined', () {
        expect(MixpanelOnboardingAction.signup, '/signup');
        expect(MixpanelOnboardingAction.createAccount, '/create-account');
        expect(MixpanelOnboardingAction.verify, '/verify');
        expect(MixpanelOnboardingAction.resendCode, '/resend-code');
        expect(MixpanelOnboardingAction.changePhone, '/change-phone');
        expect(MixpanelOnboardingAction.changeEmail, '/change-email');
        expect(MixpanelOnboardingAction.signupComplete, '/signup-complete');
      });
    });
  });
}
