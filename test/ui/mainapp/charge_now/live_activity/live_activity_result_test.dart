import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/mainapp/charge_now/live_activity/live_activity_dispatcher.dart';

void main() {
  group('LiveActivityResult.fromMap', () {
    test('parses a fully-populated started result', () {
      final result = LiveActivityResult.fromMap({
        'status': 'started',
        'activityId': 'abc-123',
        'pushToken': 'deadbeef',
      });

      expect(result.status, LiveActivityStatus.started);
      expect(result.activityId, 'abc-123');
      expect(result.pushToken, 'deadbeef');
      expect(result.error, isNull);
      expect(result.isNewActivity, isTrue);
      expect(result.needsRegistration, isTrue);
    });

    test('parses an updated result without a push token', () {
      final result = LiveActivityResult.fromMap({
        'status': 'updated',
        'activityId': 'abc-123',
      });

      expect(result.status, LiveActivityStatus.updated);
      expect(result.activityId, 'abc-123');
      expect(result.pushToken, isNull);
      expect(result.isNewActivity, isFalse);
      expect(result.needsRegistration, isFalse);
    });

    test('started without a push token does not require registration', () {
      // Happens when the 5-second push-token timeout kicks in on the native side —
      // we still start the activity but can't register with the backend.
      final result = LiveActivityResult.fromMap({
        'status': 'started',
        'activityId': 'abc-123',
      });

      expect(result.status, LiveActivityStatus.started);
      expect(result.isNewActivity, isTrue);
      expect(result.needsRegistration, isFalse);
    });

    test('parses an error result with a message', () {
      final result = LiveActivityResult.fromMap({
        'status': 'error',
        'error': 'Missing activeSessionId',
      });

      expect(result.status, LiveActivityStatus.error);
      expect(result.error, 'Missing activeSessionId');
      expect(result.needsRegistration, isFalse);
    });

    test('defaults unknown status strings to error', () {
      final result = LiveActivityResult.fromMap({'status': 'potato'});
      expect(result.status, LiveActivityStatus.error);
    });

    test('defaults missing status to error', () {
      final result = LiveActivityResult.fromMap(<String, dynamic>{});
      expect(result.status, LiveActivityStatus.error);
    });
  });

  group('LiveActivityResult factories', () {
    test('disabled() has the expected status', () {
      expect(LiveActivityResult.disabled().status, LiveActivityStatus.disabled);
    });

    test('androidNotSupported() has the expected status', () {
      expect(LiveActivityResult.androidNotSupported().status, LiveActivityStatus.androidNotSupported);
    });
  });
}
