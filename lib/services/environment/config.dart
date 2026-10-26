import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:road_mobile/flavors.dart';

class Config {
  /// White-label brands supply their own Google API keys. A flavor-suffixed
  /// key (e.g. GOOGLE_SERVICES_API_KEY_IOS_VCITYREUNION) overrides the shared
  /// unsuffixed key for that flavor.
  static String _flavorScopedEnv(String key) =>
      dotenv.env['${key}_${F.name.toUpperCase()}'] ?? dotenv.env[key] ?? '';

  static String get googleServicesApiKeyIos => _flavorScopedEnv('GOOGLE_SERVICES_API_KEY_IOS');
  static String get googleServicesApiKeyAndroid => _flavorScopedEnv('GOOGLE_SERVICES_API_KEY_ANDROID');

  // Intercom Configuration
  static String get intercomAppIdProduction => dotenv.env['INTERCOM_APP_ID_PRODUCTION'] ?? '';
  static String get intercomIosApiKeyProduction => dotenv.env['INTERCOM_IOS_API_KEY_PRODUCTION'] ?? '';
  static String get intercomAndroidApiKeyProduction => dotenv.env['INTERCOM_ANDROID_API_KEY_PRODUCTION'] ?? '';
  static String get intercomIosIdentityVerificationSecretProduction =>
      dotenv.env['INTERCOM_IOS_IDENTITY_VERIFICATION_SECRET_PRODUCTION'] ?? '';
  static String get intercomAndroidIdentityVerificationSecretProduction =>
      dotenv.env['INTERCOM_ANDROID_IDENTITY_VERIFICATION_SECRET_PRODUCTION'] ?? '';

  static String get intercomAppIdStaging => dotenv.env['INTERCOM_APP_ID_STAGING'] ?? '';
  static String get intercomIosApiKeyStaging => dotenv.env['INTERCOM_IOS_API_KEY_STAGING'] ?? '';
  static String get intercomAndroidApiKeyStaging => dotenv.env['INTERCOM_ANDROID_API_KEY_STAGING'] ?? '';
  static String get intercomIosIdentityVerificationSecretStaging =>
      dotenv.env['INTERCOM_IOS_IDENTITY_VERIFICATION_SECRET_STAGING'] ?? '';
  static String get intercomAndroidIdentityVerificationSecretStaging =>
      dotenv.env['INTERCOM_ANDROID_IDENTITY_VERIFICATION_SECRET_STAGING'] ?? '';

  // Phrase Configuration
  static String get phraseDistributionId => dotenv.env['PHRASE_DISTRIBUTION_ID'] ?? '';
  static String get phraseDevelopmentSecret => dotenv.env['PHRASE_DEVELOPMENT_SECRET'] ?? '';
  static String get phraseProductionSecret => dotenv.env['PHRASE_PRODUCTION_SECRET'] ?? '';

  // Checkout.com Configuration
  static String get checkoutSandboxPublicKey => dotenv.env['CHECKOUT_SANDBOX_PUBLIC_KEY'] ?? '';
  static String get checkoutProductionPublicKey => dotenv.env['CHECKOUT_PRODUCTION_PUBLIC_KEY'] ?? '';

  // Mixpanel Configuration
  static String get mixpanelTokenStaging => dotenv.env['MIXPANEL_TOKEN_STAGING'] ?? '';
  static String get mixpanelTokenProduction => dotenv.env['MIXPANEL_TOKEN_PRODUCTION'] ?? '';
}
