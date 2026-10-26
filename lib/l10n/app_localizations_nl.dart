// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get highwayMode => 'Highway Mode';

  @override
  String get stopAtNearestFastChargingStation =>
      'Stop bij de dichtstbijzijnde snellader';

  @override
  String get emailAddressSuccessfullyVerified =>
      'E-mailadres succesvol geverifieerd!';

  @override
  String get phoneNumberSuccessfullyVerified =>
      'Telefoonnummer succesvol geverifieerd!';

  @override
  String get pleaseVerifyYourPhoneNumberAndEmail =>
      'Verifieer je telefoonnummer en e-mailadres.';

  @override
  String get verifyYourPhoneNumberNow => 'Verifieer je telefoonnummer';

  @override
  String get verifyYourEmailNow => 'Verifieer je e-mailadres nu.';

  @override
  String get verifyYourEmailAddress => 'Verifieer je e-mailadres';

  @override
  String weSentYouAnEmailVerification(String emailAddress) {
    return 'We hebben je een e-mail gestuurd naar $emailAddress.';
  }

  @override
  String get openMailApp => 'E-mail-app openen';

  @override
  String get pleaseConfirmYourEmailAddressByClicking =>
      'Bevestig je e-mailadres door op de link te klikken in de e-mail die we je hebben gestuurd.';

  @override
  String get didntReceiveTheEmail =>
      'Heb je de e-mail niet ontvangen? Controleer je spam of';

  @override
  String get resendEmailVerificationLink => 'Verificatielink opnieuw verzenden';

  @override
  String get verified => 'Geverifieerd';

  @override
  String get stationAddedToYourFavourites =>
      'Laadpaal toegevoegd aan je favorieten';

  @override
  String get removedFromYourFavourites => 'Verwijderd uit je favorieten';

  @override
  String get yourFavouriteStationsWillShowUpHere =>
      'Je favoriete laadpalen worden hier weergegeven.';

  @override
  String get markStationsAsFavouriteByPressingTheHeartIcon =>
      'Markeer laadpalen als favoriet door op het hartpictogram te drukken.';

  @override
  String get addToFavourites => 'Toevoegen aan favorieten';

  @override
  String get removeFromFavourites => 'Verwijder uit je favorieten';

  @override
  String get exploreMap => 'Kaart verkennen';

  @override
  String get nearestStations => 'Dichtstbijzijnde laadpunten';

  @override
  String get fastStationsWithPower => 'Fast stations (>50 kW)';

  @override
  String onRoad(String road) {
    return 'on $road';
  }

  @override
  String get noNearbyStations => 'Geen laadpunten in de buurt gevonden';

  @override
  String get noChargingStationsFoundNearby =>
      'Geen laadpunten in de buurt gevonden';

  @override
  String get accountRemovalIsPending =>
      'Het verwijderen van het account is in behandeling';

  @override
  String get areYouSureYouWantToRemoveYourAccount =>
      'Weet je zeker dat je je account wilt verwijderen?';

  @override
  String get thisActionIsPermanent => 'Deze actie is permanent.';

  @override
  String get yesRemoveAccount => 'Ja, account verwijderen';

  @override
  String weSentYouAndSmsFullNumber(String phoneNumber) {
    return 'We hebben je een sms gestuurd naar $phoneNumber.';
  }

  @override
  String get saveRecoveryCodes => 'Herstelcodes opslaan';

  @override
  String get recoveryCodesCanBeUsed =>
      'Herstelcodes kunnen worden gebruikt om toegang te krijgen tot je account voor het geval u de toegang tot uw apparaat verliest en geen tweefactor authenticatie codes kunt ontvangen.';

  @override
  String get downloadCodes => 'Codes downloaden';

  @override
  String get copyCodes => 'Codes kopiëren';

  @override
  String get iSavedMyBackupCodes => 'Ik heb mijn back-upcodes opgeslagen';

  @override
  String get putTheseInASafeSpot =>
      'Zet deze op een veilige plek. Als je je apparaat kwijtraakt en niet over de herstelcodes beschikt, verliest je de toegang tot je account.';

  @override
  String get or => 'of';

  @override
  String get oneDownloadAnAuthenticatorApp =>
      '1. Download een authenticator-app';

  @override
  String get weRecommendGoogleAuthenticator =>
      'We raden --authoption--, --authoption-- of --authoption aan--.';

  @override
  String get googleAuthenticator => 'Google Authenticator';

  @override
  String get onePassword => '1Password';

  @override
  String get authy => 'Authy';

  @override
  String get twoScanTheQrCode => '2. Scan de QR-code met je authenticator-app';

  @override
  String get threeEnterTheCode =>
      '3. Voer de beveiligingscode in die door de app is gegenereerd';

  @override
  String get appAuthentication => 'App authenticatie';

  @override
  String get securityCodesGeneratedByApp =>
      'Beveiligingscodes worden gegenereerd door de authenticator-app die je voorkeur heeft.';

  @override
  String get smsAuthentication => 'SMS authenticatie';

  @override
  String get securityCodesSentViaSms =>
      'Beveiligingscodes worden via sms naar je mobiele telefoon verzonden.';

  @override
  String get passwordAndAuthentication => 'Wachtwoord en authenticatie';

  @override
  String get dontHaveYourBackupCodes => 'Heb je de back-upcodes niet meer?';

  @override
  String get contactSupportAt =>
      'Neem contact op met onze support afdeling via';

  @override
  String get toStartAManualVerificationProcess =>
      'om een handmatig verificatieproces te starten.';

  @override
  String get pleaseEnterBackupCode =>
      'Voer één van je ongebruikte backup codes in';

  @override
  String get backupVerificationCode => 'Back-up verificatiecode';

  @override
  String get codeEnteredIsIncorrect =>
      'De ingevoerde code is onjuist. Probeer het opnieuw of vraag een nieuwe code aan.';

  @override
  String get isThisAuthMethodNotWorking =>
      'Werkt deze authenticatiemethode niet?';

  @override
  String get useYourBackupCodes => 'Gebruik je back-upcodes';

  @override
  String get chooseVerificationMethod => 'Choose a verification method';

  @override
  String get howWouldYouLikeToVerify =>
      'How would you like to verify it\'s you?';

  @override
  String get useRecoveryCode => 'Use a recovery code';

  @override
  String get enterRecoveryCodeBelow =>
      'Enter one of your single-use recovery codes below.';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get useDifferentVerificationMethod =>
      'Use a different verification method';

  @override
  String weSentACodeToPhone(String phoneNumber) {
    return 'We sent a verification code to $phoneNumber.';
  }

  @override
  String weSentACodeToEmail(String emailAddress) {
    return 'We sent a verification code to $emailAddress.';
  }

  @override
  String get secureYourAccount => 'Secure your account';

  @override
  String get mfaEnrolExplanationEncourage =>
      'Add a second sign-in step to protect your account against stolen passwords. You can set this up now, or skip and do it later.';

  @override
  String get mfaEnrolExplanationEnforce =>
      'A second sign-in step is required to protect your account. Set one up now to continue.';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get confirmYourEmailFirst => 'First, let\'s confirm it\'s you.';

  @override
  String get chooseEnrolmentMethod =>
      'Choose how you want to verify future sign-ins';

  @override
  String get cantScanTheCode =>
      'Can\'t scan the code? Enter this key manually:';

  @override
  String get enterTheSecurityCodeGenerated =>
      'Voer de beveiligingscode in die door de app wordt gegenereerd.';

  @override
  String get enterCode => 'Code invoeren';

  @override
  String get weSentYouAnSms =>
      'We hebben je een sms-verificatiecode gestuurd naar het telefoonnummer dat eindigt op --telefoonnummer--.';

  @override
  String get enterThe6DigitCodeBelow => 'Vul hieronder de 6-cijferige code in';

  @override
  String get verify => 'Controleren';

  @override
  String stepCounter(int current, int total) {
    return 'Stap $current/$total:';
  }

  @override
  String get verifyPhoneStepTitle => 'Telefoon verifiëren\n';

  @override
  String get verifyEmailStepTitle => 'E-mailadres verifiëren';

  @override
  String get didntReceiveTheCode =>
      'Heb je de code niet ontvangen? Het kan een minuut duren voordat het aankomt of';

  @override
  String get resendVerificationCode => 'Verificatiecode opnieuw verzenden';

  @override
  String get codeResent => 'Code opnieuw verzenden!';

  @override
  String get brandnameChargers => '--brandname-- laadpunten';

  @override
  String get publicTariff => 'Publiek Tarief';

  @override
  String get specialCardTariff => 'Speciaal kaarttarief';

  @override
  String get updateBillingInformation => 'Betalingsgegevens bijwerken';

  @override
  String get billingAddressSuccessfullyUpdated =>
      'Factuuradres succesvol bijgewerkt';

  @override
  String get provideYourBillingDetails => 'Geef je factuurgegevens op';

  @override
  String get profileSuccessfullyUpdated => 'Profiel succesvol bijgewerkt';

  @override
  String get updateProfile => 'Profiel bijwerken';

  @override
  String get manageYourPersonalContactInformation =>
      'Beheer je persoonlijke contactgegevens';

  @override
  String get passwordSuccessfullyUpdated => 'Wachtwoord succesvol bijgewerkt';

  @override
  String get updatePassword => 'Wachtwoord bijwerken';

  @override
  String get passwordIsRequired => 'Wachtwoord is vereist';

  @override
  String get updateYourPassword => 'Werk je wachtwoord bij';

  @override
  String get currentPassword => 'Huidig wachtwoord';

  @override
  String get newPassword => 'Nieuw wachtwoord';

  @override
  String get accountSettings => 'Account instellingen';

  @override
  String get enableNotifications => 'Notificaties aanzetten';

  @override
  String get pleaseAllowNotifications =>
      'Sta notificaties toe onder instellingen ';

  @override
  String get sendNotifications => 'Notificaties versturen';

  @override
  String get chargingUpdatesSubtitleIOS =>
      'Push notifications and Live Activities';

  @override
  String get chargingUpdatesSubtitleAndroid =>
      'Push notifications and Ongoing Notifications';

  @override
  String get personalSettings => 'Persoonlijke instellingen';

  @override
  String get notifications => 'Meldingen';

  @override
  String get manageYourNotifications => 'Beheer notificaties voor laadsessies.';

  @override
  String get allNotifications => 'Alle notificaties';

  @override
  String get chargingStartedTitle => 'Laadsessie gestart';

  @override
  String get chargingSessionEndedTitle => 'Laadsessie beëindigd';

  @override
  String get chargingSessionStateOver80Title => '80% opgeladen';

  @override
  String get chargingSessionChargingTitle => 'Laden gestart';

  @override
  String get chargingSessionSuspendedEvTitle => 'Laden gestopt';

  @override
  String get chargingSessionSuspendedEvseTitle =>
      'Het laden is gestopt door de laadpaal.';

  @override
  String get chargingSessionStartedSubtitle =>
      'Notificatie wanneer je laadsessie start.';

  @override
  String get chargingSessionEndedSubtitle =>
      'Notificatie wanneer je laadsessie is gestopt.';

  @override
  String get chargingSessionStateOver80Subtitle =>
      'Notificatie wanneer je auto voor 80% is opgeladen.';

  @override
  String get chargingSessionChargingSubtitle =>
      'Notificatie wanneer de auto begint met laden.';

  @override
  String get chargingSessionSuspendedEvSubtitle =>
      'Notificatie wanneer de auto stopt met laden.';

  @override
  String get chargingSessionSuspendedEvseSubtitle =>
      'Notificatie wanneer laadpaal stopt met laden.';

  @override
  String get chargingSessionLiveUpdateTitle => 'Live Charging Updates';

  @override
  String get chargingSessionLiveUpdateSubtitleIOS =>
      'Show live charging progress on your lock screen and in the Dynamic Island.';

  @override
  String get chargingSessionLiveUpdateSubtitleAndroid =>
      'Show live charging progress as an ongoing notification.';

  @override
  String get wantToAddYourCreditOrDebitCardLater =>
      'Wil je je creditcard of betaalpas later toevoegen?';

  @override
  String get viewYourChargeCards => 'Bekijk je laadpas(sen).';

  @override
  String get viewYourPreviousChargingSessions =>
      'Bekijk je eerdere laadsessies.';

  @override
  String get viewInvoicesForYourChargeCards =>
      'Bekijk facturen voor je laadsessies.';

  @override
  String get viewYourProfileAndAccount => 'Bekijk je profiel en account.';

  @override
  String get payWith => 'Betalen met';

  @override
  String get postCodeIsInvalid => 'Postcode is ongeldig';

  @override
  String get later => 'Later';

  @override
  String get enableLocationServices => 'Locatieservices inschakelen';

  @override
  String get pleaseAllowLocationUpdates =>
      'Sta locatie-updates toe in de app-instellingen.';

  @override
  String get contactUs => 'Neem contact op';

  @override
  String get accountCreatedWelcomeOnBoard =>
      'Je account is aangemaakt. Welkom aan boord!';

  @override
  String get search => 'Zoek';

  @override
  String get lookingForAppleOrGooglePay =>
      'Op zoek naar Apple Pay of Google Pay?';

  @override
  String get skipThisStep => 'Sla deze stap over';

  @override
  String get invalidPhoneNumber => 'Ongeldig telefoonnummer';

  @override
  String get appVersion => 'App versie';

  @override
  String get privacyStatementOneLine => 'Privacyverklaring';

  @override
  String get termsOfServiceOneLine => 'Service voorwaarden';

  @override
  String get aboutUs => 'Over ons';

  @override
  String get about => 'Meer informatie';

  @override
  String get support => 'Support';

  @override
  String get addCreditOrDebitCard => 'Creditcard of betaalpas toevoegen';

  @override
  String get byAddingAPaymentMethod =>
      'Door een betaalmethode toe te voegen kun je een laadsessie starten op elk --merknaam-- station.';

  @override
  String get youWillAddYourPaymentDetails =>
      'In de volgende stap voeg je je betaalgegevens toe.';

  @override
  String get supportedMethods => 'Betaalmethodes die ondersteunt worden';

  @override
  String get payments => 'Betalingen';

  @override
  String get invoices => 'Facturen';

  @override
  String get signupNowToSeeYourChargeCards =>
      'Meldt je aan om laadpas(sen) te bekijken.';

  @override
  String get signupNowToViewChargingSessions =>
      'Meld je nu aan om al je eerdere laadsessies te bekijken.';

  @override
  String get signupNowToViewInvoices =>
      'Meld je nu aan om alle facturen van uw laadpassen te bekijken.';

  @override
  String get alreadyHaveAnAccount => 'Heb je al een account?';

  @override
  String get applePay => 'Apple pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get downloadInvoice => 'Factuur downloaden';

  @override
  String get invoiceDetails => 'Factuurgegevens';

  @override
  String get noInvoiceDataAvailable => 'Geen factuurgegevens beschikbaar.';

  @override
  String get filterByYear => 'Filteren op jaar';

  @override
  String get chargeCardInvoices => 'Facturen voor laadpassen';

  @override
  String get viewAllInvoices => 'Bekijk alle facturen →';

  @override
  String get chooseRoutingApp => 'Kies navigatie app';

  @override
  String get manuallyInputStationId => 'Handmatig invoeren van laadpaal ID';

  @override
  String get inputTheStationIdFromTheSticker =>
      'Voer de laadpaal ID in van de sticker';

  @override
  String get findTheStickerEnterTheDigits =>
      'Zoek de sticker op het laadpunt en vul de cijfercode in.';

  @override
  String get scanStationQrCode => 'Scan de QR-code van het laadpunt';

  @override
  String get useCameraToIdentifyStationId =>
      'Gebruik de camera om je laadpunt-ID te identificeren.';

  @override
  String get qrScannerTorchToggle => 'Toggle torch';

  @override
  String get cameraPermissionRequired => 'Cameratoegang Vereist';

  @override
  String get cameraPermissionMessage =>
      'Cameratoegang is vereist om QR-codes te scannen. Sta cameratoegang toe in de instellingen van je apparaat.';

  @override
  String get cameraPermissionDenied => 'Cameratoegang geweigerd';

  @override
  String get errorAccessingCamera => 'Fout bij het openen van de camera';

  @override
  String get stationId => 'Laadpaal ID';

  @override
  String get example => 'Voorbeeld:';

  @override
  String get input => 'invoer';

  @override
  String get dontHaveAnAccount => 'Heb je geen account?';

  @override
  String get signup => 'Aanmelden';

  @override
  String get youHaventAddedAnyCardsYet =>
      'Je hebt nog geen kaarten toegevoegd.';

  @override
  String get selectPaymentMethod => 'Selecteer betaalmethode';

  @override
  String get chargingInProgress => 'Aan het laden';

  @override
  String get cancelSession => 'Sessie annuleren';

  @override
  String get unableToConnectToServer =>
      'Het is niet mogelijk om een sessie te starten. Probeer het later nog eens.';

  @override
  String get chargeCard => 'Laadpas';

  @override
  String get youAreReadyToGo => 'Klaar om te gaan!';

  @override
  String get noteWeAreStillProcessing =>
      'Let op: de transactie wordt nog verwerkt. Als dit klaar is, kun je de laadsessie in het sessie overzicht bekijken.';

  @override
  String get sessionCompleted => 'Sessie afgerond';

  @override
  String get sessionDetails => 'Sessie details';

  @override
  String get price => 'Prijs';

  @override
  String get inclVat => '(incl. Btw)';

  @override
  String get exclVat => '(excl. Btw)';

  @override
  String get usage => 'Verbruik';

  @override
  String get duration => 'Laadduur';

  @override
  String get startTime => 'Starttijd';

  @override
  String get endTime => 'Eindtijd';

  @override
  String get charged => 'Charged';

  @override
  String get date => 'Date';

  @override
  String get totalCosts => 'Total Costs';

  @override
  String get payment => 'Betaling';

  @override
  String get thereArentAnyStationsNearYourLocations =>
      'Er zijn geen laadpalen in jouw omgeving.';

  @override
  String get sessionStarting => 'Sessie wordt gestart';

  @override
  String get sessionStopping => 'Sessie wordt gestopt';

  @override
  String get sessionEnded => 'Sessie is beeïndigd';

  @override
  String get stationDoesntSupportSessions =>
      'Bij deze laadpaal kun je geen sessie vanuit de app starten. Gebruik de functionaliteit van de laadpaal zelf om een sessie te starten.';

  @override
  String get stationOnlySupportsRfidCards =>
      'Deze laadpaal ondersteunt alleen het starten van een sessie vanuit de app met een RFID laadpas.';

  @override
  String get stationOnlySupportsCreditCards =>
      'Deze laadpaal ondersteunt alleen het starten van een sessie vanuit de app met een creditcard.';

  @override
  String get weLoggedYouInAutomatically => 'Je bent automatisch ingelogd.';

  @override
  String get cannotAddAPaymentMethod =>
      'Er kan geen betaalmethode worden toegevoegd aan dit account.';

  @override
  String get imAllPluggedInToTheEvStation =>
      'Ik ben helemaal aangesloten op het laadstation';

  @override
  String get automaticallyDetectMyConnection =>
      'Detecteer automatisch mijn verbinding';

  @override
  String get findNearbyEvStations => 'Vind laadpalen in de buurt';

  @override
  String get chooseFromAListOfNearbyConnectors =>
      'Kies uit een lijst met beschikbare connectors';

  @override
  String get accountCreated => 'Account is aangemaakt';

  @override
  String get youCanNowStartYourFirstCharge =>
      'Je kunt nu beginnen met je eerste laadsessie';

  @override
  String get youCanNowAddAPaymentMethod =>
      'Je kunt nu een betaalmethode toevoegen en je eerste laadsessie starten';

  @override
  String get countryIsRequired => 'Land is verplicht';

  @override
  String get streetIsRequired => 'Straat is verplicht';

  @override
  String get houseNumberIsRequired => 'Huisnummer is verplicht';

  @override
  String get postCodeIsRequired => 'Postcode is verplicht';

  @override
  String get cityIsRequired => 'Stad is verplicht';

  @override
  String get firstNameRequired => 'Voornaam is verplicht';

  @override
  String get lastNameRequired => 'Achternaam is verplicht';

  @override
  String get emailRequired => 'E-mail is verplicht';

  @override
  String get phoneNumberRequired => 'Telefoonnummer is vereist';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'Gelieve een geldig e-mailadres in te voeren';

  @override
  String get passwordMustContain =>
      'Het wachtwoord moet minimaal 8 tekens bevatten, waarvan één letter, één cijfer en één speciaal teken.';

  @override
  String get acceptTermsAndConditions =>
      'Accepteer eerst de algemene voorwaarden';

  @override
  String get acceptPrivacyStatement => 'Accepteer eerst de privacyverklaring';

  @override
  String get country => 'Land';

  @override
  String get street => 'Straat';

  @override
  String get houseNumberShort => 'Nr.';

  @override
  String get postCode => 'Postcode';

  @override
  String get cityTown => 'Stad/plaats';

  @override
  String get billingDetails => 'Factureringsgegevens';

  @override
  String get billingAddress => 'Facturatie adres';

  @override
  String get iAcceptThe => 'Ik accepteer de';

  @override
  String get termsOfService => 'Service voorwaarden.';

  @override
  String get iUnderstandThat =>
      'Ik begrijp dat --brandname-- mijn persoonlijke gegevens zal verwerken in overeenstemming met de';

  @override
  String get privacyStatement => 'Privacyverklaring.';

  @override
  String get iWantToReceive =>
      'Ik wil nieuwsbrieven ontvangen over mijn laadpas en/of abonnement en geef hierbij toestemming voor de verwerking van mijn persoonsgegevens hiervoor, zoals beschreven in de';

  @override
  String get firstName => 'Voornaam';

  @override
  String get lastName => 'Achternaam';

  @override
  String get phoneNumber => 'Telefoonnummer';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get createYourFreeAccount => 'Maak je gratis account aan';

  @override
  String get blockCard => 'Blokkeer kaart';

  @override
  String get unblockCard => 'Deblokkeer kaart';

  @override
  String get inactive => 'Inactief';

  @override
  String get identifier => 'Identificatie';

  @override
  String get billingPlan => 'Abonnement';

  @override
  String get nameOnCard => 'Naam op kaart';

  @override
  String get card => 'Kaart';

  @override
  String get unknownAddress => 'Onbekend adres';

  @override
  String get removeCard => 'Kaart verwijderen';

  @override
  String get areYouSureYouWantToRemoveCard =>
      'Weet je zeker dat je de kaart wilt verwijderen?';

  @override
  String get areYouSureYouWantToBlockCardFrom =>
      'Weet je zeker dat je de kaart wilt blokkeren?';

  @override
  String get thisActionCannotBeReversed =>
      'Deze actie kan niet worden teruggedraaid. Met deze kaart kun je bij geen enkele laadpaal meer betalen.';

  @override
  String get yesRemoveCard => 'Ja, kaart verwijderen';

  @override
  String get yesBlockCard => 'Ja, blokkeer deze kaart';

  @override
  String get cancel => 'Annuleren';

  @override
  String get editPaymentMethod => 'Betaalmethode bewerken';

  @override
  String get addPaymentMethod => 'Betaalmethode toevoegen';

  @override
  String get creditOrDebitCard => 'Credit- of debetkaart';

  @override
  String get cardNumber => 'Kaartnummer';

  @override
  String get saveCard => 'Kaart opslaan';

  @override
  String get cardVerificationRequired => 'Kaartverificatie vereist';

  @override
  String get clickButton3dSecure =>
      'Nadat je op de knop heeft geklikt, wordt je doorgestuurd naar je betalingsprovider voor 3D Secure-authenticatie.';

  @override
  String get continueToAuthentication => 'Ga verder met authenticatie';

  @override
  String get tdsSecureHelpsPreventFraud =>
      '3D-Secure (3DS) helpt fraude te voorkomen bij het online gebruik van betaalkaarten.';

  @override
  String get cardSaved => 'Kaart opgeslagen';

  @override
  String get cardRemoved => 'Kaart verwijderd';

  @override
  String get cardFailedToSave =>
      'Kaart kan niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get hour => 'uur';

  @override
  String get session => 'sessie';

  @override
  String get hourIdleFee => 'uur blokkeertarief';

  @override
  String get minWaitBeforeIdleFee => 'min. wachttijd voor blokkeertarief';

  @override
  String get name => 'Naam';

  @override
  String get status => 'Status';

  @override
  String get operatorKey => 'Operator';

  @override
  String get availableFacilities => 'Available facilities';

  @override
  String get carpoolParking => 'Carpool Parkeerplaats';

  @override
  String get wifi => 'Wifi';

  @override
  String get noSessionDataAvailable => 'Geen sessie data beschikbaar';

  @override
  String get filterByMonth => 'Filter per maand';

  @override
  String get viewAllSessions => 'Bekijk alle sessies →';

  @override
  String get scheduledTariffNote =>
      'Een gepland tarief overschrijft de basis tariefprijzen voor een specifieke periode.';

  @override
  String get dynamicTariffNote =>
      'Het dynamische tarief is gebaseerd op de actuele energie prijs (1 uur interval).';

  @override
  String get pricing => 'Prijzen';

  @override
  String get baseTariff => 'Basis tarief';

  @override
  String get dynamicTariff => 'Dynamisch tarief';

  @override
  String get activeNow => 'NU ACTIEF';

  @override
  String get viewAllHourlyPrices => 'Bekijk alle uur tarieven';

  @override
  String get hourlyPrices => 'Uur Tarieven';

  @override
  String get tariffNotes => 'Tariefinformatie';

  @override
  String get viewTariffNotes => 'Bekijk Tariefinformatie';

  @override
  String get active => 'Actief';

  @override
  String get noConnectorDataAvailable => 'Geen connector data beschikbaar';

  @override
  String get hotel => 'Hotel';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get cafe => 'Café';

  @override
  String get mall => 'Winkelcentrum';

  @override
  String get supermarket => 'Supermarkt';

  @override
  String get sport => 'Sport';

  @override
  String get recreationArea => 'Recreatiegebied';

  @override
  String get nature => 'Natuur';

  @override
  String get museum => 'Museum';

  @override
  String get bikeSharing => 'Delen van een fiets';

  @override
  String get busStop => 'Bus stop';

  @override
  String get taxiStand => 'Taxi plaats';

  @override
  String get tramStop => 'Tram stop';

  @override
  String get metroStation => 'Metro station';

  @override
  String get trainStation => 'Treinstation';

  @override
  String get airport => 'Vliegveld';

  @override
  String get notAvailable => 'Niet beschikbaar';

  @override
  String get available => 'Beschikbaar';

  @override
  String get unavailable => 'Niet beschikbaar';

  @override
  String get alongMotorway => 'Langs snelweg';

  @override
  String get parkingGarage => 'Parkeergarage';

  @override
  String get parkingLot => 'Parkeerplaats';

  @override
  String get onDriveway => 'Op oprit';

  @override
  String get onStreet => 'Op straat';

  @override
  String get undergroundGarage => 'Ondergrondse garage';

  @override
  String get fuelStation => 'Tankstation';

  @override
  String inaccurateTariffWarning(String appName) {
    return 'De hier getoonde tarieven zijn door de roamingpartner naar $appName gestuurd. De nauwkeurigheid kan afwijken, afhankelijk van de provider.';
  }

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      'Er is een fout opgetreden. Probeer het aub nog een keer later.';

  @override
  String hAndMin(num hours, num minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}u ${minutes}min';
  }

  @override
  String get lessThanAMinute => 'minder dan 1 minuut';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dagen',
      one: '1 dag',
      zero: '0 dagen',
    );
    return '$_temp0';
  }

  @override
  String nHours(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString uren',
      one: '1 uur',
      zero: '0 uren',
    );
    return '$_temp0';
  }

  @override
  String nMinutes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString minuten',
      one: '1 minuut',
      zero: '0 minuten',
    );
    return '$_temp0';
  }

  @override
  String get noTariffAvailable => 'Geen tarief beschikbaar';

  @override
  String get unknownKW => 'onbekend aantal kW';

  @override
  String get cardDetailsUnavailable => 'Card details onbeschikbaar';

  @override
  String get ok => 'OK';

  @override
  String get somethingWentWrong => 'Er is een fout opgetreden: ';

  @override
  String get appUpdateRequiredError =>
      'This version of the app is no longer supported. Please update it from the app store and try again.';

  @override
  String get mfaCodeExhausted =>
      'That code is no longer valid. Please request a new one.';

  @override
  String get mfaSetupIntro =>
      'Add a second step to protect your account when signing in. You can also do this later.';

  @override
  String get mfaSetupAuthenticatorTitle => 'Authenticator app';

  @override
  String get mfaSetupSmsTitle => 'Text message (SMS)';

  @override
  String get mfaSetupNotSetUp => 'Not set up';

  @override
  String get mfaSetupSetUp => 'Set up';

  @override
  String get mfaSetupEnabled => 'Enabled';

  @override
  String get mfaSetupBack => 'Back';

  @override
  String get securityScreenIntro => 'Manage how you sign in to your account.';

  @override
  String mfaActivatedOn(String date) {
    return 'Activated on $date';
  }

  @override
  String get mfaNotAvailableByPolicy => 'Not available by administrator policy';

  @override
  String get mfaBackupCodesTitle => 'Backup codes';

  @override
  String get mfaRecoveryEmailTitle => 'Recovery email';

  @override
  String mfaCodesLeft(int count) {
    return '$count codes left';
  }

  @override
  String mfaRemoveMethodConfirm(String method) {
    return 'Are you sure you want to remove $method?';
  }

  @override
  String get mfaRemoveOnlyFactorWarning =>
      'This is your only second sign-in step. If you remove it, you\'ll be asked to set one up again the next time you sign in.';

  @override
  String get mfaGenerateCodes => 'Generate';

  @override
  String get mfaRegenerateCodes => 'Regenerate';

  @override
  String get mfaRegenerateCodesWarning =>
      'Generate a new set of backup codes? Your old codes will stop working immediately.';

  @override
  String get mfaAddRecoveryEmail => 'Add a recovery email';

  @override
  String get mfaRecoveryEmailExplanation =>
      'If you ever can\'t sign in, we can send a verification code to this address to get you back into your account. It must be different from your account email address.';

  @override
  String get mfaRecoveryEmailSameAsAccount =>
      'Your recovery email must be different from your account email address.';

  @override
  String get shareCodes => 'Share Codes';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get remove => 'Remove';

  @override
  String get change => 'Change';

  @override
  String get done => 'Done';

  @override
  String get sendCode => 'Code verzenden';

  @override
  String mfaTooManyAttemptsWait(String wait) {
    return 'Too many attempts. Try again in $wait.';
  }

  @override
  String mfaResendWaitCountdown(String wait) {
    return 'Resend available in $wait';
  }

  @override
  String get stepUpTitle => 'Confirm it\'s you';

  @override
  String get stepUpPickMethodIntro =>
      'For your security, verify with your second sign-in step to continue.';

  @override
  String get stepUpAuthenticatorPrompt =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String get stepUpPasskeyOnly =>
      'Your second sign-in step is a passkey, which this app can\'t verify yet. Please use the web portal to make this change.';

  @override
  String get error => 'Error';

  @override
  String get sessionExpiredTitle => 'Session expired';

  @override
  String get sessionExpiredMessage =>
      'Your session has expired. Please log in again.';

  @override
  String get signInExpiringMessage =>
      'Your sign-in is expiring soon. Please sign in again to continue.';

  @override
  String get biometricPromptReason =>
      'Verify it\'s you to keep your session active';

  @override
  String get youreAllReadyToBegin => 'Je bent klaar om te laden!';

  @override
  String get startYouFirstEVCharge => 'Start je eerste EV laadsessie';

  @override
  String get locationServicesAreDisabled =>
      'Locatie diensten zijn niet aangezet. Open aub settings om locatie diensten aan te zetten.';

  @override
  String get skip => 'Skip →';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationPermissionsHaveBeenDenied =>
      'Locatie permissies staan uit voor deze app. Deze app werkt supoptimaal zonder locatie permissies. Open aub settings om locatie permissies toe te staan.';

  @override
  String get continueStr => 'Volgende';

  @override
  String get byAllowingLocationServices =>
      'Met locatie diensten kunnen we bepalen welke laadpunten bij jou in de buurt zijn.';

  @override
  String get findAllAvailableChargeStationsNearby =>
      'Vind alle beschikbare laadpalen in de buurt';

  @override
  String get getStarted => 'Begin';

  @override
  String get letsGetYouStarted =>
      'Laten we beginnen met de makkelijkste en snelste laad app.';

  @override
  String get eVWallet => 'EV Wallet';

  @override
  String get signupForAnAccount => 'Registreer voor een account';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get password => 'Wachtwoord';

  @override
  String get eMail => 'E-mail';

  @override
  String get priceUnknown => 'Onbekende prijs';

  @override
  String get youHaventChargedYourEVYet => 'Je hebt je EV nog niet opgeladen.';

  @override
  String get cardRfid => 'Kaart (RFID)';

  @override
  String get youDontHaveAnyPaymentMethodsYet =>
      'Je hebt nog geen betaalmethodes.';

  @override
  String get sessions => 'Sessies';

  @override
  String get paymentMethods => 'Betaalmethodes';

  @override
  String get paymentsAndSessions => 'Betalingen en laadsessies';

  @override
  String get wallet => 'Wallet';

  @override
  String get locationServicesHaveBeenDisabledForThisApp =>
      'Locatie diensten zijn niet aangezet. Open aub settings om locatie diensten aan te zetten.';

  @override
  String get locationPermissionGranted => 'Location permission granted';

  @override
  String
  get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings =>
      'Locatie permissies staan uit voor deze app. Open aub settings om locatie permissies toe te staan.';

  @override
  String get requestPermission => 'Vraag permissies';

  @override
  String get grantLocationPermissionToUseThisFeature =>
      'Sta locatie permissies toe voor deze functionaliteit';

  @override
  String get initialisingLocationService =>
      'Intialiseren van locatie diensten...';

  @override
  String get findEVChargingLocations => 'EV laadpunten';

  @override
  String get exploreStations => 'Vind laadpalen';

  @override
  String get viewWallet => 'Bekijk wallet';

  @override
  String get startAChargeSession => 'Start laadsessie';

  @override
  String get charging => 'Charging';

  @override
  String get clickTheButtonBelow => 'Klik de knop hieronder';

  @override
  String get startYourEVCharge => 'Start\nEV laden';

  @override
  String get searchLocation => 'Zoek Locatie';

  @override
  String get getDirections => 'Bekijk routebeschrijving';

  @override
  String get shareLocation => 'Share location';

  @override
  String get streetView => 'Street View';

  @override
  String get pressToView => 'Press to view';

  @override
  String get streetViewNotAvailable =>
      'Street View is not available for this location';

  @override
  String get locationPictures => 'Photos';

  @override
  String locationPictureCounter(int index, int total) {
    return '$index / $total';
  }

  @override
  String get locationPictureCouldNotLoad => 'Photo could not be loaded';

  @override
  String get chargeNow => 'Charge Now';

  @override
  String get trySearchingForAnotherLocation => 'Zoek voor een andere locatie →';

  @override
  String get noChargeStationsFound => 'Geen laadpunten gevonden';

  @override
  String get myCurrentPosition => 'Mijn huidige positie';

  @override
  String get useMyCurrentPosition => 'Gebruik mijn huidige positie';

  @override
  String get searchAddressOrPlaceName => 'Zoek adres of plaatsnaam';

  @override
  String get clearFilters => 'Filters wissen';

  @override
  String get connectorType => 'Connector Type';

  @override
  String get chargingPowerkW => 'Power [kW]';

  @override
  String get chargers => 'Laadpunten';

  @override
  String get dCChargers => 'Snelladers';

  @override
  String get availableChargers => 'Beschikbare laadpunten';

  @override
  String get onlyShow => 'Bekijk Alleen';

  @override
  String get filters => 'Filters';

  @override
  String get findMoreStationsNearby => 'Vind meer laadpunten in de buurt →';

  @override
  String get findStationsNearby => 'Vind laadpalen in de buurt →';

  @override
  String get highwayModeAvailableWhileDriving =>
      'Highway modus is beschikbaar wanneer je buiten de bebouwde kom rijdt.';

  @override
  String get youCanAlwaysFindNearbyStations =>
      'Bekijk onze kaart om laadpalen in de buurt vinden.';

  @override
  String get nearbyStations => 'Laders in de buurt';

  @override
  String get selectYourChargeStation => 'Selecteer laadpunt';

  @override
  String get paymentMethod => 'Betaalmethode';

  @override
  String get unnamedCard => 'ongenoemde kaart';

  @override
  String get noCardsAvailable => 'Geen kaarten beschikbaar';

  @override
  String get startSession => 'Start sessie';

  @override
  String get unknownEVSEID => 'Onbekende EVSE ID';

  @override
  String get startChargingSession => 'Start laadsessie';

  @override
  String get exploreOrSearchForALocation => 'Zoek een laadpaal →';

  @override
  String get thereArentAnyStationsNearYou =>
      'Er zijn geen laadpunten in de buurt van jouw locatie.\n\nDe automatische zoekfunctie is nog bezig en zal laadpunten tonen wanneer je er in de buurt komt.';

  @override
  String get noStationsFound => 'Geen stations gevonden.';

  @override
  String get selectStation => 'Selecteer laadpunt';

  @override
  String get evseId => 'EVSE ID';

  @override
  String get manualStationInput => 'Manueel Station Invoer';

  @override
  String get manualEVSEIDInput => 'Manueel EVSE ID invoer →';

  @override
  String get noSelectDifferentStation => 'Nee, selecteer ander laadpunt →';

  @override
  String get yesThisIsMe => 'Ja dit ben ik!';

  @override
  String get isThisYou => 'Ben jij dit?';

  @override
  String get imAllPluggedIn => 'I\'m all plugged in!';

  @override
  String get close => 'Sluit';

  @override
  String get endSession => 'Sessie beëindigen';

  @override
  String get yourCarIsCharging => 'Je auto wordt opgeladen';

  @override
  String get unknownKWh => 'onbekende kWh';

  @override
  String get profile => 'Profiel';

  @override
  String get account => 'Account';

  @override
  String get login => 'Login';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get cancelSubscription => 'Abonnement annuleren';

  @override
  String get removeAccount => 'Verwijder account';

  @override
  String get logout => 'Uitloggen';

  @override
  String get directPayments => 'Directe betalingen';

  @override
  String get chargingCardOrTag => 'Laadpas of tag';

  @override
  String get withoutAdditionalFeePerSession => 'Zonder extra kosten per sessie';

  @override
  String get supportsRemoteCharge => 'Laden via app mogelijk';

  @override
  String get additionalFee => 'Extra kosten';

  @override
  String get favouriteStations => 'Favoriete laadpalen';

  @override
  String get compassDirectionNorth => 'N';

  @override
  String get compassDirectionNorthEast => 'NE';

  @override
  String get compassDirectionEast => 'E';

  @override
  String get compassDirectionSouthEast => 'SE';

  @override
  String get compassDirectionSouth => 'S';

  @override
  String get compassDirectionSouthWest => 'SW';

  @override
  String get compassDirectionWest => 'W';

  @override
  String get compassDirectionNorthWest => 'NW';

  @override
  String get totalSessions => 'Totaal aantal sessies';

  @override
  String get totalEnergy => 'Totale energie';

  @override
  String get totalTime => 'Totale tijd';

  @override
  String get totalCost => 'Totale kosten';

  @override
  String get costTooltipText =>
      'Let op: de hier getoonde kosten zijn een schatting en exclusief eventuele extra toeslagen. De volledige kosten staan op jouw factuur.';

  @override
  String get selectOption => 'Selecteer optie';

  @override
  String get carScreenFastChargersAhead => 'Snelladers op de route';

  @override
  String get carScreenHighway => 'Highway mode';

  @override
  String get carScreenHighwayAuto => 'Highway Auto';

  @override
  String get carScreenHighwayOff => 'Highway Off';

  @override
  String get carScreenHighwayOn => 'Highway mode: On';

  @override
  String get carScreenNavigate => 'Navigeren';

  @override
  String get carScreenShowDetails => 'Toon details';

  @override
  String carScreenFiltersCount(int count) {
    return 'Filters ($count)';
  }

  @override
  String get carScreenFilterOn => 'Aan';

  @override
  String get carScreenFilterOff => 'Uit';

  @override
  String get carScreenSearchingStations =>
      'Searching for nearby charging stations…';

  @override
  String get carScreenNoStationsFound => 'No charging stations found nearby';

  @override
  String get carScreenNavigationNotAvailable => 'Navigatie niet beschikbaar';

  @override
  String get carScreenNavigationError => 'Navigatie foutmelding';

  @override
  String get carScreenNavigateOnPhone => 'Navigeer op telefoon';

  @override
  String get carScreenNoFiltersAvailable => 'Geen filters beschikbaar';

  @override
  String carScreenAvailabilityCount(int available, int total) {
    return '$available/$total beschikbaar';
  }

  @override
  String carScreenPricePerKwh(String price) {
    return '$price/kWh';
  }

  @override
  String get carScreenTabMap => 'Kaart';

  @override
  String get carScreenTabFilters => 'Filters';

  @override
  String get carScreenTabFavourites => 'Favorieten';

  @override
  String get carScreenNoFavourites => 'Nog geen favoriete laadpunten';

  @override
  String get carScreenLoginToSaveFavourites =>
      'Log in om jouw favoriete laadpunten op te slaan';

  @override
  String get carScreenSave => '🤍 Opslaan';

  @override
  String get carScreenSaved => '❤️ Opgeslagen';

  @override
  String get carScreenChargingPower => 'Laadvermogen';

  @override
  String get carScreenAll => 'All';

  @override
  String get carScreenPowerSlow => 'Slow (3+ kW)';

  @override
  String get carScreenPowerFast => 'Fast (23+ kW)';

  @override
  String get carScreenPowerRapid => 'Rapid (100+ kW)';

  @override
  String get carScreenPowerUltra => 'Ultra (200+ kW)';

  @override
  String carScreenCountSelected(int count) {
    return '$count geselecteerd';
  }

  @override
  String get selectNetworks => 'Alleen geselecteerde laadnetwerken';

  @override
  String get excludeNetworks => 'Laadnetwerken uitsluiten';

  @override
  String get selectNetworksToInclude => 'Select networks to include';

  @override
  String get selectNetworksToExclude => 'Select networks to exclude';

  @override
  String get searchNetworks => 'Search networks';

  @override
  String get couldNotLoadNetworks => 'Couldn\'t load networks';

  @override
  String get noNetworksFound => 'No networks found';

  @override
  String get addANetwork => '+ Add a network';

  @override
  String get reportProblemEntryStation => 'Having issues with this station?';

  @override
  String get reportProblemEntrySession => 'Had an issue with your session?';

  @override
  String get reportProblemEntrySessionEnded =>
      'Had an issue during your session?';

  @override
  String get reportProblemEntryCta => 'Report it here';

  @override
  String get reportProblemTitle => 'Report a Problem';

  @override
  String get reportProblemFieldConnector => 'Connector';

  @override
  String get reportProblemFieldCategory => 'Problem Type';

  @override
  String get reportProblemFieldDescription => 'Description';

  @override
  String get reportProblemDescriptionPlaceholder => 'Describe the problem';

  @override
  String get reportProblemSubmit => 'Submit Report';

  @override
  String get reportProblemSuccess =>
      'Report submitted. Thanks for helping out.';

  @override
  String get reportProblemCategoryChargerNotAvailable =>
      'Charger is not available';

  @override
  String get reportProblemCategoryChargerDamaged => 'Charger is damaged';

  @override
  String get reportProblemCategoryChargerHardToFind =>
      'Charger is hard to find';

  @override
  String get reportProblemCategoryWrongConnectorSpeed =>
      'Wrong connector speed';

  @override
  String get reportProblemCategoryWrongConnectorType => 'Wrong connector type';

  @override
  String get reportProblemCategoryMissingPriceInformation =>
      'Missing price information';

  @override
  String get reportProblemCategoryMissingPowerInformation =>
      'Missing power information';

  @override
  String get reportProblemCategoryChargingSessionInterrupted =>
      'Charging session interrupted';

  @override
  String get reportProblemCategoryChargingSessionNotStarted =>
      'Charging session did not start';

  @override
  String get reportProblemCategoryOther => 'Other';

  @override
  String get stepUpPasskeyPrompt => 'Use your passkey to confirm it\'s you.';

  @override
  String get stepUpPasskeyNoCredential =>
      'No passkey for this account was found on this device. Please use the web portal to make this change.';

  @override
  String get passkeyAuthentication => 'Passkey';

  @override
  String get passkeySignInWithDevice =>
      'Verify with your fingerprint, face or screen lock';

  @override
  String get mfaPasskeyTitle => 'Verify with your passkey';

  @override
  String get mfaPasskeyExplanation =>
      'Confirm it\'s you using your fingerprint, face or screen lock.';

  @override
  String get mfaPasskeyButton => 'Use passkey';

  @override
  String get mfaPasskeyNoCredential =>
      'No passkey for this account was found on this device. Please sign in on the web to use another method.';

  @override
  String get mfaEnrolPasskeyTitle => 'Create a passkey';

  @override
  String get mfaEnrolPasskeyExplanation =>
      'Sign in quickly and securely using your fingerprint, face or screen lock instead of a code.';

  @override
  String get mfaEnrolPasskeyButton => 'Create passkey';

  @override
  String get mfaPasskeyAlreadyOnDevice =>
      'This device already has a passkey for this account. You can use it to sign in, or pick another verification method.';

  @override
  String get signInWithAPasskey => 'Sign in with a passkey';

  @override
  String get passkeyLoginNoCredential =>
      'No passkey was found on this device. Please sign in with your email and password.';

  @override
  String get mfaPasskeysTitle => 'Passkeys';

  @override
  String mfaPasskeysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passkeys',
      one: '1 passkey',
    );
    return '$_temp0';
  }

  @override
  String get mfaPasskeysIntro =>
      'Passkeys let you sign in with your fingerprint, face or screen lock instead of a password. You can add more than one.';

  @override
  String get mfaPasskeysDisallowed =>
      'Your administrator no longer allows passkeys for sign-in. You can remove existing passkeys, but new ones can\'t be added.';

  @override
  String get mfaPasskeysUnsupportedDevice =>
      'Passkeys can\'t be added on this device.';

  @override
  String get mfaAddPasskey => 'Add a passkey';

  @override
  String mfaPasskeyAddedOn(String date) {
    return 'Added on $date';
  }

  @override
  String mfaPasskeyLastUsedOn(String date) {
    return 'Last used $date';
  }

  @override
  String get mfaPasskeyRenameTitle => 'Rename passkey';

  @override
  String get mfaPasskeyNameHelp =>
      'Give this passkey a name so you can recognise it later.';

  @override
  String get mfaPasskeyNamePlaceholder => 'e.g. Work laptop';

  @override
  String get rename => 'Rename';

  @override
  String get save => 'Save';

  @override
  String get mfaPasskeyVerificationFailed =>
      'Passkey verification failed. Please try again.';

  @override
  String get mfaPasskeyChallengeMissing =>
      'Passkey verification could not be started. Please try again.';

  @override
  String get mfaPasskeyCreateFailed =>
      'Could not create a passkey on this device.';
}
