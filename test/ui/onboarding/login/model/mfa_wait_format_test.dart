import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/ui/onboarding/login/model/mfa_wait_format.dart';

void main() {
  group('formatWaitSeconds', () {
    test('renders sub-minute waits as seconds', () {
      expect(formatWaitSeconds(42), '42s');
      expect(formatWaitSeconds(0), '0s');
    });

    test('renders minute-plus waits as m:ss without rounding up', () {
      expect(formatWaitSeconds(229), '3:49');
      expect(formatWaitSeconds(60), '1:00');
      expect(formatWaitSeconds(605), '10:05');
    });
  });
}
