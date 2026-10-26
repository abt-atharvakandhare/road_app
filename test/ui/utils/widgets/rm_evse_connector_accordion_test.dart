import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_evse_connector_accordion.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

RMEvseConnectorAccordion buildAccordion({
  required String infraProviderId,
  required List<String> capabilities,
}) {
  final connector = Connector(standard: 'IEC_62196_T2', powerType: 'AC_3_PHASE');
  final evse = Evse(
    evseId: 'NL*TST*E123456',
    uid: 'evse-uid-1',
    status: 'AVAILABLE',
    capabilities: capabilities,
    connectors: [connector],
  );
  final location = MapLocationV2(
    id: 'location-1',
    evses: [evse],
    infraProviderId: infraProviderId,
  );

  return RMEvseConnectorAccordion(
    evse: evse,
    connector: connector,
    location: location,
    tariffModel: null,
    specialTariffModels: const [],
    showChargeNow: false,
    onChargeNowPressed: null,
  );
}

Future<void> pumpExpandedAccordion(
  WidgetTester tester, {
  required String infraProviderId,
  required List<String> capabilities,
}) async {
  await tester.pumpWidget(
    buildTestWidget(
      buildAccordion(infraProviderId: infraProviderId, capabilities: capabilities),
    ),
  );
  await tester.tap(find.byType(InkWell));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  group('RMEvseConnectorAccordion payment options', () {
    group('roaming (non-E-Flux) locations', () {
      testWidgets('hides charging card/tag row without RFID_READER', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'roaming-provider',
          capabilities: [],
        );

        expect(find.text('Charging Card or Tag'), findsNothing);
        expect(find.text('Payment methods'), findsNothing);
      });

      testWidgets('shows charging card/tag row with RFID_READER', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'roaming-provider',
          capabilities: ['RFID_READER'],
        );

        expect(find.text('Charging Card or Tag'), findsOneWidget);
      });

      testWidgets('never shows direct payments row', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'roaming-provider',
          capabilities: ['RFID_READER', 'REMOTE_START_STOP_CAPABLE'],
        );

        expect(find.text('Direct Payments'), findsNothing);
      });
    });

    group('E-Flux locations', () {
      testWidgets('hides charging card/tag row without RFID_READER', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'provider-EFL',
          capabilities: [],
        );

        expect(find.text('Charging Card or Tag'), findsNothing);
      });

      testWidgets('shows charging card/tag row with RFID_READER', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'provider-EFL',
          capabilities: ['RFID_READER'],
        );

        expect(find.text('Charging Card or Tag'), findsOneWidget);
      });

      testWidgets('shows direct payments row with REMOTE_START_STOP_CAPABLE', (tester) async {
        await pumpExpandedAccordion(
          tester,
          infraProviderId: 'provider-EFL',
          capabilities: ['REMOTE_START_STOP_CAPABLE'],
        );

        expect(find.text('Direct Payments'), findsOneWidget);
        expect(find.text('Charging Card or Tag'), findsNothing);
      });
    });
  });
}
