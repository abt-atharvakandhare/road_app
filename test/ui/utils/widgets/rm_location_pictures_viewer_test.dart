import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_viewer.dart';

Widget buildViewer(int count) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: RMLocationPicturesViewer(
      images: List.generate(
        count,
        (i) => LocationImage(url: 'https://example.com/site-$i.jpg', category: 'LOCATION', type: 'jpeg'),
      ),
    ),
  );
}

ScrollPhysics? pageViewPhysics(WidgetTester tester) => tester.widget<PageView>(find.byType(PageView)).physics;

/// Two-finger vertical pinch-out centred on the viewer, leaving both pointers
/// down. Vertical so the pointers don't also register as a horizontal page drag.
Future<(TestGesture, TestGesture)> pinchOut(WidgetTester tester) async {
  final center = tester.getCenter(find.byType(InteractiveViewer));
  final a = await tester.createGesture(pointer: 1, kind: PointerDeviceKind.touch);
  final b = await tester.createGesture(pointer: 2, kind: PointerDeviceKind.touch);
  await a.down(center - const Offset(0, 20));
  await b.down(center + const Offset(0, 20));
  await tester.pump();
  for (var i = 1; i <= 5; i++) {
    await a.moveBy(const Offset(0, -20));
    await b.moveBy(const Offset(0, 20));
    await tester.pump();
  }
  return (a, b);
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  testWidgets('shows the counter and swipes between pages when not zoomed', (tester) async {
    await tester.pumpWidget(buildViewer(3));

    expect(find.text('1 / 3'), findsOneWidget);
    expect(pageViewPhysics(tester), isA<PageScrollPhysics>());

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('locks page swiping while zoomed in and unlocks after zooming out', (tester) async {
    await tester.pumpWidget(buildViewer(3));

    final (a, b) = await pinchOut(tester);
    await tester.pump();

    expect(pageViewPhysics(tester), isA<NeverScrollableScrollPhysics>());

    // Pinch back in to the original spread; minScale clamps at 1.
    for (var i = 1; i <= 5; i++) {
      await a.moveBy(const Offset(0, 20));
      await b.moveBy(const Offset(0, -20));
      await tester.pump();
    }
    await a.up();
    await b.up();
    await tester.pumpAndSettle();

    expect(pageViewPhysics(tester), isA<PageScrollPhysics>());
    expect(find.text('1 / 3'), findsOneWidget);
  });
}
