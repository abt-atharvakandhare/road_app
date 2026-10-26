import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_cubit.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

@GenerateMocks([SessionsRepository])
import 'sessions_cubit_test.mocks.dart';

void main() {
  late MockSessionsRepository mockRepository;
  SessionsCubit? cubit;

  final now = DateTime.now();
  final sessionModel = SessionModel(
    kwh: 45.5,
    currency: 'EUR',
    startedAt: now,
    status: 'COMPLETED',
  );

  final activeSessionModel = SessionModel(
    kwh: 10.0,
    currency: 'EUR',
    startedAt: now,
    status: 'ACTIVE',
    endedAt: null,
  );

  final statsWithData = SessionStats(
    totalKwh: 145.5,
    totalCosts: 52.30,
    totalDurationSeconds: 19800.0,
    currency: 'EUR',
  );

  final mockResponseWithStats = SessionsResponseModel(
    data: [sessionModel],
    meta: Meta(
      limit: 50,
      skip: 0,
      total: 100,
      stats: statsWithData,
    ),
  );

  final mockResponseWithoutStats = SessionsResponseModel(
    data: [sessionModel],
    meta: Meta(
      limit: 50,
      skip: 0,
      total: 100,
      stats: null,
    ),
  );

  final mockActiveSessionsResponse = SessionsResponseModel(
    data: [activeSessionModel],
    meta: Meta(
      limit: 50,
      skip: 0,
      total: 1,
    ),
  );

  setUp(() {
    mockRepository = MockSessionsRepository();
  });

  tearDown(() {
    cubit?.close();
  });

  group('SessionsCubit', () {
    group('initialization', () {
      test('should start with empty state and call loadAllSessions', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);

        // Wait for initialization to complete
        await pumpEventQueue();

        verify(mockRepository.listActiveSessions()).called(1);
        verify(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).called(1);
      });

      // DRI-946: a pre-set year/month default hid all history older than the
      // current month. The first load must be unfiltered.
      test('should start with no filters and load the full history', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);

        expect(cubit!.state.selectedYear, isNull);
        expect(cubit!.state.selectedMonth, isNull);
        expect(cubit!.state.hasActiveFilters, isFalse);

        await pumpEventQueue();

        verify(mockRepository.listSessions(
          skip: null,
          limit: null,
          year: null,
          month: null,
          tokenId: null,
          paymentMethod: null,
        )).called(1);
        // The unfiltered load must not drop any active sessions either.
        expect(cubit!.state.activeSessions, equals([activeSessionModel]));
      });
    });

    group('loadAllSessions', () {
      test('should load sessions with stats from API', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        expect(cubit!.state.stats, equals(statsWithData));
        expect(cubit!.state.allSessions, isNotNull);
        expect(cubit!.state.allSessions!.length, equals(1));
        expect(cubit!.state.flow.isEstablished, isTrue);
      });

      test('should handle null stats gracefully', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithoutStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        expect(cubit!.state.stats, isNull);
        expect(cubit!.state.allSessions, isNotNull);
        expect(cubit!.state.flow.isEstablished, isTrue);
      });

      blocTest<SessionsCubit, SessionsState>(
        'should emit error state on API failure',
        build: () {
          when(mockRepository.listActiveSessions())
              .thenAnswer((_) async => mockActiveSessionsResponse);
          when(mockRepository.listSessions(
            skip: anyNamed('skip'),
            limit: anyNamed('limit'),
            year: anyNamed('year'),
            month: anyNamed('month'),
            tokenId: anyNamed('tokenId'),
            paymentMethod: anyNamed('paymentMethod'),
          )).thenThrow(RMApiError(cause: 'Network error'));
          return SessionsCubit(mockRepository);
        },
        act: (cubit) async {
          await pumpEventQueue();
          await cubit.loadAllSessions(true);
        },
        skip: 1,
        expect: () => [
          predicate<SessionsState>((state) => state.flow.isError),
        ],
      );

      test('should not emit loading state when fullLoadingState is false', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        // Call with fullLoadingState = false
        await cubit!.loadAllSessions(false);

        expect(cubit!.state.stats, equals(statsWithData));
        expect(cubit!.state.allSessions, isNotNull);
        expect(cubit!.state.flow.isEstablished, isTrue);
      });

      test('should update allSessionsTotal metadata', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();
        await cubit!.loadAllSessions(true);

        expect(cubit!.allSessionsTotal, equals(100));
        expect(cubit!.allSessionsLimit, equals(50));
        expect(cubit!.allSessionsSkip, equals(0));
      });
    });

    group('applyFilters', () {
      test('should update filter state and reload sessions with stats preserved', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        await cubit!.applyFilters(
          year: 2024,
          month: 3,
          chargeCardTokenId: 'token123',
          paymentMethod: 'credit_card',
        );

        expect(cubit!.state.selectedYear, equals(2024));
        expect(cubit!.state.selectedMonth, equals(3));
        expect(cubit!.state.selectedChargeCardTokenId, equals('token123'));
        expect(cubit!.state.selectedPaymentMethod, equals('credit_card'));
        expect(cubit!.state.stats, equals(statsWithData));
        expect(cubit!.state.flow.isEstablished, isTrue);
      });

      test('should call repository with filter parameters', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();
        await cubit!.applyFilters(
          year: 2024,
          month: 6,
          chargeCardTokenId: 'token456',
          paymentMethod: 'direct_debit',
        );

        verify(mockRepository.listSessions(
          year: 2024,
          month: 6,
          tokenId: 'token456',
          paymentMethod: 'direct_debit',
        )).called(1);
      });
    });

    group('clearFilters', () {
      test('should clear all filter state and reload sessions', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        // First set some filters
        await cubit!.applyFilters(
          year: 2024,
          month: 3,
          chargeCardTokenId: 'token123',
          paymentMethod: 'credit_card',
        );

        // Then clear them
        await cubit!.clearFilters();

        expect(cubit!.state.selectedYear, isNull);
        expect(cubit!.state.selectedMonth, isNull);
        expect(cubit!.state.selectedChargeCardTokenId, isNull);
        expect(cubit!.state.selectedPaymentMethod, isNull);
        expect(cubit!.state.stats, equals(statsWithData));
        expect(cubit!.state.flow.isEstablished, isTrue);
      });
    });

    group('loadMoreAllSessions', () {
      test('should load more sessions without updating stats', () async {
        final loadMoreResponse = SessionsResponseModel(
          data: [sessionModel],
          meta: Meta(
            limit: 50,
            skip: 1,
            total: 100,
            stats: SessionStats(
              totalKwh: 999.9, // Different stats that should NOT be used
              totalCosts: 999.9,
              totalDurationSeconds: 999.9,
              currency: 'USD',
            ),
          ),
        );

        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        // Constructor call returns stats with 145.5
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        // Verify stats are set correctly after constructor
        expect(cubit!.state.stats!.totalKwh, equals(145.5));
        final originalStats = cubit!.state.stats;

        // Re-stub for loadMore call — returns different stats that should NOT overwrite
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => loadMoreResponse);

        await cubit!.loadMoreAllSessions();

        expect(cubit!.state.allSessions!.length, equals(2)); // Original + new
        // Original stats preserved (should be same instance, not updated)
        expect(cubit!.state.stats, same(originalStats));
        expect(cubit!.state.flow.isEstablished, isTrue);
      });

      test('should not load more when all sessions already loaded', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer(
            (_) async => mockResponseWithStats.copyWith(
                  meta: mockResponseWithStats.meta.copyWith(total: 1),
                ));

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        final lengthBefore = cubit!.state.allSessions!.length;
        await cubit!.loadMoreAllSessions();
        final lengthAfter = cubit!.state.allSessions!.length;

        // Length should be the same since all sessions are loaded
        expect(lengthAfter, equals(lengthBefore));
      });

      test('should handle error when loading more sessions', () async {
        when(mockRepository.listActiveSessions())
            .thenAnswer((_) async => mockActiveSessionsResponse);
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => mockResponseWithStats);

        cubit = SessionsCubit(mockRepository);
        await pumpEventQueue();

        // Re-stub to throw for the loadMore call
        when(mockRepository.listSessions(
          skip: anyNamed('skip'),
          limit: anyNamed('limit'),
          year: anyNamed('year'),
          month: anyNamed('month'),
          tokenId: anyNamed('tokenId'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenThrow(RMApiError(cause: 'Network error'));

        await cubit!.loadMoreAllSessions();

        expect(cubit!.state.flow.isError, isTrue);
      });
    });

    group('hasActiveFilters', () {
      test('should return true when year filter is set', () {
        final state = const SessionsState(selectedYear: 2024);
        expect(state.hasActiveFilters, isTrue);
      });

      test('should return true when month filter is set', () {
        final state = const SessionsState(selectedMonth: 6);
        expect(state.hasActiveFilters, isTrue);
      });

      test('should return true when charge card filter is set', () {
        final state =
            const SessionsState(selectedChargeCardTokenId: 'token123');
        expect(state.hasActiveFilters, isTrue);
      });

      test('should return true when payment method filter is set', () {
        final state =
            const SessionsState(selectedPaymentMethod: 'credit_card');
        expect(state.hasActiveFilters, isTrue);
      });

      test('should return false when no filters are set', () {
        final state = const SessionsState();
        expect(state.hasActiveFilters, isFalse);
      });
    });
  });
}

// Extension to add copyWith to SessionsResponseModel and Meta for testing
extension SessionsResponseModelX on SessionsResponseModel {
  SessionsResponseModel copyWith({Meta? meta}) {
    return SessionsResponseModel(
      data: data,
      meta: meta ?? this.meta,
    );
  }
}

extension MetaX on Meta {
  Meta copyWith({int? total}) {
    return Meta(
      limit: limit,
      skip: skip,
      total: total ?? this.total,
      stats: stats,
    );
  }
}
