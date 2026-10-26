import 'app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:phrase/phrase.dart';

class _PhraseLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
	const _PhraseLocalizationsDelegate();
	@override
	Future<AppLocalizations> load(Locale locale) => AppLocalizations.delegate.load(locale).then((fallback) => PhraseLocalizations(locale.toString(), fallback)).whenComplete(() => Phrase.onLocale(locale));
	@override
	bool isSupported(Locale locale) => AppLocalizations.supportedLocales.contains(locale);
	@override
	bool shouldReload(_PhraseLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on AppLocalizations {
	String getText(String key, {Map<String, dynamic> args = const {}, String? fallbackValue}) {
		final value = Phrase.getText(localeName, key, args);
		if (value != null) return value;
		if (fallbackValue != null) return fallbackValue;
		return (this as PhraseLocalizations).useFallback(key, args, fallbackValue);
	}
}

class PhraseLocalizations extends AppLocalizations {
	PhraseLocalizations(String locale, AppLocalizations fallback) : _fallback = fallback, super(locale);
	final AppLocalizations _fallback;

	static const LocalizationsDelegate<AppLocalizations> delegate = _PhraseLocalizationsDelegate();
	static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
		delegate,
		GlobalMaterialLocalizations.delegate,
		GlobalCupertinoLocalizations.delegate,
		GlobalWidgetsLocalizations.delegate,
	];
	static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

	String useFallback(String key, Map<String, dynamic> args, String? fallbackValue) {
		switch (key) {
			case 'highwayMode':
				return _fallback.highwayMode;
			case 'stopAtNearestFastChargingStation':
				return _fallback.stopAtNearestFastChargingStation;
			case 'emailAddressSuccessfullyVerified':
				return _fallback.emailAddressSuccessfullyVerified;
			case 'phoneNumberSuccessfullyVerified':
				return _fallback.phoneNumberSuccessfullyVerified;
			case 'pleaseVerifyYourPhoneNumberAndEmail':
				return _fallback.pleaseVerifyYourPhoneNumberAndEmail;
			case 'verifyYourPhoneNumberNow':
				return _fallback.verifyYourPhoneNumberNow;
			case 'verifyYourEmailNow':
				return _fallback.verifyYourEmailNow;
			case 'verifyYourEmailAddress':
				return _fallback.verifyYourEmailAddress;
			case 'weSentYouAnEmailVerification':
				return _fallback.weSentYouAnEmailVerification(args['emailAddress']);
			case 'openMailApp':
				return _fallback.openMailApp;
			case 'pleaseConfirmYourEmailAddressByClicking':
				return _fallback.pleaseConfirmYourEmailAddressByClicking;
			case 'didntReceiveTheEmail':
				return _fallback.didntReceiveTheEmail;
			case 'resendEmailVerificationLink':
				return _fallback.resendEmailVerificationLink;
			case 'verified':
				return _fallback.verified;
			case 'stationAddedToYourFavourites':
				return _fallback.stationAddedToYourFavourites;
			case 'removedFromYourFavourites':
				return _fallback.removedFromYourFavourites;
			case 'yourFavouriteStationsWillShowUpHere':
				return _fallback.yourFavouriteStationsWillShowUpHere;
			case 'markStationsAsFavouriteByPressingTheHeartIcon':
				return _fallback.markStationsAsFavouriteByPressingTheHeartIcon;
			case 'addToFavourites':
				return _fallback.addToFavourites;
			case 'removeFromFavourites':
				return _fallback.removeFromFavourites;
			case 'exploreMap':
				return _fallback.exploreMap;
			case 'nearestStations':
				return _fallback.nearestStations;
			case 'fastStationsWithPower':
				return _fallback.fastStationsWithPower;
			case 'onRoad':
				return _fallback.onRoad(args['road']);
			case 'noNearbyStations':
				return _fallback.noNearbyStations;
			case 'noChargingStationsFoundNearby':
				return _fallback.noChargingStationsFoundNearby;
			case 'accountRemovalIsPending':
				return _fallback.accountRemovalIsPending;
			case 'areYouSureYouWantToRemoveYourAccount':
				return _fallback.areYouSureYouWantToRemoveYourAccount;
			case 'thisActionIsPermanent':
				return _fallback.thisActionIsPermanent;
			case 'yesRemoveAccount':
				return _fallback.yesRemoveAccount;
			case 'weSentYouAndSmsFullNumber':
				return _fallback.weSentYouAndSmsFullNumber(args['phoneNumber']);
			case 'saveRecoveryCodes':
				return _fallback.saveRecoveryCodes;
			case 'recoveryCodesCanBeUsed':
				return _fallback.recoveryCodesCanBeUsed;
			case 'downloadCodes':
				return _fallback.downloadCodes;
			case 'copyCodes':
				return _fallback.copyCodes;
			case 'iSavedMyBackupCodes':
				return _fallback.iSavedMyBackupCodes;
			case 'putTheseInASafeSpot':
				return _fallback.putTheseInASafeSpot;
			case 'or':
				return _fallback.or;
			case 'oneDownloadAnAuthenticatorApp':
				return _fallback.oneDownloadAnAuthenticatorApp;
			case 'weRecommendGoogleAuthenticator':
				return _fallback.weRecommendGoogleAuthenticator;
			case 'googleAuthenticator':
				return _fallback.googleAuthenticator;
			case 'onePassword':
				return _fallback.onePassword;
			case 'authy':
				return _fallback.authy;
			case 'twoScanTheQrCode':
				return _fallback.twoScanTheQrCode;
			case 'threeEnterTheCode':
				return _fallback.threeEnterTheCode;
			case 'appAuthentication':
				return _fallback.appAuthentication;
			case 'securityCodesGeneratedByApp':
				return _fallback.securityCodesGeneratedByApp;
			case 'smsAuthentication':
				return _fallback.smsAuthentication;
			case 'securityCodesSentViaSms':
				return _fallback.securityCodesSentViaSms;
			case 'passwordAndAuthentication':
				return _fallback.passwordAndAuthentication;
			case 'dontHaveYourBackupCodes':
				return _fallback.dontHaveYourBackupCodes;
			case 'contactSupportAt':
				return _fallback.contactSupportAt;
			case 'toStartAManualVerificationProcess':
				return _fallback.toStartAManualVerificationProcess;
			case 'pleaseEnterBackupCode':
				return _fallback.pleaseEnterBackupCode;
			case 'backupVerificationCode':
				return _fallback.backupVerificationCode;
			case 'codeEnteredIsIncorrect':
				return _fallback.codeEnteredIsIncorrect;
			case 'isThisAuthMethodNotWorking':
				return _fallback.isThisAuthMethodNotWorking;
			case 'useYourBackupCodes':
				return _fallback.useYourBackupCodes;
			case 'chooseVerificationMethod':
				return _fallback.chooseVerificationMethod;
			case 'howWouldYouLikeToVerify':
				return _fallback.howWouldYouLikeToVerify;
			case 'useRecoveryCode':
				return _fallback.useRecoveryCode;
			case 'enterRecoveryCodeBelow':
				return _fallback.enterRecoveryCodeBelow;
			case 'recoveryCode':
				return _fallback.recoveryCode;
			case 'useDifferentVerificationMethod':
				return _fallback.useDifferentVerificationMethod;
			case 'weSentACodeToPhone':
				return _fallback.weSentACodeToPhone(args['phoneNumber']);
			case 'weSentACodeToEmail':
				return _fallback.weSentACodeToEmail(args['emailAddress']);
			case 'secureYourAccount':
				return _fallback.secureYourAccount;
			case 'mfaEnrolExplanationEncourage':
				return _fallback.mfaEnrolExplanationEncourage;
			case 'mfaEnrolExplanationEnforce':
				return _fallback.mfaEnrolExplanationEnforce;
			case 'skipForNow':
				return _fallback.skipForNow;
			case 'confirmYourEmailFirst':
				return _fallback.confirmYourEmailFirst;
			case 'chooseEnrolmentMethod':
				return _fallback.chooseEnrolmentMethod;
			case 'cantScanTheCode':
				return _fallback.cantScanTheCode;
			case 'enterTheSecurityCodeGenerated':
				return _fallback.enterTheSecurityCodeGenerated;
			case 'enterCode':
				return _fallback.enterCode;
			case 'weSentYouAnSms':
				return _fallback.weSentYouAnSms;
			case 'enterThe6DigitCodeBelow':
				return _fallback.enterThe6DigitCodeBelow;
			case 'verify':
				return _fallback.verify;
			case 'stepCounter':
				return _fallback.stepCounter(args['current'], args['total']);
			case 'verifyPhoneStepTitle':
				return _fallback.verifyPhoneStepTitle;
			case 'verifyEmailStepTitle':
				return _fallback.verifyEmailStepTitle;
			case 'didntReceiveTheCode':
				return _fallback.didntReceiveTheCode;
			case 'resendVerificationCode':
				return _fallback.resendVerificationCode;
			case 'codeResent':
				return _fallback.codeResent;
			case 'brandnameChargers':
				return _fallback.brandnameChargers;
			case 'publicTariff':
				return _fallback.publicTariff;
			case 'specialCardTariff':
				return _fallback.specialCardTariff;
			case 'updateBillingInformation':
				return _fallback.updateBillingInformation;
			case 'billingAddressSuccessfullyUpdated':
				return _fallback.billingAddressSuccessfullyUpdated;
			case 'provideYourBillingDetails':
				return _fallback.provideYourBillingDetails;
			case 'profileSuccessfullyUpdated':
				return _fallback.profileSuccessfullyUpdated;
			case 'updateProfile':
				return _fallback.updateProfile;
			case 'manageYourPersonalContactInformation':
				return _fallback.manageYourPersonalContactInformation;
			case 'passwordSuccessfullyUpdated':
				return _fallback.passwordSuccessfullyUpdated;
			case 'updatePassword':
				return _fallback.updatePassword;
			case 'passwordIsRequired':
				return _fallback.passwordIsRequired;
			case 'updateYourPassword':
				return _fallback.updateYourPassword;
			case 'currentPassword':
				return _fallback.currentPassword;
			case 'newPassword':
				return _fallback.newPassword;
			case 'accountSettings':
				return _fallback.accountSettings;
			case 'enableNotifications':
				return _fallback.enableNotifications;
			case 'pleaseAllowNotifications':
				return _fallback.pleaseAllowNotifications;
			case 'sendNotifications':
				return _fallback.sendNotifications;
			case 'chargingUpdatesSubtitleIOS':
				return _fallback.chargingUpdatesSubtitleIOS;
			case 'chargingUpdatesSubtitleAndroid':
				return _fallback.chargingUpdatesSubtitleAndroid;
			case 'personalSettings':
				return _fallback.personalSettings;
			case 'notifications':
				return _fallback.notifications;
			case 'manageYourNotifications':
				return _fallback.manageYourNotifications;
			case 'allNotifications':
				return _fallback.allNotifications;
			case 'chargingStartedTitle':
				return _fallback.chargingStartedTitle;
			case 'chargingSessionEndedTitle':
				return _fallback.chargingSessionEndedTitle;
			case 'chargingSessionStateOver80Title':
				return _fallback.chargingSessionStateOver80Title;
			case 'chargingSessionChargingTitle':
				return _fallback.chargingSessionChargingTitle;
			case 'chargingSessionSuspendedEvTitle':
				return _fallback.chargingSessionSuspendedEvTitle;
			case 'chargingSessionSuspendedEvseTitle':
				return _fallback.chargingSessionSuspendedEvseTitle;
			case 'chargingSessionStartedSubtitle':
				return _fallback.chargingSessionStartedSubtitle;
			case 'chargingSessionEndedSubtitle':
				return _fallback.chargingSessionEndedSubtitle;
			case 'chargingSessionStateOver80Subtitle':
				return _fallback.chargingSessionStateOver80Subtitle;
			case 'chargingSessionChargingSubtitle':
				return _fallback.chargingSessionChargingSubtitle;
			case 'chargingSessionSuspendedEvSubtitle':
				return _fallback.chargingSessionSuspendedEvSubtitle;
			case 'chargingSessionSuspendedEvseSubtitle':
				return _fallback.chargingSessionSuspendedEvseSubtitle;
			case 'chargingSessionLiveUpdateTitle':
				return _fallback.chargingSessionLiveUpdateTitle;
			case 'chargingSessionLiveUpdateSubtitleIOS':
				return _fallback.chargingSessionLiveUpdateSubtitleIOS;
			case 'chargingSessionLiveUpdateSubtitleAndroid':
				return _fallback.chargingSessionLiveUpdateSubtitleAndroid;
			case 'wantToAddYourCreditOrDebitCardLater':
				return _fallback.wantToAddYourCreditOrDebitCardLater;
			case 'viewYourChargeCards':
				return _fallback.viewYourChargeCards;
			case 'viewYourPreviousChargingSessions':
				return _fallback.viewYourPreviousChargingSessions;
			case 'viewInvoicesForYourChargeCards':
				return _fallback.viewInvoicesForYourChargeCards;
			case 'viewYourProfileAndAccount':
				return _fallback.viewYourProfileAndAccount;
			case 'payWith':
				return _fallback.payWith;
			case 'postCodeIsInvalid':
				return _fallback.postCodeIsInvalid;
			case 'later':
				return _fallback.later;
			case 'enableLocationServices':
				return _fallback.enableLocationServices;
			case 'pleaseAllowLocationUpdates':
				return _fallback.pleaseAllowLocationUpdates;
			case 'contactUs':
				return _fallback.contactUs;
			case 'accountCreatedWelcomeOnBoard':
				return _fallback.accountCreatedWelcomeOnBoard;
			case 'search':
				return _fallback.search;
			case 'lookingForAppleOrGooglePay':
				return _fallback.lookingForAppleOrGooglePay;
			case 'skipThisStep':
				return _fallback.skipThisStep;
			case 'invalidPhoneNumber':
				return _fallback.invalidPhoneNumber;
			case 'appVersion':
				return _fallback.appVersion;
			case 'privacyStatementOneLine':
				return _fallback.privacyStatementOneLine;
			case 'termsOfServiceOneLine':
				return _fallback.termsOfServiceOneLine;
			case 'aboutUs':
				return _fallback.aboutUs;
			case 'about':
				return _fallback.about;
			case 'support':
				return _fallback.support;
			case 'addCreditOrDebitCard':
				return _fallback.addCreditOrDebitCard;
			case 'byAddingAPaymentMethod':
				return _fallback.byAddingAPaymentMethod;
			case 'youWillAddYourPaymentDetails':
				return _fallback.youWillAddYourPaymentDetails;
			case 'supportedMethods':
				return _fallback.supportedMethods;
			case 'payments':
				return _fallback.payments;
			case 'invoices':
				return _fallback.invoices;
			case 'signupNowToSeeYourChargeCards':
				return _fallback.signupNowToSeeYourChargeCards;
			case 'signupNowToViewChargingSessions':
				return _fallback.signupNowToViewChargingSessions;
			case 'signupNowToViewInvoices':
				return _fallback.signupNowToViewInvoices;
			case 'alreadyHaveAnAccount':
				return _fallback.alreadyHaveAnAccount;
			case 'applePay':
				return _fallback.applePay;
			case 'googlePay':
				return _fallback.googlePay;
			case 'downloadInvoice':
				return _fallback.downloadInvoice;
			case 'invoiceDetails':
				return _fallback.invoiceDetails;
			case 'noInvoiceDataAvailable':
				return _fallback.noInvoiceDataAvailable;
			case 'filterByYear':
				return _fallback.filterByYear;
			case 'chargeCardInvoices':
				return _fallback.chargeCardInvoices;
			case 'viewAllInvoices':
				return _fallback.viewAllInvoices;
			case 'chooseRoutingApp':
				return _fallback.chooseRoutingApp;
			case 'manuallyInputStationId':
				return _fallback.manuallyInputStationId;
			case 'inputTheStationIdFromTheSticker':
				return _fallback.inputTheStationIdFromTheSticker;
			case 'findTheStickerEnterTheDigits':
				return _fallback.findTheStickerEnterTheDigits;
			case 'scanStationQrCode':
				return _fallback.scanStationQrCode;
			case 'useCameraToIdentifyStationId':
				return _fallback.useCameraToIdentifyStationId;
			case 'qrScannerTorchToggle':
				return _fallback.qrScannerTorchToggle;
			case 'cameraPermissionRequired':
				return _fallback.cameraPermissionRequired;
			case 'cameraPermissionMessage':
				return _fallback.cameraPermissionMessage;
			case 'cameraPermissionDenied':
				return _fallback.cameraPermissionDenied;
			case 'errorAccessingCamera':
				return _fallback.errorAccessingCamera;
			case 'stationId':
				return _fallback.stationId;
			case 'example':
				return _fallback.example;
			case 'input':
				return _fallback.input;
			case 'dontHaveAnAccount':
				return _fallback.dontHaveAnAccount;
			case 'signup':
				return _fallback.signup;
			case 'youHaventAddedAnyCardsYet':
				return _fallback.youHaventAddedAnyCardsYet;
			case 'selectPaymentMethod':
				return _fallback.selectPaymentMethod;
			case 'chargingInProgress':
				return _fallback.chargingInProgress;
			case 'cancelSession':
				return _fallback.cancelSession;
			case 'unableToConnectToServer':
				return _fallback.unableToConnectToServer;
			case 'chargeCard':
				return _fallback.chargeCard;
			case 'youAreReadyToGo':
				return _fallback.youAreReadyToGo;
			case 'noteWeAreStillProcessing':
				return _fallback.noteWeAreStillProcessing;
			case 'sessionCompleted':
				return _fallback.sessionCompleted;
			case 'sessionDetails':
				return _fallback.sessionDetails;
			case 'price':
				return _fallback.price;
			case 'inclVat':
				return _fallback.inclVat;
			case 'exclVat':
				return _fallback.exclVat;
			case 'usage':
				return _fallback.usage;
			case 'duration':
				return _fallback.duration;
			case 'startTime':
				return _fallback.startTime;
			case 'endTime':
				return _fallback.endTime;
			case 'charged':
				return _fallback.charged;
			case 'date':
				return _fallback.date;
			case 'totalCosts':
				return _fallback.totalCosts;
			case 'payment':
				return _fallback.payment;
			case 'thereArentAnyStationsNearYourLocations':
				return _fallback.thereArentAnyStationsNearYourLocations;
			case 'sessionStarting':
				return _fallback.sessionStarting;
			case 'sessionStopping':
				return _fallback.sessionStopping;
			case 'sessionEnded':
				return _fallback.sessionEnded;
			case 'stationDoesntSupportSessions':
				return _fallback.stationDoesntSupportSessions;
			case 'stationOnlySupportsRfidCards':
				return _fallback.stationOnlySupportsRfidCards;
			case 'stationOnlySupportsCreditCards':
				return _fallback.stationOnlySupportsCreditCards;
			case 'weLoggedYouInAutomatically':
				return _fallback.weLoggedYouInAutomatically;
			case 'cannotAddAPaymentMethod':
				return _fallback.cannotAddAPaymentMethod;
			case 'imAllPluggedInToTheEvStation':
				return _fallback.imAllPluggedInToTheEvStation;
			case 'automaticallyDetectMyConnection':
				return _fallback.automaticallyDetectMyConnection;
			case 'findNearbyEvStations':
				return _fallback.findNearbyEvStations;
			case 'chooseFromAListOfNearbyConnectors':
				return _fallback.chooseFromAListOfNearbyConnectors;
			case 'accountCreated':
				return _fallback.accountCreated;
			case 'youCanNowStartYourFirstCharge':
				return _fallback.youCanNowStartYourFirstCharge;
			case 'youCanNowAddAPaymentMethod':
				return _fallback.youCanNowAddAPaymentMethod;
			case 'countryIsRequired':
				return _fallback.countryIsRequired;
			case 'streetIsRequired':
				return _fallback.streetIsRequired;
			case 'houseNumberIsRequired':
				return _fallback.houseNumberIsRequired;
			case 'postCodeIsRequired':
				return _fallback.postCodeIsRequired;
			case 'cityIsRequired':
				return _fallback.cityIsRequired;
			case 'firstNameRequired':
				return _fallback.firstNameRequired;
			case 'lastNameRequired':
				return _fallback.lastNameRequired;
			case 'emailRequired':
				return _fallback.emailRequired;
			case 'phoneNumberRequired':
				return _fallback.phoneNumberRequired;
			case 'pleaseEnterAValidEmailAddress':
				return _fallback.pleaseEnterAValidEmailAddress;
			case 'passwordMustContain':
				return _fallback.passwordMustContain;
			case 'acceptTermsAndConditions':
				return _fallback.acceptTermsAndConditions;
			case 'acceptPrivacyStatement':
				return _fallback.acceptPrivacyStatement;
			case 'country':
				return _fallback.country;
			case 'street':
				return _fallback.street;
			case 'houseNumberShort':
				return _fallback.houseNumberShort;
			case 'postCode':
				return _fallback.postCode;
			case 'cityTown':
				return _fallback.cityTown;
			case 'billingDetails':
				return _fallback.billingDetails;
			case 'billingAddress':
				return _fallback.billingAddress;
			case 'iAcceptThe':
				return _fallback.iAcceptThe;
			case 'termsOfService':
				return _fallback.termsOfService;
			case 'iUnderstandThat':
				return _fallback.iUnderstandThat;
			case 'privacyStatement':
				return _fallback.privacyStatement;
			case 'iWantToReceive':
				return _fallback.iWantToReceive;
			case 'firstName':
				return _fallback.firstName;
			case 'lastName':
				return _fallback.lastName;
			case 'phoneNumber':
				return _fallback.phoneNumber;
			case 'createAccount':
				return _fallback.createAccount;
			case 'createYourFreeAccount':
				return _fallback.createYourFreeAccount;
			case 'blockCard':
				return _fallback.blockCard;
			case 'unblockCard':
				return _fallback.unblockCard;
			case 'inactive':
				return _fallback.inactive;
			case 'identifier':
				return _fallback.identifier;
			case 'billingPlan':
				return _fallback.billingPlan;
			case 'nameOnCard':
				return _fallback.nameOnCard;
			case 'card':
				return _fallback.card;
			case 'unknownAddress':
				return _fallback.unknownAddress;
			case 'removeCard':
				return _fallback.removeCard;
			case 'areYouSureYouWantToRemoveCard':
				return _fallback.areYouSureYouWantToRemoveCard;
			case 'areYouSureYouWantToBlockCardFrom':
				return _fallback.areYouSureYouWantToBlockCardFrom;
			case 'thisActionCannotBeReversed':
				return _fallback.thisActionCannotBeReversed;
			case 'yesRemoveCard':
				return _fallback.yesRemoveCard;
			case 'yesBlockCard':
				return _fallback.yesBlockCard;
			case 'cancel':
				return _fallback.cancel;
			case 'editPaymentMethod':
				return _fallback.editPaymentMethod;
			case 'addPaymentMethod':
				return _fallback.addPaymentMethod;
			case 'creditOrDebitCard':
				return _fallback.creditOrDebitCard;
			case 'cardNumber':
				return _fallback.cardNumber;
			case 'saveCard':
				return _fallback.saveCard;
			case 'cardVerificationRequired':
				return _fallback.cardVerificationRequired;
			case 'clickButton3dSecure':
				return _fallback.clickButton3dSecure;
			case 'continueToAuthentication':
				return _fallback.continueToAuthentication;
			case 'tdsSecureHelpsPreventFraud':
				return _fallback.tdsSecureHelpsPreventFraud;
			case 'cardSaved':
				return _fallback.cardSaved;
			case 'cardRemoved':
				return _fallback.cardRemoved;
			case 'cardFailedToSave':
				return _fallback.cardFailedToSave;
			case 'hour':
				return _fallback.hour;
			case 'session':
				return _fallback.session;
			case 'hourIdleFee':
				return _fallback.hourIdleFee;
			case 'minWaitBeforeIdleFee':
				return _fallback.minWaitBeforeIdleFee;
			case 'name':
				return _fallback.name;
			case 'status':
				return _fallback.status;
			case 'operatorKey':
				return _fallback.operatorKey;
			case 'availableFacilities':
				return _fallback.availableFacilities;
			case 'carpoolParking':
				return _fallback.carpoolParking;
			case 'wifi':
				return _fallback.wifi;
			case 'noSessionDataAvailable':
				return _fallback.noSessionDataAvailable;
			case 'filterByMonth':
				return _fallback.filterByMonth;
			case 'viewAllSessions':
				return _fallback.viewAllSessions;
			case 'scheduledTariffNote':
				return _fallback.scheduledTariffNote;
			case 'dynamicTariffNote':
				return _fallback.dynamicTariffNote;
			case 'pricing':
				return _fallback.pricing;
			case 'baseTariff':
				return _fallback.baseTariff;
			case 'dynamicTariff':
				return _fallback.dynamicTariff;
			case 'activeNow':
				return _fallback.activeNow;
			case 'viewAllHourlyPrices':
				return _fallback.viewAllHourlyPrices;
			case 'hourlyPrices':
				return _fallback.hourlyPrices;
			case 'tariffNotes':
				return _fallback.tariffNotes;
			case 'viewTariffNotes':
				return _fallback.viewTariffNotes;
			case 'active':
				return _fallback.active;
			case 'noConnectorDataAvailable':
				return _fallback.noConnectorDataAvailable;
			case 'hotel':
				return _fallback.hotel;
			case 'restaurant':
				return _fallback.restaurant;
			case 'cafe':
				return _fallback.cafe;
			case 'mall':
				return _fallback.mall;
			case 'supermarket':
				return _fallback.supermarket;
			case 'sport':
				return _fallback.sport;
			case 'recreationArea':
				return _fallback.recreationArea;
			case 'nature':
				return _fallback.nature;
			case 'museum':
				return _fallback.museum;
			case 'bikeSharing':
				return _fallback.bikeSharing;
			case 'busStop':
				return _fallback.busStop;
			case 'taxiStand':
				return _fallback.taxiStand;
			case 'tramStop':
				return _fallback.tramStop;
			case 'metroStation':
				return _fallback.metroStation;
			case 'trainStation':
				return _fallback.trainStation;
			case 'airport':
				return _fallback.airport;
			case 'notAvailable':
				return _fallback.notAvailable;
			case 'available':
				return _fallback.available;
			case 'unavailable':
				return _fallback.unavailable;
			case 'alongMotorway':
				return _fallback.alongMotorway;
			case 'parkingGarage':
				return _fallback.parkingGarage;
			case 'parkingLot':
				return _fallback.parkingLot;
			case 'onDriveway':
				return _fallback.onDriveway;
			case 'onStreet':
				return _fallback.onStreet;
			case 'undergroundGarage':
				return _fallback.undergroundGarage;
			case 'fuelStation':
				return _fallback.fuelStation;
			case 'inaccurateTariffWarning':
				return _fallback.inaccurateTariffWarning(args['appName']);
			case 'somethingWentWrongPleaseTryAgainLater':
				return _fallback.somethingWentWrongPleaseTryAgainLater;
			case 'hAndMin':
				return _fallback.hAndMin(args['hours'], args['minutes']);
			case 'lessThanAMinute':
				return _fallback.lessThanAMinute;
			case 'nDays':
				return _fallback.nDays(args['count']);
			case 'nHours':
				return _fallback.nHours(args['count']);
			case 'nMinutes':
				return _fallback.nMinutes(args['count']);
			case 'noTariffAvailable':
				return _fallback.noTariffAvailable;
			case 'unknownKW':
				return _fallback.unknownKW;
			case 'cardDetailsUnavailable':
				return _fallback.cardDetailsUnavailable;
			case 'ok':
				return _fallback.ok;
			case 'somethingWentWrong':
				return _fallback.somethingWentWrong;
			case 'appUpdateRequiredError':
				return _fallback.appUpdateRequiredError;
			case 'mfaCodeExhausted':
				return _fallback.mfaCodeExhausted;
			case 'mfaSetupIntro':
				return _fallback.mfaSetupIntro;
			case 'mfaSetupAuthenticatorTitle':
				return _fallback.mfaSetupAuthenticatorTitle;
			case 'mfaSetupSmsTitle':
				return _fallback.mfaSetupSmsTitle;
			case 'mfaSetupNotSetUp':
				return _fallback.mfaSetupNotSetUp;
			case 'mfaSetupSetUp':
				return _fallback.mfaSetupSetUp;
			case 'mfaSetupEnabled':
				return _fallback.mfaSetupEnabled;
			case 'mfaSetupBack':
				return _fallback.mfaSetupBack;
			case 'securityScreenIntro':
				return _fallback.securityScreenIntro;
			case 'mfaActivatedOn':
				return _fallback.mfaActivatedOn(args['date']);
			case 'mfaNotAvailableByPolicy':
				return _fallback.mfaNotAvailableByPolicy;
			case 'mfaBackupCodesTitle':
				return _fallback.mfaBackupCodesTitle;
			case 'mfaRecoveryEmailTitle':
				return _fallback.mfaRecoveryEmailTitle;
			case 'mfaCodesLeft':
				return _fallback.mfaCodesLeft(args['count']);
			case 'mfaRemoveMethodConfirm':
				return _fallback.mfaRemoveMethodConfirm(args['method']);
			case 'mfaRemoveOnlyFactorWarning':
				return _fallback.mfaRemoveOnlyFactorWarning;
			case 'mfaGenerateCodes':
				return _fallback.mfaGenerateCodes;
			case 'mfaRegenerateCodes':
				return _fallback.mfaRegenerateCodes;
			case 'mfaRegenerateCodesWarning':
				return _fallback.mfaRegenerateCodesWarning;
			case 'mfaAddRecoveryEmail':
				return _fallback.mfaAddRecoveryEmail;
			case 'mfaRecoveryEmailExplanation':
				return _fallback.mfaRecoveryEmailExplanation;
			case 'mfaRecoveryEmailSameAsAccount':
				return _fallback.mfaRecoveryEmailSameAsAccount;
			case 'shareCodes':
				return _fallback.shareCodes;
			case 'copiedToClipboard':
				return _fallback.copiedToClipboard;
			case 'remove':
				return _fallback.remove;
			case 'change':
				return _fallback.change;
			case 'done':
				return _fallback.done;
			case 'sendCode':
				return _fallback.sendCode;
			case 'mfaTooManyAttemptsWait':
				return _fallback.mfaTooManyAttemptsWait(args['wait']);
			case 'mfaResendWaitCountdown':
				return _fallback.mfaResendWaitCountdown(args['wait']);
			case 'stepUpTitle':
				return _fallback.stepUpTitle;
			case 'stepUpPickMethodIntro':
				return _fallback.stepUpPickMethodIntro;
			case 'stepUpAuthenticatorPrompt':
				return _fallback.stepUpAuthenticatorPrompt;
			case 'stepUpPasskeyOnly':
				return _fallback.stepUpPasskeyOnly;
			case 'error':
				return _fallback.error;
			case 'sessionExpiredTitle':
				return _fallback.sessionExpiredTitle;
			case 'sessionExpiredMessage':
				return _fallback.sessionExpiredMessage;
			case 'signInExpiringMessage':
				return _fallback.signInExpiringMessage;
			case 'biometricPromptReason':
				return _fallback.biometricPromptReason;
			case 'youreAllReadyToBegin':
				return _fallback.youreAllReadyToBegin;
			case 'startYouFirstEVCharge':
				return _fallback.startYouFirstEVCharge;
			case 'locationServicesAreDisabled':
				return _fallback.locationServicesAreDisabled;
			case 'skip':
				return _fallback.skip;
			case 'openSettings':
				return _fallback.openSettings;
			case 'locationPermissionsHaveBeenDenied':
				return _fallback.locationPermissionsHaveBeenDenied;
			case 'continueStr':
				return _fallback.continueStr;
			case 'byAllowingLocationServices':
				return _fallback.byAllowingLocationServices;
			case 'findAllAvailableChargeStationsNearby':
				return _fallback.findAllAvailableChargeStationsNearby;
			case 'getStarted':
				return _fallback.getStarted;
			case 'letsGetYouStarted':
				return _fallback.letsGetYouStarted;
			case 'eVWallet':
				return _fallback.eVWallet;
			case 'signupForAnAccount':
				return _fallback.signupForAnAccount;
			case 'forgotPassword':
				return _fallback.forgotPassword;
			case 'password':
				return _fallback.password;
			case 'eMail':
				return _fallback.eMail;
			case 'priceUnknown':
				return _fallback.priceUnknown;
			case 'youHaventChargedYourEVYet':
				return _fallback.youHaventChargedYourEVYet;
			case 'cardRfid':
				return _fallback.cardRfid;
			case 'youDontHaveAnyPaymentMethodsYet':
				return _fallback.youDontHaveAnyPaymentMethodsYet;
			case 'sessions':
				return _fallback.sessions;
			case 'paymentMethods':
				return _fallback.paymentMethods;
			case 'paymentsAndSessions':
				return _fallback.paymentsAndSessions;
			case 'wallet':
				return _fallback.wallet;
			case 'locationServicesHaveBeenDisabledForThisApp':
				return _fallback.locationServicesHaveBeenDisabledForThisApp;
			case 'locationPermissionGranted':
				return _fallback.locationPermissionGranted;
			case 'locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings':
				return _fallback.locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings;
			case 'requestPermission':
				return _fallback.requestPermission;
			case 'grantLocationPermissionToUseThisFeature':
				return _fallback.grantLocationPermissionToUseThisFeature;
			case 'initialisingLocationService':
				return _fallback.initialisingLocationService;
			case 'findEVChargingLocations':
				return _fallback.findEVChargingLocations;
			case 'exploreStations':
				return _fallback.exploreStations;
			case 'viewWallet':
				return _fallback.viewWallet;
			case 'startAChargeSession':
				return _fallback.startAChargeSession;
			case 'charging':
				return _fallback.charging;
			case 'clickTheButtonBelow':
				return _fallback.clickTheButtonBelow;
			case 'startYourEVCharge':
				return _fallback.startYourEVCharge;
			case 'searchLocation':
				return _fallback.searchLocation;
			case 'getDirections':
				return _fallback.getDirections;
			case 'shareLocation':
				return _fallback.shareLocation;
			case 'streetView':
				return _fallback.streetView;
			case 'pressToView':
				return _fallback.pressToView;
			case 'streetViewNotAvailable':
				return _fallback.streetViewNotAvailable;
			case 'locationPictures':
				return _fallback.locationPictures;
			case 'locationPictureCounter':
				return _fallback.locationPictureCounter(args['index'], args['total']);
			case 'locationPictureCouldNotLoad':
				return _fallback.locationPictureCouldNotLoad;
			case 'chargeNow':
				return _fallback.chargeNow;
			case 'trySearchingForAnotherLocation':
				return _fallback.trySearchingForAnotherLocation;
			case 'noChargeStationsFound':
				return _fallback.noChargeStationsFound;
			case 'myCurrentPosition':
				return _fallback.myCurrentPosition;
			case 'useMyCurrentPosition':
				return _fallback.useMyCurrentPosition;
			case 'searchAddressOrPlaceName':
				return _fallback.searchAddressOrPlaceName;
			case 'clearFilters':
				return _fallback.clearFilters;
			case 'connectorType':
				return _fallback.connectorType;
			case 'chargingPowerkW':
				return _fallback.chargingPowerkW;
			case 'chargers':
				return _fallback.chargers;
			case 'dCChargers':
				return _fallback.dCChargers;
			case 'availableChargers':
				return _fallback.availableChargers;
			case 'onlyShow':
				return _fallback.onlyShow;
			case 'filters':
				return _fallback.filters;
			case 'findMoreStationsNearby':
				return _fallback.findMoreStationsNearby;
			case 'findStationsNearby':
				return _fallback.findStationsNearby;
			case 'highwayModeAvailableWhileDriving':
				return _fallback.highwayModeAvailableWhileDriving;
			case 'youCanAlwaysFindNearbyStations':
				return _fallback.youCanAlwaysFindNearbyStations;
			case 'nearbyStations':
				return _fallback.nearbyStations;
			case 'selectYourChargeStation':
				return _fallback.selectYourChargeStation;
			case 'paymentMethod':
				return _fallback.paymentMethod;
			case 'unnamedCard':
				return _fallback.unnamedCard;
			case 'noCardsAvailable':
				return _fallback.noCardsAvailable;
			case 'startSession':
				return _fallback.startSession;
			case 'unknownEVSEID':
				return _fallback.unknownEVSEID;
			case 'startChargingSession':
				return _fallback.startChargingSession;
			case 'exploreOrSearchForALocation':
				return _fallback.exploreOrSearchForALocation;
			case 'thereArentAnyStationsNearYou':
				return _fallback.thereArentAnyStationsNearYou;
			case 'noStationsFound':
				return _fallback.noStationsFound;
			case 'selectStation':
				return _fallback.selectStation;
			case 'evseId':
				return _fallback.evseId;
			case 'manualStationInput':
				return _fallback.manualStationInput;
			case 'manualEVSEIDInput':
				return _fallback.manualEVSEIDInput;
			case 'noSelectDifferentStation':
				return _fallback.noSelectDifferentStation;
			case 'yesThisIsMe':
				return _fallback.yesThisIsMe;
			case 'isThisYou':
				return _fallback.isThisYou;
			case 'imAllPluggedIn':
				return _fallback.imAllPluggedIn;
			case 'close':
				return _fallback.close;
			case 'endSession':
				return _fallback.endSession;
			case 'yourCarIsCharging':
				return _fallback.yourCarIsCharging;
			case 'unknownKWh':
				return _fallback.unknownKWh;
			case 'profile':
				return _fallback.profile;
			case 'account':
				return _fallback.account;
			case 'login':
				return _fallback.login;
			case 'dashboard':
				return _fallback.dashboard;
			case 'helpAndSupport':
				return _fallback.helpAndSupport;
			case 'cancelSubscription':
				return _fallback.cancelSubscription;
			case 'removeAccount':
				return _fallback.removeAccount;
			case 'logout':
				return _fallback.logout;
			case 'directPayments':
				return _fallback.directPayments;
			case 'chargingCardOrTag':
				return _fallback.chargingCardOrTag;
			case 'withoutAdditionalFeePerSession':
				return _fallback.withoutAdditionalFeePerSession;
			case 'supportsRemoteCharge':
				return _fallback.supportsRemoteCharge;
			case 'additionalFee':
				return _fallback.additionalFee;
			case 'favouriteStations':
				return _fallback.favouriteStations;
			case 'compassDirectionNorth':
				return _fallback.compassDirectionNorth;
			case 'compassDirectionNorthEast':
				return _fallback.compassDirectionNorthEast;
			case 'compassDirectionEast':
				return _fallback.compassDirectionEast;
			case 'compassDirectionSouthEast':
				return _fallback.compassDirectionSouthEast;
			case 'compassDirectionSouth':
				return _fallback.compassDirectionSouth;
			case 'compassDirectionSouthWest':
				return _fallback.compassDirectionSouthWest;
			case 'compassDirectionWest':
				return _fallback.compassDirectionWest;
			case 'compassDirectionNorthWest':
				return _fallback.compassDirectionNorthWest;
			case 'totalSessions':
				return _fallback.totalSessions;
			case 'totalEnergy':
				return _fallback.totalEnergy;
			case 'totalTime':
				return _fallback.totalTime;
			case 'totalCost':
				return _fallback.totalCost;
			case 'costTooltipText':
				return _fallback.costTooltipText;
			case 'selectOption':
				return _fallback.selectOption;
			case 'carScreenFastChargersAhead':
				return _fallback.carScreenFastChargersAhead;
			case 'carScreenHighway':
				return _fallback.carScreenHighway;
			case 'carScreenHighwayAuto':
				return _fallback.carScreenHighwayAuto;
			case 'carScreenHighwayOff':
				return _fallback.carScreenHighwayOff;
			case 'carScreenHighwayOn':
				return _fallback.carScreenHighwayOn;
			case 'carScreenNavigate':
				return _fallback.carScreenNavigate;
			case 'carScreenShowDetails':
				return _fallback.carScreenShowDetails;
			case 'carScreenFiltersCount':
				return _fallback.carScreenFiltersCount(args['count']);
			case 'carScreenFilterOn':
				return _fallback.carScreenFilterOn;
			case 'carScreenFilterOff':
				return _fallback.carScreenFilterOff;
			case 'carScreenSearchingStations':
				return _fallback.carScreenSearchingStations;
			case 'carScreenNoStationsFound':
				return _fallback.carScreenNoStationsFound;
			case 'carScreenNavigationNotAvailable':
				return _fallback.carScreenNavigationNotAvailable;
			case 'carScreenNavigationError':
				return _fallback.carScreenNavigationError;
			case 'carScreenNavigateOnPhone':
				return _fallback.carScreenNavigateOnPhone;
			case 'carScreenNoFiltersAvailable':
				return _fallback.carScreenNoFiltersAvailable;
			case 'carScreenAvailabilityCount':
				return _fallback.carScreenAvailabilityCount(args['available'], args['total']);
			case 'carScreenPricePerKwh':
				return _fallback.carScreenPricePerKwh(args['price']);
			case 'carScreenTabMap':
				return _fallback.carScreenTabMap;
			case 'carScreenTabFilters':
				return _fallback.carScreenTabFilters;
			case 'carScreenTabFavourites':
				return _fallback.carScreenTabFavourites;
			case 'carScreenNoFavourites':
				return _fallback.carScreenNoFavourites;
			case 'carScreenLoginToSaveFavourites':
				return _fallback.carScreenLoginToSaveFavourites;
			case 'carScreenSave':
				return _fallback.carScreenSave;
			case 'carScreenSaved':
				return _fallback.carScreenSaved;
			case 'carScreenChargingPower':
				return _fallback.carScreenChargingPower;
			case 'carScreenAll':
				return _fallback.carScreenAll;
			case 'carScreenPowerSlow':
				return _fallback.carScreenPowerSlow;
			case 'carScreenPowerFast':
				return _fallback.carScreenPowerFast;
			case 'carScreenPowerRapid':
				return _fallback.carScreenPowerRapid;
			case 'carScreenPowerUltra':
				return _fallback.carScreenPowerUltra;
			case 'carScreenCountSelected':
				return _fallback.carScreenCountSelected(args['count']);
			case 'selectNetworks':
				return _fallback.selectNetworks;
			case 'excludeNetworks':
				return _fallback.excludeNetworks;
			case 'selectNetworksToInclude':
				return _fallback.selectNetworksToInclude;
			case 'selectNetworksToExclude':
				return _fallback.selectNetworksToExclude;
			case 'searchNetworks':
				return _fallback.searchNetworks;
			case 'couldNotLoadNetworks':
				return _fallback.couldNotLoadNetworks;
			case 'noNetworksFound':
				return _fallback.noNetworksFound;
			case 'addANetwork':
				return _fallback.addANetwork;
			case 'reportProblemEntryStation':
				return _fallback.reportProblemEntryStation;
			case 'reportProblemEntrySession':
				return _fallback.reportProblemEntrySession;
			case 'reportProblemEntrySessionEnded':
				return _fallback.reportProblemEntrySessionEnded;
			case 'reportProblemEntryCta':
				return _fallback.reportProblemEntryCta;
			case 'reportProblemTitle':
				return _fallback.reportProblemTitle;
			case 'reportProblemFieldConnector':
				return _fallback.reportProblemFieldConnector;
			case 'reportProblemFieldCategory':
				return _fallback.reportProblemFieldCategory;
			case 'reportProblemFieldDescription':
				return _fallback.reportProblemFieldDescription;
			case 'reportProblemDescriptionPlaceholder':
				return _fallback.reportProblemDescriptionPlaceholder;
			case 'reportProblemSubmit':
				return _fallback.reportProblemSubmit;
			case 'reportProblemSuccess':
				return _fallback.reportProblemSuccess;
			case 'reportProblemCategoryChargerNotAvailable':
				return _fallback.reportProblemCategoryChargerNotAvailable;
			case 'reportProblemCategoryChargerDamaged':
				return _fallback.reportProblemCategoryChargerDamaged;
			case 'reportProblemCategoryChargerHardToFind':
				return _fallback.reportProblemCategoryChargerHardToFind;
			case 'reportProblemCategoryWrongConnectorSpeed':
				return _fallback.reportProblemCategoryWrongConnectorSpeed;
			case 'reportProblemCategoryWrongConnectorType':
				return _fallback.reportProblemCategoryWrongConnectorType;
			case 'reportProblemCategoryMissingPriceInformation':
				return _fallback.reportProblemCategoryMissingPriceInformation;
			case 'reportProblemCategoryMissingPowerInformation':
				return _fallback.reportProblemCategoryMissingPowerInformation;
			case 'reportProblemCategoryChargingSessionInterrupted':
				return _fallback.reportProblemCategoryChargingSessionInterrupted;
			case 'reportProblemCategoryChargingSessionNotStarted':
				return _fallback.reportProblemCategoryChargingSessionNotStarted;
			case 'reportProblemCategoryOther':
				return _fallback.reportProblemCategoryOther;
			case 'stepUpPasskeyPrompt':
				return _fallback.stepUpPasskeyPrompt;
			case 'stepUpPasskeyNoCredential':
				return _fallback.stepUpPasskeyNoCredential;
			case 'passkeyAuthentication':
				return _fallback.passkeyAuthentication;
			case 'passkeySignInWithDevice':
				return _fallback.passkeySignInWithDevice;
			case 'mfaPasskeyTitle':
				return _fallback.mfaPasskeyTitle;
			case 'mfaPasskeyExplanation':
				return _fallback.mfaPasskeyExplanation;
			case 'mfaPasskeyButton':
				return _fallback.mfaPasskeyButton;
			case 'mfaPasskeyNoCredential':
				return _fallback.mfaPasskeyNoCredential;
			case 'mfaEnrolPasskeyTitle':
				return _fallback.mfaEnrolPasskeyTitle;
			case 'mfaEnrolPasskeyExplanation':
				return _fallback.mfaEnrolPasskeyExplanation;
			case 'mfaEnrolPasskeyButton':
				return _fallback.mfaEnrolPasskeyButton;
			case 'mfaPasskeyAlreadyOnDevice':
				return _fallback.mfaPasskeyAlreadyOnDevice;
			case 'signInWithAPasskey':
				return _fallback.signInWithAPasskey;
			case 'passkeyLoginNoCredential':
				return _fallback.passkeyLoginNoCredential;
			case 'mfaPasskeysTitle':
				return _fallback.mfaPasskeysTitle;
			case 'mfaPasskeysCount':
				return _fallback.mfaPasskeysCount(args['count']);
			case 'mfaPasskeysIntro':
				return _fallback.mfaPasskeysIntro;
			case 'mfaPasskeysDisallowed':
				return _fallback.mfaPasskeysDisallowed;
			case 'mfaPasskeysUnsupportedDevice':
				return _fallback.mfaPasskeysUnsupportedDevice;
			case 'mfaAddPasskey':
				return _fallback.mfaAddPasskey;
			case 'mfaPasskeyAddedOn':
				return _fallback.mfaPasskeyAddedOn(args['date']);
			case 'mfaPasskeyLastUsedOn':
				return _fallback.mfaPasskeyLastUsedOn(args['date']);
			case 'mfaPasskeyRenameTitle':
				return _fallback.mfaPasskeyRenameTitle;
			case 'mfaPasskeyNameHelp':
				return _fallback.mfaPasskeyNameHelp;
			case 'mfaPasskeyNamePlaceholder':
				return _fallback.mfaPasskeyNamePlaceholder;
			case 'rename':
				return _fallback.rename;
			case 'save':
				return _fallback.save;
			case 'mfaPasskeyVerificationFailed':
				return _fallback.mfaPasskeyVerificationFailed;
			case 'mfaPasskeyChallengeMissing':
				return _fallback.mfaPasskeyChallengeMissing;
			case 'mfaPasskeyCreateFailed':
				return _fallback.mfaPasskeyCreateFailed;
			default:
				if (fallbackValue != null) return fallbackValue;
				return 'Translation missing for key "$key"';
		}
	}

	@override
	String get highwayMode => Phrase.getText(localeName, 'highwayMode') ?? _fallback.highwayMode;
	@override
	String get stopAtNearestFastChargingStation => Phrase.getText(localeName, 'stopAtNearestFastChargingStation') ?? _fallback.stopAtNearestFastChargingStation;
	@override
	String get emailAddressSuccessfullyVerified => Phrase.getText(localeName, 'emailAddressSuccessfullyVerified') ?? _fallback.emailAddressSuccessfullyVerified;
	@override
	String get phoneNumberSuccessfullyVerified => Phrase.getText(localeName, 'phoneNumberSuccessfullyVerified') ?? _fallback.phoneNumberSuccessfullyVerified;
	@override
	String get pleaseVerifyYourPhoneNumberAndEmail => Phrase.getText(localeName, 'pleaseVerifyYourPhoneNumberAndEmail') ?? _fallback.pleaseVerifyYourPhoneNumberAndEmail;
	@override
	String get verifyYourPhoneNumberNow => Phrase.getText(localeName, 'verifyYourPhoneNumberNow') ?? _fallback.verifyYourPhoneNumberNow;
	@override
	String get verifyYourEmailNow => Phrase.getText(localeName, 'verifyYourEmailNow') ?? _fallback.verifyYourEmailNow;
	@override
	String get verifyYourEmailAddress => Phrase.getText(localeName, 'verifyYourEmailAddress') ?? _fallback.verifyYourEmailAddress;
	@override
	String weSentYouAnEmailVerification(String emailAddress) => Phrase.getText(localeName, 'weSentYouAnEmailVerification', {'emailAddress':emailAddress}) ?? _fallback.weSentYouAnEmailVerification(emailAddress);
	@override
	String get openMailApp => Phrase.getText(localeName, 'openMailApp') ?? _fallback.openMailApp;
	@override
	String get pleaseConfirmYourEmailAddressByClicking => Phrase.getText(localeName, 'pleaseConfirmYourEmailAddressByClicking') ?? _fallback.pleaseConfirmYourEmailAddressByClicking;
	@override
	String get didntReceiveTheEmail => Phrase.getText(localeName, 'didntReceiveTheEmail') ?? _fallback.didntReceiveTheEmail;
	@override
	String get resendEmailVerificationLink => Phrase.getText(localeName, 'resendEmailVerificationLink') ?? _fallback.resendEmailVerificationLink;
	@override
	String get verified => Phrase.getText(localeName, 'verified') ?? _fallback.verified;
	@override
	String get stationAddedToYourFavourites => Phrase.getText(localeName, 'stationAddedToYourFavourites') ?? _fallback.stationAddedToYourFavourites;
	@override
	String get removedFromYourFavourites => Phrase.getText(localeName, 'removedFromYourFavourites') ?? _fallback.removedFromYourFavourites;
	@override
	String get yourFavouriteStationsWillShowUpHere => Phrase.getText(localeName, 'yourFavouriteStationsWillShowUpHere') ?? _fallback.yourFavouriteStationsWillShowUpHere;
	@override
	String get markStationsAsFavouriteByPressingTheHeartIcon => Phrase.getText(localeName, 'markStationsAsFavouriteByPressingTheHeartIcon') ?? _fallback.markStationsAsFavouriteByPressingTheHeartIcon;
	@override
	String get addToFavourites => Phrase.getText(localeName, 'addToFavourites') ?? _fallback.addToFavourites;
	@override
	String get removeFromFavourites => Phrase.getText(localeName, 'removeFromFavourites') ?? _fallback.removeFromFavourites;
	@override
	String get exploreMap => Phrase.getText(localeName, 'exploreMap') ?? _fallback.exploreMap;
	@override
	String get nearestStations => Phrase.getText(localeName, 'nearestStations') ?? _fallback.nearestStations;
	@override
	String get fastStationsWithPower => Phrase.getText(localeName, 'fastStationsWithPower') ?? _fallback.fastStationsWithPower;
	@override
	String onRoad(String road) => Phrase.getText(localeName, 'onRoad', {'road':road}) ?? _fallback.onRoad(road);
	@override
	String get noNearbyStations => Phrase.getText(localeName, 'noNearbyStations') ?? _fallback.noNearbyStations;
	@override
	String get noChargingStationsFoundNearby => Phrase.getText(localeName, 'noChargingStationsFoundNearby') ?? _fallback.noChargingStationsFoundNearby;
	@override
	String get accountRemovalIsPending => Phrase.getText(localeName, 'accountRemovalIsPending') ?? _fallback.accountRemovalIsPending;
	@override
	String get areYouSureYouWantToRemoveYourAccount => Phrase.getText(localeName, 'areYouSureYouWantToRemoveYourAccount') ?? _fallback.areYouSureYouWantToRemoveYourAccount;
	@override
	String get thisActionIsPermanent => Phrase.getText(localeName, 'thisActionIsPermanent') ?? _fallback.thisActionIsPermanent;
	@override
	String get yesRemoveAccount => Phrase.getText(localeName, 'yesRemoveAccount') ?? _fallback.yesRemoveAccount;
	@override
	String weSentYouAndSmsFullNumber(String phoneNumber) => Phrase.getText(localeName, 'weSentYouAndSmsFullNumber', {'phoneNumber':phoneNumber}) ?? _fallback.weSentYouAndSmsFullNumber(phoneNumber);
	@override
	String get saveRecoveryCodes => Phrase.getText(localeName, 'saveRecoveryCodes') ?? _fallback.saveRecoveryCodes;
	@override
	String get recoveryCodesCanBeUsed => Phrase.getText(localeName, 'recoveryCodesCanBeUsed') ?? _fallback.recoveryCodesCanBeUsed;
	@override
	String get downloadCodes => Phrase.getText(localeName, 'downloadCodes') ?? _fallback.downloadCodes;
	@override
	String get copyCodes => Phrase.getText(localeName, 'copyCodes') ?? _fallback.copyCodes;
	@override
	String get iSavedMyBackupCodes => Phrase.getText(localeName, 'iSavedMyBackupCodes') ?? _fallback.iSavedMyBackupCodes;
	@override
	String get putTheseInASafeSpot => Phrase.getText(localeName, 'putTheseInASafeSpot') ?? _fallback.putTheseInASafeSpot;
	@override
	String get or => Phrase.getText(localeName, 'or') ?? _fallback.or;
	@override
	String get oneDownloadAnAuthenticatorApp => Phrase.getText(localeName, 'oneDownloadAnAuthenticatorApp') ?? _fallback.oneDownloadAnAuthenticatorApp;
	@override
	String get weRecommendGoogleAuthenticator => Phrase.getText(localeName, 'weRecommendGoogleAuthenticator') ?? _fallback.weRecommendGoogleAuthenticator;
	@override
	String get googleAuthenticator => Phrase.getText(localeName, 'googleAuthenticator') ?? _fallback.googleAuthenticator;
	@override
	String get onePassword => Phrase.getText(localeName, 'onePassword') ?? _fallback.onePassword;
	@override
	String get authy => Phrase.getText(localeName, 'authy') ?? _fallback.authy;
	@override
	String get twoScanTheQrCode => Phrase.getText(localeName, 'twoScanTheQrCode') ?? _fallback.twoScanTheQrCode;
	@override
	String get threeEnterTheCode => Phrase.getText(localeName, 'threeEnterTheCode') ?? _fallback.threeEnterTheCode;
	@override
	String get appAuthentication => Phrase.getText(localeName, 'appAuthentication') ?? _fallback.appAuthentication;
	@override
	String get securityCodesGeneratedByApp => Phrase.getText(localeName, 'securityCodesGeneratedByApp') ?? _fallback.securityCodesGeneratedByApp;
	@override
	String get smsAuthentication => Phrase.getText(localeName, 'smsAuthentication') ?? _fallback.smsAuthentication;
	@override
	String get securityCodesSentViaSms => Phrase.getText(localeName, 'securityCodesSentViaSms') ?? _fallback.securityCodesSentViaSms;
	@override
	String get passwordAndAuthentication => Phrase.getText(localeName, 'passwordAndAuthentication') ?? _fallback.passwordAndAuthentication;
	@override
	String get dontHaveYourBackupCodes => Phrase.getText(localeName, 'dontHaveYourBackupCodes') ?? _fallback.dontHaveYourBackupCodes;
	@override
	String get contactSupportAt => Phrase.getText(localeName, 'contactSupportAt') ?? _fallback.contactSupportAt;
	@override
	String get toStartAManualVerificationProcess => Phrase.getText(localeName, 'toStartAManualVerificationProcess') ?? _fallback.toStartAManualVerificationProcess;
	@override
	String get pleaseEnterBackupCode => Phrase.getText(localeName, 'pleaseEnterBackupCode') ?? _fallback.pleaseEnterBackupCode;
	@override
	String get backupVerificationCode => Phrase.getText(localeName, 'backupVerificationCode') ?? _fallback.backupVerificationCode;
	@override
	String get codeEnteredIsIncorrect => Phrase.getText(localeName, 'codeEnteredIsIncorrect') ?? _fallback.codeEnteredIsIncorrect;
	@override
	String get isThisAuthMethodNotWorking => Phrase.getText(localeName, 'isThisAuthMethodNotWorking') ?? _fallback.isThisAuthMethodNotWorking;
	@override
	String get useYourBackupCodes => Phrase.getText(localeName, 'useYourBackupCodes') ?? _fallback.useYourBackupCodes;
	@override
	String get chooseVerificationMethod => Phrase.getText(localeName, 'chooseVerificationMethod') ?? _fallback.chooseVerificationMethod;
	@override
	String get howWouldYouLikeToVerify => Phrase.getText(localeName, 'howWouldYouLikeToVerify') ?? _fallback.howWouldYouLikeToVerify;
	@override
	String get useRecoveryCode => Phrase.getText(localeName, 'useRecoveryCode') ?? _fallback.useRecoveryCode;
	@override
	String get enterRecoveryCodeBelow => Phrase.getText(localeName, 'enterRecoveryCodeBelow') ?? _fallback.enterRecoveryCodeBelow;
	@override
	String get recoveryCode => Phrase.getText(localeName, 'recoveryCode') ?? _fallback.recoveryCode;
	@override
	String get useDifferentVerificationMethod => Phrase.getText(localeName, 'useDifferentVerificationMethod') ?? _fallback.useDifferentVerificationMethod;
	@override
	String weSentACodeToPhone(String phoneNumber) => Phrase.getText(localeName, 'weSentACodeToPhone', {'phoneNumber':phoneNumber}) ?? _fallback.weSentACodeToPhone(phoneNumber);
	@override
	String weSentACodeToEmail(String emailAddress) => Phrase.getText(localeName, 'weSentACodeToEmail', {'emailAddress':emailAddress}) ?? _fallback.weSentACodeToEmail(emailAddress);
	@override
	String get secureYourAccount => Phrase.getText(localeName, 'secureYourAccount') ?? _fallback.secureYourAccount;
	@override
	String get mfaEnrolExplanationEncourage => Phrase.getText(localeName, 'mfaEnrolExplanationEncourage') ?? _fallback.mfaEnrolExplanationEncourage;
	@override
	String get mfaEnrolExplanationEnforce => Phrase.getText(localeName, 'mfaEnrolExplanationEnforce') ?? _fallback.mfaEnrolExplanationEnforce;
	@override
	String get skipForNow => Phrase.getText(localeName, 'skipForNow') ?? _fallback.skipForNow;
	@override
	String get confirmYourEmailFirst => Phrase.getText(localeName, 'confirmYourEmailFirst') ?? _fallback.confirmYourEmailFirst;
	@override
	String get chooseEnrolmentMethod => Phrase.getText(localeName, 'chooseEnrolmentMethod') ?? _fallback.chooseEnrolmentMethod;
	@override
	String get cantScanTheCode => Phrase.getText(localeName, 'cantScanTheCode') ?? _fallback.cantScanTheCode;
	@override
	String get enterTheSecurityCodeGenerated => Phrase.getText(localeName, 'enterTheSecurityCodeGenerated') ?? _fallback.enterTheSecurityCodeGenerated;
	@override
	String get enterCode => Phrase.getText(localeName, 'enterCode') ?? _fallback.enterCode;
	@override
	String get weSentYouAnSms => Phrase.getText(localeName, 'weSentYouAnSms') ?? _fallback.weSentYouAnSms;
	@override
	String get enterThe6DigitCodeBelow => Phrase.getText(localeName, 'enterThe6DigitCodeBelow') ?? _fallback.enterThe6DigitCodeBelow;
	@override
	String get verify => Phrase.getText(localeName, 'verify') ?? _fallback.verify;
	@override
	String stepCounter(int current, int total) => Phrase.getText(localeName, 'stepCounter', {'current':current, 'total':total}) ?? _fallback.stepCounter(current, total);
	@override
	String get verifyPhoneStepTitle => Phrase.getText(localeName, 'verifyPhoneStepTitle') ?? _fallback.verifyPhoneStepTitle;
	@override
	String get verifyEmailStepTitle => Phrase.getText(localeName, 'verifyEmailStepTitle') ?? _fallback.verifyEmailStepTitle;
	@override
	String get didntReceiveTheCode => Phrase.getText(localeName, 'didntReceiveTheCode') ?? _fallback.didntReceiveTheCode;
	@override
	String get resendVerificationCode => Phrase.getText(localeName, 'resendVerificationCode') ?? _fallback.resendVerificationCode;
	@override
	String get codeResent => Phrase.getText(localeName, 'codeResent') ?? _fallback.codeResent;
	@override
	String get brandnameChargers => Phrase.getText(localeName, 'brandnameChargers') ?? _fallback.brandnameChargers;
	@override
	String get publicTariff => Phrase.getText(localeName, 'publicTariff') ?? _fallback.publicTariff;
	@override
	String get specialCardTariff => Phrase.getText(localeName, 'specialCardTariff') ?? _fallback.specialCardTariff;
	@override
	String get updateBillingInformation => Phrase.getText(localeName, 'updateBillingInformation') ?? _fallback.updateBillingInformation;
	@override
	String get billingAddressSuccessfullyUpdated => Phrase.getText(localeName, 'billingAddressSuccessfullyUpdated') ?? _fallback.billingAddressSuccessfullyUpdated;
	@override
	String get provideYourBillingDetails => Phrase.getText(localeName, 'provideYourBillingDetails') ?? _fallback.provideYourBillingDetails;
	@override
	String get profileSuccessfullyUpdated => Phrase.getText(localeName, 'profileSuccessfullyUpdated') ?? _fallback.profileSuccessfullyUpdated;
	@override
	String get updateProfile => Phrase.getText(localeName, 'updateProfile') ?? _fallback.updateProfile;
	@override
	String get manageYourPersonalContactInformation => Phrase.getText(localeName, 'manageYourPersonalContactInformation') ?? _fallback.manageYourPersonalContactInformation;
	@override
	String get passwordSuccessfullyUpdated => Phrase.getText(localeName, 'passwordSuccessfullyUpdated') ?? _fallback.passwordSuccessfullyUpdated;
	@override
	String get updatePassword => Phrase.getText(localeName, 'updatePassword') ?? _fallback.updatePassword;
	@override
	String get passwordIsRequired => Phrase.getText(localeName, 'passwordIsRequired') ?? _fallback.passwordIsRequired;
	@override
	String get updateYourPassword => Phrase.getText(localeName, 'updateYourPassword') ?? _fallback.updateYourPassword;
	@override
	String get currentPassword => Phrase.getText(localeName, 'currentPassword') ?? _fallback.currentPassword;
	@override
	String get newPassword => Phrase.getText(localeName, 'newPassword') ?? _fallback.newPassword;
	@override
	String get accountSettings => Phrase.getText(localeName, 'accountSettings') ?? _fallback.accountSettings;
	@override
	String get enableNotifications => Phrase.getText(localeName, 'enableNotifications') ?? _fallback.enableNotifications;
	@override
	String get pleaseAllowNotifications => Phrase.getText(localeName, 'pleaseAllowNotifications') ?? _fallback.pleaseAllowNotifications;
	@override
	String get sendNotifications => Phrase.getText(localeName, 'sendNotifications') ?? _fallback.sendNotifications;
	@override
	String get chargingUpdatesSubtitleIOS => Phrase.getText(localeName, 'chargingUpdatesSubtitleIOS') ?? _fallback.chargingUpdatesSubtitleIOS;
	@override
	String get chargingUpdatesSubtitleAndroid => Phrase.getText(localeName, 'chargingUpdatesSubtitleAndroid') ?? _fallback.chargingUpdatesSubtitleAndroid;
	@override
	String get personalSettings => Phrase.getText(localeName, 'personalSettings') ?? _fallback.personalSettings;
	@override
	String get notifications => Phrase.getText(localeName, 'notifications') ?? _fallback.notifications;
	@override
	String get manageYourNotifications => Phrase.getText(localeName, 'manageYourNotifications') ?? _fallback.manageYourNotifications;
	@override
	String get allNotifications => Phrase.getText(localeName, 'allNotifications') ?? _fallback.allNotifications;
	@override
	String get chargingStartedTitle => Phrase.getText(localeName, 'chargingStartedTitle') ?? _fallback.chargingStartedTitle;
	@override
	String get chargingSessionEndedTitle => Phrase.getText(localeName, 'chargingSessionEndedTitle') ?? _fallback.chargingSessionEndedTitle;
	@override
	String get chargingSessionStateOver80Title => Phrase.getText(localeName, 'chargingSessionStateOver80Title') ?? _fallback.chargingSessionStateOver80Title;
	@override
	String get chargingSessionChargingTitle => Phrase.getText(localeName, 'chargingSessionChargingTitle') ?? _fallback.chargingSessionChargingTitle;
	@override
	String get chargingSessionSuspendedEvTitle => Phrase.getText(localeName, 'chargingSessionSuspendedEvTitle') ?? _fallback.chargingSessionSuspendedEvTitle;
	@override
	String get chargingSessionSuspendedEvseTitle => Phrase.getText(localeName, 'chargingSessionSuspendedEvseTitle') ?? _fallback.chargingSessionSuspendedEvseTitle;
	@override
	String get chargingSessionStartedSubtitle => Phrase.getText(localeName, 'chargingSessionStartedSubtitle') ?? _fallback.chargingSessionStartedSubtitle;
	@override
	String get chargingSessionEndedSubtitle => Phrase.getText(localeName, 'chargingSessionEndedSubtitle') ?? _fallback.chargingSessionEndedSubtitle;
	@override
	String get chargingSessionStateOver80Subtitle => Phrase.getText(localeName, 'chargingSessionStateOver80Subtitle') ?? _fallback.chargingSessionStateOver80Subtitle;
	@override
	String get chargingSessionChargingSubtitle => Phrase.getText(localeName, 'chargingSessionChargingSubtitle') ?? _fallback.chargingSessionChargingSubtitle;
	@override
	String get chargingSessionSuspendedEvSubtitle => Phrase.getText(localeName, 'chargingSessionSuspendedEvSubtitle') ?? _fallback.chargingSessionSuspendedEvSubtitle;
	@override
	String get chargingSessionSuspendedEvseSubtitle => Phrase.getText(localeName, 'chargingSessionSuspendedEvseSubtitle') ?? _fallback.chargingSessionSuspendedEvseSubtitle;
	@override
	String get chargingSessionLiveUpdateTitle => Phrase.getText(localeName, 'chargingSessionLiveUpdateTitle') ?? _fallback.chargingSessionLiveUpdateTitle;
	@override
	String get chargingSessionLiveUpdateSubtitleIOS => Phrase.getText(localeName, 'chargingSessionLiveUpdateSubtitleIOS') ?? _fallback.chargingSessionLiveUpdateSubtitleIOS;
	@override
	String get chargingSessionLiveUpdateSubtitleAndroid => Phrase.getText(localeName, 'chargingSessionLiveUpdateSubtitleAndroid') ?? _fallback.chargingSessionLiveUpdateSubtitleAndroid;
	@override
	String get wantToAddYourCreditOrDebitCardLater => Phrase.getText(localeName, 'wantToAddYourCreditOrDebitCardLater') ?? _fallback.wantToAddYourCreditOrDebitCardLater;
	@override
	String get viewYourChargeCards => Phrase.getText(localeName, 'viewYourChargeCards') ?? _fallback.viewYourChargeCards;
	@override
	String get viewYourPreviousChargingSessions => Phrase.getText(localeName, 'viewYourPreviousChargingSessions') ?? _fallback.viewYourPreviousChargingSessions;
	@override
	String get viewInvoicesForYourChargeCards => Phrase.getText(localeName, 'viewInvoicesForYourChargeCards') ?? _fallback.viewInvoicesForYourChargeCards;
	@override
	String get viewYourProfileAndAccount => Phrase.getText(localeName, 'viewYourProfileAndAccount') ?? _fallback.viewYourProfileAndAccount;
	@override
	String get payWith => Phrase.getText(localeName, 'payWith') ?? _fallback.payWith;
	@override
	String get postCodeIsInvalid => Phrase.getText(localeName, 'postCodeIsInvalid') ?? _fallback.postCodeIsInvalid;
	@override
	String get later => Phrase.getText(localeName, 'later') ?? _fallback.later;
	@override
	String get enableLocationServices => Phrase.getText(localeName, 'enableLocationServices') ?? _fallback.enableLocationServices;
	@override
	String get pleaseAllowLocationUpdates => Phrase.getText(localeName, 'pleaseAllowLocationUpdates') ?? _fallback.pleaseAllowLocationUpdates;
	@override
	String get contactUs => Phrase.getText(localeName, 'contactUs') ?? _fallback.contactUs;
	@override
	String get accountCreatedWelcomeOnBoard => Phrase.getText(localeName, 'accountCreatedWelcomeOnBoard') ?? _fallback.accountCreatedWelcomeOnBoard;
	@override
	String get search => Phrase.getText(localeName, 'search') ?? _fallback.search;
	@override
	String get lookingForAppleOrGooglePay => Phrase.getText(localeName, 'lookingForAppleOrGooglePay') ?? _fallback.lookingForAppleOrGooglePay;
	@override
	String get skipThisStep => Phrase.getText(localeName, 'skipThisStep') ?? _fallback.skipThisStep;
	@override
	String get invalidPhoneNumber => Phrase.getText(localeName, 'invalidPhoneNumber') ?? _fallback.invalidPhoneNumber;
	@override
	String get appVersion => Phrase.getText(localeName, 'appVersion') ?? _fallback.appVersion;
	@override
	String get privacyStatementOneLine => Phrase.getText(localeName, 'privacyStatementOneLine') ?? _fallback.privacyStatementOneLine;
	@override
	String get termsOfServiceOneLine => Phrase.getText(localeName, 'termsOfServiceOneLine') ?? _fallback.termsOfServiceOneLine;
	@override
	String get aboutUs => Phrase.getText(localeName, 'aboutUs') ?? _fallback.aboutUs;
	@override
	String get about => Phrase.getText(localeName, 'about') ?? _fallback.about;
	@override
	String get support => Phrase.getText(localeName, 'support') ?? _fallback.support;
	@override
	String get addCreditOrDebitCard => Phrase.getText(localeName, 'addCreditOrDebitCard') ?? _fallback.addCreditOrDebitCard;
	@override
	String get byAddingAPaymentMethod => Phrase.getText(localeName, 'byAddingAPaymentMethod') ?? _fallback.byAddingAPaymentMethod;
	@override
	String get youWillAddYourPaymentDetails => Phrase.getText(localeName, 'youWillAddYourPaymentDetails') ?? _fallback.youWillAddYourPaymentDetails;
	@override
	String get supportedMethods => Phrase.getText(localeName, 'supportedMethods') ?? _fallback.supportedMethods;
	@override
	String get payments => Phrase.getText(localeName, 'payments') ?? _fallback.payments;
	@override
	String get invoices => Phrase.getText(localeName, 'invoices') ?? _fallback.invoices;
	@override
	String get signupNowToSeeYourChargeCards => Phrase.getText(localeName, 'signupNowToSeeYourChargeCards') ?? _fallback.signupNowToSeeYourChargeCards;
	@override
	String get signupNowToViewChargingSessions => Phrase.getText(localeName, 'signupNowToViewChargingSessions') ?? _fallback.signupNowToViewChargingSessions;
	@override
	String get signupNowToViewInvoices => Phrase.getText(localeName, 'signupNowToViewInvoices') ?? _fallback.signupNowToViewInvoices;
	@override
	String get alreadyHaveAnAccount => Phrase.getText(localeName, 'alreadyHaveAnAccount') ?? _fallback.alreadyHaveAnAccount;
	@override
	String get applePay => Phrase.getText(localeName, 'applePay') ?? _fallback.applePay;
	@override
	String get googlePay => Phrase.getText(localeName, 'googlePay') ?? _fallback.googlePay;
	@override
	String get downloadInvoice => Phrase.getText(localeName, 'downloadInvoice') ?? _fallback.downloadInvoice;
	@override
	String get invoiceDetails => Phrase.getText(localeName, 'invoiceDetails') ?? _fallback.invoiceDetails;
	@override
	String get noInvoiceDataAvailable => Phrase.getText(localeName, 'noInvoiceDataAvailable') ?? _fallback.noInvoiceDataAvailable;
	@override
	String get filterByYear => Phrase.getText(localeName, 'filterByYear') ?? _fallback.filterByYear;
	@override
	String get chargeCardInvoices => Phrase.getText(localeName, 'chargeCardInvoices') ?? _fallback.chargeCardInvoices;
	@override
	String get viewAllInvoices => Phrase.getText(localeName, 'viewAllInvoices') ?? _fallback.viewAllInvoices;
	@override
	String get chooseRoutingApp => Phrase.getText(localeName, 'chooseRoutingApp') ?? _fallback.chooseRoutingApp;
	@override
	String get manuallyInputStationId => Phrase.getText(localeName, 'manuallyInputStationId') ?? _fallback.manuallyInputStationId;
	@override
	String get inputTheStationIdFromTheSticker => Phrase.getText(localeName, 'inputTheStationIdFromTheSticker') ?? _fallback.inputTheStationIdFromTheSticker;
	@override
	String get findTheStickerEnterTheDigits => Phrase.getText(localeName, 'findTheStickerEnterTheDigits') ?? _fallback.findTheStickerEnterTheDigits;
	@override
	String get scanStationQrCode => Phrase.getText(localeName, 'scanStationQrCode') ?? _fallback.scanStationQrCode;
	@override
	String get useCameraToIdentifyStationId => Phrase.getText(localeName, 'useCameraToIdentifyStationId') ?? _fallback.useCameraToIdentifyStationId;
	@override
	String get qrScannerTorchToggle => Phrase.getText(localeName, 'qrScannerTorchToggle') ?? _fallback.qrScannerTorchToggle;
	@override
	String get cameraPermissionRequired => Phrase.getText(localeName, 'cameraPermissionRequired') ?? _fallback.cameraPermissionRequired;
	@override
	String get cameraPermissionMessage => Phrase.getText(localeName, 'cameraPermissionMessage') ?? _fallback.cameraPermissionMessage;
	@override
	String get cameraPermissionDenied => Phrase.getText(localeName, 'cameraPermissionDenied') ?? _fallback.cameraPermissionDenied;
	@override
	String get errorAccessingCamera => Phrase.getText(localeName, 'errorAccessingCamera') ?? _fallback.errorAccessingCamera;
	@override
	String get stationId => Phrase.getText(localeName, 'stationId') ?? _fallback.stationId;
	@override
	String get example => Phrase.getText(localeName, 'example') ?? _fallback.example;
	@override
	String get input => Phrase.getText(localeName, 'input') ?? _fallback.input;
	@override
	String get dontHaveAnAccount => Phrase.getText(localeName, 'dontHaveAnAccount') ?? _fallback.dontHaveAnAccount;
	@override
	String get signup => Phrase.getText(localeName, 'signup') ?? _fallback.signup;
	@override
	String get youHaventAddedAnyCardsYet => Phrase.getText(localeName, 'youHaventAddedAnyCardsYet') ?? _fallback.youHaventAddedAnyCardsYet;
	@override
	String get selectPaymentMethod => Phrase.getText(localeName, 'selectPaymentMethod') ?? _fallback.selectPaymentMethod;
	@override
	String get chargingInProgress => Phrase.getText(localeName, 'chargingInProgress') ?? _fallback.chargingInProgress;
	@override
	String get cancelSession => Phrase.getText(localeName, 'cancelSession') ?? _fallback.cancelSession;
	@override
	String get unableToConnectToServer => Phrase.getText(localeName, 'unableToConnectToServer') ?? _fallback.unableToConnectToServer;
	@override
	String get chargeCard => Phrase.getText(localeName, 'chargeCard') ?? _fallback.chargeCard;
	@override
	String get youAreReadyToGo => Phrase.getText(localeName, 'youAreReadyToGo') ?? _fallback.youAreReadyToGo;
	@override
	String get noteWeAreStillProcessing => Phrase.getText(localeName, 'noteWeAreStillProcessing') ?? _fallback.noteWeAreStillProcessing;
	@override
	String get sessionCompleted => Phrase.getText(localeName, 'sessionCompleted') ?? _fallback.sessionCompleted;
	@override
	String get sessionDetails => Phrase.getText(localeName, 'sessionDetails') ?? _fallback.sessionDetails;
	@override
	String get price => Phrase.getText(localeName, 'price') ?? _fallback.price;
	@override
	String get inclVat => Phrase.getText(localeName, 'inclVat') ?? _fallback.inclVat;
	@override
	String get exclVat => Phrase.getText(localeName, 'exclVat') ?? _fallback.exclVat;
	@override
	String get usage => Phrase.getText(localeName, 'usage') ?? _fallback.usage;
	@override
	String get duration => Phrase.getText(localeName, 'duration') ?? _fallback.duration;
	@override
	String get startTime => Phrase.getText(localeName, 'startTime') ?? _fallback.startTime;
	@override
	String get endTime => Phrase.getText(localeName, 'endTime') ?? _fallback.endTime;
	@override
	String get charged => Phrase.getText(localeName, 'charged') ?? _fallback.charged;
	@override
	String get date => Phrase.getText(localeName, 'date') ?? _fallback.date;
	@override
	String get totalCosts => Phrase.getText(localeName, 'totalCosts') ?? _fallback.totalCosts;
	@override
	String get payment => Phrase.getText(localeName, 'payment') ?? _fallback.payment;
	@override
	String get thereArentAnyStationsNearYourLocations => Phrase.getText(localeName, 'thereArentAnyStationsNearYourLocations') ?? _fallback.thereArentAnyStationsNearYourLocations;
	@override
	String get sessionStarting => Phrase.getText(localeName, 'sessionStarting') ?? _fallback.sessionStarting;
	@override
	String get sessionStopping => Phrase.getText(localeName, 'sessionStopping') ?? _fallback.sessionStopping;
	@override
	String get sessionEnded => Phrase.getText(localeName, 'sessionEnded') ?? _fallback.sessionEnded;
	@override
	String get stationDoesntSupportSessions => Phrase.getText(localeName, 'stationDoesntSupportSessions') ?? _fallback.stationDoesntSupportSessions;
	@override
	String get stationOnlySupportsRfidCards => Phrase.getText(localeName, 'stationOnlySupportsRfidCards') ?? _fallback.stationOnlySupportsRfidCards;
	@override
	String get stationOnlySupportsCreditCards => Phrase.getText(localeName, 'stationOnlySupportsCreditCards') ?? _fallback.stationOnlySupportsCreditCards;
	@override
	String get weLoggedYouInAutomatically => Phrase.getText(localeName, 'weLoggedYouInAutomatically') ?? _fallback.weLoggedYouInAutomatically;
	@override
	String get cannotAddAPaymentMethod => Phrase.getText(localeName, 'cannotAddAPaymentMethod') ?? _fallback.cannotAddAPaymentMethod;
	@override
	String get imAllPluggedInToTheEvStation => Phrase.getText(localeName, 'imAllPluggedInToTheEvStation') ?? _fallback.imAllPluggedInToTheEvStation;
	@override
	String get automaticallyDetectMyConnection => Phrase.getText(localeName, 'automaticallyDetectMyConnection') ?? _fallback.automaticallyDetectMyConnection;
	@override
	String get findNearbyEvStations => Phrase.getText(localeName, 'findNearbyEvStations') ?? _fallback.findNearbyEvStations;
	@override
	String get chooseFromAListOfNearbyConnectors => Phrase.getText(localeName, 'chooseFromAListOfNearbyConnectors') ?? _fallback.chooseFromAListOfNearbyConnectors;
	@override
	String get accountCreated => Phrase.getText(localeName, 'accountCreated') ?? _fallback.accountCreated;
	@override
	String get youCanNowStartYourFirstCharge => Phrase.getText(localeName, 'youCanNowStartYourFirstCharge') ?? _fallback.youCanNowStartYourFirstCharge;
	@override
	String get youCanNowAddAPaymentMethod => Phrase.getText(localeName, 'youCanNowAddAPaymentMethod') ?? _fallback.youCanNowAddAPaymentMethod;
	@override
	String get countryIsRequired => Phrase.getText(localeName, 'countryIsRequired') ?? _fallback.countryIsRequired;
	@override
	String get streetIsRequired => Phrase.getText(localeName, 'streetIsRequired') ?? _fallback.streetIsRequired;
	@override
	String get houseNumberIsRequired => Phrase.getText(localeName, 'houseNumberIsRequired') ?? _fallback.houseNumberIsRequired;
	@override
	String get postCodeIsRequired => Phrase.getText(localeName, 'postCodeIsRequired') ?? _fallback.postCodeIsRequired;
	@override
	String get cityIsRequired => Phrase.getText(localeName, 'cityIsRequired') ?? _fallback.cityIsRequired;
	@override
	String get firstNameRequired => Phrase.getText(localeName, 'firstNameRequired') ?? _fallback.firstNameRequired;
	@override
	String get lastNameRequired => Phrase.getText(localeName, 'lastNameRequired') ?? _fallback.lastNameRequired;
	@override
	String get emailRequired => Phrase.getText(localeName, 'emailRequired') ?? _fallback.emailRequired;
	@override
	String get phoneNumberRequired => Phrase.getText(localeName, 'phoneNumberRequired') ?? _fallback.phoneNumberRequired;
	@override
	String get pleaseEnterAValidEmailAddress => Phrase.getText(localeName, 'pleaseEnterAValidEmailAddress') ?? _fallback.pleaseEnterAValidEmailAddress;
	@override
	String get passwordMustContain => Phrase.getText(localeName, 'passwordMustContain') ?? _fallback.passwordMustContain;
	@override
	String get acceptTermsAndConditions => Phrase.getText(localeName, 'acceptTermsAndConditions') ?? _fallback.acceptTermsAndConditions;
	@override
	String get acceptPrivacyStatement => Phrase.getText(localeName, 'acceptPrivacyStatement') ?? _fallback.acceptPrivacyStatement;
	@override
	String get country => Phrase.getText(localeName, 'country') ?? _fallback.country;
	@override
	String get street => Phrase.getText(localeName, 'street') ?? _fallback.street;
	@override
	String get houseNumberShort => Phrase.getText(localeName, 'houseNumberShort') ?? _fallback.houseNumberShort;
	@override
	String get postCode => Phrase.getText(localeName, 'postCode') ?? _fallback.postCode;
	@override
	String get cityTown => Phrase.getText(localeName, 'cityTown') ?? _fallback.cityTown;
	@override
	String get billingDetails => Phrase.getText(localeName, 'billingDetails') ?? _fallback.billingDetails;
	@override
	String get billingAddress => Phrase.getText(localeName, 'billingAddress') ?? _fallback.billingAddress;
	@override
	String get iAcceptThe => Phrase.getText(localeName, 'iAcceptThe') ?? _fallback.iAcceptThe;
	@override
	String get termsOfService => Phrase.getText(localeName, 'termsOfService') ?? _fallback.termsOfService;
	@override
	String get iUnderstandThat => Phrase.getText(localeName, 'iUnderstandThat') ?? _fallback.iUnderstandThat;
	@override
	String get privacyStatement => Phrase.getText(localeName, 'privacyStatement') ?? _fallback.privacyStatement;
	@override
	String get iWantToReceive => Phrase.getText(localeName, 'iWantToReceive') ?? _fallback.iWantToReceive;
	@override
	String get firstName => Phrase.getText(localeName, 'firstName') ?? _fallback.firstName;
	@override
	String get lastName => Phrase.getText(localeName, 'lastName') ?? _fallback.lastName;
	@override
	String get phoneNumber => Phrase.getText(localeName, 'phoneNumber') ?? _fallback.phoneNumber;
	@override
	String get createAccount => Phrase.getText(localeName, 'createAccount') ?? _fallback.createAccount;
	@override
	String get createYourFreeAccount => Phrase.getText(localeName, 'createYourFreeAccount') ?? _fallback.createYourFreeAccount;
	@override
	String get blockCard => Phrase.getText(localeName, 'blockCard') ?? _fallback.blockCard;
	@override
	String get unblockCard => Phrase.getText(localeName, 'unblockCard') ?? _fallback.unblockCard;
	@override
	String get inactive => Phrase.getText(localeName, 'inactive') ?? _fallback.inactive;
	@override
	String get identifier => Phrase.getText(localeName, 'identifier') ?? _fallback.identifier;
	@override
	String get billingPlan => Phrase.getText(localeName, 'billingPlan') ?? _fallback.billingPlan;
	@override
	String get nameOnCard => Phrase.getText(localeName, 'nameOnCard') ?? _fallback.nameOnCard;
	@override
	String get card => Phrase.getText(localeName, 'card') ?? _fallback.card;
	@override
	String get unknownAddress => Phrase.getText(localeName, 'unknownAddress') ?? _fallback.unknownAddress;
	@override
	String get removeCard => Phrase.getText(localeName, 'removeCard') ?? _fallback.removeCard;
	@override
	String get areYouSureYouWantToRemoveCard => Phrase.getText(localeName, 'areYouSureYouWantToRemoveCard') ?? _fallback.areYouSureYouWantToRemoveCard;
	@override
	String get areYouSureYouWantToBlockCardFrom => Phrase.getText(localeName, 'areYouSureYouWantToBlockCardFrom') ?? _fallback.areYouSureYouWantToBlockCardFrom;
	@override
	String get thisActionCannotBeReversed => Phrase.getText(localeName, 'thisActionCannotBeReversed') ?? _fallback.thisActionCannotBeReversed;
	@override
	String get yesRemoveCard => Phrase.getText(localeName, 'yesRemoveCard') ?? _fallback.yesRemoveCard;
	@override
	String get yesBlockCard => Phrase.getText(localeName, 'yesBlockCard') ?? _fallback.yesBlockCard;
	@override
	String get cancel => Phrase.getText(localeName, 'cancel') ?? _fallback.cancel;
	@override
	String get editPaymentMethod => Phrase.getText(localeName, 'editPaymentMethod') ?? _fallback.editPaymentMethod;
	@override
	String get addPaymentMethod => Phrase.getText(localeName, 'addPaymentMethod') ?? _fallback.addPaymentMethod;
	@override
	String get creditOrDebitCard => Phrase.getText(localeName, 'creditOrDebitCard') ?? _fallback.creditOrDebitCard;
	@override
	String get cardNumber => Phrase.getText(localeName, 'cardNumber') ?? _fallback.cardNumber;
	@override
	String get saveCard => Phrase.getText(localeName, 'saveCard') ?? _fallback.saveCard;
	@override
	String get cardVerificationRequired => Phrase.getText(localeName, 'cardVerificationRequired') ?? _fallback.cardVerificationRequired;
	@override
	String get clickButton3dSecure => Phrase.getText(localeName, 'clickButton3dSecure') ?? _fallback.clickButton3dSecure;
	@override
	String get continueToAuthentication => Phrase.getText(localeName, 'continueToAuthentication') ?? _fallback.continueToAuthentication;
	@override
	String get tdsSecureHelpsPreventFraud => Phrase.getText(localeName, 'tdsSecureHelpsPreventFraud') ?? _fallback.tdsSecureHelpsPreventFraud;
	@override
	String get cardSaved => Phrase.getText(localeName, 'cardSaved') ?? _fallback.cardSaved;
	@override
	String get cardRemoved => Phrase.getText(localeName, 'cardRemoved') ?? _fallback.cardRemoved;
	@override
	String get cardFailedToSave => Phrase.getText(localeName, 'cardFailedToSave') ?? _fallback.cardFailedToSave;
	@override
	String get hour => Phrase.getText(localeName, 'hour') ?? _fallback.hour;
	@override
	String get session => Phrase.getText(localeName, 'session') ?? _fallback.session;
	@override
	String get hourIdleFee => Phrase.getText(localeName, 'hourIdleFee') ?? _fallback.hourIdleFee;
	@override
	String get minWaitBeforeIdleFee => Phrase.getText(localeName, 'minWaitBeforeIdleFee') ?? _fallback.minWaitBeforeIdleFee;
	@override
	String get name => Phrase.getText(localeName, 'name') ?? _fallback.name;
	@override
	String get status => Phrase.getText(localeName, 'status') ?? _fallback.status;
	@override
	String get operatorKey => Phrase.getText(localeName, 'operatorKey') ?? _fallback.operatorKey;
	@override
	String get availableFacilities => Phrase.getText(localeName, 'availableFacilities') ?? _fallback.availableFacilities;
	@override
	String get carpoolParking => Phrase.getText(localeName, 'carpoolParking') ?? _fallback.carpoolParking;
	@override
	String get wifi => Phrase.getText(localeName, 'wifi') ?? _fallback.wifi;
	@override
	String get noSessionDataAvailable => Phrase.getText(localeName, 'noSessionDataAvailable') ?? _fallback.noSessionDataAvailable;
	@override
	String get filterByMonth => Phrase.getText(localeName, 'filterByMonth') ?? _fallback.filterByMonth;
	@override
	String get viewAllSessions => Phrase.getText(localeName, 'viewAllSessions') ?? _fallback.viewAllSessions;
	@override
	String get scheduledTariffNote => Phrase.getText(localeName, 'scheduledTariffNote') ?? _fallback.scheduledTariffNote;
	@override
	String get dynamicTariffNote => Phrase.getText(localeName, 'dynamicTariffNote') ?? _fallback.dynamicTariffNote;
	@override
	String get pricing => Phrase.getText(localeName, 'pricing') ?? _fallback.pricing;
	@override
	String get baseTariff => Phrase.getText(localeName, 'baseTariff') ?? _fallback.baseTariff;
	@override
	String get dynamicTariff => Phrase.getText(localeName, 'dynamicTariff') ?? _fallback.dynamicTariff;
	@override
	String get activeNow => Phrase.getText(localeName, 'activeNow') ?? _fallback.activeNow;
	@override
	String get viewAllHourlyPrices => Phrase.getText(localeName, 'viewAllHourlyPrices') ?? _fallback.viewAllHourlyPrices;
	@override
	String get hourlyPrices => Phrase.getText(localeName, 'hourlyPrices') ?? _fallback.hourlyPrices;
	@override
	String get tariffNotes => Phrase.getText(localeName, 'tariffNotes') ?? _fallback.tariffNotes;
	@override
	String get viewTariffNotes => Phrase.getText(localeName, 'viewTariffNotes') ?? _fallback.viewTariffNotes;
	@override
	String get active => Phrase.getText(localeName, 'active') ?? _fallback.active;
	@override
	String get noConnectorDataAvailable => Phrase.getText(localeName, 'noConnectorDataAvailable') ?? _fallback.noConnectorDataAvailable;
	@override
	String get hotel => Phrase.getText(localeName, 'hotel') ?? _fallback.hotel;
	@override
	String get restaurant => Phrase.getText(localeName, 'restaurant') ?? _fallback.restaurant;
	@override
	String get cafe => Phrase.getText(localeName, 'cafe') ?? _fallback.cafe;
	@override
	String get mall => Phrase.getText(localeName, 'mall') ?? _fallback.mall;
	@override
	String get supermarket => Phrase.getText(localeName, 'supermarket') ?? _fallback.supermarket;
	@override
	String get sport => Phrase.getText(localeName, 'sport') ?? _fallback.sport;
	@override
	String get recreationArea => Phrase.getText(localeName, 'recreationArea') ?? _fallback.recreationArea;
	@override
	String get nature => Phrase.getText(localeName, 'nature') ?? _fallback.nature;
	@override
	String get museum => Phrase.getText(localeName, 'museum') ?? _fallback.museum;
	@override
	String get bikeSharing => Phrase.getText(localeName, 'bikeSharing') ?? _fallback.bikeSharing;
	@override
	String get busStop => Phrase.getText(localeName, 'busStop') ?? _fallback.busStop;
	@override
	String get taxiStand => Phrase.getText(localeName, 'taxiStand') ?? _fallback.taxiStand;
	@override
	String get tramStop => Phrase.getText(localeName, 'tramStop') ?? _fallback.tramStop;
	@override
	String get metroStation => Phrase.getText(localeName, 'metroStation') ?? _fallback.metroStation;
	@override
	String get trainStation => Phrase.getText(localeName, 'trainStation') ?? _fallback.trainStation;
	@override
	String get airport => Phrase.getText(localeName, 'airport') ?? _fallback.airport;
	@override
	String get notAvailable => Phrase.getText(localeName, 'notAvailable') ?? _fallback.notAvailable;
	@override
	String get available => Phrase.getText(localeName, 'available') ?? _fallback.available;
	@override
	String get unavailable => Phrase.getText(localeName, 'unavailable') ?? _fallback.unavailable;
	@override
	String get alongMotorway => Phrase.getText(localeName, 'alongMotorway') ?? _fallback.alongMotorway;
	@override
	String get parkingGarage => Phrase.getText(localeName, 'parkingGarage') ?? _fallback.parkingGarage;
	@override
	String get parkingLot => Phrase.getText(localeName, 'parkingLot') ?? _fallback.parkingLot;
	@override
	String get onDriveway => Phrase.getText(localeName, 'onDriveway') ?? _fallback.onDriveway;
	@override
	String get onStreet => Phrase.getText(localeName, 'onStreet') ?? _fallback.onStreet;
	@override
	String get undergroundGarage => Phrase.getText(localeName, 'undergroundGarage') ?? _fallback.undergroundGarage;
	@override
	String get fuelStation => Phrase.getText(localeName, 'fuelStation') ?? _fallback.fuelStation;
	@override
	String inaccurateTariffWarning(String appName) => Phrase.getText(localeName, 'inaccurateTariffWarning', {'appName':appName}) ?? _fallback.inaccurateTariffWarning(appName);
	@override
	String get somethingWentWrongPleaseTryAgainLater => Phrase.getText(localeName, 'somethingWentWrongPleaseTryAgainLater') ?? _fallback.somethingWentWrongPleaseTryAgainLater;
	@override
	String hAndMin(num hours, num minutes) => Phrase.getText(localeName, 'hAndMin', {'hours':hours, 'minutes':minutes}) ?? _fallback.hAndMin(hours, minutes);
	@override
	String get lessThanAMinute => Phrase.getText(localeName, 'lessThanAMinute') ?? _fallback.lessThanAMinute;
	@override
	String nDays(num count) => Phrase.getText(localeName, 'nDays', {'count':count}) ?? _fallback.nDays(count);
	@override
	String nHours(num count) => Phrase.getText(localeName, 'nHours', {'count':count}) ?? _fallback.nHours(count);
	@override
	String nMinutes(num count) => Phrase.getText(localeName, 'nMinutes', {'count':count}) ?? _fallback.nMinutes(count);
	@override
	String get noTariffAvailable => Phrase.getText(localeName, 'noTariffAvailable') ?? _fallback.noTariffAvailable;
	@override
	String get unknownKW => Phrase.getText(localeName, 'unknownKW') ?? _fallback.unknownKW;
	@override
	String get cardDetailsUnavailable => Phrase.getText(localeName, 'cardDetailsUnavailable') ?? _fallback.cardDetailsUnavailable;
	@override
	String get ok => Phrase.getText(localeName, 'ok') ?? _fallback.ok;
	@override
	String get somethingWentWrong => Phrase.getText(localeName, 'somethingWentWrong') ?? _fallback.somethingWentWrong;
	@override
	String get appUpdateRequiredError => Phrase.getText(localeName, 'appUpdateRequiredError') ?? _fallback.appUpdateRequiredError;
	@override
	String get mfaCodeExhausted => Phrase.getText(localeName, 'mfaCodeExhausted') ?? _fallback.mfaCodeExhausted;
	@override
	String get mfaSetupIntro => Phrase.getText(localeName, 'mfaSetupIntro') ?? _fallback.mfaSetupIntro;
	@override
	String get mfaSetupAuthenticatorTitle => Phrase.getText(localeName, 'mfaSetupAuthenticatorTitle') ?? _fallback.mfaSetupAuthenticatorTitle;
	@override
	String get mfaSetupSmsTitle => Phrase.getText(localeName, 'mfaSetupSmsTitle') ?? _fallback.mfaSetupSmsTitle;
	@override
	String get mfaSetupNotSetUp => Phrase.getText(localeName, 'mfaSetupNotSetUp') ?? _fallback.mfaSetupNotSetUp;
	@override
	String get mfaSetupSetUp => Phrase.getText(localeName, 'mfaSetupSetUp') ?? _fallback.mfaSetupSetUp;
	@override
	String get mfaSetupEnabled => Phrase.getText(localeName, 'mfaSetupEnabled') ?? _fallback.mfaSetupEnabled;
	@override
	String get mfaSetupBack => Phrase.getText(localeName, 'mfaSetupBack') ?? _fallback.mfaSetupBack;
	@override
	String get securityScreenIntro => Phrase.getText(localeName, 'securityScreenIntro') ?? _fallback.securityScreenIntro;
	@override
	String mfaActivatedOn(String date) => Phrase.getText(localeName, 'mfaActivatedOn', {'date':date}) ?? _fallback.mfaActivatedOn(date);
	@override
	String get mfaNotAvailableByPolicy => Phrase.getText(localeName, 'mfaNotAvailableByPolicy') ?? _fallback.mfaNotAvailableByPolicy;
	@override
	String get mfaBackupCodesTitle => Phrase.getText(localeName, 'mfaBackupCodesTitle') ?? _fallback.mfaBackupCodesTitle;
	@override
	String get mfaRecoveryEmailTitle => Phrase.getText(localeName, 'mfaRecoveryEmailTitle') ?? _fallback.mfaRecoveryEmailTitle;
	@override
	String mfaCodesLeft(int count) => Phrase.getText(localeName, 'mfaCodesLeft', {'count':count}) ?? _fallback.mfaCodesLeft(count);
	@override
	String mfaRemoveMethodConfirm(String method) => Phrase.getText(localeName, 'mfaRemoveMethodConfirm', {'method':method}) ?? _fallback.mfaRemoveMethodConfirm(method);
	@override
	String get mfaRemoveOnlyFactorWarning => Phrase.getText(localeName, 'mfaRemoveOnlyFactorWarning') ?? _fallback.mfaRemoveOnlyFactorWarning;
	@override
	String get mfaGenerateCodes => Phrase.getText(localeName, 'mfaGenerateCodes') ?? _fallback.mfaGenerateCodes;
	@override
	String get mfaRegenerateCodes => Phrase.getText(localeName, 'mfaRegenerateCodes') ?? _fallback.mfaRegenerateCodes;
	@override
	String get mfaRegenerateCodesWarning => Phrase.getText(localeName, 'mfaRegenerateCodesWarning') ?? _fallback.mfaRegenerateCodesWarning;
	@override
	String get mfaAddRecoveryEmail => Phrase.getText(localeName, 'mfaAddRecoveryEmail') ?? _fallback.mfaAddRecoveryEmail;
	@override
	String get mfaRecoveryEmailExplanation => Phrase.getText(localeName, 'mfaRecoveryEmailExplanation') ?? _fallback.mfaRecoveryEmailExplanation;
	@override
	String get mfaRecoveryEmailSameAsAccount => Phrase.getText(localeName, 'mfaRecoveryEmailSameAsAccount') ?? _fallback.mfaRecoveryEmailSameAsAccount;
	@override
	String get shareCodes => Phrase.getText(localeName, 'shareCodes') ?? _fallback.shareCodes;
	@override
	String get copiedToClipboard => Phrase.getText(localeName, 'copiedToClipboard') ?? _fallback.copiedToClipboard;
	@override
	String get remove => Phrase.getText(localeName, 'remove') ?? _fallback.remove;
	@override
	String get change => Phrase.getText(localeName, 'change') ?? _fallback.change;
	@override
	String get done => Phrase.getText(localeName, 'done') ?? _fallback.done;
	@override
	String get sendCode => Phrase.getText(localeName, 'sendCode') ?? _fallback.sendCode;
	@override
	String mfaTooManyAttemptsWait(String wait) => Phrase.getText(localeName, 'mfaTooManyAttemptsWait', {'wait':wait}) ?? _fallback.mfaTooManyAttemptsWait(wait);
	@override
	String mfaResendWaitCountdown(String wait) => Phrase.getText(localeName, 'mfaResendWaitCountdown', {'wait':wait}) ?? _fallback.mfaResendWaitCountdown(wait);
	@override
	String get stepUpTitle => Phrase.getText(localeName, 'stepUpTitle') ?? _fallback.stepUpTitle;
	@override
	String get stepUpPickMethodIntro => Phrase.getText(localeName, 'stepUpPickMethodIntro') ?? _fallback.stepUpPickMethodIntro;
	@override
	String get stepUpAuthenticatorPrompt => Phrase.getText(localeName, 'stepUpAuthenticatorPrompt') ?? _fallback.stepUpAuthenticatorPrompt;
	@override
	String get stepUpPasskeyOnly => Phrase.getText(localeName, 'stepUpPasskeyOnly') ?? _fallback.stepUpPasskeyOnly;
	@override
	String get error => Phrase.getText(localeName, 'error') ?? _fallback.error;
	@override
	String get sessionExpiredTitle => Phrase.getText(localeName, 'sessionExpiredTitle') ?? _fallback.sessionExpiredTitle;
	@override
	String get sessionExpiredMessage => Phrase.getText(localeName, 'sessionExpiredMessage') ?? _fallback.sessionExpiredMessage;
	@override
	String get signInExpiringMessage => Phrase.getText(localeName, 'signInExpiringMessage') ?? _fallback.signInExpiringMessage;
	@override
	String get biometricPromptReason => Phrase.getText(localeName, 'biometricPromptReason') ?? _fallback.biometricPromptReason;
	@override
	String get youreAllReadyToBegin => Phrase.getText(localeName, 'youreAllReadyToBegin') ?? _fallback.youreAllReadyToBegin;
	@override
	String get startYouFirstEVCharge => Phrase.getText(localeName, 'startYouFirstEVCharge') ?? _fallback.startYouFirstEVCharge;
	@override
	String get locationServicesAreDisabled => Phrase.getText(localeName, 'locationServicesAreDisabled') ?? _fallback.locationServicesAreDisabled;
	@override
	String get skip => Phrase.getText(localeName, 'skip') ?? _fallback.skip;
	@override
	String get openSettings => Phrase.getText(localeName, 'openSettings') ?? _fallback.openSettings;
	@override
	String get locationPermissionsHaveBeenDenied => Phrase.getText(localeName, 'locationPermissionsHaveBeenDenied') ?? _fallback.locationPermissionsHaveBeenDenied;
	@override
	String get continueStr => Phrase.getText(localeName, 'continueStr') ?? _fallback.continueStr;
	@override
	String get byAllowingLocationServices => Phrase.getText(localeName, 'byAllowingLocationServices') ?? _fallback.byAllowingLocationServices;
	@override
	String get findAllAvailableChargeStationsNearby => Phrase.getText(localeName, 'findAllAvailableChargeStationsNearby') ?? _fallback.findAllAvailableChargeStationsNearby;
	@override
	String get getStarted => Phrase.getText(localeName, 'getStarted') ?? _fallback.getStarted;
	@override
	String get letsGetYouStarted => Phrase.getText(localeName, 'letsGetYouStarted') ?? _fallback.letsGetYouStarted;
	@override
	String get eVWallet => Phrase.getText(localeName, 'eVWallet') ?? _fallback.eVWallet;
	@override
	String get signupForAnAccount => Phrase.getText(localeName, 'signupForAnAccount') ?? _fallback.signupForAnAccount;
	@override
	String get forgotPassword => Phrase.getText(localeName, 'forgotPassword') ?? _fallback.forgotPassword;
	@override
	String get password => Phrase.getText(localeName, 'password') ?? _fallback.password;
	@override
	String get eMail => Phrase.getText(localeName, 'eMail') ?? _fallback.eMail;
	@override
	String get priceUnknown => Phrase.getText(localeName, 'priceUnknown') ?? _fallback.priceUnknown;
	@override
	String get youHaventChargedYourEVYet => Phrase.getText(localeName, 'youHaventChargedYourEVYet') ?? _fallback.youHaventChargedYourEVYet;
	@override
	String get cardRfid => Phrase.getText(localeName, 'cardRfid') ?? _fallback.cardRfid;
	@override
	String get youDontHaveAnyPaymentMethodsYet => Phrase.getText(localeName, 'youDontHaveAnyPaymentMethodsYet') ?? _fallback.youDontHaveAnyPaymentMethodsYet;
	@override
	String get sessions => Phrase.getText(localeName, 'sessions') ?? _fallback.sessions;
	@override
	String get paymentMethods => Phrase.getText(localeName, 'paymentMethods') ?? _fallback.paymentMethods;
	@override
	String get paymentsAndSessions => Phrase.getText(localeName, 'paymentsAndSessions') ?? _fallback.paymentsAndSessions;
	@override
	String get wallet => Phrase.getText(localeName, 'wallet') ?? _fallback.wallet;
	@override
	String get locationServicesHaveBeenDisabledForThisApp => Phrase.getText(localeName, 'locationServicesHaveBeenDisabledForThisApp') ?? _fallback.locationServicesHaveBeenDisabledForThisApp;
	@override
	String get locationPermissionGranted => Phrase.getText(localeName, 'locationPermissionGranted') ?? _fallback.locationPermissionGranted;
	@override
	String get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings => Phrase.getText(localeName, 'locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings') ?? _fallback.locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings;
	@override
	String get requestPermission => Phrase.getText(localeName, 'requestPermission') ?? _fallback.requestPermission;
	@override
	String get grantLocationPermissionToUseThisFeature => Phrase.getText(localeName, 'grantLocationPermissionToUseThisFeature') ?? _fallback.grantLocationPermissionToUseThisFeature;
	@override
	String get initialisingLocationService => Phrase.getText(localeName, 'initialisingLocationService') ?? _fallback.initialisingLocationService;
	@override
	String get findEVChargingLocations => Phrase.getText(localeName, 'findEVChargingLocations') ?? _fallback.findEVChargingLocations;
	@override
	String get exploreStations => Phrase.getText(localeName, 'exploreStations') ?? _fallback.exploreStations;
	@override
	String get viewWallet => Phrase.getText(localeName, 'viewWallet') ?? _fallback.viewWallet;
	@override
	String get startAChargeSession => Phrase.getText(localeName, 'startAChargeSession') ?? _fallback.startAChargeSession;
	@override
	String get charging => Phrase.getText(localeName, 'charging') ?? _fallback.charging;
	@override
	String get clickTheButtonBelow => Phrase.getText(localeName, 'clickTheButtonBelow') ?? _fallback.clickTheButtonBelow;
	@override
	String get startYourEVCharge => Phrase.getText(localeName, 'startYourEVCharge') ?? _fallback.startYourEVCharge;
	@override
	String get searchLocation => Phrase.getText(localeName, 'searchLocation') ?? _fallback.searchLocation;
	@override
	String get getDirections => Phrase.getText(localeName, 'getDirections') ?? _fallback.getDirections;
	@override
	String get shareLocation => Phrase.getText(localeName, 'shareLocation') ?? _fallback.shareLocation;
	@override
	String get streetView => Phrase.getText(localeName, 'streetView') ?? _fallback.streetView;
	@override
	String get pressToView => Phrase.getText(localeName, 'pressToView') ?? _fallback.pressToView;
	@override
	String get streetViewNotAvailable => Phrase.getText(localeName, 'streetViewNotAvailable') ?? _fallback.streetViewNotAvailable;
	@override
	String get locationPictures => Phrase.getText(localeName, 'locationPictures') ?? _fallback.locationPictures;
	@override
	String locationPictureCounter(int index, int total) => Phrase.getText(localeName, 'locationPictureCounter', {'index':index, 'total':total}) ?? _fallback.locationPictureCounter(index, total);
	@override
	String get locationPictureCouldNotLoad => Phrase.getText(localeName, 'locationPictureCouldNotLoad') ?? _fallback.locationPictureCouldNotLoad;
	@override
	String get chargeNow => Phrase.getText(localeName, 'chargeNow') ?? _fallback.chargeNow;
	@override
	String get trySearchingForAnotherLocation => Phrase.getText(localeName, 'trySearchingForAnotherLocation') ?? _fallback.trySearchingForAnotherLocation;
	@override
	String get noChargeStationsFound => Phrase.getText(localeName, 'noChargeStationsFound') ?? _fallback.noChargeStationsFound;
	@override
	String get myCurrentPosition => Phrase.getText(localeName, 'myCurrentPosition') ?? _fallback.myCurrentPosition;
	@override
	String get useMyCurrentPosition => Phrase.getText(localeName, 'useMyCurrentPosition') ?? _fallback.useMyCurrentPosition;
	@override
	String get searchAddressOrPlaceName => Phrase.getText(localeName, 'searchAddressOrPlaceName') ?? _fallback.searchAddressOrPlaceName;
	@override
	String get clearFilters => Phrase.getText(localeName, 'clearFilters') ?? _fallback.clearFilters;
	@override
	String get connectorType => Phrase.getText(localeName, 'connectorType') ?? _fallback.connectorType;
	@override
	String get chargingPowerkW => Phrase.getText(localeName, 'chargingPowerkW') ?? _fallback.chargingPowerkW;
	@override
	String get chargers => Phrase.getText(localeName, 'chargers') ?? _fallback.chargers;
	@override
	String get dCChargers => Phrase.getText(localeName, 'dCChargers') ?? _fallback.dCChargers;
	@override
	String get availableChargers => Phrase.getText(localeName, 'availableChargers') ?? _fallback.availableChargers;
	@override
	String get onlyShow => Phrase.getText(localeName, 'onlyShow') ?? _fallback.onlyShow;
	@override
	String get filters => Phrase.getText(localeName, 'filters') ?? _fallback.filters;
	@override
	String get findMoreStationsNearby => Phrase.getText(localeName, 'findMoreStationsNearby') ?? _fallback.findMoreStationsNearby;
	@override
	String get findStationsNearby => Phrase.getText(localeName, 'findStationsNearby') ?? _fallback.findStationsNearby;
	@override
	String get highwayModeAvailableWhileDriving => Phrase.getText(localeName, 'highwayModeAvailableWhileDriving') ?? _fallback.highwayModeAvailableWhileDriving;
	@override
	String get youCanAlwaysFindNearbyStations => Phrase.getText(localeName, 'youCanAlwaysFindNearbyStations') ?? _fallback.youCanAlwaysFindNearbyStations;
	@override
	String get nearbyStations => Phrase.getText(localeName, 'nearbyStations') ?? _fallback.nearbyStations;
	@override
	String get selectYourChargeStation => Phrase.getText(localeName, 'selectYourChargeStation') ?? _fallback.selectYourChargeStation;
	@override
	String get paymentMethod => Phrase.getText(localeName, 'paymentMethod') ?? _fallback.paymentMethod;
	@override
	String get unnamedCard => Phrase.getText(localeName, 'unnamedCard') ?? _fallback.unnamedCard;
	@override
	String get noCardsAvailable => Phrase.getText(localeName, 'noCardsAvailable') ?? _fallback.noCardsAvailable;
	@override
	String get startSession => Phrase.getText(localeName, 'startSession') ?? _fallback.startSession;
	@override
	String get unknownEVSEID => Phrase.getText(localeName, 'unknownEVSEID') ?? _fallback.unknownEVSEID;
	@override
	String get startChargingSession => Phrase.getText(localeName, 'startChargingSession') ?? _fallback.startChargingSession;
	@override
	String get exploreOrSearchForALocation => Phrase.getText(localeName, 'exploreOrSearchForALocation') ?? _fallback.exploreOrSearchForALocation;
	@override
	String get thereArentAnyStationsNearYou => Phrase.getText(localeName, 'thereArentAnyStationsNearYou') ?? _fallback.thereArentAnyStationsNearYou;
	@override
	String get noStationsFound => Phrase.getText(localeName, 'noStationsFound') ?? _fallback.noStationsFound;
	@override
	String get selectStation => Phrase.getText(localeName, 'selectStation') ?? _fallback.selectStation;
	@override
	String get evseId => Phrase.getText(localeName, 'evseId') ?? _fallback.evseId;
	@override
	String get manualStationInput => Phrase.getText(localeName, 'manualStationInput') ?? _fallback.manualStationInput;
	@override
	String get manualEVSEIDInput => Phrase.getText(localeName, 'manualEVSEIDInput') ?? _fallback.manualEVSEIDInput;
	@override
	String get noSelectDifferentStation => Phrase.getText(localeName, 'noSelectDifferentStation') ?? _fallback.noSelectDifferentStation;
	@override
	String get yesThisIsMe => Phrase.getText(localeName, 'yesThisIsMe') ?? _fallback.yesThisIsMe;
	@override
	String get isThisYou => Phrase.getText(localeName, 'isThisYou') ?? _fallback.isThisYou;
	@override
	String get imAllPluggedIn => Phrase.getText(localeName, 'imAllPluggedIn') ?? _fallback.imAllPluggedIn;
	@override
	String get close => Phrase.getText(localeName, 'close') ?? _fallback.close;
	@override
	String get endSession => Phrase.getText(localeName, 'endSession') ?? _fallback.endSession;
	@override
	String get yourCarIsCharging => Phrase.getText(localeName, 'yourCarIsCharging') ?? _fallback.yourCarIsCharging;
	@override
	String get unknownKWh => Phrase.getText(localeName, 'unknownKWh') ?? _fallback.unknownKWh;
	@override
	String get profile => Phrase.getText(localeName, 'profile') ?? _fallback.profile;
	@override
	String get account => Phrase.getText(localeName, 'account') ?? _fallback.account;
	@override
	String get login => Phrase.getText(localeName, 'login') ?? _fallback.login;
	@override
	String get dashboard => Phrase.getText(localeName, 'dashboard') ?? _fallback.dashboard;
	@override
	String get helpAndSupport => Phrase.getText(localeName, 'helpAndSupport') ?? _fallback.helpAndSupport;
	@override
	String get cancelSubscription => Phrase.getText(localeName, 'cancelSubscription') ?? _fallback.cancelSubscription;
	@override
	String get removeAccount => Phrase.getText(localeName, 'removeAccount') ?? _fallback.removeAccount;
	@override
	String get logout => Phrase.getText(localeName, 'logout') ?? _fallback.logout;
	@override
	String get directPayments => Phrase.getText(localeName, 'directPayments') ?? _fallback.directPayments;
	@override
	String get chargingCardOrTag => Phrase.getText(localeName, 'chargingCardOrTag') ?? _fallback.chargingCardOrTag;
	@override
	String get withoutAdditionalFeePerSession => Phrase.getText(localeName, 'withoutAdditionalFeePerSession') ?? _fallback.withoutAdditionalFeePerSession;
	@override
	String get supportsRemoteCharge => Phrase.getText(localeName, 'supportsRemoteCharge') ?? _fallback.supportsRemoteCharge;
	@override
	String get additionalFee => Phrase.getText(localeName, 'additionalFee') ?? _fallback.additionalFee;
	@override
	String get favouriteStations => Phrase.getText(localeName, 'favouriteStations') ?? _fallback.favouriteStations;
	@override
	String get compassDirectionNorth => Phrase.getText(localeName, 'compassDirectionNorth') ?? _fallback.compassDirectionNorth;
	@override
	String get compassDirectionNorthEast => Phrase.getText(localeName, 'compassDirectionNorthEast') ?? _fallback.compassDirectionNorthEast;
	@override
	String get compassDirectionEast => Phrase.getText(localeName, 'compassDirectionEast') ?? _fallback.compassDirectionEast;
	@override
	String get compassDirectionSouthEast => Phrase.getText(localeName, 'compassDirectionSouthEast') ?? _fallback.compassDirectionSouthEast;
	@override
	String get compassDirectionSouth => Phrase.getText(localeName, 'compassDirectionSouth') ?? _fallback.compassDirectionSouth;
	@override
	String get compassDirectionSouthWest => Phrase.getText(localeName, 'compassDirectionSouthWest') ?? _fallback.compassDirectionSouthWest;
	@override
	String get compassDirectionWest => Phrase.getText(localeName, 'compassDirectionWest') ?? _fallback.compassDirectionWest;
	@override
	String get compassDirectionNorthWest => Phrase.getText(localeName, 'compassDirectionNorthWest') ?? _fallback.compassDirectionNorthWest;
	@override
	String get totalSessions => Phrase.getText(localeName, 'totalSessions') ?? _fallback.totalSessions;
	@override
	String get totalEnergy => Phrase.getText(localeName, 'totalEnergy') ?? _fallback.totalEnergy;
	@override
	String get totalTime => Phrase.getText(localeName, 'totalTime') ?? _fallback.totalTime;
	@override
	String get totalCost => Phrase.getText(localeName, 'totalCost') ?? _fallback.totalCost;
	@override
	String get costTooltipText => Phrase.getText(localeName, 'costTooltipText') ?? _fallback.costTooltipText;
	@override
	String get selectOption => Phrase.getText(localeName, 'selectOption') ?? _fallback.selectOption;
	@override
	String get carScreenFastChargersAhead => Phrase.getText(localeName, 'carScreenFastChargersAhead') ?? _fallback.carScreenFastChargersAhead;
	@override
	String get carScreenHighway => Phrase.getText(localeName, 'carScreenHighway') ?? _fallback.carScreenHighway;
	@override
	String get carScreenHighwayAuto => Phrase.getText(localeName, 'carScreenHighwayAuto') ?? _fallback.carScreenHighwayAuto;
	@override
	String get carScreenHighwayOff => Phrase.getText(localeName, 'carScreenHighwayOff') ?? _fallback.carScreenHighwayOff;
	@override
	String get carScreenHighwayOn => Phrase.getText(localeName, 'carScreenHighwayOn') ?? _fallback.carScreenHighwayOn;
	@override
	String get carScreenNavigate => Phrase.getText(localeName, 'carScreenNavigate') ?? _fallback.carScreenNavigate;
	@override
	String get carScreenShowDetails => Phrase.getText(localeName, 'carScreenShowDetails') ?? _fallback.carScreenShowDetails;
	@override
	String carScreenFiltersCount(int count) => Phrase.getText(localeName, 'carScreenFiltersCount', {'count':count}) ?? _fallback.carScreenFiltersCount(count);
	@override
	String get carScreenFilterOn => Phrase.getText(localeName, 'carScreenFilterOn') ?? _fallback.carScreenFilterOn;
	@override
	String get carScreenFilterOff => Phrase.getText(localeName, 'carScreenFilterOff') ?? _fallback.carScreenFilterOff;
	@override
	String get carScreenSearchingStations => Phrase.getText(localeName, 'carScreenSearchingStations') ?? _fallback.carScreenSearchingStations;
	@override
	String get carScreenNoStationsFound => Phrase.getText(localeName, 'carScreenNoStationsFound') ?? _fallback.carScreenNoStationsFound;
	@override
	String get carScreenNavigationNotAvailable => Phrase.getText(localeName, 'carScreenNavigationNotAvailable') ?? _fallback.carScreenNavigationNotAvailable;
	@override
	String get carScreenNavigationError => Phrase.getText(localeName, 'carScreenNavigationError') ?? _fallback.carScreenNavigationError;
	@override
	String get carScreenNavigateOnPhone => Phrase.getText(localeName, 'carScreenNavigateOnPhone') ?? _fallback.carScreenNavigateOnPhone;
	@override
	String get carScreenNoFiltersAvailable => Phrase.getText(localeName, 'carScreenNoFiltersAvailable') ?? _fallback.carScreenNoFiltersAvailable;
	@override
	String carScreenAvailabilityCount(int available, int total) => Phrase.getText(localeName, 'carScreenAvailabilityCount', {'available':available, 'total':total}) ?? _fallback.carScreenAvailabilityCount(available, total);
	@override
	String carScreenPricePerKwh(String price) => Phrase.getText(localeName, 'carScreenPricePerKwh', {'price':price}) ?? _fallback.carScreenPricePerKwh(price);
	@override
	String get carScreenTabMap => Phrase.getText(localeName, 'carScreenTabMap') ?? _fallback.carScreenTabMap;
	@override
	String get carScreenTabFilters => Phrase.getText(localeName, 'carScreenTabFilters') ?? _fallback.carScreenTabFilters;
	@override
	String get carScreenTabFavourites => Phrase.getText(localeName, 'carScreenTabFavourites') ?? _fallback.carScreenTabFavourites;
	@override
	String get carScreenNoFavourites => Phrase.getText(localeName, 'carScreenNoFavourites') ?? _fallback.carScreenNoFavourites;
	@override
	String get carScreenLoginToSaveFavourites => Phrase.getText(localeName, 'carScreenLoginToSaveFavourites') ?? _fallback.carScreenLoginToSaveFavourites;
	@override
	String get carScreenSave => Phrase.getText(localeName, 'carScreenSave') ?? _fallback.carScreenSave;
	@override
	String get carScreenSaved => Phrase.getText(localeName, 'carScreenSaved') ?? _fallback.carScreenSaved;
	@override
	String get carScreenChargingPower => Phrase.getText(localeName, 'carScreenChargingPower') ?? _fallback.carScreenChargingPower;
	@override
	String get carScreenAll => Phrase.getText(localeName, 'carScreenAll') ?? _fallback.carScreenAll;
	@override
	String get carScreenPowerSlow => Phrase.getText(localeName, 'carScreenPowerSlow') ?? _fallback.carScreenPowerSlow;
	@override
	String get carScreenPowerFast => Phrase.getText(localeName, 'carScreenPowerFast') ?? _fallback.carScreenPowerFast;
	@override
	String get carScreenPowerRapid => Phrase.getText(localeName, 'carScreenPowerRapid') ?? _fallback.carScreenPowerRapid;
	@override
	String get carScreenPowerUltra => Phrase.getText(localeName, 'carScreenPowerUltra') ?? _fallback.carScreenPowerUltra;
	@override
	String carScreenCountSelected(int count) => Phrase.getText(localeName, 'carScreenCountSelected', {'count':count}) ?? _fallback.carScreenCountSelected(count);
	@override
	String get selectNetworks => Phrase.getText(localeName, 'selectNetworks') ?? _fallback.selectNetworks;
	@override
	String get excludeNetworks => Phrase.getText(localeName, 'excludeNetworks') ?? _fallback.excludeNetworks;
	@override
	String get selectNetworksToInclude => Phrase.getText(localeName, 'selectNetworksToInclude') ?? _fallback.selectNetworksToInclude;
	@override
	String get selectNetworksToExclude => Phrase.getText(localeName, 'selectNetworksToExclude') ?? _fallback.selectNetworksToExclude;
	@override
	String get searchNetworks => Phrase.getText(localeName, 'searchNetworks') ?? _fallback.searchNetworks;
	@override
	String get couldNotLoadNetworks => Phrase.getText(localeName, 'couldNotLoadNetworks') ?? _fallback.couldNotLoadNetworks;
	@override
	String get noNetworksFound => Phrase.getText(localeName, 'noNetworksFound') ?? _fallback.noNetworksFound;
	@override
	String get addANetwork => Phrase.getText(localeName, 'addANetwork') ?? _fallback.addANetwork;
	@override
	String get reportProblemEntryStation => Phrase.getText(localeName, 'reportProblemEntryStation') ?? _fallback.reportProblemEntryStation;
	@override
	String get reportProblemEntrySession => Phrase.getText(localeName, 'reportProblemEntrySession') ?? _fallback.reportProblemEntrySession;
	@override
	String get reportProblemEntrySessionEnded => Phrase.getText(localeName, 'reportProblemEntrySessionEnded') ?? _fallback.reportProblemEntrySessionEnded;
	@override
	String get reportProblemEntryCta => Phrase.getText(localeName, 'reportProblemEntryCta') ?? _fallback.reportProblemEntryCta;
	@override
	String get reportProblemTitle => Phrase.getText(localeName, 'reportProblemTitle') ?? _fallback.reportProblemTitle;
	@override
	String get reportProblemFieldConnector => Phrase.getText(localeName, 'reportProblemFieldConnector') ?? _fallback.reportProblemFieldConnector;
	@override
	String get reportProblemFieldCategory => Phrase.getText(localeName, 'reportProblemFieldCategory') ?? _fallback.reportProblemFieldCategory;
	@override
	String get reportProblemFieldDescription => Phrase.getText(localeName, 'reportProblemFieldDescription') ?? _fallback.reportProblemFieldDescription;
	@override
	String get reportProblemDescriptionPlaceholder => Phrase.getText(localeName, 'reportProblemDescriptionPlaceholder') ?? _fallback.reportProblemDescriptionPlaceholder;
	@override
	String get reportProblemSubmit => Phrase.getText(localeName, 'reportProblemSubmit') ?? _fallback.reportProblemSubmit;
	@override
	String get reportProblemSuccess => Phrase.getText(localeName, 'reportProblemSuccess') ?? _fallback.reportProblemSuccess;
	@override
	String get reportProblemCategoryChargerNotAvailable => Phrase.getText(localeName, 'reportProblemCategoryChargerNotAvailable') ?? _fallback.reportProblemCategoryChargerNotAvailable;
	@override
	String get reportProblemCategoryChargerDamaged => Phrase.getText(localeName, 'reportProblemCategoryChargerDamaged') ?? _fallback.reportProblemCategoryChargerDamaged;
	@override
	String get reportProblemCategoryChargerHardToFind => Phrase.getText(localeName, 'reportProblemCategoryChargerHardToFind') ?? _fallback.reportProblemCategoryChargerHardToFind;
	@override
	String get reportProblemCategoryWrongConnectorSpeed => Phrase.getText(localeName, 'reportProblemCategoryWrongConnectorSpeed') ?? _fallback.reportProblemCategoryWrongConnectorSpeed;
	@override
	String get reportProblemCategoryWrongConnectorType => Phrase.getText(localeName, 'reportProblemCategoryWrongConnectorType') ?? _fallback.reportProblemCategoryWrongConnectorType;
	@override
	String get reportProblemCategoryMissingPriceInformation => Phrase.getText(localeName, 'reportProblemCategoryMissingPriceInformation') ?? _fallback.reportProblemCategoryMissingPriceInformation;
	@override
	String get reportProblemCategoryMissingPowerInformation => Phrase.getText(localeName, 'reportProblemCategoryMissingPowerInformation') ?? _fallback.reportProblemCategoryMissingPowerInformation;
	@override
	String get reportProblemCategoryChargingSessionInterrupted => Phrase.getText(localeName, 'reportProblemCategoryChargingSessionInterrupted') ?? _fallback.reportProblemCategoryChargingSessionInterrupted;
	@override
	String get reportProblemCategoryChargingSessionNotStarted => Phrase.getText(localeName, 'reportProblemCategoryChargingSessionNotStarted') ?? _fallback.reportProblemCategoryChargingSessionNotStarted;
	@override
	String get reportProblemCategoryOther => Phrase.getText(localeName, 'reportProblemCategoryOther') ?? _fallback.reportProblemCategoryOther;
	@override
	String get stepUpPasskeyPrompt => Phrase.getText(localeName, 'stepUpPasskeyPrompt') ?? _fallback.stepUpPasskeyPrompt;
	@override
	String get stepUpPasskeyNoCredential => Phrase.getText(localeName, 'stepUpPasskeyNoCredential') ?? _fallback.stepUpPasskeyNoCredential;
	@override
	String get passkeyAuthentication => Phrase.getText(localeName, 'passkeyAuthentication') ?? _fallback.passkeyAuthentication;
	@override
	String get passkeySignInWithDevice => Phrase.getText(localeName, 'passkeySignInWithDevice') ?? _fallback.passkeySignInWithDevice;
	@override
	String get mfaPasskeyTitle => Phrase.getText(localeName, 'mfaPasskeyTitle') ?? _fallback.mfaPasskeyTitle;
	@override
	String get mfaPasskeyExplanation => Phrase.getText(localeName, 'mfaPasskeyExplanation') ?? _fallback.mfaPasskeyExplanation;
	@override
	String get mfaPasskeyButton => Phrase.getText(localeName, 'mfaPasskeyButton') ?? _fallback.mfaPasskeyButton;
	@override
	String get mfaPasskeyNoCredential => Phrase.getText(localeName, 'mfaPasskeyNoCredential') ?? _fallback.mfaPasskeyNoCredential;
	@override
	String get mfaEnrolPasskeyTitle => Phrase.getText(localeName, 'mfaEnrolPasskeyTitle') ?? _fallback.mfaEnrolPasskeyTitle;
	@override
	String get mfaEnrolPasskeyExplanation => Phrase.getText(localeName, 'mfaEnrolPasskeyExplanation') ?? _fallback.mfaEnrolPasskeyExplanation;
	@override
	String get mfaEnrolPasskeyButton => Phrase.getText(localeName, 'mfaEnrolPasskeyButton') ?? _fallback.mfaEnrolPasskeyButton;
	@override
	String get mfaPasskeyAlreadyOnDevice => Phrase.getText(localeName, 'mfaPasskeyAlreadyOnDevice') ?? _fallback.mfaPasskeyAlreadyOnDevice;
	@override
	String get signInWithAPasskey => Phrase.getText(localeName, 'signInWithAPasskey') ?? _fallback.signInWithAPasskey;
	@override
	String get passkeyLoginNoCredential => Phrase.getText(localeName, 'passkeyLoginNoCredential') ?? _fallback.passkeyLoginNoCredential;
	@override
	String get mfaPasskeysTitle => Phrase.getText(localeName, 'mfaPasskeysTitle') ?? _fallback.mfaPasskeysTitle;
	@override
	String mfaPasskeysCount(num count) => Phrase.getText(localeName, 'mfaPasskeysCount', {'count':count}) ?? _fallback.mfaPasskeysCount(count);
	@override
	String get mfaPasskeysIntro => Phrase.getText(localeName, 'mfaPasskeysIntro') ?? _fallback.mfaPasskeysIntro;
	@override
	String get mfaPasskeysDisallowed => Phrase.getText(localeName, 'mfaPasskeysDisallowed') ?? _fallback.mfaPasskeysDisallowed;
	@override
	String get mfaPasskeysUnsupportedDevice => Phrase.getText(localeName, 'mfaPasskeysUnsupportedDevice') ?? _fallback.mfaPasskeysUnsupportedDevice;
	@override
	String get mfaAddPasskey => Phrase.getText(localeName, 'mfaAddPasskey') ?? _fallback.mfaAddPasskey;
	@override
	String mfaPasskeyAddedOn(String date) => Phrase.getText(localeName, 'mfaPasskeyAddedOn', {'date':date}) ?? _fallback.mfaPasskeyAddedOn(date);
	@override
	String mfaPasskeyLastUsedOn(String date) => Phrase.getText(localeName, 'mfaPasskeyLastUsedOn', {'date':date}) ?? _fallback.mfaPasskeyLastUsedOn(date);
	@override
	String get mfaPasskeyRenameTitle => Phrase.getText(localeName, 'mfaPasskeyRenameTitle') ?? _fallback.mfaPasskeyRenameTitle;
	@override
	String get mfaPasskeyNameHelp => Phrase.getText(localeName, 'mfaPasskeyNameHelp') ?? _fallback.mfaPasskeyNameHelp;
	@override
	String get mfaPasskeyNamePlaceholder => Phrase.getText(localeName, 'mfaPasskeyNamePlaceholder') ?? _fallback.mfaPasskeyNamePlaceholder;
	@override
	String get rename => Phrase.getText(localeName, 'rename') ?? _fallback.rename;
	@override
	String get save => Phrase.getText(localeName, 'save') ?? _fallback.save;
	@override
	String get mfaPasskeyVerificationFailed => Phrase.getText(localeName, 'mfaPasskeyVerificationFailed') ?? _fallback.mfaPasskeyVerificationFailed;
	@override
	String get mfaPasskeyChallengeMissing => Phrase.getText(localeName, 'mfaPasskeyChallengeMissing') ?? _fallback.mfaPasskeyChallengeMissing;
	@override
	String get mfaPasskeyCreateFailed => Phrase.getText(localeName, 'mfaPasskeyCreateFailed') ?? _fallback.mfaPasskeyCreateFailed;
}
