import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_capabilities_widget.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  group('RMCapabilitiesWidget', () {
    group('roaming (non-E-Flux) locations', () {
      testWidgets('hides charging card/tag row without RFID_READER', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: [],
              isEflux: false,
            ),
          ),
        );

        expect(find.text('Charging Card or Tag'), findsNothing);
        expect(find.text('Payment methods'), findsNothing);
      });

      testWidgets('shows charging card/tag row with RFID_READER', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: ['RFID_READER'],
              isEflux: false,
            ),
          ),
        );

        expect(find.text('Charging Card or Tag'), findsOneWidget);
        expect(find.text('Payment methods'), findsOneWidget);
      });

      testWidgets('never shows direct payments row', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: ['RFID_READER', 'REMOTE_START_STOP_CAPABLE'],
              isEflux: false,
            ),
          ),
        );

        expect(find.text('Direct Payments'), findsNothing);
      });
    });

    group('E-Flux locations', () {
      testWidgets('hides charging card/tag row without RFID_READER', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: [],
              isEflux: true,
            ),
          ),
        );

        expect(find.text('Charging Card or Tag'), findsNothing);
        expect(find.text('Payment methods'), findsNothing);
      });

      testWidgets('shows charging card/tag row with RFID_READER', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: ['RFID_READER'],
              isEflux: true,
            ),
          ),
        );

        expect(find.text('Charging Card or Tag'), findsOneWidget);
      });

      testWidgets('shows direct payments row with REMOTE_START_STOP_CAPABLE', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const RMCapabilitiesWidget(
              capabilities: ['REMOTE_START_STOP_CAPABLE'],
              isEflux: true,
            ),
          ),
        );

        expect(find.text('Direct Payments'), findsOneWidget);
        expect(find.text('Charging Card or Tag'), findsNothing);
      });
    });
  });
}
