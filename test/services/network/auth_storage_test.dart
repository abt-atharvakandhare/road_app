import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/services/network/auth_storage.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const IOSOptions());
    registerFallbackValue(const AndroidOptions());
  });

  late _MockSecureStorage secure;
  late AuthStorage storage;

  setUp(() {
    secure = _MockSecureStorage();
    storage = AuthStorage(secure);
    when(() => secure.read(key: any(named: 'key'), iOptions: any(named: 'iOptions')))
        .thenAnswer((_) async => 'persisted');
    when(() => secure.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
          iOptions: any(named: 'iOptions'),
          aOptions: any(named: 'aOptions'),
        )).thenAnswer((_) async {});
    when(() => secure.delete(key: any(named: 'key'), iOptions: any(named: 'iOptions')))
        .thenAnswer((_) async {});
  });

  test('repeated reads hit the keychain only once (cache primes on first read)', () async {
    expect(await storage.readAuthToken(), 'persisted');
    expect(await storage.readAuthToken(), 'persisted');
    expect(await storage.readAuthToken(), 'persisted');

    verify(() => secure.read(key: '_auth_token', iOptions: any(named: 'iOptions'))).called(1);
  });

  test('write updates the cache without a re-read', () async {
    await storage.storeAuthToken('fresh');

    expect(await storage.readAuthToken(), 'fresh');
    verifyNever(() => secure.read(key: '_auth_token', iOptions: any(named: 'iOptions')));
  });

  test('delete clears the cache to null without a re-read', () async {
    await storage.storeAuthToken('fresh');
    await storage.deleteAuthToken();

    expect(await storage.readAuthToken(), isNull);
    verifyNever(() => secure.read(key: '_auth_token', iOptions: any(named: 'iOptions')));
  });

  test('caches are per-key (provider/device independent of auth token)', () async {
    await storage.storeProviderId('prov');
    await storage.storeDeviceToken('dev');

    expect(await storage.readProviderId(), 'prov');
    expect(await storage.readDeviceToken(), 'dev');
    // Auth token never written → first read falls through to the keychain.
    expect(await storage.readAuthToken(), 'persisted');
    verify(() => secure.read(key: '_auth_token', iOptions: any(named: 'iOptions'))).called(1);
    verifyNever(() => secure.read(key: '_provider_id', iOptions: any(named: 'iOptions')));
    verifyNever(() => secure.read(key: '_device_token', iOptions: any(named: 'iOptions')));
  });
}
