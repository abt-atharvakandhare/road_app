import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/login/mfa_code_sent_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/mainapp/account/subscreens/security/cubit/security_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/run_with_step_up.dart';

class MockMfaFactorsRepository extends Mock implements MfaFactorsRepository {}

class MockPasskeyService extends Mock implements PasskeyService {}

RMApiError mfaError(String code, {int? retryAfterSeconds}) =>
    RMApiError(cause: 'mfa error', details: [ErrorDetails(code: code, retryAfterSeconds: retryAfterSeconds)]);

void main() {
  late MockMfaFactorsRepository mockRepository;
  late MockPasskeyService mockPasskeyService;

  final totpFactor = MfaFactorModel(
      id: 'factor-totp',
      type: MfaMethod.totp,
      status: MfaFactorStatus.active,
      createdAt: DateTime(2026, 3, 14));
  final smsFactor =
      MfaFactorModel(id: 'factor-sms', type: MfaMethod.sms, status: MfaFactorStatus.active, hint: '•••• 3813');
  final recoveryCodesFactor = MfaFactorModel(
      id: 'factor-codes', type: MfaMethod.recoveryCode, status: MfaFactorStatus.active, remainingCodes: 12);
  final recoveryEmailFactor = MfaFactorModel(
      id: 'factor-email', type: MfaMethod.recoveryEmail, status: MfaFactorStatus.active, hint: 'r•••@y•••.do');
  final passkeyFactor = MfaFactorModel(
      id: 'factor-passkey',
      type: MfaMethod.passkey,
      status: MfaFactorStatus.active,
      label: 'Work laptop',
      hint: 'iCloud Keychain',
      createdAt: DateTime(2026, 5, 2),
      lastUsedAt: DateTime(2026, 8, 1));
  final secondPasskeyFactor =
      MfaFactorModel(id: 'factor-passkey-2', type: MfaMethod.passkey, status: MfaFactorStatus.active);

  final creationOptions = <String, dynamic>{
    'rp': {'id': 'e-flux.dashboard.road.io'},
    'challenge': 'Y2hhbGxlbmdl',
  };
  final attestationResponse = <String, dynamic>{'id': 'cred-1', 'type': 'public-key'};

  MfaFactorsModel listing({List<MfaFactorModel>? factors, List<MfaMethod>? permitted}) => MfaFactorsModel(
      factors: factors ?? [totpFactor],
      permittedMethods: permitted ?? [MfaMethod.totp, MfaMethod.sms],
      mode: MfaMode.encourage);

  final sixteenCodes = List.generate(16, (i) => 'code-${i.toString().padLeft(2, '0')}');

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepository = MockMfaFactorsRepository();
    when(() => mockRepository.getFactors()).thenAnswer((_) async => listing());
    mockPasskeyService = MockPasskeyService();
    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => true);
  });

  Future<SecurityCubit> makeCubit() async {
    final cubit = SecurityCubit(mockRepository, mockPasskeyService);
    // Let the constructor's initial load settle.
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      captured = context;
      return const SizedBox();
    })));
    return captured;
  }

  group('listing', () {
    test('loads the factor listing on creation', () async {
      final full = listing(factors: [totpFactor, smsFactor, recoveryCodesFactor, recoveryEmailFactor]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => full);

      final cubit = await makeCubit();

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, full);
      await cubit.close();
    });

    test('a failed load leaves the list usable with an error', () async {
      when(() => mockRepository.getFactors()).thenThrow(RMApiError(cause: 'network'));

      final cubit = await makeCubit();

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, isNull);
      expect(cubit.state.flow.isError, isTrue);
      await cubit.close();
    });
  });

  group('row policy', () {
    test('only active factors count as enrolled', () {
      final pendingTotp = MfaFactorModel(id: 'p', type: MfaMethod.totp, status: MfaFactorStatus.pending);
      final withPending = listing(factors: [pendingTotp]);

      expect(withPending.activeFactorOf(MfaMethod.totp), isNull);
      expect(withPending.canSetUp(MfaMethod.totp), isTrue);
    });

    test('a permitted, unenrolled method can be set up', () {
      expect(listing(factors: []).canSetUp(MfaMethod.sms), isTrue);
      expect(listing(factors: []).isDisabledByPolicy(MfaMethod.sms), isFalse);
    });

    test('an unpermitted, unenrolled method is disabled by policy', () {
      final smsForbidden = listing(factors: [], permitted: [MfaMethod.totp]);

      expect(smsForbidden.canSetUp(MfaMethod.sms), isFalse);
      expect(smsForbidden.isDisabledByPolicy(MfaMethod.sms), isTrue);
    });

    test('an enrolled method whose type was withdrawn from policy stays removable, not re-addable', () {
      final withdrawn = listing(factors: [smsFactor], permitted: [MfaMethod.totp]);

      expect(withdrawn.activeFactorOf(MfaMethod.sms), smsFactor);
      expect(withdrawn.canSetUp(MfaMethod.sms), isFalse);
      expect(withdrawn.isDisabledByPolicy(MfaMethod.sms), isFalse);
    });

    test('the only active sign-in factor is flagged for the stronger confirm', () {
      final one = listing(factors: [totpFactor, recoveryCodesFactor, recoveryEmailFactor]);
      final two = listing(factors: [totpFactor, smsFactor]);

      expect(one.isOnlyActiveLoginFactor(totpFactor), isTrue);
      expect(two.isOnlyActiveLoginFactor(totpFactor), isFalse);
      // Recovery factors are never sign-in factors.
      expect(one.isOnlyActiveLoginFactor(recoveryCodesFactor), isFalse);
    });
  });

  group('removeFactor', () {
    test('removes and refreshes the listing', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.removeFactor(factorId: 'factor-totp')).thenAnswer((_) async {});
      when(() => mockRepository.getFactors()).thenAnswer((_) async => listing(factors: []));

      final removed = await cubit.removeFactor('factor-totp');

      expect(removed, isTrue);
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors?.factors, isEmpty);
      await cubit.close();
    });

    test('a step-up demand is rethrown with the list left calm', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.removeFactor(factorId: 'factor-totp'))
          .thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(cubit.removeFactor('factor-totp'), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    testWidgets('runs through the step-up seam: verified prompt retries exactly once', (tester) async {
      final context = await pumpContext(tester);
      // runAsync: the cubit's repository futures resolve on the real event
      // loop, which FakeAsync would otherwise hold forever.
      await tester.runAsync(() async {
        final cubit = await makeCubit();
        var attempts = 0;
        when(() => mockRepository.removeFactor(factorId: 'factor-totp')).thenAnswer((_) async {
          attempts++;
          if (attempts == 1) throw mfaError('MFA_STEP_UP_REQUIRED');
        });
        when(() => mockRepository.getFactors()).thenAnswer((_) async => listing(factors: []));
        var promptCount = 0;

        final removed = await runWithStepUp(context, () => cubit.removeFactor('factor-totp'),
            prompt: (_) async {
          promptCount++;
          return true;
        });

        expect(removed, isTrue);
        expect(attempts, 2);
        expect(promptCount, 1);
        expect((cubit.state as MfaSetupMethodList).factors?.factors, isEmpty);
        await cubit.close();
      });
    });

    testWidgets('a declined step-up leaves the listing untouched', (tester) async {
      final context = await pumpContext(tester);
      await tester.runAsync(() async {
        final cubit = await makeCubit();
        when(() => mockRepository.removeFactor(factorId: 'factor-totp'))
            .thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

        await expectLater(
          runWithStepUp(context, () => cubit.removeFactor('factor-totp'), prompt: (_) async => null),
          throwsA(isA<RMApiError>()),
        );
        verify(() => mockRepository.removeFactor(factorId: 'factor-totp')).called(1);
        expect(cubit.state.flow.isError, isFalse);
        expect((cubit.state as MfaSetupMethodList).factors?.factors, [totpFactor]);
        await cubit.close();
      });
    });

    test('any other failure surfaces on the list', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.removeFactor(factorId: 'factor-totp')).thenThrow(RMApiError(cause: 'boom'));

      final removed = await cubit.removeFactor('factor-totp');

      expect(removed, isFalse);
      expect(cubit.state.flow.isError, isTrue);
      expect((cubit.state as MfaSetupMethodList).factors?.factors, [totpFactor]);
      await cubit.close();
    });
  });

  group('setUpMethod (settings host)', () {
    test('a step-up demand on begin is rethrown, not surfaced', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.beginTotp()).thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(cubit.setUpMethod(MfaMethod.totp), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });
  });

  group('recovery codes', () {
    test('generating shows the minted codes once', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.generateRecoveryCodes())
          .thenAnswer((_) async => MfaRecoveryCodesModel(factorId: 'factor-codes', codes: sixteenCodes));

      await cubit.generateRecoveryCodes();

      expect(cubit.state, isA<MfaSetupRecoveryCodes>());
      expect((cubit.state as MfaSetupRecoveryCodes).codes, sixteenCodes);
      await cubit.close();
    });

    test('leaving the codes step refreshes the listing', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.generateRecoveryCodes())
          .thenAnswer((_) async => MfaRecoveryCodesModel(factorId: 'factor-codes', codes: sixteenCodes));
      await cubit.generateRecoveryCodes();
      final refreshed = listing(factors: [totpFactor, recoveryCodesFactor]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => refreshed);

      cubit.backToList();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, refreshed);
      await cubit.close();
    });

    test('a step-up demand is rethrown with the list left calm', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.generateRecoveryCodes()).thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(cubit.generateRecoveryCodes(), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    test('any other failure surfaces on the list', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.generateRecoveryCodes()).thenThrow(RMApiError(cause: 'boom'));

      await cubit.generateRecoveryCodes();

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isTrue);
      await cubit.close();
    });
  });

  group('recovery email', () {
    Future<SecurityCubit> makeCubitAtEntry() async {
      final cubit = await makeCubit();
      cubit.startRecoveryEmail();
      return cubit;
    }

    test('starting opens the address entry', () async {
      final cubit = await makeCubitAtEntry();

      expect(cubit.state, isA<MfaSetupRecoveryEmailEntry>());
      await cubit.close();
    });

    test('submitting stages the factor and moves to code entry', () async {
      final cubit = await makeCubitAtEntry();
      when(() => mockRepository.beginRecoveryEmail(email: 'backup@example.com')).thenAnswer((_) async =>
          MfaFactorModel(id: 'factor-email', type: MfaMethod.recoveryEmail, status: MfaFactorStatus.pending));

      final moved = await cubit.submitRecoveryEmail('backup@example.com');

      expect(moved, isTrue);
      final state = cubit.state;
      expect(state, isA<MfaSetupRecoveryEmailVerify>());
      expect((state as MfaSetupRecoveryEmailVerify).factorId, 'factor-email');
      expect(state.email, 'backup@example.com');
      await cubit.close();
    });

    test('the account-email address is refused and stays on the entry', () async {
      final cubit = await makeCubitAtEntry();
      when(() => mockRepository.beginRecoveryEmail(email: 'me@example.com'))
          .thenThrow(mfaError('MFA_RECOVERY_EMAIL_SAME_AS_ACCOUNT'));

      final moved = await cubit.submitRecoveryEmail('me@example.com');

      expect(moved, isFalse);
      expect(cubit.state, isA<MfaSetupRecoveryEmailEntry>());
      expect(cubit.state.flow.isError, isTrue);
      expect(cubit.state.flow.error.isRecoveryEmailSameAsAccount, isTrue);
      await cubit.close();
    });

    test('a step-up demand on begin is rethrown, not surfaced', () async {
      final cubit = await makeCubitAtEntry();
      when(() => mockRepository.beginRecoveryEmail(email: 'backup@example.com'))
          .thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(cubit.submitRecoveryEmail('backup@example.com'), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupRecoveryEmailEntry>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    Future<SecurityCubit> makeCubitAtVerify() async {
      final cubit = await makeCubitAtEntry();
      when(() => mockRepository.beginRecoveryEmail(email: 'backup@example.com')).thenAnswer((_) async =>
          MfaFactorModel(id: 'factor-email', type: MfaMethod.recoveryEmail, status: MfaFactorStatus.pending));
      await cubit.submitRecoveryEmail('backup@example.com');
      return cubit;
    }

    test('verifying activates and refreshes the listing', () async {
      final cubit = await makeCubitAtVerify();
      when(() => mockRepository.verifyRecoveryEmail(factorId: 'factor-email', code: '123456'))
          .thenAnswer((_) async => recoveryEmailFactor);
      final refreshed = listing(factors: [totpFactor, recoveryEmailFactor]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => refreshed);

      final result = await cubit.verifyRecoveryEmailCode('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, refreshed);
      await cubit.close();
    });

    test('a wrong code retries inline', () async {
      final cubit = await makeCubitAtVerify();
      when(() => mockRepository.verifyRecoveryEmail(factorId: 'factor-email', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_INVALID_CODE'));

      final result = await cubit.verifyRecoveryEmailCode('000000');

      expect(result, TwoFactorAuthResult.wrongCode);
      expect(cubit.state, isA<MfaSetupRecoveryEmailVerify>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    test('resending re-stages the factor for the same address', () async {
      final cubit = await makeCubitAtVerify();
      when(() => mockRepository.beginRecoveryEmail(email: 'backup@example.com')).thenAnswer((_) async =>
          MfaFactorModel(id: 'factor-email-2', type: MfaMethod.recoveryEmail, status: MfaFactorStatus.pending));

      await cubit.resendRecoveryEmailCode();

      final state = cubit.state;
      expect(state, isA<MfaSetupRecoveryEmailVerify>());
      expect((state as MfaSetupRecoveryEmailVerify).factorId, 'factor-email-2');
      expect(state.email, 'backup@example.com');
      await cubit.close();
    });

    test('a throttled resend updates the wait instead of erroring', () async {
      final cubit = await makeCubitAtVerify();
      when(() => mockRepository.beginRecoveryEmail(email: 'backup@example.com'))
          .thenThrow(mfaError('MFA_CHALLENGE_TOO_SOON', retryAfterSeconds: 42));

      await cubit.resendRecoveryEmailCode();

      final state = cubit.state;
      expect(state, isA<MfaSetupRecoveryEmailVerify>());
      expect((state as MfaSetupRecoveryEmailVerify).nextSendAfterSeconds, 42);
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });
  });

  group('passkeys row policy', () {
    test('activeFactorsOf lists only the active passkeys', () {
      final pendingPasskey =
          MfaFactorModel(id: 'p1', type: MfaMethod.passkey, status: MfaFactorStatus.pending);
      final disabledPasskey =
          MfaFactorModel(id: 'p2', type: MfaMethod.passkey, status: MfaFactorStatus.disabled);
      final mixed = listing(factors: [passkeyFactor, pendingPasskey, disabledPasskey, secondPasskeyFactor]);

      expect(mixed.activeFactorsOf(MfaMethod.passkey), [passkeyFactor, secondPasskeyFactor]);
    });

    test('unpermitted and unenrolled passkeys are disabled by policy', () {
      final forbidden = listing(factors: [totpFactor], permitted: [MfaMethod.totp, MfaMethod.sms]);

      expect(forbidden.isDisabledByPolicy(MfaMethod.passkey), isTrue);
      expect(forbidden.canSetUp(MfaMethod.passkey), isFalse);
    });

    test('enrolled passkeys whose type was withdrawn from policy stay listed, not re-addable', () {
      final withdrawn = listing(factors: [passkeyFactor], permitted: [MfaMethod.totp]);

      expect(withdrawn.activeFactorsOf(MfaMethod.passkey), [passkeyFactor]);
      expect(withdrawn.isDisabledByPolicy(MfaMethod.passkey), isFalse);
      expect(withdrawn.canSetUp(MfaMethod.passkey), isFalse);
    });

    test('the only active passkey counts as the only sign-in factor; a second one does not', () {
      final single = listing(factors: [passkeyFactor, recoveryCodesFactor]);
      final pair = listing(factors: [passkeyFactor, secondPasskeyFactor]);

      expect(single.isOnlyActiveLoginFactor(passkeyFactor), isTrue);
      expect(pair.isOnlyActiveLoginFactor(passkeyFactor), isFalse);
    });

    test('device support is resolved before the listing shows', () async {
      final cubit = await makeCubit();

      expect(cubit.passkeySupported, isTrue);
      expect(cubit.state, isA<MfaSetupMethodList>());
      await cubit.close();
    });

    test('an unsupporting device still lists enrolled passkeys', () async {
      when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => listing(factors: [passkeyFactor]));

      final cubit = await makeCubit();

      expect(cubit.passkeySupported, isFalse);
      expect((cubit.state as MfaSetupMethodList).factors?.activeFactorsOf(MfaMethod.passkey),
          [passkeyFactor]);
      await cubit.close();
    });
  });

  group('add passkey', () {
    void stubHappyCeremony() {
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse))
          .thenAnswer((_) async => passkeyFactor);
    }

    test('runs begin, ceremony and verify, then refreshes the listing', () async {
      final cubit = await makeCubit();
      stubHappyCeremony();
      final refreshed = listing(factors: [totpFactor, passkeyFactor]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => refreshed);

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, refreshed);
      // No label at creation — the backend defaults it; renaming comes later.
      verify(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse)).called(1);
      await cubit.close();
    });

    test('a factorless user is routed through the email proof, then straight into the ceremony',
        () async {
      when(() => mockRepository.getFactors()).thenAnswer((_) async =>
          listing(factors: [], permitted: [MfaMethod.totp, MfaMethod.sms, MfaMethod.passkey]));
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenThrow(mfaError('MFA_ENROL_EMAIL_PROOF_REQUIRED'));
      when(() => mockRepository.sendEmailProof())
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 60));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupEmailProof>());
      expect((cubit.state as MfaSetupEmailProof).pendingMethod, MfaMethod.passkey);

      when(() => mockRepository.verifyEmailProof(code: '123456')).thenAnswer((_) async {});
      stubHappyCeremony();
      final refreshed = listing(
          factors: [passkeyFactor], permitted: [MfaMethod.totp, MfaMethod.sms, MfaMethod.passkey]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => refreshed);

      final result = await cubit.verifyEmailProofCode('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, refreshed);
      await cubit.close();
    });

    test('a step-up demand on begin is rethrown with the list left calm', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(cubit.setUpMethod(MfaMethod.passkey), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    test('a cancelled ceremony is silent and nothing is verified', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      verifyNever(() => mockRepository.verifyPasskeyRegistration(
          response: any(named: 'response'), label: any(named: 'label')));
      await cubit.close();
    });

    test('an existing credential on this device surfaces the already-on-device message', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.excludedCredentialExists));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isTrue);
      expect(cubit.state.flow.error.isPasskeyAlreadyOnDevice, isTrue);
      await cubit.close();
    });

    test('a ceremony integrity failure surfaces the localized generic message', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.securityError, 'DOMImplementation'));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isTrue);
      expect(cubit.state.flow.error.isPasskeyCreationFailed, isTrue);
      await cubit.close();
    });

    test('a failed registration verify surfaces on the list', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse))
          .thenThrow(RMApiError(cause: 'boom'));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isTrue);
      await cubit.close();
    });
  });

  group('renameFactor', () {
    test('renames and refreshes the listing', () async {
      when(() => mockRepository.getFactors()).thenAnswer((_) async => listing(factors: [passkeyFactor]));
      final cubit = await makeCubit();
      when(() => mockRepository.renameFactor(factorId: 'factor-passkey', label: 'Personal phone'))
          .thenAnswer((_) async => passkeyFactor);
      final refreshed = listing(factors: [passkeyFactor, secondPasskeyFactor]);
      when(() => mockRepository.getFactors()).thenAnswer((_) async => refreshed);

      final renamed = await cubit.renameFactor('factor-passkey', 'Personal phone');

      expect(renamed, isTrue);
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, refreshed);
      await cubit.close();
    });

    test('a step-up demand is rethrown with the list left calm', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.renameFactor(factorId: 'factor-passkey', label: 'Personal phone'))
          .thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

      await expectLater(
          cubit.renameFactor('factor-passkey', 'Personal phone'), throwsA(isA<RMApiError>()));
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    test('any other failure surfaces on the list', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.renameFactor(factorId: 'factor-passkey', label: 'Personal phone'))
          .thenThrow(RMApiError(cause: 'boom'));

      final renamed = await cubit.renameFactor('factor-passkey', 'Personal phone');

      expect(renamed, isFalse);
      expect(cubit.state.flow.isError, isTrue);
      expect((cubit.state as MfaSetupMethodList).factors?.factors, [totpFactor]);
      await cubit.close();
    });
  });
}
