import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_error_code.dart';
import 'package:road_mobile/ui/utils/mfa_enrolment/mfa_enrolment_cubit.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

export 'package:road_mobile/ui/utils/mfa_enrolment/mfa_enrolment_cubit.dart';

/// Drives the settings "Password & Authentication" screen over the shared
/// [MfaEnrolmentCubit] state machine, adding factor removal, backup codes
/// and the recovery email.
///
/// Every mutation here is step-up-gated server-side; a `MFA_STEP_UP_REQUIRED`
/// demand is rethrown so the screen can run the call through `runWithStepUp`
/// (challenge sheet + one retry).
@injectable
class SecurityCubit extends MfaEnrolmentCubit {
  SecurityCubit(super.repository, PasskeyService passkeyService)
      : super(passkeyService: passkeyService);

  @override
  bool get rethrowsStepUpDemands => true;

  /// Renames a factor (passkey labels) and refreshes the listing. Returns
  /// whether the rename went through.
  Future<bool> renameFactor(String factorId, String label) async {
    emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: const UIFlow.loading()));
    try {
      await repository.renameFactor(factorId: factorId, label: label);
      if (isClosed) return false;
      await load();
      return true;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(MfaEnrolmentState.methodList(factors: lastFactors));
        rethrow;
      }
      emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Removes a factor of any type/status and refreshes the listing. Returns
  /// whether the removal went through.
  Future<bool> removeFactor(String factorId) async {
    emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: const UIFlow.loading()));
    try {
      await repository.removeFactor(factorId: factorId);
      if (isClosed) return false;
      await load();
      return true;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(MfaEnrolmentState.methodList(factors: lastFactors));
        rethrow;
      }
      emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Mints a fresh set of backup codes (replacing any existing set
  /// immediately) and shows them — the plaintext exists exactly this once.
  Future<void> generateRecoveryCodes() async {
    emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: const UIFlow.loading()));
    try {
      final minted = await repository.generateRecoveryCodes();
      if (isClosed) return;
      emit(MfaEnrolmentState.recoveryCodes(codes: minted.codes));
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(MfaEnrolmentState.methodList(factors: lastFactors));
        rethrow;
      }
      emit(MfaEnrolmentState.methodList(factors: lastFactors, flow: UIFlow.error(e)));
    }
  }

  /// Opens the recovery-email address entry (both first add and Change —
  /// activating a new address replaces the old factor server-side).
  void startRecoveryEmail() {
    emit(const MfaEnrolmentState.recoveryEmailEntry());
  }

  /// Stages the recovery-email factor, mailing a code to [email]. Returns
  /// whether the flow moved on to code entry.
  Future<bool> submitRecoveryEmail(String email) async {
    final current = state;
    if (current is! MfaSetupRecoveryEmailEntry) return false;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final staged = await repository.beginRecoveryEmail(email: email);
      if (isClosed) return false;
      emit(MfaEnrolmentState.recoveryEmailVerify(factorId: staged.id, email: email));
      return true;
    } on RMApiError catch (e) {
      if (isClosed) return false;
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(current.copyWith(flow: const UIFlow.established()));
        rethrow;
      }
      emit(current.copyWith(flow: UIFlow.error(e)));
      return false;
    }
  }

  /// Re-stages the factor for the same address, which mails a fresh code.
  Future<void> resendRecoveryEmailCode() async {
    final current = state;
    if (current is! MfaSetupRecoveryEmailVerify) return;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      final staged = await repository.beginRecoveryEmail(email: current.email);
      if (isClosed) return;
      emit(MfaEnrolmentState.recoveryEmailVerify(factorId: staged.id, email: current.email));
    } on RMApiError catch (e) {
      if (isClosed) return;
      if (MfaErrorCode.fromError(e)?.isSendThrottled == true) {
        emit(current.copyWith(
            flow: const UIFlow.established(),
            nextSendAfterSeconds: e.retryAfterSeconds ?? MfaEnrolmentCubit.fallbackSendWaitSeconds));
        return;
      }
      if (MfaErrorCode.fromError(e) == MfaErrorCode.stepUpRequired) {
        emit(current.copyWith(flow: const UIFlow.established()));
        rethrow;
      }
      emit(current.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Confirms the mailed code, activating the recovery email.
  Future<TwoFactorAuthResult> verifyRecoveryEmailCode(String code) async {
    final current = state;
    if (current is! MfaSetupRecoveryEmailVerify) return TwoFactorAuthResult.error;
    emit(current.copyWith(flow: const UIFlow.loading()));
    try {
      await repository.verifyRecoveryEmail(factorId: current.factorId, code: code);
      if (isClosed) return TwoFactorAuthResult.error;
      await load();
      return TwoFactorAuthResult.success;
    } on RMApiError catch (e) {
      if (isClosed) return TwoFactorAuthResult.error;
      return mapVerifyError(e);
    }
  }
}

/// Row policy for the security screen, derived from the factors listing.
/// Only **active** factors count as enrolled; `permittedMethods` gates
/// sign-in factors only (backup codes and the recovery email are never
/// gated).
extension SecurityFactorPolicy on MfaFactorsModel {
  MfaFactorModel? activeFactorOf(MfaMethod method) =>
      factors.firstWhereOrNull((f) => f.type == method && f.status == MfaFactorStatus.active);

  /// All active factors of [method] — passkeys can be enrolled more than
  /// once (one per device/credential provider).
  List<MfaFactorModel> activeFactorsOf(MfaMethod method) =>
      factors.where((f) => f.type == method && f.status == MfaFactorStatus.active).toList();

  /// An enrolled sign-in factor whose type has since been withdrawn from
  /// `permittedMethods` stays removable — but can't be set up again.
  bool canSetUp(MfaMethod method) => activeFactorOf(method) == null && permittedMethods.contains(method);

  /// Absent from `permittedMethods` and not enrolled: the row renders
  /// disabled ("by administrator policy").
  bool isDisabledByPolicy(MfaMethod method) =>
      activeFactorOf(method) == null && !permittedMethods.contains(method);

  /// Removing the only active sign-in factor gets the stronger confirm —
  /// the user re-enrols at next login when the provider enforces MFA.
  bool isOnlyActiveLoginFactor(MfaFactorModel factor) =>
      factor.isActiveLoginFactor && factors.where((f) => f.isActiveLoginFactor).length == 1;
}
