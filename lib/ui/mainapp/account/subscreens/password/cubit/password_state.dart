part of 'password_cubit.dart';

@freezed
sealed class PasswordState with _$PasswordState {
  const factory PasswordState.password({
    @Default(UIFlow.established()) UIFlow flow,
  }) = Password;
}
