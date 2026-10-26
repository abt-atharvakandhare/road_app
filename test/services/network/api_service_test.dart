import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/network/api_error.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/services/network/app_check_token_provider.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/token_status_bus.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/services/di/injection.dart';

@GenerateMocks([PackageInfo, Analytics, DebugControlsRepo, AppCheckTokenProvider])
import 'api_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dio = Dio();
  final dioAdapter = DioAdapter(dio: dio);
  late String baseUrl;
  late ApiService service;
  late MockPackageInfo mockPackageInfo;
  late MockAnalytics mockAnalytics;
  late MockDebugControlsRepo mockDebugControlsRepo;
  late MockAppCheckTokenProvider mockAppCheckTokenProvider;

  setUp(() async {
    // Setup SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Reset GetIt before each test
    await getIt.reset();

    // Create and configure mocks
    mockPackageInfo = MockPackageInfo();
    when(mockPackageInfo.version).thenReturn('1.0.0');
    when(mockPackageInfo.packageName).thenReturn('com.example.app');
    when(mockPackageInfo.buildNumber).thenReturn('1');
    when(mockPackageInfo.buildSignature).thenReturn('signature');
    when(mockPackageInfo.installerStore).thenReturn('store');
    when(mockPackageInfo.appName).thenReturn('Test App');

    // Mock the static fromPlatform method
    PackageInfo.setMockInitialValues(
      appName: 'Test App',
      packageName: 'com.example.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'signature',
    );

    mockAnalytics = MockAnalytics();
    mockAppCheckTokenProvider = MockAppCheckTokenProvider();
    when(mockAppCheckTokenProvider.getLimitedUseToken()).thenAnswer((_) async => null);
    mockDebugControlsRepo = MockDebugControlsRepo();
    when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(false);
    when(mockDebugControlsRepo.stageTarget).thenReturn(StageTarget.production);

    // Register DebugControlsRepo mock
    getIt.registerSingleton<DebugControlsRepo>(mockDebugControlsRepo);

    dio.httpClientAdapter = dioAdapter;
    baseUrl = 'https://api.e-flux.nl';
    service = ApiService(
      dio,
      Stage()..setTarget(StageTarget.production),
      mockAnalytics,
      AuthStorage(const FlutterSecureStorage()),
      TokenStatusBus(),
      AuthLifecycleBus(),
      mockAppCheckTokenProvider,
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('GET ApiService test double retry mechanism', (tester) async {
    await tester.runAsync(() async {
      // Test success
      const okPath = 'okPath';
      dioAdapter.onGet(
        '$baseUrl$okPath',
        (request) {
          return request.reply(200, 'ok');
        },
        data: null,
        queryParameters: {},
        headers: {},
      );
      final response = await service.get(okPath);
      expect(response.statusCode, 200);
      expect(response.data, 'ok');

      /// TEST fail
      const failPath = 'failPath';
      dioAdapter.onGet(
        '$baseUrl$failPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: null,
        queryParameters: {},
        headers: {},
      );

      bool didThrow = false;
      try {
        final _ = await service.get(failPath);
      } on RMApiError catch (e) {
        expect(e.cause, 'ERROR: Server busy');
        didThrow = true;
      }
      expect(didThrow, true);

      /// TEST Fail with recovery - dioAdapter caches responses
      const failRecoverPath = 'failRecoverPath';
      dioAdapter.onGet(
        '$baseUrl$failRecoverPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: null,
        queryParameters: {},
        headers: {},
      );

      // 2 * 2 second delays
      Future.delayed(const Duration(seconds: 3), () {
        dioAdapter.reset();
        dioAdapter.onGet(
          '$baseUrl$failRecoverPath',
          (request) {
            return request.reply(200, 'ok');
          },
          data: null,
          queryParameters: {},
          headers: {},
        );
      });

      didThrow = false;

      final recoverResponse = await service.get(failRecoverPath);
      expect(recoverResponse.statusCode, 200);
      expect(recoverResponse.data, 'ok');
    });
  });

  testWidgets('POST ApiService test double retry mechanism', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const sampledata = 'sampledata';

      // Test success
      const okPath = 'okPath';
      dioAdapter.onPost(
        '$baseUrl$okPath',
        (request) {
          return request.reply(200, 'ok');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );
      final response = await service.post(okPath, data: sampledata);
      expect(response.statusCode, 200);
      expect(response.data, 'ok');

      /// TEST fail
      const failPath = 'failPath';
      dioAdapter.onPost(
        '$baseUrl$failPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      bool didThrow = false;
      try {
        final _ = await service.post(failPath, data: sampledata);
      } on RMApiError catch (e) {
        expect(e.cause, 'ERROR: Server busy');
        didThrow = true;
      }
      expect(didThrow, true);

      /// TEST Fail with recovery - dioAdapter caches responses
      const failRecoverPath = 'failRecoverPath';
      dioAdapter.onPost(
        '$baseUrl$failRecoverPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      // 2 * 2 second delays
      Future.delayed(const Duration(seconds: 3), () {
        dioAdapter.reset();
        dioAdapter.onPost(
          '$baseUrl$failRecoverPath',
          (request) {
            return request.reply(200, 'ok');
          },
          data: sampledata,
          queryParameters: {},
          headers: {},
        );
      });

      final recoverResponse = await service.post(failRecoverPath, data: sampledata);
      expect(recoverResponse.statusCode, 200);
      expect(recoverResponse.data, 'ok');
    });
  });

  testWidgets('PUT ApiService test double retry mechanism', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const sampledata = 'sampledata';

      // Test success
      const okPath = 'okPath';
      dioAdapter.onPut(
        '$baseUrl$okPath',
        (request) {
          return request.reply(200, 'ok');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );
      final response = await service.put(okPath, data: sampledata);
      expect(response.statusCode, 200);
      expect(response.data, 'ok');

      /// TEST fail
      const failPath = 'failPath';
      dioAdapter.onPut(
        '$baseUrl$failPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      bool didThrow = false;
      try {
        final _ = await service.put(failPath, data: sampledata);
      } on RMApiError catch (e) {
        expect(e.cause, 'ERROR: Server busy');
        didThrow = true;
      }
      expect(didThrow, true);

      /// TEST Fail with recovery - dioAdapter caches responses
      const failRecoverPath = 'failRecoverPath';
      dioAdapter.onPut(
        '$baseUrl$failRecoverPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      // 2 * 2 second delays
      Future.delayed(const Duration(seconds: 3), () {
        dioAdapter.reset();
        dioAdapter.onPut(
          '$baseUrl$failRecoverPath',
          (request) {
            return request.reply(200, 'ok');
          },
          data: sampledata,
          queryParameters: {},
          headers: {},
        );
      });

      final recoverResponse = await service.put(failRecoverPath, data: sampledata);
      expect(recoverResponse.statusCode, 200);
      expect(recoverResponse.data, 'ok');
    });
  });

  testWidgets('DELETE ApiService test double retry mechanism', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const sampledata = 'sampledata';

      // Test success
      const okPath = 'okPath';
      dioAdapter.onDelete(
        '$baseUrl$okPath',
        (request) {
          return request.reply(200, 'ok');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );
      final response = await service.delete(okPath, data: sampledata);
      expect(response.statusCode, 200);
      expect(response.data, 'ok');

      /// TEST fail
      const failPath = 'failPath';
      dioAdapter.onDelete(
        '$baseUrl$failPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      bool didThrow = false;
      try {
        final _ = await service.delete(failPath, data: sampledata);
      } on RMApiError catch (e) {
        expect(e.cause, 'ERROR: Server busy');
        didThrow = true;
      }
      expect(didThrow, true);

      /// TEST Fail with recovery - dioAdapter caches responses
      const failRecoverPath = 'failRecoverPath';
      dioAdapter.onDelete(
        '$baseUrl$failRecoverPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      // 2 * 2 second delays
      Future.delayed(const Duration(seconds: 3), () {
        dioAdapter.reset();
        dioAdapter.onDelete(
          '$baseUrl$failRecoverPath',
          (request) {
            return request.reply(200, 'ok');
          },
          data: sampledata,
          queryParameters: {},
          headers: {},
        );
      });

      final recoverResponse = await service.delete(failRecoverPath, data: sampledata);
      expect(recoverResponse.statusCode, 200);
      expect(recoverResponse.data, 'ok');
    });
  });

  testWidgets('GET 401 with TOKEN_EXPIRED throws RMApiErrorJwtRejected(expired: true)', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const path = 'expiredPath';
      dioAdapter.onGet(
        '$baseUrl$path',
        (request) => request.reply(401, {
          'error': {
            'type': 'error',
            'message': 'jwt token has expired',
            'status': 401,
            'details': [
              {'code': 'TOKEN_EXPIRED', 'message': 'jwt token has expired'},
            ],
          },
        }),
        data: null,
        queryParameters: {},
        headers: {},
      );

      RMApiErrorJwtRejected? thrown;
      try {
        await service.get(path);
      } on RMApiErrorJwtRejected catch (e) {
        thrown = e;
      }
      expect(thrown, isNotNull);
      expect(thrown!.expired, isTrue);
    });
  });

  testWidgets('POST 401 with INVALID_SIGNATURE throws RMApiErrorJwtRejected(expired: false)', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const path = 'invalidSigPath';
      dioAdapter.onPost(
        '$baseUrl$path',
        (request) => request.reply(401, {
          'error': {
            'type': 'error',
            'message': 'invalid signature',
            'status': 401,
            'details': [
              {'code': 'INVALID_SIGNATURE', 'message': 'invalid signature'},
            ],
          },
        }),
        data: null,
        queryParameters: {},
        headers: {},
      );

      RMApiErrorJwtRejected? thrown;
      try {
        await service.post(path);
      } on RMApiErrorJwtRejected catch (e) {
        thrown = e;
      }
      expect(thrown, isNotNull);
      expect(thrown!.expired, isFalse);
    });
  });

  testWidgets('GET 401 with no JWT code surfaces as RMApiError, NOT RMApiErrorJwtRejected', (tester) async {
    // A 401 without a JWT-specific code (e.g. /auth/login returning
    // INVALID_CREDENTIALS or a bare "unauthorized") must reach the caller as
    // a normal RMApiError so the screen can show the error to the user. If
    // it leaks as RMApiErrorJwtRejected the global handler silently logs out
    // and the user sees nothing happen.
    dioAdapter.reset();

    await tester.runAsync(() async {
      const path = 'noDetailsPath';
      dioAdapter.onGet(
        '$baseUrl$path',
        (request) => request.reply(401, {
          'error': {'type': 'error', 'message': 'unauthorized', 'status': 401},
        }),
        data: null,
        queryParameters: {},
        headers: {},
      );

      bool sawJwtRejected = false;
      RMApiError? thrown;
      try {
        await service.get(path);
      } on RMApiErrorJwtRejected {
        sawJwtRejected = true;
      } on RMApiError catch (e) {
        thrown = e;
      }
      expect(sawJwtRejected, isFalse);
      expect(thrown, isNotNull);
      expect(thrown!.cause, 'unauthorized');
    });
  });

  testWidgets('POST 401 INVALID_CREDENTIALS (login bad password) surfaces as RMApiError', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const path = '/1/auth/login';
      dioAdapter.onPost(
        '$baseUrl$path',
        (request) => request.reply(401, {
          'error': {
            'type': 'error',
            'message': 'Incorrect email or password',
            'status': 401,
            'details': [
              {'code': 'INVALID_CREDENTIALS', 'message': 'Incorrect email or password'},
            ],
          },
        }),
        data: {'email': 'a@b.c', 'password': 'wrong'},
        queryParameters: {},
        headers: {},
      );

      bool sawJwtRejected = false;
      RMApiError? thrown;
      try {
        await service.post(path, data: {'email': 'a@b.c', 'password': 'wrong'});
      } on RMApiErrorJwtRejected {
        sawJwtRejected = true;
      } on RMApiError catch (e) {
        thrown = e;
      }
      expect(sawJwtRejected, isFalse);
      expect(thrown, isNotNull);
      expect(thrown!.cause, 'Incorrect email or password');
    });
  });

  testWidgets('GET 403 (permission) does NOT throw RMApiErrorJwtRejected', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const path = 'forbiddenPath';
      dioAdapter.onGet(
        '$baseUrl$path',
        (request) => request.reply(403, {
          'error': {'type': 'error', 'message': 'forbidden', 'status': 403},
        }),
        data: null,
        queryParameters: {},
        headers: {},
      );

      bool sawUnauthorized = false;
      bool sawNormalError = false;
      try {
        await service.get(path);
      } on RMApiErrorJwtRejected {
        sawUnauthorized = true;
      } on RMApiError {
        sawNormalError = true;
      }
      expect(sawUnauthorized, isFalse);
      expect(sawNormalError, isTrue);
    });
  });

  testWidgets('PATCH ApiService test double retry mechanism', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const sampledata = 'sampledata';

      // Test success
      const okPath = 'okPath';
      dioAdapter.onPatch(
        '$baseUrl$okPath',
        (request) {
          return request.reply(200, 'ok');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );
      final response = await service.patch(okPath, data: sampledata);
      expect(response.statusCode, 200);
      expect(response.data, 'ok');

      /// TEST fail
      const failPath = 'failPath';
      dioAdapter.onPatch(
        '$baseUrl$failPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      bool didThrow = false;
      try {
        final _ = await service.patch(failPath, data: sampledata);
      } on RMApiError catch (e) {
        expect(e.cause, 'ERROR: Server busy');
        didThrow = true;
      }
      expect(didThrow, true);

      /// TEST Fail with recovery - dioAdapter caches responses
      const failRecoverPath = 'failRecoverPath';
      dioAdapter.onPatch(
        '$baseUrl$failRecoverPath',
        (request) {
          return request.reply(502, 'ERROR: Server busy');
        },
        data: sampledata,
        queryParameters: {},
        headers: {},
      );

      // 2 * 2 second delays
      Future.delayed(const Duration(seconds: 3), () {
        dioAdapter.reset();
        dioAdapter.onPatch(
          '$baseUrl$failRecoverPath',
          (request) {
            return request.reply(200, 'ok');
          },
          data: sampledata,
          queryParameters: {},
          headers: {},
        );
      });

      final recoverResponse = await service.patch(failRecoverPath, data: sampledata);
      expect(recoverResponse.statusCode, 200);
      expect(recoverResponse.data, 'ok');
    });
  });

  group('shouldRetryFor budget-aware 429s', () {
    test('a plain 429 still retries', () {
      expect(service.shouldRetryFor(statusCode: 429), true);
      expect(
          service.shouldRetryFor(statusCode: 429, apiError: ApiError(message: 'Too many requests', status: 429)),
          true);
    });

    test('a 429 carrying retryAfterSeconds is not retried', () {
      final apiError = ApiError(message: 'Too many attempts', status: 429, details: [
        ErrorDetails(code: 'MFA_CHALLENGE_LIMIT_REACHED', retryAfterSeconds: 229),
      ]);
      expect(service.shouldRetryFor(statusCode: 429, apiError: apiError), false);
    });

    test('a 429 with an MFA_ code but no wait is not retried', () {
      final apiError = ApiError(message: 'Too soon', status: 429, details: [
        ErrorDetails(code: 'MFA_CHALLENGE_TOO_SOON'),
      ]);
      expect(service.shouldRetryFor(statusCode: 429, apiError: apiError), false);
    });

    test('a 5xx and a missing response still retry', () {
      expect(service.shouldRetryFor(statusCode: 502), true);
      expect(service.shouldRetryFor(statusCode: null), true);
    });
  });

  testWidgets('POST 429 with an MFA wait surfaces immediately without the retry delays', (tester) async {
    dioAdapter.reset();

    await tester.runAsync(() async {
      const mfaPath = '/1/auth/step-up/challenge';
      dioAdapter.onPost(
        '$baseUrl$mfaPath',
        (request) {
          return request.reply(429, {
            'error': {
              'message': 'Too many attempts.',
              'status': 429,
              'details': [
                {'code': 'MFA_CHALLENGE_LIMIT_REACHED', 'retryAfterSeconds': 229}
              ],
            }
          });
        },
        data: {'method': 'sms'},
        queryParameters: {},
        headers: {},
      );

      final stopwatch = Stopwatch()..start();
      bool didThrow = false;
      try {
        final _ = await service.post(mfaPath, data: {'method': 'sms'});
      } on RMApiError catch (e) {
        didThrow = true;
        expect(e.retryAfterSeconds, 229);
      }
      stopwatch.stop();
      expect(didThrow, true);
      // The retry loop waits 2 seconds per attempt; skipping it means the
      // error arrives well inside that.
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });
  });
}
