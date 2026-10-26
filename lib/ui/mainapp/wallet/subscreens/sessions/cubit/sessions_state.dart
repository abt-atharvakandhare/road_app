part of 'sessions_cubit.dart';

@freezed
sealed class SessionsState with _$SessionsState {
  const SessionsState._();

  const factory SessionsState({
    List<SessionModel>? activeSessions,
    List<SessionModel>? allSessions,
    // Filter state
    int? selectedYear,
    int? selectedMonth,
    String? selectedChargeCardTokenId,
    String? selectedPaymentMethod,
    // Stats from API
    SessionStats? stats,
    @Default(UIFlow.established()) UIFlow flow,
  }) = Sessions;

  /// Returns true if any filter is currently active
  bool get hasActiveFilters =>
      selectedYear != null ||
      selectedMonth != null ||
      selectedChargeCardTokenId != null ||
      selectedPaymentMethod != null;

  /// Returns the filter as a DateTime for API calls (combines year and month)
  DateTime? get filterAsDateTime {
    if (selectedYear == null) return null;
    return DateTime(selectedYear!, selectedMonth ?? 1);
  }
}
