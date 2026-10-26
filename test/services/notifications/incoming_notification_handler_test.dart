import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/services/notifications/incoming_notification_handler.dart';

void main() {
  group('claimMessageId', () {
    late Set<String> handled;

    setUp(() {
      handled = <String>{};
    });

    test('returns true on first claim and records the id', () {
      expect(claimMessageId(handled, 'msg-1'), isTrue);
      expect(handled, contains('msg-1'));
    });

    test('returns false when the same id is claimed twice', () {
      claimMessageId(handled, 'msg-1');

      expect(claimMessageId(handled, 'msg-1'), isFalse);
      expect(handled, hasLength(1));
    });

    test('treats distinct ids independently', () {
      expect(claimMessageId(handled, 'msg-1'), isTrue);
      expect(claimMessageId(handled, 'msg-2'), isTrue);
      expect(claimMessageId(handled, 'msg-1'), isFalse);
      expect(claimMessageId(handled, 'msg-2'), isFalse);
    });

    test('returns true for a null id and does not record anything', () {
      // No identifier means we can't dedup — fall back to dispatching.
      expect(claimMessageId(handled, null), isTrue);
      expect(handled, isEmpty);
    });

    test('null ids never collide with each other', () {
      expect(claimMessageId(handled, null), isTrue);
      expect(claimMessageId(handled, null), isTrue);
      expect(handled, isEmpty);
    });
  });
}
