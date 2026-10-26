import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/login/auth_refresh_response_model.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/auth_token_refresher.dart';
import 'package:road_mobile/services/network/token_status_bus.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart';

class _MockRepo extends Mock implements AuthRepository {}

class _FakeStorage extends Fake implements AuthStorage {
  String? token;
  String? deviceToken;

  @override
  Future<void> storeAuthToken(String? value) async {
    token = value;
  }

  @override
  Future<void> storeDeviceToken(String value) async {
    deviceToken = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Need this so the SecureStorageInterface fallback type can be set up if any
  // transitive mock construction reaches for it.
  registerFallbackValue(const FlutterSecureStorage());

  late _MockRepo repo;
  late _FakeStorage storage;
  late TokenStatusBus statusBus;
  late AuthLifecycleBus lifecycleBus;
  late AuthTokenRefresher refresher;

  setUp(() {
    repo = _MockRepo();
    storage = _FakeStorage();
    statusBus = TokenStatusBus();
    lifecycleBus = AuthLifecycleBus();
    refresher = AuthTokenRefresher(repo, storage, statusBus, lifecycleBus);
  });

  test('"refresh" header triggers POST /auth/refresh and stores new tokens', () async {
    when(() => repo.refreshToken()).thenAnswer(
      (_) async => AuthRefreshResponseModel(token: 'new-jwt', deviceToken: 'new-device'),
    );

    final rotated = <String>[];
    lifecycleBus.stream.listen((event) {
      if (event is TokenRotated) rotated.add(event.token);
    });

    statusBus.publish('refresh');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    verify(() => repo.refreshToken()).called(1);
    expect(storage.token, 'new-jwt');
    expect(storage.deviceToken, 'new-device');
    expect(rotated, ['new-jwt']);
  });

  test('debounces concurrent "refresh" events into one HTTP call', () async {
    final completer = <Future<AuthRefreshResponseModel>>[];
    when(() => repo.refreshToken()).thenAnswer((_) {
      final f = Future<AuthRefreshResponseModel>.delayed(
        const Duration(milliseconds: 30),
        () => AuthRefreshResponseModel(token: 'jwt-1'),
      );
      completer.add(f);
      return f;
    });

    statusBus.publish('refresh');
    statusBus.publish('refresh');
    statusBus.publish('refresh');
    await Future<void>.delayed(const Duration(milliseconds: 60));

    verify(() => repo.refreshToken()).called(1);
    expect(storage.token, 'jwt-1');
  });

  test('"ending" header publishes SessionEnding to lifecycle bus', () async {
    final events = <AuthLifecycleEvent>[];
    lifecycleBus.stream.listen(events.add);

    statusBus.publish('ending');
    await Future<void>.delayed(Duration.zero);

    expect(events, [isA<SessionEnding>()]);
  });

  test('refresh failure falls through to the registered renewer', () async {
    when(() => repo.refreshToken()).thenThrow(Exception('boom'));
    bool renewerCalled = false;
    refresher.setRenewer(() async {
      renewerCalled = true;
      return false;
    });

    statusBus.publish('refresh');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(renewerCalled, isTrue);
  });
}
