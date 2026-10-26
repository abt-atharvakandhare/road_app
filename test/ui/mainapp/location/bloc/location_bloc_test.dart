import 'dart:async';
import 'dart:collection';

import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([SharedPreferences, DebugControlsRepo])
import 'location_bloc_test.mocks.dart';

/// Manual fake for [GeolocatorPlatform]. Allows tests to:
///  - Queue successive `checkPermission` / `requestPermission` results
///    (to simulate Allow Once expiry, permission upgrades, etc.)
///  - Drive the position stream and service-status stream from the test body
///  - Inspect call counts for the permission request guard tests
class FakeGeolocatorPlatform extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  bool serviceEnabled = true;
  Position? lastKnownPosition;
  Position? currentPosition;
  Object? currentPositionError;
  final Queue<LocationPermission> permissionResponses = Queue();
  final Queue<LocationPermission> requestResponses = Queue();
  LocationPermission defaultPermission = LocationPermission.whileInUse;
  LocationPermission defaultRequestResponse = LocationPermission.whileInUse;

  int requestPermissionCallCount = 0;
  int checkPermissionCallCount = 0;
  int positionStreamSubscribeCount = 0;
  int getCurrentPositionCallCount = 0;
  LocationAccuracy? lastSubscribedAccuracy;

  final StreamController<Position> positionController = StreamController<Position>.broadcast();
  final StreamController<ServiceStatus> serviceStatusController =
      StreamController<ServiceStatus>.broadcast();

  /// Optional gate the test can use to hold `requestPermission` mid-call.
  /// When set, the call awaits this completer before returning.
  Completer<void>? requestPermissionGate;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async {
    checkPermissionCallCount++;
    return permissionResponses.isNotEmpty ? permissionResponses.removeFirst() : defaultPermission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCallCount++;
    if (requestPermissionGate != null) {
      await requestPermissionGate!.future;
    }
    return requestResponses.isNotEmpty
        ? requestResponses.removeFirst()
        : defaultRequestResponse;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => lastKnownPosition;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    getCurrentPositionCallCount++;
    if (currentPositionError != null) throw currentPositionError!;
    if (currentPosition != null) return currentPosition!;
    // Default: mimic the real world when no cached fix is available quickly.
    throw TimeoutException('No current position (test default)');
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    positionStreamSubscribeCount++;
    lastSubscribedAccuracy = locationSettings?.accuracy;
    return positionController.stream;
  }

  @override
  Stream<ServiceStatus> getServiceStatusStream() => serviceStatusController.stream;
}

/// Captures every recordError call so tests can assert on (or against) Crashlytics reporting.
class CrashRecorderSpy {
  final List<({Object error, StackTrace? stack, String? reason})> calls = [];

  Future<void> call(Object error, StackTrace? stack, {String? reason}) async {
    calls.add((error: error, stack: stack, reason: reason));
  }
}

Position _testPosition({
  double latitude = 52.3676,
  double longitude = 4.9041,
  double accuracy = 10.0,
  double speed = 0.0,
  double heading = 0.0,
}) =>
    Position(
      longitude: longitude,
      latitude: latitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: heading,
      headingAccuracy: 0,
      speed: speed,
      speedAccuracy: 0,
    );

