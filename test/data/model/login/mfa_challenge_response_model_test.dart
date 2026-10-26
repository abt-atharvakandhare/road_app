import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';

void main() {
  test('a passkey arm carries the ceremony id and the options verbatim', () {
    final options = {
      'challenge': 'Y2hhbGxlbmdlLWdldA',
      'rpId': 'e-flux.dashboard.road.io',
      'timeout': 60000,
      'userVerification': 'required',
      'allowCredentials': [
        {
          'type': 'public-key',
          'id': 'a25vd24tY3JlZA',
          'transports': ['internal', 'hybrid'],
        },
      ],
    };

    final model = MfaChallengeResponseModel.fromJson({
      'type': 'passkey',
      'ceremonyId': 'ceremony-1',
      'options': options,
    });

    expect(model.type, MfaMethod.passkey);
    expect(model.ceremonyId, 'ceremony-1');
    // The options must survive untouched — they are handed verbatim to the
    // platform authenticator, nested structures included.
    expect(model.options, options);
    expect(model.hint, isNull);
    expect(model.nextSendAfterSeconds, isNull);
  });

  test('an sms arm parses without the passkey fields', () {
    final model = MfaChallengeResponseModel.fromJson({
      'type': 'sms',
      'hint': '•••• 3813',
      'nextSendAfterSeconds': 60,
    });

    expect(model.type, MfaMethod.sms);
    expect(model.hint, '•••• 3813');
    expect(model.nextSendAfterSeconds, 60);
    expect(model.ceremonyId, isNull);
    expect(model.options, isNull);
  });

  test('an unknown factor type parses as unknown instead of failing', () {
    final model = MfaChallengeResponseModel.fromJson({'type': 'push'});

    expect(model.type, MfaMethod.unknown);
  });
}
