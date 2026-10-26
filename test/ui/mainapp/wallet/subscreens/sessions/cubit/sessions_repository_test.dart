import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_repository.dart';

@GenerateMocks([ApiService])
import 'sessions_repository_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late SessionsRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = SessionsRepository(mockApiService);
  });

  group('SessionsRepository', () {
    group('listActiveSessions', () {
      test('should return active sessions response', () async {
        final mockResponseData = {
          'data': [],
          'meta': {
            'limit': 50,
            'skip': 0,
            'total': 0,
          },
        };

        when(mockApiService.post('/1/active-sessions/mine',
                data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/active-sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        final result = await repository.listActiveSessions();

        expect(result, isA<SessionsResponseModel>());
        expect(result.data, isEmpty);
        expect(result.meta.total, equals(0));
        verify(mockApiService.post('/1/active-sessions/mine',
                data: {'ownership': 'user', 'statuses': ['ACTIVE']}))
            .called(1);
      });

    });

    group('listSessions', () {
      test('should return sessions with stats', () async {
        final mockResponseData = {
          'data': [],
          'meta': {
            'limit': 50,
            'skip': 0,
            'total': 100,
            'stats': {
              'totalKwh': 145.5,
              'totalCosts': 52.30,
              'totalDurationSeconds': 19800.0,
              'currency': 'EUR',
            },
          },
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        final result = await repository.listSessions();

        expect(result, isA<SessionsResponseModel>());
        expect(result.meta.stats, isNotNull);
        expect(result.meta.stats!.totalKwh, equals(145.5));
        expect(result.meta.stats!.totalCosts, equals(52.30));
        expect(result.meta.stats!.totalDurationSeconds, equals(19800.0));
        expect(result.meta.stats!.currency, equals('EUR'));
      });

      test('should handle missing stats field', () async {
        final mockResponseData = {
          'data': [],
          'meta': {
            'limit': 50,
            'skip': 0,
            'total': 100,
          },
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        final result = await repository.listSessions();

        expect(result, isA<SessionsResponseModel>());
        expect(result.meta.stats, isNull);
      });

      test('should handle null stats field', () async {
        final mockResponseData = {
          'data': [],
          'meta': {
            'limit': 50,
            'skip': 0,
            'total': 100,
            'stats': null,
          },
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        final result = await repository.listSessions();

        expect(result, isA<SessionsResponseModel>());
        expect(result.meta.stats, isNull);
      });

      test('should include skip parameter when provided', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 25, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(skip: 25);

        verify(mockApiService.post('/1/sessions/mine',
                data: argThat(contains('skip'), named: 'data')))
            .called(1);
      });

      test('should include limit parameter when provided', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 100, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(limit: 100);

        verify(mockApiService.post('/1/sessions/mine',
                data: argThat(contains('limit'), named: 'data')))
            .called(1);
      });

      test('should build date range filter for year only', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(year: 2024);

        final captured = verify(mockApiService.post('/1/sessions/mine',
                data: captureAnyNamed('data')))
            .captured
            .single as Map;

        expect(captured['from'], contains('2024-01-01'));
        expect(captured['to'], contains('2025-01-01'));
      });

      test('should build date range filter for year and month', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(year: 2024, month: 6);

        final captured = verify(mockApiService.post('/1/sessions/mine',
                data: captureAnyNamed('data')))
            .captured
            .single as Map;

        expect(captured['from'], contains('2024-06-01'));
        expect(captured['to'], contains('2024-07-01'));
      });

      test('should include tokenId filter when provided', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(tokenId: 'token123');

        final captured = verify(mockApiService.post('/1/sessions/mine',
                data: captureAnyNamed('data')))
            .captured
            .single as Map;

        expect(captured['tokenId'], equals('token123'));
      });

      test('should include paymentMethod filter when provided', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(paymentMethod: 'credit_card');

        final captured = verify(mockApiService.post('/1/sessions/mine',
                data: captureAnyNamed('data')))
            .captured
            .single as Map;

        expect(captured['paymentMethod'], equals('credit_card'));
      });

      test('should include all filters when provided', () async {
        final mockResponseData = {
          'data': [],
          'meta': {'limit': 50, 'skip': 0, 'total': 100},
        };

        when(mockApiService.post('/1/sessions/mine', data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/1/sessions/mine'),
                  data: mockResponseData,
                  statusCode: 200,
                ));

        await repository.listSessions(
          skip: 10,
          limit: 25,
          year: 2024,
          month: 3,
          tokenId: 'token456',
          paymentMethod: 'direct_debit',
        );

        final captured = verify(mockApiService.post('/1/sessions/mine',
                data: captureAnyNamed('data')))
            .captured
            .single as Map;

        expect(captured['skip'], equals(10));
        expect(captured['limit'], equals(25));
        expect(captured['from'], contains('2024-03-01'));
        expect(captured['to'], contains('2024-04-01'));
        expect(captured['tokenId'], equals('token456'));
        expect(captured['paymentMethod'], equals('direct_debit'));
      });

    });
  });
}
