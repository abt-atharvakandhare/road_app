// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get highwayMode => 'Highway Mode';

  @override
  String get stopAtNearestFastChargingStation =>
      'Para en la estación de carga rápida más cercana';

  @override
  String get emailAddressSuccessfullyVerified =>
      '¡Dirección de correo electrónico verificada con éxito!';

  @override
  String get phoneNumberSuccessfullyVerified =>
      '¡Número de teléfono verificado con éxito!';

  @override
  String get pleaseVerifyYourPhoneNumberAndEmail =>
      'Por favor, verifica tu número de teléfono y tu correo electrónico.';

  @override
  String get verifyYourPhoneNumberNow =>
      'Verifica tu número de teléfono ahora.';

  @override
  String get verifyYourEmailNow => 'Verifica tu correo electrónico ahora.';

  @override
  String get verifyYourEmailAddress =>
      'Verifica tu dirección de correo electrónico.';

  @override
  String weSentYouAnEmailVerification(String emailAddress) {
    return 'Te enviamos un correo electrónico a $emailAddress.';
  }

  @override
  String get openMailApp => 'Abre la aplicación de correo.';

  @override
  String get pleaseConfirmYourEmailAddressByClicking =>
      'Por favor, confirma tu dirección de correo electrónico haciendo clic en el enlace que te enviamos por correo.';

  @override
  String get didntReceiveTheEmail =>
      '¿No recibiste el correo? Por favor, revisa tu carpeta de spam o...';

  @override
  String get resendEmailVerificationLink =>
      'reenviar el enlace de verificación de correo electrónico';

  @override
  String get verified => 'Verificado';

  @override
  String get stationAddedToYourFavourites => 'Estación añadida a tus favoritos';

  @override
  String get removedFromYourFavourites => 'Eliminado de tus favoritos';

  @override
  String get yourFavouriteStationsWillShowUpHere =>
      'Tus estaciones favoritas con disponibilidad en tiempo real aparecerán aquí.';

  @override
  String get markStationsAsFavouriteByPressingTheHeartIcon =>
      'Marca las estaciones como favoritas pulsando el ícono de corazón.';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get removeFromFavourites => 'Verwijder uit je favorieten';

  @override
  String get exploreMap => 'Explorar mapa';

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
      'La eliminación de la cuenta está pendiente';

  @override
  String get areYouSureYouWantToRemoveYourAccount =>
      '¿Estás seguro de que quieres eliminar tu cuenta?';

  @override
  String get thisActionIsPermanent => 'Esta acción es permanente.';

  @override
  String get yesRemoveAccount => 'Sí, eliminar cuenta';

  @override
  String weSentYouAndSmsFullNumber(String phoneNumber) {
    return 'Te enviamos un SMS a $phoneNumber.';
  }

  @override
  String get saveRecoveryCodes => 'Guardar códigos de recuperación';

  @override
  String get recoveryCodesCanBeUsed =>
      'Los códigos de recuperación se pueden usar para acceder a tu cuenta en caso de que pierdas acceso a tu dispositivo y no puedas recibir los códigos de autenticación de dos factores.';

  @override
  String get downloadCodes => 'Descargar códigos';

  @override
  String get copyCodes => 'Copiar códigos';

  @override
  String get iSavedMyBackupCodes => 'He guardado mis códigos de respaldo.';

  @override
  String get putTheseInASafeSpot =>
      'Guarda estos en un lugar seguro. Si pierdes tu dispositivo y no tienes los códigos de recuperación, perderás el acceso a tu cuenta.';

  @override
  String get or => 'o';

  @override
  String get oneDownloadAnAuthenticatorApp =>
      '1. Descarga una aplicación de autenticación';

  @override
  String get weRecommendGoogleAuthenticator =>
      'Recomendamos --authoption--, --authoption-- o --authoption--.';

  @override
  String get googleAuthenticator => 'Google Authenticator';

  @override
  String get onePassword => '1Password';

  @override
  String get authy => 'Authy';

  @override
  String get twoScanTheQrCode =>
      '2. Escanea el código QR usando tu aplicación de autenticación';

  @override
  String get threeEnterTheCode =>
      '3. Introduce el código de seguridad generado por la aplicación';

  @override
  String get appAuthentication => 'Autenticación por aplicación';

  @override
  String get securityCodesGeneratedByApp =>
      'Los códigos de seguridad serán generados por tu aplicación de autenticación preferida.';

  @override
  String get smsAuthentication => 'Autenticación por SMS';

  @override
  String get securityCodesSentViaSms =>
      'Los códigos de seguridad se enviarán vía SMS a tu dispositivo móvil.';

  @override
  String get passwordAndAuthentication => 'Contraseña y autenticación';

  @override
  String get dontHaveYourBackupCodes =>
      '¿Ya no tienes tus códigos de respaldo?';

  @override
  String get contactSupportAt => 'Contacta con el soporte en';

  @override
  String get toStartAManualVerificationProcess =>
      'para iniciar un proceso de verificación manual.';

  @override
  String get pleaseEnterBackupCode =>
      'Por favor, ingresa uno de tus códigos de verificación de respaldo no usados:';

  @override
  String get backupVerificationCode => 'Código de verificación de respaldo';

  @override
  String get codeEnteredIsIncorrect =>
      'El código ingresado es incorrecto. Por favor, inténtalo de nuevo o solicita un nuevo código.';

  @override
  String get isThisAuthMethodNotWorking =>
      '¿No funciona este método de autenticación?';

  @override
  String get useYourBackupCodes => 'Usa tus códigos de respaldo';

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
      'Introduce el código de seguridad generado por la app.';

  @override
  String get enterCode => 'Introduce el código';

  @override
  String get weSentYouAnSms =>
      'Te enviamos un código de verificación por SMS al número de teléfono que termina en --phonenumber--.';

  @override
  String get enterThe6DigitCodeBelow =>
      'Ingrese el código de 6 dígitos a continuación';

  @override
  String get verify => 'Verificar';

  @override
  String stepCounter(int current, int total) {
    return 'Paso $current/$total:';
  }

  @override
  String get verifyPhoneStepTitle => 'Verificar teléfono';

  @override
  String get verifyEmailStepTitle => 'Verificar correo electrónico';

  @override
  String get didntReceiveTheCode =>
      '¿No recibiste el código? Puede tardar un minuto en llegar o';

  @override
  String get resendVerificationCode => 'Reenviar código de verificación';

  @override
  String get codeResent => '¡Código reenviado!';

  @override
  String get brandnameChargers => '--brandname-- Cargadores';

  @override
  String get publicTariff => 'Tarifa pública';

  @override
  String get specialCardTariff => 'Tarifa Tarjeta Especial';

  @override
  String get updateBillingInformation =>
      'Actualizar la información de facturación';

  @override
  String get billingAddressSuccessfullyUpdated =>
      'Dirección de facturación actualizada correctamente';

  @override
  String get provideYourBillingDetails =>
      'Proporciona tus datos de facturación';

  @override
  String get profileSuccessfullyUpdated => 'Perfil actualizado con éxito';

  @override
  String get updateProfile => 'Actualizar perfil';

  @override
  String get manageYourPersonalContactInformation =>
      'Gestiona tu información de contacto personal';

  @override
  String get passwordSuccessfullyUpdated =>
      'Contraseña actualizada correctamente';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get passwordIsRequired => 'Se requiere contraseña';

  @override
  String get updateYourPassword => 'Actualiza tu contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get accountSettings => 'Configuración de la cuenta';

  @override
  String get enableNotifications => 'Habilitar notificaciones';

  @override
  String get pleaseAllowNotifications =>
      'Permita las notificaciones en la configuración de la aplicación.';

  @override
  String get sendNotifications => 'Enviar notificaciones';

  @override
  String get chargingUpdatesSubtitleIOS =>
      'Push notifications and Live Activities';

  @override
  String get chargingUpdatesSubtitleAndroid =>
      'Push notifications and Ongoing Notifications';

  @override
  String get personalSettings => 'Configuración personal';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get manageYourNotifications =>
      'Administra tus notificaciones para las sesiones de carga.';

  @override
  String get allNotifications => 'Todas las notificaciones';

  @override
  String get chargingStartedTitle => 'Sesión de carga iniciada';

  @override
  String get chargingSessionEndedTitle => 'Sesión de carga finalizada';

  @override
  String get chargingSessionStateOver80Title => 'La carga alcanzó el 80%';

  @override
  String get chargingSessionChargingTitle => 'Carga iniciada';

  @override
  String get chargingSessionSuspendedEvTitle => 'Carga detenida';

  @override
  String get chargingSessionSuspendedEvseTitle =>
      'Carga detenida por la estación';

  @override
  String get chargingSessionStartedSubtitle =>
      'Notificación cuando se inicia la sesión de carga.';

  @override
  String get chargingSessionEndedSubtitle =>
      'Notificación cuando finaliza la sesión de carga.';

  @override
  String get chargingSessionStateOver80Subtitle =>
      'Notificación cuando la carga de tu coche alcanza el 80%.';

  @override
  String get chargingSessionChargingSubtitle =>
      'Notificación cuando tu coche empieza a cargarse.';

  @override
  String get chargingSessionSuspendedEvSubtitle =>
      'Notificación cuando tu coche deja de cargarse.';

  @override
  String get chargingSessionSuspendedEvseSubtitle =>
      'Notificación cuando la estación deja de cargar.';

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
      '¿Quieres añadir tu tarjeta de crédito o débito más tarde?';

  @override
  String get viewYourChargeCards => 'Ver tus tarjetas de carga';

  @override
  String get viewYourPreviousChargingSessions =>
      'Ver tus sesiones de carga anteriores.';

  @override
  String get viewInvoicesForYourChargeCards =>
      'Ver tus facturas de tus tarjetas de carga';

  @override
  String get viewYourProfileAndAccount => 'Ver tu perfil & cuenta';

  @override
  String get payWith => 'Pagar con ';

  @override
  String get postCodeIsInvalid => 'El código postal no es válido';

  @override
  String get later => 'Más tarde';

  @override
  String get enableLocationServices => 'Habilitar servicios de ubicación';

  @override
  String get pleaseAllowLocationUpdates =>
      'Permita las actualizaciones de ubicación en la configuración de la aplicación.';

  @override
  String get contactUs => 'Contáctenos';

  @override
  String get accountCreatedWelcomeOnBoard =>
      'Cuenta creada. ¡Bienvenidos a bordo!';

  @override
  String get search => 'Buscar';

  @override
  String get lookingForAppleOrGooglePay => '¿Buscas Apple Pay o Google Pay?';

  @override
  String get skipThisStep => 'Omitir este paso';

  @override
  String get invalidPhoneNumber => 'Número de teléfono no válido';

  @override
  String get appVersion => 'Versión de la aplicación';

  @override
  String get privacyStatementOneLine => 'Declaración de privacidad';

  @override
  String get termsOfServiceOneLine => 'Términos de servicio';

  @override
  String get aboutUs => 'Sobre nosotros';

  @override
  String get about => 'Más información';

  @override
  String get support => 'Apoyo';

  @override
  String get addCreditOrDebitCard => 'Agregar tarjeta de crédito o débito';

  @override
  String get byAddingAPaymentMethod =>
      'Al agregar un método de pago, podrás iniciar una sesión de carga en cualquier estación de --marca--';

  @override
  String get youWillAddYourPaymentDetails =>
      'Añadirás tus datos de pago en el siguiente paso.';

  @override
  String get supportedMethods => 'Métodos admitidos';

  @override
  String get payments => 'Pagos';

  @override
  String get invoices => 'Facturas';

  @override
  String get signupNowToSeeYourChargeCards =>
      'Regístrate ahora para ver todas las facturas de tus tarjetas de carga';

  @override
  String get signupNowToViewChargingSessions =>
      'Regístrtate ahora para ver todas tus sesiones de carga anteriores.';

  @override
  String get signupNowToViewInvoices =>
      'Regístrate ahora para ver todas las facturas de sus tarjetas de crédito.';

  @override
  String get alreadyHaveAnAccount => '¿Ya tienes una cuenta?';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get downloadInvoice => 'Descargar factura';

  @override
  String get invoiceDetails => 'Detalles de la factura';

  @override
  String get noInvoiceDataAvailable => 'No se dispone de datos de factura.';

  @override
  String get filterByYear => 'Filtrar por año';

  @override
  String get chargeCardInvoices => 'Facturas de tarjetas de carga';

  @override
  String get viewAllInvoices => 'Ver todas las facturas →';

  @override
  String get chooseRoutingApp => 'Elije la aplicación de enrutamiento';

  @override
  String get manuallyInputStationId =>
      'Introducción manual del ID de la estación';

  @override
  String get inputTheStationIdFromTheSticker =>
      'Ingresa el ID de la estación de la etiqueta';

  @override
  String get findTheStickerEnterTheDigits =>
      'Encuentra la etiqueta en la estación de carga e ingresa el identificador numérico';

  @override
  String get scanStationQrCode => 'Escanea el código QR de la estación';

  @override
  String get useCameraToIdentifyStationId =>
      'Usa la cámara para identificar el ID de tu estación';

  @override
  String get qrScannerTorchToggle => 'Toggle torch';

  @override
  String get cameraPermissionRequired => 'Se requiere permiso de la cámara';

  @override
  String get cameraPermissionMessage =>
      'Se requiere permiso de cámara para escanear códigos QR. Por favor, concede acceso a la cámara en la configuración de tu dispositivo';

  @override
  String get cameraPermissionDenied => 'Permiso de cámara denegado';

  @override
  String get errorAccessingCamera => 'Error al acceder a la cámara';

  @override
  String get stationId => 'ID de estación';

  @override
  String get example => 'Ejemplo:';

  @override
  String get input => 'entrada';

  @override
  String get dontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get signup => 'Inscribirse';

  @override
  String get youHaventAddedAnyCardsYet => 'Aún no has añadido ninguna tarjeta';

  @override
  String get selectPaymentMethod => 'seleccione Método de pago';

  @override
  String get chargingInProgress => 'Carga en progreso';

  @override
  String get cancelSession => 'Cancelar sesión';

  @override
  String get unableToConnectToServer => 'No se puede conectar al servidor';

  @override
  String get chargeCard => 'Tarjeta de cargo';

  @override
  String get youAreReadyToGo => '¡Estás listo para partir!';

  @override
  String get noteWeAreStillProcessing =>
      'Nota: todavía estamos procesando la transacción. Una vez hecho esto, podrá revisar los detalles de su sesión.';

  @override
  String get sessionCompleted => 'Sesión completa';

  @override
  String get sessionDetails => 'Detalles de la sesión';

  @override
  String get price => 'Precio';

  @override
  String get inclVat => '(incluye IVA)';

  @override
  String get exclVat => '(excl. IVA)';

  @override
  String get usage => 'Uso';

  @override
  String get duration => 'Duración';

  @override
  String get startTime => 'Hora de inicio';

  @override
  String get endTime => 'Hora de finalización';

  @override
  String get charged => 'Charged';

  @override
  String get date => 'Date';

  @override
  String get totalCosts => 'Total Costs';

  @override
  String get payment => 'Pago';

  @override
  String get thereArentAnyStationsNearYourLocations =>
      'No hay estaciones cerca de tu ubicación.';

  @override
  String get sessionStarting => 'Inicio de sesión';

  @override
  String get sessionStopping => 'Detención de sesión';

  @override
  String get sessionEnded => 'Sesión finalizada';

  @override
  String get stationDoesntSupportSessions =>
      'Esta estación no admite el inicio de sesiones dentro de la aplicación. Utilice los controles de la estación para autenticarse e iniciar una sesión de carga.';

  @override
  String get stationOnlySupportsRfidCards =>
      'Esta estación solo admite el inicio de sesiones dentro de la aplicación con una tarjeta de crédito RFID.';

  @override
  String get stationOnlySupportsCreditCards =>
      'Esta estación solo admite iniciar sesiones dentro de la aplicación con una tarjeta de crédito.';

  @override
  String get weLoggedYouInAutomatically => 'Te registramos automáticamente.';

  @override
  String get cannotAddAPaymentMethod =>
      'No se puede agregar un método de pago a esta cuenta.';

  @override
  String get imAllPluggedInToTheEvStation =>
      'Estoy todo conectado a la estación de vehículos eléctricos';

  @override
  String get automaticallyDetectMyConnection =>
      'Detectar automáticamente mi conexión';

  @override
  String get findNearbyEvStations =>
      'Encuentra estaciones de vehículos eléctricos cercanas';

  @override
  String get chooseFromAListOfNearbyConnectors =>
      'Elija de una lista de conectores cercanos';

  @override
  String get accountCreated => 'Cuenta creada';

  @override
  String get youCanNowStartYourFirstCharge =>
      'Ahora puede iniciar la primera carga de su vehículo eléctrico.';

  @override
  String get youCanNowAddAPaymentMethod =>
      'Ahora puede agregar un método de pago y comenzar su primera carga de vehículo eléctrico.';

  @override
  String get countryIsRequired => 'Se requiere el País';

  @override
  String get streetIsRequired => 'Se requiere la calle';

  @override
  String get houseNumberIsRequired => 'Se requiere el número de casa';

  @override
  String get postCodeIsRequired => 'Se requiere el código postal';

  @override
  String get cityIsRequired => 'Se requiere la ciudad';

  @override
  String get firstNameRequired => 'Se requiere el nombre';

  @override
  String get lastNameRequired => 'Se requiere el apellido';

  @override
  String get emailRequired => 'El correo electronico es requerido';

  @override
  String get phoneNumberRequired => 'Se requiere número de teléfono';

  @override
  String get pleaseEnterAValidEmailAddress =>
      'Por favor, introduce una dirección de correo electrónico válida';

  @override
  String get passwordMustContain =>
      'La contraseña debe contener al menos 8 caracteres, con una letra, un número y un carácter especial.';

  @override
  String get acceptTermsAndConditions =>
      'Por favor acepte los términos y condiciones.';

  @override
  String get acceptPrivacyStatement =>
      'Por favor acepte la declaración de privacidad';

  @override
  String get country => 'País';

  @override
  String get street => 'Calle';

  @override
  String get houseNumberShort => 'No.';

  @override
  String get postCode => 'Código postal';

  @override
  String get cityTown => 'Ciudad/Pueblo';

  @override
  String get billingDetails => 'Detalles de facturación';

  @override
  String get billingAddress => 'Dirección de Envio';

  @override
  String get iAcceptThe => 'acepto el';

  @override
  String get termsOfService => 'Términos de servicio.';

  @override
  String get iUnderstandThat =>
      'Entiendo que --brandname-- procesará mis datos personales de acuerdo con los';

  @override
  String get privacyStatement => 'Declaracion de privacidad.';

  @override
  String get iWantToReceive =>
      'Deseo recibir boletines informativos sobre mi tarjeta de crédito y/o suscripción, y por la presente doy mi consentimiento para el procesamiento de mis datos personales para ello, como se describe en la';

  @override
  String get firstName => 'Nombre de pila';

  @override
  String get lastName => 'Apellido';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get createYourFreeAccount => 'Crea tu cuenta gratuita';

  @override
  String get blockCard => 'Bloqueo de tarjeta';

  @override
  String get unblockCard => 'Desbloquear tarjeta';

  @override
  String get inactive => 'Inactivo';

  @override
  String get identifier => 'Identificador';

  @override
  String get billingPlan => 'Plan de facturación';

  @override
  String get nameOnCard => 'Nombre en la tarjeta';

  @override
  String get card => 'Tarjeta';

  @override
  String get unknownAddress => 'Dirección desconocida';

  @override
  String get removeCard => 'Quitar tarjeta';

  @override
  String get areYouSureYouWantToRemoveCard =>
      '¿Estás seguro de que quieres eliminar la tarjeta?';

  @override
  String get areYouSureYouWantToBlockCardFrom =>
      '¿Estás seguro de que deseas bloquear la tarjeta?';

  @override
  String get thisActionCannotBeReversed =>
      'Esta acción no se puede revertir. Ya no podrás pagar en ninguna estación de carga con esta tarjeta.';

  @override
  String get yesRemoveCard => 'Sí, quitar tarjeta';

  @override
  String get yesBlockCard => 'Sí, bloquear tarjeta';

  @override
  String get cancel => 'Cancelar';

  @override
  String get editPaymentMethod => 'Editar método de pago';

  @override
  String get addPaymentMethod => 'Añadir método de pago';

  @override
  String get creditOrDebitCard => 'Tarjeta de crédito o débito';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get saveCard => 'Guardar tarjeta';

  @override
  String get cardVerificationRequired => 'Se requiere verificación de tarjeta';

  @override
  String get clickButton3dSecure =>
      'Después de hacer clic en el botón, será redirigido a su proveedor de pagos para la autenticación 3D Secure.';

  @override
  String get continueToAuthentication => 'Continuar con la autenticación';

  @override
  String get tdsSecureHelpsPreventFraud =>
      '3D-Secure (3DS) ayuda a prevenir el fraude al utilizar tarjetas de pago en línea.';

  @override
  String get cardSaved => 'Tarjeta guardada';

  @override
  String get cardRemoved => 'Tarjeta eliminada';

  @override
  String get cardFailedToSave =>
      'Fallo de Tarjeta no se pudo guardar. Inténtalo de nuevo.';

  @override
  String get hour => 'Hora';

  @override
  String get session => 'Sesión';

  @override
  String get hourIdleFee => 'Tarifa por hora inactiva';

  @override
  String get minWaitBeforeIdleFee =>
      'espera mínima antes de la tarifa de inactivida';

  @override
  String get name => 'Nombre';

  @override
  String get status => 'Estado';

  @override
  String get operatorKey => 'Operador';

  @override
  String get availableFacilities => 'Available facilities';

  @override
  String get carpoolParking => 'Aparcamiento compartido';

  @override
  String get wifi => 'Wifi';

  @override
  String get noSessionDataAvailable => 'No hay datos de sesión disponibles.';

  @override
  String get filterByMonth => 'Filtrar por mes';

  @override
  String get viewAllSessions => 'Ver todas las sesiones →';

  @override
  String get scheduledTariffNote =>
      'Una tarifa programada anula los precios de la tarifa base para un período de tiempo específico.';

  @override
  String get dynamicTariffNote =>
      'El precio dinámico se ajusta automáticamente en función del precio del mercado de energía (intervalo de 1 hora).';

  @override
  String get pricing => 'Precios';

  @override
  String get baseTariff => 'Tarifa básica';

  @override
  String get dynamicTariff => 'Tarifa dinámica';

  @override
  String get activeNow => 'ACTIVO AHORA';

  @override
  String get viewAllHourlyPrices => 'Ver todos los precios por hora';

  @override
  String get hourlyPrices => 'Precios por hora';

  @override
  String get tariffNotes => 'Notas de las tarifas';

  @override
  String get viewTariffNotes => 'Ver notas de las tarifas';

  @override
  String get active => 'Activo';

  @override
  String get noConnectorDataAvailable => 'No hay datos de conector disponibles';

  @override
  String get hotel => 'Hotel';

  @override
  String get restaurant => 'Restaurante';

  @override
  String get cafe => 'Cafetería';

  @override
  String get mall => 'Centro comercial';

  @override
  String get supermarket => 'Supermercado';

  @override
  String get sport => 'Deporte';

  @override
  String get recreationArea => 'Área recreativa';

  @override
  String get nature => 'Naturaleza';

  @override
  String get museum => 'Museo';

  @override
  String get bikeSharing => 'Bicicleta compartida';

  @override
  String get busStop => 'Parada de autobús';

  @override
  String get taxiStand => 'Parada de taxi';

  @override
  String get tramStop => 'Parada de tranvía';

  @override
  String get metroStation => 'Estación de metro';

  @override
  String get trainStation => 'Estación de tren';

  @override
  String get airport => 'Aeropuerto';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get alongMotorway => 'A lo largo de la autopista';

  @override
  String get parkingGarage => 'Parking Garaje ';

  @override
  String get parkingLot => 'Estacionamiento';

  @override
  String get onDriveway => 'En la entrada';

  @override
  String get onStreet => 'En la calle';

  @override
  String get undergroundGarage => 'Garaje subterráneo';

  @override
  String get fuelStation => 'Gasolinera';

  @override
  String inaccurateTariffWarning(String appName) {
    return 'Las tarifas que se muestran aquí han sido enviadas a E-Flux por el socio de roaming. La informacion precisa puede variar según el proveedor.';
  }

  @override
  String get somethingWentWrongPleaseTryAgainLater =>
      'Algo salió mal. Por favor, inténtelo de nuevo más tarde.';

  @override
  String hAndMin(num hours, num minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    return '${hoursString}h ${minutes}min';
  }

  @override
  String get lessThanAMinute => 'menos de un minuto';

  @override
  String nDays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString días',
      one: '1 día',
      zero: '0 días',
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
      other: '$countString horas',
      one: '1 hora',
      zero: '0 horas',
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
      other: '$countString minutos',
      one: '1 minuto',
      zero: '0 minutos',
    );
    return '$_temp0';
  }

  @override
  String get noTariffAvailable => 'No hay tarifa disponible';

  @override
  String get unknownKW => 'kW desconocidos';

  @override
  String get cardDetailsUnavailable => 'Detalles de la tarjeta no disponibles';

  @override
  String get ok => 'DE ACUERDO';

  @override
  String get somethingWentWrong => 'Algo salió mal:';

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
  String get sendCode => 'Enviar código';

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
  String get youreAllReadyToBegin =>
      'Ya está todo listo para comenzar su primera sesión de carga.';

  @override
  String get startYouFirstEVCharge =>
      'Inicie su primera carga de vehículo eléctrico';

  @override
  String get locationServicesAreDisabled =>
      'Los servicios de ubicación están deshabilitados. Abra la configuración y habilite los servicios de ubicación.';

  @override
  String get skip => 'Saltar →';

  @override
  String get openSettings => 'Abra Configuración ';

  @override
  String get locationPermissionsHaveBeenDenied =>
      'Se han denegado los permisos de ubicación para esta aplicación. El rendimiento de esta aplicación se verá gravemente afectado sin este permiso. Abra la configuración y permita permisos de ubicación.';

  @override
  String get continueStr => 'Continuar';

  @override
  String get byAllowingLocationServices =>
      'Al permitir los servicios de ubicación, podemos determinar las estaciones de carga más cercanas a usted.';

  @override
  String get findAllAvailableChargeStationsNearby =>
      'Encuentra todas las estaciones de carga disponibles cercanas';

  @override
  String get getStarted => 'Empezar';

  @override
  String get letsGetYouStarted =>
      'Comencemos con la aplicación de carga más fácil y rápida.';

  @override
  String get eVWallet => 'Cartera para vehículos eléctricos';

  @override
  String get signupForAnAccount => 'Regístrese para obtener una cuenta';

  @override
  String get forgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get password => 'Contraseña';

  @override
  String get eMail => 'Correo electrónico';

  @override
  String get priceUnknown => 'precio desconocido';

  @override
  String get youHaventChargedYourEVYet =>
      'Aún no has cargado tu vehículo eléctrico.';

  @override
  String get cardRfid => 'Tarjeta (RFID)';

  @override
  String get youDontHaveAnyPaymentMethodsYet =>
      'Aún no tienes ningún método de pago.';

  @override
  String get sessions => 'Sesiones';

  @override
  String get paymentMethods => 'Métodos de pago';

  @override
  String get paymentsAndSessions => 'Pagos y Sesiones';

  @override
  String get wallet => 'Cartera';

  @override
  String get locationServicesHaveBeenDisabledForThisApp =>
      'Los servicios de ubicación se han desactivado para esta aplicación. Habilítelos en la configuración de su dispositivo.';

  @override
  String get locationPermissionGranted => 'Permiso de ubicación concedido';

  @override
  String
  get locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings =>
      'Permiso de ubicación denegado para esta aplicación. Habilítelo en la configuración de su dispositivo.';

  @override
  String get requestPermission => 'Pedir permiso';

  @override
  String get grantLocationPermissionToUseThisFeature =>
      'Conceder permiso de ubicación para utilizar esta función';

  @override
  String get initialisingLocationService =>
      'Iniciando servicio de ubicación...';

  @override
  String get findEVChargingLocations =>
      'Encuentre ubicaciones de carga de vehículos eléctricos';

  @override
  String get exploreStations => 'Explorar estaciones';

  @override
  String get viewWallet => 'Ver cartera';

  @override
  String get startAChargeSession => 'Iniciar una sesión de carga';

  @override
  String get charging => 'Cargando';

  @override
  String get clickTheButtonBelow => 'Haga clic en el botón de abajo';

  @override
  String get startYourEVCharge => 'Comience la carga de su vehículo eléctrico';

  @override
  String get searchLocation => 'Buscar ubicación';

  @override
  String get getDirections => 'Obtener las direcciones';

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
      'Intenta buscar otra ubicación →';

  @override
  String get noChargeStationsFound => 'No se encontraron estaciones de carga';

  @override
  String get myCurrentPosition => 'Mi posición actual';

  @override
  String get useMyCurrentPosition => 'Usar mi puesto actual';

  @override
  String get searchAddressOrPlaceName => 'Buscar dirección o nombre de lugar';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get connectorType => 'tipo de conector';

  @override
  String get chargingPowerkW => 'Potencia de carga [kW]';

  @override
  String get chargers => 'Cargadores';

  @override
  String get dCChargers => 'Cargadores rápidos';

  @override
  String get availableChargers => 'Cargadores disponibles';

  @override
  String get onlyShow => 'Sólo mostrar';

  @override
  String get filters => 'Filtros';

  @override
  String get findMoreStationsNearby => 'Encuentra más estaciones cercanas →';

  @override
  String get findStationsNearby => 'Find stations nearby →';

  @override
  String get highwayModeAvailableWhileDriving =>
      'Highway mode is available while driving outside of city speed limits.';

  @override
  String get youCanAlwaysFindNearbyStations =>
      'You can always find nearby stations on our map.';

  @override
  String get nearbyStations => 'Estaciones cercanas';

  @override
  String get selectYourChargeStation => 'Selecciona tu estación de carga';

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get unnamedCard => 'tarjeta sin nombre';

  @override
  String get noCardsAvailable => 'No hay tarjetas disponibles';

  @override
  String get startSession => 'Iniciar sesión';

  @override
  String get unknownEVSEID => 'ID EVSE desconocido';

  @override
  String get startChargingSession => 'Iniciar sesión de carga';

  @override
  String get exploreOrSearchForALocation => 'Explora o busca una ubicación →';

  @override
  String get thereArentAnyStationsNearYou =>
      'No hay estaciones cerca de tu ubicación. La búsqueda automática de ubicación aún está en progreso y detectará estaciones cercanas a usted a medida que se acerque a ellas hasta que cierre esta pantalla.';

  @override
  String get noStationsFound => 'No se encontraron estaciones.';

  @override
  String get selectStation => 'Seleccionar estación';

  @override
  String get evseId => 'ID EVSE';

  @override
  String get manualStationInput => 'Entrada manual de estación';

  @override
  String get manualEVSEIDInput => 'Entrada manual de ID de EVSE →';

  @override
  String get noSelectDifferentStation => 'No, seleccione otra estación →';

  @override
  String get yesThisIsMe => '¡Sí este soy yo!';

  @override
  String get isThisYou => '¿Este Eres tu?';

  @override
  String get imAllPluggedIn => '¡Estoy todo conectado!';

  @override
  String get close => 'Cerca';

  @override
  String get endSession => 'Finalizar sesión';

  @override
  String get yourCarIsCharging => 'Tu coche se está cargando';

  @override
  String get unknownKWh => 'kWh desconocido';

  @override
  String get profile => 'Perfil';

  @override
  String get account => 'Cuenta';

  @override
  String get login => 'Acceso';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get helpAndSupport => 'Servicio de asistencia';

  @override
  String get cancelSubscription => 'Cancelar suscripción';

  @override
  String get removeAccount => 'Eliminar cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get directPayments => 'Pagos Directos';

  @override
  String get chargingCardOrTag => 'Tarjeta de carga o etiqueta';

  @override
  String get withoutAdditionalFeePerSession => 'Sin cargo adicional por sesión';

  @override
  String get supportsRemoteCharge => 'Admite carga desde la App';

  @override
  String get additionalFee => 'Tarifa adicional';

  @override
  String get favouriteStations => 'Estaciones favoritas';

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
  String get totalSessions => 'Total de sesiones';

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
  String get carScreenFastChargersAhead => 'Cargadores rápidos adelante';

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
  String get selectNetworks => 'Sólo red seleccionada';

  @override
  String get excludeNetworks => 'Ocultar redes seleccionadas';

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
