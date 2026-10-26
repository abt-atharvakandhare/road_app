part of 'session_detail_cubit.dart';

@freezed
sealed class SessionDetailState with _$SessionDetailState {
  const factory SessionDetailState({
    SessionModel? detailSession,
    @Default(UIFlow.established()) UIFlow flow,
  }) = _SessionDetailState;
}
