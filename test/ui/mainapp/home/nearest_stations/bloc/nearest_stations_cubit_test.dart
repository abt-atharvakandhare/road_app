import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart'
    show Evse, MapLocationV2, MapLocationsResponseModel;
import 'package:road_mobile/data/model/locations/locations_response_model.dart' show GeoLocation;
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_repository.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';

@GenerateMocks([NearestStationsRepository, LocationBloc])
import 'nearest_stations_cubit_test.mocks.dart';

void main() {
  late MockNearestStationsRepository mockRepository;
  late MockLocationBloc mockLocationBloc;
  late StreamController<LocationState> locationStreamController;

  // Test data constants
  const highwaySpeedThreshold = 50.0; // km/h

  // Test locations
  final lowSpeedLocation = const UserLocation(
    latitude: 52.3676,
    longitude: 4.9041,
    accuracy: 10.0,
    speed: 30.0, // Below threshold
    heading: 90.0,
  );

  final highSpeedLocation = const UserLocation(
    latitude: 52.3676,
    longitude: 4.9041,
    accuracy: 10.0,
    speed: 80.0, // Above threshold
    heading: 90.0,
  );

  final exactThresholdLocation = const UserLocation(
    latitude: 52.3676,
    longitude: 4.9041,
    accuracy: 10.0,
    speed: highwaySpeedThreshold, // Exactly at threshold
    heading: 90.0,
  );

  // Location far enough away to trigger fetch (>150m)
  final farLocation = const UserLocation(
    latitude: 52.3700, // ~270m north
    longitude: 4.9041,
    accuracy: 10.0,
    speed: 80.0,
    heading: 90.0,
  );

  // Test station data
  final testEvse = Evse(
    evseId: 'EVSE001',
    status: 'AVAILABLE',
    maxPower: 50.0,
    connectors: [],
  );

  final testLocation = MapLocationV2(
    id: 'LOC001',
    name: 'Test Charging Station',
    address: '123 Test Street',
    evses: [testEvse],
    geoLocation: GeoLocation(coordinates: [4.9041, 52.3676]),
  );

  final mockResponse = MapLocationsResponseModel(data: [testLocation]);
  // ignore: unused_local_variable
  final emptyResponse = MapLocationsResponseModel(data: []);

  setUpAll(() {
    // Provide dummy values for sealed classes that mockito can't generate
    provideDummy<LocationState>(const LocationState.initial());
  });

  setUp(() {
    mockRepository = MockNearestStationsRepository();
    mockLocationBloc = MockLocationBloc();
    locationStreamController = StreamController<LocationState>.broadcast();

    // Default mock setup
    when(mockLocationBloc.stream).thenAnswer((_) => locationStreamController.stream);
    when(mockLocationBloc.state).thenReturn(const LocationState.initial());

    when(mockRepository.getNearestChargingLocations(
      location: anyNamed('location'),
      filterConfig: anyNamed('filterConfig'),
      limit: anyNamed('limit'),
    )).thenAnswer((_) async => mockResponse);
  });

  tearDown(() {
    locationStreamController.close();
  });

  group('NearestStationsCubit', () {
    group('initialization', () {
      test('should initialize with correct default state for carScreen mode', () {
        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(mode: NearestStationsMode.carScreen),
        );

        expect(cubit.state.stations, isEmpty);
        expect(cubit.state.mode, NearestStationsMode.carScreen);
        expect(cubit.state.isHighwayModeActive, false);
        expect(cubit.highwayMode, HighwayMode.auto);

        cubit.close();
      });

      test('should initialize with correct default state for highway mode', () {
        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(mode: NearestStationsMode.highway),
        );

        expect(cubit.state.stations, isEmpty);
        expect(cubit.state.mode, NearestStationsMode.highway);

        cubit.close();
      });

      test('should use config values', () {
        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(
            mode: NearestStationsMode.carScreen,
            stationLimit: 15,
            highwayMode: HighwayMode.off,
          ),
        );

        expect(cubit.highwayMode, HighwayMode.off);

        cubit.close();
      });
    });

    group('carScreen mode - hybrid behavior', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should set isHighwayModeActive=false when speed < 50 km/h and auto is ON',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: lowSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          // Wait for the initial fetch triggered by constructor
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isHighwayModeActive, false);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should set isHighwayModeActive=true when speed >= 50 km/h and auto is ON',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isHighwayModeActive, true);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should set isHighwayModeActive=true when speed is exactly 50 km/h',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: exactThresholdLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isHighwayModeActive, true);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should set isHighwayModeActive=false when auto is OFF regardless of speed',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(
              mode: NearestStationsMode.carScreen,
              highwayMode: HighwayMode.off,
            ),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isHighwayModeActive, false);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should set isHighwayModeActive=true when HighwayMode.on even at low speed',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: lowSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(
              mode: NearestStationsMode.carScreen,
              highwayMode: HighwayMode.on,
            ),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isHighwayModeActive, true);
          // Should apply highway filters even at low speed
          final captured = verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: captureAnyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).captured;

          final filterConfig = captured.last as NearestStationsFilterConfig;
          expect(filterConfig.minPowerKw, 50);
          expect(filterConfig.availableOnly, true);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should use highway filters (50kW, heading) when highway mode is active',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          final captured = verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: captureAnyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).captured;

          final filterConfig = captured.last as NearestStationsFilterConfig;
          expect(filterConfig.minPowerKw, 50);
          expect(filterConfig.availableOnly, true);
          expect(filterConfig.heading, highSpeedLocation.heading);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should use nearest filters (no power filter) when highway mode is inactive',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: lowSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          final captured = verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: captureAnyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).captured;

          final filterConfig = captured.last as NearestStationsFilterConfig;
          expect(filterConfig.minPowerKw, isNull);
          expect(filterConfig.availableOnly, false);
        },
      );
    });

    group('setHighwayAutoEnabled', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should trigger re-fetch when toggling highway auto off',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
          clearInteractions(mockRepository);
          cubit.setHighwayMode(HighwayMode.off);
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.highwayMode, HighwayMode.off);
          // Should have called repository again after toggle
          verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).called(greaterThanOrEqualTo(1));
        },
      );

      test('should ignore setHighwayMode in non-carScreen mode', () {
        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(mode: NearestStationsMode.highway),
        );

        cubit.setHighwayMode(HighwayMode.off);

        // In highway mode, this should be ignored
        // (the cubit logs and returns without changing state)
        cubit.close();
      });
    });

    group('highway mode', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should emit isLowSpeed=true when speed < 50 km/h',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: lowSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.highway),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isLowSpeed, true);
          expect(cubit.state.stations, isEmpty);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should fetch stations when speed >= 50 km/h',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.highway),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.isLowSpeed, false);
          verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).called(1);
        },
      );
    });

    group('nearest mode', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should always fetch stations regardless of speed',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: lowSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.nearest),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).called(1);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should not apply power filter or heading in nearest mode',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.nearest),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          final captured = verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: captureAnyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).captured;

          final filterConfig = captured.last as NearestStationsFilterConfig;
          expect(filterConfig.minPowerKw, isNull);
          expect(filterConfig.heading, isNull);
        },
      );
    });

    group('location threshold', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should skip fetch if distance moved < 150m',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          // First fetch happens on init
          await Future.delayed(const Duration(milliseconds: 100));
          clearInteractions(mockRepository);

          // Emit location that's very close (same coordinates)
          locationStreamController.add(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          // Should not have fetched again since location is the same
          verifyNever(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          ));
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should fetch if distance moved >= 150m',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen, minUpdateIntervalSeconds: 0),
          );
        },
        act: (cubit) async {
          // First fetch happens on init
          await Future.delayed(const Duration(milliseconds: 100));
          clearInteractions(mockRepository);

          // Emit location that's far enough away
          locationStreamController.add(
            LocationState.locationProvided(userLocation: farLocation),
          );
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (_) {
          // Should have fetched since location moved enough
          verify(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).called(1);
        },
      );
    });

    group('cubit lifecycle', () {
      test('should not emit after close() is called', () async {
        when(mockLocationBloc.state).thenReturn(const LocationState.initial());

        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(mode: NearestStationsMode.carScreen),
        );

        await cubit.close();

        expect(cubit.isClosed, true);
      });

      test('should cancel location subscription on close', () async {
        final cubit = NearestStationsCubit(
          mockRepository,
          mockLocationBloc,
          NearestStationsConfig(mode: NearestStationsMode.carScreen),
        );

        await cubit.close();

        // After close, emitting to the location stream should not cause issues
        locationStreamController.add(
          LocationState.locationProvided(userLocation: highSpeedLocation),
        );

        // No exception should be thrown
      });
    });

    group('error handling', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should emit error state when repository throws',
        build: () {
          when(mockLocationBloc.state).thenReturn(
            LocationState.locationProvided(userLocation: highSpeedLocation),
          );
          when(mockRepository.getNearestChargingLocations(
            location: anyNamed('location'),
            filterConfig: anyNamed('filterConfig'),
            limit: anyNamed('limit'),
          )).thenThrow(Exception('Network error'));

          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.flow.isError, true);
        },
      );
    });

    group('location state handling', () {
      blocTest<NearestStationsCubit, NearestStationsState>(
        'should emit error when location service is disabled',
        build: () {
          when(mockLocationBloc.state).thenReturn(const LocationState.initial());
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          locationStreamController.add(const LocationState.serviceDisabled());
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.flow.isError, true);
        },
      );

      blocTest<NearestStationsCubit, NearestStationsState>(
        'should emit error when location permission is denied',
        build: () {
          when(mockLocationBloc.state).thenReturn(const LocationState.initial());
          return NearestStationsCubit(
            mockRepository,
            mockLocationBloc,
            NearestStationsConfig(mode: NearestStationsMode.carScreen),
          );
        },
        act: (cubit) async {
          locationStreamController.add(const LocationState.shouldDirectToSettings());
          await Future.delayed(const Duration(milliseconds: 100));
        },
        verify: (cubit) {
          expect(cubit.state.flow.isError, true);
        },
      );
    });
  });
}
