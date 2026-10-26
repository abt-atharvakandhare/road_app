import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/car_screen/car_screen.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_repository.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([NearestStationsCubit, NearestStationsRepository, LocationBloc])
import 'car_screen_test.mocks.dart';

// Two layers of coverage:
// 1. "CarScreen channel integration": real CarScreen instances driven through
//    a mocked platform channel — session activation (pull and push), the
//    empty-station-send guard, and the locationPermissionChanged recheck.
// 2. "CarScreen state validation patterns": the cubit-interaction patterns
//    CarScreen relies on (isClosed guards, stream handling).

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNearestStationsCubit mockCubit;
  late StreamController<NearestStationsState> stateStreamController;

  final testLocation = const UserLocation(
    latitude: 52.3676,
    longitude: 4.9041,
    accuracy: 10.0,
    speed: 80.0,
    heading: 90.0,
  );

  final testState = NearestStationsState(
    stations: [],
    userLocation: testLocation,
    mode: NearestStationsMode.carScreen,
    flow: UIFlow.established(),
    isHighwayModeActive: true,
  );

  setUpAll(() {
    // Provide dummy values for sealed/freezed classes that mockito can't generate
    provideDummy<NearestStationsState>(NearestStationsState(
      stations: [],
      mode: NearestStationsMode.carScreen,
    ));
  });

  setUp(() {
    mockCubit = MockNearestStationsCubit();
    stateStreamController = StreamController<NearestStationsState>.broadcast();

    when(mockCubit.stream).thenAnswer((_) => stateStreamController.stream);
    when(mockCubit.state).thenReturn(testState);
    when(mockCubit.isClosed).thenReturn(false);
  });

  tearDown(() {
    stateStreamController.close();
  });

  group('CarScreen channel integration', () {
    const channelName = 'io.e-flux.mobile/auto';
    const channel = MethodChannel(channelName);
    const codec = StandardMethodCodec();

    late MockLocationBloc mockLocationBloc;
    late List<MethodCall> outgoingCalls;
    CarScreen? carScreen;

    /// Installs a mock native side: records every Dart->native call and
    /// answers getCarSessionState with [sessionActive].
    void installNativeMock({required bool sessionActive}) {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        outgoingCalls.add(call);
        if (call.method == 'getCarSessionState') return sessionActive;
        return 'OK';
      });
    }

    /// Delivers a native->Dart method call to CarScreen's handler.
    Future<void> deliverFromNative(String method, [dynamic arguments]) async {
      await TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channelName,
        codec.encodeMethodCall(MethodCall(method, arguments)),
        (_) {},
      );
    }

    List<String> outgoingMethods() => outgoingCalls.map((c) => c.method).toList();

    setUpAll(() {
      // late field — assignable exactly once per test process
      F.appFlavor = Flavor.eflux;
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      outgoingCalls = [];
      mockLocationBloc = MockLocationBloc();

      when(mockCubit.refresh()).thenAnswer((_) async {});
      when(mockCubit.close()).thenAnswer((_) async {});
      when(mockCubit.getFormattedLocationsForCarScreen(isLoggedIn: anyNamed('isLoggedIn'))).thenReturn([]);

      GetIt.instance.registerFactoryParam<NearestStationsCubit, NearestStationsConfig?, void>(
        (config, _) => mockCubit,
      );
      GetIt.instance.registerSingleton<LocationBloc>(mockLocationBloc);
    });

    tearDown(() async {
      carScreen?.dispose();
      carScreen = null;
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
      await GetIt.instance.reset();
    });

    test('activates the pipeline when native reports an active session (pull)', () async {
      installNativeMock(sessionActive: true);

      carScreen = CarScreen();
      await pumpEventQueue();

      expect(outgoingMethods(), contains('getCarSessionState'));
      expect(outgoingMethods(), contains('sendUiStrings'));
      expect(outgoingMethods(), contains('sendFilterDefinitions'));
      verify(mockCubit.refresh()).called(1);
    });

    test('stays inactive when native reports no session', () async {
      installNativeMock(sessionActive: false);

      carScreen = CarScreen();
      await pumpEventQueue();

      expect(outgoingMethods(), contains('getCarSessionState'));
      expect(outgoingMethods(), isNot(contains('sendUiStrings')));
      verifyNever(mockCubit.refresh());
    });

    test('survives a native side without getCarSessionState', () async {
      // No mock handler installed: invokeMethod throws MissingPluginException.
      carScreen = CarScreen();
      await pumpEventQueue();

      verifyNever(mockCubit.refresh());
    });

    test('activates on the carSystemStateChanged push', () async {
      installNativeMock(sessionActive: false);

      carScreen = CarScreen();
      await pumpEventQueue();
      expect(outgoingMethods(), isNot(contains('sendUiStrings')));

      await deliverFromNative('carSystemStateChanged', true);
      await pumpEventQueue();

      expect(outgoingMethods(), contains('sendUiStrings'));
      verify(mockCubit.refresh()).called(1);
    });

    test('does not send an empty station list while the first fetch is loading', () async {
      when(mockCubit.state).thenReturn(NearestStationsState(
        stations: [],
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.loading(),
      ));
      installNativeMock(sessionActive: true);

      carScreen = CarScreen();
      await pumpEventQueue();

      // Localization updates re-send data to native while a session is active —
      // this is the path that previously pushed a premature empty list.
      carScreen!.updateLocalizations(lookupAppLocalizations(const Locale('en')));
      await pumpEventQueue();

      expect(outgoingMethods(), isNot(contains('sendLocations')));
    });

    test('sends the empty station list once the fetch is established', () async {
      when(mockCubit.state).thenReturn(NearestStationsState(
        stations: [],
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
      ));
      installNativeMock(sessionActive: true);

      carScreen = CarScreen();
      await pumpEventQueue();

      carScreen!.updateLocalizations(lookupAppLocalizations(const Locale('en')));
      await pumpEventQueue();

      final sendLocations = outgoingCalls.where((c) => c.method == 'sendLocations').toList();
      expect(sendLocations, isNotEmpty);
      expect((sendLocations.last.arguments as Map)['locations'], isEmpty);
    });

    test('locationPermissionChanged triggers a LocationBloc recheck', () async {
      installNativeMock(sessionActive: false);

      carScreen = CarScreen();
      await pumpEventQueue();

      await deliverFromNative('locationPermissionChanged');
      await pumpEventQueue();

      verify(mockLocationBloc.add(const LocationEvent.checkServiceStatus())).called(1);
    });
  });

  group('CarScreen state validation patterns', () {
    group('isClosed checks', () {
      test('should not call methods on closed cubit', () {
        // Simulate cubit being closed
        when(mockCubit.isClosed).thenReturn(true);

        // The pattern used in CarScreen:
        // if (_nearestStationsCubit == null || _nearestStationsCubit!.isClosed) return;

        final cubit = mockCubit;
        final shouldSkip = cubit.isClosed;

        expect(shouldSkip, true);

        // Verify that if we check isClosed before calling methods,
        // we can avoid calling methods on a closed cubit
        if (!cubit.isClosed) {
          cubit.refresh(); // This should NOT be called
        }

        verifyNever(mockCubit.refresh());
      });

      test('should call methods on open cubit', () {
        when(mockCubit.isClosed).thenReturn(false);
        when(mockCubit.refresh()).thenAnswer((_) async {});

        final cubit = mockCubit;

        if (!cubit.isClosed) {
          cubit.refresh();
        }

        verify(mockCubit.refresh()).called(1);
      });

      test('should handle null cubit gracefully', () {
        // The pattern used in CarScreen:
        // if (_nearestStationsCubit == null || _nearestStationsCubit!.isClosed) return;

        // Test with a function that simulates the null check pattern
        bool shouldSkipOperation(MockNearestStationsCubit? cubit) {
          return cubit == null || cubit.isClosed;
        }

        // Null cubit should skip
        expect(shouldSkipOperation(null), true);

        // Non-null open cubit should not skip
        when(mockCubit.isClosed).thenReturn(false);
        expect(shouldSkipOperation(mockCubit), false);

        // Non-null closed cubit should skip
        when(mockCubit.isClosed).thenReturn(true);
        expect(shouldSkipOperation(mockCubit), true);
      });

      test('should handle isClosed == false check for toggle', () {
        when(mockCubit.isClosed).thenReturn(false);

        // The pattern used in toggleHighwayAutoEnabled:
        // if (_nearestStationsCubit?.isClosed == false) { ... }

        final cubit = mockCubit;
        final shouldProceed = cubit.isClosed == false;

        expect(shouldProceed, true);
      });

      test('should skip toggle when cubit is closed', () {
        when(mockCubit.isClosed).thenReturn(true);

        final cubit = mockCubit;
        final shouldProceed = cubit.isClosed == false;

        expect(shouldProceed, false);
      });
    });

    group('setHighwayMode', () {
      test('should call setHighwayMode on cubit when not closed', () {
        when(mockCubit.isClosed).thenReturn(false);

        final cubit = mockCubit;

        if (cubit.isClosed == false) {
          cubit.setHighwayMode(HighwayMode.off);
        }

        verify(mockCubit.setHighwayMode(HighwayMode.off)).called(1);
      });

      test('should not call setHighwayMode when cubit is closed', () {
        when(mockCubit.isClosed).thenReturn(true);

        final cubit = mockCubit;

        if (cubit.isClosed == false) {
          cubit.setHighwayMode(HighwayMode.off);
        }

        verifyNever(mockCubit.setHighwayMode(any));
      });
    });

    group('getFormattedLocationsForCarScreen', () {
      test('should get formatted locations when cubit is not closed', () {
        when(mockCubit.isClosed).thenReturn(false);
        when(mockCubit.getFormattedLocationsForCarScreen()).thenReturn([
          {'lat': 52.0, 'lng': 4.0, 'name': 'Test Station'},
        ]);

        final cubit = mockCubit;
        List<Map<String, dynamic>>? result;

        if (!cubit.isClosed) {
          result = cubit.getFormattedLocationsForCarScreen();
        }

        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result[0]['name'], 'Test Station');
      });

      test('should not get formatted locations when cubit is closed', () {
        when(mockCubit.isClosed).thenReturn(true);

        final cubit = mockCubit;
        List<Map<String, dynamic>>? result;

        if (!cubit.isClosed) {
          result = cubit.getFormattedLocationsForCarScreen();
        }

        expect(result, isNull);
        verifyNever(mockCubit.getFormattedLocationsForCarScreen());
      });
    });

    group('stream subscription handling', () {
      test('should receive state updates from cubit stream', () async {
        final states = <NearestStationsState>[];

        final subscription = mockCubit.stream.listen((state) {
          states.add(state);
        });

        // Emit a state
        stateStreamController.add(testState);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states.length, 1);
        expect(states.first.isHighwayModeActive, true);

        await subscription.cancel();
      });

      test('should handle stream cancellation gracefully', () async {
        final subscription = mockCubit.stream.listen((state) {});

        await subscription.cancel();

        // Emitting after cancel should not cause issues
        stateStreamController.add(testState);

        // No exception should be thrown
      });
    });
  });

  group('Highway mode state from cubit', () {
    test('should read isHighwayModeActive=true from cubit state', () {
      final highwayActiveState = NearestStationsState(
        stations: [],
        userLocation: testLocation,
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
        isHighwayModeActive: true,
      );
      when(mockCubit.state).thenReturn(highwayActiveState);

      // Verify we can read the highway mode state from the cubit
      expect(mockCubit.state.isHighwayModeActive, true);
    });

    test('should read isHighwayModeActive=false from cubit state', () {
      final highwayInactiveState = NearestStationsState(
        stations: [],
        userLocation: testLocation,
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
        isHighwayModeActive: false,
      );
      when(mockCubit.state).thenReturn(highwayInactiveState);

      expect(mockCubit.state.isHighwayModeActive, false);
    });

    test('should receive highway mode changes via stream', () async {
      final states = <NearestStationsState>[];

      final subscription = mockCubit.stream.listen((state) {
        states.add(state);
      });

      // Simulate highway mode activating (speed increased above threshold)
      final highwayActiveState = NearestStationsState(
        stations: [],
        userLocation: const UserLocation(
          latitude: 52.3676,
          longitude: 4.9041,
          accuracy: 10.0,
          speed: 80.0, // Above 50 km/h threshold
          heading: 90.0,
        ),
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
        isHighwayModeActive: true,
      );
      stateStreamController.add(highwayActiveState);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 1);
      expect(states.first.isHighwayModeActive, true);
      expect(states.first.userLocation?.speed, 80.0);

      // Simulate highway mode deactivating (speed dropped below threshold)
      final highwayInactiveState = NearestStationsState(
        stations: [],
        userLocation: const UserLocation(
          latitude: 52.3676,
          longitude: 4.9041,
          accuracy: 10.0,
          speed: 30.0, // Below 50 km/h threshold
          heading: 90.0,
        ),
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
        isHighwayModeActive: false,
      );
      stateStreamController.add(highwayInactiveState);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states.last.isHighwayModeActive, false);
      expect(states.last.userLocation?.speed, 30.0);

      await subscription.cancel();
    });

    test('should correctly identify highway mode state for native payload', () {
      // This tests the pattern used in _sendStationsToNative
      final highwayActiveState = NearestStationsState(
        stations: [],
        userLocation: testLocation,
        mode: NearestStationsMode.carScreen,
        flow: UIFlow.established(),
        isHighwayModeActive: true,
      );
      when(mockCubit.state).thenReturn(highwayActiveState);
      when(mockCubit.isClosed).thenReturn(false);

      // Simulate the check pattern from CarScreen._sendStationsToNative
      final cubit = mockCubit;
      final bool canSendToNative = !cubit.isClosed;
      final bool isHighwayActive = cubit.state.isHighwayModeActive;

      expect(canSendToNative, true);
      expect(isHighwayActive, true);
    });
  });
}
