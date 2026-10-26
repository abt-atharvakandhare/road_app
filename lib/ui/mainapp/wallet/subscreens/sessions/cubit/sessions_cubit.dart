import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import 'sessions_repository.dart';

part 'sessions_state.dart';
part 'sessions_cubit.freezed.dart';

@injectable
class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit(this._sessionsRepository) : super(const SessionsState()) {
    loadAllSessions(true);
  }

  final SessionsRepository _sessionsRepository;

  int? allSessionsLimit;
  int? allSessionsSkip;
  int? allSessionsTotal;

  /// Load sessions with current filter state
  Future<void> loadAllSessions(bool fullLoadingState) async {
    try {
      if (fullLoadingState) {
        emit(state.copyWith(flow: const UIFlow.loading()));
      }

      final sessionsFuture = _sessionsRepository.listSessions(
        year: state.selectedYear,
        month: state.selectedMonth,
        tokenId: state.selectedChargeCardTokenId,
        paymentMethod: state.selectedPaymentMethod,
      );
      final activeSessions = await _sessionsRepository.listActiveSessions();
      final sessions = await sessionsFuture;

      allSessionsLimit = sessions.meta.limit;
      allSessionsSkip = sessions.meta.skip;
      allSessionsTotal = sessions.meta.total;

      if (isClosed) {
        return;
      }

      // listActiveSessions sends statuses:['ACTIVE'] to the BE, so the
      // response is already scoped — no need for an extra client-side guard.
      var filteredActiveSessions = _filterSessionsByDate(
        activeSessions.data,
        year: state.selectedYear,
        month: state.selectedMonth,
      );

      emit(state.copyWith(
        activeSessions: filteredActiveSessions,
        allSessions: sessions.data,
        stats: sessions.meta.stats,
        flow: const UIFlow.established(),
      ));
    } on RMApiError catch (e) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }

  /// Apply filters and reload sessions
  Future<void> applyFilters({
    int? year,
    int? month,
    String? chargeCardTokenId,
    String? paymentMethod,
  }) async {
    emit(state.copyWith(
      selectedYear: year,
      selectedMonth: month,
      selectedChargeCardTokenId: chargeCardTokenId,
      selectedPaymentMethod: paymentMethod,
      flow: const UIFlow.loading(),
    ));
    await loadAllSessions(false);
  }

  /// Clear all filters and reload sessions
  Future<void> clearFilters() async {
    emit(state.copyWith(
      selectedYear: null,
      selectedMonth: null,
      selectedChargeCardTokenId: null,
      selectedPaymentMethod: null,
      flow: const UIFlow.loading(),
    ));
    await loadAllSessions(false);
  }

  /// Filters sessions by year and/or month based on their startedAt date.
  List<SessionModel> _filterSessionsByDate(
    List<SessionModel> sessions, {
    int? year,
    int? month,
  }) {
    if (year == null) {
      return sessions;
    }

    return sessions.where((session) {
      final startedAt = session.startedAt;
      if (startedAt.year != year) {
        return false;
      }
      if (month != null && startedAt.month != month) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> loadMoreAllSessions() async {
    // Prevent duplicate loads while already loading
    if (state.flow.isLoading) {
      log('Already loading sessions, skipping');
      return;
    }

    final allSessions = state.allSessions;
    if (allSessions == null || allSessions.isEmpty) {
      log('No sessions to load more');
      return;
    }

    if (allSessions.length >= (allSessionsTotal ?? 0)) {
      log('No more sessions to load');
      return;
    }

    try {
      emit(state.copyWith(flow: const UIFlow.loading()));
      final SessionsResponseModel sessions = await _sessionsRepository.listSessions(
        skip: allSessions.length,
        year: state.selectedYear,
        month: state.selectedMonth,
        tokenId: state.selectedChargeCardTokenId,
        paymentMethod: state.selectedPaymentMethod,
      );

      allSessionsLimit = sessions.meta.limit;
      allSessionsSkip = sessions.meta.skip;
      allSessionsTotal = sessions.meta.total;

      if (isClosed) {
        return;
      }

      emit(state.copyWith(allSessions: [...allSessions, ...sessions.data], flow: const UIFlow.established()));
    } on RMApiError catch (e) {
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }
}
