import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:road_mobile/data/model/cards/unified_payment_cards.dart';
import 'package:road_mobile/data/model/charging/charging_sessions_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/payment/three_ds_service.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';

@GenerateMocks([ChargeNowRepository, Analytics, ThreeDsService])
import 'charge_now_bloc_cancel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  late MockChargeNowRepository mockRepository;
  late MockAnalytics mockAnalytics;
  late MockThreeDsService mockThreeDsService;

  final testSession = ChargingSessionModel(
    'session-1',
    null,
    'loc-1',
    'STARTING',
    DateTime.utc(2026, 1, 1),
    null,
    null,
    null,
    null,
    null,
  );

  setUp(() {
    mockRepository = MockChargeNowRepository();
    mockAnalytics = MockAnalytics();
    mockThreeDsService = MockThreeDsService();

    when(mockRepository.getMyPaymentCards(any, any)).thenAnswer(
      (_) async => UnifiedPaymentCards(rfidCards: null, creditCards: null),
    );
  });

  group('ChargeNowBloc - cancel during starting (DRI-672)', () {
    blocTest<ChargeNowBloc, ChargeNowState>(
      'silent reset to initial screen when cancel succeeds',
      build: () {
        // The bloc's constructor fires checkChargingStatus immediately. To
        // preserve the seeded ChargeSessionStarting state for that first call,
        // return the matching active session; on subsequent calls (post-cancel)
        // return empty to simulate the cancelled session being gone.
        var listCallCount = 0;
        when(mockRepository.listRemoteSessions()).thenAnswer((_) async {
          listCallCount++;
          return listCallCount == 1
              ? ChargingSessionsResponseModel(data: [testSession])
              : ChargingSessionsResponseModel(data: []);
        });
        when(mockRepository.cancelRemoteSession('session-1')).thenAnswer((_) async => true);
        return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
      },
      seed: () => ChargeNowState.chargeSessionStarting(testSession, null, DateTime.utc(2026, 1, 1)),
      act: (bloc) => bloc.add(ChargeNowEvent.cancelStartCharge(testSession)),
      // _cancelCharging awaits Future.delayed(3s) before triggering the status
      // check; STARTING also schedules a 2s polling timer. 5s covers both.
      wait: const Duration(seconds: 5),
      // Other intermediate states are emitted (loading flag, polling timer
      // re-emissions). The contract under test is: we eventually reach the
      // initial screen with NO error flow after a successful cancel.
      expect: () => containsAllInOrder([
        isA<ConnectYourCar>().having((s) => s.flow.isError, 'flow.isError', false),
      ]),
      verify: (_) {
        verify(mockRepository.cancelRemoteSession('session-1')).called(1);
        // A successful cancel must NOT be logged as a start failure.
        verifyNever(mockAnalytics.logChargeNowEvent(
          ChargeNowAnalyticsType.chargeSessionStartFailed,
          sessionId: anyNamed('sessionId'),
          locationId: anyNamed('locationId'),
          paymentType: anyNamed('paymentType'),
          evseUid: anyNamed('evseUid'),
          connectorId: anyNamed('connectorId'),
          message: anyNamed('message'),
        ));
      },
    );

    blocTest<ChargeNowBloc, ChargeNowState>(
      'shows start-charging error when no session is found without a prior cancel',
      build: () {
        // No prior cancel — listRemoteSessions returns empty, so the
        // constructor-fired status check sees no session against the seeded
        // ChargeSessionStarting state and treats it as a genuine start failure.
        when(mockRepository.listRemoteSessions()).thenAnswer(
          (_) async => ChargingSessionsResponseModel(data: []),
        );
        return ChargeNowBloc(mockRepository, mockAnalytics, mockThreeDsService, isInitiallyLoggedIn: true);
      },
      seed: () => ChargeNowState.chargeSessionStarting(testSession, null, DateTime.utc(2026, 1, 1)),
      // Constructor's checkChargingStatus drives the assertion; no extra act needed.
      expect: () => containsAllInOrder([
        isA<ConnectYourCar>().having((s) => s.flow.isError, 'flow.isError', true),
      ]),
      verify: (_) {
        verifyNever(mockRepository.cancelRemoteSession(any));
        verify(mockAnalytics.logChargeNowEvent(
          ChargeNowAnalyticsType.chargeSessionStartFailed,
          sessionId: anyNamed('sessionId'),
          locationId: anyNamed('locationId'),
          paymentType: anyNamed('paymentType'),
          evseUid: anyNamed('evseUid'),
          connectorId: anyNamed('connectorId'),
          message: anyNamed('message'),
        )).called(1);
      },
    );
  });
}
