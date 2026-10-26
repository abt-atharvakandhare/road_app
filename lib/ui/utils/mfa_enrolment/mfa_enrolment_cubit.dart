import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_totp_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_error_code.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'mfa_enrolment_state.dart';
part 'mfa_enrolment_cubit.freezed.dart';

/// Shared state machine for enrolling sign-in factors over the in-session
/// factor-management endpoints (`/1/users/me/mfa-factors/*`): the method
/// list is the hub, TOTP/SMS set-up runs through sub-flow states, and a
/// factorless user is routed through the email proof first.
///
/// Enrolment errors follow the same budget-aware rules as the login-time
/// flow: wrong codes retry inline, dead codes steer to resend, throttled
/// sends update the countdown.
///
/// Hosts differ in how a `MFA_STEP_UP_REQUIRED` demand is handled — see
/// [rethrowsStepUpDemands].
abstract class MfaEnrolmentCubit extends Cubit<MfaEnrolmentState> {
  MfaEnrolmentCubit(this.repository, {this.passkeyService})
      : super(const MfaEnrolmentState.methodList()) {
    load();
  }

  @protected
  final MfaFactorsRepository repository;

  /// Drives in-session passkey registration ceremonies. Hosts that don't
  /// offer passkey enrolment leave it null — the passkey method then reads
  /// as unusable ([passkeySupported] stays false).
  @protected
  final PasskeyService? passkeyService;

  bool _passkeySupported = false;

  /// Device passkey capability, resolved during [load] before the factor
  /// listing is emitted. Widgets gate the passkey row on it via
  /// `usableOnMobile(passkeySupported: ...)`.
  bool get passkeySupported => _passkeySupported;

  @protected
  MfaFactorsModel? lastFactors;

  /// Whether a `MFA_STEP_UP_REQUIRED` demand on a mutation is rethrown to the
  /// caller — for hosts that run mutations through `runWithStepUp` — instead
  /// of surfacing as an error on the current state.
  @protected
  bool get rethrowsStepUpDemands;

  /// When a 429 arrives without its wait, match the SMS resend spacing.
  @protected
  static const fallbackSendWaitSeconds = 60;

  /// Fetches the factor listing and returns to the method list.
  @protected
  Future<void> load() async {
    try {
      final service = passkeyService;
      if (service != null && !_passkeySupported) {
        try {
          _passkeySupported = await service.isSupported();
        } catch (_) {
          // An unanswerable capability check reads as "can't do passkeys".
        }
        if (isClosed) return;
      }
      final factors = await repository.getFactors();
      if (isClosed) return;
      lastFactors = factors;
      emit(MfaEnrolmentState.methodList(factors: factors));
    } on RMApiError catch (e) {
      if (isClosed) return;
      // The listing is the hub, not a gate — surface the failure but leave
      // the host's own affordances live.
      emit(MfaEnrolmentState.methodList(flow: UIFlow.error(e)));
    }
  }

