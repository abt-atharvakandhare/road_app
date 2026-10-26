// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get highwayMode => 'Highway Mode';

  @override
  String get stopAtNearestFastChargingStation =>
      'Halte an der nächstgelegenen Schnellladestation';

  @override
  String get emailAddressSuccessfullyVerified =>
      'E-Mail-Adresse erfolgreich bestätigt!';

  @override
  String get phoneNumberSuccessfullyVerified =>
      'Telefonnummer erfolgreich bestätigt!';

  @override
  String get pleaseVerifyYourPhoneNumberAndEmail =>
      'Bitte bestätige deine Telefonnummer und E-Mail.';

  @override
  String get verifyYourPhoneNumberNow => 'Bestätige jetzt deine Telefonnummer.';

  @override
  String get verifyYourEmailNow => 'Bestätige jetzt deine E-Mail';

  @override
  String get verifyYourEmailAddress => 'Bestätige deine E-Mail-Adresse';

  @override
  String weSentYouAnEmailVerification(String emailAddress) {
    return 'Wir haben dir eine E-Mail an $emailAddress geschickt';
  }

  @override
  String get openMailApp => 'Mail-App öffnen';

  @override
  String get pleaseConfirmYourEmailAddressByClicking =>
      'Bitte bestätige deine E-Mail-Adresse, indem du auf den Link in der E-Mail klickst, die wir dir geschickt haben.';

  @override
  String get didntReceiveTheEmail =>
      'Keine E-Mail bekommen? Schau mal in deinen Spam-Ordner oder';

  @override
  String get resendEmailVerificationLink => 'Bestätigungslink erneut senden';

  @override
  String get verified => 'Bestätigt';

  @override
  String get stationAddedToYourFavourites =>
      'Station zu Favoriten hinzugefügt.';

  @override
  String get removedFromYourFavourites => 'Aus Favoriten entfernt.';

  @override
  String get yourFavouriteStationsWillShowUpHere =>
      'Hier werden Ihre favorisierten Stationen mit Echtzeit-Verfügbarkeit angezeigt.\n\n';

  @override
  String get markStationsAsFavouriteByPressingTheHeartIcon =>
      'Markiere Stationen als Favoriten, indem du auf das Herz-Symbol tippst.';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get removeFromFavourites => 'Remove from favourites';

  @override
  String get exploreMap => 'Karte entdecken';

  @override
  String get nearestStations => 'Nearest Stations';

  @override
  String get fastStationsWithPower => 'Fast stations (>50 kW)';

  @override
  String onRoad(String road) {
    return 'on $road';
  }

  @override
  String get noNearbyStations => 'No Nearby Stations';

  @override
  String get noChargingStationsFoundNearby =>
      'No charging stations found nearby';

  @override
  String get accountRemovalIsPending =>
      'Die Löschung des Kontos ist ausstehend.';

  @override
  String get areYouSureYouWantToRemoveYourAccount =>
      'Bist du sicher, dass du dein Konto löschen willst?';

  @override
  String get thisActionIsPermanent =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get yesRemoveAccount => 'Ja, Konto löschen';

  @override
  String weSentYouAndSmsFullNumber(String phoneNumber) {
    return 'Wir haben Ihnen eine SMS an $phoneNumber gesendet.';
  }

  @override
  String get saveRecoveryCodes => 'Wiederherstellungscodes speichern';

  @override
  String get recoveryCodesCanBeUsed =>
      'Wiederherstellungscodes können verwendet werden, um auf Ihr Konto zuzugreifen, falls Sie keinen Zugriff mehr auf Ihr Gerät haben und keine Zwei-Faktor-Authentifizierungscodes empfangen können';

  @override
  String get downloadCodes => 'Codes herunterladen.';

  @override
  String get copyCodes => 'Codes Kopieren';

  @override
  String get iSavedMyBackupCodes => 'Ich habe meine Backup-Codes gespeichert.';

  @override
  String get putTheseInASafeSpot =>
      'Leg die Codes an einen sicheren Ort. Wenn du dein Gerät verlierst und keine Wiederherstellungscodes hast, kannst du nicht mehr auf dein Konto zugreifen.';

  @override
  String get or => 'Oder';

  @override
  String get oneDownloadAnAuthenticatorApp => 'Hol dir eine Authenticator-App';

  @override
  String get weRecommendGoogleAuthenticator =>
      'Wir empfehlen: - Auth-Option - -Auth-Option 2 Oder Auth-Option 3';

  @override
  String get googleAuthenticator => 'Google Authenticator';

  @override
  String get onePassword => '1Password\n';

  @override
  String get authy => 'Authy';

  @override
  String get twoScanTheQrCode =>
      'Scannen Sie den QR-Code mit Ihrer Authenticator-App.';

  @override
  String get threeEnterTheCode =>
      '3. Geben Sie den von der App generierten Sicherheitscode ein.';

  @override
  String get appAuthentication => 'App-Authentifizierung';

  @override
  String get securityCodesGeneratedByApp =>
      'Ihre bevorzugte Authenticator-App generiert die Sicherheitscodes.';

  @override
  String get smsAuthentication => 'SMS-Authentifizierung';

  @override
  String get securityCodesSentViaSms =>
      'Sicherheitscodes werden per SMS an Ihr Mobilgerät gesendet';

  @override
  String get passwordAndAuthentication => 'Passwort & Authentifizierung';

  @override
  String get dontHaveYourBackupCodes =>
      'Haben Sie Ihre Backup-Codes nicht mehr?';

  @override
  String get contactSupportAt => 'Kontaktiere den Support unter';

  @override
  String get toStartAManualVerificationProcess =>
      'um einen manuellen Verifizierungsprozess zu starten';

  @override
  String get pleaseEnterBackupCode =>
      'Bitte geben Sie einen Ihrer ungenutzten Backup-Verifizierungscodes ein';

  @override
  String get backupVerificationCode => 'Backup-Code';

  @override
  String get codeEnteredIsIncorrect =>
      'Der eingegebene Code ist falsch. Bitte versuchen Sie es erneut oder fordern Sie einen neuen Code an.';

  @override
  String get isThisAuthMethodNotWorking =>
      'Funktioniert diese Authentifizierungsmethode nicht?';

  @override
  String get useYourBackupCodes => 'Nutzen Sie Ihre Backup-Codes.';

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
      'Geben Sie den von der App generierten Sicherheitscode ein.';

  @override
  String get enterCode => 'Code eingeben.';

  @override
  String get weSentYouAnSms =>
      'Wir haben Ihnen einen SMS-Verifizierungscode an die Telefonnummer gesendet, die auf --Rufnummernende-- endet.';

  @override
  String get enterThe6DigitCodeBelow =>
      'Geben Sie den 6-stelligen Code unten ein.';

  @override
  String get verify => 'Verifizieren';

  @override
  String stepCounter(int current, int total) {
    return 'Schritt $current/$total:';
  }

  @override
  String get verifyPhoneStepTitle => 'Telefonnummer verifizieren';

  @override
  String get verifyEmailStepTitle => 'E-Mail bestätigen';

  @override
  String get didntReceiveTheCode =>
      'Code nicht erhalten?\nEs kann eine Minute dauern, bis er ankommt, oder...';

  @override
  String get resendVerificationCode => 'Code erneut senden';

  @override
  String get codeResent => 'Code erneut gesendet!';

  @override
  String get brandnameChargers => '--brandname-- Ladestationen';

  @override
  String get publicTariff => 'Öffentlicher Tarif';

  @override
  String get specialCardTariff => 'Spezieller Kartentarif';

  @override
  String get updateBillingInformation => 'Zahlungsinformationen aktualisieren';

  @override
  String get billingAddressSuccessfullyUpdated =>
      'Rechnungsadresse erfolgreich aktualisiert';

  @override
  String get provideYourBillingDetails => 'Geben Sie Ihre Rechnungsdaten an';

  @override
  String get profileSuccessfullyUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get updateProfile => 'Profil aktualisieren';

  @override
  String get manageYourPersonalContactInformation =>
      'Verwalten Sie Ihre persönlichen Kontaktinformationen';

  @override
  String get passwordSuccessfullyUpdated => 'Passwort erfolgreich aktualisiert';

  @override
  String get updatePassword => 'Passwort aktualisieren';

  @override
  String get passwordIsRequired => 'Kennwort ist erforderlich';

  @override
  String get updateYourPassword => 'Aktualisieren Sie Ihr Passwort';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get pleaseAllowNotifications =>
      'Bitte erlauben Sie Benachrichtigungen in den App-Einstellungen.';

  @override
  String get sendNotifications => 'Benachrichtigungen senden';

  @override
  String get chargingUpdatesSubtitleIOS =>
      'Push notifications and Live Activities';

  @override
  String get chargingUpdatesSubtitleAndroid =>
      'Push notifications and Ongoing Notifications';

  @override
  String get personalSettings => 'Persönliche Einstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get manageYourNotifications =>
      'Verwalten Sie Ihre Benachrichtigungen für Ladesitzungen.';

  @override
  String get allNotifications => 'Alle Benachrichtigungen';

  @override
  String get chargingStartedTitle => 'Ladevorgang gestartet';

  @override
  String get chargingSessionEndedTitle => 'Ladevorgang beendet';

  @override
  String get chargingSessionStateOver80Title => 'Ladung bei 80%';

  @override
  String get chargingSessionChargingTitle => 'Laden gestartet';

  @override
  String get chargingSessionSuspendedEvTitle => 'Laden beendet';

  @override
  String get chargingSessionSuspendedEvseTitle =>
      'Laden wurde von der Station gestoppt';

  @override
  String get chargingSessionStartedSubtitle =>
      'Benachrichtigung, sobald Ihr Ladevorgang beginnt.';

  @override
  String get chargingSessionEndedSubtitle =>
      'Benachrichtigung, wenn Ihr Ladevorgang endet.';

  @override
  String get chargingSessionStateOver80Subtitle =>
      'Benachrichtigung, sobald Ihr Auto 80% Ladung erreicht.';

  @override
  String get chargingSessionChargingSubtitle =>
      'Benachrichtigung, wenn Ihr Auto mit dem Laden beginnt.';

  @override
  String get chargingSessionSuspendedEvSubtitle =>
      'Benachrichtigung, sobald Ihr Auto nicht mehr lädt.';

  @override
  String get chargingSessionSuspendedEvseSubtitle =>
      'Benachrichtigung, wenn die Station das Laden beendet.';

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
      'Möchten Sie Ihre Kredit- oder Debitkarte später hinzufügen?';

  @override
  String get viewYourChargeCards => 'Ihre Ladekarten anzeigen.';

  @override
  String get viewYourPreviousChargingSessions =>
      'Ihre früheren Ladesitzungen anzeigen.';

  @override
  String get viewInvoicesForYourChargeCards =>
      'Ihre Rechnungen für Ladekarten einsehen.';

  @override
  String get viewYourProfileAndAccount => 'Ihr Profil & Konto anzeigen.';

  @override
  String get payWith => 'Bezahlen mit';

  @override
  String get postCodeIsInvalid => 'Postleitzahl ist ungültig';

  @override
  String get later => 'Später';

  @override
  String get enableLocationServices => 'Standortdienste aktivieren';

  @override
  String get pleaseAllowLocationUpdates =>
      'Bitte erlauben Sie Standortaktualisierungen in den App-Einstellungen.';

  @override
  String get contactUs => 'Kontakt aufnehmen';

  @override
  String get accountCreatedWelcomeOnBoard =>
      'Konto erstellt. Willkommen an Bord!';

  @override
  String get search => 'Suchen';

  @override
  String get lookingForAppleOrGooglePay =>
      'Auf der Suche nach Apple Pay oder Google Pay?';

  @override
  String get skipThisStep => 'Diesen Schritt überspringen';

  @override
  String get invalidPhoneNumber => 'Ungültige Telefonnummer';

  @override
  String get appVersion => 'App-Version';

  @override
  String get privacyStatementOneLine => 'Datenschutzerklärung';

  @override
  String get termsOfServiceOneLine => 'Nutzungsbedingungen';

  @override
  String get aboutUs => 'Über uns';

  @override
  String get about => 'Weitere Informationen';

  @override
  String get support => 'Support';

  @override
  String get addCreditOrDebitCard => 'Kredit- oder Debitkarte hinzufügen';

  @override
  String get byAddingAPaymentMethod =>
      'Durch Hinzufügen einer Zahlungsmethode können Sie eine Ladesitzung an jeder --brandname-- Ladestation starten.';

  @override
  String get youWillAddYourPaymentDetails =>
      'Im nächsten Schritt geben Sie Ihre Zahlungsinformationen an.';

  @override
  String get supportedMethods => 'Unterstützte Methoden';

  @override
  String get payments => 'Zahlungen';

  @override
  String get invoices => 'Rechnungen';

  @override
  String get signupNowToSeeYourChargeCards =>
      'Melden Sie sich jetzt an, um Ihre Ladekarten zu sehen.';

  @override
  String get signupNowToViewChargingSessions =>
      'Jetzt anmelden, um alle Ihre bisherigen Ladesitzungen einzusehen.';

  @override
  String get signupNowToViewInvoices =>
      'Jetzt anmelden, um alle Rechnungen für Ihre Ladekarten einzusehen.';

  @override
  String get alreadyHaveAnAccount => 'Sie haben bereits ein Konto?';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get downloadInvoice => 'Rechnung herunterladen';

  @override
  String get invoiceDetails => 'Rechnungsdetails';

  @override
  String get noInvoiceDataAvailable => 'Keine Rechnungsdaten verfügbar.';

  @override
  String get filterByYear => 'Nach Jahr filtern';

  @override
  String get chargeCardInvoices => 'Ladekarten-Rechnungen';

  @override
  String get viewAllInvoices => 'Alle Rechnungen anzeigen →';

  @override
  String get chooseRoutingApp => 'Routing-App auswählen';

  @override
  String get manuallyInputStationId => 'Manuelle Eingabe der Ladestations-ID';

  @override
  String get inputTheStationIdFromTheSticker =>
      'Eingabe der Ladestations-ID vom Aufkleber.';

  @override
  String get findTheStickerEnterTheDigits =>
      'Suchen Sie den Aufkleber an der Ladestation und geben Sie die Ziffernkennung ein.';

  @override
  String get scanStationQrCode => 'QR-Code der Scanstation';

  @override
  String get useCameraToIdentifyStationId =>
      'Verwenden Sie die Kamera, um Ihre Sender-ID zu identifizieren';

  @override
  String get qrScannerTorchToggle => 'Toggle torch';

  @override
  String get cameraPermissionRequired => 'Kameraerlaubnis erforderlich';

  @override
  String get cameraPermissionMessage =>
      'Für das Scannen von QR-Codes ist eine Kameraberechtigung erforderlich. Bitte gewähren Sie den Kamerazugriff in Ihren Geräteeinstellungen.';

  @override
  String get cameraPermissionDenied => 'Kameraberechtigung verweigert';

  @override
  String get errorAccessingCamera => 'Fehler beim Zugriff auf die Kamera';

  @override
  String get stationId => 'Ladestation ID';

  @override
  String get example => 'Beispiel:';

  @override
  String get input => 'eingabe';

  @override
  String get dontHaveAnAccount => 'Sie haben noch kein Konto?';

  @override
  String get signup => 'Anmeldung';

  @override
  String get youHaventAddedAnyCardsYet =>
      'Sie haben noch keine Karten hinzugefügt.';

  @override
  String get selectPaymentMethod => 'Zahlungsmethode auswählen';

  @override
  String get chargingInProgress => 'Ladevorgang läuft';

  @override
  String get cancelSession => 'Sitzung abbrechen';

  @override
  String get unableToConnectToServer =>
      'Ein Ladevorgang kann nicht gestartet werden. Bitte versuchen Sie es später erneut.';

  @override
  String get chargeCard => 'Ladekarte';

  @override
  String get youAreReadyToGo => 'Sie können loslegen!';

  @override
  String get noteWeAreStillProcessing =>
      'Hinweis: Wir bearbeiten die Transaktion noch. Sobald dies erledigt ist, können Sie Ihre Sitzungsdetails überprüfen.';

  @override
  String get sessionCompleted => 'Sitzung ist abgeschlossen';

  @override
  String get sessionDetails => 'Sitzungsdetails';

  @override
  String get price => 'Preis';

  @override
  String get inclVat => '(inkl. MwSt.)';

  @override
  String get exclVat => '(exkl. MwSt.)';

  @override
  String get usage => 'Verbrauch';

  @override
  String get duration => 'Dauer';

  @override
  String get startTime => 'Startzeit';

  @override
  String get endTime => 'Endzeit';

  @override
  String get charged => 'Charged';

  @override
  String get date => 'Date';

  @override
  String get totalCosts => 'Total Costs';

  @override
  String get payment => 'Zahlung';

  @override
  String get thereArentAnyStationsNearYourLocations =>
      'Es befinden sich keine Ladestationen in Ihrer Nähe.';

  @override
  String get sessionStarting => 'Sitzung wird gestartet';

  @override
  String get sessionStopping => 'Sitzung wird gestopt';

  @override
  String get sessionEnded => 'Sitzung beendet';

  @override
  String get stationDoesntSupportSessions =>
      'Diese Station unterstützt das Starten von Ladesitzungen innerhalb der App nicht. Verwenden Sie die Stationssteuerung, um sich anzumelden und eine Ladesitzung zu starten';

  @override
  String get stationOnlySupportsRfidCards =>
      'Diese Ladestation unterstützt das Starten in der App nur mit RFID Ladekarte.';

  @override
  String get stationOnlySupportsCreditCards =>
      'Diese Ladestation unterstützt das Starten in der App nur mit Kreditkarte.';

  @override
  String get weLoggedYouInAutomatically =>
      'Wir haben Sie automatisch eingeloggt. ';

  @override
  String get cannotAddAPaymentMethod =>
      'Es ist nicht möglich eine Zahlungsmethode zu diesem Konto hinzuzufügen. ';

  @override
  String get imAllPluggedInToTheEvStation =>
      'Diese Station unterstützt das Starten von Sitzungen innerhalb der App nicht. Verwenden Sie die Stationssteuerungen, um sich zu authentifizieren und eine Ladesitzung zu starten';

  @override
  String get automaticallyDetectMyConnection =>
      'Meine Vebindung automatisch erkennen.';

  @override
  String get findNearbyEvStations => 'Ladestationen in der Nähe finden';

  @override
  String get chooseFromAListOfNearbyConnectors =>
      'Wählen Sie aus einer Liste von Ladestationen in der Nähe';

  @override
  String get accountCreated => 'Konto erstellt';

  @override
  String get youCanNowStartYourFirstCharge =>
      'Sie können nun mit der ersten EV-Ladung beginnen';

  @override
  String get youCanNowAddAPaymentMethod =>
      'Sie können nun eine Zahlungsmethode hinterlegen und mit der ersten EV-Ladung beginnen';

  @override
  String get countryIsRequired => 'Land ist erforderlich';

  @override
  String get streetIsRequired => 'Straße ';

  @override
  String get houseNumberIsRequired => 'Hausnummer ist erforderlich';

  @override
  String get postCodeIsRequired => 'Postleitzahl ist erforderlich';

  @override
  String get cityIsRequired => 'Ort ist erforderlich';

  @override
  String get firstNameRequired => 'Vorname ist erforderlich';

  @override
  String get lastNameRequired => 'Nachname ist erforderlich';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get phoneNumberRequired => 'Telefonnummer ist erforderlich';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'Bitte gebe eine gültige E-Mailadresse an';

  @override
  String get passwordMustContain =>
      'Das Passwort muss mindestens 8 Zeichen lang sein und mindestens einen Buchstaben, eine Zahl und ein Sonderzeichen enthalten.';

  @override
  String get acceptTermsAndConditions =>
      'Bitte akzeptieren Sie die Nutzungsbedingungen';

  @override
  String get acceptPrivacyStatement =>
      'Bitte akzeptieren Sie die Datenschutzbedingungen';

  @override
  String get country => 'Land';

  @override
  String get street => 'Straße ';

  @override
  String get houseNumberShort => 'Nummer';

  @override
  String get postCode => 'Postleitzahl';

  @override
  String get cityTown => 'Stadt/Ort';

  @override
  String get billingDetails => 'Rechnungsdetails';

  @override
  String get billingAddress => 'Rechnungsadresse';

  @override
  String get iAcceptThe => 'Ich akzeptiere die';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get iUnderstandThat =>
      'Ich verstehe, dass --brandname-- meine persönlichen Daten gemäß den, verarbeiten wird';

  @override
  String get privacyStatement => 'Datenschutzerklärung';

  @override
  String get iWantToReceive =>
      'Ich möchte Newsletter über meine Ladekarte und/oder Abonnement erhalten und erteile hiermit meine Zustimmung zur Verarbeitung meiner persönlichen Daten dafür, wie in den beschrieben';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createYourFreeAccount => 'Kostenloses Konto erstellen';

  @override
  String get blockCard => 'Karte blockieren';

  @override
  String get unblockCard => 'Karte entblockieren';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get identifier => 'Identifikator';

  @override
  String get billingPlan => 'Abonnement';

  @override
  String get nameOnCard => 'Name auf Karte';

  @override
  String get card => 'Karte';

  @override
  String get unknownAddress => 'Unbekannte Adresse';

  @override
  String get removeCard => 'Karte löschen';

  @override
  String get areYouSureYouWantToRemoveCard =>
      'Sind Sie sicher, dass Sie diese Karte löschen möchten?';

  @override
  String get areYouSureYouWantToBlockCardFrom =>
      'Sind Sie sicher, dass Sie diese Karte blockieren möchten?';

  @override
  String get thisActionCannotBeReversed =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Sie werden mit dieser Karte an keiner Ladestation mehr laden können.';

  @override
  String get yesRemoveCard => 'Ja, Karte löschen';

  @override
  String get yesBlockCard => 'Ja, Karte blockieren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get editPaymentMethod => 'Zahlungsmethode berarbeiten';

  @override
  String get addPaymentMethod => 'Zahlungsmethode hinzufügen';

  @override
  String get creditOrDebitCard => 'Kredit- oder Debitkarte';

  @override
  String get cardNumber => 'Kartennummer';

  @override
  String get saveCard => 'Karte speichern';

  @override
  String get cardVerificationRequired => 'Kartenverifikation erforderlich';

  @override
  String get clickButton3dSecure =>
      'Nachdem Sie auf die Schaltfläche geklickt haben, werden Sie zur Authentifizierung über 3D Secure zu Ihrem Zahlungsanbieter weitergeleitet';

  @override
  String get continueToAuthentication =>
      'Fahren Sie fort für die Authentifikation';

  @override
  String get tdsSecureHelpsPreventFraud =>
      '3D-Secure (3DS) hilft dabei, Betrug beim Online-Gebrauch von Zahlungskarten zu verhindern.';

  @override
  String get cardSaved => 'Karte gespeichert';

  @override
  String get cardRemoved => 'Karte gelöscht';

  @override
  String get cardFailedToSave =>
      'Karte konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get hour => 'Stunde';

  @override
  String get session => 'Sitzung';

  @override
  String get hourIdleFee => 'Blockiergebühr pro Stunde';

  @override
  String get minWaitBeforeIdleFee =>
      'Warteminuten ab Ladeende bevor Blockiergebühr erhoben wird';

  @override
  String get name => 'Name';

  @override
  String get status => 'Status';

  @override
  String get operatorKey => 'Anwender';

  @override
  String get availableFacilities => 'Available facilities';

  @override
  String get carpoolParking => 'Fuhrpark Parken';

  @override
  String get wifi => 'WLAN';

  @override
  String get noSessionDataAvailable => 'Keine Sitzungsdaten verfügbar';

  @override
  String get filterByMonth => 'Nach Monat filtern';

  @override
  String get viewAllSessions => 'Alle Sitzungen anzeigen →';

  @override
  String get scheduledTariffNote =>
      'Ein geplanter Tarif überschreibt die Grundtarifpreise für einen bestimmten Zeitraum.\n\n\n\n\r';

  @override
  String get dynamicTariffNote =>
      'Der dynamische Preis wird automatisch basierend auf dem Energiemarktpreis (im Intervall von 1 Stunde) angepasst.';

  @override
  String get pricing => 'Preisgestaltung';

  @override
  String get baseTariff => 'Basistarif';

  @override
  String get dynamicTariff => 'Dynamischer Preis';

  @override
  String get activeNow => 'JETZT AKTIVIEREN';

  @override
  String get viewAllHourlyPrices => 'Alle Preise pro Stunde anzeigen';

  @override
  String get hourlyPrices => 'Preise pro Stunde';

  @override
  String get tariffNotes => 'Tarifbemerkungen';

  @override
  String get viewTariffNotes => 'Tarifbemerkeungen anzeigen';

  @override
  String get active => 'Aktiv';

  @override
  String get noConnectorDataAvailable => 'Keine Connector Daten verfügbar';

  @override
  String get hotel => 'Hotel';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get cafe => 'Café';

  @override
  String get mall => 'Shoppingcenter';

  @override
  String get supermarket => 'Supermarkt';

  @override
  String get sport => 'Sport';

  @override
  String get recreationArea => 'Erholungsgebiet';

  @override
  String get nature => 'Natur';

  @override
  String get museum => 'Museum';

  @override
  String get bikeSharing => 'Fahrrad-Sharing';

  @override
  String get busStop => 'Bus-Haltestelle';

  @override
  String get taxiStand => 'Taxi Stand';

  @override
  String get tramStop => 'Straßenbahn-Haltestelle';

  @override
  String get metroStation => 'U-Bahn-Station';

  @override
  String get trainStation => 'Bahn-Station';

  @override
  String get airport => 'Flughafen';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get available => 'Verfügbar';

  @override
  String get unavailable => 'Nicht verfügbar';

  @override
  String get alongMotorway => 'Neben Autobahn';

  @override
  String get parkingGarage => 'Garage';

  @override
  String get parkingLot => 'Parkplatz';

  @override
  String get onDriveway => 'Auf Auffahrt';

  @override
  String get onStreet => 'Auf der Straße';

  @override
  String get undergroundGarage => 'Untergrund Garage';

  @override
  String get fuelStation => 'Tankstelle';

  @override
  String inaccurateTariffWarning(String appName) {
    return '\nBitte hier angezeigte Tarife wurden E-Flux von Roaming-Partnern übermittelt. Die Genauigkeit kann je nach Anbieter variieren.';
  }

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      '\nEtwas ist schiefgegangen. Bitte versuchen Sie es später erneut.';

  @override
  String hAndMin(num hours, num minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}s ${minutes}min';
  }

  @override
  String get lessThanAMinute => 'kürzer als eine Minute';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tage',
      one: '1 tage',
      zero: '0 tage',
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
      other: '$countString stunden',
      one: '1 stunde',
      zero: '0 stunden',
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
      one: '1 minute',
      zero: '0 minuten',
    );
    return '$_temp0';
  }

  @override
  String get noTariffAvailable => 'Kein Tarif verfügbar';

  @override
  String get unknownKW => 'unbekannte KW';

  @override
  String get cardDetailsUnavailable =>
      'Kartendetails nicht verfügbar.\n\n\n\n\r';

  @override
  String get ok => 'ok';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgegangen: ';

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
  String get sendCode => 'Code senden';

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
  String get error => 'Fehler';

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
  String get youreAllReadyToBegin =>
      'Sie können Ihre erste Ladesitzung starten';

  @override
  String get startYouFirstEVCharge => 'Starten Sie Ihre erste EV-Ladung';

  @override
  String get locationServicesAreDisabled =>
      '\nStandortdienste sind deaktiviert. Bitte öffnen Sie die Einstellungen und aktivieren Sie die Standortdienste.';

  @override
  String get skip => 'Überspringen →';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get locationPermissionsHaveBeenDenied =>
      '\nDie Standortberechtigungen wurden für diese App verweigert. Die Leistung dieser App wird ohne diese Berechtigung erheblich beeinträchtigt. Bitte öffnen Sie die Einstellungen und erlauben Sie die Standortberechtigungen.';

  @override
  String get continueStr => 'Fortfahren';

  @override
  String get byAllowingLocationServices =>
      'Durch das Zulassen von Standortdiensten können wir Ladestationen in Ihrer Nähe ermitteln.\n\n\n\n\r';

  @override
  String get findAllAvailableChargeStationsNearby =>
      'Finden Sie alle verfügbaren Ladestationen in Ihrer Nähe';

  @override
  String get getStarted => 'Legen Sie los';

  @override
  String get letsGetYouStarted =>
      'Beginnen Sie mit der Nutzung der einfachsten und schnellsten Lade-App\n\n\n\n';

  @override
  String get eVWallet => 'EV Wallet';

  @override
  String get signupForAnAccount => 'Registrieren Sie sich für ein Konto';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get password => 'Passwort';

  @override
  String get eMail => 'E-mail';

  @override
  String get priceUnknown => 'Preis unbekannt';

  @override
  String get youHaventChargedYourEVYet =>
      'Sie haben Ihr E-Fahrzeug noch nicht geladen';

  @override
  String get cardRfid => 'Card (RFID)';

  @override
  String get youDontHaveAnyPaymentMethodsYet =>
      'Sie haben bisher keine Zahlungsmethoden';

  @override
  String get sessions => 'Sitzungen';

  @override
  String get paymentMethods => 'Zahlungsmethoden';

  @override
  String get paymentsAndSessions => 'Zahlungsmethoden & Sitzungen';

  @override
  String get wallet => 'Wallet';

  @override
  String get locationServicesHaveBeenDisabledForThisApp =>
      'Standortdienste wurden für diese App deaktiviert. Bitte aktivieren Sie diese in den Einstellungen Ihres Geräts';

  @override
  String get locationPermissionGranted => 'Standortberechtigung erteilt';

  @override
  String
  get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings =>
      'Standortberechtigung für diese App verweigert. Bitte aktivieren Sie sie in den Einstellungen Ihres Geräts.';

  @override
  String get requestPermission => 'Berechtigung anfragen';

  @override
  String get grantLocationPermissionToUseThisFeature =>
      'Erteilen Sie die Standortberechtigung, um diese Funktion zu verwenden';

  @override
  String get initialisingLocationService =>
      'Standortdienst wird initialisiert...';

  @override
  String get findEVChargingLocations => 'EV-Ladestationen finden';

  @override
  String get exploreStations => 'Stationen erkunden';

  @override
  String get viewWallet => 'Wallet angucken';

  @override
  String get startAChargeSession => 'Ladesitzung starten';

  @override
  String get charging => 'Laden';

  @override
  String get clickTheButtonBelow => 'Klicken Sie auf die Schaltfläche unten';

  @override
  String get startYourEVCharge => 'Starte deine\nEV-Ladung';

  @override
  String get searchLocation => 'Standort suchen';

  @override
  String get getDirections => 'Wegbeschreibung erhalten';

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
  String get trySearchingForAnotherLocation => 'Anderen Standort suchen →';

  @override
  String get noChargeStationsFound => 'Keine Ladestationen gefunden';

  @override
  String get myCurrentPosition => 'Mein aktueller Standort';

  @override
  String get useMyCurrentPosition => 'Meinen aktuellen Standort verwenden';

  @override
  String get searchAddressOrPlaceName => 'Suche nach Adresse oder Ort';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get connectorType => 'Connector Type';

  @override
  String get chargingPowerkW => 'Charging Power [kW]';

  @override
  String get chargers => 'Ladestationen';

  @override
  String get dCChargers => 'Schnell Ladestationen';

  @override
  String get availableChargers => 'Verfügbare Ladestationen';

  @override
  String get onlyShow => 'Nur anzeigen';

  @override
  String get filters => 'Filter';

  @override
  String get findMoreStationsNearby => 'Mehr Stationen in der Nähe finden →';

  @override
  String get findStationsNearby => 'Find stations nearby →';

  @override
  String get highwayModeAvailableWhileDriving =>
      'Highway mode is available while driving outside of city speed limits.';

  @override
  String get youCanAlwaysFindNearbyStations =>
      'You can always find nearby stations on our map.';

  @override
  String get nearbyStations => 'Stationen in der Nähe';

  @override
  String get selectYourChargeStation => 'Wählen Sie Ihre Ladestation';

  @override
  String get paymentMethod => 'Zahlungsmethode';

  @override
  String get unnamedCard => 'Unbenannte Karte';

  @override
  String get noCardsAvailable => 'Keine Karten verfügbar';

  @override
  String get startSession => 'Sitzung starten';

  @override
  String get unknownEVSEID => 'Unbekannte EVSE ID';

  @override
  String get startChargingSession => 'Ladesitzung starten';

  @override
  String get exploreOrSearchForALocation =>
      'Erkunden oder nach einem Standort suchen →';

  @override
  String get thereArentAnyStationsNearYou =>
      '\"Es gibt keine Stationen in der Nähe Ihres Standorts.\n\nDie automatische Standortsuche ist noch in Gange und wird Stationen in Ihrer Nähe erkennen, wenn Sie sich ihnen nähern, bis Sie diesen Bildschirm schließen';

  @override
  String get noStationsFound => 'Keine Ladestationen gefunden';

  @override
  String get selectStation => 'Ladestation auswählen';

  @override
  String get evseId => 'EVSE ID';

  @override
  String get manualStationInput => 'Manueller Ladestation Input';

  @override
  String get manualEVSEIDInput => 'Manueller EVSE ID Input →';

  @override
  String get noSelectDifferentStation => 'Nein, andere Station auswählen →';

  @override
  String get yesThisIsMe => 'Ja, das bin ich!';

  @override
  String get isThisYou => 'Sind Sie das?';

  @override
  String get imAllPluggedIn => 'Ich bin bereits angeschlossen';

  @override
  String get close => 'Schließen';

  @override
  String get endSession => 'Sitzung beenden';

  @override
  String get yourCarIsCharging => 'Ihr Auto lädt';

  @override
  String get unknownKWh => 'unbekannte kWh';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Konto';

  @override
  String get login => 'Login';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get helpAndSupport => 'Hilfe & Support';

  @override
  String get cancelSubscription => 'Abonnement kündigen';

  @override
  String get removeAccount => 'Account löschen';

  @override
  String get logout => 'Ausloggen';

  @override
  String get directPayments => 'Direktzahlungen';

  @override
  String get chargingCardOrTag => 'Ladekarte oder -Chip';

  @override
  String get withoutAdditionalFeePerSession =>
      'Ohne zusätzliche Gebühr pro Sitzung';

  @override
  String get supportsRemoteCharge => 'Start per App möglich';

  @override
  String get additionalFee => 'Zusätzliche Gebühr';

  @override
  String get favouriteStations => 'Favoriten-Stationen';

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
  String get totalSessions => 'Gesamtzahl der Sitzungen';

  @override
  String get totalEnergy => 'Total energy';

  @override
  String get totalTime => 'Total time';

  @override
  String get totalCost => 'Total Costs';

  @override
  String get costTooltipText =>
      'Note that the cost displayed here is approximate and does not include all additional fees. Full costs are displayed on your invoice.';

  @override
  String get selectOption => 'Select option';

  @override
  String get carScreenFastChargersAhead => 'Schnell Ladestationen';

  @override
  String get carScreenHighway => 'Highway mode';

  @override
  String get carScreenHighwayAuto => 'Highway Auto';

  @override
  String get carScreenHighwayOff => 'Highway Off';

  @override
  String get carScreenHighwayOn => 'Highway mode: On';

  @override
  String get carScreenNavigate => 'Navigate';

  @override
  String get carScreenShowDetails => 'Show details';

  @override
  String carScreenFiltersCount(int count) {
    return 'Filters ($count)';
  }

  @override
  String get carScreenFilterOn => 'On';

  @override
  String get carScreenFilterOff => 'Off';

  @override
  String get carScreenSearchingStations =>
      'Searching for nearby charging stations…';

  @override
  String get carScreenNoStationsFound => 'No charging stations found nearby';

  @override
  String get carScreenNavigationNotAvailable => 'Navigation not available';

  @override
  String get carScreenNavigationError => 'Navigation Error';

  @override
  String get carScreenNavigateOnPhone => 'Navigate on Phone';

  @override
  String get carScreenNoFiltersAvailable => 'No filters available';

  @override
  String carScreenAvailabilityCount(int available, int total) {
    return '$available/$total available';
  }

  @override
  String carScreenPricePerKwh(String price) {
    return '$price/kWh';
  }

  @override
  String get carScreenTabMap => 'Map';

  @override
  String get carScreenTabFilters => 'Filters';

  @override
  String get carScreenTabFavourites => 'Favourites';

  @override
  String get carScreenNoFavourites => 'No favourites yet';

  @override
  String get carScreenLoginToSaveFavourites =>
      'Log in to save your favourite stations';

  @override
  String get carScreenSave => '🤍 Save';

  @override
  String get carScreenSaved => '❤️ Saved';

  @override
  String get carScreenChargingPower => 'Charging Power';

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
    return '$count selected';
  }

  @override
  String get selectNetworks => 'Nur ausgewähltes Netz';

  @override
  String get excludeNetworks => 'Ausgewählte Netzwerke ausblenden';

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
