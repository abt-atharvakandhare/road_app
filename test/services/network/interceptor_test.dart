import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/network/app_check_token_provider.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/interceptor.dart';
import 'package:road_mobile/services/network/renew_outcome.dart';
import 'package:road_mobile/services/network/token_status_bus.dart';

class _MockAuthStorage extends Mock implements AuthStorage {}

class _MockAppCheckTokenProvider extends Mock implements AppCheckTokenProvider {}

/// Serves a fixed sequence of responses (last one repeats), recording the
/// `Authorization` header seen on each call. Lets a test simulate "401 then
/// 200 on retry".
class _SequencedAdapter implements HttpClientAdapter {
  _SequencedAdapter(this.responses);
  final List<ResponseBody Function()> responses;
  int callCount = 0;
  final List<String?> sentAuth = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    sentAuth.add(options.headers['Authorization'] as String?);
    final i = callCount < responses.length ? callCount : responses.length - 1;
    callCount++;
    return responses[i]();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );

Map<String, dynamic> get _jwt401 => {
      'error': {
        'type': 'error',
        'message': 'jwt token has expired',
        'status': 401,
        'details': [
          {'code': 'TOKEN_EXPIRED', 'message': 'jwt token has expired'},
        ],
      },
    };

/// Captures each outgoing request and replies with the pre-set response.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  Map<String, List<String>> nextResponseHeaders = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        'content-type': ['application/json'],
        ...nextResponseHeaders,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late _CapturingAdapter adapter;
  late _MockAuthStorage storage;
  late TokenStatusBus bus;

  setUp(() {
    dio = Dio();
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    storage = _MockAuthStorage();
    bus = TokenStatusBus();
    dio.interceptors.add(ApiServiceInterceptor(StageTarget.production, storage, dio, tokenStatusBus: bus));

    when(() => storage.readAuthToken()).thenAnswer((_) async => null);
    when(() => storage.readProviderId()).thenAnswer((_) async => null);
    when(() => storage.readDeviceToken()).thenAnswer((_) async => null);
  });

  test('attaches X-Device-Id when device token is stored', () async {
    when(() => storage.readDeviceToken()).thenAnswer((_) async => 'device-abc');

    await dio.get<dynamic>('https://example.com/ping');

    expect(adapter.lastRequest!.headers['X-Device-Id'], 'device-abc');
  });

  test('does not attach X-Device-Id when no device token is stored', () async {
    await dio.get<dynamic>('https://example.com/ping');

    expect(adapter.lastRequest!.headers.containsKey('X-Device-Id'), isFalse);
  });

  test('attaches Authorization Bearer when user token is stored', () async {
    when(() => storage.readAuthToken()).thenAnswer((_) async => 'jwt-1');

    await dio.get<dynamic>('https://example.com/ping');

    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer jwt-1');
  });

  test('publishes "refresh" to TokenStatusBus when response carries X-Token-Status: refresh', () async {
    final events = <String>[];
    bus.stream.listen(events.add);

    adapter.nextResponseHeaders = {
      'x-token-status': ['refresh']
    };
    await dio.get<dynamic>('https://example.com/ping');
    await Future<void>.delayed(Duration.zero);

    expect(events, ['refresh']);
  });

  test('publishes "ending" to TokenStatusBus when response carries X-Token-Status: ending', () async {
    final events = <String>[];
    bus.stream.listen(events.add);

    adapter.nextResponseHeaders = {
      'x-token-status': ['ending']
    };
    await dio.get<dynamic>('https://example.com/ping');
    await Future<void>.delayed(Duration.zero);

    expect(events, ['ending']);
  });

  test('does not publish on "ok" or absent X-Token-Status', () async {
    final events = <String>[];
    bus.stream.listen(events.add);

    adapter.nextResponseHeaders = {
      'x-token-status': ['ok']
    };
    await dio.get<dynamic>('https://example.com/a');

    adapter.nextResponseHeaders = {};
    await dio.get<dynamic>('https://example.com/b');

    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
  });

  test('skips X-Token-Status publish for /auth/refresh (would otherwise loop)', () async {
    when(() => storage.readAuthToken()).thenAnswer((_) async => 'user-jwt');
    final events = <String>[];
    bus.stream.listen(events.add);

    adapter.nextResponseHeaders = {
      'x-token-status': ['refresh']
    };
    await dio.post<dynamic>('https://example.com/1/auth/refresh');

    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty,
        reason: 'publishing on /auth/refresh would cause the refresher to fire another /auth/refresh');
  });

  test('skips X-Token-Status publish for /auth/renew', () async {
    final events = <String>[];
    bus.stream.listen(events.add);

    adapter.nextResponseHeaders = {
      'x-token-status': ['refresh']
    };
    await dio.post<dynamic>('https://example.com/1/auth/renew');

    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
  });

  test('caller-provided Authorization is not overwritten, X-Device-Id still attached', () async {
    when(() => storage.readAuthToken()).thenAnswer((_) async => 'user-jwt');
    when(() => storage.readDeviceToken()).thenAnswer((_) async => 'device-abc');

    await dio.post<dynamic>(
      'https://example.com/1/auth/renew',
      options: Options(headers: {'Authorization': 'Bearer my-renewal-token'}),
    );

    // /auth/renew uses the renewal token in Authorization — interceptor must
    // yield to it. But X-Device-Id is independent and per the guide must be
    // sent on auth requests (login, MFA verify, renewal).
    expect(adapter.lastRequest!.headers['Authorization'], 'Bearer my-renewal-token');
    expect(adapter.lastRequest!.headers['X-Device-Id'], 'device-abc');
  });

  group('X-Firebase-AppCheck attestation', () {
    const guardedPaths = [
      '/1/auth/login',
      '/1/auth/request-password',
      '/1/signup',
    ];

    late Dio adio;
    late _CapturingAdapter aAdapter;
    late _MockAppCheckTokenProvider appCheck;

    setUp(() {
      adio = Dio();
      aAdapter = _CapturingAdapter();
      adio.httpClientAdapter = aAdapter;
      appCheck = _MockAppCheckTokenProvider();
      final astorage = _MockAuthStorage();
      when(() => astorage.readAuthToken()).thenAnswer((_) async => null);
      when(() => astorage.readProviderId()).thenAnswer((_) async => null);
      when(() => astorage.readDeviceToken()).thenAnswer((_) async => null);
      adio.interceptors.add(
        ApiServiceInterceptor(StageTarget.production, astorage, adio, appCheckTokenProvider: appCheck),
      );
    });

    for (final path in guardedPaths) {
      test('attaches X-Firebase-AppCheck on $path', () async {
        when(() => appCheck.getLimitedUseToken()).thenAnswer((_) async => 'app-check-jwt');

        await adio.post<dynamic>('https://example.com$path');

        expect(aAdapter.lastRequest!.headers['X-Firebase-AppCheck'], 'app-check-jwt');
      });
    }

    test('does not attach X-Firebase-AppCheck on non-guarded paths', () async {
      when(() => appCheck.getLimitedUseToken()).thenAnswer((_) async => 'app-check-jwt');

      for (final path in ['/1/signup/countries', '/1/auth/refresh', '/1/map/locations', '/ping']) {
        await adio.post<dynamic>('https://example.com$path');

        expect(aAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse, reason: path);
      }
      verifyNever(() => appCheck.getLimitedUseToken());
    });

    test('proceeds without the header when the token provider throws', () async {
      when(() => appCheck.getLimitedUseToken()).thenThrow(Exception('App Check unavailable'));

      final res = await adio.post<dynamic>('https://example.com/1/auth/login');

      expect(res.statusCode, 200);
      expect(aAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse);
    });

    test('proceeds without the header when the token provider fails asynchronously', () async {
      when(() => appCheck.getLimitedUseToken()).thenAnswer((_) async => throw Exception('App Check unavailable'));

      final res = await adio.post<dynamic>('https://example.com/1/auth/login');

      expect(res.statusCode, 200);
      expect(aAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse);
    });

    test('proceeds without the header when the token fetch exceeds the timeout', () {
      fakeAsync((async) {
        when(() => appCheck.getLimitedUseToken()).thenAnswer((_) => Completer<String?>().future);

        Response<dynamic>? response;
        adio.post<dynamic>('https://example.com/1/auth/login').then((r) => response = r);
        async.elapse(const Duration(seconds: 9));
        async.flushMicrotasks();

        expect(response, isNotNull);
        expect(response!.statusCode, 200);
        expect(aAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse);
      });
    });

    test('proceeds without the header when the token provider returns null', () async {
      when(() => appCheck.getLimitedUseToken()).thenAnswer((_) async => null);

      final res = await adio.post<dynamic>('https://example.com/1/auth/login');

      expect(res.statusCode, 200);
      expect(aAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse);
    });

    test('no provider configured (tests, stage rebuilds) → guarded path still succeeds without header', () async {
      final bare = Dio();
      final bareAdapter = _CapturingAdapter();
      bare.httpClientAdapter = bareAdapter;
      final bstorage = _MockAuthStorage();
      when(() => bstorage.readAuthToken()).thenAnswer((_) async => null);
      when(() => bstorage.readProviderId()).thenAnswer((_) async => null);
      when(() => bstorage.readDeviceToken()).thenAnswer((_) async => null);
      bare.interceptors.add(ApiServiceInterceptor(StageTarget.production, bstorage, bare));

      final res = await bare.post<dynamic>('https://example.com/1/auth/login');

      expect(res.statusCode, 200);
      expect(bareAdapter.lastRequest!.headers.containsKey('X-Firebase-AppCheck'), isFalse);
    });
  });

  group('recover-and-retry on JWT-401', () {
    late Dio rdio;
    late AuthLifecycleBus lifecycleBus;
    late List<AuthLifecycleEvent> events;
    late int recoverCalls;

    setUp(() {
      lifecycleBus = AuthLifecycleBus();
      events = [];
      lifecycleBus.stream.listen(events.add);
      recoverCalls = 0;
    });

    void build(_SequencedAdapter adapter, Future<RenewOutcome> Function() recover) {
      rdio = Dio()..httpClientAdapter = adapter;
      final rstorage = _MockAuthStorage();
      when(() => rstorage.readAuthToken()).thenAnswer((_) async => 'stale-jwt');
      when(() => rstorage.readProviderId()).thenAnswer((_) async => null);
      when(() => rstorage.readDeviceToken()).thenAnswer((_) async => null);
      final interceptor = ApiServiceInterceptor(StageTarget.production, rstorage, rdio, lifecycleBus: lifecycleBus)
        ..setRecover(recover);
      rdio.interceptors.add(interceptor);
    }

    test('recover renewed → retries the original request and resolves', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401), () => _json(200, {'ok': true})]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.renewed;
      });

      final res = await rdio.get<dynamic>('https://example.com/1/foo');

      expect(res.statusCode, 200);
      expect(recoverCalls, 1);
      expect(adapter.callCount, 2); // original 401 + retried 200
      expect(events, isEmpty); // success → no logout
    });

    test('recover rejected → publishes SessionRevoked and surfaces the error', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.rejected;
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(recoverCalls, 1);
      expect(adapter.callCount, 1); // not retried
      expect(events, [isA<SessionRevoked>()]);
    });

    test('recover transientError → surfaces the error, no logout', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.transientError;
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(events, isEmpty); // transient ≠ revoked
    });

    test('retried request that 401s again → no loop, logs out once', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]); // always 401
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.renewed;
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(recoverCalls, 1); // renewed once, not in a loop
      expect(adapter.callCount, 2); // original + a single retry, then gives up
      expect(events, [isA<SessionRevoked>()]);
    });

    test('JWT-401 on /auth/renew does not trigger recovery', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.renewed;
      });

      await expectLater(
        rdio.post<dynamic>(
          'https://example.com/1/auth/renew',
          options: Options(headers: {'Authorization': 'Bearer renewal'}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(recoverCalls, 0);
      expect(events, isEmpty);
    });

    test('recover notAvailable → publishes SessionRevoked, no retry', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.notAvailable;
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(recoverCalls, 1);
      expect(adapter.callCount, 1);
      expect(events, [isA<SessionRevoked>()]);
    });

    test('recover userCancelled → publishes SessionRevoked, no retry', () async {
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        return RenewOutcome.userCancelled;
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(recoverCalls, 1);
      expect(adapter.callCount, 1);
      expect(events, [isA<SessionRevoked>()]);
    });

    test('recover() throwing → request completes (no hang) and logs out', () async {
      // A biometric/keychain platform error escaping the renewer must not stall
      // the request — the interceptor catches it, logs out, and surfaces the
      // error. If it hung instead, this expectLater would time out.
      final adapter = _SequencedAdapter([() => _json(401, _jwt401)]);
      build(adapter, () async {
        recoverCalls++;
        throw Exception('biometric platform error');
      });

      await expectLater(rdio.get<dynamic>('https://example.com/1/foo'), throwsA(isA<DioException>()));

      expect(recoverCalls, 1);
      expect(adapter.callCount, 1); // not retried
      expect(events, [isA<SessionRevoked>()]);
    });

    test('token already rotated since request sent → skips renewal, retries with current token', () async {
      // A concurrent request renewed between this request being sent and its
      // 401 arriving: readAuthToken returns the stale token on the original
      // onRequest, then the rotated token thereafter. recover() must NOT fire
      // (no second biometric prompt) — the interceptor just retries.
      final adapter = _SequencedAdapter([() => _json(401, _jwt401), () => _json(200, {'ok': true})]);
      final rstorage = _MockAuthStorage();
      var authReads = 0;
      when(() => rstorage.readAuthToken()).thenAnswer((_) async => authReads++ == 0 ? 'stale' : 'rotated');
      when(() => rstorage.readProviderId()).thenAnswer((_) async => null);
      when(() => rstorage.readDeviceToken()).thenAnswer((_) async => null);

      final rotatedDio = Dio()..httpClientAdapter = adapter;
      var recovers = 0;
      rotatedDio.interceptors.add(
        ApiServiceInterceptor(StageTarget.production, rstorage, rotatedDio, lifecycleBus: lifecycleBus)
          ..setRecover(() async {
            recovers++;
            return RenewOutcome.renewed;
          }),
      );

      final res = await rotatedDio.get<dynamic>('https://example.com/1/foo');

      expect(res.statusCode, 200);
      expect(recovers, 0); // already rotated → renewal skipped
      expect(adapter.callCount, 2); // original 401 + retry 200
      expect(events, isEmpty);
    });
  });
}
