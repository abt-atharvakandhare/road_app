import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_factors_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/step_up_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/step_up/step_up_cubit.dart';

class MockMfaFactorsRepository extends Mock implements MfaFactorsRepository {}

class MockStepUpRepository extends Mock implements StepUpRepository {}

class MockPasskeyService extends Mock implements PasskeyService {}

RMApiError mfaError(String code, {int? retryAfterSeconds}) =>
    RMApiError(cause: 'mfa error', details: [ErrorDetails(code: code, retryAfterSeconds: retryAfterSeconds)]);

MfaFactorsModel listingOf(List<MfaFactorModel> factors) =>
    MfaFactorsModel(factors: factors, permittedMethods: [MfaMethod.totp, MfaMethod.sms], mode: MfaMode.encourage);

void main() {
  late MockMfaFactorsRepository mockFactorsRepository;
  late MockStepUpRepository mockStepUpRepository;
  late MockPasskeyService mockPasskeyService;

  final totpFactor = MfaFactorModel(id: 'factor-totp', type: MfaMethod.totp, status: MfaFactorStatus.active);
  final smsFactor =
      MfaFactorModel(id: 'factor-sms', type: MfaMethod.sms, status: MfaFactorStatus.active, hint: '•••• 3813');
  final passkeyFactor = MfaFactorModel(id: 'factor-pk', type: MfaMethod.passkey, status: MfaFactorStatus.active);

  setUpAll(() {
    registerFallbackValue(MfaMethod.sms);
  });

  setUp(() {
    mockFactorsRepository = MockMfaFactorsRepository();
    mockStepUpRepository = MockStepUpRepository();
    mockPasskeyService = MockPasskeyService();
    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);
  });

  Future<StepUpCubit> makeCubit() async {
    final cubit = StepUpCubit(mockFactorsRepository, mockStepUpRepository, mockPasskeyService);
    // Let the constructor's initial load settle.
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  test('a single totp factor skips the picker straight to code entry, without arming', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor]));

    final cubit = await makeCubit();

    final state = cubit.state;
    expect(state, isA<StepUpCodeEntry>());
    expect((state as StepUpCodeEntry).method, MfaMethod.totp);
    expect(state.canPickAnother, isFalse);
    verifyNever(() => mockStepUpRepository.challenge(any()));
    await cubit.close();
  });

  test('a correct totp code verifies', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor]));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.verifyTotp(code: '111111')).thenAnswer((_) async {});

    final result = await cubit.verifyCode('111111');

    expect(result, TwoFactorAuthResult.success);
    expect(cubit.state.flow.isError, isFalse);
    await cubit.close();
  });

  test('a single sms factor arms the challenge and enters the code step with hint and wait', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([smsFactor]));
    when(() => mockStepUpRepository.challenge(MfaMethod.sms)).thenAnswer(
        (_) async => MfaChallengeResponseModel(type: MfaMethod.sms, hint: '•••• 3813', nextSendAfterSeconds: 60));

    final cubit = await makeCubit();

    final state = cubit.state;
    expect(state, isA<StepUpCodeEntry>());
    expect((state as StepUpCodeEntry).method, MfaMethod.sms);
    expect(state.hint, '•••• 3813');
    expect(state.nextSendAfterSeconds, 60);
    await cubit.close();
  });

  test('a correct sms code verifies', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([smsFactor]));
    when(() => mockStepUpRepository.challenge(MfaMethod.sms))
        .thenAnswer((_) async => MfaChallengeResponseModel(type: MfaMethod.sms, hint: '•••• 3813'));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.verifySms(code: '222222')).thenAnswer((_) async {});

    final result = await cubit.verifyCode('222222');

    expect(result, TwoFactorAuthResult.success);
    expect(cubit.state.flow.isError, isFalse);
    await cubit.close();
  });

  test('a throttled first arm still enters code entry with the wait and the listing hint', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([smsFactor]));
    when(() => mockStepUpRepository.challenge(MfaMethod.sms))
        .thenThrow(mfaError('MFA_CHALLENGE_LIMIT_REACHED', retryAfterSeconds: 229));

    final cubit = await makeCubit();

    final state = cubit.state;
    expect(state, isA<StepUpCodeEntry>());
    expect((state as StepUpCodeEntry).method, MfaMethod.sms);
    expect(state.hint, '•••• 3813');
    expect(state.nextSendAfterSeconds, 229);
    expect(state.flow.isError, isFalse);
    await cubit.close();
  });

  test('a wrong code retries inline', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor]));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.verifyTotp(code: '000000'))
        .thenThrow(mfaError('MFA_CHALLENGE_INVALID_CODE'));

    final result = await cubit.verifyCode('000000');

    expect(result, TwoFactorAuthResult.wrongCode);
    expect(cubit.state, isA<StepUpCodeEntry>());
    expect(cubit.state.flow.isError, isFalse);
    await cubit.close();
  });

  test('an exhausted code steers to resend without re-arming', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([smsFactor]));
    when(() => mockStepUpRepository.challenge(MfaMethod.sms))
        .thenAnswer((_) async => MfaChallengeResponseModel(type: MfaMethod.sms, hint: '•••• 3813'));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.verifySms(code: '000000')).thenThrow(mfaError('MFA_CHALLENGE_EXHAUSTED'));

    final result = await cubit.verifyCode('000000');

    expect(result, TwoFactorAuthResult.codeExhausted);
    expect(cubit.state, isA<StepUpCodeEntry>());
    // The initial arm only — an exhausted code must never trigger a re-arm.
    verify(() => mockStepUpRepository.challenge(MfaMethod.sms)).called(1);
    await cubit.close();
  });

  test('a guess limit maps to a rate-limited result with the exact wait', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor]));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.verifyTotp(code: '000000'))
        .thenThrow(mfaError('MFA_GUESS_LIMIT_REACHED', retryAfterSeconds: 137));

    final result = await cubit.verifyCode('000000');

    expect(result, isA<TwoFactorAuthRateLimited>());
    expect((result as TwoFactorAuthRateLimited).retryAfterSeconds, 137);
    expect(cubit.state.flow.isError, isFalse);
    await cubit.close();
  });

  test('a user-initiated resend re-arms and updates the wait', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([smsFactor]));
    when(() => mockStepUpRepository.challenge(MfaMethod.sms)).thenAnswer(
        (_) async => MfaChallengeResponseModel(type: MfaMethod.sms, hint: '•••• 3813', nextSendAfterSeconds: 60));
    final cubit = await makeCubit();
    when(() => mockStepUpRepository.challenge(MfaMethod.sms))
        .thenThrow(mfaError('MFA_CHALLENGE_TOO_SOON', retryAfterSeconds: 42));

    await cubit.resendCode();

    final state = cubit.state;
    expect(state, isA<StepUpCodeEntry>());
    expect((state as StepUpCodeEntry).nextSendAfterSeconds, 42);
    expect(state.flow.isError, isFalse);
    await cubit.close();
  });

  test('several usable factors show the picker', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor, smsFactor]));

    final cubit = await makeCubit();

    final state = cubit.state;
    expect(state, isA<StepUpMethodPick>());
    expect((state as StepUpMethodPick).factors, [totpFactor, smsFactor]);
    await cubit.close();
  });

  test('picking totp from the picker allows going back to it', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([totpFactor, smsFactor]));
    final cubit = await makeCubit();

    await cubit.pickMethod(MfaMethod.totp);

    expect(cubit.state, isA<StepUpCodeEntry>());
    expect((cubit.state as StepUpCodeEntry).canPickAnother, isTrue);

    cubit.backToPicker();
    expect(cubit.state, isA<StepUpMethodPick>());
    await cubit.close();
  });

  test('a passkey-only factor set dead-ends', () async {
    when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));

    final cubit = await makeCubit();

    expect(cubit.state, isA<StepUpDeadEnd>());
    await cubit.close();
  });

  test('a failed listing load surfaces as an error on the picker', () async {
    when(() => mockFactorsRepository.getFactors()).thenThrow(RMApiError(cause: 'network'));

    final cubit = await makeCubit();

    expect(cubit.state, isA<StepUpMethodPick>());
    expect(cubit.state.flow.isError, isTrue);
    await cubit.close();
  });

  group('passkey step-up', () {
    final options = <String, dynamic>{'challenge': 'Y2hhbGxlbmdl', 'rpId': 'e-flux.dashboard.road.io'};
    final assertionResponse = <String, dynamic>{'id': 'a25vd24tY3JlZA', 'type': 'public-key'};

    void stubPasskeySupported() =>
        when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => true);

    void stubArm() => when(() => mockStepUpRepository.challenge(MfaMethod.passkey)).thenAnswer(
        (_) async => MfaChallengeResponseModel(
            type: MfaMethod.passkey, ceremonyId: 'ceremony-1', options: options));

    test('a single passkey factor on a supporting device goes to the passkey step, without arming',
        () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));

      final cubit = await makeCubit();

      final state = cubit.state;
      expect(state, isA<StepUpPasskey>());
      expect((state as StepUpPasskey).canPickAnother, isFalse);
      // Arming is per attempt, driven by the sheet — landing here arms nothing.
      verifyNever(() => mockStepUpRepository.challenge(any()));
      await cubit.close();
    });

    test('a passkey factor beside a code factor shows the picker and is pickable', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors())
          .thenAnswer((_) async => listingOf([passkeyFactor, totpFactor]));

      final cubit = await makeCubit();
      expect(cubit.state, isA<StepUpMethodPick>());

      await cubit.pickMethod(MfaMethod.passkey);

      expect(cubit.state, isA<StepUpPasskey>());
      expect((cubit.state as StepUpPasskey).canPickAnother, isTrue);
      await cubit.close();
    });

    test('a full ceremony arms, asserts and verifies', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));
      final cubit = await makeCubit();
      stubArm();
      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockStepUpRepository.verifyPasskey(ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenAnswer((_) async {});

      final result = await cubit.verifyPasskey();

      expect(result, TwoFactorAuthResult.success);
      expect(cubit.state.flow.isError, isFalse);
      await cubit.close();
    });

    test('a dismissed OS sheet with no picker stays on the step; a retry re-arms', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));
      final cubit = await makeCubit();
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      final cancelled = await cubit.verifyPasskey();

      expect(cancelled, TwoFactorAuthResult.error);
      expect(cubit.state, isA<StepUpPasskey>());
      expect(cubit.state.flow.isError, isFalse);

      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockStepUpRepository.verifyPasskey(ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenAnswer((_) async {});

      final retried = await cubit.verifyPasskey();

      expect(retried, TwoFactorAuthResult.success);
      // Ceremony ids are single-use — every attempt must re-arm.
      verify(() => mockStepUpRepository.challenge(MfaMethod.passkey)).called(2);
      await cubit.close();
    });

    test('a dismissed OS sheet returns to the picker when one exists', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors())
          .thenAnswer((_) async => listingOf([passkeyFactor, totpFactor]));
      final cubit = await makeCubit();
      await cubit.pickMethod(MfaMethod.passkey);
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      await cubit.verifyPasskey();

      expect(cubit.state, isA<StepUpMethodPick>());
      await cubit.close();
    });

    test('no credential on this device dead-ends the step (step-up has no recovery path)', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));
      final cubit = await makeCubit();
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      final result = await cubit.verifyPasskey();

      expect(result, TwoFactorAuthResult.error);
      final state = cubit.state;
      expect(state, isA<StepUpPasskey>());
      expect((state as StepUpPasskey).noCredential, isTrue);
      expect(state.flow.isError, isFalse);
      await cubit.close();
    });

    test('a security error surfaces as an error dialog on the step', () async {
      stubPasskeySupported();
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));
      final cubit = await makeCubit();
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.securityError, 'domain not associated'));

      final result = await cubit.verifyPasskey();

      expect(result, TwoFactorAuthResult.error);
      expect(cubit.state.flow.isError, isTrue);
      // Coded so the error dialog can localize it at the display seam.
      expect(cubit.state.flow.error.isPasskeyVerificationFailed, isTrue);
      await cubit.close();
    });

    test('an unsupporting device still dead-ends a passkey-only factor set', () async {
      when(() => mockFactorsRepository.getFactors()).thenAnswer((_) async => listingOf([passkeyFactor]));

      final cubit = await makeCubit();

      expect(cubit.state, isA<StepUpDeadEnd>());
      await cubit.close();
    });
  });
}
