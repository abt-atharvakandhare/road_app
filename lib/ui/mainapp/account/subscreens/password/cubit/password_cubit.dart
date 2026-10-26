import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/password/cubit/password_repo.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_error_code.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

part 'password_state.dart';
part 'password_cubit.freezed.dart';

@injectable
class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit(this._passwordRepo) : super(const PasswordState.password());

  final PasswordRepo _passwordRepo;

  /// Changing the password is step-up-gated server-side; a
  /// `MFA_STEP_UP_REQUIRED` demand is rethrown so the screen can run the
  /// call through `runWithStepUp` (challenge sheet + one retry).
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      await _passwordRepo.changePassword(currentPassword, newPassword);
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
  }
}
