import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_picture.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_accordion.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_viewer.dart';

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

List<LocationImage> buildImages(int count) {
  return List.generate(
    count,
    (i) => LocationImage(url: 'https://example.com/site-$i.jpg', category: 'LOCATION', type: 'jpeg'),
  );
}

Future<void> expandAccordion(WidgetTester tester) async {
  await tester.tap(find.text('Photos'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  testWidgets('starts collapsed with only the header visible', (tester) async {
    await tester.pumpWidget(buildTestWidget(RMLocationPicturesAccordion(images: buildImages(2))));

    expect(find.text('Photos'), findsOneWidget);
    expect(find.byType(RMLocationPicture), findsNothing);
  });

  testWidgets('expanding shows a tile per picture', (tester) async {
    await tester.pumpWidget(buildTestWidget(RMLocationPicturesAccordion(images: buildImages(2))));
    await expandAccordion(tester);

    expect(find.byType(RMLocationPicture), findsNWidgets(2));
  });

  testWidgets('shows at most four pictures', (tester) async {
    await tester.pumpWidget(buildTestWidget(RMLocationPicturesAccordion(images: buildImages(6))));
    await expandAccordion(tester);

    // Tiles are laid out lazily; drag the strip to the end so every tile has been built.
    await tester.drag(find.byType(ListView), const Offset(-2000, 0));
    await tester.pumpAndSettle();

    final builtUrls = tester.widgetList<RMLocationPicture>(find.byType(RMLocationPicture)).map((w) => w.image.url);
    expect(builtUrls, contains('https://example.com/site-3.jpg'));
    expect(builtUrls, isNot(contains('https://example.com/site-4.jpg')));
    expect(builtUrls, isNot(contains('https://example.com/site-5.jpg')));
  });

  testWidgets('tapping a picture opens the full-screen viewer at that index', (tester) async {
    await tester.pumpWidget(buildTestWidget(RMLocationPicturesAccordion(images: buildImages(3))));
    await expandAccordion(tester);

    await tester.tap(find.byType(RMLocationPicture).first);
    await tester.pumpAndSettle();

    expect(find.byType(RMLocationPicturesViewer), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(RMLocationPicturesViewer), findsNothing);
  });
}
