import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/street_view/street_view_availability_service.dart';
import 'package:road_mobile/ui/utils/widgets/rm_street_view_accordion.dart';
import 'package:road_mobile/ui/utils/widgets/rm_street_view_panorama.dart';

class FakeAvailabilityService extends StreetViewAvailabilityService {
  FakeAvailabilityService({required this.available});

  final bool available;
  int callCount = 0;

  @override
  Future<bool> isAvailable(double latitude, double longitude, {CancelToken? cancelToken}) async {
    callCount++;
    return available;
  }
}

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

Widget buildAccordion(StreetViewAvailabilityService service) {
  return RMStreetViewAccordion(
    latitude: 52.3315,
    longitude: 4.9192,
    availabilityService: service,
  );
}

Future<void> expandAccordion(WidgetTester tester) async {
  await tester.tap(find.text('Street View'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  testWidgets('is collapsed by default', (tester) async {
    await tester.pumpWidget(buildTestWidget(buildAccordion(FakeAvailabilityService(available: true))));

    expect(find.text('Street View'), findsOneWidget);
    expect(tester.getSize(find.byType(SizeTransition)).height, 0);
  });

  testWidgets('expanding shows the press-to-view placeholder without loading anything', (tester) async {
    final service = FakeAvailabilityService(available: true);
    await tester.pumpWidget(buildTestWidget(buildAccordion(service)));

    await expandAccordion(tester);

    expect(find.text('Press to view'), findsOneWidget);
    expect(service.callCount, 0);
    expect(find.byType(RMStreetViewPanorama), findsNothing);
  });

  testWidgets('pressing the placeholder loads the panorama when imagery is available', (tester) async {
    final service = FakeAvailabilityService(available: true);
    await tester.pumpWidget(buildTestWidget(buildAccordion(service)));

    await expandAccordion(tester);
    await tester.tap(find.text('Press to view'));
    await tester.pumpAndSettle();

    expect(service.callCount, 1);
    expect(find.byType(RMStreetViewPanorama), findsOneWidget);
  });

  testWidgets('pressing the placeholder shows the unavailable message when there is no imagery', (tester) async {
    final service = FakeAvailabilityService(available: false);
    await tester.pumpWidget(buildTestWidget(buildAccordion(service)));

    await expandAccordion(tester);
    await tester.tap(find.text('Press to view'));
    await tester.pumpAndSettle();

    expect(find.byType(RMStreetViewPanorama), findsNothing);
    expect(find.text('Street View is not available for this location'), findsOneWidget);
  });
}
