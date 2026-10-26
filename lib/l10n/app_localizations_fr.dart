// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get highwayMode => 'Highway Mode';

  @override
  String get stopAtNearestFastChargingStation =>
      'Arrêtez-vous à la station de recharge rapide la plus proche';

  @override
  String get emailAddressSuccessfullyVerified =>
      'Adresse e-mail vérifiée avec succès !';

  @override
  String get phoneNumberSuccessfullyVerified =>
      'Numéro de téléphone vérifié avec succès !';

  @override
  String get pleaseVerifyYourPhoneNumberAndEmail =>
      'Veuillez vérifier votre numéro de téléphone et votre adresse e-mail.';

  @override
  String get verifyYourPhoneNumberNow =>
      'Vérifiez votre numéro de téléphone dès maintenant';

  @override
  String get verifyYourEmailNow =>
      'Confirmez votre adresse e-mail dès maintenant';

  @override
  String get verifyYourEmailAddress => 'Vérifiez votre adresse e-mail';

  @override
  String weSentYouAnEmailVerification(String emailAddress) {
    return 'Un e-mail a été envoyé à $emailAddress';
  }

  @override
  String get openMailApp => 'Accéder à votre messagerie';

  @override
  String get pleaseConfirmYourEmailAddressByClicking =>
      'Veuillez confirmer votre adresse e-mail en cliquant sur le lien dans l’e-mail que nous vous avons envoyé.';

  @override
  String get didntReceiveTheEmail =>
      'Vous n’avez pas reçu l’e-mail ? Vérifiez vos courriers indésirables ou ';

  @override
  String get resendEmailVerificationLink =>
      'demandez à recevoir à nouveau le lien de vérification';

  @override
  String get verified => 'Vérifié';

  @override
  String get stationAddedToYourFavourites => 'Station ajoutée à vos favoris';

  @override
  String get removedFromYourFavourites => 'Station retirée de vos favoris';

  @override
  String get yourFavouriteStationsWillShowUpHere =>
      'Retrouvez ici vos stations favorites, avec leur disponibilité en temps réel.';

  @override
  String get markStationsAsFavouriteByPressingTheHeartIcon =>
      'Pour ajouter une station à vos favoris, cliquez sur l’icône cœur.';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get removeFromFavourites => 'Remove from favourites';

  @override
  String get exploreMap => 'Voir la carte';

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
  String get accountRemovalIsPending => 'Suppression du compte en cours';

  @override
  String get areYouSureYouWantToRemoveYourAccount =>
      'Êtes-vous sûr de vouloir supprimer votre compte ?';

  @override
  String get thisActionIsPermanent => 'Cette action est définitive.';

  @override
  String get yesRemoveAccount => 'Oui, supprimer le compte';

  @override
  String weSentYouAndSmsFullNumber(String phoneNumber) {
    return 'Nous vous avons envoyé un SMS au $phoneNumber.';
  }

  @override
  String get saveRecoveryCodes => 'Enregistrer les codes de récupération';

  @override
  String get recoveryCodesCanBeUsed =>
      'Les codes de récupération permettent d’accéder à votre compte si vous perdez l’accès à votre appareil et ne pouvez pas utiliser la double authentification.';

  @override
  String get downloadCodes => 'Télécharger les codes ';

  @override
  String get copyCodes => 'Copier les codes';

  @override
  String get iSavedMyBackupCodes =>
      'J’ai enregistré mes codes de récupération.';

  @override
  String get putTheseInASafeSpot =>
      'Stockez ces codes en sécurité. En cas de perte de votre appareil sans codes de récupération, vous ne pourrez plus accéder à votre compte.';

  @override
  String get or => 'ou';

  @override
  String get oneDownloadAnAuthenticatorApp =>
      '1. Téléchargez une application d’authentification';

  @override
  String get weRecommendGoogleAuthenticator =>
      'Nous recommandons --authoption--, --authoption-- ou --authoption--. ';

  @override
  String get googleAuthenticator => 'Google Authenticator';

  @override
  String get onePassword => '1Password';

  @override
  String get authy => 'Authy';

  @override
  String get twoScanTheQrCode =>
      '2. Scannez le QR code avec votre application d’authentification.';

  @override
  String get threeEnterTheCode =>
      '3. Saisissez le code de sécurité généré par l’application. ';

  @override
  String get appAuthentication => 'Application d\'authentification';

  @override
  String get securityCodesGeneratedByApp =>
      'L’application d’authentification de votre choix générera les codes de sécurité.';

  @override
  String get smsAuthentication => 'Vérification par SMS';

  @override
  String get securityCodesSentViaSms =>
      'Les codes de sécurité seront envoyés par SMS sur votre appareil mobile.';

  @override
  String get passwordAndAuthentication => 'Mot de passe et sécurité ';

  @override
  String get dontHaveYourBackupCodes =>
      'Vous avez perdu vos codes de récupération ? ';

  @override
  String get contactSupportAt => 'Contactez le support à';

  @override
  String get toStartAManualVerificationProcess =>
      'pour initier une vérification manuelle.';

  @override
  String get pleaseEnterBackupCode =>
      'Entrez un code de récupération non utilisés';

  @override
  String get backupVerificationCode => 'Code de récupération';

  @override
  String get codeEnteredIsIncorrect =>
      'Le code saisi est incorrect. Veuillez réessayer ou demander un nouveau code.';

  @override
  String get isThisAuthMethodNotWorking =>
      'Cette méthode d’authentification ne fonctionne pas ?';

  @override
  String get useYourBackupCodes => 'Utilisez vos codes de récupération.';

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
      'Saisissez le code de sécurité généré par l\'application.';

  @override
  String get enterCode => 'Saisissez le code';

  @override
  String get weSentYouAnSms =>
      'Un code de vérification a été envoyé par SMS au numéro se terminant par --phonenumber--.';

  @override
  String get enterThe6DigitCodeBelow =>
      'Saisissez le code à 6 chiffres ci-dessous.';

  @override
  String get verify => 'Vérifier';

  @override
  String stepCounter(int current, int total) {
    return 'Étape $current/$total :';
  }

  @override
  String get verifyPhoneStepTitle => 'Vérifier téléphone';

  @override
  String get verifyEmailStepTitle => 'Vérifier l’e-mail';

  @override
  String get didntReceiveTheCode =>
      'Vous n’avez pas reçu le code ? Vous recevrez le code dans un instant ou ';

  @override
  String get resendVerificationCode => 'renvoyer le code de vérification';

  @override
  String get codeResent => 'Code renvoyé !';

  @override
  String get brandnameChargers => 'Chargeurs --brandname--';

  @override
  String get publicTariff => 'Tarif publique';

  @override
  String get specialCardTariff => 'Tarif carte spécial';

  @override
  String get updateBillingInformation =>
      'Mettre à jour les informations de facturation';

  @override
  String get billingAddressSuccessfullyUpdated =>
      'Adresse de facturation mise à jour avec succès';

  @override
  String get provideYourBillingDetails =>
      'Veuillez fournir vos informations de facturation';

  @override
  String get profileSuccessfullyUpdated => 'Profil mis à jour avec succès';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get manageYourPersonalContactInformation =>
      'Gérez vos informations personnelles';

  @override
  String get passwordSuccessfullyUpdated =>
      'Mot de passe mis à jour avec succès';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get passwordIsRequired => 'Un mot de passe est requis';

  @override
  String get updateYourPassword => 'Mettre à jour votre mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get accountSettings => 'Paramètres de compte';

  @override
  String get enableNotifications => 'Autoriser les notifications';

  @override
  String get pleaseAllowNotifications =>
      'Veuillez autoriser les notifications dans les paramètres de l\'application.';

  @override
  String get sendNotifications => 'Envoyer des notifications';

  @override
  String get chargingUpdatesSubtitleIOS =>
      'Push notifications and Live Activities';

  @override
  String get chargingUpdatesSubtitleAndroid =>
      'Push notifications and Ongoing Notifications';

  @override
  String get personalSettings => 'Paramètres personnels';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageYourNotifications =>
      'Gérez les notifications pour vos sessions de recharge.';

  @override
  String get allNotifications => 'Toutes les notifications';

  @override
  String get chargingStartedTitle => 'Session de recharge commencée';

  @override
  String get chargingSessionEndedTitle => 'Session de recharge terminée';

  @override
  String get chargingSessionStateOver80Title => 'La recharge a atteint 80%';

  @override
  String get chargingSessionChargingTitle => 'Recharge démarrée';

  @override
  String get chargingSessionSuspendedEvTitle => 'Recharge terminée';

  @override
  String get chargingSessionSuspendedEvseTitle =>
      'Recharge terminée par la borne ';

  @override
  String get chargingSessionStartedSubtitle =>
      'Notification lors du démarrage de votre session de recharge.';

  @override
  String get chargingSessionEndedSubtitle =>
      'Notification lors de l\'arrêt de votre session de recharge.';

  @override
  String get chargingSessionStateOver80Subtitle =>
      'Notification lorsque votre véhicule est chargé à 80%.';

  @override
  String get chargingSessionChargingSubtitle =>
      'Notification lorsque votre véhicule commence à charger.';

  @override
  String get chargingSessionSuspendedEvSubtitle =>
      'Notification lorsque votre véhicule a fini de charger.';

  @override
  String get chargingSessionSuspendedEvseSubtitle =>
      'Notification lorsque la borne termine la recharge.';

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
      'Vous voulez ajouter votre carte de crédit ou de débit plus tard ?';

  @override
  String get viewYourChargeCards => 'Consultez vos cartes de recharge.';

  @override
  String get viewYourPreviousChargingSessions =>
      'Consultez vos sessions de recharge précédentes.';

  @override
  String get viewInvoicesForYourChargeCards =>
      'Consultez vos factures de cartes de recharge.';

  @override
  String get viewYourProfileAndAccount =>
      'Consultez votre profile et votre compte.';

  @override
  String get payWith => 'Payer avec';

  @override
  String get postCodeIsInvalid => 'Code postal non valide';

  @override
  String get later => 'Plus tard';

  @override
  String get enableLocationServices => 'Activer les services de localisation';

  @override
  String get pleaseAllowLocationUpdates =>
      'Veuillez autoriser les mises à jour de localisation dans les paramètres de l\'application.';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get accountCreatedWelcomeOnBoard => 'Compte créé. Bienvenue à bord !';

  @override
  String get search => 'Chercher';

  @override
  String get lookingForAppleOrGooglePay =>
      'Vous cherchez Apple Pay ou Google Pay ?';

  @override
  String get skipThisStep => 'Ignorer cette étape';

  @override
  String get invalidPhoneNumber => 'Numéro de téléphone invalide';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get privacyStatementOneLine => 'Déclaration de confidentialité';

  @override
  String get termsOfServiceOneLine => 'Conditions d\'utilisation';

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get about => 'Plus d\'informations';

  @override
  String get support => 'Support';

  @override
  String get addCreditOrDebitCard => 'Ajouter une carte de crédit ou de débit';

  @override
  String get byAddingAPaymentMethod =>
      'En ajoutant une méthode de paiement, vous pourrez démarrer une session de recharge sur n\'importe quelle station --brandname--.';

  @override
  String get youWillAddYourPaymentDetails =>
      'Vous ajouterez vos données de paiement à l\'étape suivante.';

  @override
  String get supportedMethods => 'Méthodes prises en charge';

  @override
  String get payments => 'Paiements';

  @override
  String get invoices => 'Factures';

  @override
  String get signupNowToSeeYourChargeCards =>
      'Inscrivez-vous maintenant pour consulter vos cartes de recharge';

  @override
  String get signupNowToViewChargingSessions =>
      'Inscrivez-vous maintenant pour voir toutes vos sessions de recharge précédentes.';

  @override
  String get signupNowToViewInvoices =>
      'Inscrivez-vous maintenant pour voir toutes vos factures de cartes de recharge.';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ? ';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get downloadInvoice => 'Télécharger la facture';

  @override
  String get invoiceDetails => 'Détails de la facture';

  @override
  String get noInvoiceDataAvailable =>
      'Aucune donnée de facturation n\'est disponible.';

  @override
  String get filterByYear => 'Filtrer par année';

  @override
  String get chargeCardInvoices => 'Factures de carte de recharge';

  @override
  String get viewAllInvoices => 'Voir toutes les factures';

  @override
  String get chooseRoutingApp => 'Choisir une application de routage';

  @override
  String get manuallyInputStationId =>
      'Saisir manuellement l\'identifiant de la borne';

  @override
  String get inputTheStationIdFromTheSticker =>
      'Saisir l\'identifiant de la borne figurant sur l\'autocollant';

  @override
  String get findTheStickerEnterTheDigits =>
      'Repérez l’autocollant sur la borne de recharge puis entrez le code chiffré.';

  @override
  String get scanStationQrCode => 'Scanner le QR code de la borne';

  @override
  String get useCameraToIdentifyStationId =>
      'Utilisez la caméra pour identifier l’ID de votre borne';

  @override
  String get qrScannerTorchToggle => 'Toggle torch';

  @override
  String get cameraPermissionRequired => 'Autorisation caméra requise';

  @override
  String get cameraPermissionMessage =>
      'Pour scanner un QR code, l’accès à la caméra est nécessaire. Merci d’autoriser la caméra dans les paramètres de votre appareil.';

  @override
  String get cameraPermissionDenied => 'Permission d’accès à la caméra refusée';

  @override
  String get errorAccessingCamera => 'Erreur d’accès à la caméra';

  @override
  String get stationId => 'ID de la borne';

  @override
  String get example => 'Exemple:';

  @override
  String get input => 'saisir';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signup => 'S\'inscrire';

  @override
  String get youHaventAddedAnyCardsYet =>
      'Vous n\'avez pas encore ajouté de cartes.';

  @override
  String get selectPaymentMethod => 'Sélectionnez le mode de paiement';

  @override
  String get chargingInProgress => 'Recharge en cours';

  @override
  String get cancelSession => 'Annuler la recharge';

  @override
  String get unableToConnectToServer =>
      'Impossible de démarrer la recharge. Veuillez réessayer plus tard.';

  @override
  String get chargeCard => 'Carte de crédit';

  @override
  String get youAreReadyToGo => 'Vous êtes prêt à partir!';

  @override
  String get noteWeAreStillProcessing =>
      'Remarque : nous traitons toujours la transaction. Une fois cela fait, vous pourrez consulter les détails de votre session.';

  @override
  String get sessionCompleted => 'La séance est terminée';

  @override
  String get sessionDetails => 'Détails de la séance';

  @override
  String get price => 'Prix';

  @override
  String get inclVat => '(TTC)';

  @override
  String get exclVat => '(HT)';

  @override
  String get usage => 'Utilisation';

  @override
  String get duration => 'Durée';

  @override
  String get startTime => 'Heure de début';

  @override
  String get endTime => 'Heure de fin';

  @override
  String get charged => 'Charged';

  @override
  String get date => 'Date';

  @override
  String get totalCosts => 'Total Costs';

  @override
  String get payment => 'Paiement';

  @override
  String get thereArentAnyStationsNearYourLocations =>
      'Il n’y a aucune station à proximité de votre position.';

  @override
  String get sessionStarting => 'Début de la session';

  @override
  String get sessionStopping => 'Arrêt de la session';

  @override
  String get sessionEnded => 'Session terminée';

  @override
  String get stationDoesntSupportSessions =>
      'Cette borne ne prend pas en charge le démarrage de sessions dans l\'application. Utilisez les commandes de la borne pour vous authentifier et démarrer une session de recharge.';

  @override
  String get stationOnlySupportsRfidCards =>
      'Cette borne prend uniquement en charge le démarrage de sessions dans l\'application avec une carte de paiement RFID.';

  @override
  String get stationOnlySupportsCreditCards =>
      'Cette borne ne prend en charge que le démarrage de sessions dans l\'application avec une carte de crédit.';

  @override
  String get weLoggedYouInAutomatically =>
      'Nous vous avons connecté automatiquement.';

  @override
  String get cannotAddAPaymentMethod =>
      'Impossible d\'ajouter un mode de paiement à ce compte.';

  @override
  String get imAllPluggedInToTheEvStation =>
      'Je suis connecté à la borne de recharge';

  @override
  String get automaticallyDetectMyConnection =>
      'Détecter automatiquement ma connexion';

  @override
  String get findNearbyEvStations =>
      'Trouver des bornes de recharge à proximité';

  @override
  String get chooseFromAListOfNearbyConnectors =>
      'Choisissez parmi une liste de connecteurs à proximité';

  @override
  String get accountCreated => 'Compte créé';

  @override
  String get youCanNowStartYourFirstCharge =>
      'Vous pouvez maintenant démarrer votre première recharge électrique.';

  @override
  String get youCanNowAddAPaymentMethod =>
      'Vous pouvez désormais ajouter un mode de paiement et démarrer votre première recharge électrique';

  @override
  String get countryIsRequired => 'Le pays est requis';

  @override
  String get streetIsRequired => 'La rue est requise';

  @override
  String get houseNumberIsRequired => 'Le numéro de rue est requis';

  @override
  String get postCodeIsRequired => 'Le code postal est requis';

  @override
  String get cityIsRequired => 'La ville est requise';

  @override
  String get firstNameRequired => 'Le prénom est requis';

  @override
  String get lastNameRequired => 'Le nom de famille est requis';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get phoneNumberRequired => 'Le numéro de téléphone est requis';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'Veuillez saisir une adresse email valide';

  @override
  String get passwordMustContain =>
      'Le mot de passe doit contenir au moins 8 caractères, dont une lettre, un chiffre et un caractère spécial.';

  @override
  String get acceptTermsAndConditions =>
      'Veuillez accepter les termes et conditions';

  @override
  String get acceptPrivacyStatement =>
      'Veuillez accepter la déclaration de confidentialité';

  @override
  String get country => 'Pays';

  @override
  String get street => 'Rue';

  @override
  String get houseNumberShort => 'N°';

  @override
  String get postCode => 'Code postal';

  @override
  String get cityTown => 'Ville';

  @override
  String get billingDetails => 'Détails de facturation';

  @override
  String get billingAddress => 'Adresse de facturation';

  @override
  String get iAcceptThe => 'J\'accepte les';

  @override
  String get termsOfService => 'Conditions d\'utilisation.';

  @override
  String get iUnderstandThat =>
      'Je comprends que --brandname-- traitera mes données personnelles conformément aux';

  @override
  String get privacyStatement => 'Déclaration de confidentialité.';

  @override
  String get iWantToReceive =>
      'Je souhaite recevoir des newsletters concernant ma carte de paiement et/ou mon abonnement et j\'accepte par la présente le traitement de mes données personnelles à cet effet, comme décrit dans la';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createYourFreeAccount => 'Créer votre compte gratuit';

  @override
  String get blockCard => 'Bloquer la carte';

  @override
  String get unblockCard => 'Débloquer la carte';

  @override
  String get inactive => 'Inactif';

  @override
  String get identifier => 'Identifiant';

  @override
  String get billingPlan => 'Plan de facturation';

  @override
  String get nameOnCard => 'Nom sur la carte';

  @override
  String get card => 'Carte';

  @override
  String get unknownAddress => 'Adresse inconnue';

  @override
  String get removeCard => 'Supprimer la carte';

  @override
  String get areYouSureYouWantToRemoveCard =>
      'Êtes-vous sûr de vouloir supprimer la carte';

  @override
  String get areYouSureYouWantToBlockCardFrom =>
      'Etes-vous sûr de vouloir bloquer la carte de';

  @override
  String get thisActionCannotBeReversed =>
      'Cette action ne peut pas être annulée. Vous ne pourrez plus payer sur aucune borne de recharge avec cette carte.';

  @override
  String get yesRemoveCard => 'Oui, supprimer la carte';

  @override
  String get yesBlockCard => 'Oui, bloquer la carte';

  @override
  String get cancel => 'Annuler';

  @override
  String get editPaymentMethod => 'Modifier le mode de paiement';

  @override
  String get addPaymentMethod => 'Ajouter un mode de paiement';

  @override
  String get creditOrDebitCard => 'Carte de crédit ou de débit';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get saveCard => 'Enregistrer la carte';

  @override
  String get cardVerificationRequired => 'Vérification de la carte requise';

  @override
  String get clickButton3dSecure =>
      'Après avoir cliqué sur le bouton, vous serez redirigé vers votre fournisseur de paiement pour l\'authentification 3D Secure.';

  @override
  String get continueToAuthentication => 'Continuer vers l\'authentification';

  @override
  String get tdsSecureHelpsPreventFraud =>
      '3D-Secure (3DS) permet de prévenir la fraude lors de l\'utilisation de cartes de paiement en ligne.';

  @override
  String get cardSaved => 'Carte enregistrée';

  @override
  String get cardRemoved => 'Carte supprimée';

  @override
  String get cardFailedToSave =>
      'Échec de l\'enregistrement de la carte. Veuillez réessayer.';

  @override
  String get hour => 'Heure';

  @override
  String get session => 'Session';

  @override
  String get hourIdleFee => 'Frais d\'inactivité par heure';

  @override
  String get minWaitBeforeIdleFee =>
      'min d\'attente avant les frais d\'inactivité';

  @override
  String get name => 'Nom';

  @override
  String get status => 'Statut';

  @override
  String get operatorKey => 'Opérateur';

  @override
  String get availableFacilities => 'Available facilities';

  @override
  String get carpoolParking => 'Stationnement pour covoiturage';

  @override
  String get wifi => 'Wifi';

  @override
  String get noSessionDataAvailable => 'Aucune donnée de session disponible.';

  @override
  String get filterByMonth => 'Filtrer par mois';

  @override
  String get viewAllSessions => 'Voir toutes les sessions';

  @override
  String get scheduledTariffNote =>
      'Un tarif programmé remplace les prix du tarif de base pour une période spécifique.';

  @override
  String get dynamicTariffNote =>
      'Le tarif dynamique est ajusté automatiquement en fonction du prix du marché de l\'énergie (intervalle d\'une heure).';

  @override
  String get pricing => 'Tarifs';

  @override
  String get baseTariff => 'Tarif de base';

  @override
  String get dynamicTariff => 'Tarif dynamique';

  @override
  String get activeNow => 'ACTIF MAINTENANT';

  @override
  String get viewAllHourlyPrices => 'voir tous les tarifs horaires';

  @override
  String get hourlyPrices => 'Tarifs horaires';

  @override
  String get tariffNotes => 'Notes tarifaires';

  @override
  String get viewTariffNotes => 'Voir les notes tarifaires';

  @override
  String get active => 'Actif';

  @override
  String get noConnectorDataAvailable =>
      'Aucune donnée de connecteur disponible';

  @override
  String get hotel => 'Hôtel';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get cafe => 'Café';

  @override
  String get mall => 'Centre commercial';

  @override
  String get supermarket => 'Supermarché';

  @override
  String get sport => 'sport';

  @override
  String get recreationArea => 'Zone de loisirs';

  @override
  String get nature => 'Nature';

  @override
  String get museum => 'Musée';

  @override
  String get bikeSharing => 'vélos partagés';

  @override
  String get busStop => 'Arrêt de bus';

  @override
  String get taxiStand => 'Station de taxi';

  @override
  String get tramStop => 'Arrêt de tramway';

  @override
  String get metroStation => 'Gare de métro';

  @override
  String get trainStation => 'Gare';

  @override
  String get airport => 'Aéroport';

  @override
  String get notAvailable => 'Pas disponible';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get alongMotorway => 'Le long de l\'autoroute';

  @override
  String get parkingGarage => 'Parking Garage';

  @override
  String get parkingLot => 'Terrain de stationnement';

  @override
  String get onDriveway => 'Sur l\'allée';

  @override
  String get onStreet => 'Dans la rue';

  @override
  String get undergroundGarage => 'Garage souterrain';

  @override
  String get fuelStation => 'Station essence';

  @override
  String inaccurateTariffWarning(String appName) {
    return 'Les tarifs affichés ici ont été envoyés à E-Flux par l\'opérateur en roaming. La précision peut varier selon l\'opérateur.';
  }

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      'Quelque chose s\'est mal passé. Veuillez réessayer plus tard.';

  @override
  String hAndMin(num hours, num minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}h ${minutes}min';
  }

  @override
  String get lessThanAMinute => 'moins d\'une minute';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jours',
      one: '1 jour',
      zero: '0 jours',
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
      other: '$countString heures',
      one: '1 heure',
      zero: '0 heures',
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
      other: '$countString minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String get noTariffAvailable => 'Aucun tarif disponible';

  @override
  String get unknownKW => 'kW inconnu';

  @override
  String get cardDetailsUnavailable => 'Détails de la carte indisponibles';

  @override
  String get ok => 'OK';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé :';

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
  String get sendCode => 'Envoyer le code';

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
  String get error => 'Erreur';

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
      'Vous êtes tous prêts à commencer votre première session de recharge.';

  @override
  String get startYouFirstEVCharge => 'Commencez votre première recharge de VE';

  @override
  String get locationServicesAreDisabled =>
      'Les services de localisation sont désactivés. Veuillez ouvrir les paramètres et activer les services de localisation.';

  @override
  String get skip => 'passer';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get locationPermissionsHaveBeenDenied =>
      'Les autorisations de localisation ont été refusées pour cette application. Les performances de cette application seront gravement altérées sans cette autorisation. Veuillez ouvrir les paramètres et autoriser les services de localisation.';

  @override
  String get continueStr => 'Continuer';

  @override
  String get byAllowingLocationServices =>
      'En autorisant les services de localisation, nous serons en mesure de déterminer les bornes de recharge les plus proches de chez vous.';

  @override
  String get findAllAvailableChargeStationsNearby =>
      'Trouvez toutes les bornes de recharge disponibles à proximité';

  @override
  String get getStarted => 'Commencer';

  @override
  String get letsGetYouStarted =>
      'Commençons avec l\'application de recharge la plus simple et la plus rapide.';

  @override
  String get eVWallet => 'Portefeuille EV';

  @override
  String get signupForAnAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get password => 'Mot de passe';

  @override
  String get eMail => 'E-mail';

  @override
  String get priceUnknown => 'prix inconnu';

  @override
  String get youHaventChargedYourEVYet =>
      'Vous n\'avez pas encore chargé votre véhicule électrique.';

  @override
  String get cardRfid => 'Carte (RFID)';

  @override
  String get youDontHaveAnyPaymentMethodsYet =>
      'Vous n\'avez pas encore de moyens de paiement.';

  @override
  String get sessions => 'Sessions';

  @override
  String get paymentMethods => 'Méthodes de paiement';

  @override
  String get paymentsAndSessions => 'Paiements et sessions';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get locationServicesHaveBeenDisabledForThisApp =>
      'Les services de localisation ont été désactivés pour cette application. Veuillez les activer dans les paramètres de votre appareil.';

  @override
  String get locationPermissionGranted =>
      'Autorisation de localisation accordée';

  @override
  String
  get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings =>
      'Autorisation de localisation refusée pour cette application. Veuillez l\'activer dans les paramètres de votre appareil.';

  @override
  String get requestPermission => 'Demander l\'autorisation';

  @override
  String get grantLocationPermissionToUseThisFeature =>
      'Autoriser la localisation pour utiliser cette fonctionnalité';

  @override
  String get initialisingLocationService =>
      'Trouver des stations de recharge pour véhicules électriques';

  @override
  String get findEVChargingLocations => 'Explorer les stations';

  @override
  String get exploreStations => 'Bornes de recharge';

  @override
  String get viewWallet => 'Voir le portefeuille';

  @override
  String get startAChargeSession => 'Démarrer une session de recharge';

  @override
  String get charging => 'En charge';

  @override
  String get clickTheButtonBelow => 'Cliquez sur le bouton ci-dessous';

  @override
  String get startYourEVCharge => 'Commencez votre recharge';

  @override
  String get searchLocation => 'Chercher la station';

  @override
  String get getDirections => 'Obtenir l\'itinéraire';

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
  String get trySearchingForAnotherLocation =>
      'Essayez de chercher un autre emplacement →';

  @override
  String get noChargeStationsFound => 'Aucune borne de recharge trouvée';

  @override
  String get myCurrentPosition => 'Ma position actuelle';

  @override
  String get useMyCurrentPosition => 'Utiliser ma position actuelle';

  @override
  String get searchAddressOrPlaceName => 'Rechercher une adresse ou un lieu';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get connectorType => 'Type de connecteur';

  @override
  String get chargingPowerkW => 'Puissance de charge [kW]';

  @override
  String get chargers => 'Chargeurs';

  @override
  String get dCChargers => 'Chargeurs rapides disponibles';

  @override
  String get availableChargers => 'Chargeurs disponibles';

  @override
  String get onlyShow => 'Seulement montrer';

  @override
  String get filters => 'Filtres';

  @override
  String get findMoreStationsNearby => 'Trouver plus de stations à proximité →';

  @override
  String get findStationsNearby => 'Find stations nearby →';

  @override
  String get highwayModeAvailableWhileDriving =>
      'Highway mode is available while driving outside of city speed limits.';

  @override
  String get youCanAlwaysFindNearbyStations =>
      'You can always find nearby stations on our map.';

  @override
  String get nearbyStations => 'Station à proximité';

  @override
  String get selectYourChargeStation => 'Sélectionnez votre borne de recharge';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get unnamedCard => 'carte sans nom';

  @override
  String get noCardsAvailable => 'Aucune carte disponible';

  @override
  String get startSession => 'Démarrer la session';

  @override
  String get unknownEVSEID => 'ID EVSE inconnu';

  @override
  String get startChargingSession => 'Démarrer la session de recharge';

  @override
  String get exploreOrSearchForALocation =>
      'Explorer ou rechercher un emplacement →';

  @override
  String get thereArentAnyStationsNearYou =>
      'Il n\'y a aucune station à proximité de chez vous.\n\nLa recherche automatique de localisation est toujours en cours et détectera les stations proches de vous à mesure que vous vous en rapprochez et jusqu\'à ce que vous fermiez cet écran.';

  @override
  String get noStationsFound => 'Aucune station trouvée.';

  @override
  String get selectStation => 'Sélectionner la Station';

  @override
  String get evseId => 'ID EVSE';

  @override
  String get manualStationInput => 'Saisie manuelle de la station';

  @override
  String get manualEVSEIDInput => 'Saisie manuelle de l\'ID EVSE →';

  @override
  String get noSelectDifferentStation =>
      'Non, sélectionnez une autre station →';

  @override
  String get yesThisIsMe => 'Oui c\'est moi !';

  @override
  String get isThisYou => 'Est-ce vous ?';

  @override
  String get imAllPluggedIn => 'Je suis branché !';

  @override
  String get close => 'Fermer';

  @override
  String get endSession => 'Fin de session';

  @override
  String get yourCarIsCharging => 'Votre voiture se recharge';

  @override
  String get unknownKWh => 'kWh inconnu';

  @override
  String get profile => 'Profil';

  @override
  String get account => 'Compte';

  @override
  String get login => 'Se connecter';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get helpAndSupport => 'Aide et Support';

  @override
  String get cancelSubscription => 'Résilier l’abonnement';

  @override
  String get removeAccount => 'Supprimer le compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get directPayments => 'Paiements directs';

  @override
  String get chargingCardOrTag => 'Carte de recharge';

  @override
  String get withoutAdditionalFeePerSession =>
      'Sans frais supplémentaires par session';

  @override
  String get supportsRemoteCharge => 'Démarrage via app possible';

  @override
  String get additionalFee => 'Frais supplémentaires';

  @override
  String get favouriteStations => 'Stations favorites';

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
  String get totalSessions => 'Total des sessions';

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
  String get carScreenFastChargersAhead => 'Chargeurs rapides à venir';

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
  String get selectNetworks => 'Réseau sélectionné uniquement';

  @override
  String get excludeNetworks => 'Masquer les réseaux sélectionnés';

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
