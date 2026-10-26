import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/login/auth_renew_response_model.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_session_renewer.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/auth_token_refresher.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

class _MockRepo extends Mock implements AuthRepository {}

class _MockAuthStorage extends Mock implements AuthStorage {}

class _MockRenewalStorage extends Mock implements SessionRenewalTokenStorage {}

class _MockRefresher extends Mock implements AuthTokenRefresher {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late _MockAuthStorage authStorage;
  late _MockRenewalStorage renewalStorage;
  late AuthLifecycleBus lifecycleBus;
  late _MockRefresher refresher;
  late AuthSessionRenewer renewer;

  setUp(() {
    repo = _MockRepo();
    authStorage = _MockAuthStorage();
    renewalStorage = _MockRenewalStorage();
    lifecycleBus = AuthLifecycleBus();
    refresher = _MockRefresher();

    // Sensible defaults — the happy path. Individual tests override.
    when(() => renewalStorage.isAvailable()).thenAnswer((_) async => true);
    when(() => renewalStorage.read(promptReason: any(named: 'promptReason')))
        .thenAnswer((_) async => 'renewal-old');
    when(() => renewalStorage.store(any())).thenAnswer((_) async {});
    when(() => renewalStorage.clear()).thenAnswer((_) async {});
    when(() => authStorage.storeAuthToken(any())).thenAnswer((_) async {});
    when(() => authStorage.deleteDeviceToken()).thenAnswer((_) async {});
    when(() => repo.renewSession(any())).thenAnswer(
      (_) async => AuthRenewResponseModel(token: 'new-jwt', sessionRenewalToken: 'renewal-new'),
    );

    renewer = AuthSessionRenewer(repo, authStorage, renewalStorage, lifecycleBus, refresher);
  });

  test('happy path: stores new JWT + rotated renewal token, publishes SessionRenewed', () async {
    final events = <AuthLifecycleEvent>[];
    lifecycleBus.stream.listen(events.add);

    final outcome = await renewer.tryRenew();
    await Future<void>.delayed(Duration.zero);

    expect(outcome, RenewOutcome.renewed);
    verify(() => repo.renewSession('renewal-old')).called(1);
    verify(() => authStorage.storeAuthToken('new-jwt')).called(1);
    verify(() => renewalStorage.store('renewal-new')).called(1);
    expect(events, [isA<SessionRenewed>()]);
  });

  test('no renewal token available → notAvailable, no network call', () async {
    when(() => renewalStorage.isAvailable()).thenAnswer((_) async => false);

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.notAvailable);
    verifyNever(() => repo.renewSession(any()));
  });

  test('read returns null → clears storage and reports notAvailable', () async {
    when(() => renewalStorage.read(promptReason: any(named: 'promptReason')))
        .thenAnswer((_) async => null);

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.notAvailable);
    verify(() => renewalStorage.clear()).called(1);
    verifyNever(() => repo.renewSession(any()));
  });

  test('biometric cancel on read → userCancelled, token left intact', () async {
    when(() => renewalStorage.read(promptReason: any(named: 'promptReason')))
        .thenThrow(AuthException(AuthExceptionCode.userCanceled, 'cancelled'));

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.userCancelled);
    verifyNever(() => renewalStorage.clear());
    verifyNever(() => repo.renewSession(any()));
  });

  test('biometric read throwing a non-AuthException (iOS permission denied) → userCancelled, not escaped', () async {
    // iOS Face ID permission denied surfaces as a PlatformException(SecurityError),
    // NOT an AuthException. Must be caught so it can't escape and hang the request.
    when(() => renewalStorage.read(promptReason: any(named: 'promptReason')))
        .thenThrow(PlatformException(code: 'SecurityError', message: 'Error retrieving item. -25293'));

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.userCancelled);
    verifyNever(() => repo.renewSession(any()));
  });

  test('JWT-rejected renewal → rejected, clears renewal storage', () async {
    when(() => repo.renewSession(any())).thenThrow(RMApiErrorJwtRejected(cause: 'nope'));

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.rejected);
    verify(() => renewalStorage.clear()).called(1);
    verifyNever(() => authStorage.deleteDeviceToken());
    verifyNever(() => authStorage.storeAuthToken(any()));
  });

  test('device-revoked renewal → rejected, also deletes device token', () async {
    when(() => repo.renewSession(any()))
        .thenThrow(RMApiErrorJwtRejected(cause: 'gone', deviceRevoked: true));

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.rejected);
    verify(() => renewalStorage.clear()).called(1);
    verify(() => authStorage.deleteDeviceToken()).called(1);
  });

  test('transient network error → transientError, renewal token kept', () async {
    when(() => repo.renewSession(any())).thenThrow(Exception('no connectivity'));

    final outcome = await renewer.tryRenew();

    expect(outcome, RenewOutcome.transientError);
    verifyNever(() => renewalStorage.clear());
    verifyNever(() => authStorage.storeAuthToken(any()));
  });

  test('store failure after a successful renew → still renewed, presence flag cleared', () async {
    // JWT is already stored by the time the rotated-token write fails (e.g.
    // user cancels the Android write prompt). Session is live, so we must not
    // report failure — but the consumed old token must not be retried.
    when(() => renewalStorage.store(any())).thenThrow(Exception('write prompt cancelled'));
    final events = <AuthLifecycleEvent>[];
    lifecycleBus.stream.listen(events.add);

    final outcome = await renewer.tryRenew();
    await Future<void>.delayed(Duration.zero);

    expect(outcome, RenewOutcome.renewed);
    verify(() => authStorage.storeAuthToken('new-jwt')).called(1);
    verify(() => renewalStorage.clear()).called(1);
    expect(events, [isA<SessionRenewed>()]);
  });

  test('single-flight: concurrent tryRenew calls collapse to one network call', () async {
    when(() => repo.renewSession(any())).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 30),
        () => AuthRenewResponseModel(token: 'new-jwt', sessionRenewalToken: 'renewal-new'),
      ),
    );

    final results = await Future.wait([renewer.tryRenew(), renewer.tryRenew(), renewer.tryRenew()]);

    expect(results, everyElement(RenewOutcome.renewed));
    verify(() => repo.renewSession(any())).called(1);
  });
}
