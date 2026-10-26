import 'dart:async';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/account/account_self_response_model.dart';
import 'package:road_mobile/data/model/mobile_features/mobile_user_summary_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/intercom/intercom_utils.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_session_renewer.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/services/storage/persistent_prefs.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import '../../../../data/model/login/login_response_model.dart';
import '../../../../data/model/login/mfa_enrol_totp_begin_model.dart';
import '../../../../data/model/login/mfa_method.dart';
import '../../../../data/model/login/mfa_session_model.dart';
import '../../../../services/network/auth_storage.dart';
import '../../../../data/model/account/account_details_model.dart';
import '../model/mfa_error_code.dart';
import 'auth_repository.dart';
import 'mfa_repository.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

enum UpdateBillingDetailsError {
  invalidPostcode,
  apiError;

  static UpdateBillingDetailsError? fromString(String error) {
    switch (error) {
      case 'SIGNUP_INVALID_POSTAL_CODE_FOR_COUNTRY':
        return UpdateBillingDetailsError.invalidPostcode;
      default:
        return null;
    }
  }
}

/// Outcome of a code-verify attempt, for the code-entry widgets' inline
/// handling. The const singletons keep enum-style `==` comparisons working;
/// [TwoFactorAuthRateLimited] carries the wait and is matched with `is`.
sealed class TwoFactorAuthResult {
  const TwoFactorAuthResult();

  static const TwoFactorAuthResult success = _TwoFactorAuthSuccess();
  static const TwoFactorAuthResult wrongCode = _TwoFactorAuthWrongCode();
  static const TwoFactorAuthResult error = _TwoFactorAuthError();

  /// The code in hand can never verify (exhausted/expired/not armed) —
  /// steer the user to request a new one instead of retrying.
  static const TwoFactorAuthResult codeExhausted = _TwoFactorAuthCodeExhausted();
}

class _TwoFactorAuthSuccess extends TwoFactorAuthResult {
  const _TwoFactorAuthSuccess();
}

class _TwoFactorAuthWrongCode extends TwoFactorAuthResult {
  const _TwoFactorAuthWrongCode();
}

class _TwoFactorAuthError extends TwoFactorAuthResult {
  const _TwoFactorAuthError();
}

class _TwoFactorAuthCodeExhausted extends TwoFactorAuthResult {
  const _TwoFactorAuthCodeExhausted();
}

/// Too many wrong guesses at a factor that sends nothing (TOTP, recovery
/// code): only waiting [retryAfterSeconds] helps.
class TwoFactorAuthRateLimited extends TwoFactorAuthResult {
  const TwoFactorAuthRateLimited(this.retryAfterSeconds);

