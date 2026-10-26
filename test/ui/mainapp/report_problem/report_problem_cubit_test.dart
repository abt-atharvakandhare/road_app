import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_category.dart';
import 'package:road_mobile/data/model/issue_reports/issue_report_request.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart';
import 'package:road_mobile/ui/mainapp/report_problem/cubit/report_problem_cubit.dart';
import 'package:road_mobile/ui/mainapp/report_problem/data/report_problem_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

@GenerateMocks([ReportProblemRepository, ChargeNowRepository])
import 'report_problem_cubit_test.mocks.dart';

void main() {
  late MockReportProblemRepository mockReportRepository;
  late MockChargeNowRepository mockChargeNowRepository;

  const locationId = 'loc-1';
  const evseUid = 'evse-uid-1';
  const evseDisplayId = 'NL*EFL*12345678';

  final connectorA = Connector(id: '1', standard: 'IEC_62196_T2');
  final connectorB = Connector(id: '2', standard: 'IEC_62196_T2');

  final evseSingleConnector = Evse(
    uid: evseUid,
    evseId: evseDisplayId,
    connectors: [connectorA],
  );

  final evseMultiConnector = Evse(
    uid: evseUid,
    evseId: evseDisplayId,
    connectors: [connectorA, connectorB],
  );

  MapLocationsResponseModel responseFor(List<Evse> evses) => MapLocationsResponseModel(
        data: [
          MapLocationV2(
            id: locationId,
            address: '123 Test Street',
            evses: evses,
          ),
        ],
      );

  setUp(() {
    mockReportRepository = MockReportProblemRepository();
    mockChargeNowRepository = MockChargeNowRepository();

    when(mockReportRepository.fetchCategories()).thenAnswer(
      (_) async => (known: IssueReportCategory.values, unknown: const <String>[]),
    );
    when(mockReportRepository.submitReport(any)).thenAnswer((_) async {});
  });

  group('initialize', () {
    blocTest<ReportProblemCubit, ReportProblemState>(
      'auto-selects the only connector when EVSE has just one',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) => cubit.initialize(
        locationId: locationId,
        evseUid: evseUid,
      ),
      verify: (cubit) {
        expect(cubit.state.selectedEvseUid, evseUid);
        expect(cubit.state.selectedConnectorId, '1');
        expect(cubit.connectorOptions, hasLength(1));
        expect(cubit.state.headerDisplayId, evseDisplayId);
        expect(cubit.state.flow, isA<UIFlowEstablished>());
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'leaves connector unselected when EVSE has multiple connectors',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseMultiConnector]));
      },
      act: (cubit) => cubit.initialize(locationId: locationId, evseUid: evseUid),
      verify: (cubit) {
        expect(cubit.connectorOptions, hasLength(2));
        expect(cubit.state.selectedConnectorId, isNull);
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'aggregates connectors across all EVSEs when no specific EVSE is given',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        final secondEvse = Evse(
          uid: 'evse-uid-2',
          evseId: 'NL*EFL*99999999',
          connectors: [Connector(id: '1', standard: 'CHADEMO')],
        );
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseMultiConnector, secondEvse]));
      },
      act: (cubit) => cubit.initialize(locationId: locationId),
      verify: (cubit) {
        expect(cubit.connectorOptions, hasLength(3));
        // Connectors from both EVSEs are present.
        expect(cubit.connectorOptions.map((o) => o.evseUid).toSet(), {evseUid, 'evse-uid-2'});
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'resolves evseUid from evseDisplayId when only display id is provided',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) => cubit.initialize(
        locationId: locationId,
        evseDisplayId: evseDisplayId,
      ),
      verify: (cubit) {
        expect(cubit.state.selectedEvseUid, evseUid);
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'falls back to default category list when fetchCategories errors',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockReportRepository.fetchCategories())
            .thenAnswer((_) => Future.error(RMApiError(cause: 'boom')));
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) => cubit.initialize(locationId: locationId, evseUid: evseUid),
      verify: (cubit) {
        expect(cubit.state.categories, IssueReportCategory.values);
        expect(cubit.state.flow, isA<UIFlowEstablished>());
      },
    );
  });

  group('canSubmit', () {
    test('false when no category is selected', () {
      final cubit = ReportProblemCubit(mockReportRepository, mockChargeNowRepository);
      expect(cubit.canSubmit, isFalse);
    });

    test('false for "other" without a description', () {
      final cubit = ReportProblemCubit(mockReportRepository, mockChargeNowRepository);
      cubit.selectCategory(IssueReportCategory.other);
      expect(cubit.canSubmit, isFalse);
    });

    test('true for "other" with a non-empty description', () {
      final cubit = ReportProblemCubit(mockReportRepository, mockChargeNowRepository);
      cubit.selectCategory(IssueReportCategory.other);
      cubit.updateDescription('Door is jammed');
      expect(cubit.canSubmit, isTrue);
    });

    test('true for known categories without description', () {
      final cubit = ReportProblemCubit(mockReportRepository, mockChargeNowRepository);
      cubit.selectCategory(IssueReportCategory.chargerNotAvailable);
      expect(cubit.canSubmit, isTrue);
    });
  });

  group('submit', () {
    blocTest<ReportProblemCubit, ReportProblemState>(
      'POSTs report and emits submitted=true on success',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) async {
        await cubit.initialize(locationId: locationId, evseUid: evseUid);
        cubit.selectCategory(IssueReportCategory.chargerNotAvailable);
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.submitted, isTrue);
        expect(cubit.state.flow, isA<UIFlowEstablished>());
        final captured = verify(mockReportRepository.submitReport(captureAny)).captured.single
            as IssueReportRequest;
        expect(captured.locationId, locationId);
        expect(captured.evseUid, evseUid);
        expect(captured.connectorId, '1');
        expect(captured.category, 'charger_not_available');
        expect(captured.description, isNull);
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'emits UIFlow.error when the repository fails',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
        when(mockReportRepository.submitReport(any))
            .thenAnswer((_) => Future.error(RMApiError(cause: 'server down')));
      },
      act: (cubit) async {
        await cubit.initialize(locationId: locationId, evseUid: evseUid);
        cubit.selectCategory(IssueReportCategory.chargerNotAvailable);
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.submitted, isFalse);
        expect(cubit.state.flow, isA<UIFlowError>());
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'no-ops when canSubmit is false',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      act: (cubit) async {
        await cubit.submit();
      },
      verify: (_) {
        verifyNever(mockReportRepository.submitReport(any));
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'sends raw category id when an unknown category is selected',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) async {
        await cubit.initialize(locationId: locationId, evseUid: evseUid);
        cubit.selectUnknownCategory('future_category_added_by_be');
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.submitted, isTrue);
        final captured = verify(mockReportRepository.submitReport(captureAny)).captured.single
            as IssueReportRequest;
        expect(captured.category, 'future_category_added_by_be');
      },
    );

    blocTest<ReportProblemCubit, ReportProblemState>(
      'resolves and submits evseUid when only evseDisplayId was provided',
      build: () => ReportProblemCubit(mockReportRepository, mockChargeNowRepository),
      setUp: () {
        when(mockChargeNowRepository.getChargingLocationsDetails([locationId]))
            .thenAnswer((_) async => responseFor([evseSingleConnector]));
      },
      act: (cubit) async {
        await cubit.initialize(locationId: locationId, evseDisplayId: evseDisplayId);
        cubit.selectCategory(IssueReportCategory.chargerNotAvailable);
        await cubit.submit();
      },
      verify: (cubit) {
        final captured = verify(mockReportRepository.submitReport(captureAny)).captured.single
            as IssueReportRequest;
        expect(captured.evseUid, evseUid);
        expect(captured.connectorId, '1');
      },
    );
  });
}
