import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/login/mfa_code_sent_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_totp_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_mfa_setup_cubit.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';

class MockMfaFactorsRepository extends Mock implements MfaFactorsRepository {}

class MockPasskeyService extends Mock implements PasskeyService {}

RMApiError mfaError(String code, {int? retryAfterSeconds}) =>
    RMApiError(cause: 'mfa error', details: [ErrorDetails(code: code, retryAfterSeconds: retryAfterSeconds)]);

void main() {
  late MockMfaFactorsRepository mockRepository;
  late MockPasskeyService mockPasskeyService;

  final factorless = MfaFactorsModel(
      factors: [], permittedMethods: [MfaMethod.totp, MfaMethod.sms], mode: MfaMode.encourage);
  final smsEnrolled = MfaFactorsModel(factors: [
    MfaFactorModel(id: 'factor-sms', type: MfaMethod.sms, status: MfaFactorStatus.active, hint: '•••• 3813'),
  ], permittedMethods: [
    MfaMethod.totp,
    MfaMethod.sms
  ], mode: MfaMode.encourage);
  final totpBegin = MfaEnrolTotpBeginModel(factorId: 'factor-totp', otpauthUri: 'otpauth://totp/x', secret: 'SECRET');

  setUp(() {
    mockRepository = MockMfaFactorsRepository();
    mockPasskeyService = MockPasskeyService();
    when(() => mockRepository.getFactors()).thenAnswer((_) async => smsEnrolled);
    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => true);
  });

  Future<SignupMfaSetupCubit> makeCubit() async {
    final cubit = SignupMfaSetupCubit(mockRepository, mockPasskeyService);
    // Let the constructor's initial load settle.
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('loads the factor list on creation', () async {
    final cubit = await makeCubit();

    expect(cubit.state, isA<MfaSetupMethodList>());
    expect((cubit.state as MfaSetupMethodList).factors, smsEnrolled);
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

  test('setting up totp with a factor already enrolled goes straight to the QR step', () async {
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenAnswer((_) async => totpBegin);

    await cubit.setUpMethod(MfaMethod.totp);

    expect(cubit.state, isA<MfaSetupTotp>());
    expect((cubit.state as MfaSetupTotp).totp.factorId, 'factor-totp');
    await cubit.close();
  });

  test('a factorless user is bounced to the email proof first', () async {
    when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenThrow(mfaError('MFA_ENROL_EMAIL_PROOF_REQUIRED'));
    when(() => mockRepository.sendEmailProof())
        .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));

    await cubit.setUpMethod(MfaMethod.totp);

    final state = cubit.state;
    expect(state, isA<MfaSetupEmailProof>());
    expect((state as MfaSetupEmailProof).pendingMethod, MfaMethod.totp);
    expect(state.nextSendAfterSeconds, 30);
    await cubit.close();
  });

  test('verifying the email proof continues into the pending method', () async {
    when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenThrow(mfaError('MFA_ENROL_EMAIL_PROOF_REQUIRED'));
    when(() => mockRepository.sendEmailProof())
        .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
    await cubit.setUpMethod(MfaMethod.totp);
    when(() => mockRepository.verifyEmailProof(code: '123456')).thenAnswer((_) async {});
    when(() => mockRepository.beginTotp()).thenAnswer((_) async => totpBegin);

    final result = await cubit.verifyEmailProofCode('123456');

    expect(result, TwoFactorAuthResult.success);
    expect(cubit.state, isA<MfaSetupTotp>());
    await cubit.close();
  });

  test('activating totp refreshes the list on success', () async {
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenAnswer((_) async => totpBegin);
    await cubit.setUpMethod(MfaMethod.totp);
    when(() => mockRepository.activateTotp(factorId: 'factor-totp', code: '111111')).thenAnswer(
        (_) async => MfaFactorModel(id: 'factor-totp', type: MfaMethod.totp, status: MfaFactorStatus.active));

    final result = await cubit.activateTotpCode('111111');

    expect(result, TwoFactorAuthResult.success);
    expect(cubit.state, isA<MfaSetupMethodList>());
    await cubit.close();
  });

  test('a wrong totp activation code retries inline', () async {
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenAnswer((_) async => totpBegin);
    await cubit.setUpMethod(MfaMethod.totp);
    when(() => mockRepository.activateTotp(factorId: 'factor-totp', code: '000000'))
        .thenThrow(mfaError('MFA_TOTP_INVALID_CODE'));

    final result = await cubit.activateTotpCode('000000');

    expect(result, TwoFactorAuthResult.wrongCode);
    expect(cubit.state, isA<MfaSetupTotp>());
    await cubit.close();
  });

  test('setting up sms shows the code entry with hint and wait', () async {
    when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
    final cubit = await makeCubit();
    when(() => mockRepository.enrolSms()).thenAnswer(
        (_) async => MfaEnrolledSmsFactorModel(id: 'factor-sms', hint: '•••• 3813', nextSendAfterSeconds: 60));

    await cubit.setUpMethod(MfaMethod.sms);

    final state = cubit.state;
    expect(state, isA<MfaSetupSmsVerify>());
    expect((state as MfaSetupSmsVerify).factorId, 'factor-sms');
    expect(state.nextSendAfterSeconds, 60);
    await cubit.close();
  });

  test('an exhausted sms code steers to resend', () async {
    when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
    final cubit = await makeCubit();
    when(() => mockRepository.enrolSms()).thenAnswer(
        (_) async => MfaEnrolledSmsFactorModel(id: 'factor-sms', hint: '•••• 3813', nextSendAfterSeconds: 60));
    await cubit.setUpMethod(MfaMethod.sms);
    when(() => mockRepository.verifySms(factorId: 'factor-sms', code: '000000'))
        .thenThrow(mfaError('MFA_CHALLENGE_EXHAUSTED'));

    final result = await cubit.verifySmsCode('000000');

    expect(result, TwoFactorAuthResult.codeExhausted);
    expect(cubit.state, isA<MfaSetupSmsVerify>());
    await cubit.close();
  });

  test('a throttled sms resend updates the wait instead of erroring', () async {
    when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
    final cubit = await makeCubit();
    when(() => mockRepository.enrolSms()).thenAnswer(
        (_) async => MfaEnrolledSmsFactorModel(id: 'factor-sms', hint: '•••• 3813', nextSendAfterSeconds: 60));
    await cubit.setUpMethod(MfaMethod.sms);
    when(() => mockRepository.enrolSms()).thenThrow(mfaError('MFA_CHALLENGE_TOO_SOON', retryAfterSeconds: 42));

    await cubit.resendSmsCode();

    final state = cubit.state;
    expect(state, isA<MfaSetupSmsVerify>());
    expect((state as MfaSetupSmsVerify).nextSendAfterSeconds, 42);
    expect(cubit.state.flow.isError, isFalse);
    await cubit.close();
  });

  test('a step-up demand is rethrown with the list left calm', () async {
    final cubit = await makeCubit();
    when(() => mockRepository.beginTotp()).thenThrow(mfaError('MFA_STEP_UP_REQUIRED'));

    await expectLater(cubit.setUpMethod(MfaMethod.totp), throwsA(isA<RMApiError>()));

    expect(cubit.state, isA<MfaSetupMethodList>());
    expect(cubit.state.flow.isError, isFalse);
    expect((cubit.state as MfaSetupMethodList).factors, smsEnrolled);
    await cubit.close();
  });

  group('passkey enrolment', () {
    final creationOptions = <String, dynamic>{
      'rp': {'id': 'e-flux.dashboard.road.io'},
      'challenge': 'Y2hhbGxlbmdl',
    };
    final attestationResponse = <String, dynamic>{
      'id': 'credential-1',
      'response': {'attestationObject': 'b2JqZWN0'},
    };
    final passkeyEnrolled = MfaFactorsModel(factors: [
      MfaFactorModel(id: 'factor-passkey', type: MfaMethod.passkey, status: MfaFactorStatus.active),
    ], permittedMethods: [
      MfaMethod.passkey,
      MfaMethod.totp,
      MfaMethod.sms
    ], mode: MfaMode.encourage);

    test('device capability is resolved before the first listing lands', () async {
      final cubit = await makeCubit();

      expect(cubit.passkeySupported, isTrue);
      await cubit.close();
    });

    test('an unanswerable capability check reads as unsupported', () async {
      when(() => mockPasskeyService.isSupported()).thenThrow(Exception('platform down'));

      final cubit = await makeCubit();

      expect(cubit.passkeySupported, isFalse);
      expect(cubit.state, isA<MfaSetupMethodList>());
      await cubit.close();
    });

    test('happy path: register, ceremony, verify, refreshed list', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse)).thenAnswer(
          (_) async => MfaFactorModel(id: 'factor-passkey', type: MfaMethod.passkey, status: MfaFactorStatus.active));
      when(() => mockRepository.getFactors()).thenAnswer((_) async => passkeyEnrolled);

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, passkeyEnrolled);
      expect(cubit.state.flow.isError, isFalse);
      verify(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse)).called(1);
      await cubit.close();
    });

    test('a dismissed OS sheet returns to the list silently', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      expect((cubit.state as MfaSetupMethodList).factors, smsEnrolled);
      verifyNever(() => mockRepository.verifyPasskeyRegistration(
          response: any(named: 'response'), label: any(named: 'label')));
      await cubit.close();
    });

    test('a device that already holds the passkey surfaces the already-on-device error', () async {
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

    test('an integrity failure surfaces the localized creation error', () async {
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.securityError));

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isTrue);
      expect(cubit.state.flow.error.isPasskeyCreationFailed, isTrue);
      await cubit.close();
    });

    test('a factorless user is bounced to the email proof first', () async {
      when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenThrow(mfaError('MFA_ENROL_EMAIL_PROOF_REQUIRED'));
      when(() => mockRepository.sendEmailProof())
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));

      await cubit.setUpMethod(MfaMethod.passkey);

      final state = cubit.state;
      expect(state, isA<MfaSetupEmailProof>());
      expect((state as MfaSetupEmailProof).pendingMethod, MfaMethod.passkey);
      await cubit.close();
    });

    test('verifying the email proof continues into the passkey ceremony', () async {
      when(() => mockRepository.getFactors()).thenAnswer((_) async => factorless);
      final cubit = await makeCubit();
      when(() => mockRepository.registerPasskey()).thenThrow(mfaError('MFA_ENROL_EMAIL_PROOF_REQUIRED'));
      when(() => mockRepository.sendEmailProof())
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await cubit.setUpMethod(MfaMethod.passkey);
      when(() => mockRepository.verifyEmailProof(code: '123456')).thenAnswer((_) async {});
      when(() => mockRepository.registerPasskey()).thenAnswer((_) async => creationOptions);
      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockRepository.verifyPasskeyRegistration(response: attestationResponse)).thenAnswer(
          (_) async => MfaFactorModel(id: 'factor-passkey', type: MfaMethod.passkey, status: MfaFactorStatus.active));
      when(() => mockRepository.getFactors()).thenAnswer((_) async => passkeyEnrolled);

      final result = await cubit.verifyEmailProofCode('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(cubit.state, isA<MfaSetupMethodList>());
      expect((cubit.state as MfaSetupMethodList).factors, passkeyEnrolled);
      await cubit.close();
    });

    test('an unsupported device never starts the ceremony', () async {
      when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);
      final cubit = await makeCubit();

      await cubit.setUpMethod(MfaMethod.passkey);

      expect(cubit.state, isA<MfaSetupMethodList>());
      expect(cubit.state.flow.isError, isFalse);
      verifyNever(() => mockRepository.registerPasskey());
      await cubit.close();
    });
  });
}