  /// "Set up" on a method row. A factorless user is bounced to the email
  /// proof first (`MFA_ENROL_EMAIL_PROOF_REQUIRED`); a step-up demand is
  /// handled per [rethrowsStepUpDemands].
  Future<void> setUpMethod(MfaMethod method) async {
    emit(state.copyWith(flow: const UIFlow.loading()));
    try {
      await _beginEnrolment(method);
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.enrolEmailProofRequired) {
        await _startEmailProof(method);
        return;
      }
      if (rethrowsStepUpDemands && MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(MfaEnrolmentState.methodList(factors: lastFactors));
        rethrow;
      }
      emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: UIFlow.error(e)));
    }
  }

  Future<void> _beginEnrolment(MfaMethod method) async {
    switch (method) {
      case MfaMethod.totp:
        final totp = await repository.beginTotp();
        if (isClosed) return;
        emit(MfaEnrolmentState.totpSetup(totp: totp));
      case MfaMethod.sms:
        final enrolled = await repository.enrolSms();
        if (isClosed) return;
        emit(MfaEnrolmentState.smsVerify(
            factorId: enrolled.id, hint: enrolled.hint, nextSendAfterSeconds: enrolled.nextSendAfterSeconds));
      case MfaMethod.passkey:
        await _enrolPasskey();
      case MfaMethod.recoveryCode:
      case MfaMethod.recoveryEmail:
      case MfaMethod.unknown:
        log('Attempted to set up unsupported MFA method: $method');
        emit(MfaEnrolmentState.methodList(factors: lastFactors));
    }
  }

  /// One full in-session passkey registration: begin, platform ceremony,
  /// verify. The begin call is where the email-proof gate (and, for hosts
  /// that step-up, the step-up demand) fires as an [RMApiError] — those
  /// propagate to the caller. Ceremony failures are absorbed here: a
  /// dismissed OS sheet returns to the list silently, the rest surface as
  /// localized errors on the list.
  Future<void> _enrolPasskey() async {
    final service = passkeyService;
    if (service == null || !_passkeySupported) {
      log('Attempted passkey enrolment without device support');
      emit(MfaEnrolmentState.methodList(factors: lastFactors));
      return;
    }
    final options = await repository.registerPasskey();
    if (isClosed) return;
    try {
      final response = await service.create(options);
      if (isClosed) return;
      await repository.verifyPasskeyRegistration(response: response);
      if (isClosed) return;
      await load();
    } on PasskeyException catch (e) {
      if (isClosed) return;
      switch (e.type) {
        case PasskeyErrorType.cancelled:
          // Silent: the user dismissed the OS sheet — the list's "Set up"
          // row is the retry affordance.
          emit(MfaEnrolmentState.methodList(factors: lastFactors));
        case PasskeyErrorType.excludedCredentialExists:
          emit(MfaEnrolmentState.methodList(
              factors: lastFactors, flow: UIFlow.error(RMApiError.passkeyAlreadyOnDevice())));
        case PasskeyErrorType.noCredential:
        case PasskeyErrorType.unsupported:
        case PasskeyErrorType.securityError:
          log('Passkey enrolment ceremony failed: $e');
          emit(MfaEnrolmentState.methodList(
              factors: lastFactors, flow: UIFlow.error(RMApiError.passkeyCreationFailed())));
      }
    }
  }

  Future<void> _startEmailProof(MfaMethod pendingMethod) async {
    try {
      final sent = await repository.sendEmailProof();
      if (isClosed) return;
      emit(MfaEnrolmentState.emailProof(pendingMethod: pendingMethod, nextSendAfterSeconds: sent.nextSendAfterSeconds));
    } on RMApiError catch (e) {
      if (isClosed) return;
      // Per-user budget: the send can be refused outright; an earlier code
      // may still verify, so show the entry with the wait.
      if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
        emit(MfaEnrolmentState.emailProof(
            pendingMethod: pendingMethod, nextSendAfterSeconds: e.retryAfterSeconds ?? fallbackSendWaitSeconds));
        return;
      }
      emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: UIFlow.error(e)));
    }
  }

  Future<void> resendEmailProof() async {
    final current = state;
    if (current is! MfaSetupEmailProof) return;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final sent = await repository.sendEmailProof();
      if (isClosed) return;
      emit(MfaEnrolmentState.emailProof(
          pendingMethod: current.pendingMethod, nextSendAfterSeconds: sent.nextSendAfterSeconds));
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
        emit(MfaEnrolmentState.emailProof(
            pendingMethod: current.pendingMethod,
            nextSendAfterSeconds: e.retryAfterSeconds ?? fallbackSendWaitSeconds));
        return;
      }
      emit(current.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Verifies the email proof and continues straight into the pending
  /// method's enrolment.
  Future<TwoFactorAuthResult> verifyEmailProofCode(String code) async {
    final current = state;
    if (current is! MfaSetupEmailProof) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      await repository.verifyEmailProof(code: code);
      if (isClosed) return TwoFactorAuthResult.error;
      await _beginEnrolment(current.pendingMethod);
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return mapVerifyError(e);
    }
  }

  /// Confirms the authenticator code, activating the factor.
  /// Wrong codes are `MFA_TOTP_INVALID_CODE` (unthrottled) — inline retry.
  Future<TwoFactorAuthResult> activateTotpCode(String code) async {
    final current = state;
    if (current is! MfaSetupTotp) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      await repository.activateTotp(factorId: current.totp.factorId, code: code);
      if (isClosed) return TwoFactorAuthResult.error;
      await load();
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return mapVerifyError(e);
    }
  }

  Future<TwoFactorAuthResult> verifySmsCode(String code) async {
    final current = state;
    if (current is! MfaSetupSmsVerify) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      await repository.verifySms(factorId: current.factorId, code: code);
      if (isClosed) return TwoFactorAuthResult.error;
      await load();
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return mapVerifyError(e);
    }
  }

  /// Re-runs the SMS enrolment, which resends the code (an in-flight code is
  /// handed back without sending or spending anything).
  Future<void> resendSmsCode() async {
    final current = state;
    if (current is! MfaSetupSmsVerify) return;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final enrolled = await repository.enrolSms();
      if (isClosed) return;
      emit(MfaEnrolmentState.smsVerify(
          factorId: enrolled.id,
          hint: enrolled.hint ?? current.hint,
          nextSendAfterSeconds: enrolled.nextSendAfterSeconds));
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
        emit(current.copyWith(
            flow: const UIFlow.established(), nextSendAfterSeconds: e.retryAfterSeconds ?? fallbackSendWaitSeconds));
        return;
      }
      if (rethrowsStepUpDemands && MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(current.copyWith(flow: const UIFlow.established()));
        rethrow;
      }
      emit(current.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Back from a sub-flow to the method list (never traps the user).
  void backToList() {
    emit(MfaEnrolmentState.methodList(factors: lastFactors));
    load();
  }

  /// Maps a failed code verification onto the shared result vocabulary; the
  /// unmatched remainder either rethrows (a step-up demand, per
  /// [rethrowsStepUpDemands]) or surfaces on the current state.
  @protected
  TwoFactorAuthResult mapVerifyError(RMApiError e) {
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
      return TwoFactorAuthRateLimited(e.retryAfterSeconds ?? fallbackSendWaitSeconds);
    }
    if (rethrowsStepUpDemands && code == MfaErrorCode.stepUpRequired) {
      emit(state.copyWith(flow: const UIFlow.established()));
      throw e;
    }
    emit(state.copyWith(flow: UIFlow.error(e)));
    return TwoFactorAuthResult.error;
  }
}
