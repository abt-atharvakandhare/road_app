import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/session_detail_cubit.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

@GenerateMocks([SessionsRepository])
import 'session_detail_cubit_test.mocks.dart';

void main() {
  late MockSessionsRepository mockRepository;

  final now = DateTime.now();
  final detailSession = SessionModel(
    id: 'session-123',
    kwh: 45.5,
    currency: 'EUR',
    startedAt: now,
    endedAt: now.add(const Duration(hours: 2)),
    status: 'COMPLETED',
    externalCalculatedPrice: 12.50,
    mspLocation: MspLocation(
      id: 'loc-1',
      name: 'Test Station',
      geoLocation: GeoLocation(type: 'Point', coordinates: [4.9, 52.3]),
    ),
  );

  setUp(() {
    mockRepository = MockSessionsRepository();
  });

  group('SessionDetailCubit', () {
    test('initial state has null detailSession and established flow', () {
      final cubit = SessionDetailCubit(mockRepository);
      addTeardownCubit(cubit);

      expect(cubit.state.detailSession, isNull);
      expect(cubit.state.flow.isEstablished, isTrue);
    });

    blocTest<SessionDetailCubit, SessionDetailState>(
      'loadDetail sets detailSession on success',
      build: () {
        when(mockRepository.getSessionDetail('session-123'))
            .thenAnswer((_) async => detailSession);
        return SessionDetailCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDetail('session-123'),
      expect: () => [
        predicate<SessionDetailState>((s) => s.flow.isLoading && s.detailSession == null),
        predicate<SessionDetailState>(
            (s) => s.flow.isEstablished && s.detailSession == detailSession),
      ],
    );

    blocTest<SessionDetailCubit, SessionDetailState>(
      'loadDetail emits error flow on API failure',
      build: () {
        when(mockRepository.getSessionDetail('session-123'))
            .thenThrow(RMApiError(cause: 'Network error'));
        return SessionDetailCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDetail('session-123'),
      expect: () => [
        predicate<SessionDetailState>((s) => s.flow.isLoading),
        predicate<SessionDetailState>((s) => s.flow.isError && s.detailSession == null),
      ],
    );

    test('loadDetail does not emit after cubit is closed', () async {
      when(mockRepository.getSessionDetail('session-123')).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => detailSession),
      );

      final cubit = SessionDetailCubit(mockRepository);
      final future = cubit.loadDetail('session-123');
      await cubit.close();
      await future;

      // After close, detailSession should still be null (no post-close emission)
      expect(cubit.state.detailSession, isNull);
    });
  });
}

/// Helper to ensure cubit is closed after test.
void addTeardownCubit(SessionDetailCubit cubit) {
  addTearDown(() => cubit.close());
}
