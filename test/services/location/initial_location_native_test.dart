import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/services/location/initial_location_native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('io.e-flux.mobile/initial_location');
  final messenger = TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('InitialLocationNative', () {
    test('returns UserLocation when the channel yields a complete map', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getCurrentLocation');
        return <String, double>{
          'latitude': 52.3676,
          'longitude': 4.9041,
          'accuracy': 17.5,
        };
      });

      final result = await InitialLocationNative.getCurrentLocation();

      expect(result, isNotNull);
      expect(result!.latitude, 52.3676);
      expect(result.longitude, 4.9041);
      expect(result.accuracy, 17.5);
    });

    test('returns null when the channel returns null', () async {
      messenger.setMockMethodCallHandler(channel, (_) async => null);

      expect(await InitialLocationNative.getCurrentLocation(), isNull);
    });

    test('returns null when a required key is missing', () async {
      messenger.setMockMethodCallHandler(channel, (_) async => <String, double>{
            'latitude': 1.0,
            'longitude': 2.0,
            // accuracy intentionally omitted
          });

      expect(await InitialLocationNative.getCurrentLocation(), isNull);
    });

    test('swallows PlatformException and returns null', () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'BOOM');
      });

      expect(await InitialLocationNative.getCurrentLocation(), isNull);
    });
  });
}
