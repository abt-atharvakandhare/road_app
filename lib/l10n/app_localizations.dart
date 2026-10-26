import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
  ];

  /// No description provided for @highwayMode.
  ///
  /// In en, this message translates to:
  /// **'Highway Mode'**
  String get highwayMode;

  /// No description provided for @stopAtNearestFastChargingStation.
  ///
  /// In en, this message translates to:
  /// **'Stop at nearest fast charging station'**
  String get stopAtNearestFastChargingStation;

  /// No description provided for @emailAddressSuccessfullyVerified.
  ///
  /// In en, this message translates to:
  /// **'E-mail address successfully verified!'**
  String get emailAddressSuccessfullyVerified;

  /// No description provided for @phoneNumberSuccessfullyVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number successfully verified!'**
  String get phoneNumberSuccessfullyVerified;

  /// No description provided for @pleaseVerifyYourPhoneNumberAndEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number and e-mail.'**
  String get pleaseVerifyYourPhoneNumberAndEmail;

  /// No description provided for @verifyYourPhoneNumberNow.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number now.'**
  String get verifyYourPhoneNumberNow;

  /// No description provided for @verifyYourEmailNow.
  ///
  /// In en, this message translates to:
  /// **'Verify your e-mail now.'**
  String get verifyYourEmailNow;

  /// No description provided for @verifyYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Verify your e-mail address'**
  String get verifyYourEmailAddress;

  /// No description provided for @weSentYouAnEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'We sent you an e-mail to {emailAddress}.'**
  String weSentYouAnEmailVerification(String emailAddress);

  /// No description provided for @openMailApp.
  ///
  /// In en, this message translates to:
  /// **'Open mail app'**
  String get openMailApp;

  /// No description provided for @pleaseConfirmYourEmailAddressByClicking.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your e-mail address by clicking the link in the e-mail we sent you.'**
  String get pleaseConfirmYourEmailAddressByClicking;

  /// No description provided for @didntReceiveTheEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Please check your spam folder or'**
  String get didntReceiveTheEmail;

  /// No description provided for @resendEmailVerificationLink.
  ///
  /// In en, this message translates to:
  /// **'resend e-mail verification link'**
  String get resendEmailVerificationLink;

  /// Small label that appears next to a verified profile item, e.g. phone number or e-mail
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @stationAddedToYourFavourites.
  ///
  /// In en, this message translates to:
  /// **'Station added to your favourites'**
  String get stationAddedToYourFavourites;

  /// No description provided for @removedFromYourFavourites.
  ///
  /// In en, this message translates to:
  /// **'Removed from your favourites'**
  String get removedFromYourFavourites;

  /// No description provided for @yourFavouriteStationsWillShowUpHere.
  ///
  /// In en, this message translates to:
  /// **'Your favourite stations with real-time availability will show up here.'**
  String get yourFavouriteStationsWillShowUpHere;

  /// No description provided for @markStationsAsFavouriteByPressingTheHeartIcon.
  ///
  /// In en, this message translates to:
  /// **'Mark stations as favourite by pressing the heart icon.'**
  String get markStationsAsFavouriteByPressingTheHeartIcon;

  /// No description provided for @addToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addToFavourites;

  /// No description provided for @removeFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get removeFromFavourites;

  /// No description provided for @exploreMap.
  ///
  /// In en, this message translates to:
  /// **'Explore Map'**
  String get exploreMap;

  /// No description provided for @nearestStations.
  ///
  /// In en, this message translates to:
  /// **'Nearest Stations'**
  String get nearestStations;

  /// Title for highway mode screen when driving above 50km/h - shows fast charging stations
  ///
  /// In en, this message translates to:
  /// **'Fast stations (>50 kW)'**
  String get fastStationsWithPower;

  /// No description provided for @onRoad.
  ///
  /// In en, this message translates to:
  /// **'on {road}'**
  String onRoad(String road);

  /// No description provided for @noNearbyStations.
  ///
  /// In en, this message translates to:
  /// **'No Nearby Stations'**
  String get noNearbyStations;

  /// No description provided for @noChargingStationsFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No charging stations found nearby'**
  String get noChargingStationsFoundNearby;

  /// No description provided for @accountRemovalIsPending.
  ///
  /// In en, this message translates to:
  /// **'Account removal is pending'**
  String get accountRemovalIsPending;

  /// No description provided for @areYouSureYouWantToRemoveYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your account?'**
  String get areYouSureYouWantToRemoveYourAccount;

  /// No description provided for @thisActionIsPermanent.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent.'**
  String get thisActionIsPermanent;

  /// No description provided for @yesRemoveAccount.
  ///
  /// In en, this message translates to:
  /// **'Yes, remove account'**
  String get yesRemoveAccount;

  /// No description provided for @weSentYouAndSmsFullNumber.
  ///
  /// In en, this message translates to:
  /// **'We sent you an SMS to {phoneNumber}.'**
  String weSentYouAndSmsFullNumber(String phoneNumber);

  /// No description provided for @saveRecoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'Save Recovery Codes'**
  String get saveRecoveryCodes;

  /// No description provided for @recoveryCodesCanBeUsed.
  ///
  /// In en, this message translates to:
  /// **'Recovery codes can be used to access your account in case you lose access to your device and cannot receive two-factor authentication codes.'**
  String get recoveryCodesCanBeUsed;

  /// No description provided for @downloadCodes.
  ///
  /// In en, this message translates to:
  /// **'Download Codes'**
  String get downloadCodes;

  /// No description provided for @copyCodes.
  ///
  /// In en, this message translates to:
  /// **'Copy Codes'**
  String get copyCodes;

  /// No description provided for @iSavedMyBackupCodes.
  ///
  /// In en, this message translates to:
  /// **'I saved my backup codes'**
  String get iSavedMyBackupCodes;

  /// No description provided for @putTheseInASafeSpot.
  ///
  /// In en, this message translates to:
  /// **'Put these in a safe spot. If you lose your device and don\'t have the recovery codes you will lose access to your account.'**
  String get putTheseInASafeSpot;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @oneDownloadAnAuthenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'1. Download an authenticator app'**
  String get oneDownloadAnAuthenticatorApp;

  /// --authoption-- is a placeholder for the authenticator app name. It will be replaced with 'Google Authenticator', 'Authy' or '1Password'. The string must split into 4 parts precisely around the auth options.
  ///
  /// In en, this message translates to:
  /// **'We recommend --authoption--, --authoption-- or --authoption--.'**
  String get weRecommendGoogleAuthenticator;

  /// No description provided for @googleAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Google Authenticator'**
  String get googleAuthenticator;

  /// No description provided for @onePassword.
  ///
  /// In en, this message translates to:
  /// **'1Password'**
  String get onePassword;

  /// No description provided for @authy.
  ///
  /// In en, this message translates to:
  /// **'Authy'**
  String get authy;

  /// No description provided for @twoScanTheQrCode.
  ///
  /// In en, this message translates to:
  /// **'2. Scan the QR code using your authenticator app'**
  String get twoScanTheQrCode;

  /// No description provided for @threeEnterTheCode.
  ///
  /// In en, this message translates to:
  /// **'3. Enter the security code generated by the app'**
  String get threeEnterTheCode;

  /// No description provided for @appAuthentication.
  ///
  /// In en, this message translates to:
  /// **'App Authentication'**
  String get appAuthentication;

  /// No description provided for @securityCodesGeneratedByApp.
  ///
  /// In en, this message translates to:
  /// **'Security codes will be generated by your preferred authenticator app.'**
  String get securityCodesGeneratedByApp;

  /// No description provided for @smsAuthentication.
  ///
  /// In en, this message translates to:
  /// **'SMS Authentication'**
  String get smsAuthentication;

  /// No description provided for @securityCodesSentViaSms.
  ///
  /// In en, this message translates to:
  /// **'Security codes will be sent via SMS to your mobile device.'**
  String get securityCodesSentViaSms;

  /// No description provided for @passwordAndAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Password & Authentication'**
  String get passwordAndAuthentication;

  /// No description provided for @dontHaveYourBackupCodes.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have your backup codes anymore?'**
  String get dontHaveYourBackupCodes;

  /// Prefix to email address in 'Contact support at support@road.io to start a manual verification process'
  ///
  /// In en, this message translates to:
  /// **'Contact support at'**
  String get contactSupportAt;

  /// Postfix to email address in 'Contact support at support@road.io to start a manual verification process'
  ///
  /// In en, this message translates to:
  /// **'to start a manual verification process.'**
  String get toStartAManualVerificationProcess;

  /// No description provided for @pleaseEnterBackupCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter one of your unused backup verification codes:'**
  String get pleaseEnterBackupCode;

  /// No description provided for @backupVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Backup verification code'**
  String get backupVerificationCode;

  /// No description provided for @codeEnteredIsIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Code entered is incorrect. Please try again or request a new code.'**
  String get codeEnteredIsIncorrect;

  /// No description provided for @isThisAuthMethodNotWorking.
  ///
  /// In en, this message translates to:
  /// **'Is this authentication method not working?'**
  String get isThisAuthMethodNotWorking;

  /// No description provided for @useYourBackupCodes.
  ///
  /// In en, this message translates to:
  /// **'Use your backup codes'**
  String get useYourBackupCodes;

  /// No description provided for @chooseVerificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a verification method'**
  String get chooseVerificationMethod;

  /// No description provided for @howWouldYouLikeToVerify.
  ///
  /// In en, this message translates to:
  /// **'How would you like to verify it\'s you?'**
  String get howWouldYouLikeToVerify;

  /// No description provided for @useRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code'**
  String get useRecoveryCode;

  /// No description provided for @enterRecoveryCodeBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter one of your single-use recovery codes below.'**
  String get enterRecoveryCodeBelow;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @useDifferentVerificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Use a different verification method'**
  String get useDifferentVerificationMethod;

  /// No description provided for @weSentACodeToPhone.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {phoneNumber}.'**
  String weSentACodeToPhone(String phoneNumber);

  /// No description provided for @weSentACodeToEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {emailAddress}.'**
  String weSentACodeToEmail(String emailAddress);

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureYourAccount;

  /// No description provided for @mfaEnrolExplanationEncourage.
  ///
  /// In en, this message translates to:
  /// **'Add a second sign-in step to protect your account against stolen passwords. You can set this up now, or skip and do it later.'**
  String get mfaEnrolExplanationEncourage;

  /// No description provided for @mfaEnrolExplanationEnforce.
  ///
  /// In en, this message translates to:
  /// **'A second sign-in step is required to protect your account. Set one up now to continue.'**
  String get mfaEnrolExplanationEnforce;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @confirmYourEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'First, let\'s confirm it\'s you.'**
  String get confirmYourEmailFirst;

  /// No description provided for @chooseEnrolmentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to verify future sign-ins'**
  String get chooseEnrolmentMethod;

  /// No description provided for @cantScanTheCode.
  ///
  /// In en, this message translates to:
  /// **'Can\'t scan the code? Enter this key manually:'**
  String get cantScanTheCode;

  /// No description provided for @enterTheSecurityCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Enter the security code generated by the app.'**
  String get enterTheSecurityCodeGenerated;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @weSentYouAnSms.
  ///
  /// In en, this message translates to:
  /// **'We sent you an SMS verification code to phone number ending with --phonenumber--.'**
  String get weSentYouAnSms;

  /// No description provided for @enterThe6DigitCodeBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code below'**
  String get enterThe6DigitCodeBelow;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @stepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total}:'**
  String stepCounter(int current, int total);

  /// No description provided for @verifyPhoneStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get verifyPhoneStepTitle;

  /// No description provided for @verifyEmailStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify E-mail'**
  String get verifyEmailStepTitle;

  /// No description provided for @didntReceiveTheCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? It may take a minute to arrive or'**
  String get didntReceiveTheCode;

  /// Postfix highlighted as a link, comes after didntReceiveTheCode.
  ///
  /// In en, this message translates to:
  /// **'resend verification code'**
  String get resendVerificationCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent!'**
  String get codeResent;

  /// Shows on map filter screen - e.g. E-Flux Chargers
  ///
  /// In en, this message translates to:
  /// **'--brandname-- Chargers'**
  String get brandnameChargers;

  /// No description provided for @publicTariff.
  ///
  /// In en, this message translates to:
  /// **'Public Tariff'**
  String get publicTariff;

  /// No description provided for @specialCardTariff.
  ///
  /// In en, this message translates to:
  /// **'Special Card Tariff'**
  String get specialCardTariff;

  /// No description provided for @updateBillingInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Billing Information'**
  String get updateBillingInformation;

  /// No description provided for @billingAddressSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Billing address successfully updated'**
  String get billingAddressSuccessfullyUpdated;

  /// No description provided for @provideYourBillingDetails.
  ///
  /// In en, this message translates to:
  /// **'Provide your billing details'**
  String get provideYourBillingDetails;

  /// No description provided for @profileSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileSuccessfullyUpdated;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @manageYourPersonalContactInformation.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal contact information'**
  String get manageYourPersonalContactInformation;

  /// No description provided for @passwordSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password successfully updated'**
  String get passwordSuccessfullyUpdated;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @updateYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Update Your Password'**
  String get updateYourPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @pleaseAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please allow notifications in the app settings.'**
  String get pleaseAllowNotifications;

  /// No description provided for @sendNotifications.
  ///
  /// In en, this message translates to:
  /// **'Charging updates'**
  String get sendNotifications;

  /// No description provided for @chargingUpdatesSubtitleIOS.
  ///
  /// In en, this message translates to:
  /// **'Push notifications and Live Activities'**
  String get chargingUpdatesSubtitleIOS;

  /// No description provided for @chargingUpdatesSubtitleAndroid.
  ///
  /// In en, this message translates to:
  /// **'Push notifications and Ongoing Notifications'**
  String get chargingUpdatesSubtitleAndroid;

  /// No description provided for @personalSettings.
  ///
  /// In en, this message translates to:
  /// **'Personal Settings'**
  String get personalSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageYourNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications for charging sessions.'**
  String get manageYourNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @chargingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Session Started'**
  String get chargingStartedTitle;

  /// No description provided for @chargingSessionEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Session Ended'**
  String get chargingSessionEndedTitle;

  /// No description provided for @chargingSessionStateOver80Title.
  ///
  /// In en, this message translates to:
  /// **'Charging Session 80% Completed'**
  String get chargingSessionStateOver80Title;

  /// No description provided for @chargingSessionChargingTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Session Started Charging'**
  String get chargingSessionChargingTitle;

  /// No description provided for @chargingSessionSuspendedEvTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Session Suspended EV'**
  String get chargingSessionSuspendedEvTitle;

  /// No description provided for @chargingSessionSuspendedEvseTitle.
  ///
  /// In en, this message translates to:
  /// **'Charging Session Suspended EVSE'**
  String get chargingSessionSuspendedEvseTitle;

  /// No description provided for @chargingSessionStartedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when your car charging session starts.'**
  String get chargingSessionStartedSubtitle;

  /// No description provided for @chargingSessionEndedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when your car charging session ends.'**
  String get chargingSessionEndedSubtitle;

  /// No description provided for @chargingSessionStateOver80Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when your charge level reaches 80%.'**
  String get chargingSessionStateOver80Subtitle;

  /// No description provided for @chargingSessionChargingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when your car starts charging.'**
  String get chargingSessionChargingSubtitle;

  /// No description provided for @chargingSessionSuspendedEvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when your car stops charging.'**
  String get chargingSessionSuspendedEvSubtitle;

  /// No description provided for @chargingSessionSuspendedEvseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification when the charging station stops charging your car.'**
  String get chargingSessionSuspendedEvseSubtitle;

  /// No description provided for @chargingSessionLiveUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Charging Updates'**
  String get chargingSessionLiveUpdateTitle;

  /// No description provided for @chargingSessionLiveUpdateSubtitleIOS.
  ///
  /// In en, this message translates to:
  /// **'Show live charging progress on your lock screen and in the Dynamic Island.'**
  String get chargingSessionLiveUpdateSubtitleIOS;

  /// No description provided for @chargingSessionLiveUpdateSubtitleAndroid.
  ///
  /// In en, this message translates to:
  /// **'Show live charging progress as an ongoing notification.'**
  String get chargingSessionLiveUpdateSubtitleAndroid;

  /// No description provided for @wantToAddYourCreditOrDebitCardLater.
  ///
  /// In en, this message translates to:
  /// **'Want to add your credit or debit card later?'**
  String get wantToAddYourCreditOrDebitCardLater;

  /// No description provided for @viewYourChargeCards.
  ///
  /// In en, this message translates to:
  /// **'View your charge cards.'**
  String get viewYourChargeCards;

  /// No description provided for @viewYourPreviousChargingSessions.
  ///
  /// In en, this message translates to:
  /// **'View your previous charging sessions.'**
  String get viewYourPreviousChargingSessions;

  /// No description provided for @viewInvoicesForYourChargeCards.
  ///
  /// In en, this message translates to:
  /// **'View invoices for your charge cards.'**
  String get viewInvoicesForYourChargeCards;

  /// No description provided for @viewYourProfileAndAccount.
  ///
  /// In en, this message translates to:
  /// **'View your profile & account.'**
  String get viewYourProfileAndAccount;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @postCodeIsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Post code is invalid'**
  String get postCodeIsInvalid;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable Location Services'**
  String get enableLocationServices;

  /// No description provided for @pleaseAllowLocationUpdates.
  ///
  /// In en, this message translates to:
  /// **'Please allow location updates in the app settings.'**
  String get pleaseAllowLocationUpdates;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @accountCreatedWelcomeOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Account created. Welcome on board!'**
  String get accountCreatedWelcomeOnBoard;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @lookingForAppleOrGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Looking for Apple Pay or Google Pay?'**
  String get lookingForAppleOrGooglePay;

  /// No description provided for @skipThisStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get skipThisStep;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// Single entry on account page
  ///
  /// In en, this message translates to:
  /// **'Privacy Statement'**
  String get privacyStatementOneLine;

  /// Single entry on account page
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceOneLine;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @addCreditOrDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Add Credit or Debit Card'**
  String get addCreditOrDebitCard;

  /// No description provided for @byAddingAPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'By adding a payment method you will be able to start a charging session on any --brandname-- station.'**
  String get byAddingAPaymentMethod;

  /// No description provided for @youWillAddYourPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'You will add your payment details in the next step.'**
  String get youWillAddYourPaymentDetails;

  /// No description provided for @supportedMethods.
  ///
  /// In en, this message translates to:
  /// **'Supported Methods'**
  String get supportedMethods;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @signupNowToSeeYourChargeCards.
  ///
  /// In en, this message translates to:
  /// **'Signup now to see your charge cards.'**
  String get signupNowToSeeYourChargeCards;

  /// No description provided for @signupNowToViewChargingSessions.
  ///
  /// In en, this message translates to:
  /// **'Signup now to view all your previous charging sessions.'**
  String get signupNowToViewChargingSessions;

  /// No description provided for @signupNowToViewInvoices.
  ///
  /// In en, this message translates to:
  /// **'Signup now to view all invoices for your charge cards.'**
  String get signupNowToViewInvoices;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @googlePay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @noInvoiceDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No invoice data available.'**
  String get noInvoiceDataAvailable;

  /// No description provided for @filterByYear.
  ///
  /// In en, this message translates to:
  /// **'Filter by Year'**
  String get filterByYear;

  /// No description provided for @chargeCardInvoices.
  ///
  /// In en, this message translates to:
  /// **'Charge Card Invoices'**
  String get chargeCardInvoices;

  /// No description provided for @viewAllInvoices.
  ///
  /// In en, this message translates to:
  /// **'View All Invoices →'**
  String get viewAllInvoices;

  /// No description provided for @chooseRoutingApp.
  ///
  /// In en, this message translates to:
  /// **'Choose Routing App'**
  String get chooseRoutingApp;

  /// No description provided for @manuallyInputStationId.
  ///
  /// In en, this message translates to:
  /// **'Manually input station ID'**
  String get manuallyInputStationId;

  /// No description provided for @inputTheStationIdFromTheSticker.
  ///
  /// In en, this message translates to:
  /// **'Input the station ID from the sticker'**
  String get inputTheStationIdFromTheSticker;

  /// No description provided for @findTheStickerEnterTheDigits.
  ///
  /// In en, this message translates to:
  /// **'Find the sticker on the charging station and enter the digit identifier.'**
  String get findTheStickerEnterTheDigits;

  /// No description provided for @scanStationQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan station QR code'**
  String get scanStationQrCode;

  /// No description provided for @useCameraToIdentifyStationId.
  ///
  /// In en, this message translates to:
  /// **'Use camera to identify your station ID'**
  String get useCameraToIdentifyStationId;

  /// No description provided for @qrScannerTorchToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle torch'**
  String get qrScannerTorchToggle;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR codes. Please grant camera access in your device settings.'**
  String get cameraPermissionMessage;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @errorAccessingCamera.
  ///
  /// In en, this message translates to:
  /// **'Error accessing camera'**
  String get errorAccessingCamera;

  /// No description provided for @stationId.
  ///
  /// In en, this message translates to:
  /// **'Station ID'**
  String get stationId;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get example;

  /// Used in station ID input example, eg: NL*EFL*EV1234567 -> input 1234567
  ///
  /// In en, this message translates to:
  /// **'input'**
  String get input;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @youHaventAddedAnyCardsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any cards yet.'**
  String get youHaventAddedAnyCardsYet;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @chargingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Charging in progress'**
  String get chargingInProgress;

  /// No description provided for @cancelSession.
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get cancelSession;

  /// No description provided for @unableToConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to start a charging session. Please try again later.'**
  String get unableToConnectToServer;

  /// No description provided for @chargeCard.
  ///
  /// In en, this message translates to:
  /// **'Charge Card'**
  String get chargeCard;

  /// No description provided for @youAreReadyToGo.
  ///
  /// In en, this message translates to:
  /// **'You are ready to go!'**
  String get youAreReadyToGo;

  /// No description provided for @noteWeAreStillProcessing.
  ///
  /// In en, this message translates to:
  /// **'Note: we are still processing the transaction. Once this is done you will be able to review your session details.'**
  String get noteWeAreStillProcessing;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session completed'**
  String get sessionCompleted;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @inclVat.
  ///
  /// In en, this message translates to:
  /// **'(incl. VAT)'**
  String get inclVat;

  /// No description provided for @exclVat.
  ///
  /// In en, this message translates to:
  /// **'(excl. VAT)'**
  String get exclVat;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @charged.
  ///
  /// In en, this message translates to:
  /// **'Charged'**
  String get charged;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @totalCosts.
  ///
  /// In en, this message translates to:
  /// **'Total Costs'**
  String get totalCosts;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @thereArentAnyStationsNearYourLocations.
  ///
  /// In en, this message translates to:
  /// **'There aren\'t any stations near your location.'**
  String get thereArentAnyStationsNearYourLocations;

  /// No description provided for @sessionStarting.
  ///
  /// In en, this message translates to:
  /// **'Session starting'**
  String get sessionStarting;

  /// No description provided for @sessionStopping.
  ///
  /// In en, this message translates to:
  /// **'Session stopping'**
  String get sessionStopping;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEnded;

  /// No description provided for @stationDoesntSupportSessions.
  ///
  /// In en, this message translates to:
  /// **'This station doesn\'t support starting sessions inside the app. Use station controls to authenticate and start a charging session.'**
  String get stationDoesntSupportSessions;

  /// No description provided for @stationOnlySupportsRfidCards.
  ///
  /// In en, this message translates to:
  /// **'This station only supports starting sessions inside the app with an RFID charge card.'**
  String get stationOnlySupportsRfidCards;

  /// No description provided for @stationOnlySupportsCreditCards.
  ///
  /// In en, this message translates to:
  /// **'This station only supports starting sessions inside the app with a credit card.'**
  String get stationOnlySupportsCreditCards;

  /// No description provided for @weLoggedYouInAutomatically.
  ///
  /// In en, this message translates to:
  /// **'We logged you in automatically.'**
  String get weLoggedYouInAutomatically;

  /// No description provided for @cannotAddAPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Cannot add a payment method to this account.'**
  String get cannotAddAPaymentMethod;

  /// No description provided for @imAllPluggedInToTheEvStation.
  ///
  /// In en, this message translates to:
  /// **'I\'m all plugged in to EV station'**
  String get imAllPluggedInToTheEvStation;

  /// No description provided for @automaticallyDetectMyConnection.
  ///
  /// In en, this message translates to:
  /// **'Automatically detect my connection'**
  String get automaticallyDetectMyConnection;

  /// No description provided for @findNearbyEvStations.
  ///
  /// In en, this message translates to:
  /// **'Find nearby EV stations'**
  String get findNearbyEvStations;

  /// No description provided for @chooseFromAListOfNearbyConnectors.
  ///
  /// In en, this message translates to:
  /// **'Choose from a list of nearby connectors'**
  String get chooseFromAListOfNearbyConnectors;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreated;

  /// No description provided for @youCanNowStartYourFirstCharge.
  ///
  /// In en, this message translates to:
  /// **'You can now start your first EV charge.'**
  String get youCanNowStartYourFirstCharge;

  /// No description provided for @youCanNowAddAPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'You can now add a payment method and start your first EV charge.'**
  String get youCanNowAddAPaymentMethod;

  /// No description provided for @countryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryIsRequired;

  /// No description provided for @streetIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Street is required'**
  String get streetIsRequired;

  /// No description provided for @houseNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'House number is required'**
  String get houseNumberIsRequired;

  /// No description provided for @postCodeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Post code is required'**
  String get postCodeIsRequired;

  /// No description provided for @cityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityIsRequired;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @pleaseEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 8 characters, with one letter, one number and one special character.'**
  String get passwordMustContain;

  /// No description provided for @acceptTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions'**
  String get acceptTermsAndConditions;

  /// No description provided for @acceptPrivacyStatement.
  ///
  /// In en, this message translates to:
  /// **'Please accept the privacy statement'**
  String get acceptPrivacyStatement;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// Shortest possible abbreviation for 'House Number'.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get houseNumberShort;

  /// No description provided for @postCode.
  ///
  /// In en, this message translates to:
  /// **'Post Code'**
  String get postCode;

  /// No description provided for @cityTown.
  ///
  /// In en, this message translates to:
  /// **'City/Town'**
  String get cityTown;

  /// No description provided for @billingDetails.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get billingDetails;

  /// No description provided for @billingAddress.
  ///
  /// In en, this message translates to:
  /// **'Billing Address'**
  String get billingAddress;

  /// Precedes the hyperlink 'terms of service'
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get iAcceptThe;

  /// Comes after 'I accept the' Hyperlink to the terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service.'**
  String get termsOfService;

  /// Precedes the hyperlink 'privacy statement'. --brandname-- is set to the name of the app
  ///
  /// In en, this message translates to:
  /// **'I understand that --brandname-- will process my personal data in accordance with the'**
  String get iUnderstandThat;

  /// Comes after 'I accept that...' Hyperlink to the privacy statement
  ///
  /// In en, this message translates to:
  /// **'Privacy Statement.'**
  String get privacyStatement;

  /// Comes aater the hyperlink to 'privacy statement'
  ///
  /// In en, this message translates to:
  /// **'I want to receive newsletters about my charge card and/or subscription, and I hereby consent to the processing of my personal data for this, as described in the'**
  String get iWantToReceive;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createYourFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Free Account'**
  String get createYourFreeAccount;

  /// No description provided for @blockCard.
  ///
  /// In en, this message translates to:
  /// **'Block Card'**
  String get blockCard;

  /// No description provided for @unblockCard.
  ///
  /// In en, this message translates to:
  /// **'Unblock Card'**
  String get unblockCard;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @identifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get identifier;

  /// No description provided for @billingPlan.
  ///
  /// In en, this message translates to:
  /// **'Billing Plan'**
  String get billingPlan;

  /// No description provided for @nameOnCard.
  ///
  /// In en, this message translates to:
  /// **'Name On Card'**
  String get nameOnCard;

  /// Postfix for E-Flux Card / Elexon Card etc.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @unknownAddress.
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get unknownAddress;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove Card'**
  String get removeCard;

  /// No description provided for @areYouSureYouWantToRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove card'**
  String get areYouSureYouWantToRemoveCard;

  /// No description provided for @areYouSureYouWantToBlockCardFrom.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block card from'**
  String get areYouSureYouWantToBlockCardFrom;

  /// No description provided for @thisActionCannotBeReversed.
  ///
  /// In en, this message translates to:
  /// **'This action can not be reversed. You will not be able to pay at any charging station anymore with this card.'**
  String get thisActionCannotBeReversed;

  /// No description provided for @yesRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Yes, Remove Card'**
  String get yesRemoveCard;

  /// No description provided for @yesBlockCard.
  ///
  /// In en, this message translates to:
  /// **'Yes, Block Card'**
  String get yesBlockCard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method'**
  String get editPaymentMethod;

  /// No description provided for @addPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// No description provided for @creditOrDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Credit or Debit Card'**
  String get creditOrDebitCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @cardVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Card Verification Required'**
  String get cardVerificationRequired;

  /// No description provided for @clickButton3dSecure.
  ///
  /// In en, this message translates to:
  /// **'After clicking the button you will be redirected to your payment provider for 3D Secure authentication.'**
  String get clickButton3dSecure;

  /// No description provided for @continueToAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Continue to Authentication'**
  String get continueToAuthentication;

  /// No description provided for @tdsSecureHelpsPreventFraud.
  ///
  /// In en, this message translates to:
  /// **'3D-Secure (3DS) helps prevent fraud when using payment cards online.'**
  String get tdsSecureHelpsPreventFraud;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card Saved'**
  String get cardSaved;

  /// No description provided for @cardRemoved.
  ///
  /// In en, this message translates to:
  /// **'Card Removed'**
  String get cardRemoved;

  /// No description provided for @cardFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Card Failed to save. Please try again.'**
  String get cardFailedToSave;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @hourIdleFee.
  ///
  /// In en, this message translates to:
  /// **'Hour idle fee'**
  String get hourIdleFee;

  /// No description provided for @minWaitBeforeIdleFee.
  ///
  /// In en, this message translates to:
  /// **'min wait before idle fee'**
  String get minWaitBeforeIdleFee;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @operatorKey.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operatorKey;

  /// No description provided for @availableFacilities.
  ///
  /// In en, this message translates to:
  /// **'Available facilities'**
  String get availableFacilities;

  /// No description provided for @carpoolParking.
  ///
  /// In en, this message translates to:
  /// **'Carpool Parking'**
  String get carpoolParking;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wifi'**
  String get wifi;

  /// No description provided for @noSessionDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No session data available.'**
  String get noSessionDataAvailable;

  /// No description provided for @filterByMonth.
  ///
  /// In en, this message translates to:
  /// **'Filter by Month'**
  String get filterByMonth;

  /// No description provided for @viewAllSessions.
  ///
  /// In en, this message translates to:
  /// **'View All Sessions →'**
  String get viewAllSessions;

  /// No description provided for @scheduledTariffNote.
  ///
  /// In en, this message translates to:
  /// **'A scheduled tariff overrides base tariff prices for specific time period.'**
  String get scheduledTariffNote;

  /// No description provided for @dynamicTariffNote.
  ///
  /// In en, this message translates to:
  /// **'Dynamic price is adjusted automatically based on energy market price (1 hour interval).'**
  String get dynamicTariffNote;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @baseTariff.
  ///
  /// In en, this message translates to:
  /// **'Base Tariff'**
  String get baseTariff;

  /// No description provided for @dynamicTariff.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Tariff'**
  String get dynamicTariff;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE NOW'**
  String get activeNow;

  /// No description provided for @viewAllHourlyPrices.
  ///
  /// In en, this message translates to:
  /// **'View All Hourly Prices'**
  String get viewAllHourlyPrices;

  /// No description provided for @hourlyPrices.
  ///
  /// In en, this message translates to:
  /// **'Hourly Prices'**
  String get hourlyPrices;

  /// No description provided for @tariffNotes.
  ///
  /// In en, this message translates to:
  /// **'Tariff Notes'**
  String get tariffNotes;

  /// No description provided for @viewTariffNotes.
  ///
  /// In en, this message translates to:
  /// **'View Tariff Notes'**
  String get viewTariffNotes;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @noConnectorDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No connector data available'**
  String get noConnectorDataAvailable;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get cafe;

  /// No description provided for @mall.
  ///
  /// In en, this message translates to:
  /// **'Mall'**
  String get mall;

  /// No description provided for @supermarket.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get supermarket;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @recreationArea.
  ///
  /// In en, this message translates to:
  /// **'Recreation Area'**
  String get recreationArea;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @museum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get museum;

  /// No description provided for @bikeSharing.
  ///
  /// In en, this message translates to:
  /// **'Bike Sharing'**
  String get bikeSharing;

  /// No description provided for @busStop.
  ///
  /// In en, this message translates to:
  /// **'Bus Stop'**
  String get busStop;

  /// No description provided for @taxiStand.
  ///
  /// In en, this message translates to:
  /// **'Taxi Stand'**
  String get taxiStand;

  /// No description provided for @tramStop.
  ///
  /// In en, this message translates to:
  /// **'Tram Stop'**
  String get tramStop;

  /// No description provided for @metroStation.
  ///
  /// In en, this message translates to:
  /// **'Metro Station'**
  String get metroStation;

  /// No description provided for @trainStation.
  ///
  /// In en, this message translates to:
  /// **'Train Station'**
  String get trainStation;

  /// No description provided for @airport.
  ///
  /// In en, this message translates to:
  /// **'Airport'**
  String get airport;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @alongMotorway.
  ///
  /// In en, this message translates to:
  /// **'Along Motorway'**
  String get alongMotorway;

  /// No description provided for @parkingGarage.
  ///
  /// In en, this message translates to:
  /// **'Parking Garage'**
  String get parkingGarage;

  /// No description provided for @parkingLot.
  ///
  /// In en, this message translates to:
  /// **'Parking Lot'**
  String get parkingLot;

  /// No description provided for @onDriveway.
  ///
  /// In en, this message translates to:
  /// **'On Driveway'**
  String get onDriveway;

  /// No description provided for @onStreet.
  ///
  /// In en, this message translates to:
  /// **'On Street'**
  String get onStreet;

  /// No description provided for @undergroundGarage.
  ///
  /// In en, this message translates to:
  /// **'Underground Garage'**
  String get undergroundGarage;

  /// No description provided for @fuelStation.
  ///
  /// In en, this message translates to:
  /// **'Fuel Station'**
  String get fuelStation;

  /// No description provided for @inaccurateTariffWarning.
  ///
  /// In en, this message translates to:
  /// **'Tariffs shown here have been sent to {appName} by roaming partner. Accuracy may vary depending on provider.'**
  String inaccurateTariffWarning(String appName);

  /// No description provided for @somethingWentWrongPleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get somethingWentWrongPleaseTryAgainLater;

  /// Hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}min'**
  String hAndMin(num hours, num minutes);

  /// No description provided for @lessThanAMinute.
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get lessThanAMinute;

  /// Count of days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String nDays(num count);

  /// Count of hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 hours} =1{1 hour} other{{count} hours}}'**
  String nHours(num count);

  /// Count of minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 minutes} =1{1 minute} other{{count} minutes}}'**
  String nMinutes(num count);

  /// No description provided for @noTariffAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tariff available'**
  String get noTariffAvailable;

  /// No description provided for @unknownKW.
  ///
  /// In en, this message translates to:
  /// **'unknown kW'**
  String get unknownKW;

  /// No description provided for @cardDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Card details unavailable'**
  String get cardDetailsUnavailable;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: '**
  String get somethingWentWrong;

  /// No description provided for @appUpdateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'This version of the app is no longer supported. Please update it from the app store and try again.'**
  String get appUpdateRequiredError;

  /// No description provided for @mfaCodeExhausted.
  ///
  /// In en, this message translates to:
  /// **'That code is no longer valid. Please request a new one.'**
  String get mfaCodeExhausted;

  /// No description provided for @mfaSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Add a second step to protect your account when signing in. You can also do this later.'**
  String get mfaSetupIntro;

  /// No description provided for @mfaSetupAuthenticatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app'**
  String get mfaSetupAuthenticatorTitle;

  /// No description provided for @mfaSetupSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Text message (SMS)'**
  String get mfaSetupSmsTitle;

  /// No description provided for @mfaSetupNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get mfaSetupNotSetUp;

  /// No description provided for @mfaSetupSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get mfaSetupSetUp;

  /// No description provided for @mfaSetupEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get mfaSetupEnabled;

  /// No description provided for @mfaSetupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mfaSetupBack;

  /// No description provided for @securityScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Manage how you sign in to your account.'**
  String get securityScreenIntro;

  /// No description provided for @mfaActivatedOn.
  ///
  /// In en, this message translates to:
  /// **'Activated on {date}'**
  String mfaActivatedOn(String date);

  /// No description provided for @mfaNotAvailableByPolicy.
  ///
  /// In en, this message translates to:
  /// **'Not available by administrator policy'**
  String get mfaNotAvailableByPolicy;

  /// No description provided for @mfaBackupCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup codes'**
  String get mfaBackupCodesTitle;

  /// No description provided for @mfaRecoveryEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery email'**
  String get mfaRecoveryEmailTitle;

  /// No description provided for @mfaCodesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} codes left'**
  String mfaCodesLeft(int count);

  /// No description provided for @mfaRemoveMethodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {method}?'**
  String mfaRemoveMethodConfirm(String method);

  /// No description provided for @mfaRemoveOnlyFactorWarning.
  ///
  /// In en, this message translates to:
  /// **'This is your only second sign-in step. If you remove it, you\'ll be asked to set one up again the next time you sign in.'**
  String get mfaRemoveOnlyFactorWarning;

  /// No description provided for @mfaGenerateCodes.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get mfaGenerateCodes;

  /// No description provided for @mfaRegenerateCodes.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get mfaRegenerateCodes;

  /// No description provided for @mfaRegenerateCodesWarning.
  ///
  /// In en, this message translates to:
  /// **'Generate a new set of backup codes? Your old codes will stop working immediately.'**
  String get mfaRegenerateCodesWarning;

  /// No description provided for @mfaAddRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Add a recovery email'**
  String get mfaAddRecoveryEmail;

  /// No description provided for @mfaRecoveryEmailExplanation.
  ///
  /// In en, this message translates to:
  /// **'If you ever can\'t sign in, we can send a verification code to this address to get you back into your account. It must be different from your account email address.'**
  String get mfaRecoveryEmailExplanation;

  /// No description provided for @mfaRecoveryEmailSameAsAccount.
  ///
  /// In en, this message translates to:
  /// **'Your recovery email must be different from your account email address.'**
  String get mfaRecoveryEmailSameAsAccount;

  /// No description provided for @shareCodes.
  ///
  /// In en, this message translates to:
  /// **'Share Codes'**
  String get shareCodes;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @mfaTooManyAttemptsWait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {wait}.'**
  String mfaTooManyAttemptsWait(String wait);

  /// No description provided for @mfaResendWaitCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend available in {wait}'**
  String mfaResendWaitCountdown(String wait);

  /// No description provided for @stepUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get stepUpTitle;

  /// No description provided for @stepUpPickMethodIntro.
  ///
  /// In en, this message translates to:
  /// **'For your security, verify with your second sign-in step to continue.'**
  String get stepUpPickMethodIntro;

  /// No description provided for @stepUpAuthenticatorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get stepUpAuthenticatorPrompt;

  /// No description provided for @stepUpPasskeyOnly.
  ///
  /// In en, this message translates to:
  /// **'Your second sign-in step is a passkey, which this app can\'t verify yet. Please use the web portal to make this change.'**
  String get stepUpPasskeyOnly;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @sessionExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpiredTitle;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @signInExpiringMessage.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in is expiring soon. Please sign in again to continue.'**
  String get signInExpiringMessage;

  /// No description provided for @biometricPromptReason.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you to keep your session active'**
  String get biometricPromptReason;

  /// No description provided for @youreAllReadyToBegin.
  ///
  /// In en, this message translates to:
  /// **'You\'re all ready to begin your first charging session.'**
  String get youreAllReadyToBegin;

  /// No description provided for @startYouFirstEVCharge.
  ///
  /// In en, this message translates to:
  /// **'Start you first EV charge'**
  String get startYouFirstEVCharge;

  /// No description provided for @locationServicesAreDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please open settings and enable location services.'**
  String get locationServicesAreDisabled;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip →'**
  String get skip;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @locationPermissionsHaveBeenDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions have been denied for this app. The performance of this app will be severely impared without this permission. Please open settings and allow location permissions.'**
  String get locationPermissionsHaveBeenDenied;

  /// No description provided for @continueStr.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueStr;

  /// No description provided for @byAllowingLocationServices.
  ///
  /// In en, this message translates to:
  /// **'By allowing location services we are able to determine charge stations closest to you.'**
  String get byAllowingLocationServices;

  /// No description provided for @findAllAvailableChargeStationsNearby.
  ///
  /// In en, this message translates to:
  /// **'Find all available charge stations nearby'**
  String get findAllAvailableChargeStationsNearby;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @letsGetYouStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started with the easiest & quickest charging app.'**
  String get letsGetYouStarted;

  /// No description provided for @eVWallet.
  ///
  /// In en, this message translates to:
  /// **'EV Wallet'**
  String get eVWallet;

  /// No description provided for @signupForAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Signup for an account'**
  String get signupForAnAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @eMail.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get eMail;

  /// No description provided for @priceUnknown.
  ///
  /// In en, this message translates to:
  /// **'price unknown'**
  String get priceUnknown;

  /// No description provided for @youHaventChargedYourEVYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t charged your EV yet.'**
  String get youHaventChargedYourEVYet;

  /// No description provided for @cardRfid.
  ///
  /// In en, this message translates to:
  /// **'Card (RFID)'**
  String get cardRfid;

  /// No description provided for @youDontHaveAnyPaymentMethodsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any payment methods yet.'**
  String get youDontHaveAnyPaymentMethodsYet;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @paymentsAndSessions.
  ///
  /// In en, this message translates to:
  /// **'Payments & Sessions'**
  String get paymentsAndSessions;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @locationServicesHaveBeenDisabledForThisApp.
  ///
  /// In en, this message translates to:
  /// **'Location services have been disabled for this app. Please enable them in your device settings.'**
  String get locationServicesHaveBeenDisabledForThisApp;

  /// No description provided for @locationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Location permission granted'**
  String get locationPermissionGranted;

  /// No description provided for @locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied for this app. Please enable it in your device settings.'**
  String
  get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get requestPermission;

  /// No description provided for @grantLocationPermissionToUseThisFeature.
  ///
  /// In en, this message translates to:
  /// **'Grant location permission to use this feature'**
  String get grantLocationPermissionToUseThisFeature;

  /// No description provided for @initialisingLocationService.
  ///
  /// In en, this message translates to:
  /// **'Initialising location service...'**
  String get initialisingLocationService;

  /// No description provided for @findEVChargingLocations.
  ///
  /// In en, this message translates to:
  /// **'Find EV charging locations'**
  String get findEVChargingLocations;

  /// No description provided for @exploreStations.
  ///
  /// In en, this message translates to:
  /// **'Explore Stations'**
  String get exploreStations;

  /// No description provided for @viewWallet.
  ///
  /// In en, this message translates to:
  /// **'View Wallet'**
  String get viewWallet;

  /// No description provided for @startAChargeSession.
  ///
  /// In en, this message translates to:
  /// **'Start a charge session'**
  String get startAChargeSession;

  /// No description provided for @charging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get charging;

  /// No description provided for @clickTheButtonBelow.
  ///
  /// In en, this message translates to:
  /// **'Click the button below'**
  String get clickTheButtonBelow;

  /// No description provided for @startYourEVCharge.
  ///
  /// In en, this message translates to:
  /// **'Start your\nEV Charge'**
  String get startYourEVCharge;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get shareLocation;

  /// No description provided for @streetView.
  ///
  /// In en, this message translates to:
  /// **'Street View'**
  String get streetView;

  /// No description provided for @pressToView.
  ///
  /// In en, this message translates to:
  /// **'Press to view'**
  String get pressToView;

  /// No description provided for @streetViewNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Street View is not available for this location'**
  String get streetViewNotAvailable;

  /// No description provided for @locationPictures.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get locationPictures;

  /// No description provided for @locationPictureCounter.
  ///
  /// In en, this message translates to:
  /// **'{index} / {total}'**
  String locationPictureCounter(int index, int total);

  /// No description provided for @locationPictureCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Photo could not be loaded'**
  String get locationPictureCouldNotLoad;

  /// No description provided for @chargeNow.
  ///
  /// In en, this message translates to:
  /// **'Charge Now'**
  String get chargeNow;

  /// No description provided for @trySearchingForAnotherLocation.
  ///
  /// In en, this message translates to:
  /// **'Try searching for another location →'**
  String get trySearchingForAnotherLocation;

  /// No description provided for @noChargeStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No charge stations found'**
  String get noChargeStationsFound;

  /// No description provided for @myCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'My current position'**
  String get myCurrentPosition;

  /// No description provided for @useMyCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Use my current position'**
  String get useMyCurrentPosition;

  /// No description provided for @searchAddressOrPlaceName.
  ///
  /// In en, this message translates to:
  /// **'Search address or place name'**
  String get searchAddressOrPlaceName;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @connectorType.
  ///
  /// In en, this message translates to:
  /// **'Connector Type'**
  String get connectorType;

  /// No description provided for @chargingPowerkW.
  ///
  /// In en, this message translates to:
  /// **'Charging Power [kW]'**
  String get chargingPowerkW;

  /// No description provided for @chargers.
  ///
  /// In en, this message translates to:
  /// **'Chargers'**
  String get chargers;

  /// No description provided for @dCChargers.
  ///
  /// In en, this message translates to:
  /// **'DC Chargers'**
  String get dCChargers;

  /// No description provided for @availableChargers.
  ///
  /// In en, this message translates to:
  /// **'Available Chargers'**
  String get availableChargers;

  /// No description provided for @onlyShow.
  ///
  /// In en, this message translates to:
  /// **'Only Show'**
  String get onlyShow;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @findMoreStationsNearby.
  ///
  /// In en, this message translates to:
  /// **'Find more stations nearby →'**
  String get findMoreStationsNearby;

  /// Link text on low speed highway mode screen to navigate to map
  ///
  /// In en, this message translates to:
  /// **'Find stations nearby →'**
  String get findStationsNearby;

  /// No description provided for @highwayModeAvailableWhileDriving.
  ///
  /// In en, this message translates to:
  /// **'Highway mode is available while driving outside of city speed limits.'**
  String get highwayModeAvailableWhileDriving;

  /// No description provided for @youCanAlwaysFindNearbyStations.
  ///
  /// In en, this message translates to:
  /// **'You can always find nearby stations on our map.'**
  String get youCanAlwaysFindNearbyStations;

  /// No description provided for @nearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Nearby stations'**
  String get nearbyStations;

  /// No description provided for @selectYourChargeStation.
  ///
  /// In en, this message translates to:
  /// **'Select your charge station'**
  String get selectYourChargeStation;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @unnamedCard.
  ///
  /// In en, this message translates to:
  /// **'unnamed card'**
  String get unnamedCard;

  /// No description provided for @noCardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cards available'**
  String get noCardsAvailable;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get startSession;

  /// No description provided for @unknownEVSEID.
  ///
  /// In en, this message translates to:
  /// **'Unknown EVSE ID'**
  String get unknownEVSEID;

  /// No description provided for @startChargingSession.
  ///
  /// In en, this message translates to:
  /// **'Start charging session'**
  String get startChargingSession;

  /// No description provided for @exploreOrSearchForALocation.
  ///
  /// In en, this message translates to:
  /// **'Explore or search for a location →'**
  String get exploreOrSearchForALocation;

  /// No description provided for @thereArentAnyStationsNearYou.
  ///
  /// In en, this message translates to:
  /// **'There aren\'t any stations near your location.\n\nAutomatic location search is still in progress and will detect stations near you as you move closer to them until you close this screen.'**
  String get thereArentAnyStationsNearYou;

  /// No description provided for @noStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No stations found.'**
  String get noStationsFound;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select Station'**
  String get selectStation;

  /// No description provided for @evseId.
  ///
  /// In en, this message translates to:
  /// **'EVSE ID'**
  String get evseId;

  /// No description provided for @manualStationInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Station Input'**
  String get manualStationInput;

  /// No description provided for @manualEVSEIDInput.
  ///
  /// In en, this message translates to:
  /// **'Manual EVSE ID input →'**
  String get manualEVSEIDInput;

  /// No description provided for @noSelectDifferentStation.
  ///
  /// In en, this message translates to:
  /// **'No, select different station →'**
  String get noSelectDifferentStation;

  /// No description provided for @yesThisIsMe.
  ///
  /// In en, this message translates to:
  /// **'Yes this is me!'**
  String get yesThisIsMe;

  /// No description provided for @isThisYou.
  ///
  /// In en, this message translates to:
  /// **'Is this you?'**
  String get isThisYou;

  /// No description provided for @imAllPluggedIn.
  ///
  /// In en, this message translates to:
  /// **'I\'m all plugged in!'**
  String get imAllPluggedIn;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @yourCarIsCharging.
  ///
  /// In en, this message translates to:
  /// **'Your car is charging'**
  String get yourCarIsCharging;

  /// No description provided for @unknownKWh.
  ///
  /// In en, this message translates to:
  /// **'unknown kWh'**
  String get unknownKWh;

  /// Header for the profile page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @removeAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get removeAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @directPayments.
  ///
  /// In en, this message translates to:
  /// **'Direct Payments'**
  String get directPayments;

  /// No description provided for @chargingCardOrTag.
  ///
  /// In en, this message translates to:
  /// **'Charging Card or Tag'**
  String get chargingCardOrTag;

  /// No description provided for @withoutAdditionalFeePerSession.
  ///
  /// In en, this message translates to:
  /// **'Without additional fee per session'**
  String get withoutAdditionalFeePerSession;

  /// No description provided for @supportsRemoteCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge via App'**
  String get supportsRemoteCharge;

  /// No description provided for @additionalFee.
  ///
  /// In en, this message translates to:
  /// **'Additional Fee'**
  String get additionalFee;

  /// No description provided for @favouriteStations.
  ///
  /// In en, this message translates to:
  /// **'Favourite Stations'**
  String get favouriteStations;

  /// Compass direction abbreviation for North - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get compassDirectionNorth;

  /// Compass direction abbreviation for North-East - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get compassDirectionNorthEast;

  /// Compass direction abbreviation for East - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get compassDirectionEast;

  /// Compass direction abbreviation for South-East - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get compassDirectionSouthEast;

  /// Compass direction abbreviation for South - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get compassDirectionSouth;

  /// Compass direction abbreviation for South-West - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get compassDirectionSouthWest;

  /// Compass direction abbreviation for West - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get compassDirectionWest;

  /// Compass direction abbreviation for North-West - used in highway mode to show travel direction
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get compassDirectionNorthWest;

  /// Label for total number of charging sessions in stats widget
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get totalSessions;

  /// Label for total energy consumed in stats widget
  ///
  /// In en, this message translates to:
  /// **'Total Energy'**
  String get totalEnergy;

  /// Label for total charging time in stats widget
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTime;

  /// Label for total cost in stats widget
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get totalCost;

  /// Tooltip text explaining that cost is approximate
  ///
  /// In en, this message translates to:
  /// **'Note that the cost displayed here is approximate and does not include all additional fees. Full costs are displayed on your invoice.'**
  String get costTooltipText;

  /// Placeholder text for filter dropdown selectors
  ///
  /// In en, this message translates to:
  /// **'Select option'**
  String get selectOption;

  /// CarPlay/Android Auto template title when highway mode is active
  ///
  /// In en, this message translates to:
  /// **'Fast Chargers Ahead'**
  String get carScreenFastChargersAhead;

  /// CarPlay filter list row title for the highway mode setting
  ///
  /// In en, this message translates to:
  /// **'Highway mode'**
  String get carScreenHighway;

  /// CarPlay/Android Auto highway mode toggle button label when auto-switching is enabled
  ///
  /// In en, this message translates to:
  /// **'Highway mode: Auto'**
  String get carScreenHighwayAuto;

  /// CarPlay/Android Auto highway mode button label when highway mode is off
  ///
  /// In en, this message translates to:
  /// **'Highway mode: Off'**
  String get carScreenHighwayOff;

  /// CarPlay/Android Auto highway mode button label when highway mode is always on
  ///
  /// In en, this message translates to:
  /// **'Highway mode: On'**
  String get carScreenHighwayOn;

  /// CarPlay/Android Auto button to start navigation to a charging station
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get carScreenNavigate;

  /// CarPlay/Android Auto button to show station detail screen
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get carScreenShowDetails;

  /// CarPlay/Android Auto filter button label showing active filter count
  ///
  /// In en, this message translates to:
  /// **'Filters ({count})'**
  String carScreenFiltersCount(int count);

  /// CarPlay/Android Auto filter status label when filter is enabled
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get carScreenFilterOn;

  /// CarPlay/Android Auto filter status label when filter is disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get carScreenFilterOff;

  /// CarPlay/Android Auto message shown while station data is loading
  ///
  /// In en, this message translates to:
  /// **'Searching for nearby charging stations…'**
  String get carScreenSearchingStations;

  /// CarPlay/Android Auto message shown when a search returned no stations
  ///
  /// In en, this message translates to:
  /// **'No charging stations found nearby'**
  String get carScreenNoStationsFound;

  /// Android Auto error message when navigation cannot be started
  ///
  /// In en, this message translates to:
  /// **'Navigation not available'**
  String get carScreenNavigationNotAvailable;

  /// Android Auto error screen title for navigation failures
  ///
  /// In en, this message translates to:
  /// **'Navigation Error'**
  String get carScreenNavigationError;

  /// Android Auto button to open navigation on the phone instead
  ///
  /// In en, this message translates to:
  /// **'Navigate on Phone'**
  String get carScreenNavigateOnPhone;

  /// Android Auto message shown when no filter definitions have been received
  ///
  /// In en, this message translates to:
  /// **'No filters available'**
  String get carScreenNoFiltersAvailable;

  /// Availability count text for car screen station display
  ///
  /// In en, this message translates to:
  /// **'{available}/{total} available'**
  String carScreenAvailabilityCount(int available, int total);

  /// Price per kWh text for car screen station display
  ///
  /// In en, this message translates to:
  /// **'{price}/kWh'**
  String carScreenPricePerKwh(String price);

  /// Tab label for the map/stations tab in CarPlay and Android Auto
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get carScreenTabMap;

  /// Tab label for the filters tab in CarPlay and Android Auto
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get carScreenTabFilters;

  /// Tab label for the favourites tab in CarPlay and Android Auto
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get carScreenTabFavourites;

  /// Message shown when the user has no favourite stations in CarPlay/Android Auto
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get carScreenNoFavourites;

  /// Message shown on the favourites tab in CarPlay/Android Auto when the user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Log in to save your favourite stations'**
  String get carScreenLoginToSaveFavourites;

  /// Button label to save a station as a favourite in CarPlay/Android Auto
  ///
  /// In en, this message translates to:
  /// **'🤍 Save'**
  String get carScreenSave;

  /// Button label shown when a station is already saved as a favourite in CarPlay/Android Auto
  ///
  /// In en, this message translates to:
  /// **'❤️ Saved'**
  String get carScreenSaved;

  /// Label for the charging power filter group in CarPlay/Android Auto
  ///
  /// In en, this message translates to:
  /// **'Charging Power'**
  String get carScreenChargingPower;

  /// Generic 'All' label used for unfiltered state in car screen filters (e.g. all power tiers, all connector types)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get carScreenAll;

  /// Label for slow charging power filter (3+ kW) in car screen
  ///
  /// In en, this message translates to:
  /// **'Slow (3+ kW)'**
  String get carScreenPowerSlow;

  /// Label for fast charging power filter (23+ kW) in car screen
  ///
  /// In en, this message translates to:
  /// **'Fast (23+ kW)'**
  String get carScreenPowerFast;

  /// Label for rapid charging power filter (100+ kW) in car screen
  ///
  /// In en, this message translates to:
  /// **'Rapid (100+ kW)'**
  String get carScreenPowerRapid;

  /// Label for ultra charging power filter (200+ kW) in car screen
  ///
  /// In en, this message translates to:
  /// **'Ultra (200+ kW)'**
  String get carScreenPowerUltra;

  /// Shown when multiple options are selected in a car screen filter group
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String carScreenCountSelected(int count);

  /// No description provided for @selectNetworks.
  ///
  /// In en, this message translates to:
  /// **'Select Networks'**
  String get selectNetworks;

  /// No description provided for @excludeNetworks.
  ///
  /// In en, this message translates to:
  /// **'Exclude Networks'**
  String get excludeNetworks;

  /// No description provided for @selectNetworksToInclude.
  ///
  /// In en, this message translates to:
  /// **'Select networks to include'**
  String get selectNetworksToInclude;

  /// No description provided for @selectNetworksToExclude.
  ///
  /// In en, this message translates to:
  /// **'Select networks to exclude'**
  String get selectNetworksToExclude;

  /// No description provided for @searchNetworks.
  ///
  /// In en, this message translates to:
  /// **'Search networks'**
  String get searchNetworks;

  /// No description provided for @couldNotLoadNetworks.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load networks'**
  String get couldNotLoadNetworks;

  /// No description provided for @noNetworksFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found'**
  String get noNetworksFound;

  /// No description provided for @addANetwork.
  ///
  /// In en, this message translates to:
  /// **'+ Add a network'**
  String get addANetwork;

  /// No description provided for @reportProblemEntryStation.
  ///
  /// In en, this message translates to:
  /// **'Having issues with this station?'**
  String get reportProblemEntryStation;

  /// No description provided for @reportProblemEntrySession.
  ///
  /// In en, this message translates to:
  /// **'Had an issue with your session?'**
  String get reportProblemEntrySession;

  /// No description provided for @reportProblemEntrySessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Had an issue during your session?'**
  String get reportProblemEntrySessionEnded;

  /// No description provided for @reportProblemEntryCta.
  ///
  /// In en, this message translates to:
  /// **'Report it here'**
  String get reportProblemEntryCta;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemTitle;

  /// No description provided for @reportProblemFieldConnector.
  ///
  /// In en, this message translates to:
  /// **'Connector'**
  String get reportProblemFieldConnector;

  /// No description provided for @reportProblemFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Problem Type'**
  String get reportProblemFieldCategory;

  /// No description provided for @reportProblemFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportProblemFieldDescription;

  /// No description provided for @reportProblemDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get reportProblemDescriptionPlaceholder;

  /// No description provided for @reportProblemSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportProblemSubmit;

  /// No description provided for @reportProblemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thanks for helping out.'**
  String get reportProblemSuccess;

  /// No description provided for @reportProblemCategoryChargerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Charger is not available'**
  String get reportProblemCategoryChargerNotAvailable;

  /// No description provided for @reportProblemCategoryChargerDamaged.
  ///
  /// In en, this message translates to:
  /// **'Charger is damaged'**
  String get reportProblemCategoryChargerDamaged;

  /// No description provided for @reportProblemCategoryChargerHardToFind.
  ///
  /// In en, this message translates to:
  /// **'Charger is hard to find'**
  String get reportProblemCategoryChargerHardToFind;

  /// No description provided for @reportProblemCategoryWrongConnectorSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wrong connector speed'**
  String get reportProblemCategoryWrongConnectorSpeed;

  /// No description provided for @reportProblemCategoryWrongConnectorType.
  ///
  /// In en, this message translates to:
  /// **'Wrong connector type'**
  String get reportProblemCategoryWrongConnectorType;

  /// No description provided for @reportProblemCategoryMissingPriceInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing price information'**
  String get reportProblemCategoryMissingPriceInformation;

  /// No description provided for @reportProblemCategoryMissingPowerInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing power information'**
  String get reportProblemCategoryMissingPowerInformation;

  /// No description provided for @reportProblemCategoryChargingSessionInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Charging session interrupted'**
  String get reportProblemCategoryChargingSessionInterrupted;

  /// No description provided for @reportProblemCategoryChargingSessionNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Charging session did not start'**
  String get reportProblemCategoryChargingSessionNotStarted;

  /// No description provided for @reportProblemCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportProblemCategoryOther;

  /// No description provided for @stepUpPasskeyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Use your passkey to confirm it\'s you.'**
  String get stepUpPasskeyPrompt;

  /// No description provided for @stepUpPasskeyNoCredential.
  ///
  /// In en, this message translates to:
  /// **'No passkey for this account was found on this device. Please use the web portal to make this change.'**
  String get stepUpPasskeyNoCredential;

  /// No description provided for @passkeyAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get passkeyAuthentication;

  /// No description provided for @passkeySignInWithDevice.
  ///
  /// In en, this message translates to:
  /// **'Verify with your fingerprint, face or screen lock'**
  String get passkeySignInWithDevice;

  /// No description provided for @mfaPasskeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify with your passkey'**
  String get mfaPasskeyTitle;

  /// No description provided for @mfaPasskeyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you using your fingerprint, face or screen lock.'**
  String get mfaPasskeyExplanation;

  /// No description provided for @mfaPasskeyButton.
  ///
  /// In en, this message translates to:
  /// **'Use passkey'**
  String get mfaPasskeyButton;

  /// No description provided for @mfaPasskeyNoCredential.
  ///
  /// In en, this message translates to:
  /// **'No passkey for this account was found on this device. Please sign in on the web to use another method.'**
  String get mfaPasskeyNoCredential;

  /// No description provided for @mfaEnrolPasskeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a passkey'**
  String get mfaEnrolPasskeyTitle;

  /// No description provided for @mfaEnrolPasskeyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Sign in quickly and securely using your fingerprint, face or screen lock instead of a code.'**
  String get mfaEnrolPasskeyExplanation;

  /// No description provided for @mfaEnrolPasskeyButton.
  ///
  /// In en, this message translates to:
  /// **'Create passkey'**
  String get mfaEnrolPasskeyButton;

  /// No description provided for @mfaPasskeyAlreadyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'This device already has a passkey for this account. You can use it to sign in, or pick another verification method.'**
  String get mfaPasskeyAlreadyOnDevice;

  /// No description provided for @signInWithAPasskey.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a passkey'**
  String get signInWithAPasskey;

  /// No description provided for @passkeyLoginNoCredential.
  ///
  /// In en, this message translates to:
  /// **'No passkey was found on this device. Please sign in with your email and password.'**
  String get passkeyLoginNoCredential;

  /// No description provided for @mfaPasskeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Passkeys'**
  String get mfaPasskeysTitle;

  /// No description provided for @mfaPasskeysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 passkey} other{{count} passkeys}}'**
  String mfaPasskeysCount(num count);

  /// No description provided for @mfaPasskeysIntro.
  ///
  /// In en, this message translates to:
  /// **'Passkeys let you sign in with your fingerprint, face or screen lock instead of a password. You can add more than one.'**
  String get mfaPasskeysIntro;

  /// No description provided for @mfaPasskeysDisallowed.
  ///
  /// In en, this message translates to:
  /// **'Your administrator no longer allows passkeys for sign-in. You can remove existing passkeys, but new ones can\'t be added.'**
  String get mfaPasskeysDisallowed;

  /// No description provided for @mfaPasskeysUnsupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Passkeys can\'t be added on this device.'**
  String get mfaPasskeysUnsupportedDevice;

  /// No description provided for @mfaAddPasskey.
  ///
  /// In en, this message translates to:
  /// **'Add a passkey'**
  String get mfaAddPasskey;

  /// No description provided for @mfaPasskeyAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added on {date}'**
  String mfaPasskeyAddedOn(String date);

  /// No description provided for @mfaPasskeyLastUsedOn.
  ///
  /// In en, this message translates to:
  /// **'Last used {date}'**
  String mfaPasskeyLastUsedOn(String date);

  /// No description provided for @mfaPasskeyRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename passkey'**
  String get mfaPasskeyRenameTitle;

  /// No description provided for @mfaPasskeyNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Give this passkey a name so you can recognise it later.'**
  String get mfaPasskeyNameHelp;

  /// No description provided for @mfaPasskeyNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Work laptop'**
  String get mfaPasskeyNamePlaceholder;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @mfaPasskeyVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Passkey verification failed. Please try again.'**
  String get mfaPasskeyVerificationFailed;

  /// No description provided for @mfaPasskeyChallengeMissing.
  ///
  /// In en, this message translates to:
  /// **'Passkey verification could not be started. Please try again.'**
  String get mfaPasskeyChallengeMissing;

  /// No description provided for @mfaPasskeyCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a passkey on this device.'**
  String get mfaPasskeyCreateFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
