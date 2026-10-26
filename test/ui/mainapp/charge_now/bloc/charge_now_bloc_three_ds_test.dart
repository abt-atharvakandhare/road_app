import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/cards/preauth_limits_model.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/cards/charging_authorizations_model.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/data/model/charging/start_remote_session_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/payment/three_ds_service.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';

@GenerateMocks([ChargeNowRepository, Analytics, ThreeDsService])
import 'charge_now_bloc_three_ds_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  late MockChargeNowRepository mockRepository;
  late MockAnalytics mockAnalytics;
  late MockThreeDsService mockThreeDsService;

  final testMetadata = StartChargingLocationMetadata(
    locationId: 'loc-1',
    evseId: 'evse-1',
    evseUid: 'uid-1',
    connectorId: 'conn-1',
    latLng: const LatLng(52.0, 4.0),
    name: 'Test Station',
    address: 'Test Address',
    status: ChargingPortAvailability.available,
    maxPower: 22.0,
    powerType: 'AC',
    tariffModel: null,
    userSpecialTariffs: null,
    supportsRemoteRfidCardCharging: true,
    supportsCreditCardCharging: true,
    capabilities: ['REMOTE_START_STOP_CAPABLE'],
  );

  final testPreauthLimits = PreauthLimitsModel(
    currency: 'EUR',
    defaultAmount: 25,
  );

  final testCreditCard = UnifiedPaymentCard(
    paymentCard: PaymentInstrumentModel(
      id: 'pi-123',
      psp: 'checkout',
      pspReference: 'ref-123',
      status: 'active',
      tokenId: 'tok-123',
      type: 'card',
    ),
  );

  final testUnifiedCards = UnifiedPaymentCards(
    rfidCards: null,
    creditCards: [testCreditCard.paymentCard!],
  );

  setUp(() {
    mockRepository = MockChargeNowRepository();
    mockAnalytics = MockAnalytics();
    mockThreeDsService = MockThreeDsService();

    when(mockRepository.listRemoteSessions()).thenAnswer(
      (_) async => ChargingSessionsResponseModel(data: []),
    );
  });

  group('ChargeNowBloc - 3DS during charging', () {
    blocTest<ChargeNowBloc, ChargeNowState>(
      'proceeds to checkChargingStatus when no 3DS required',
      build: () {
        when(mockRepository.startRemoteSession(params: anyNamed('params')))
            .thenAnswer((_) async => StartRemoteSessionResponseModel(
                  StartRemoteSessionDataModel('session-1', 'PENDING'),
                  null,
                ));
        return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
      },
      seed: () => ChargeNowState.startChargingSession(
        testMetadata,
        testUnifiedCards,
        testCreditCard,
        testPreauthLimits,
      ),
      act: (bloc) => bloc.add(ChargeNowEvent.startCharging(
        testMetadata,
        testCreditCard,
        testPreauthLimits,
      )),
      verify: (_) {
        verifyNever(mockThreeDsService.performThreeDs(any));
        verify(mockRepository.listRemoteSessions()).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<ChargeNowBloc, ChargeNowState>(
      'triggers 3DS and proceeds when 3DS errors (webhook-driven)',
      build: () {
        when(mockRepository.startRemoteSession(params: anyNamed('params')))
            .thenAnswer((_) async => StartRemoteSessionResponseModel(
                  StartRemoteSessionDataModel('session-1', 'PENDING'),
                  StartRemoteSessionAction(
                    'redirect',
                    StartRemoteSessionActionValue('https://example.com/3ds'),
                  ),
                ));
        when(mockThreeDsService.performThreeDs('https://example.com/3ds'))
            .thenAnswer((_) async => ThreeDsOutcome(ThreeDsResult.error, null));
        return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
      },
      seed: () => ChargeNowState.startChargingSession(
        testMetadata,
        testUnifiedCards,
        testCreditCard,
        testPreauthLimits,
      ),
      act: (bloc) => bloc.add(ChargeNowEvent.startCharging(
        testMetadata,
        testCreditCard,
        testPreauthLimits,
      )),
      verify: (_) {
        verify(mockThreeDsService.performThreeDs('https://example.com/3ds')).called(1);
        // Should still proceed to check charging status (webhooks handle it)
        verify(mockRepository.listRemoteSessions()).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<ChargeNowBloc, ChargeNowState>(
      'returns to established state when user cancels 3DS',
      build: () {
        when(mockRepository.startRemoteSession(params: anyNamed('params')))
            .thenAnswer((_) async => StartRemoteSessionResponseModel(
                  StartRemoteSessionDataModel('session-1', 'PENDING'),
                  StartRemoteSessionAction(
                    'redirect',
                    StartRemoteSessionActionValue('https://example.com/3ds'),
                  ),
                ));
        when(mockThreeDsService.performThreeDs('https://example.com/3ds'))
            .thenAnswer((_) async => ThreeDsOutcome(ThreeDsResult.cancelled, null));
        return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
      },
      seed: () => ChargeNowState.startChargingSession(
        testMetadata,
        testUnifiedCards,
        testCreditCard,
        testPreauthLimits,
      ),
      act: (bloc) => bloc.add(ChargeNowEvent.startCharging(
        testMetadata,
        testCreditCard,
        testPreauthLimits,
      )),
      expect: () => [
        // Loading state
        isA<StartChargingSession>().having(
          (state) => state.flow.isLoading,
          'flow.isLoading',
          true,
        ),
        // Returns to established (cancelled)
        isA<StartChargingSession>().having(
          (state) => state.flow,
          'flow',
          const UIFlow.established(),
        ),
      ],
      verify: (_) {
        verify(mockThreeDsService.performThreeDs('https://example.com/3ds')).called(1);
      },
    );
  });

  group('StartRemoteSessionResponseModel', () {
    test('requiresThreeDs returns true for redirect action with url', () {
      final model = StartRemoteSessionResponseModel(
        StartRemoteSessionDataModel('id', 'PENDING'),
        StartRemoteSessionAction(
          'redirect',
          StartRemoteSessionActionValue('https://example.com/3ds'),
        ),
      );
      expect(model.requiresThreeDs, true);
      expect(model.threeDsRedirectUrl, 'https://example.com/3ds');
    });

    test('requiresThreeDs returns false when action is null', () {
      final model = StartRemoteSessionResponseModel(
        StartRemoteSessionDataModel('id', 'PENDING'),
        null,
      );
      expect(model.requiresThreeDs, false);
      expect(model.threeDsRedirectUrl, isNull);
    });

    test('requiresThreeDs returns false for non-redirect action', () {
      final model = StartRemoteSessionResponseModel(
        StartRemoteSessionDataModel('id', 'PENDING'),
        StartRemoteSessionAction('other', StartRemoteSessionActionValue('https://example.com')),
      );
      expect(model.requiresThreeDs, false);
    });

    test('requiresThreeDs returns false when redirect url is null', () {
      final model = StartRemoteSessionResponseModel(
        StartRemoteSessionDataModel('id', 'PENDING'),
        StartRemoteSessionAction('redirect', StartRemoteSessionActionValue(null)),
      );
      expect(model.requiresThreeDs, false);
    });

    test('parses from JSON correctly', () {
      final json = {
        'data': {'id': 'test-id', 'status': 'PENDING'},
        'action': {
          'case': 'redirect',
          'value': {'url': 'https://example.com/3ds'},
        },
      };
      final model = StartRemoteSessionResponseModel.fromJson(json);
      expect(model.data.id, 'test-id');
      expect(model.requiresThreeDs, true);
      expect(model.threeDsRedirectUrl, 'https://example.com/3ds');
    });

    test('parses from JSON without action', () {
      final json = {
        'data': {'id': 'test-id', 'status': 'ACTIVE'},
      };
      final model = StartRemoteSessionResponseModel.fromJson(json);
      expect(model.data.id, 'test-id');
      expect(model.requiresThreeDs, false);
    });
  });
}
