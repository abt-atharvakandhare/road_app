import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/step_up_repository.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_error_code.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'step_up_state.dart';
part 'step_up_cubit.freezed.dart';

/// Drives the step-up sheet (spec §13): pick one of the account's active
/// sign-in factors, verify a code over `/1/auth/step-up/*`, and the gated
/// request that triggered the sheet can be retried.
///
/// Budget rules are shared with login-time MFA: a refused first arm (429)
/// still shows the code entry with the wait, an exhausted code steers to a
/// user-initiated resend, and nothing is ever re-armed automatically.
@injectable
class StepUpCubit extends Cubit<StepUpState> {
  StepUpCubit(this._factorsRepository, this._stepUpRepository, this._passkeyService)
      : super(const StepUpState.methodPick()) {
    _load();
  }

  final MfaFactorsRepository _factorsRepository;
  final StepUpRepository _stepUpRepository;
  final PasskeyService _passkeyService;

  List<MfaFactorModel> _usableFactors = const [];

  /// When a 429 arrives without its wait, match the SMS resend spacing.
  static const _fallbackSendWaitSeconds = 60;

  Future<void> _load() async {
    try {
      bool passkeySupported = false;
      try {
        passkeySupported = await _passkeyService.isSupported();
      } catch (_) {
        // An unanswerable capability check reads as "can't do passkeys".
      }
      if (isClosed) return;
      final listing = await _factorsRepository.getFactors();
      if (isClosed) return;
      final active = listing.factors.where((factor) => factor.isActiveLoginFactor).toList();
      final usableTypes =
          active.map((factor) => factor.type).toList().usableOnMobile(passkeySupported: passkeySupported);
      _usableFactors = active.where((factor) => usableTypes.contains(factor.type)).toList();

      if (_usableFactors.isEmpty) {
        emit(const StepUpState.deadEnd());
      } else if (_usableFactors.length == 1) {
        await _startChallenge(_usableFactors.single, canPickAnother: false);
      } else {
        emit(StepUpState.methodPick(factors: _usableFactors));
      }
    } on RMApiError catch (e) {
      if (isClosed) return;
      emit(StepUpState.methodPick(flow: UIFlow.error(e)));
    }
  }

  /// A row tap on the picker.
  Future<void> pickMethod(MfaMethod method) async {
    final factor = _usableFactors.firstWhereOrNull((factor) => factor.type == method);
    if (factor == null) return;
    await _startChallenge(factor, canPickAnother: _usableFactors.length > 1);
  }

