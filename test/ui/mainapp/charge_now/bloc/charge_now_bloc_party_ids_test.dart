import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart'
    hide Location;
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/payment/three_ds_service.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';

@GenerateMocks([ChargeNowRepository, Analytics, ThreeDsService])
import 'charge_now_bloc_party_ids_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  late ChargeNowBloc chargeNowBloc;
  late MockChargeNowRepository mockRepository;
  late MockAnalytics mockAnalytics;
  late MockThreeDsService mockThreeDsService;

  setUp(() {
    mockRepository = MockChargeNowRepository();
    mockAnalytics = MockAnalytics();
    mockThreeDsService = MockThreeDsService();

    // Setup default mock responses for the automatic checkChargingStatus call
    when(mockRepository.listRemoteSessions()).thenAnswer(
      (_) async => ChargingSessionsResponseModel(data: []),
    );

    chargeNowBloc = ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
  });

  tearDown(() {
    chargeNowBloc.close();
  });

  group('ChargeNowBloc - PartyIds Filtering', () {
    final testLocation = UserLocation(
      latitude: 52.3676,
      longitude: 4.9041,
      accuracy: 10.0,
    );

    final testPartyIds = ['EFL', 'OPC', 'NXT'];

    StartChargingLocationMetadata createMockStation({
      required String locationId,
      required LatLng latLng,
      required String name,
    }) {
      return StartChargingLocationMetadata(
        locationId: locationId,
        evseId: 'evse-$locationId',
        evseUid: 'uid-$locationId',
        connectorId: 'conn-$locationId',
        latLng: latLng,
        name: name,
        address: '$name Address',
        status: ChargingPortAvailability.available,
        maxPower: 22.0,
        powerType: 'AC',
        tariffModel: null,
        userSpecialTariffs: null,
        supportsRemoteRfidCardCharging: true,
        supportsCreditCardCharging: true,
        capabilities: ['REMOTE_START_STOP_CAPABLE'],
      );
    }

    group('ReceivedLocation with partyIds', () {
      blocTest<ChargeNowBloc, ChargeNowState>(
        'should pass partyIds to getAvailableChargingLocations',
        build: () {
          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => []);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.receivedLocation(
          testLocation,
          testPartyIds,
        )),
        verify: (_) {
          verify(mockRepository.getAvailableChargingLocations(
            eventLocation: testLocation,
            partyIds: testPartyIds,
          )).called(1);
        },
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should emit location state when no stations found',
        build: () {
          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => []);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.receivedLocation(
          testLocation,
          testPartyIds,
        )),
        skip: 3, // Skip initial states from constructor's checkChargingStatus
        expect: () => [
          isA<Location>().having(
            (state) => state.evseLocations,
            'evseLocations',
            isEmpty,
          ),
        ],
        verify: (_) {
          verify(mockAnalytics.logChargeNowEvent(
            ChargeNowAnalyticsType.noNearbyStationFound,
          )).called(1);
        },
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should emit isThisYou state when station found',
        build: () {
          final mockStation = createMockStation(
            locationId: 'loc-1',
            latLng: const LatLng(52.3676, 4.9041),
            name: 'Test Station',
          );

          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => [mockStation]);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.receivedLocation(
          testLocation,
          testPartyIds,
        )),
        skip: 3, // Skip initial states from constructor's checkChargingStatus
        expect: () => [
          isA<IsThisYou>().having(
            (state) => state.evseLocation.locationId,
            'locationId',
            'loc-1',
          ),
        ],
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should handle empty partyIds list',
        build: () {
          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => []);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.receivedLocation(
          testLocation,
          [], // Empty partyIds
        )),
        verify: (_) {
          verify(mockRepository.getAvailableChargingLocations(
            eventLocation: testLocation,
            partyIds: [],
          )).called(1);
        },
      );

      // When location is null, the bloc does not emit a new state
      // (it returns early without emitting). This test verifies that behavior.
      blocTest<ChargeNowBloc, ChargeNowState>(
        'should not emit new state when location is null',
        build: () => ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true),
        act: (bloc) => bloc.add(const ChargeNowEvent.receivedLocation(
          null,
          ['EFL'],
        )),
        skip: 3, // Skip initial states from constructor's checkChargingStatus
        expect: () => [], // No new state emitted when location is null
      );
    });

    group('ShowMoreChargingStationsTapped with partyIds', () {
      blocTest<ChargeNowBloc, ChargeNowState>(
        'should pass partyIds to getAvailableChargingLocations when finding nearby stations',
        build: () {
          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => []);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.showMoreChargingStationsTapped(
          testLocation,
          true,
          testPartyIds,
        )),
        verify: (_) {
          verify(mockRepository.getAvailableChargingLocations(
            eventLocation: testLocation,
            partyIds: testPartyIds,
          )).called(1);
        },
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should emit selectYourChargeStation with stations sorted by distance',
        build: () {
          final nearStation = createMockStation(
            locationId: 'near-loc',
            latLng: const LatLng(52.3676, 4.9041), // Same as user
            name: 'Near Station',
          );

          final farStation = createMockStation(
            locationId: 'far-loc',
            latLng: const LatLng(52.4000, 4.9500), // Further away
            name: 'Far Station',
          );

          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => [farStation, nearStation]);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.showMoreChargingStationsTapped(
          testLocation,
          true,
          testPartyIds,
        )),
        skip: 3, // Skip initial states from constructor's checkChargingStatus
        expect: () => [
          isA<SelectYourChargeStation>()
              .having(
                (state) => state.evseLocations.length,
                'evseLocations length',
                2,
              )
              .having(
                (state) => state.evseLocations.first.locationId,
                'first station (nearest)',
                'near-loc',
              )
              .having(
                (state) => state.source,
                'source',
                ChargeStationSelectionSource.nearbySearch,
              ),
        ],
        verify: (_) {
          verify(mockAnalytics.logChargeNowEvent(
            ChargeNowAnalyticsType.findNearbyChargingStations,
          )).called(1);
        },
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should set searchLocation on each station for distance display',
        build: () {
          final station = createMockStation(
            locationId: 'loc-1',
            latLng: const LatLng(52.3676, 4.9041),
            name: 'Test Station',
          );

          when(mockRepository.getAvailableChargingLocations(
            eventLocation: anyNamed('eventLocation'),
            partyIds: anyNamed('partyIds'),
          )).thenAnswer((_) async => [station]);

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        act: (bloc) => bloc.add(ChargeNowEvent.showMoreChargingStationsTapped(
          testLocation,
          true,
          testPartyIds,
        )),
        skip: 3, // Skip initial states from constructor's checkChargingStatus
        expect: () => [
          isA<SelectYourChargeStation>().having(
            (state) => state.evseLocations.first.searchLocation,
            'searchLocation',
            LatLng(testLocation.latitude, testLocation.longitude),
          ),
        ],
      );
    });

    group('ManualEvseIdSubmitted with partyIds', () {
      blocTest<ChargeNowBloc, ChargeNowState>(
        'should pass partyIds to getChargingLocationsWithSearchId',
        build: () {
          when(mockRepository.getChargingLocationsWithSearchId(any, any))
              .thenAnswer((_) async => LocationsResponseModel(
                    data: [],
                    meta: Meta(limit: 0, skip: 0, total: 0),
                  ));

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        seed: () => const ChargeNowState.manualEvseIdInput(),
        act: (bloc) => bloc.add(ChargeNowEvent.manualEvseIdSubmitted(
          '1234567',
          testPartyIds,
          testLocation,
        )),
        verify: (_) {
          verify(mockRepository.getChargingLocationsWithSearchId(
            '1234567',
            testPartyIds,
          )).called(1);
        },
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should pass userLocation to create searchLocation on results',
        build: () {
          when(mockRepository.getChargingLocationsWithSearchId(any, any))
              .thenAnswer((_) async => LocationsResponseModel(
                    data: [],
                    meta: Meta(limit: 0, skip: 0, total: 0),
                  ));

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        seed: () => const ChargeNowState.manualEvseIdInput(),
        act: (bloc) => bloc.add(ChargeNowEvent.manualEvseIdSubmitted(
          '1234567',
          testPartyIds,
          testLocation, // User location provided
        )),
        expect: () => [
          // Loading state
          isA<ManualEvseIdInput>().having(
            (state) => state.flow.isLoading,
            'flow.isLoading',
            true,
          ),
          // Error state (no locations found)
          isA<ManualEvseIdInput>().having(
            (state) => state.flow.isError,
            'flow.isError',
            true,
          ),
        ],
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'should handle null userLocation',
        build: () {
          when(mockRepository.getChargingLocationsWithSearchId(any, any))
              .thenAnswer((_) async => LocationsResponseModel(
                    data: [],
                    meta: Meta(limit: 0, skip: 0, total: 0),
                  ));

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        seed: () => const ChargeNowState.manualEvseIdInput(),
        act: (bloc) => bloc.add(const ChargeNowEvent.manualEvseIdSubmitted(
          '1234567',
          ['EFL'],
          null, // No user location
        )),
        verify: (_) {
          verify(mockRepository.getChargingLocationsWithSearchId(
            '1234567',
            ['EFL'],
          )).called(1);
        },
      );
    });

    group('PartyIds from different sources', () {
      test('should support single party ID', () {
        const event = ChargeNowEvent.receivedLocation(null, ['EFL']);
        expect((event as ReceivedLocation).partyIds, equals(['EFL']));
      });

      test('should support multiple party IDs', () {
        const event =
            ChargeNowEvent.receivedLocation(null, ['EFL', 'OPC', 'NXT']);
        expect((event as ReceivedLocation).partyIds,
            equals(['EFL', 'OPC', 'NXT']));
      });

      test('showMoreChargingStationsTapped should include partyIds', () {
        const event = ChargeNowEvent.showMoreChargingStationsTapped(
          null,
          true,
          ['EFL', 'CUSTOM'],
        );
        expect((event as ShowMoreChargingStationsTapped).partyIds,
            equals(['EFL', 'CUSTOM']));
      });

      test('manualEvseIdSubmitted should include partyIds and userLocation',
          () {
        final location = UserLocation(
          latitude: 52.0,
          longitude: 4.0,
          accuracy: 10.0,
        );
        final event = ChargeNowEvent.manualEvseIdSubmitted(
          '123456',
          ['EFL'],
          location,
        );
        expect((event as ManualEvseIdSubmitted).partyIds, equals(['EFL']));
        expect(event.userLocation, equals(location));
      });
    });

    group('Repository integration', () {
      test(
          'ChargeNowRepository.getAvailableChargingLocations should accept partyIds',
          () {
        // This is a compile-time check that the repository method signature is correct
        when(mockRepository.getAvailableChargingLocations(
          eventLocation: argThat(isNotNull, named: 'eventLocation'),
          partyIds: argThat(isA<List<String>>(), named: 'partyIds'),
        )).thenAnswer((_) async => []);

        // Verify the method can be called with partyIds
        expect(
          () => mockRepository.getAvailableChargingLocations(
            eventLocation: testLocation,
            partyIds: ['EFL', 'OPC'],
          ),
          returnsNormally,
        );
      });

      test(
          'ChargeNowRepository.getChargingLocationsWithSearchId should accept partyIds',
          () {
        when(mockRepository.getChargingLocationsWithSearchId(any, any))
            .thenAnswer((_) async => LocationsResponseModel(
                  data: [],
                  meta: Meta(limit: 0, skip: 0, total: 0),
                ));

        expect(
          () => mockRepository.getChargingLocationsWithSearchId(
            '123456',
            ['EFL', 'OPC'],
          ),
          returnsNormally,
        );
      });
    });
  });
}
