import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/map_overlay_widget.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/charging_location_filters.dart';
import 'package:road_mobile/flavors.dart';

class MockMapOverlayBloc extends MockBloc<MapOverlayEvent, MapOverlayState> implements MapOverlayBloc {
  @override
  final GlobalKey searchFieldKey = GlobalKey();

  @override
  TextEditingController searchFieldController = TextEditingController();
}

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {
  @override
  ChargingLocationFilters mapFilters = ChargingLocationFilters();
}

Widget buildOverlayWidget(MockMapBloc mockMapBloc, MockMapOverlayBloc mockMapOverlayBloc) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(
          create: (context) => mockMapBloc,
        ),
        BlocProvider<MapOverlayBloc>(
          create: (context) => mockMapOverlayBloc,
        ),
      ],
      child: const Scaffold(body: MapOverlayWidget()),
    ),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux; // Initialize appFlavor for tests
    registerFallbackValue(const MapOverlayEvent.searchQuery(''));
  });

  Future<MockMapOverlayBloc> pumpOverlayIn(WidgetTester tester, MapOverlayState overlayState) async {
    final mockMapOverlayBloc = MockMapOverlayBloc();
    whenListen(mockMapOverlayBloc, Stream.fromIterable([overlayState]), initialState: overlayState);

    final mockMapBloc = MockMapBloc();
    whenListen(mockMapBloc, Stream.fromIterable([const MapState.chargingStations(mapItems: [])]),
        initialState: const MapState.chargingStations(mapItems: []));

    await tester.pumpWidget(buildOverlayWidget(mockMapBloc, mockMapOverlayBloc));
    await tester.pump();
    return mockMapOverlayBloc;
  }

  Future<void> focusSearchField(WidgetTester tester) async {
    tester.widget<EditableText>(find.byType(EditableText)).focusNode.requestFocus();
    await tester.pump();
  }

  testWidgets('focusing the search field from the initial state starts a search', (tester) async {
    final mockMapOverlayBloc = await pumpOverlayIn(tester, const MapOverlayState.initial());

    await focusSearchField(tester);

    verify(() => mockMapOverlayBloc.add(const MapOverlayEvent.searchQuery(''))).called(1);
  });

  testWidgets('regaining focus while typeahead results are showing does not repeat the search', (tester) async {
    // Closing an error dialog hands focus back to the search field. Repeating the failed query at
    // that point would reopen the dialog in a loop.
    final mockMapOverlayBloc =
        await pumpOverlayIn(tester, const MapOverlayState.typeaheadSearchResults('g', []));
    mockMapOverlayBloc.searchFieldController.text = 'g';

    await focusSearchField(tester);

    verifyNever(() => mockMapOverlayBloc.add(any(that: isA<SearchQuery>())));
  });

  (testWidgets('Default map overlay', (tester) async {
    final mockMapOverlayBloc = MockMapOverlayBloc();
    whenListen(
      mockMapOverlayBloc,
      Stream.fromIterable([const MapOverlayState.initial()]),
      initialState: const MapOverlayState.initial(),
    );

    final mockMapBloc = MockMapBloc();
    whenListen(mockMapBloc, Stream.fromIterable([const MapState.chargingStations(mapItems: [])]),
        initialState: const MapState.chargingStations(mapItems: []));

    await tester.pumpWidget(buildOverlayWidget(mockMapBloc, mockMapOverlayBloc));

    final editableText = find.byType(EditableText);
    expect(editableText, findsOneWidget);
    final searchFieldDecoration = find.widgetWithText(Transform, 'Search address or place name');
    expect(searchFieldDecoration, findsOneWidget);
  }));
}
