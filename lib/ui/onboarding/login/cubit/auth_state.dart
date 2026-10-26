part of 'auth_cubit.dart';

enum TwoFactorAuthMethod {
  appAuth,
  smsAuth;

  String get backendRepresentation {
    switch (this) {
      case TwoFactorAuthMethod.appAuth:
        return 'otp';
      case TwoFactorAuthMethod.smsAuth:
        return 'sms';
    }
  }

  static TwoFactorAuthMethod? fromString(String stringRepresentation) {
    switch (stringRepresentation) {
      case 'otp':
        return TwoFactorAuthMethod.appAuth;
      case 'sms':
        return TwoFactorAuthMethod.smsAuth;
      default:
        return null;
    }
  }
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.showSplash({@Default(UIFlow.established()) UIFlow flow}) = ShowSplash;
  const factory AuthState.loggedOut(
      {ProviderResponseModel? providerModel,
      TwoFactorAuth? twoFactorAuth,
      @Default(false) bool sessionExpired,
      @Default(UIFlow.established()) UIFlow flow}) = LoggedOut;
  const factory AuthState.loggedIn(AccountDetailsModel profile, String token,
      {@Default(false) bool sessionEnding, @Default(UIFlow.established()) UIFlow flow}) = LoggedIn;
}

@freezed
sealed class TwoFactorAuth with _$TwoFactorAuth {
  const factory TwoFactorAuth.authenticatorApp(
      {required String mfaToken,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthOtp;
  const factory TwoFactorAuth.sms(
      {required String mfaToken,
      required String mfaPhoneNumber,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthSms;
  const factory TwoFactorAuth.useBackupCode(
      {required String mfaToken,
      required String? mfaPhoneNumber, // Set if the user is using SMS, null if using authenticator app
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthUseBackupCode;

  // ── Decision-engine members (`/1/auth/mfa/*`). The single-use handle inside
  // [challenge] / [enrolment] is the credential — there is no mfaToken. ──

  /// The user has several usable factor types — pick one to verify with.
  const factory TwoFactorAuth.methodPicker(
      {required MfaPendingChallengeModel challenge,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthMethodPicker;

  /// Enter the code from the authenticator app (no arming round-trip needed).
  const factory TwoFactorAuth.pendingTotp(
      {required MfaPendingChallengeModel challenge,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthPendingTotp;

  /// A code was texted to the masked [hint] number; re-arming resends it.
  /// [nextSendAfterSeconds] is the server-enforced resend spacing at the time
  /// of the last send (or refused resend) — the widget counts it down.
  const factory TwoFactorAuth.pendingSms(
      {required MfaPendingChallengeModel challenge,
      String? hint,
      int? nextSendAfterSeconds,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthPendingSms;

  /// Verify with a passkey. The widget auto-starts one ceremony and offers a
  /// retry button — every attempt re-arms (ceremony ids are single-use).
  /// [noCredential] flags that a ceremony already failed because this device
  /// holds no passkey for the account and no other factor can absorb the
  /// fallback — the widget swaps the copy for a dead-end explanation.
  const factory TwoFactorAuth.pendingPasskey(
      {required MfaPendingChallengeModel challenge,
      @Default(false) bool noCredential,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthPendingPasskey;

  /// Lost-factor fallback: enter a single-use recovery code.
  const factory TwoFactorAuth.pendingRecoveryCode(
      {required MfaPendingChallengeModel challenge,
      String? smsHint, // Restored when navigating back to the SMS entry screen.
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthPendingRecoveryCode;

  /// Email-verification step-up: prove control of the account email to finish
  /// the sign-in (no factor enrolled). [pendingId] lives in its own handle
  /// namespace, valid only on the `verify-email` endpoints.
  const factory TwoFactorAuth.verifyEmail(
      {required String pendingId,
      int? nextSendAfterSeconds,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthVerifyEmail;

  /// Login-time enrolment: explain why a factor is needed; Skip only under
  /// [MfaMode.encourage]. Continuing sends the email-proof code.
  const factory TwoFactorAuth.enrolIntro(
      {required MfaEnrolmentModel enrolment,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolIntro;

  /// Enter the emailed proof-of-control code to unlock factor enrolment.
  const factory TwoFactorAuth.enrolEmailProof(
      {required MfaEnrolmentModel enrolment,
      int? nextSendAfterSeconds,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolEmailProof;

  /// Several factor types may be enrolled — pick one.
  const factory TwoFactorAuth.enrolMethodPicker(
      {required MfaEnrolmentModel enrolment,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolMethodPicker;

  /// Scan/enter the authenticator secret, then confirm with a code.
  const factory TwoFactorAuth.enrolTotp(
      {required MfaEnrolmentModel enrolment,
      required MfaEnrolTotpBeginModel totp,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolTotp;

  /// A code was texted to the account phone ([hint]); confirm to activate.
  const factory TwoFactorAuth.enrolSms(
      {required MfaEnrolmentModel enrolment,
      required String factorId,
      String? hint,
      int? nextSendAfterSeconds,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolSms;

  /// Create a passkey to finish enrolment. The widget auto-starts one
  /// ceremony and offers a retry button — every attempt re-begins (creation
  /// challenges are single-use). [deviceHasPasskey] flags a refused
  /// registration because this device already holds a passkey for the
  /// account (`excludeCredentials` match).
  const factory TwoFactorAuth.enrolPasskey(
      {required MfaEnrolmentModel enrolment,
      @Default(false) bool deviceHasPasskey,
      required String email,
      required ProviderResponseModel providerModel}) = TwoFactorAuthEnrolPasskey;

  const TwoFactorAuth._();
}

extension IsLoggedIn on AuthState {
  bool get isLoggedIn => this is LoggedIn;

  bool get canAddCreditCard {
    if (!F.isRemoteChargeEnabled) {
      return false;
    }

    return switch (this) {
      LoggedIn(:final profile) => profile.canAddCreditCard,
      _ => false,
    };
  }

  TwoFactorAuthMethod? get mfaMethod {
    return switch (this) {
      LoggedIn(:final profile) => profile.mfaMethod == null ? null : TwoFactorAuthMethod.fromString(profile.mfaMethod!),
      _ => null,
    };
  }

  String? get accountEmail {
    return switch (this) {
      LoggedIn(:final profile) => profile.email,
      _ => null,
    };
  }

  /// Returns the list of party IDs enabled for remote charging sessions.
  /// Falls back to ['EFL'] if not logged in or if the field is not set.
  List<String> get remoteSessionEnabledPartyIds {
    return switch (this) {
      LoggedIn(:final profile) => profile.remoteSessionEnabledPartyIds,
      _ => const ['EFL'],
    };
  }
}

extension ExternalLinks on AuthState {
  Uri? get tosUrl {
    final tosString = switch (this) {
      LoggedIn(:final profile) => profile.termsOfServiceUrl,
      LoggedOut(:final providerModel) => providerModel?.tosUrl,
      _ => null,
    };

    if (tosString == null) {
      return null;
    }

    if (tosString.startsWith('http')) {
      return Uri.tryParse(tosString);
    }

    return Uri.tryParse('https://$tosString');
  }

  Uri? get privacyUrl {
    final privacyString = switch (this) {
      LoggedIn(:final profile) => profile.privacyUrl,
      LoggedOut(:final providerModel) => providerModel?.privacyUrl,
      _ => null,
    };

    if (privacyString == null) {
      return null;
    }

    if (privacyString.startsWith('http')) {
      return Uri.tryParse(privacyString);
    }

    return Uri.tryParse('https://$privacyString');
  }

  Uri? get aboutUsUrl {
    final aboutUsString = switch (this) {
      LoggedIn(:final profile) => profile.aboutUsUrl,
      LoggedOut(:final providerModel) => providerModel?.csuiAboutUrl,
      _ => null,
    };

    if (aboutUsString == null) {
      return null;
    }

    if (aboutUsString.startsWith('http')) {
      return Uri.tryParse(aboutUsString);
    }

    return Uri.tryParse('https://$aboutUsString');
  }

  Uri? get csuiSupportUrl {
    final supportString = switch (this) {
      LoggedIn(:final profile) => profile.helpAndSupportUrl,
      LoggedOut(:final providerModel) => providerModel?.supportUrl ?? providerModel?.csuiSupportUrl,
      _ => null,
    };

    if (supportString == null) {
      return null;
    }

    if (supportString.startsWith('http')) {
      return Uri.tryParse(supportString);
    }

    return Uri.tryParse('https://$supportString');
  }

  Uri? get customDomain {
    final customDomainString = switch (this) {
      LoggedIn(:final profile) => profile.customDomain,
      LoggedOut(:final providerModel) => providerModel?.customDomain,
      _ => null,
    };

    if (customDomainString == null) {
      return null;
    }

    if (customDomainString.startsWith('http')) {
      return Uri.tryParse(customDomainString);
    }

    return Uri.tryParse('https://$customDomainString');
  }

  Uri? get forgotPasswordUrl {
    final baseDomain = customDomain;
    return baseDomain?.replace(path: '/password/forgot');
  }
}
