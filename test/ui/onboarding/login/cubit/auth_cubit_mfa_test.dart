import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/account/account_self_response_model.dart';
import 'package:road_mobile/data/model/login/login_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_challenge_response_model.dart';
import 'package:road_mobile/data/model/login/mfa_code_sent_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_email_proof_verify_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_sms_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_enrol_totp_begin_model.dart';
import 'package:road_mobile/data/model/login/mfa_method.dart';
import 'package:road_mobile/data/model/login/mfa_session_model.dart';
import 'package:road_mobile/data/model/mobile_features/mobile_user_summary_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/api_error_details.dart';
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart';
import 'package:road_mobile/services/network/auth_session_renewer.dart';
import 'package:road_mobile/services/network/auth_storage.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/services/passkey/passkey_service.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_repository.dart';
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockMfaRepository extends Mock implements MfaRepository {}

class MockPasskeyService extends Mock implements PasskeyService {}

class MockVerificationRepository extends Mock implements VerificationRepository {}

class MockAuthStorage extends Mock implements AuthStorage {}

class MockAnalytics extends Mock implements Analytics {}

class MockMixpanelService extends Mock implements MixpanelService {}

class MockSessionRenewalTokenStorage extends Mock implements SessionRenewalTokenStorage {}

class MockAuthSessionRenewer extends Mock implements AuthSessionRenewer {}

