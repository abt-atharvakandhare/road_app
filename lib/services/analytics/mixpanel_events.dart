/// Mixpanel event names as defined in the tracking plan
class MixpanelEvents {
  static const String pageViewed = 'Page Viewed';
  static const String buttonClicked = 'Button Clicked';
  static const String signupCompleted = 'Signup Completed';
  static const String signupFailed = 'Signup Failed';
  static const String onboardingJourneyStep = 'onboarding.journey-step';
}

/// Page URL values for Page Viewed events
class MixpanelPageUrl {
  static const String home = '/home';
  static const String map = '/map';
  static const String chargeNow = '/charge-now';
  static const String wallet = '/wallet';
  static const String cardOrder = '/card-order';
  static const String account = '/account';
}

/// Button Name values for Button Clicked events
class MixpanelButtonName {
  static const String nearbyStations = '/nearby-stations';
  static const String mapSearch = '/map-search';
  static const String chargeNow = '/charge-now';
  static const String wallet = '/wallet';
  static const String evseIdInput = '/evse-id-input';
  static const String paymentMethods = '/payment-methods';
  static const String sessions = '/sessions';
  static const String invoices = '/invoices';
  static const String dashboard = '/dashboard';
  static const String help = '/help';
  static const String login = '/login';
  static const String passkeyLogin = '/passkey-login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String highwayMode = '/highway-mode';
}

/// Property keys for Mixpanel events
class MixpanelPropertyKeys {
  static const String pageUrl = 'Page URL';
  static const String buttonName = 'Button Name';
  static const String errorType = 'Error Type';
  static const String user = 'User';
  static const String step = 'Step';
}

/// User state values
class MixpanelUserState {
  static const String loggedIn = '/logged-in';
  static const String loggedOut = '/logged-out';
}

/// Step values for the onboarding.journey-step event
class MixpanelOnboardingStep {
  static const String onboardingStarted = 'onboarding_started';
  static const String accountCreated = 'account_created';
  static const String phoneVerificationStep = 'phone_verification_step';
  static const String emailVerificationStep = 'email_verification_step';
  static const String mfaSetupStep = 'mfa_setup_step';
  static const String onboardingCompleted = 'onboarding_completed';
}

/// Sub-action slugs sent alongside an onboarding journey step
/// (reuses the `Button Name` property key — same shape as Button Clicked slugs).
class MixpanelOnboardingAction {
  static const String signup = '/signup';
  static const String createAccount = '/create-account';
  static const String verify = '/verify';
  static const String resendCode = '/resend-code';
  static const String changePhone = '/change-phone';
  static const String changeEmail = '/change-email';

  /// Mobile pops the signup modal back to whichever surface launched it
  /// (wallet, account, map, ...), so the completion slug is
  /// destination-neutral rather than a landing-page path.
  static const String signupComplete = '/signup-complete';

  // mfa_setup_step sub-actions
  static const String offered = '/offered';
  static const String enrolled = '/enrolled';
  static const String skip = '/skip';
}
