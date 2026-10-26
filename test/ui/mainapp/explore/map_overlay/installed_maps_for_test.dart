import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/charging_location_details_widget.dart';

SupportedMap _map(MapApp app, {required bool installed}) => SupportedMap(map: app, isInstalled: installed);

void main() {
  group('installedMapsFor', () {
    test('adds installed navigation-only apps that the marker request leaves out', () {
      final maps = installedMapsFor(
        markerMaps: [_map(MapApp.google, installed: true)],
        directionsMaps: [_map(MapApp.google, installed: true), _map(MapApp.waze, installed: true)],
      );

      expect(maps.map((m) => m.map.id), ['google', 'waze']);
    });

    test('keeps the marker entry when an app supports both request types', () {
      final markerEntry = _map(MapApp.google, installed: true);

      final maps = installedMapsFor(
        markerMaps: [markerEntry],
        directionsMaps: [_map(MapApp.google, installed: true)],
      );

      expect(maps, hasLength(1));
      expect(identical(maps.single, markerEntry), isTrue);
    });

    test('drops apps that are only reachable through a browser link', () {
      final maps = installedMapsFor(
        markerMaps: [_map(MapApp.google, installed: false), _map(MapApp.apple, installed: true)],
        directionsMaps: [_map(MapApp.waze, installed: false)],
      );

      expect(maps.map((m) => m.map.id), ['apple']);
    });

    test('Waze is navigation-only in map_launcher, which is why both requests are needed', () {
      expect(MapApp.waze.supportsMarkerCoords, isFalse);
      expect(MapApp.waze.supportsDirectionsCoords, isTrue);
    });
  });
}
