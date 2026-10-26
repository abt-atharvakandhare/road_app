import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/environment/config.dart';

class IntercomUtils {
  static bool _isIOS = Platform.isIOS;
  static bool _isAndroid = Platform.isAndroid;

  // For testing purposes only
  static void setPlatformForTesting({bool? isIOS, bool? isAndroid}) {
    _isIOS = isIOS ?? Platform.isIOS;
    _isAndroid = isAndroid ?? Platform.isAndroid;
  }

  /// Initialize Intercom SDK and login as unidentified user
  static Future<void> initialize() async {
    if (!Defines.intercomEnabled || !F.useIntercomForHelp) {
      return;
    }

    final stage = getIt<Stage>();
    final isProduction = stage.target == StageTarget.production;

    await _initializeWithEnvironment(isProduction);
    await Intercom.instance.loginUnidentifiedUser();
  }

  static Future<void> _initializeWithEnvironment(bool isProduction) async {
    // On Android, always use production keys since the native SDK doesn't support switching environments
    final effectiveIsProduction = _isAndroid ? true : isProduction;

    final appId = effectiveIsProduction ? Config.intercomAppIdProduction : Config.intercomAppIdStaging;
    final iosApiKey = effectiveIsProduction ? Config.intercomIosApiKeyProduction : Config.intercomIosApiKeyStaging;
    final androidApiKey = effectiveIsProduction
        ? Config.intercomAndroidApiKeyProduction
        : Config.intercomAndroidApiKeyStaging;

    await Intercom.instance.initialize(appId, iosApiKey: iosApiKey, androidApiKey: androidApiKey);
  }

  static Future<void> reinitializeForEnvironment(bool isProduction) async {
    if (!Defines.intercomEnabled || !F.useIntercomForHelp) {
      return;
    }

    // First logout to clean up the current session
    await Intercom.instance.logout();

    // Then initialize with the new environment
    await _initializeWithEnvironment(isProduction);

    // Re-login as unidentified user
    await Intercom.instance.loginUnidentifiedUser();
  }

  /// Login to Intercom with user details (identified) or as unidentified user
  static Future<void> loginWithUserDetails({required String? userIdString, required String? emailString}) async {
    if (!Defines.intercomEnabled || !F.useIntercomForHelp) {
      return;
    }

    final stage = getIt<Stage>();
    await _initializeWithEnvironment(stage.target == StageTarget.production);

    if (userIdString == null && emailString == null) {
      await Intercom.instance.loginUnidentifiedUser();
      return;
    }

    if (userIdString?.isNotEmpty == true) {
      final userHash = createIntercomUserHash(userIdString!);
      if (userHash == null) {
        return;
      }
      await Intercom.instance.setUserHash(userHash);
      await Intercom.instance.loginIdentifiedUser(userId: userIdString);
    } else if (emailString?.isNotEmpty == true) {
      final userHash = createIntercomUserHash(emailString!);
      if (userHash == null) {
        return;
      }
      await Intercom.instance.setUserHash(userHash);
      await Intercom.instance.loginIdentifiedUser(email: emailString);
    }
  }

  static Future<void> logout() async {
    if (!Defines.intercomEnabled || !F.useIntercomForHelp) {
      return;
    }
    await Intercom.instance.logout();
    await IntercomUtils.loginWithUserDetails(userIdString: null, emailString: null);
  }

  static bool canShowMessenger() {
    if (!Defines.intercomEnabled || !F.useIntercomForHelp) {
      return false;
    }

    return true;
  }

  /// Show Intercom messenger
  /// Returns false if Intercom is disabled, true if messenger was shown.
  static Future<bool> showIntercomMessenger() async {
    if (!canShowMessenger()) {
      return false;
    }

    await Intercom.instance.displayMessenger();
    return true;
  }

  // Visible for testing
  static String? createIntercomUserHash(String userId) {
    final stage = getIt<Stage>();
    final isProduction = stage.target == StageTarget.production;

    final String secret;
    if (_isIOS) {
      secret = isProduction
          ? Config.intercomIosIdentityVerificationSecretProduction
          : Config.intercomIosIdentityVerificationSecretStaging;
    } else if (_isAndroid) {
      secret = isProduction
          ? Config.intercomAndroidIdentityVerificationSecretProduction
          : Config.intercomAndroidIdentityVerificationSecretStaging;
    } else {
      log('Platform not supported for Intercom user hash creation.');
      return null;
    }

    final encodedSecret = utf8.encode(secret);
    final encodedUserId = utf8.encode(userId);
    final hmac = Hmac(sha256, encodedSecret);
    final hash = hmac.convert(encodedUserId);
    final hashString = hash.toString();
    return hashString;
  }
}
