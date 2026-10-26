import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

import 'sessions_repository.dart';

part 'session_detail_state.dart';
part 'session_detail_cubit.freezed.dart';

@injectable
class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit(this._sessionsRepository)
      : super(const SessionDetailState(flow: UIFlow.established()));

  final SessionsRepository _sessionsRepository;

  Future<void> loadDetail(String sessionId) async {
    emit(state.copyWith(flow: const UIFlow.loading()));

    try {
      final detail = await _sessionsRepository.getSessionDetail(sessionId);

      if (isClosed) return;

      emit(state.copyWith(
        detailSession: detail,
        flow: const UIFlow.established(),
      ));
    } on RMApiError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(flow: UIFlow.error(e)));
    }
  }
}