/// Helper that builds a `LocationBloc` with the supplied fakes. Centralises the
/// optional-constructor wiring so individual tests stay terse.
LocationBloc buildBloc({
  required MockSharedPreferences prefs,
  required Stream<FGBGType> fgbgStream,
  required CrashRecorderSpy recorder,
}) =>
    LocationBloc.forTesting(
      prefs,
      fgbgStream: fgbgStream,
      recordError: recorder.call,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockPrefs;
  late MockDebugControlsRepo mockDebugControlsRepo;
  late FakeGeolocatorPlatform fakeGeolocator;
  late StreamController<FGBGType> fgbgController;
  late CrashRecorderSpy recorder;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockDebugControlsRepo = MockDebugControlsRepo();
    fakeGeolocator = FakeGeolocatorPlatform();
    fgbgController = StreamController<FGBGType>.broadcast();
    recorder = CrashRecorderSpy();

    GeolocatorPlatform.instance = fakeGeolocator;

    if (getIt.isRegistered<DebugControlsRepo>()) {
      getIt.unregister<DebugControlsRepo>();
    }
    getIt.registerSingleton<DebugControlsRepo>(mockDebugControlsRepo);

    when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(false);
    when(mockPrefs.getDouble(any)).thenReturn(null);
    when(mockPrefs.setDouble(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await fgbgController.close();
    await fakeGeolocator.serviceStatusController.close();
    if (!fakeGeolocator.positionController.isClosed) {
      await fakeGeolocator.positionController.close();
    }
    // Swap in a fresh fake so any stray callbacks from the closed controllers
    // can't reach test assertions in the next case.
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
    if (getIt.isRegistered<DebugControlsRepo>()) {
      getIt.unregister<DebugControlsRepo>();
    }
  });

  /// Build the bloc and wait for the constructor-fired `checkServiceStatus` to settle.
  Future<LocationBloc> makeBloc() async {
    final bloc = buildBloc(
      prefs: mockPrefs,
      fgbgStream: fgbgController.stream,
      recorder: recorder,
    );
    // Drain any pending microtasks/events from constructor work.
    await pumpEventQueue();
    return bloc;
  }

  group('LocationBloc', () {
    group('_onCheckServiceStatus', () {
      test('emits serviceDisabled when location services are off', () async {
        fakeGeolocator.serviceEnabled = false;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.serviceDisabled());
        await bloc.close();
      });

      test('with whileInUse permission emits permissionGranted and starts updates', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.permissionGranted());
        // startUpdates was dispatched -> position stream subscribed
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('with always permission emits permissionGranted and starts updates', () async {
        fakeGeolocator.defaultPermission = LocationPermission.always;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.permissionGranted());
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('with deniedForever emits shouldDirectToSettings without prompting', () async {
        fakeGeolocator.defaultPermission = LocationPermission.deniedForever;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.shouldDirectToSettings());
        // requestPermission must NOT be called for deniedForever
        expect(fakeGeolocator.requestPermissionCallCount, 0);
        await bloc.close();
      });

      test('with unableToDetermine emits shouldDirectToSettings', () async {
        fakeGeolocator.defaultPermission = LocationPermission.unableToDetermine;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.shouldDirectToSettings());
        await bloc.close();
      });

      test('with denied + user grants -> permissionGranted and starts updates', () async {
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        expect(fakeGeolocator.requestPermissionCallCount, 1);
        expect(bloc.state, const LocationState.permissionGranted());
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('with denied + user declines (denied) -> shouldDirectToSettings', () async {
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.denied;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.shouldDirectToSettings());
        expect(fakeGeolocator.positionStreamSubscribeCount, 0);
        await bloc.close();
      });

      test('with denied + user declines (deniedForever) -> shouldDirectToSettings', () async {
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.deniedForever;

        final bloc = await makeBloc();

        expect(bloc.state, const LocationState.shouldDirectToSettings());
        await bloc.close();
      });

      test('checkServiceStatus while requestPermission in flight -> guard prevents double-prompt',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.whileInUse;
        // Hold the first request mid-flight so the second event can race it.
        final gate = Completer<void>();
        fakeGeolocator.requestPermissionGate = gate;

        final bloc = buildBloc(
          prefs: mockPrefs,
          fgbgStream: fgbgController.stream,
          recorder: recorder,
        );
        // Wait until the first request has actually started.
        while (fakeGeolocator.requestPermissionCallCount == 0) {
          await pumpEventQueue();
        }
        expect(fakeGeolocator.requestPermissionCallCount, 1);

        // Now race a second checkServiceStatus while the first is still in-flight.
        bloc.add(const LocationEvent.checkServiceStatus());
        await pumpEventQueue();

        expect(fakeGeolocator.requestPermissionCallCount, 1,
            reason: 'guard must short-circuit the second prompt');

        gate.complete();
        await pumpEventQueue();
        await bloc.close();
      });
    });

    group('_onRequestPermission', () {
      test('calls requestPermission then dispatches checkServiceStatus', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        bloc.add(const LocationEvent.requestPermission());
        await pumpEventQueue();

        expect(fakeGeolocator.requestPermissionCallCount, greaterThanOrEqualTo(1));
        // RequestPermission flow always re-runs checkServiceStatus afterwards.
        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        await bloc.close();
      });

      test('concurrent RequestPermission events: second short-circuits via guard', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();
        final requestsBefore = fakeGeolocator.requestPermissionCallCount;

        // Hold the first request so the second has time to race it.
        final gate = Completer<void>();
        fakeGeolocator.requestPermissionGate = gate;

        bloc.add(const LocationEvent.requestPermission());
        while (fakeGeolocator.requestPermissionCallCount == requestsBefore) {
          await pumpEventQueue();
        }

        bloc.add(const LocationEvent.requestPermission());
        await pumpEventQueue();

        expect(fakeGeolocator.requestPermissionCallCount - requestsBefore, 1,
            reason: 'guard must short-circuit the second prompt');

        gate.complete();
        await pumpEventQueue();
        await bloc.close();
      });
    });

    group('_onStartUpdates / position stream', () {
      test('uses _debugLocation when set, does NOT subscribe to platform stream', () async {
        when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(true);
        when(mockPrefs.getDouble('debug_latitude')).thenReturn(1.1);
        when(mockPrefs.getDouble('debug_longitude')).thenReturn(2.2);
        when(mockPrefs.getDouble('debug_accuracy')).thenReturn(3.3);
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        expect(
          bloc.state,
          const LocationState.locationProvided(
            userLocation: UserLocation(latitude: 1.1, longitude: 2.2, accuracy: 3.3),
          ),
        );
        // Debug-location path must NOT subscribe to the real position stream.
        expect(fakeGeolocator.positionStreamSubscribeCount, 0);
        await bloc.close();
      });

      test('does not double-subscribe when StartUpdates fires twice', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();
        // First subscription happened during the constructor's checkServiceStatus.
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);

        bloc.add(const LocationEvent.startUpdates());
        await pumpEventQueue();

        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('emits LocationReceived when getLastKnownPosition returns a value', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        fakeGeolocator.lastKnownPosition = _testPosition(
          latitude: 10.0,
          longitude: 20.0,
          accuracy: 5.0,
          speed: 10.0, // m/s
          heading: 90,
        );

        final bloc = await makeBloc();

        expect(bloc.state, isA<LocationProvided>());
        final provided = bloc.state as LocationProvided;
        expect(provided.userLocation.latitude, 10.0);
        expect(provided.userLocation.longitude, 20.0);
        // Speed is converted from m/s to km/h (multiply by 3.6).
        expect(provided.userLocation.speed, closeTo(36.0, 0.001));
        expect(provided.userLocation.heading, 90);
        await bloc.close();
      });

      test('Android path: lastKnownPosition non-null skips getCurrentPosition (no double emit)',
          () async {
        // On Android the OS returns a cached last-known position immediately; we
        // must NOT then also hit getCurrentPosition, which would double-emit.
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        fakeGeolocator.lastKnownPosition = _testPosition(latitude: 1, longitude: 2);

        final bloc = await makeBloc();

        expect(bloc.state, isA<LocationProvided>());
        expect(fakeGeolocator.getCurrentPositionCallCount, 0,
            reason: 'getCurrentPosition must be skipped when lastKnownPosition is non-null');
        await bloc.close();
      });

      test('Android fallback: lastKnownPosition null -> getCurrentPosition seeds state', () async {
        // On Android, if there's no cached last-known position (fresh boot,
        // cleared cache) the bloc falls through to a low-accuracy one-shot
        // getCurrentPosition before the stream's first emission. The iOS path
        // uses a native CLLocationManager channel instead and is not exercised
        // in unit tests (Platform.isIOS is false on the host).
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        fakeGeolocator.lastKnownPosition = null;
        fakeGeolocator.currentPosition = _testPosition(
          latitude: 40.0,
          longitude: -3.0,
          accuracy: 12.0,
        );

        final bloc = await makeBloc();

        expect(fakeGeolocator.getCurrentPositionCallCount, 1);
        expect(bloc.state, isA<LocationProvided>());
        final provided = bloc.state as LocationProvided;
        expect(provided.userLocation.latitude, 40.0);
        expect(provided.userLocation.longitude, -3.0);
        await bloc.close();
      });

      test('Android fallback: getCurrentPosition timeout is swallowed, stream stays primary',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        // lastKnownPosition stays null, getCurrentPosition default throws TimeoutException.
        final bloc = await makeBloc();

        expect(fakeGeolocator.getCurrentPositionCallCount, 1);
        // No location emitted yet — bloc is still in permissionGranted waiting for stream.
        expect(bloc.state, const LocationState.permissionGranted());
        expect(recorder.calls, isEmpty,
            reason: 'one-shot errors must not reach Crashlytics');

        // Stream still works normally.
        fakeGeolocator.positionController.add(_testPosition(latitude: 5, longitude: 6));
        await pumpEventQueue();
        expect(bloc.state, isA<LocationProvided>());
        await bloc.close();
      });

      test('emits LocationProvided when position stream emits a Position', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        fakeGeolocator.positionController.add(_testPosition(
          latitude: 50.0,
          longitude: 4.0,
          accuracy: 8.0,
          speed: 5.0, // m/s -> 18 km/h
        ));
        await pumpEventQueue();

        expect(bloc.state, isA<LocationProvided>());
        final provided = bloc.state as LocationProvided;
        expect(provided.userLocation.latitude, 50.0);
        expect(provided.userLocation.speed, closeTo(18.0, 0.001));
        await bloc.close();
      });

      test('LocationReceived event emits LocationProvided with the supplied UserLocation',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();

        const ul = UserLocation(latitude: 1, longitude: 2, accuracy: 3);
        bloc.add(const LocationEvent.locationReceived(ul));
        await pumpEventQueue();

        expect(bloc.state, const LocationState.locationProvided(userLocation: ul));
        await bloc.close();
      });
    });

    group('position stream error handler', () {
      test('LocationServiceDisabledException on high-accuracy stream retries with low accuracy',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final firstSub = fakeGeolocator.positionStreamSubscribeCount;
        expect(fakeGeolocator.lastSubscribedAccuracy, isNot(LocationAccuracy.low));

        // Reset the stream so the bloc cancels the old sub and subscribes to a new one.
        fakeGeolocator.positionController.addError(LocationServiceDisabledException());
        await pumpEventQueue();

        expect(fakeGeolocator.positionStreamSubscribeCount, firstSub + 1);
        expect(fakeGeolocator.lastSubscribedAccuracy, LocationAccuracy.low);
        expect(recorder.calls, isEmpty);
        await bloc.close();
      });

      test('LocationServiceDisabledException on low-accuracy stream dispatches checkServiceStatus, no recordError',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        // Force the bloc into the low-accuracy path first.
        fakeGeolocator.positionController.addError(LocationServiceDisabledException());
        await pumpEventQueue();
        expect(fakeGeolocator.lastSubscribedAccuracy, LocationAccuracy.low);

        final checksBefore = fakeGeolocator.checkPermissionCallCount;
        // Now error on the low-accuracy stream — must NOT retry, MUST re-check.
        fakeGeolocator.positionController.addError(LocationServiceDisabledException());
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        expect(recorder.calls, isEmpty);
        await bloc.close();
      });

      test('PermissionDeniedException dispatches checkServiceStatus, no recordError', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        fakeGeolocator.positionController.addError(const PermissionDeniedException(null));
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        expect(recorder.calls, isEmpty);
        await bloc.close();
      });

      test('PositionUpdateException with kCLErrorDomain message -> checkServiceStatus, NO recordError',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        fakeGeolocator.positionController.addError(
          const PositionUpdateException(
            "The operation couldn't be completed. (kCLErrorDomain error 1.)",
          ),
        );
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        expect(recorder.calls, isEmpty,
            reason: 'iOS permission-denied flavour must NOT be reported to Crashlytics');
        await bloc.close();
      });

      test('PositionUpdateException without kCLErrorDomain message DOES recordError', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();

        fakeGeolocator.positionController.addError(
          const PositionUpdateException('Some unexpected position update failure'),
        );
        await pumpEventQueue();

        expect(recorder.calls, hasLength(1));
        expect(recorder.calls.single.reason, 'Geolocator position stream error');
        await bloc.close();
      });

      test('PositionUpdateException with null message DOES recordError (no NPE on the filter)',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();

        fakeGeolocator.positionController.addError(const PositionUpdateException(null));
        await pumpEventQueue();

        expect(recorder.calls, hasLength(1));
        await bloc.close();
      });

      test('Generic Exception is reported to Crashlytics', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();

        fakeGeolocator.positionController.addError(Exception('boom'));
        await pumpEventQueue();

        expect(recorder.calls, hasLength(1));
        await bloc.close();
      });
    });

    group('FGBG and service-status streams', () {
      test('foreground event triggers checkServiceStatus', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        fgbgController.add(FGBGType.foreground);
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        await bloc.close();
      });

      test('background event does NOT trigger checkServiceStatus', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        fgbgController.add(FGBGType.background);
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, checksBefore);
        await bloc.close();
      });

      test('service-status event triggers checkServiceStatus', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        fakeGeolocator.serviceStatusController.add(ServiceStatus.enabled);
        await pumpEventQueue();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        await bloc.close();
      });
    });

    group('_onUseDebugLocation', () {
      test('non-null value emits locationProvided and persists to SharedPreferences', () async {
        when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(true);
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        const debugLoc = UserLocation(latitude: 7, longitude: 8, accuracy: 9);
        bloc.add(const LocationEvent.useDebugLocation(debugLoc));
        await pumpEventQueue();

        expect(bloc.state, const LocationState.locationProvided(userLocation: debugLoc));
        verify(mockPrefs.setDouble('debug_latitude', 7)).called(1);
        verify(mockPrefs.setDouble('debug_longitude', 8)).called(1);
        verify(mockPrefs.setDouble('debug_accuracy', 9)).called(1);
        await bloc.close();
      });

      test('null value clears SharedPreferences and re-checks service status', () async {
        when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(true);
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();
        final checksBefore = fakeGeolocator.checkPermissionCallCount;

        bloc.add(const LocationEvent.useDebugLocation(null));
        await pumpEventQueue();

        verify(mockPrefs.remove('debug_latitude')).called(1);
        verify(mockPrefs.remove('debug_longitude')).called(1);
        verify(mockPrefs.remove('debug_accuracy')).called(1);
        expect(fakeGeolocator.checkPermissionCallCount, greaterThan(checksBefore));
        await bloc.close();
      });
    });

    group('lifecycle and constructor init', () {
      test('debug controls disabled: _debugLocation stays null even if prefs has values', () async {
        when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(false);
        when(mockPrefs.getDouble('debug_latitude')).thenReturn(1.0);
        when(mockPrefs.getDouble('debug_longitude')).thenReturn(2.0);
        when(mockPrefs.getDouble('debug_accuracy')).thenReturn(3.0);
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        // Should NOT use the debug values — should subscribe to real stream instead.
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('debug controls enabled but a pref missing: _debugLocation stays null', () async {
        when(mockDebugControlsRepo.areDebugControlsEnabled).thenReturn(true);
        when(mockPrefs.getDouble('debug_latitude')).thenReturn(1.0);
        when(mockPrefs.getDouble('debug_longitude')).thenReturn(null); // missing
        when(mockPrefs.getDouble('debug_accuracy')).thenReturn(3.0);
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        expect(fakeGeolocator.positionStreamSubscribeCount, 1);
        await bloc.close();
      });

      test('constructor dispatches an initial checkServiceStatus', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;

        final bloc = await makeBloc();

        expect(fakeGeolocator.checkPermissionCallCount, greaterThanOrEqualTo(1));
        await bloc.close();
      });

      test('StopUpdates cancels the position subscription', () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();

        bloc.add(const LocationEvent.stopUpdates());
        await pumpEventQueue();

        // Re-subscription happens when StartUpdates fires; that means the previous
        // subscription was actually cancelled (not just left dangling).
        bloc.add(const LocationEvent.startUpdates());
        await pumpEventQueue();
        expect(fakeGeolocator.positionStreamSubscribeCount, 2);
        await bloc.close();
      });
    });

    group('platform permission state transitions', () {
      test('iOS Allow Once: granted this session, denied next "session" -> shouldDirectToSettings',
          () async {
        // First bloc: granted.
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final firstBloc = await makeBloc();
        expect(firstBloc.state, const LocationState.permissionGranted());
        await firstBloc.close();

        // Simulate a fresh launch where the one-time grant has expired.
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.denied;

        final secondBloc = await makeBloc();
        expect(secondBloc.state, const LocationState.shouldDirectToSettings());
        await secondBloc.close();
      });

      test('Allow Once expires while backgrounded: foreground -> denied -> shouldDirectToSettings',
          () async {
        // First check during construction: granted.
        fakeGeolocator.permissionResponses.add(LocationPermission.whileInUse);
        // Subsequent check after foregrounding: now denied, decline re-prompt.
        fakeGeolocator.permissionResponses.add(LocationPermission.denied);
        fakeGeolocator.defaultRequestResponse = LocationPermission.denied;

        final bloc = await makeBloc();
        expect(bloc.state, const LocationState.permissionGranted());

        fgbgController.add(FGBGType.foreground);
        await pumpEventQueue();

        expect(bloc.state, const LocationState.shouldDirectToSettings());
        await bloc.close();
      });

      test('permission upgrade (whileInUse -> always) keeps state as permissionGranted',
          () async {
        fakeGeolocator.permissionResponses.add(LocationPermission.whileInUse);
        fakeGeolocator.permissionResponses.add(LocationPermission.always);

        final bloc = await makeBloc();
        expect(bloc.state, const LocationState.permissionGranted());

        fgbgController.add(FGBGType.foreground);
        await pumpEventQueue();

        expect(bloc.state, const LocationState.permissionGranted());
        await bloc.close();
      });

      test('Android approximate-only: low-accuracy retry succeeds and emits locations',
          () async {
        fakeGeolocator.defaultPermission = LocationPermission.whileInUse;
        final bloc = await makeBloc();
        expect(fakeGeolocator.lastSubscribedAccuracy, isNot(LocationAccuracy.low));

        // First subscription errors → bloc retries with low accuracy.
        fakeGeolocator.positionController.addError(LocationServiceDisabledException());
        await pumpEventQueue();
        expect(fakeGeolocator.lastSubscribedAccuracy, LocationAccuracy.low);

        // Low-accuracy stream now delivers a position successfully.
        fakeGeolocator.positionController.add(_testPosition(latitude: 1, longitude: 2));
        await pumpEventQueue();
        expect(bloc.state, isA<LocationProvided>());
        await bloc.close();
      });

      test('multiple checkServiceStatus events while one prompt is in-flight: guard catches all extras',
          () async {
        // Simulates the iOS crash window: a prompt is mid-flight when more checks
        // arrive (rapid foreground events, simultaneous service-status changes).
        fakeGeolocator.defaultPermission = LocationPermission.denied;
        fakeGeolocator.defaultRequestResponse = LocationPermission.whileInUse;

        // Gate the constructor's prompt so it stays in-flight.
        final gate = Completer<void>();
        fakeGeolocator.requestPermissionGate = gate;

        final bloc = buildBloc(
          prefs: mockPrefs,
          fgbgStream: fgbgController.stream,
          recorder: recorder,
        );
        // Wait for the first request to actually start.
        while (fakeGeolocator.requestPermissionCallCount == 0) {
          await pumpEventQueue();
        }
        expect(fakeGeolocator.requestPermissionCallCount, 1);

        // Fire more checks — these would otherwise reach requestPermission and crash.
        bloc.add(const LocationEvent.checkServiceStatus());
        bloc.add(const LocationEvent.checkServiceStatus());
        bloc.add(const LocationEvent.checkServiceStatus());
        await pumpEventQueue();

        expect(fakeGeolocator.requestPermissionCallCount, 1,
            reason: 'No additional prompts while the first one is in-flight');

        gate.complete();
        await pumpEventQueue();
        await bloc.close();
      });
    });

    group('integration flows', () {
      test('iOS revoke-and-recover: kCLErrorDomain -> shouldDirectToSettings -> recover via foreground',
          () async {
        // 1. Construction: permission whileInUse, subscribe to position stream.
        fakeGeolocator.permissionResponses.add(LocationPermission.whileInUse);
        final bloc = await makeBloc();
        expect(bloc.state, const LocationState.permissionGranted());
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);

        // 2. User revokes in Settings (master switch off): stream errors with kCLErrorDomain,
        //    permission check now reports denied + decline.
        fakeGeolocator.permissionResponses.add(LocationPermission.denied);
        fakeGeolocator.defaultRequestResponse = LocationPermission.denied;
        fakeGeolocator.positionController.addError(
          const PositionUpdateException('Operation could not be completed (kCLErrorDomain error 1.)'),
        );
        await pumpEventQueue();
        expect(bloc.state, const LocationState.shouldDirectToSettings());

        // 3. User re-enables in Settings and foregrounds the app: permission now whileInUse.
        fakeGeolocator.permissionResponses.add(LocationPermission.whileInUse);
        fgbgController.add(FGBGType.foreground);
        await pumpEventQueue();

        expect(bloc.state, const LocationState.permissionGranted());
        // Fresh subscription was created.
        expect(fakeGeolocator.positionStreamSubscribeCount, 2);
        await bloc.close();
      });

      test('first-run grant flow: denied -> request -> granted -> stream -> location', () async {
        fakeGeolocator.permissionResponses.add(LocationPermission.denied);
        fakeGeolocator.defaultRequestResponse = LocationPermission.whileInUse;

        final bloc = await makeBloc();
        expect(bloc.state, const LocationState.permissionGranted());
        expect(fakeGeolocator.positionStreamSubscribeCount, 1);

        fakeGeolocator.positionController.add(_testPosition(latitude: 11, longitude: 12));
        await pumpEventQueue();
        expect(bloc.state, isA<LocationProvided>());
        await bloc.close();
      });

      test('first-run deny: denied -> request -> denied -> shouldDirectToSettings, no stream', () async {
        fakeGeolocator.permissionResponses.add(LocationPermission.denied);
        fakeGeolocator.defaultRequestResponse = LocationPermission.denied;

        final bloc = await makeBloc();
        expect(bloc.state, const LocationState.shouldDirectToSettings());
        expect(fakeGeolocator.positionStreamSubscribeCount, 0);
        await bloc.close();
      });
    });
  });
}