RMApiError mfaError(String code, {int? retryAfterSeconds}) =>
    RMApiError(cause: 'mfa error', details: [ErrorDetails(code: code, retryAfterSeconds: retryAfterSeconds)]);

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;
  late MockMfaRepository mockMfaRepository;
  late MockPasskeyService mockPasskeyService;
  late SharedPreferences mockPrefs;

  const testEmail = 'mfa-test@example.com';
  const testPassword = 'password123';
  final testProvider = ProviderResponseModel(id: 'test-provider');
  final testSession = MfaSessionModel(token: 'session-token', deviceToken: 'device-token');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    F.appFlavor = Flavor.eflux;
    Defines.intercomEnabled = false;
    registerFallbackValue(MfaMethod.sms);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('maido.io/intercom'), (MethodCall methodCall) async {
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
    mockAuthRepository = MockAuthRepository();
    mockMfaRepository = MockMfaRepository();
    mockPasskeyService = MockPasskeyService();
    when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => false);
    final mockAuthStorage = MockAuthStorage();
    final mockRenewalStorage = MockSessionRenewalTokenStorage();
    final mockMixpanelService = MockMixpanelService();

    await getIt.reset();
    getIt.registerSingleton<DebugControlsRepo>(DebugControlsRepo(mockPrefs));

    when(() => mockRenewalStorage.isAvailable()).thenAnswer((_) async => false);
    when(() => mockRenewalStorage.canStore()).thenAnswer((_) async => false);
    when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => null);
    when(() => mockAuthStorage.storeAuthToken(any())).thenAnswer((_) async {});
    when(() => mockAuthStorage.storeDeviceToken(any())).thenAnswer((_) async {});
    when(() => mockAuthStorage.deleteAuthToken()).thenAnswer((_) async {});
    when(() => mockAuthStorage.storeProviderId(any())).thenAnswer((_) async {});
    when(() => mockMixpanelService.identify(any(), email: any(named: 'email'))).thenReturn(null);
    when(() => mockMixpanelService.flush()).thenReturn(null);

    when(() => mockAuthRepository.getProvider(any())).thenAnswer((_) async => testProvider);
    when(() => mockAuthRepository.getMyAccount()).thenAnswer(
      (_) async => AccountSelfModel('test-user-id', null, null, null),
    );
    when(() => mockAuthRepository.getMyProfile()).thenAnswer(
      (_) async => ProfileResponseModel(
        ProfileModel('test-user-id', 'Test User', testEmail, null, null, null),
      ),
    );
    when(() => mockAuthRepository.getMobileFeatures()).thenAnswer((_) async => MobileUserSummaryModel());

    authCubit = AuthCubit(
      mockAuthRepository,
      mockMfaRepository,
      mockPasskeyService,
      MockVerificationRepository(),
      mockAuthStorage,
      mockPrefs,
      MockAnalytics(),
      mockMixpanelService,
      mockRenewalStorage,
      MockAuthSessionRenewer(),
      AuthLifecycleBus(),
    );
    // Wait for moveToInitialAppState to finish. It emits LoggedOut twice —
    // bare, then with the provider — so wait for the provider-carrying emit:
    // deterministic where a fixed delay is not, and it guarantees the second
    // emit can't land mid-test and clobber MFA state.
    await expectLater(
      authCubit.stream,
      emitsThrough(predicate<AuthState>((state) => state is LoggedOut && state.providerModel != null)),
    );
  });

  tearDown(() async {
    await authCubit.close();
    await getIt.reset();
  });

  void stubLoginResponse(LoginResponseModel response) {
    when(() => mockAuthRepository.login(any(), password: any(named: 'password')))
        .thenAnswer((_) async => response);
  }

  TwoFactorAuth? currentTwoFactorAuth() => switch (authCubit.state) {
        LoggedOut(:final twoFactorAuth) => twoFactorAuth,
        _ => null,
      };

  group('performLogin decision-engine outcomes', () {
    test('single usable method (totp) goes straight to code entry, no arm call', () async {
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1', methods: [MfaMethod.totp], preferred: MfaMethod.totp)));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());
      verifyNever(() => mockMfaRepository.armChallenge(
          pendingId: any(named: 'pendingId'), method: any(named: 'method')));
    });

    test('multiple usable methods show the method picker', () async {
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1',
              methods: [MfaMethod.totp, MfaMethod.sms],
              preferred: MfaMethod.totp)));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthMethodPicker>());
    });

    test('passkey-only challenge surfaces an error instead of a dead end', () async {
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1', methods: [MfaMethod.passkey], preferred: MfaMethod.passkey)));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isNull);
      expect(authCubit.state.flow.isError, isTrue);
    });

    test('mfaEnrolment outcome shows the enrolment intro', () async {
      stubLoginResponse(LoginResponseModel(
          mfaEnrolment: MfaEnrolmentModel(
              enrolId: 'enrol-1', mode: MfaMode.encourage, permittedMethods: [MfaMethod.totp])));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolIntro>());
    });

    test('mfaVerifyEmail outcome sends the code and shows the entry step', () async {
      when(() => mockMfaRepository.sendVerifyEmail(pendingId: any(named: 'pendingId')))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      stubLoginResponse(LoginResponseModel(mfaVerifyEmail: MfaVerifyEmailModel(pendingId: 'pending-ve')));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthVerifyEmail>());
      verify(() => mockMfaRepository.sendVerifyEmail(pendingId: 'pending-ve')).called(1);
    });

    test('verify-email code completes the step-up', () async {
      when(() => mockMfaRepository.sendVerifyEmail(pendingId: 'pending-ve'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      stubLoginResponse(LoginResponseModel(mfaVerifyEmail: MfaVerifyEmailModel(pendingId: 'pending-ve')));
      await authCubit.performLogin(testEmail, testPassword);
      when(() => mockMfaRepository.verifyEmailCode(pendingId: 'pending-ve', code: '123456'))
          .thenAnswer((_) async => testSession);

      final result = await authCubit.verifyPendingMfaCode('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(authCubit.state, isA<LoggedIn>());
    });

    test('APP_UPGRADE_REQUIRED login rejection surfaces as an error carrying the code', () async {
      // The dialog resolves this flag to the localized "update the app"
      // message via RMApiError.causeString.
      when(() => mockAuthRepository.login(any(), password: any(named: 'password')))
          .thenThrow(RMApiError(cause: 'Unauthorized', details: [ErrorDetails(code: 'APP_UPGRADE_REQUIRED')]));

      final didLogin = await authCubit.performLogin(testEmail, testPassword);

      expect(didLogin, isFalse);
      expect(authCubit.state.flow.isError, isTrue);
      expect(authCubit.state.flow.error.isAppUpgradeRequired, isTrue);
    });

    test('legacy mfaToken outcome still takes the legacy branch', () async {
      stubLoginResponse(LoginResponseModel(mfaRequired: true, mfaMethod: 'otp', mfaToken: 'legacy-token'));

      await authCubit.performLogin(testEmail, testPassword);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthOtp>());
    });
  });

  group('completeSignupSession', () {
    test('establishes the session from the signup-issued token without a login call', () async {
      final didLogin =
          await authCubit.completeSignupSession(token: 'signup-token', deviceToken: 'device-1', email: testEmail);

      expect(didLogin, isTrue);
      expect(authCubit.state, isA<LoggedIn>());
      verifyNever(() => mockAuthRepository.login(any(), password: any(named: 'password')));
    });
  });

  group('verify flow', () {
    Future<void> loginToPendingTotp({bool multipleMethods = false}) async {
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1',
              methods: [MfaMethod.totp, if (multipleMethods) MfaMethod.sms],
              preferred: MfaMethod.totp)));
      await authCubit.performLogin(testEmail, testPassword);
      if (multipleMethods) {
        await authCubit.selectMfaMethod(MfaMethod.totp);
      }
    }

    Future<void> loginToPendingSms({int? nextSendAfterSeconds}) async {
      when(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.sms)).thenAnswer(
          (_) async => MfaChallengeResponseModel(
              type: MfaMethod.sms, hint: '•••• 6789', nextSendAfterSeconds: nextSendAfterSeconds));
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1',
              methods: [MfaMethod.totp, MfaMethod.sms],
              preferred: MfaMethod.sms)));
      await authCubit.performLogin(testEmail, testPassword);
      await authCubit.selectMfaMethod(MfaMethod.sms);
    }

    test('selecting sms arms the challenge and shows the hint and resend wait', () async {
      await loginToPendingSms(nextSendAfterSeconds: 60);

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthPendingSms>());
      expect((tfa as TwoFactorAuthPendingSms).hint, '•••• 6789');
      expect(tfa.nextSendAfterSeconds, 60);
    });

    test('throttled sms resend updates the wait on the step instead of erroring', () async {
      await loginToPendingSms(nextSendAfterSeconds: 60);
      when(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.sms))
          .thenThrow(mfaError('MFA_CHALLENGE_TOO_SOON', retryAfterSeconds: 42));

      await authCubit.resendPendingSmsCode();

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthPendingSms>());
      expect((tfa as TwoFactorAuthPendingSms).nextSendAfterSeconds, 42);
      expect(tfa.hint, '•••• 6789');
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('send budget spent on the first sms arm still shows the entry step with the wait', () async {
      // Budgets are per user, so a fresh sign-in can arrive already spent —
      // and a code from an earlier send may still verify.
      when(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.sms))
          .thenThrow(mfaError('MFA_CHALLENGE_LIMIT_REACHED', retryAfterSeconds: 229));
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1', methods: [MfaMethod.sms], preferred: MfaMethod.sms)));

      await authCubit.performLogin(testEmail, testPassword);

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthPendingSms>());
      expect((tfa as TwoFactorAuthPendingSms).nextSendAfterSeconds, 229);
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('correct totp code completes the sign-in', () async {
      await loginToPendingTotp();
      when(() => mockMfaRepository.verifyTotp(pendingId: 'pending-1', code: '123456'))
          .thenAnswer((_) async => testSession);

      final result = await authCubit.verifyPendingMfaCode('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(authCubit.state, isA<LoggedIn>());
    });

    test('wrong code keeps the pending state for retry', () async {
      await loginToPendingTotp();
      when(() => mockMfaRepository.verifyTotp(pendingId: 'pending-1', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_INVALID_CODE'));

      final result = await authCubit.verifyPendingMfaCode('000000');

      expect(result, TwoFactorAuthResult.wrongCode);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('guess limit returns the wait and keeps the step', () async {
      await loginToPendingTotp();
      when(() => mockMfaRepository.verifyTotp(pendingId: 'pending-1', code: '000000'))
          .thenThrow(mfaError('MFA_GUESS_LIMIT_REACHED', retryAfterSeconds: 229));

      final result = await authCubit.verifyPendingMfaCode('000000');

      expect(result, isA<TwoFactorAuthRateLimited>());
      expect((result as TwoFactorAuthRateLimited).retryAfterSeconds, 229);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('exhausted sms code returns codeExhausted and keeps the step', () async {
      await loginToPendingSms();
      when(() => mockMfaRepository.verifySms(pendingId: 'pending-1', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_EXHAUSTED'));

      final result = await authCubit.verifyPendingMfaCode('000000');

      expect(result, TwoFactorAuthResult.codeExhausted);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingSms>());
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('expired pending handle resets to the credentials form', () async {
      await loginToPendingTotp();
      when(() => mockMfaRepository.verifyTotp(pendingId: 'pending-1', code: '123456'))
          .thenThrow(mfaError('MFA_PENDING_LOGIN_NOT_FOUND'));

      final result = await authCubit.verifyPendingMfaCode('123456');

      expect(result, TwoFactorAuthResult.error);
      expect(currentTwoFactorAuth(), isNull);
      expect(authCubit.state.flow.isError, isTrue);
    });

    test('resending sms keeps the previous hint when the re-arm returns none', () async {
      final armResponses = [
        MfaChallengeResponseModel(type: MfaMethod.sms, hint: '•••• 6789'),
        MfaChallengeResponseModel(type: MfaMethod.sms),
      ];
      when(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.sms))
          .thenAnswer((_) async => armResponses.removeAt(0));
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1', methods: [MfaMethod.sms], preferred: MfaMethod.sms)));
      await authCubit.performLogin(testEmail, testPassword);

      await authCubit.resendPendingSmsCode();

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthPendingSms>());
      expect((tfa as TwoFactorAuthPendingSms).hint, '•••• 6789');
      verify(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.sms))
          .called(2);
    });

    test('backToMfaMethodPicker returns from a factor step to the picker', () async {
      await loginToPendingTotp(multipleMethods: true);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());

      authCubit.backToMfaMethodPicker();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthMethodPicker>());
    });

    test('useRecoveryCode moves to recovery entry and back restores the factor step', () async {
      await loginToPendingTotp();

      authCubit.useRecoveryCode();
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingRecoveryCode>());

      authCubit.backFromRecoveryCode();
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());
    });

    test('recovery code verify completes the sign-in', () async {
      await loginToPendingTotp();
      authCubit.useRecoveryCode();
      when(() => mockMfaRepository.verifyRecoveryCode(pendingId: 'pending-1', code: 'RECOVERY-1'))
          .thenAnswer((_) async => testSession);

      final result = await authCubit.verifyPendingMfaCode('RECOVERY-1');

      expect(result, TwoFactorAuthResult.success);
      expect(authCubit.state, isA<LoggedIn>());
    });
  });

  group('enrolment flow', () {
    Future<void> loginToEnrolIntro({MfaMode mode = MfaMode.encourage}) async {
      stubLoginResponse(LoginResponseModel(
          mfaEnrolment: MfaEnrolmentModel(
              enrolId: 'enrol-1', mode: mode, permittedMethods: [MfaMethod.totp, MfaMethod.sms])));
      await authCubit.performLogin(testEmail, testPassword);
    }

    test('continueEnrolment sends the email proof and shows its entry', () async {
      await loginToEnrolIntro();
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));

      await authCubit.continueEnrolment();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolEmailProof>());
      verify(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1')).called(1);
    });

    test('email proof verify with multiple methods shows the enrol picker', () async {
      await loginToEnrolIntro();
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await authCubit.continueEnrolment();
      when(() => mockMfaRepository.verifyEnrolmentEmailProof(enrolId: 'enrol-1', code: '123456'))
          .thenAnswer((_) async =>
              MfaEnrolEmailProofVerifyModel(permittedMethods: [MfaMethod.totp, MfaMethod.sms]));

      final result = await authCubit.verifyEnrolmentEmailProof('123456');

      expect(result, TwoFactorAuthResult.success);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolMethodPicker>());
    });

    /// Walks intro → email proof → verified proof, landing on the method picker.
    Future<void> walkToEnrolMethodPicker({MfaMode mode = MfaMode.encourage}) async {
      await loginToEnrolIntro(mode: mode);
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await authCubit.continueEnrolment();
      when(() => mockMfaRepository.verifyEnrolmentEmailProof(enrolId: 'enrol-1', code: '123456'))
          .thenAnswer((_) async =>
              MfaEnrolEmailProofVerifyModel(permittedMethods: [MfaMethod.totp, MfaMethod.sms]));
      await authCubit.verifyEnrolmentEmailProof('123456');
    }

    test('wrong email-proof code keeps the proof step for retry', () async {
      await loginToEnrolIntro();
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await authCubit.continueEnrolment();
      when(() => mockMfaRepository.verifyEnrolmentEmailProof(enrolId: 'enrol-1', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_INVALID_CODE'));

      final result = await authCubit.verifyEnrolmentEmailProof('000000');

      expect(result, TwoFactorAuthResult.wrongCode);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolEmailProof>());
    });

    test('sms enrol begin with code-required shows the sms confirmation step', () async {
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginSmsEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolSmsBeginModel(
              kind: 'code-required', factorId: 'factor-1', hint: '•••• 6789'));

      await authCubit.chooseEnrolMethod(MfaMethod.sms);

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthEnrolSms>());
      expect((tfa as TwoFactorAuthEnrolSms).factorId, 'factor-1');
    });

    test('sms enrolment code verify activates the factor and completes the sign-in', () async {
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginSmsEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolSmsBeginModel(
              kind: 'code-required', factorId: 'factor-1', hint: '•••• 6789'));
      await authCubit.chooseEnrolMethod(MfaMethod.sms);
      when(() => mockMfaRepository.verifySmsEnrolment(enrolId: 'enrol-1', factorId: 'factor-1', code: '654321'))
          .thenAnswer((_) async => testSession);

      final result = await authCubit.verifyEnrolmentCode('654321');

      expect(result, TwoFactorAuthResult.success);
      expect(authCubit.state, isA<LoggedIn>());
    });

    test('exhausted sms enrolment code returns codeExhausted and keeps the step', () async {
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginSmsEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolSmsBeginModel(kind: 'code-required', factorId: 'factor-1', hint: '•••• 6789'));
      await authCubit.chooseEnrolMethod(MfaMethod.sms);
      when(() => mockMfaRepository.verifySmsEnrolment(enrolId: 'enrol-1', factorId: 'factor-1', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_EXHAUSTED'));

      final result = await authCubit.verifyEnrolmentCode('000000');

      expect(result, TwoFactorAuthResult.codeExhausted);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolSms>());
    });

    test('wrong sms enrolment code keeps the confirmation step for retry', () async {
      // An already-verified phone no longer short-circuits to a session, so a
      // wrong code here is a live path: it must retry inline, not dead-end.
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginSmsEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolSmsBeginModel(
              kind: 'code-required', factorId: 'factor-1', hint: '•••• 6789'));
      await authCubit.chooseEnrolMethod(MfaMethod.sms);
      when(() => mockMfaRepository.verifySmsEnrolment(enrolId: 'enrol-1', factorId: 'factor-1', code: '000000'))
          .thenThrow(mfaError('MFA_CHALLENGE_INVALID_CODE'));

      final result = await authCubit.verifyEnrolmentCode('000000');

      expect(result, TwoFactorAuthResult.wrongCode);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolSms>());
    });

    test('totp enrolment activation completes the sign-in', () async {
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginTotpEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolTotpBeginModel(factorId: 'factor-totp', otpauthUri: 'otpauth://totp/x', secret: 'SECRET'));
      await authCubit.chooseEnrolMethod(MfaMethod.totp);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolTotp>());
      when(() => mockMfaRepository.activateTotpEnrolment(
          enrolId: 'enrol-1', factorId: 'factor-totp', code: '111111')).thenAnswer((_) async => testSession);

      final result = await authCubit.verifyEnrolmentCode('111111');

      expect(result, TwoFactorAuthResult.success);
      expect(authCubit.state, isA<LoggedIn>());
    });

    test('wrong totp enrolment code keeps the setup step for retry', () async {
      await walkToEnrolMethodPicker();
      when(() => mockMfaRepository.beginTotpEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async =>
          MfaEnrolTotpBeginModel(factorId: 'factor-totp', otpauthUri: 'otpauth://totp/x', secret: 'SECRET'));
      await authCubit.chooseEnrolMethod(MfaMethod.totp);
      when(() => mockMfaRepository.activateTotpEnrolment(
              enrolId: 'enrol-1', factorId: 'factor-totp', code: '000000'))
          .thenThrow(mfaError('MFA_TOTP_INVALID_CODE'));

      final result = await authCubit.verifyEnrolmentCode('000000');

      expect(result, TwoFactorAuthResult.wrongCode);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolTotp>());
    });

    test('skipEnrolment completes the sign-in under encourage', () async {
      await loginToEnrolIntro();
      when(() => mockMfaRepository.skipEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async => testSession);

      final didLogIn = await authCubit.skipEnrolment();

      expect(didLogIn, isTrue);
      expect(authCubit.state, isA<LoggedIn>());
    });

    test('skipEnrolment refuses under enforce without calling the backend', () async {
      await loginToEnrolIntro(mode: MfaMode.enforce);

      final didLogIn = await authCubit.skipEnrolment();

      expect(didLogIn, isFalse);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolIntro>());
      verifyNever(() => mockMfaRepository.skipEnrolment(enrolId: any(named: 'enrolId')));
    });

    test('expired enrolment handle resets to the credentials form', () async {
      await loginToEnrolIntro();
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenThrow(mfaError('MFA_PENDING_ENROLMENT_NOT_FOUND'));

      await authCubit.continueEnrolment();

      expect(currentTwoFactorAuth(), isNull);
      expect(authCubit.state.flow.isError, isTrue);
    });
  });

  group('passkey factor-at-login', () {
    final options = <String, dynamic>{'challenge': 'Y2hhbGxlbmdl', 'rpId': 'e-flux.dashboard.road.io'};
    final assertionResponse = <String, dynamic>{'id': 'a25vd24tY3JlZA', 'type': 'public-key'};

    void stubPasskeySupported() =>
        when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => true);

    void stubArm() => when(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.passkey))
        .thenAnswer((_) async =>
            MfaChallengeResponseModel(type: MfaMethod.passkey, ceremonyId: 'ceremony-1', options: options));

    Future<void> loginToPendingPasskey({List<MfaMethod>? methods, bool? canUseRecoveryCode}) async {
      stubPasskeySupported();
      stubLoginResponse(LoginResponseModel(
          mfaRequired: true,
          mfa: MfaPendingChallengeModel(
              pendingId: 'pending-1',
              methods: methods ?? [MfaMethod.passkey],
              preferred: MfaMethod.passkey,
              canUseRecoveryCode: canUseRecoveryCode)));
      await authCubit.performLogin(testEmail, testPassword);
    }

    test('a passkey-only challenge on a supporting device goes to the passkey step', () async {
      await loginToPendingPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingPasskey>());
      // Arming is per attempt, driven by the widget — landing here arms nothing.
      verifyNever(() => mockMfaRepository.armChallenge(
          pendingId: any(named: 'pendingId'), method: any(named: 'method')));
    });

    test('passkey among several methods shows the picker, and picking it lands on the passkey step',
        () async {
      await loginToPendingPasskey(methods: [MfaMethod.passkey, MfaMethod.totp]);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthMethodPicker>());

      await authCubit.selectMfaMethod(MfaMethod.passkey);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingPasskey>());
    });

    test('a full ceremony arms, asserts and verifies into a session', () async {
      await loginToPendingPasskey();
      stubArm();
      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockMfaRepository.verifyPasskey(
              pendingId: 'pending-1', ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenAnswer((_) async => testSession);

      await authCubit.verifyWithPasskey();

      expect(authCubit.state, isA<LoggedIn>());
    });

    test('a dismissed OS sheet is silent and keeps the passkey step; a retry re-arms', () async {
      await loginToPendingPasskey();
      stubArm();
      when(() => mockPasskeyService.get(options)).thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingPasskey>());
      expect(authCubit.state.flow.isError, isFalse);

      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockMfaRepository.verifyPasskey(
              pendingId: 'pending-1', ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenAnswer((_) async => testSession);

      await authCubit.verifyWithPasskey();

      expect(authCubit.state, isA<LoggedIn>());
      // Ceremony ids are single-use — every attempt must re-arm.
      verify(() => mockMfaRepository.armChallenge(pendingId: 'pending-1', method: MfaMethod.passkey))
          .called(2);
    });

    test('no credential on this device falls back to the single other method', () async {
      await loginToPendingPasskey(methods: [MfaMethod.passkey, MfaMethod.totp]);
      await authCubit.selectMfaMethod(MfaMethod.passkey);
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingTotp>());
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('no credential with several other methods falls back to the picker', () async {
      await loginToPendingPasskey(methods: [MfaMethod.passkey, MfaMethod.totp, MfaMethod.sms]);
      await authCubit.selectMfaMethod(MfaMethod.passkey);
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthMethodPicker>());
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('no credential on a passkey-only account offers the recovery code when held', () async {
      await loginToPendingPasskey(canUseRecoveryCode: true);
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingRecoveryCode>());
    });

    test('no credential with no fallback at all dead-ends on the passkey step', () async {
      await loginToPendingPasskey();
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      await authCubit.verifyWithPasskey();

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthPendingPasskey>());
      expect((tfa as TwoFactorAuthPendingPasskey).noCredential, isTrue);
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('a security error surfaces as an error dialog on the passkey step', () async {
      await loginToPendingPasskey();
      stubArm();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.securityError, 'domain not associated'));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthPendingPasskey>());
      expect(authCubit.state.flow.isError, isTrue);
    });

    test('an expired pending handle during verify resets to the credentials form', () async {
      await loginToPendingPasskey();
      stubArm();
      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockMfaRepository.verifyPasskey(
              pendingId: 'pending-1', ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenThrow(mfaError('MFA_PENDING_LOGIN_NOT_FOUND'));

      await authCubit.verifyWithPasskey();

      expect(currentTwoFactorAuth(), isNull);
      expect(authCubit.state.flow.isError, isTrue);
    });
  });

  group('passkey enrolment at login (3c)', () {
    final creationOptions = <String, dynamic>{'challenge': 'Y3JlYXRl', 'rp': {'id': 'e-flux.dashboard.road.io'}};
    final attestationResponse = <String, dynamic>{'id': 'bmV3LWNyZWQ', 'type': 'public-key'};

    /// Walks intro → email proof → verified proof with the given permitted
    /// set on a passkey-capable device.
    Future<void> walkThroughEmailProof({required List<MfaMethod> permittedMethods}) async {
      when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => true);
      stubLoginResponse(LoginResponseModel(
          mfaEnrolment:
              MfaEnrolmentModel(enrolId: 'enrol-1', mode: MfaMode.encourage, permittedMethods: permittedMethods)));
      await authCubit.performLogin(testEmail, testPassword);
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await authCubit.continueEnrolment();
      when(() => mockMfaRepository.verifyEnrolmentEmailProof(enrolId: 'enrol-1', code: '123456'))
          .thenAnswer((_) async => MfaEnrolEmailProofVerifyModel(permittedMethods: permittedMethods));
      await authCubit.verifyEnrolmentEmailProof('123456');
    }

    void stubBegin() => when(() => mockMfaRepository.beginPasskeyEnrolment(enrolId: 'enrol-1'))
        .thenAnswer((_) async => creationOptions);

    test('passkey as the only supported method goes straight to the enrol-passkey step', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey]);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolPasskey>());
      // Beginning is per attempt, driven by the widget — landing here calls nothing.
      verifyNever(() => mockMfaRepository.beginPasskeyEnrolment(enrolId: any(named: 'enrolId')));
    });

    test('choosing passkey from the enrol picker lands on the enrol-passkey step', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey, MfaMethod.totp]);
      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolMethodPicker>());

      await authCubit.chooseEnrolMethod(MfaMethod.passkey);

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolPasskey>());
    });

    test('a passkey-only permitted set on an unsupporting device errors instead of dead-ending', () async {
      stubLoginResponse(LoginResponseModel(
          mfaEnrolment: MfaEnrolmentModel(
              enrolId: 'enrol-1', mode: MfaMode.enforce, permittedMethods: [MfaMethod.passkey])));
      await authCubit.performLogin(testEmail, testPassword);
      when(() => mockMfaRepository.sendEnrolmentEmailProof(enrolId: 'enrol-1'))
          .thenAnswer((_) async => MfaCodeSentModel(nextSendAfterSeconds: 30));
      await authCubit.continueEnrolment();
      when(() => mockMfaRepository.verifyEnrolmentEmailProof(enrolId: 'enrol-1', code: '123456'))
          .thenAnswer((_) async => MfaEnrolEmailProofVerifyModel(permittedMethods: [MfaMethod.passkey]));

      await authCubit.verifyEnrolmentEmailProof('123456');

      expect(authCubit.state.flow.isError, isTrue);
    });

    test('a full ceremony begins, creates and verifies into a session', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey]);
      stubBegin();
      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockMfaRepository.verifyPasskeyEnrolment(enrolId: 'enrol-1', response: attestationResponse))
          .thenAnswer((_) async => testSession);

      await authCubit.enrolWithPasskey();

      expect(authCubit.state, isA<LoggedIn>());
    });

    test('a dismissed OS sheet is silent and keeps the step; a retry re-begins', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey]);
      stubBegin();
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      await authCubit.enrolWithPasskey();

      expect(currentTwoFactorAuth(), isA<TwoFactorAuthEnrolPasskey>());
      expect(authCubit.state.flow.isError, isFalse);

      when(() => mockPasskeyService.create(creationOptions)).thenAnswer((_) async => attestationResponse);
      when(() => mockMfaRepository.verifyPasskeyEnrolment(enrolId: 'enrol-1', response: attestationResponse))
          .thenAnswer((_) async => testSession);

      await authCubit.enrolWithPasskey();

      expect(authCubit.state, isA<LoggedIn>());
      // Creation challenges are single-use — every attempt must re-begin.
      verify(() => mockMfaRepository.beginPasskeyEnrolment(enrolId: 'enrol-1')).called(2);
    });

    test('an existing passkey on this device flags the step instead of erroring', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey]);
      stubBegin();
      when(() => mockPasskeyService.create(creationOptions))
          .thenThrow(const PasskeyException(PasskeyErrorType.excludedCredentialExists));

      await authCubit.enrolWithPasskey();

      final tfa = currentTwoFactorAuth();
      expect(tfa, isA<TwoFactorAuthEnrolPasskey>());
      expect((tfa as TwoFactorAuthEnrolPasskey).deviceHasPasskey, isTrue);
      expect(authCubit.state.flow.isError, isFalse);
    });

    test('skip stays available from the enrol-passkey step under encourage', () async {
      await walkThroughEmailProof(permittedMethods: [MfaMethod.passkey]);
      when(() => mockMfaRepository.skipEnrolment(enrolId: 'enrol-1')).thenAnswer((_) async => testSession);

      final didLogIn = await authCubit.skipEnrolment();

      expect(didLogIn, isTrue);
      expect(authCubit.state, isA<LoggedIn>());
    });
  });

  group('passwordless passkey login (spec §6)', () {
    final options = <String, dynamic>{'challenge': 'Y2hhbGxlbmdl', 'rpId': 'e-flux.dashboard.road.io'};
    final assertionResponse = <String, dynamic>{'id': 'a25vd24tY3JlZA', 'type': 'public-key'};

    void stubChallenge() =>
        when(() => mockAuthRepository.beginPasskeyLogin(providerId: 'test-provider')).thenAnswer(
            (_) async => MfaChallengeResponseModel(ceremonyId: 'ceremony-1', options: options));

    test('challenge, ceremony and login complete into a session with the profile email', () async {
      stubChallenge();
      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockAuthRepository.completePasskeyLogin(ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenAnswer((_) async => testSession);

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isTrue);
      final state = authCubit.state;
      expect(state, isA<LoggedIn>());
      // No login email exists in this flow — the profile's address fills in.
      expect((state as LoggedIn).profile.email, testEmail);
    });

    test('a dismissed OS sheet is silent and stays on the credentials form', () async {
      stubChallenge();
      when(() => mockPasskeyService.get(options)).thenThrow(const PasskeyException(PasskeyErrorType.cancelled));

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isFalse);
      expect(authCubit.state, isA<LoggedOut>());
      expect(authCubit.state.flow.isError, isFalse);
      verifyNever(() => mockAuthRepository.completePasskeyLogin(
          ceremonyId: any(named: 'ceremonyId'), response: any(named: 'response')));
    });

    test('no credential on this device surfaces the steer-to-password error', () async {
      stubChallenge();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.noCredential));

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isFalse);
      expect(authCubit.state, isA<LoggedOut>());
      expect(authCubit.state.flow.isError, isTrue);
      expect(authCubit.state.flow.error.isPasskeyNoneOnDevice, isTrue);
    });

    test('a security error surfaces as the generic verification failure', () async {
      stubChallenge();
      when(() => mockPasskeyService.get(options))
          .thenThrow(const PasskeyException(PasskeyErrorType.securityError));

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isFalse);
      expect(authCubit.state.flow.error.isPasskeyVerificationFailed, isTrue);
    });

    test('a challenge without ceremony options errors instead of running a ceremony', () async {
      when(() => mockAuthRepository.beginPasskeyLogin(providerId: 'test-provider'))
          .thenAnswer((_) async => MfaChallengeResponseModel());

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isFalse);
      expect(authCubit.state.flow.error.isPasskeyChallengeMissing, isTrue);
      verifyNever(() => mockPasskeyService.get(any()));
    });

    test('a backend rejection (e.g. rate limit) surfaces as the error dialog', () async {
      stubChallenge();
      when(() => mockPasskeyService.get(options)).thenAnswer((_) async => assertionResponse);
      when(() => mockAuthRepository.completePasskeyLogin(ceremonyId: 'ceremony-1', response: assertionResponse))
          .thenThrow(mfaError('MFA_PASSKEY_VERIFICATION_FAILED'));

      final didLogIn = await authCubit.loginWithPasskey();

      expect(didLogIn, isFalse);
      expect(authCubit.state.flow.isError, isTrue);
    });

    group('conditional UI', () {
      void stubConditionalSupport({bool supported = true}) {
        when(() => mockPasskeyService.supportsConditionalUi).thenReturn(supported);
        when(() => mockPasskeyService.isSupported()).thenAnswer((_) async => supported);
      }

      test('a picked passkey completes into a session', () async {
        stubConditionalSupport();
        stubChallenge();
        when(() => mockPasskeyService.getConditional(options)).thenAnswer((_) async => assertionResponse);
        when(() => mockAuthRepository.completePasskeyLogin(ceremonyId: 'ceremony-1', response: assertionResponse))
            .thenAnswer((_) async => testSession);

        final didLogIn = await authCubit.startConditionalPasskeyLogin();

        expect(didLogIn, isTrue);
        expect(authCubit.state, isA<LoggedIn>());
      });

      test('everything before a selection is silent — cancel, no passkey, arm refusal', () async {
        stubConditionalSupport();
        for (final failure in [
          const PasskeyException(PasskeyErrorType.cancelled),
          const PasskeyException(PasskeyErrorType.noCredential),
        ]) {
          stubChallenge();
          when(() => mockPasskeyService.getConditional(options)).thenThrow(failure);

          expect(await authCubit.startConditionalPasskeyLogin(), isFalse);
          expect(authCubit.state, isA<LoggedOut>());
          expect(authCubit.state.flow.isError, isFalse);
        }

        // The arm itself refused (rate limit / passkey disallowed) — silent too.
        when(() => mockAuthRepository.beginPasskeyLogin(providerId: 'test-provider'))
            .thenThrow(mfaError('MFA_SEND_RATE_LIMITED', retryAfterSeconds: 60));

        expect(await authCubit.startConditionalPasskeyLogin(), isFalse);
        expect(authCubit.state.flow.isError, isFalse);
        verifyNever(() => mockAuthRepository.completePasskeyLogin(
            ceremonyId: any(named: 'ceremonyId'), response: any(named: 'response')));
      });

      test('a server rejection after the user picked a passkey surfaces the error', () async {
        stubConditionalSupport();
        stubChallenge();
        when(() => mockPasskeyService.getConditional(options)).thenAnswer((_) async => assertionResponse);
        when(() => mockAuthRepository.completePasskeyLogin(ceremonyId: 'ceremony-1', response: assertionResponse))
            .thenThrow(mfaError('MFA_PASSKEY_VERIFICATION_FAILED'));

        final didLogIn = await authCubit.startConditionalPasskeyLogin();

        expect(didLogIn, isFalse);
        expect(authCubit.state.flow.isError, isTrue);
      });

      test('a cancel during the challenge fetch stops the ceremony from parking', () async {
        stubConditionalSupport();
        // Hold the challenge fetch open so the cancel lands mid-fetch: at that
        // point no ceremony exists for the PasskeyService cancel to reach, so
        // only the cubit's own cancellation tracking can stop the park.
        final challengeFetch = Completer<MfaChallengeResponseModel>();
        when(() => mockAuthRepository.beginPasskeyLogin(providerId: 'test-provider'))
            .thenAnswer((_) => challengeFetch.future);
        when(() => mockPasskeyService.cancelCeremony()).thenAnswer((_) async {});

        final login = authCubit.startConditionalPasskeyLogin();
        await Future<void>.delayed(Duration.zero);
        verify(() => mockAuthRepository.beginPasskeyLogin(providerId: 'test-provider')).called(1);

        await authCubit.cancelConditionalPasskeyLogin();
        challengeFetch.complete(MfaChallengeResponseModel(ceremonyId: 'ceremony-1', options: options));

        expect(await login, isFalse);
        verifyNever(() => mockPasskeyService.getConditional(any()));
      });

      test('an unsupported platform arms nothing', () async {
        stubConditionalSupport(supported: false);

        expect(await authCubit.startConditionalPasskeyLogin(), isFalse);
        verifyNever(() => mockAuthRepository.beginPasskeyLogin(providerId: any(named: 'providerId')));
      });
    });
  });
}
