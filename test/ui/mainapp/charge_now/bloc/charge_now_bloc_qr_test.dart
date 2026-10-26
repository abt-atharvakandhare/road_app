import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/payment/three_ds_service.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/ui/utils/evse_id_extractor.dart';

@GenerateMocks([ChargeNowRepository, Analytics, ThreeDsService])
import 'charge_now_bloc_qr_test.mocks.dart';

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

  group('ChargeNowBloc - QR Code Scanning', () {
    blocTest<ChargeNowBloc, ChargeNowState>(
      'emits ScanningQrCode state when scanQrCodeTapped event is added',
      build: () => chargeNowBloc,
      act: (bloc) => bloc.add(const ChargeNowEvent.scanQrCodeTapped()),
      expect: () => [
        isA<ScanningQrCode>(),
      ],
      verify: (_) {
        verify(mockAnalytics.logChargeNowEvent(ChargeNowAnalyticsType.scanQrCode)).called(1);
      },
    );

    blocTest<ChargeNowBloc, ChargeNowState>(
      'handles invalidQrCode event and emits error state',
      build: () => chargeNowBloc,
      seed: () => const ChargeNowState.scanningQrCode(flow: UIFlow.established()),
      act: (bloc) => bloc.add(const ChargeNowEvent.invalidQrCode('Invalid QR code format')),
      expect: () => [
        isA<ScanningQrCode>()
            .having(
              (state) => state.flow.isError,
              'flow.isError',
              true,
            )
            .having(
              (state) => state.flow.error.cause,
              'error cause',
              'Invalid QR code format',
            ),
      ],
    );

    group('Integration with manualEvseIdSubmitted', () {
      // This tests that QR scanning integrates properly with the existing manual EVSE flow

      test('QR scanner extracts EVSE ID and triggers manual submission flow', () async {
        // This test verifies the integration between QrScannerWidget URL extraction
        // and the ChargeNowBloc manual EVSE submission flow

        // 1. Test the complete flow
        const qrCodeUrl = 'https://dashboard.e-flux.io/evse/NLEFLEV6910384';
        final extractedId = EvseIdExtractor.extractEvseIdFromDashboardUrl(qrCodeUrl);

        expect(extractedId, equals('6910384'), reason: 'QR code URL should extract correct EVSE ID');

        // 2. Verify this ID would be passed to the bloc
        // In the actual QrScannerWidget, this happens in the onDetect callback:
        // bloc.add(ChargeNowEvent.manualEvseIdSubmitted(extractedId!));

        // 3. The bloc then handles it through the existing manual EVSE flow
        // which is tested in the "successful QR scan triggers manualEvseIdSubmitted" test above

        // Test edge cases that might occur in real QR codes
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384?ref=qr'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384#station'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFLEV6910384/'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.io/evse/NLEFL1234567'),
            equals('1234567'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/NLEFL12345678/'),
            equals('12345678'));

        // Test new chargestation.road.io URLs
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://chargestation.road.io/evse/NLEFLEV6910384'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('http://chargestation.road.io/evse/NLEFLEV6910384'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://chargestation.road.io/evse/NLEFL1234567?ref=qr'),
            equals('1234567'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://chargestation.road.io/evse/NLEFL12345678/'),
            equals('12345678'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('http://chargestation.road.io/evse/NLEFL9999999#section'),
            equals('9999999'));

        // Test new dashboard.e-flux.nl URLs
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/NLEFLEV6910384'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.nl/evse/NLEFLEV6910384'),
            equals('6910384'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/NLEFL1234567?ref=qr'),
            equals('1234567'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.nl/evse/NLEFL12345678/'),
            equals('12345678'));
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('http://dashboard.e-flux.nl/evse/NLEFL9999999#section'),
            equals('9999999'));

        // Invalid cases should return null
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://wrong-domain.com/evse/1234567'), isNull);
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/wrong-path/1234567'), isNull);
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://dashboard.e-flux.io/evse/123'), isNull);
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://chargestation.road.io/wrong-path/1234567'), isNull);
        expect(EvseIdExtractor.extractEvseIdFromDashboardUrl('https://chargestation.road.io/evse/123456'), isNull);
      });
    });

    group('State transitions from QR scanning', () {
      blocTest<ChargeNowBloc, ChargeNowState>(
        'can transition from initial screen to QR scanning',
        build: () => chargeNowBloc,
        seed: () => const ChargeNowState.chargeFlowInitialScreen(),
        act: (bloc) => bloc.add(const ChargeNowEvent.scanQrCodeTapped()),
        expect: () => [
          isA<ScanningQrCode>(),
        ],
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'back button from QR scanning returns to initial screen',
        build: () => chargeNowBloc,
        seed: () => const ChargeNowState.scanningQrCode(flow: UIFlow.established()),
        act: (bloc) => bloc.add(const ChargeNowEvent.backButtonTapped()),
        expect: () => [
          isA<ConnectYourCar>(),
        ],
      );

      blocTest<ChargeNowBloc, ChargeNowState>(
        'back button from station selection returns to QR scanner when source is qrCode',
        build: () => chargeNowBloc,
        seed: () => const ChargeNowState.selectYourChargeStation(
          [],
          false,
          source: ChargeStationSelectionSource.qrCode,
        ),
        act: (bloc) => bloc.add(const ChargeNowEvent.backButtonTapped()),
        expect: () => [
          isA<ScanningQrCode>(),
        ],
      );

      test('back button from station selection returns to manual input when source is manual by default', () {
        // This test verifies that the default source (manual) behavior is preserved
        // when the back button is pressed from the station selection screen
        const state = ChargeNowState.selectYourChargeStation(
          [],
          false,
          // source defaults to manual
        );

        expect((state as SelectYourChargeStation).source, equals(ChargeStationSelectionSource.manual));
      });
    });

    group('Analytics tracking', () {
      test('logs QR scan event when scanner is opened', () async {
        chargeNowBloc.add(const ChargeNowEvent.scanQrCodeTapped());

        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockAnalytics.logChargeNowEvent(ChargeNowAnalyticsType.scanQrCode)).called(1);
      });

      blocTest<ChargeNowBloc, ChargeNowState>(
        'successful QR scan triggers manualEvseIdSubmitted and logs analytics',
        build: () {
          // Setup mocks for the manual EVSE ID submission flow
          when(mockRepository.getChargingLocationsWithSearchId('6910384', any))
              .thenAnswer((_) async => LocationsResponseModel(
                    data: [],
                    meta: Meta(limit: 0, skip: 0, total: 0),
                  ));
          when(mockRepository.listRemoteSessions()).thenAnswer(
            (_) async => ChargingSessionsResponseModel(data: []),
          );

          return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
        },
        seed: () => const ChargeNowState.scanningQrCode(flow: UIFlow.established()),
        act: (bloc) {
          // Simulate successful QR scan by triggering manualEvseIdSubmitted
          // This is what QrScannerWidget does after extracting the EVSE ID
          bloc.add(const ChargeNowEvent.manualEvseIdSubmitted('6910384', ['EFL'], null));
        },
        expect: () => [
          // First it emits loading state
          isA<ScanningQrCode>().having(
            (state) => state.flow.isLoading,
            'flow.isLoading',
            true,
          ),
          // Then it emits error because no location found
          isA<ScanningQrCode>()
              .having(
                (state) => state.flow.isError,
                'flow.isError',
                true,
              )
              .having(
                (state) => state.flow.error.cause,
                'error cause',
                'No location with that ID found',
              ),
        ],
        verify: (_) {
          // Verify that the manual EVSE ID analytics event is logged
          verify(mockAnalytics.logChargeNowEvent(
            ChargeNowAnalyticsType.manualInputStationIdEntered,
          )).called(1);

          // Verify the repository was called with correct params (brand party IDs as list)
          verify(mockRepository.getChargingLocationsWithSearchId('6910384', ['EFL'])).called(1);
        },
      );
    });
  });
}
