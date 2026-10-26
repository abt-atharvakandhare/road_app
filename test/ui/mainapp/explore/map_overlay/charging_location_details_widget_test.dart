import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/locations/locations_response_model.dart' show GeoLocation;
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_cubit.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/charging_location_details_widget.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_accordion.dart';
import 'package:road_mobile/ui/utils/widgets/rm_street_view_accordion.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockFavouritesCubit extends MockCubit<FavouritesState> implements FavouritesCubit {}

class MockMapOverlayBloc extends MockBloc<MapOverlayEvent, MapOverlayState> implements MapOverlayBloc {}

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

MapLocationV2 buildLocation({List<LocationImage>? images}) {
  return MapLocationV2(
    id: 'location-1',
    address: 'Joan Muyskenweg 35, Amsterdam',
    evses: [
      Evse(
        evseId: 'NL*TST*E123456',
        uid: 'evse-uid-1',
        status: 'AVAILABLE',
        connectors: [Connector(standard: 'IEC_62196_T2', powerType: 'AC_3_PHASE')],
      ),
    ],
    geoLocation: GeoLocation(coordinates: [4.9192, 52.3315]),
    images: images,
  );
}

Widget buildTestWidget(MapLocationV2 location) {
  final authCubit = MockAuthCubit();
  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([const AuthState.loggedOut()]),
    initialState: const AuthState.loggedOut(),
  );

  final favouritesCubit = MockFavouritesCubit();
  const favouritesState = FavouritesState.favourites(stationIds: [], stations: []);
  whenListen(
    favouritesCubit,
    Stream<FavouritesState>.fromIterable([favouritesState]),
    initialState: favouritesState,
  );

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: AppLocalizations.supportedLocales.first,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => authCubit),
        BlocProvider<FavouritesCubit>(create: (context) => favouritesCubit),
        BlocProvider<MapOverlayBloc>(create: (context) => MockMapOverlayBloc()),
        BlocProvider<MapBloc>(create: (context) => MockMapBloc()),
      ],
      child: Scaffold(
        body: ChargingLocationDetailsWidget(
          mapLocations: [location],
          resetOnClose: false,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    F.appFlavor = Flavor.eflux;
  });

  testWidgets('shows the Street View section when the location has no pictures', (tester) async {
    await tester.pumpWidget(buildTestWidget(buildLocation()));

    expect(find.byType(RMStreetViewAccordion), findsOneWidget);
  });

  testWidgets('shows the Photos section instead of Street View when the location has OCPI pictures',
      (tester) async {
    final location = buildLocation(
      images: [LocationImage(url: 'https://example.com/site.jpg', category: 'LOCATION')],
    );
    await tester.pumpWidget(buildTestWidget(location));

    expect(find.byType(RMStreetViewAccordion), findsNothing);
    expect(find.byType(RMLocationPicturesAccordion), findsOneWidget);
  });

  testWidgets('hides the Photos section when the location has no pictures', (tester) async {
    await tester.pumpWidget(buildTestWidget(buildLocation(images: [])));

    expect(find.byType(RMLocationPicturesAccordion), findsNothing);
    expect(find.byType(RMStreetViewAccordion), findsOneWidget);
  });

  testWidgets('shows the share button next to Get Directions', (tester) async {
    await tester.pumpWidget(buildTestWidget(buildLocation()));

    expect(find.text('Get Directions'), findsOneWidget);
    // The glyph is platform-specific (ios_share on iOS, share elsewhere), so
    // find the button by its semantic label instead.
    final icons = tester.widgetList<Icon>(find.byType(Icon));
    expect(icons.where((icon) => icon.semanticLabel == 'Share location'), hasLength(1));
  });
}
