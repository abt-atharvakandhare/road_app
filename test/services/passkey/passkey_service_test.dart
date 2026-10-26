import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';

class MockPasskeyAuthenticator extends Mock implements PasskeyAuthenticator {}

/// Creation options exactly as the backend's SimpleWebAuthn emits them.
final creationOptions = <String, dynamic>{
  'challenge': 'Y2hhbGxlbmdlLWNyZWF0ZQ',
  'rp': {'id': 'e-flux.dashboard.road.io', 'name': 'E-Flux'},
  'user': {'id': 'dXNlci1pZA', 'name': 'user@example.com', 'displayName': 'user@example.com'},
  'pubKeyCredParams': [
    {'type': 'public-key', 'alg': -7},
    {'type': 'public-key', 'alg': -257},
  ],
  'timeout': 60000,
  'attestation': 'none',
  'excludeCredentials': [
    {'type': 'public-key', 'id': 'ZXhpc3RpbmctY3JlZA', 'transports': ['internal']},
  ],
  'authenticatorSelection': {
    'residentKey': 'required',
    'userVerification': 'required',
    'requireResidentKey': true,
  },
};

/// Request options exactly as the backend's SimpleWebAuthn emits them.
final requestOptions = <String, dynamic>{
  'challenge': 'Y2hhbGxlbmdlLWdldA',
  'rpId': 'e-flux.dashboard.road.io',
  'timeout': 60000,
  'userVerification': 'required',
  'allowCredentials': [
    {'type': 'public-key', 'id': 'a25vd24tY3JlZA', 'transports': ['internal', 'hybrid']},
  ],
};

void main() {
  late MockPasskeyAuthenticator mockAuthenticator;
  late PasskeyService service;

  setUpAll(() {
    registerFallbackValue(RegisterRequestType.fromJson(creationOptions));
    registerFallbackValue(AuthenticateRequestType.fromJson(requestOptions));
  });

  setUp(() {
    mockAuthenticator = MockPasskeyAuthenticator();
    service = PasskeyService.withAuthenticator(mockAuthenticator);
  });

  group('isSupported', () {
    test('is false on a non-mobile host without asking the platform', () async {
      expect(await service.isSupported(), isFalse);
      verifyNever(() => mockAuthenticator.getAvailability());
    });
  });

  group('create', () {
    test('passes the creation options through verbatim and returns the WebAuthn response JSON', () async {
      when(() => mockAuthenticator.register(any())).thenAnswer((_) async => const RegisterResponseType(
            id: 'bmV3LWNyZWQ',
            rawId: 'bmV3LWNyZWQ',
            clientDataJSON: 'Y2xpZW50LWRhdGE',
            attestationObject: 'YXR0ZXN0YXRpb24',
            transports: ['internal'],
          ));

      final response = await service.create(creationOptions);

      final request = verify(() => mockAuthenticator.register(captureAny())).captured.single
          as RegisterRequestType;
      expect(request.challenge, 'Y2hhbGxlbmdlLWNyZWF0ZQ');
      expect(request.relyingParty.id, 'e-flux.dashboard.road.io');
      expect(request.user.id, 'dXNlci1pZA');
      expect(request.excludeCredentials.single.id, 'ZXhpc3RpbmctY3JlZA');
      expect(request.authSelectionType?.userVerification, 'required');

      expect(response['id'], 'bmV3LWNyZWQ');
      expect(response['rawId'], 'bmV3LWNyZWQ');
      expect(response['type'], 'public-key');
      expect(response['response'], {
        'clientDataJSON': 'Y2xpZW50LWRhdGE',
        'attestationObject': 'YXR0ZXN0YXRpb24',
        'transports': ['internal'],
      });
    });

    test('maps a user cancellation', () async {
      when(() => mockAuthenticator.register(any())).thenThrow(PasskeyAuthCancelledException());

      await expectLater(
          service.create(creationOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.cancelled)));
    });

    test('maps an exclude-credentials match', () async {
      when(() => mockAuthenticator.register(any()))
          .thenThrow(ExcludeCredentialsCanNotBeRegisteredException());

      await expectLater(
          service.create(creationOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.excludedCredentialExists)));
    });

    test('maps a missing domain association to a security error', () async {
      when(() => mockAuthenticator.register(any()))
          .thenThrow(DomainNotAssociatedException('no AASA entry'));

      await expectLater(
          service.create(creationOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.securityError)));
    });

    test('maps an unsupported device', () async {
      when(() => mockAuthenticator.register(any())).thenThrow(DeviceNotSupportedException());

      await expectLater(
          service.create(creationOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.unsupported)));
    });

    test('maps malformed options to a security error without calling the platform', () async {
      await expectLater(
          service.create({'challenge': 'x', 'rp': 'not-a-map', 'user': {}}),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.securityError)));
      verifyNever(() => mockAuthenticator.register(any()));
    });
  });

  group('get', () {
    test('passes the request options through verbatim and returns the WebAuthn response JSON', () async {
      when(() => mockAuthenticator.authenticate(any())).thenAnswer((_) async => const AuthenticateResponseType(
            id: 'a25vd24tY3JlZA',
            rawId: 'a25vd24tY3JlZA',
            clientDataJSON: 'Y2xpZW50LWRhdGE',
            authenticatorData: 'YXV0aC1kYXRh',
            signature: 'c2lnbmF0dXJl',
            userHandle: 'dXNlci1pZA',
          ));

      final response = await service.get(requestOptions);

      final request = verify(() => mockAuthenticator.authenticate(captureAny())).captured.single
          as AuthenticateRequestType;
      expect(request.challenge, 'Y2hhbGxlbmdlLWdldA');
      expect(request.relyingPartyId, 'e-flux.dashboard.road.io');
      expect(request.userVerification, 'required');
      expect(request.allowCredentials?.single.id, 'a25vd24tY3JlZA');

      expect(response['id'], 'a25vd24tY3JlZA');
      expect(response['type'], 'public-key');
      expect(response['response'], {
        'clientDataJSON': 'Y2xpZW50LWRhdGE',
        'authenticatorData': 'YXV0aC1kYXRh',
        'signature': 'c2lnbmF0dXJl',
        'userHandle': 'dXNlci1pZA',
      });
    });

    test('maps a user cancellation', () async {
      when(() => mockAuthenticator.authenticate(any())).thenThrow(PasskeyAuthCancelledException());

      await expectLater(
          service.get(requestOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.cancelled)));
    });

    test('maps a timeout to a cancellation', () async {
      when(() => mockAuthenticator.authenticate(any())).thenThrow(TimeoutException('timed out'));

      await expectLater(
          service.get(requestOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.cancelled)));
    });

    test('maps a missing credential', () async {
      when(() => mockAuthenticator.authenticate(any())).thenThrow(NoCredentialsAvailableException());

      await expectLater(
          service.get(requestOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.noCredential)));
    });

    test('maps a missing Google account to unsupported', () async {
      when(() => mockAuthenticator.authenticate(any())).thenThrow(MissingGoogleSignInException());

      await expectLater(
          service.get(requestOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.unsupported)));
    });

    test('maps an unhandled authenticator failure to a security error', () async {
      when(() => mockAuthenticator.authenticate(any()))
          .thenThrow(UnhandledAuthenticatorException('ios-unhandled', 'boom', null));

      await expectLater(
          service.get(requestOptions),
          throwsA(isA<PasskeyException>()
              .having((e) => e.type, 'type', PasskeyErrorType.securityError)));
    });
  });
}
