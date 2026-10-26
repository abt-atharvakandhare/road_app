import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/environment/config.dart';
import 'package:road_mobile/services/environment/environment.dart';

@lazySingleton
class MixpanelService {
  /// EU data residency endpoint (Mixpanel stops EU forwarding via the US
  /// endpoint in July 2026).
  static const String serverUrl = 'https://api-eu.mixpanel.com';

  Mixpanel? _mixpanel;
  bool _isLoggedIn = false;

  bool get isEnabled => _mixpanel != null;

  Future<void> initialize(Stage stage) async {
    // Only enable for e-flux flavor (matching web implementation)
    if (F.appFlavor != Flavor.eflux) {
      log('Mixpanel: Disabled for non-eflux flavor');
      return;
    }

    final token = stage.target == StageTarget.staging
        ? Config.mixpanelTokenStaging
        : Config.mixpanelTokenProduction;

    if (token.isEmpty) {
      log('Mixpanel: No token configured');
      return;
    }

    try {
      _mixpanel = await Mixpanel.init(
        token,
        trackAutomaticEvents: false,
        serverURL: serverUrl,
      );

      // Enable debug logging in debug mode
      if (kDebugMode) {
        _mixpanel?.setLoggingEnabled(true);
      }

      // Register provider as super property
      _mixpanel?.registerSuperProperties({
        'provider_slug': F.providerName,
        'app_flavor': F.appFlavor.name,
        'source': 'mobile',
      });

      log('Mixpanel: Initialized successfully');
    } catch (e) {
      log('Mixpanel: Failed to initialize - $e');
    }
  }

  /// Identify a user after login
  void identify(String distinctId, {String? email}) {
    if (!isEnabled) return;

    _mixpanel?.identify(distinctId);
    _isLoggedIn = true;

    // Set user profile properties
    if (email != null) {
      _mixpanel?.getPeople().set('\$email', email);
    }

    log('Mixpanel: Identified user $distinctId');
  }

  /// Reset user identification on logout
  void reset() {
    if (!isEnabled) return;

    _mixpanel?.reset();
    _isLoggedIn = false;

    log('Mixpanel: Reset user');
  }

  /// Track a page view event
  void trackPageView(String pageUrl) {
    if (!isEnabled) return;

    _mixpanel?.track(MixpanelEvents.pageViewed, properties: {
      MixpanelPropertyKeys.pageUrl: pageUrl,
      MixpanelPropertyKeys.user: _isLoggedIn
          ? MixpanelUserState.loggedIn
          : MixpanelUserState.loggedOut,
    });

    log('Mixpanel: Page Viewed - $pageUrl');
  }

  /// Track a button click event
  void trackButtonClick(String buttonName) {
    if (!isEnabled) return;

    _mixpanel?.track(MixpanelEvents.buttonClicked, properties: {
      MixpanelPropertyKeys.buttonName: buttonName,
      MixpanelPropertyKeys.user: _isLoggedIn
          ? MixpanelUserState.loggedIn
          : MixpanelUserState.loggedOut,
    });

    log('Mixpanel: Button Clicked - $buttonName');
  }

  /// Track successful signup
  void trackSignupCompleted() {
    if (!isEnabled) return;

    _mixpanel?.track(MixpanelEvents.signupCompleted);

    log('Mixpanel: Signup Completed');
  }

  /// Track failed signup
  void trackSignupFailed(String errorType) {
    if (!isEnabled) return;

    _mixpanel?.track(MixpanelEvents.signupFailed, properties: {
      MixpanelPropertyKeys.errorType: '/$errorType',
      MixpanelPropertyKeys.user: MixpanelUserState.loggedOut,
    });

    log('Mixpanel: Signup Failed - $errorType');
  }

  /// Track a step in the onboarding journey funnel.
  ///
  /// Emits the `onboarding.journey-step` event with a `Step` property and a
  /// sub-action carried under the existing `Button Name` key (matches the
  /// `/xxx` slug convention used by Button Clicked events).
  void trackOnboardingStep(String step, String action) {
    if (!isEnabled) return;

    _mixpanel?.track(MixpanelEvents.onboardingJourneyStep, properties: {
      MixpanelPropertyKeys.step: step,
      MixpanelPropertyKeys.buttonName: action,
    });

    log('Mixpanel: Onboarding Journey Step - $step $action');
  }

  /// Flush any pending events immediately
  void flush() {
    _mixpanel?.flush();
  }

  /// Reinitialize Mixpanel with a new environment/token
  /// Call this when switching between staging and production
  Future<void> reinitialize(Stage stage) async {
    // Flush pending events to the old project
    _mixpanel?.flush();

    // Reset user identification
    _mixpanel?.reset();
    _isLoggedIn = false;
    _mixpanel = null;

    // Reinitialize with new token
    await initialize(stage);
  }
}