  final int retryAfterSeconds;
}

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final MfaRepository _mfaRepository;
  final PasskeyService _passkeyService;
  final VerificationRepository _verificationRepo;
  final AuthStorage _storage;
  final SharedPreferences _prefs;
  final Analytics? _analytics;
  final MixpanelService _mixpanelService;
  final SessionRenewalTokenStorage _renewalStorage;
  final AuthSessionRenewer _renewer;
  final AuthLifecycleBus _lifecycleBus;

  StreamSubscription<FGBGType>? _fgbgSubscription;
  StreamSubscription<AuthLifecycleEvent>? _lifecycleSubscription;

  // One-shot gate so the "session ending" snackbar only renders once per
  // logged-in session, regardless of how many `X-Token-Status: ending`
  // headers the API sends. Reset whenever a fresh session begins (login,
  // refresh, renewal) or ends (logout).
  bool _sessionEndingNoticeShown = false;

  // Guards against concurrent SessionRevoked events (the interceptor publishes
  // one per 401 it couldn't recover) stacking multiple logouts.
  bool _revoking = false;

  // Bumped by [cancelConditionalPasskeyLogin] and on every conditional-login
  // start. A cancel that lands while [startConditionalPasskeyLogin] is still
  // fetching the challenge finds no ceremony to abort on the PasskeyService,
  // so the cubit itself must notice the stale generation and stop before
  // parking a ceremony the form no longer expects.
  int _conditionalLoginGeneration = 0;

  AuthCubit(
    this._repository,
    this._mfaRepository,
    this._passkeyService,
    this._verificationRepo,
    this._storage,
    this._prefs,
    this._analytics,
    this._mixpanelService,
    this._renewalStorage,
    this._renewer,
    this._lifecycleBus,
  ) : super(const AuthState.showSplash()) {
    moveToInitialAppState();
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      if (event == FGBGType.foreground) {
        _refreshAccountDetails();
      } else if (event == FGBGType.background) {
        // Flush Mixpanel events when app goes to background
        _mixpanelService.flush();
      }
    });
    _lifecycleSubscription = _lifecycleBus.stream.listen(_onLifecycleEvent);
  }

  void _onLifecycleEvent(AuthLifecycleEvent event) async {
    final current = state;
    switch (event) {
      case TokenRotated(:final token):
        // A new JWT is a new "near-expiry" window — re-arm the notice.
        _sessionEndingNoticeShown = false;
        if (current is LoggedIn) {
          emit(current.copyWith(token: token));
        }
      case SessionRenewed(:final token):
        // Rotate the in-state token if we're already in LoggedIn. The
        // app-start case (renewal fires while we're in ShowSplash or
        // LoggedOut) is intentionally a no-op here: moveToInitialAppState
        // is already in flight and will re-read the freshly stored auth
        // token from AuthStorage before emitting LoggedIn itself, so we
        // don't need a duplicate state transition from this event.
        _sessionEndingNoticeShown = false;
        if (current is LoggedIn) {
          emit(current.copyWith(token: token));
        }
      case SessionEnding():
        // Only surface a notice when the user can't be silently renewed.
        // With a biometric renewal token stored, expiry is seamless. The
        // `_sessionEndingNoticeShown` gate is needed because the API can
        // send `X-Token-Status: ending` on every response during the
        // tail of a session — we want one snackbar, not one per request.
        if (_sessionEndingNoticeShown || current is! LoggedIn) return;
        if (await _renewalStorage.isAvailable()) return;
        // Re-check after the await: the cubit may have closed, or the state
        // may have moved on (e.g. logout) while the biometric-availability
        // check was in flight. Emitting on a closed cubit throws, and
        // copying `current` would clobber a newer state.
        if (isClosed) return;
        final latest = state;
        if (latest is! LoggedIn) return;
        _sessionEndingNoticeShown = true;
        emit(latest.copyWith(sessionEnding: true));
      case SessionRevoked(:final expired):
        // The interceptor publishes this once per request it couldn't recover,
        // so a foreground burst can fire several. Collapse to a single logout.
        if (_revoking || current is! LoggedIn) return;
        _revoking = true;
        try {
          await logout(sessionExpired: expired);
        } finally {
          _revoking = false;
        }
    }
  }

  /// Clears the [LoggedIn.sessionEnding] flag so the notice is shown once.
  void acknowledgeSessionEnding() {
    final current = state;
    if (current is LoggedIn && current.sessionEnding) {
      emit(current.copyWith(sessionEnding: false));
    }
  }

  @override
  Future<void> close() {
    _fgbgSubscription?.cancel();
    _fgbgSubscription = null;
    _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    return super.close();
  }

  void moveToInitialAppState() async {
    try {
      AccountDetailsModel? accountDetails = AccountDetailsModel.fromSharedPrefs(_prefs);
      String? token = await _storage.readAuthToken();

      // No live token but a biometric-protected renewal token is stored —
      // attempt silent renewal before falling through to the login screen.
      if (token == null && accountDetails != null && await _renewalStorage.isAvailable()) {
        final outcome = await _renewer.tryRenew();
        if (outcome == RenewOutcome.renewed) {
          token = await _storage.readAuthToken();
        }
      }

      if (token != null && accountDetails != null) {
        IntercomUtils.loginWithUserDetails(
            userIdString: accountDetails.userId, emailString: accountDetails.email);
        // Re-identify user in Mixpanel on app launch
        if (accountDetails.userId != null) {
          _mixpanelService.identify(accountDetails.userId!, email: accountDetails.email);
          _mixpanelService.flush();
        }
        emit(AuthState.loggedIn(accountDetails, token));
        // Backfill fields added after this SharedPrefs blob was written (e.g. billingCurrency
        // for users who logged in before the field existed). Fire-and-forget so boot isn't
        // blocked; falls back to cached values on failure.
        if (accountDetails.billingCurrency == null) {
          _refreshAccountDetails();
        }
      } else {
        IntercomUtils.loginWithUserDetails(userIdString: null, emailString: null);
        emit(const AuthState.loggedOut());
        final providerModel = await getProvider();
        emit(AuthState.loggedOut(providerModel: providerModel));
      }
    } catch (e) {
      _analytics?.logErrorEvent('initial_app_state', e.toString());
      IntercomUtils.loginWithUserDetails(userIdString: null, emailString: null);
      emit(const AuthState.loggedOut());
      final providerModel = await getProvider();
      emit(AuthState.loggedOut(providerModel: providerModel));
    }
  }

  Future<ProviderResponseModel?> getProvider() async {
    ProviderResponseModel? providerModel;
    try {
      final providerName = getIt<DebugControlsRepo>().providerSlugOverride ?? F.providerName;
      providerModel = await _repository.getProvider(providerName);
      _storage.storeProviderId(providerModel.id);
    } catch (e) {
      log('Error getting provider: $e');
    }

    return providerModel;
  }

  void loginScreenClosedByUser() async {
    final currentState = state;
    if (currentState is LoggedOut && currentState.twoFactorAuth != null) {
      // Let the modal's pop animation finish before clearing the 2FA sub-state,
      // so the login screen doesn't flash back to email/password mid-dismissal.
      await Future.delayed(const Duration(milliseconds: 500));
      // Re-read the state: an event may have fired during the delay, and
      // emitting the pre-delay snapshot would clobber it.
      final latest = state;
      if (isClosed || latest is! LoggedOut) return;
      emit(latest.copyWith(twoFactorAuth: null));
    }
  }

  /// Passwordless passkey sign-in (spec §6): one usernameless ceremony — the
  /// OS picks the account from the credentials it holds for the rpId — and
  /// the assertion alone yields a full session (a passkey satisfies MFA
  /// outright). Called from the login form's passkey affordances; never
  /// auto-run. Returns true when the session completed.
  Future<bool> loginWithPasskey({ProviderResponseModel? existingProvider}) async {
    emit(state.copyWith(flow: const UIFlow.loading()));

    final providerModel = existingProvider ?? await getProvider();
    if (isClosed) return false;
    if (providerModel == null) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Provider not found.'))));
      return false;
    }

    try {
      final challenge = await _repository.beginPasskeyLogin(providerId: providerModel.id);
      if (isClosed) return false;
      final ceremonyId = challenge.ceremonyId;
      final options = challenge.options;
      if (ceremonyId == null || options == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyChallengeMissing())));
        return false;
      }
      final response = await _passkeyService.get(options);
      if (isClosed) return false;
      final session = await _repository.completePasskeyLogin(ceremonyId: ceremonyId, response: response);
      if (isClosed) return false;
      // No email to hand over — the completion falls back to the profile's.
      final result = await _completeMfaSession(session, providerModel: providerModel);
      return result == TwoFactorAuthResult.success;
    } on PasskeyException catch (e) {
      if (isClosed) return false;
      switch (e.type) {
        case PasskeyErrorType.cancelled:
          // A dismissed OS sheet is silent — the button is the retry
          // affordance.
          emit(state.copyWith(flow: const UIFlow.established()));
        case PasskeyErrorType.noCredential:
          // Unlike the MFA verify path there is no pending sign-in to fall
          // back within — steer back to email and password.
          emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyNoneOnDevice())));
        case PasskeyErrorType.excludedCredentialExists:
        case PasskeyErrorType.unsupported:
        case PasskeyErrorType.securityError:
          log('Passwordless passkey ceremony failed: $e');
          emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyVerificationFailed())));
      }
      return false;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Parks the web-parity *conditional UI* passwordless sign-in behind the
  /// login form (iOS): the OS offers a passkey over the focused email field
  /// only when the keychain holds one for the rpId — the keychain is the
  /// oracle, never the server. Silent by design up to selection: arm
  /// failures, no-passkey, unsupported platforms and dismissals all resolve
  /// to false with no UI. Once the user picks a passkey, failures surface
  /// like any sign-in error. The parked ceremony ends via
  /// [cancelConditionalPasskeyLogin] (form dispose) or is superseded by any
  /// modal ceremony starting. Returns true when a session completed.
  Future<bool> startConditionalPasskeyLogin({ProviderResponseModel? existingProvider}) async {
    final generation = ++_conditionalLoginGeneration;
    // Cancellation before the ceremony is parked no-ops on the PasskeyService,
    // so every await up to [PasskeyService.getConditional] must re-check the
    // generation, or a dispose-time cancel races the challenge fetch and the
    // ceremony parks anyway, lingering past the form.
    bool cancelled() => isClosed || generation != _conditionalLoginGeneration;

    if (!_passkeyService.supportsConditionalUi || !await _passkeyService.isSupported()) {
      return false;
    }
    if (cancelled()) return false;
    final providerModel = existingProvider ?? await getProvider();
    if (cancelled() || providerModel == null) return false;

    final String ceremonyId;
    final Map<String, dynamic> response;
    try {
      final challenge = await _repository.beginPasskeyLogin(providerId: providerModel.id);
      if (cancelled()) return false;
      final options = challenge.options;
      if (challenge.ceremonyId == null || options == null) return false;
      ceremonyId = challenge.ceremonyId!;
      response = await _passkeyService.getConditional(options);
    } on PasskeyException {
      return false;
    } on RMApiError {
      // Rate-limited or passkey disallowed — the form stays as it is.
      return false;
    }
    // Deliberately not a [cancelled] check: a passkey pick that raced the
    // form's dispose is still a completed user gesture, and completing the
    // session is what the pick promised.
    if (isClosed) return false;

    // The user actively picked a passkey — from here failures surface.
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final session = await _repository.completePasskeyLogin(ceremonyId: ceremonyId, response: response);
      if (isClosed) return false;
      final result = await _completeMfaSession(session, providerModel: providerModel);
      return result == TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Ends a parked conditional ceremony (login form dispose), so it cannot
  /// linger and contend with a later ceremony. Safe when none is parked.
  /// Also invalidates a [startConditionalPasskeyLogin] still on its way to
  /// parking one, which the PasskeyService cancel cannot reach yet.
  Future<void> cancelConditionalPasskeyLogin() {
    _conditionalLoginGeneration++;
    return _passkeyService.cancelCeremony();
  }

  /// Returns true if login was successful, false otherwise (including state change to MFA).
  Future<bool> performLogin(String email, String password, {ProviderResponseModel? existingProvider}) async {
    // Check email field actually contains an email address
    if (!EmailValidator.validate(email)) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Please enter a valid email address.'))));
      return false;
    }

    // Check password field is not empty
    if (password.isEmpty) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Please enter a password.'))));
      return false;
    }

    emit(state.copyWith(flow: const UIFlow.loading()));

    var providerModel = existingProvider;
    providerModel ??= await getProvider();

    if (providerModel == null) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Provider not found.'))));
      return false;
    }

    try {
      // The repository unconditionally requests a renewal token. The
      // biometric capability check and any prompt is deferred to
      // _persistDeviceAndRenewalTokens, after the network round-trip,
      // so the OS Face ID permission dialog can't fire before the user
      // has even submitted the form.
      LoginResponseModel response = await _repository.login(email, password: password);

      await _persistDeviceAndRenewalTokens(
        deviceToken: response.deviceToken,
        sessionRenewalToken: response.sessionRenewalToken,
      );

      final jwtToken = response.token;

      if (jwtToken != null) {
        return await _performPostLoginActions(email: email, jwtToken: jwtToken, providerModel: providerModel);
      }

      // Decision-engine outcomes: the sign-in passed the password but the
      // session is withheld behind a factor (verify / enrol / verify-email).
      final mfaChallenge = response.mfa;
      if (mfaChallenge != null) {
        await _startMfaChallenge(mfaChallenge, email: email, providerModel: providerModel);
        return false;
      }

      final mfaEnrolment = response.mfaEnrolment;
      if (mfaEnrolment != null) {
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth:
                TwoFactorAuth.enrolIntro(enrolment: mfaEnrolment, email: email, providerModel: providerModel)));
        return false;
      }

      final mfaVerifyEmail = response.mfaVerifyEmail;
      if (mfaVerifyEmail != null) {
        await _startMfaVerifyEmail(mfaVerifyEmail.pendingId, email: email, providerModel: providerModel);
        return false;
      }

      // Legacy 2FA flow (`user.mfaMethod`) starts here
      if (response.mfaRequired != true) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No token provided.'))));
        return false;
      }

      final mfaMethod = response.mfaMethod;
      final mfaToken = response.mfaToken;

      if (mfaMethod == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No mfa method provided.'))));
        return false;
      }

      if (mfaToken == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No mfa token provided.'))));
        return false;
      }

      if (response.mfaMethod == 'sms') {
        final mfaPhoneNumber = response.mfaPhoneNumber;

        if (mfaPhoneNumber == null) {
          emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No mfa phone number provided.'))));
          return false;
        }

        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth: TwoFactorAuth.sms(
                mfaToken: mfaToken, mfaPhoneNumber: mfaPhoneNumber, email: email, providerModel: providerModel)));

        await _send2FaCode(mfaToken);

        return false;
      } else if (response.mfaMethod == 'otp') {
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth:
                TwoFactorAuth.authenticatorApp(mfaToken: mfaToken, email: email, providerModel: providerModel)));
        return false;
      } else {
        emit(state.copyWith(
            flow: UIFlow.error(RMApiError(cause: 'This app does not support this MFA method yet: $mfaMethod'))));
        return false;
      }
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Completes the sign-in with the session issued by `POST /1/signup`,
  /// avoiding a password re-login that the MFA decision engine could
  /// interpose (policy applies from the next credential login). Signup
  /// issues no renewal token, so biometric session renewal also arms on
  /// that next login. Returns true when the session is established.
  Future<bool> completeSignupSession(
      {required String token, String? deviceToken, required String email}) async {
    emit(state.copyWith(flow: const UIFlow.loading()));

    final providerModel = await getProvider();
    if (isClosed) return false;
    if (providerModel == null) {
      emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'Provider not found.'))));
      return false;
    }

    await _persistDeviceAndRenewalTokens(deviceToken: deviceToken, sessionRenewalToken: null);
    if (isClosed) return false;
    return await _performPostLoginActions(email: email, jwtToken: token, providerModel: providerModel);
  }

  /// Returns true if 2FA and remainder of login was successful, false otherwise.
  Future<TwoFactorAuthResult> verify2FaCode(
      {required String mfaToken,
      required String email,
      required ProviderResponseModel providerModel,
      required String code}) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      await _storage.storeAuthToken(mfaToken);
      final loginResponse = await _repository.verify2faCode(code);
      await _persistDeviceAndRenewalTokens(
        deviceToken: loginResponse.data.deviceToken,
        sessionRenewalToken: loginResponse.data.sessionRenewalToken,
      );
      if (await _performPostLoginActions(
          email: email, jwtToken: loginResponse.data.token, providerModel: providerModel)) {
        return TwoFactorAuthResult.success;
      } else {
        return TwoFactorAuthResult.error;
      }
    } on RMApiError catch (e) {
      _storage.deleteAuthToken();
      if (e.cause == 'Not a valid code') {
        emit(state.copyWith(flow: const UIFlow.established()));
        return TwoFactorAuthResult.wrongCode;
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
      return TwoFactorAuthResult.error;
    }
  }

  Future<void> _send2FaCode(String mfaToken) async {
    try {
      await _storage.storeAuthToken(mfaToken);
      await _repository.send2faCode();
    } on RMApiError catch (e) {
      log('Error sending 2FA code: $e');
      emit(state.copyWith(flow: UIFlow.error(e)));
    } finally {
      await _storage.deleteAuthToken();
    }
  }

  void resend2FaCode(String mfaToken) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      await _storage.storeAuthToken(mfaToken);
      await _repository.send2faCode();
      emit(state.copyWith(flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    } finally {
      await _storage.deleteAuthToken();
    }
  }

  // ── MFA decision engine: verify an existing factor ──

  /// Device passkey capability, resolved before any decision-engine state is
  /// emitted so widgets can filter methods synchronously via
  /// [passkeySupported]. Device-static, hence never re-false'd.
  bool _passkeySupported = false;

  bool get passkeySupported => _passkeySupported;

  Future<void> _refreshPasskeySupport() async {
    try {
      _passkeySupported = await _passkeyService.isSupported();
    } catch (e) {
      log('Passkey support check failed: $e');
    }
  }

  Future<void> _startMfaChallenge(MfaPendingChallengeModel challenge,
      {required String email, required ProviderResponseModel providerModel}) async {
    await _refreshPasskeySupport();
    if (isClosed) return;
    final usable = challenge.methods.usableOnMobile(passkeySupported: _passkeySupported);

    if (usable.isEmpty) {
      emit(state.copyWith(
          flow: UIFlow.error(RMApiError(
              cause: 'None of your verification methods are supported in this app yet. '
                  'Please sign in on the web.'))));
      return;
    }

    if (usable.length == 1) {
      await _armMfaMethod(usable.single, challenge: challenge, email: email, providerModel: providerModel);
      return;
    }

    emit(AuthState.loggedOut(
        providerModel: providerModel,
        twoFactorAuth: TwoFactorAuth.methodPicker(challenge: challenge, email: email, providerModel: providerModel)));
  }

  /// From the method picker: arm and show the chosen factor.
  Future<void> selectMfaMethod(MfaMethod method) async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthMethodPicker) {
      log('Attempted to select an MFA method with no method picker active.');
      return;
    }
    await _armMfaMethod(method, challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel);
  }

  Future<void> _armMfaMethod(MfaMethod method,
      {required MfaPendingChallengeModel challenge,
      required String email,
      required ProviderResponseModel providerModel}) async {
    switch (method) {
      case MfaMethod.totp:
        // Nothing to arm — the code comes from the user's authenticator app.
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth:
                TwoFactorAuth.pendingTotp(challenge: challenge, email: email, providerModel: providerModel)));
      case MfaMethod.sms:
        emit(state.copyWith(flow: const UIFlow.loading()));
        try {
          final armed = await _mfaRepository.armChallenge(pendingId: challenge.pendingId, method: MfaMethod.sms);
          if (isClosed) return;
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth: TwoFactorAuth.pendingSms(
                  challenge: challenge,
                  hint: armed.hint,
                  nextSendAfterSeconds: armed.nextSendAfterSeconds,
                  email: email,
                  providerModel: providerModel)));
        } on RMApiError catch (e) {
          if (isClosed) return;
          // Send budgets are per user, not per sign-in, so even the first arm
          // can be refused. A code from an earlier send may still verify —
          // show the entry screen with the wait rather than a dead-end error.
          if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
            emit(AuthState.loggedOut(
                providerModel: providerModel,
                twoFactorAuth: TwoFactorAuth.pendingSms(
                    challenge: challenge,
                    nextSendAfterSeconds: e.retryAfterSeconds ?? _fallbackSendWaitSeconds,
                    email: email,
                    providerModel: providerModel)));
            return;
          }
          _handleMfaError(e);
        }
      case MfaMethod.passkey:
        // The widget auto-starts the ceremony (and owns the retry button);
        // arming happens per attempt in [verifyWithPasskey] because ceremony
        // ids are single-use.
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth:
                TwoFactorAuth.pendingPasskey(challenge: challenge, email: email, providerModel: providerModel)));
      case MfaMethod.recoveryCode:
      case MfaMethod.recoveryEmail:
      case MfaMethod.unknown:
        log('Attempted to arm unsupported MFA method: $method');
    }
  }

  /// Runs one full passkey verification: fresh arm, platform ceremony,
  /// verify, session. Called by the passkey step's widget (auto-start and
  /// retry button) — never re-run automatically. On success the state moves
  /// to [LoggedIn]; callers check `state.isLoggedIn` to decide whether to
  /// pop, like every other completing step.
  Future<void> verifyWithPasskey() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthPendingPasskey) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final armed =
          await _mfaRepository.armChallenge(pendingId: tfa.challenge.pendingId, method: MfaMethod.passkey);
      if (isClosed) return;
      final ceremonyId = armed.ceremonyId;
      final options = armed.options;
      if (ceremonyId == null || options == null) {
        emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyChallengeMissing())));
        return;
      }
      final response = await _passkeyService.get(options);
      if (isClosed) return;
      final session = await _mfaRepository.verifyPasskey(
          pendingId: tfa.challenge.pendingId, ceremonyId: ceremonyId, response: response);
      if (isClosed) return;
      await _completeMfaSession(session, email: tfa.email, providerModel: tfa.providerModel);
    } on PasskeyException catch (e) {
      if (isClosed) return;
      switch (e.type) {
        case PasskeyErrorType.cancelled:
          // §5.1b: a dismissed OS sheet is silent — the step's button offers
          // the retry.
          emit(state.copyWith(flow: const UIFlow.established()));
        case PasskeyErrorType.noCredential:
        case PasskeyErrorType.unsupported:
          await _fallBackFromPasskey(tfa);
        case PasskeyErrorType.excludedCredentialExists:
        case PasskeyErrorType.securityError:
          log('Passkey ceremony failed: $e');
          emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyVerificationFailed())));
      }
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleMfaError(e);
    }
  }

  /// §5.1b: the account has a passkey but this device can't produce it.
  /// Prefer the user's other factors, then the recovery code, then a
  /// dead-end explanation on the passkey step itself.
  Future<void> _fallBackFromPasskey(TwoFactorAuthPendingPasskey tfa) async {
    final others = tfa.challenge.methods.usableOnMobile(passkeySupported: false);
    if (others.length > 1) {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.methodPicker(
              challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel)));
    } else if (others.length == 1) {
      await _armMfaMethod(others.single,
          challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel);
    } else if (tfa.challenge.canUseRecoveryCode == true) {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.pendingRecoveryCode(
              challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel)));
    } else {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel, twoFactorAuth: tfa.copyWith(noCredential: true)));
    }
  }

  /// Re-arms the SMS challenge, which resends the code.
  Future<void> resendPendingSmsCode() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthPendingSms) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final armed = await _mfaRepository.armChallenge(pendingId: tfa.challenge.pendingId, method: MfaMethod.sms);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.pendingSms(
              challenge: tfa.challenge,
              hint: armed.hint ?? tfa.hint,
              nextSendAfterSeconds: armed.nextSendAfterSeconds,
              email: tfa.email,
              providerModel: tfa.providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.pendingSms(
          challenge: tfa.challenge,
          hint: tfa.hint,
          nextSendAfterSeconds: wait,
          email: tfa.email,
          providerModel: tfa.providerModel));
    }
  }

  /// Shared tail for a refused resend: a throttled send re-emits the current
  /// step with the server's wait (no dialog — nothing was sent or lost, the
  /// countdown is the message); anything else takes the standard error tail.
  void _handleThrottledResend(RMApiError e, {required TwoFactorAuth Function(int wait) reEmit}) {
    if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
      final tfa = reEmit(e.retryAfterSeconds ?? _fallbackSendWaitSeconds);
      emit(AuthState.loggedOut(providerModel: tfa.providerModel, twoFactorAuth: tfa));
      return;
    }
    _handleMfaError(e);
  }

  /// When a 429 arrives without its wait (shouldn't happen), match the SMS
  /// resend spacing rather than leaving the control locked or hammering.
  static const _fallbackSendWaitSeconds = 60;

  /// Verifies the code of whichever decision-engine step is active. On success
  /// the sign-in completes and the state moves to [LoggedIn] — callers should
  /// check `state.isLoggedIn` after awaiting to decide whether to pop.
  Future<TwoFactorAuthResult> verifyPendingMfaCode(String code) async {
    final tfa = _currentTwoFactorAuth();

    final verify = switch (tfa) {
      TwoFactorAuthPendingTotp(:final challenge) => () =>
          _mfaRepository.verifyTotp(pendingId: challenge.pendingId, code: code),
      TwoFactorAuthPendingSms(:final challenge) => () =>
          _mfaRepository.verifySms(pendingId: challenge.pendingId, code: code),
      TwoFactorAuthPendingRecoveryCode(:final challenge) => () =>
          _mfaRepository.verifyRecoveryCode(pendingId: challenge.pendingId, code: code),
      TwoFactorAuthVerifyEmail(:final pendingId) => () =>
          _mfaRepository.verifyEmailCode(pendingId: pendingId, code: code),
      _ => null,
    };

    if (tfa == null || verify == null) {
      log('Attempted to verify an MFA code with no pending challenge.');
      return TwoFactorAuthResult.error;
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final session = await verify();
      if (isClosed) return TwoFactorAuthResult.error;
      return await _completeMfaSession(session, email: tfa.email, providerModel: tfa.providerModel);
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return _mapVerifyError(e);
    }
  }

  /// Maps a failed code-verify to the widget-facing result. Wrong code and
  /// dead code (exhausted/expired/not armed) keep the step on screen for an
  /// inline retry or resend; a guess limit carries its wait; anything else
  /// takes the standard error tail.
  TwoFactorAuthResult _mapVerifyError(RMApiError e) {
    final code = MfaErrorCode.fromError(e);
    if (code?.isWrongCode == true) {
      emit(state.copyWith(flow: const UIFlow.established()));
      return TwoFactorAuthResult.wrongCode;
    }
    if (code?.needsFreshCode == true) {
      emit(state.copyWith(flow: const UIFlow.established()));
      return TwoFactorAuthResult.codeExhausted;
    }
    if (code == MfaErrorCode.guessLimitReached) {
      emit(state.copyWith(flow: const UIFlow.established()));
      return TwoFactorAuthRateLimited(e.retryAfterSeconds ?? _fallbackSendWaitSeconds);
    }
    _handleMfaError(e);
    return TwoFactorAuthResult.error;
  }

  /// Lost-factor fallback for the decision-engine flow.
  void useRecoveryCode() {
    final tfa = _currentTwoFactorAuth();
    final (challenge, smsHint) = switch (tfa) {
      TwoFactorAuthMethodPicker(:final challenge) => (challenge, null),
      TwoFactorAuthPendingTotp(:final challenge) => (challenge, null),
      TwoFactorAuthPendingSms(:final challenge, :final hint) => (challenge, hint),
      TwoFactorAuthPendingPasskey(:final challenge) => (challenge, null),
      _ => (null, null),
    };
    if (tfa == null || challenge == null) return;
    emit(AuthState.loggedOut(
        providerModel: tfa.providerModel,
        twoFactorAuth: TwoFactorAuth.pendingRecoveryCode(
            challenge: challenge, smsHint: smsHint, email: tfa.email, providerModel: tfa.providerModel)));
  }

  void backFromRecoveryCode() {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthPendingRecoveryCode) return;
    final usable = tfa.challenge.methods.usableOnMobile(passkeySupported: _passkeySupported);
    if (usable.length > 1) {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.methodPicker(
              challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel)));
    } else if (usable.singleOrNull == MfaMethod.sms) {
      // The previously texted code may still be valid; resend is available.
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.pendingSms(
              challenge: tfa.challenge, hint: tfa.smsHint, email: tfa.email, providerModel: tfa.providerModel)));
    } else if (usable.singleOrNull == MfaMethod.passkey) {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.pendingPasskey(
              challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel)));
    } else {
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.pendingTotp(
              challenge: tfa.challenge, email: tfa.email, providerModel: tfa.providerModel)));
    }
  }

  /// Back from a factor code-entry screen to the method picker.
  void backToMfaMethodPicker() {
    final tfa = _currentTwoFactorAuth();
    final challenge = switch (tfa) {
      TwoFactorAuthPendingTotp(:final challenge) => challenge,
      TwoFactorAuthPendingSms(:final challenge) => challenge,
      TwoFactorAuthPendingPasskey(:final challenge) => challenge,
      _ => null,
    };
    if (tfa == null ||
        challenge == null ||
        challenge.methods.usableOnMobile(passkeySupported: _passkeySupported).length < 2) {
      return;
    }
    emit(AuthState.loggedOut(
        providerModel: tfa.providerModel,
        twoFactorAuth:
            TwoFactorAuth.methodPicker(challenge: challenge, email: tfa.email, providerModel: tfa.providerModel)));
  }

  // ── MFA decision engine: email-verification step-up ──

  Future<void> _startMfaVerifyEmail(String pendingId,
      {required String email, required ProviderResponseModel providerModel}) async {
    emit(AuthState.loggedOut(
        providerModel: providerModel,
        twoFactorAuth: TwoFactorAuth.verifyEmail(pendingId: pendingId, email: email, providerModel: providerModel)));
    try {
      final sent = await _mfaRepository.sendVerifyEmail(pendingId: pendingId);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: providerModel,
          twoFactorAuth: TwoFactorAuth.verifyEmail(
              pendingId: pendingId,
              nextSendAfterSeconds: sent.nextSendAfterSeconds,
              email: email,
              providerModel: providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      // The send budget is per user — a fresh sign-in doesn't refill it, so
      // this first send can be refused. An earlier code may still verify.
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.verifyEmail(
          pendingId: pendingId, nextSendAfterSeconds: wait, email: email, providerModel: providerModel));
    }
  }

  Future<void> resendVerifyEmailCode() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthVerifyEmail) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final sent = await _mfaRepository.sendVerifyEmail(pendingId: tfa.pendingId);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.verifyEmail(
              pendingId: tfa.pendingId,
              nextSendAfterSeconds: sent.nextSendAfterSeconds,
              email: tfa.email,
              providerModel: tfa.providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.verifyEmail(
          pendingId: tfa.pendingId, nextSendAfterSeconds: wait, email: tfa.email, providerModel: tfa.providerModel));
    }
  }

  // ── MFA decision engine: login-time enrolment ──

  /// From the intro: send the email-proof code and show its entry screen.
  Future<void> continueEnrolment() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolIntro) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final sent = await _mfaRepository.sendEnrolmentEmailProof(enrolId: tfa.enrolment.enrolId);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.enrolEmailProof(
              enrolment: tfa.enrolment,
              nextSendAfterSeconds: sent.nextSendAfterSeconds,
              email: tfa.email,
              providerModel: tfa.providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      // Per-user budget: even the first send can be refused; an earlier
      // code may still verify, so show the entry step with the wait.
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.enrolEmailProof(
          enrolment: tfa.enrolment, nextSendAfterSeconds: wait, email: tfa.email, providerModel: tfa.providerModel));
    }
  }

  Future<void> resendEnrolmentEmailProof() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolEmailProof) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final sent = await _mfaRepository.sendEnrolmentEmailProof(enrolId: tfa.enrolment.enrolId);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.enrolEmailProof(
              enrolment: tfa.enrolment,
              nextSendAfterSeconds: sent.nextSendAfterSeconds,
              email: tfa.email,
              providerModel: tfa.providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.enrolEmailProof(
          enrolment: tfa.enrolment, nextSendAfterSeconds: wait, email: tfa.email, providerModel: tfa.providerModel));
    }
  }

  /// Verifies the emailed proof-of-control code. Advances to the method
  /// picker (or straight into the single permitted method).
  Future<TwoFactorAuthResult> verifyEnrolmentEmailProof(String code) async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolEmailProof) return TwoFactorAuthResult.error;
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final proof = await _mfaRepository.verifyEnrolmentEmailProof(enrolId: tfa.enrolment.enrolId, code: code);
      if (isClosed) return TwoFactorAuthResult.error;
      await _refreshPasskeySupport();
      if (isClosed) return TwoFactorAuthResult.error;

      // The proof response carries the authoritative permitted set.
      final enrolment = MfaEnrolmentModel(
          enrolId: tfa.enrolment.enrolId, mode: tfa.enrolment.mode, permittedMethods: proof.permittedMethods);
      final usable = enrolment.permittedMethods.usableOnMobile(passkeySupported: _passkeySupported);

      if (usable.isEmpty) {
        emit(state.copyWith(
            flow: UIFlow.error(RMApiError(
                cause: 'None of the available verification methods are supported in this app yet. '
                    'Please sign in on the web.'))));
        return TwoFactorAuthResult.error;
      }

      if (usable.length == 1) {
        await _beginEnrolMethod(usable.single,
            enrolment: enrolment, email: tfa.email, providerModel: tfa.providerModel);
      } else {
        emit(AuthState.loggedOut(
            providerModel: tfa.providerModel,
            twoFactorAuth: TwoFactorAuth.enrolMethodPicker(
                enrolment: enrolment, email: tfa.email, providerModel: tfa.providerModel)));
      }
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return _mapVerifyError(e);
    }
  }

  /// From the enrol method picker.
  Future<void> chooseEnrolMethod(MfaMethod method) async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolMethodPicker) return;
    await _beginEnrolMethod(method, enrolment: tfa.enrolment, email: tfa.email, providerModel: tfa.providerModel);
  }

  Future<void> _beginEnrolMethod(MfaMethod method,
      {required MfaEnrolmentModel enrolment,
      required String email,
      required ProviderResponseModel providerModel}) async {
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      switch (method) {
        case MfaMethod.totp:
          final totp = await _mfaRepository.beginTotpEnrolment(enrolId: enrolment.enrolId);
          if (isClosed) return;
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth: TwoFactorAuth.enrolTotp(
                  enrolment: enrolment, totp: totp, email: email, providerModel: providerModel)));
        case MfaMethod.sms:
          final begin = await _mfaRepository.beginSmsEnrolment(enrolId: enrolment.enrolId);
          if (isClosed) return;
          final factorId = begin.factorId;
          if (factorId == null) {
            emit(state.copyWith(flow: UIFlow.error(RMApiError(cause: 'No factor id provided.'))));
            return;
          }
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth: TwoFactorAuth.enrolSms(
                  enrolment: enrolment,
                  factorId: factorId,
                  hint: begin.hint,
                  nextSendAfterSeconds: begin.nextSendAfterSeconds,
                  email: email,
                  providerModel: providerModel)));
        case MfaMethod.passkey:
          // No network call yet — the widget auto-starts the ceremony, and
          // [enrolWithPasskey] re-begins per attempt (creation challenges
          // are single-use).
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth:
                  TwoFactorAuth.enrolPasskey(enrolment: enrolment, email: email, providerModel: providerModel)));
        case MfaMethod.recoveryCode:
        case MfaMethod.recoveryEmail:
        case MfaMethod.unknown:
          // Unreachable via the usableOnMobile-filtered UI, but a bare return
          // here would leave the loading spinner up forever.
          emit(state.copyWith(
              flow: UIFlow.error(RMApiError(cause: 'This verification method is not supported in this app.'))));
      }
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleMfaError(e);
    }
  }

  /// Runs one full passkey enrolment: fresh begin, platform ceremony,
  /// verify, session. Called by the enrol-passkey widget (auto-start and
  /// retry button) — never re-run automatically. On success the state moves
  /// to [LoggedIn]; callers check `state.isLoggedIn` to decide whether to
  /// pop.
  Future<void> enrolWithPasskey() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolPasskey) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final options = await _mfaRepository.beginPasskeyEnrolment(enrolId: tfa.enrolment.enrolId);
      if (isClosed) return;
      final response = await _passkeyService.create(options);
      if (isClosed) return;
      final session =
          await _mfaRepository.verifyPasskeyEnrolment(enrolId: tfa.enrolment.enrolId, response: response);
      if (isClosed) return;
      await _completeMfaSession(session, email: tfa.email, providerModel: tfa.providerModel);
    } on PasskeyException catch (e) {
      if (isClosed) return;
      switch (e.type) {
        case PasskeyErrorType.cancelled:
          // Silent — the step's button offers the retry (and Skip stays
          // available under Encourage).
          emit(state.copyWith(flow: const UIFlow.established()));
        case PasskeyErrorType.excludedCredentialExists:
          emit(AuthState.loggedOut(
              providerModel: tfa.providerModel, twoFactorAuth: tfa.copyWith(deviceHasPasskey: true)));
        case PasskeyErrorType.noCredential:
        case PasskeyErrorType.unsupported:
        case PasskeyErrorType.securityError:
          log('Passkey enrolment ceremony failed: $e');
          emit(state.copyWith(flow: UIFlow.error(RMApiError.passkeyCreationFailed())));
      }
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleMfaError(e);
    }
  }

  /// Back from the enrol-passkey step to the method picker (only offered
  /// when more than one method is permitted).
  void backToEnrolMethodPicker() {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolPasskey) return;
    if (tfa.enrolment.permittedMethods.usableOnMobile(passkeySupported: _passkeySupported).length < 2) return;
    emit(AuthState.loggedOut(
        providerModel: tfa.providerModel,
        twoFactorAuth: TwoFactorAuth.enrolMethodPicker(
            enrolment: tfa.enrolment, email: tfa.email, providerModel: tfa.providerModel)));
  }

  /// Re-runs the SMS enrolment begin step, which resends the code (a code
  /// still in flight is handed back without sending or spending anything).
  Future<void> resendEnrolmentSmsCode() async {
    final tfa = _currentTwoFactorAuth();
    if (tfa is! TwoFactorAuthEnrolSms) return;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final begin = await _mfaRepository.beginSmsEnrolment(enrolId: tfa.enrolment.enrolId);
      if (isClosed) return;
      emit(AuthState.loggedOut(
          providerModel: tfa.providerModel,
          twoFactorAuth: TwoFactorAuth.enrolSms(
              enrolment: tfa.enrolment,
              factorId: begin.factorId ?? tfa.factorId,
              hint: begin.hint ?? tfa.hint,
              nextSendAfterSeconds: begin.nextSendAfterSeconds,
              email: tfa.email,
              providerModel: tfa.providerModel)));
    } on RMApiError catch (e) {
      if (isClosed) return;
      _handleThrottledResend(e, reEmit: (wait) => TwoFactorAuth.enrolSms(
          enrolment: tfa.enrolment,
          factorId: tfa.factorId,
          hint: tfa.hint,
          nextSendAfterSeconds: wait,
          email: tfa.email,
          providerModel: tfa.providerModel));
    }
  }

  /// Confirms the enrolment code (authenticator or SMS), activating the
  /// factor and completing the sign-in.
  Future<TwoFactorAuthResult> verifyEnrolmentCode(String code) async {
    final tfa = _currentTwoFactorAuth();

    final verify = switch (tfa) {
      TwoFactorAuthEnrolTotp(:final enrolment, :final totp) => () => _mfaRepository.activateTotpEnrolment(
          enrolId: enrolment.enrolId, factorId: totp.factorId, code: code),
      TwoFactorAuthEnrolSms(:final enrolment, :final factorId) => () =>
          _mfaRepository.verifySmsEnrolment(enrolId: enrolment.enrolId, factorId: factorId, code: code),
      _ => null,
    };

    if (tfa == null || verify == null) {
      log('Attempted to verify an enrolment code with no enrolment step active.');
      return TwoFactorAuthResult.error;
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final session = await verify();
      if (isClosed) return TwoFactorAuthResult.error;
      return await _completeMfaSession(session, email: tfa.email, providerModel: tfa.providerModel);
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return _mapVerifyError(e);
    }
  }

  /// Encourage mode only. Returns true when the sign-in completed.
  Future<bool> skipEnrolment() async {
    final tfa = _currentTwoFactorAuth();
    final enrolment = switch (tfa) {
      TwoFactorAuthEnrolIntro(:final enrolment) => enrolment,
      TwoFactorAuthEnrolEmailProof(:final enrolment) => enrolment,
      TwoFactorAuthEnrolMethodPicker(:final enrolment) => enrolment,
      TwoFactorAuthEnrolTotp(:final enrolment) => enrolment,
      TwoFactorAuthEnrolSms(:final enrolment) => enrolment,
      TwoFactorAuthEnrolPasskey(:final enrolment) => enrolment,
      _ => null,
    };
    if (tfa == null || enrolment == null || enrolment.mode != MfaMode.encourage) return false;
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      final session = await _mfaRepository.skipEnrolment(enrolId: enrolment.enrolId);
      if (isClosed) return false;
      final result = await _completeMfaSession(session, email: tfa.email, providerModel: tfa.providerModel);
      return result == TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      _handleMfaError(e);
      return false;
    }
  }

  // ── MFA decision engine: shared tails ──

  TwoFactorAuth? _currentTwoFactorAuth() {
    final current = state;
    if (current is! LoggedOut) return null;
    return current.twoFactorAuth;
  }

  Future<TwoFactorAuthResult> _completeMfaSession(MfaSessionModel session,
      {String? email, required ProviderResponseModel providerModel}) async {
    await _persistDeviceAndRenewalTokens(
        deviceToken: session.deviceToken, sessionRenewalToken: session.sessionRenewalToken);
    if (isClosed) return TwoFactorAuthResult.error;
    final loggedIn =
        await _performPostLoginActions(email: email, jwtToken: session.token, providerModel: providerModel);
    return loggedIn ? TwoFactorAuthResult.success : TwoFactorAuthResult.error;
  }

  /// Shared error tail: an expired/unknown handle means the withheld sign-in
  /// is gone — reset to the credentials form. Anything else surfaces as the
  /// usual error dialog on the current step.
  void _handleMfaError(RMApiError e) {
    if (MfaErrorCode.fromError(e)?.isExpiredHandle == true) {
      final providerModel = switch (state) {
        LoggedOut(:final providerModel) => providerModel,
        _ => null,
      };
      emit(AuthState.loggedOut(
          providerModel: providerModel,
          flow: UIFlow.error(RMApiError(cause: 'Your sign-in session has expired. Please sign in again.'))));
      return;
    }
    emit(state.copyWith(flow: UIFlow.error(e)));
  }

  void useBackupCode() {
    final currentState = state;
    if (currentState is! LoggedOut) {
      log('Attempted to use backup code when not in logged out state.');
      return;
    }

    switch (currentState.twoFactorAuth) {
      case TwoFactorAuthOtp(:final mfaToken, :final email, :final providerModel):
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth: TwoFactorAuth.useBackupCode(
                mfaToken: mfaToken, mfaPhoneNumber: null, email: email, providerModel: providerModel)));
      case TwoFactorAuthSms(:final mfaToken, :final mfaPhoneNumber, :final email, :final providerModel):
        emit(AuthState.loggedOut(
            providerModel: providerModel,
            twoFactorAuth: TwoFactorAuth.useBackupCode(
                mfaToken: mfaToken, mfaPhoneNumber: mfaPhoneNumber, email: email, providerModel: providerModel)));
      default:
        return;
    }
  }

  void backFromBackupCode() {
    final currentState = state;
    if (currentState is! LoggedOut) {
      log('Attempted to go back from backup code when not in logged out state.');
      return;
    }

    final twoFactorAuth = currentState.twoFactorAuth;
    if (twoFactorAuth != null) {
      final providerModel = twoFactorAuth.providerModel;

      if (twoFactorAuth is TwoFactorAuthUseBackupCode) {
        if (twoFactorAuth.mfaPhoneNumber != null) {
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth: TwoFactorAuth.sms(
                  mfaToken: twoFactorAuth.mfaToken,
                  mfaPhoneNumber: twoFactorAuth.mfaPhoneNumber!,
                  email: twoFactorAuth.email,
                  providerModel: twoFactorAuth.providerModel)));
        } else {
          emit(AuthState.loggedOut(
              providerModel: providerModel,
              twoFactorAuth: TwoFactorAuth.authenticatorApp(
                  mfaToken: twoFactorAuth.mfaToken,
                  email: twoFactorAuth.email,
                  providerModel: twoFactorAuth.providerModel)));
        }
      }
    }
  }

  /// Returns true if login was successful, false otherwise.
  /// [email] is the address the user signed in with; a passwordless passkey
  /// sign-in has none, and falls back to the fetched profile's address.
  Future<bool> _performPostLoginActions(
      {String? email, required String jwtToken, required ProviderResponseModel providerModel}) async {
    try {
      // Fresh session — clear the one-shot so the "session ending"
      // snackbar can fire again later in this session's tail.
      _sessionEndingNoticeShown = false;
      await _storage.storeAuthToken(jwtToken);
      await _storage.storeProviderId(providerModel.id);
      final accountFuture = _repository.getMyAccount();
      final profileFuture = _repository.getMyProfile();

      MobileUserSummaryModel? mobileFeatures;

      try {
        mobileFeatures = await _repository.getMobileFeatures();
      } catch (e) {
        // Specs say this call should be allowed to fail - then no features are enabled.
        // If call succeeds but feature is not present, this should be enabled.
      }

      AccountSelfModel account = await accountFuture;
      ProfileResponseModel profile = await profileFuture;

      AccountDetailsModel? accountDetails = AccountDetailsModel.fromAccountSelfModel(
        email ?? profile.data.email,
        account,
        profile,
        mobileFeatures,
        providerModel,
      );

      accountDetails.saveToSharedPrefs(_prefs);

      IntercomUtils.loginWithUserDetails(
          userIdString: accountDetails.userId, emailString: accountDetails.email);

      // Identify user in Mixpanel
      if (accountDetails.userId != null) {
        _mixpanelService.identify(accountDetails.userId!, email: accountDetails.email);
        _mixpanelService.flush();
      }

      emit(AuthState.loggedIn(accountDetails, jwtToken));
      return true;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<void> _persistDeviceAndRenewalTokens({
    required String? deviceToken,
    required String? sessionRenewalToken,
  }) async {
    if (deviceToken != null) {
      await _storage.storeDeviceToken(deviceToken);
    }
    if (sessionRenewalToken == null) return;
    if (!await _renewalStorage.canStore()) return;
    try {
      await _renewalStorage.store(sessionRenewalToken);
    } catch (e, st) {
      // Most likely the user cancelled the Face ID / fingerprint prompt, or
      // biometrics are temporarily locked out. Some devices (notably the
      // Solana Mobile Seeker) consistently fail here due to non-standard
      // secure-element behaviour. Without the renewal token stored, the
      // user simply won't get silent re-authentication; they'll re-enter
      // credentials at the next session expiry. That's an acceptable
      // fallback — don't fail the whole login over it. Report to
      // Crashlytics so we can see which devices/users are affected
      // (Crashlytics auto-captures manufacturer/model).
      log('Could not store session renewal token: $e', error: e, stackTrace: st);
      FirebaseCrashlytics.instance.recordError(e, st, reason: 'sessionRenewalToken.store', fatal: false);
    }
  }

  Future<void> _refreshAccountDetails() async {
    final currentToken = switch (state) {
      LoggedIn(profile: _, token: final token, flow: _) => token,
      _ => null,
    };

    // Not logged in, base provider only and initialize basic app functions.
    if (currentToken == null) {
      log('Attempted to refresh account details when not logged in.');
      final providerModelFuture = await getProvider();
      await IntercomUtils.loginWithUserDetails(userIdString: null, emailString: null);

      final current2FaState = switch (state) {
        LoggedOut(providerModel: _, twoFactorAuth: final twoFactorAuth, flow: _) => twoFactorAuth,
        _ => null,
      };

      emit(AuthState.loggedOut(providerModel: providerModelFuture, twoFactorAuth: current2FaState));
      return;
    }

    log('Refreshing account details.');

    final providerModelFuture = getProvider();
    final profileFuture = _repository.getMyProfile();

    try {
      final accountFuture = _repository.getMyAccount();
      MobileUserSummaryModel? mobileFeatures;

      try {
        mobileFeatures = await _repository.getMobileFeatures();
      } catch (e) {
        // Specs say this call should be allowed to fail - then no features are enabled.
        // If call succeeds but feature is not present, this should be enabled.
      }

      final providerModel = await providerModelFuture;
      final profile = await profileFuture;

      AccountSelfModel account = await accountFuture;
      AccountDetailsModel? accountDetails = AccountDetailsModel.fromAccountSelfModel(
        profile.data.email,
        account,
        profile,
        mobileFeatures,
        providerModel,
      );

      accountDetails.saveToSharedPrefs(_prefs);

      IntercomUtils.loginWithUserDetails(
          userIdString: accountDetails.userId, emailString: accountDetails.email);

      emit(AuthState.loggedIn(accountDetails, currentToken));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Returns null if successful or if an error is emitted, otherwise returns an inline error.
  Future<UpdateBillingDetailsError?> updateAddressDetails(
      {required String address,
      required String addressLine2,
      required String postalCode,
      required String city,
      required String countryCode}) async {
    final currentToken = switch (state) {
      LoggedIn(profile: _, token: final token, flow: _) => token,
      _ => null,
    };

    if (currentToken == null) {
      log('Attempted to add address details when not logged in.');
      throw RMApiError(cause: 'Not logged in.');
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));

      await _repository.updateAccountDetails(address, addressLine2, postalCode, city, countryCode);
      await _refreshAccountDetails();

      return null;
    } on RMApiError catch (e) {
      if (e.details != null &&
          e.details!.isNotEmpty &&
          e.details!.first.code != null &&
          e.details!.first.code!.isNotEmpty) {
        final detailError = UpdateBillingDetailsError.fromString(e.details!.first.code!);
        if (detailError != null) {
          emit(state.copyWith(flow: const UIFlow.established()));
          return detailError;
        }
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
      return UpdateBillingDetailsError.apiError;
    }
  }

  /// Pass the phone fields only when the user actually changed them — an
  /// unchanged phone stays out of the PATCH body, keeping a plain name edit
  /// off the MFA step-up gate.
  ///
  /// A step-up demand is rethrown rather than surfaced as an error flow:
  /// [runWithStepUp] at the call site presents the challenge and re-runs
  /// this action.
  Future<bool> updateProfile(String firstName, String lastName,
      {String? phoneCountryCode, String? phoneNumber}) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      await _repository.updateProfile(firstName, lastName,
          phoneCountryCode: phoneCountryCode, phoneNumber: phoneNumber);
      await _refreshAccountDetails();
      if (isClosed) return false;
      emit(state.copyWith(flow: const UIFlow.established()));
      return true;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(state.copyWith(flow: const UIFlow.established()));
        rethrow;
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
    // Non-RMApiError exceptions (e.g. JSON parse bugs) intentionally bubble to
    // Crashlytics rather than being wrapped into a "Something went wrong" UI.
  }

  /// This also clears the shared preferences.
  ///
  /// [sessionExpired] is set to true when the logout is triggered by the
  /// global 401 handler observing a `JWT_EXPIRED` response. The login screen
  /// reads this flag to surface a session-expired message to the user.
  Future<bool> logout({bool sessionExpired = false}) async {
    try {
      // Logout is handled entirely client-side; there is no backend logout endpoint.
      await _storage.deleteAuthToken();
      // Clear the biometric-protected renewal token — the user explicitly
      // logged out and shouldn't be silently re-authenticated next launch.
      // Keep the device token: it persists across sessions and identifies
      // this physical device to the API.
      await _renewalStorage.clear();
      // Wipe user-scoped prefs but keep keys flagged with [persistKeyPrefix]
      // (e.g. one-time migration markers, debug toggles).
      await _prefs.clearUserScoped();

      await IntercomUtils.logout();

      // Flush any pending events before resetting user identification
      _mixpanelService.flush();
      _mixpanelService.reset();

      emit(AuthState.loggedOut(sessionExpired: sessionExpired));
      final providerModel = await getProvider();
      // sessionExpired already surfaced on the first emit (listener showed the
      // dialog and called acknowledgeSessionExpired); don't re-trigger it.
      emit(AuthState.loggedOut(providerModel: providerModel, sessionExpired: false));
      return true;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Clears the [LoggedOut.sessionExpired] flag so the session-expired
  /// message is shown only once.
  void acknowledgeSessionExpired() {
    final current = state;
    if (current is LoggedOut && current.sessionExpired) {
      emit(current.copyWith(sessionExpired: false));
    }
  }

  void invalidateAuthToken() async {
    await _storage.storeAuthToken('token1234');
  }

  /// Debug-only: wipes the current auth token but leaves the renewal token in
  /// place, then re-enters [moveToInitialAppState] so the renewer fires. Used
  /// to verify the Face ID / fingerprint renewal flow without waiting for a
  /// genuine session expiry.
  void forceSessionRenewal() async {
    await _storage.deleteAuthToken();
    emit(const AuthState.showSplash());
    moveToInitialAppState();
  }

  Future<void> refreshAccountDetails() async {
    try {
      await _refreshAccountDetails();
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  Future<bool> deleteAccount() async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      await _repository.deleteAccount();
      return await logout();
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> requestVerifyEmailAddress() async {
    try {
      final userId = switch (state) {
        LoggedIn(profile: final profile) => profile.userId,
        _ => null,
      };

      if (userId == null) {
        log('Attempted to request verify email address when not logged in.');
        throw RMApiError(cause: 'Not logged in.');
      }

      final success = await _verificationRepo.sendVerificationCode(
        VerificationType.email,
        userId: userId,
        journey: 'msp',
        context: 'profile',
      );
      return success;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> confirmEmailAddress(String code) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final success = await _verificationRepo.confirmVerificationCode(code, VerificationType.email, context: 'profile');
      if (!success) {
        // Log verification failure
        _analytics?.logVerificationEvent(
          VerificationAnalyticsType.emailVerificationFailure,
          verificationType: 'email',
          context: 'profile',
          errorMessage: 'Invalid code',
        );
        emit(state.copyWith(flow: const UIFlow.established()));
        return false;
      }

      // Log successful verification
      _analytics?.logVerificationEvent(
        VerificationAnalyticsType.emailVerificationSuccess,
        verificationType: 'email',
        context: 'profile',
      );

      await _refreshAccountDetails();
      return true;
    } on RMApiError catch (e) {
      // Log verification failure
      _analytics?.logVerificationEvent(
        VerificationAnalyticsType.emailVerificationFailure,
        verificationType: 'email',
        context: 'profile',
        errorMessage: e.cause,
      );
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> requestMobileNumberVerification() async {
    try {
      final success = await _verificationRepo.sendVerificationCode(VerificationType.mobile, context: 'profile');
      return success;
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  Future<bool> confirmMobileNumber(String code) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final success = await _verificationRepo.confirmVerificationCode(code, VerificationType.mobile, context: 'profile');
      if (!success) {
        // Log verification failure
        _analytics?.logVerificationEvent(
          VerificationAnalyticsType.phoneVerificationFailure,
          verificationType: 'mobile',
          context: 'profile',
          errorMessage: 'Invalid code',
        );
        emit(state.copyWith(flow: const UIFlow.established()));
        return false;
      }

      // Log successful verification
      _analytics?.logVerificationEvent(
        VerificationAnalyticsType.phoneVerificationSuccess,
        verificationType: 'mobile',
        context: 'profile',
      );

      await _refreshAccountDetails();
      return true;
    } on RMApiError catch (e) {
      // Log verification failure
      _analytics?.logVerificationEvent(
        VerificationAnalyticsType.phoneVerificationFailure,
        verificationType: 'mobile',
        context: 'profile',
        errorMessage: e.cause,
      );
      emit(state.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Check if the current user needs verification based on backend state
  bool needsVerification(AccountDetailsModel accountDetails) {
    // Check if email verification is required and not completed
    if (accountDetails.emailVerificationEnabled && !accountDetails.isEmailVerified) {
      return true;
    }

    // Check if phone verification is required and not completed
    if (accountDetails.mobileNumberVerificationEnabled && !accountDetails.isMobileNumberVerified) {
      // UK phone numbers are exempt from verification
      if (accountDetails.phoneCountryCode == 'GB') {
        // Log UK phone exemption in profile context
        _analytics?.logVerificationEvent(
          VerificationAnalyticsType.ukPhoneExempted,
          verificationType: 'mobile',
          context: 'profile',
          isUkPhone: true,
        );
        return false;
      }
      return true;
    }

    return false;
  }
}