  Future<void> _startChallenge(MfaFactorModel factor, {required bool canPickAnother}) async {
    switch (factor.type) {
      case MfaMethod.totp:
        // No arm at all — the authenticator generates codes on its own.
        emit(StepUpState.codeEntry(method: MfaMethod.totp, canPickAnother: canPickAnother));
      case MfaMethod.sms:
        emit(StepUpState.methodPick(factors: _usableFactors, flow: const UIFlow.loading()));
        try {
          final sent = await _stepUpRepository.challenge(MfaMethod.sms);
          if (isClosed) return;
          emit(StepUpState.codeEntry(
              method: MfaMethod.sms,
              hint: sent.hint ?? factor.hint,
              nextSendAfterSeconds: sent.nextSendAfterSeconds,
              canPickAnother: canPickAnother));
        } on RMApiError catch (e) {
          if (isClosed) return;
          // Per-user budget: the send can be refused outright; an earlier code
          // may still verify, so show the entry with the wait.
          if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
            emit(StepUpState.codeEntry(
                method: MfaMethod.sms,
                hint: factor.hint,
                nextSendAfterSeconds: e.retryAfterSeconds ?? _fallbackSendWaitSeconds,
                canPickAnother: canPickAnother));
            return;
          }
          emit(StepUpState.methodPick(factors: _usableFactors, flow: UIFlow.error(e)));
        }
      case MfaMethod.passkey:
        // The widget auto-starts the ceremony (and owns the retry button);
        // arming happens per attempt in [verifyPasskey] because ceremony ids
        // are single-use.
        emit(StepUpState.passkey(canPickAnother: canPickAnother));
      case MfaMethod.recoveryCode:
      case MfaMethod.recoveryEmail:
      case MfaMethod.unknown:
        // Filtered out of [_usableFactors] before this point.
        break;
    }
  }

  /// Runs one full passkey step-up: fresh arm, platform ceremony, verify.
  /// Called by the sheet's passkey step (auto-start and retry button) —
  /// never re-run automatically. Success means the sheet can close and the
  /// gated request can be retried.
  Future<TwoFactorAuthResult> verifyPasskey() async {
    final current = state;
    if (current is! StepUpPasskey) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final armed = await _stepUpRepository.challenge(MfaMethod.passkey);
      if (isClosed) return TwoFactorAuthResult.error;
      final ceremonyId = armed.ceremonyId;
      final options = armed.options;
      if (ceremonyId == null || options == null) {
        emit(current.copyWith(flow: UIFlow.error(RMApiError.passkeyChallengeMissing())));
        return TwoFactorAuthResult.error;
      }
      final response = await _passkeyService.get(options);
      if (isClosed) return TwoFactorAuthResult.error;
      await _stepUpRepository.verifyPasskey(ceremonyId: ceremonyId, response: response);
      if (isClosed) return TwoFactorAuthResult.error;
      emit(current.copyWith(flow: const UIFlow.established()));
      return TwoFactorAuthResult.success;
    } on PasskeyException catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      switch (e.type) {
        case PasskeyErrorType.cancelled:
          // Silent: back to the picker when there is one, otherwise stay on
          // the step — its button offers the retry and the sheet can be
          // dismissed.
          if (current.canPickAnother) {
            backToPicker();
          } else {
            emit(current.copyWith(flow: const UIFlow.established()));
          }
        case PasskeyErrorType.noCredential:
        case PasskeyErrorType.unsupported:
          // Step-up has no recovery-code path — dead-end copy on the step.
          emit(current.copyWith(flow: const UIFlow.established(), noCredential: true));
        case PasskeyErrorType.excludedCredentialExists:
        case PasskeyErrorType.securityError:
          emit(current.copyWith(flow: UIFlow.error(RMApiError.passkeyVerificationFailed())));
      }
      return TwoFactorAuthResult.error;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return _mapVerifyError(e);
    }
  }

  /// Re-arms the SMS challenge, sending a fresh code. Only ever called by the
  /// user's explicit resend tap.
  Future<void> resendCode() async {
    final current = state;
    if (current is! StepUpCodeEntry || current.method != MfaMethod.sms) return;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final sent = await _stepUpRepository.challenge(MfaMethod.sms);
      if (isClosed) return;
      emit(StepUpState.codeEntry(
          method: MfaMethod.sms,
          hint: sent.hint ?? current.hint,
          nextSendAfterSeconds: sent.nextSendAfterSeconds,
          canPickAnother: current.canPickAnother));
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
        emit(current.copyWith(
            flow: const UIFlow.established(),
            nextSendAfterSeconds: e.retryAfterSeconds ?? _fallbackSendWaitSeconds));
        return;
      }
      emit(current.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Verifies the entered code. Success refreshes the session's MFA
  /// freshness server-side; the sheet closes and the caller retries its
  /// gated request.
  Future<TwoFactorAuthResult> verifyCode(String code) async {
    final current = state;
    if (current is! StepUpCodeEntry) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      switch (current.method) {
        case MfaMethod.totp:
          await _stepUpRepository.verifyTotp(code: code);
        case MfaMethod.sms:
          await _stepUpRepository.verifySms(code: code);
        case MfaMethod.passkey:
        case MfaMethod.recoveryCode:
        case MfaMethod.recoveryEmail:
        case MfaMethod.unknown:
          return TwoFactorAuthResult.error;
      }
      if (isClosed) return TwoFactorAuthResult.error;
      emit(current.copyWith(flow: const UIFlow.established()));
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return _mapVerifyError(e);
    }
  }

  /// Back from a code entry to the picker (only offered with several usable
  /// factors).
  void backToPicker() {
    emit(StepUpState.methodPick(factors: _usableFactors));
  }

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
    emit(state.copyWith(flow: UIFlow.error(e)));
    return TwoFactorAuthResult.error;
  }
}
