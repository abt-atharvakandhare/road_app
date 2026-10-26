import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:road_mobile/data/model/account/account_details_model.dart';
import 'package:road_mobile/data/model/account/account_self_response_model.dart';
import 'package:road_mobile/data/model/login/login_response_model.dart';
import 'package:road_mobile/data/model/mobile_features/mobile_user_summary_model.dart';
import 'package:road_mobile/data/model/provider/provider_response_model.dart';
import 'package:road_mobile/data/model/user/user_profile.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
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

void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockAuthRepository;
  late MockMfaRepository mockMfaRepository;
  late MockPasskeyService mockPasskeyService;
  late MockVerificationRepository mockVerificationRepository;
  late MockAuthStorage mockAuthStorage;
  late MockAnalytics mockAnalytics;
  late MockMixpanelService mockMixpanelService;
  late MockSessionRenewalTokenStorage mockRenewalStorage;
  late MockAuthSessionRenewer mockRenewer;
  late AuthLifecycleBus lifecycleBus;
  late SharedPreferences mockPrefs;

  const testAccountDetails = AccountDetailsModel(
    accountId: 'test-account-id',
    userId: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
    hasCreditCard: false,
    hasRfidCard: false,
    canAddCreditCard: true,
    emailVerificationEnabled: false,
    mobileNumberVerificationEnabled: false,
    isEmailVerified: true,
    isMobileNumberVerified: true,
    remoteSessionEnabledPartyIds: ['EFL'],
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    F.appFlavor = Flavor.eflux;
    Defines.intercomEnabled = false;
    registerFallbackValue(VerificationType.email);

    // Mock Intercom platform channel to avoid MissingPluginException
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
    mockVerificationRepository = MockVerificationRepository();
    mockAuthStorage = MockAuthStorage();
    mockAnalytics = MockAnalytics();
    mockMixpanelService = MockMixpanelService();
    mockRenewalStorage = MockSessionRenewalTokenStorage();
    mockRenewer = MockAuthSessionRenewer();
    lifecycleBus = AuthLifecycleBus();
    when(() => mockRenewalStorage.isAvailable()).thenAnswer((_) async => false);
    when(() => mockRenewalStorage.canStore()).thenAnswer((_) async => false);
    when(() => mockRenewalStorage.clear()).thenAnswer((_) async {});
    when(() => mockRenewalStorage.store(any())).thenAnswer((_) async {});

    // AuthCubit.logout() pulls DebugControlsRepo from GetIt to re-persist the
    // debug toggles after _prefs.clear() wipes them. Register a real one against
    // the mocked SharedPreferences so the call doesn't blow up in tests.
    await getIt.reset();
    getIt.registerSingleton<DebugControlsRepo>(DebugControlsRepo(mockPrefs));

    // Setup default mocks
    when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => null);
    when(() => mockAuthStorage.storeAuthToken(any())).thenAnswer((_) async {});
    when(() => mockAuthStorage.deleteAuthToken()).thenAnswer((_) async {});
    when(() => mockAuthStorage.storeProviderId(any())).thenAnswer((_) async {});
    when(() => mockMixpanelService.identify(any(), email: any(named: 'email'))).thenReturn(null);
    when(() => mockMixpanelService.reset()).thenReturn(null);
    when(() => mockMixpanelService.flush()).thenReturn(null);

    // _refreshAccountDetails (now triggered on every app launch when the cached
    // billingCurrency is null, per the backfill in moveToInitialAppState) calls
    // these four endpoints. Stub them so the fire-and-forget refresh doesn't
    // blow up the test with an unhandled async error.
    when(() => mockAuthRepository.getProvider(any())).thenAnswer(
      (_) async => ProviderResponseModel(id: 'test-provider'),
    );
    when(() => mockAuthRepository.getMyAccount()).thenAnswer(
      (_) async => AccountSelfModel('test-user-id', null, null, null),
    );
    when(() => mockAuthRepository.getMyProfile()).thenAnswer(
      (_) async => ProfileResponseModel(
        ProfileModel('test-user-id', 'Test User', 'test@example.com', null, null, null),
      ),
    );
    when(() => mockAuthRepository.getMobileFeatures()).thenAnswer(
      (_) async => MobileUserSummaryModel(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('AuthCubit Mixpanel Integration', () {
    test('identify is called on app launch when user is already logged in', () async {
      // Save account details to SharedPreferences to simulate logged-in user
      testAccountDetails.saveToSharedPrefs(mockPrefs);

      // Mock that token exists (user is logged in)
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => 'test-token');

      // Create cubit - this triggers moveToInitialAppState
      authCubit = AuthCubit(
        mockAuthRepository,
        mockMfaRepository,
        mockPasskeyService,
        mockVerificationRepository,
        mockAuthStorage,
        mockPrefs,
        mockAnalytics,
        mockMixpanelService,
        mockRenewalStorage,
        mockRenewer,
        lifecycleBus,
      );

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify identify was called with user details from storage
      verify(() => mockMixpanelService.identify(
            'test-user-id',
            email: 'test@example.com',
          )).called(1);

      // Verify flush was called after identify
      verify(() => mockMixpanelService.flush()).called(1);

      await authCubit.close();
    });

    test('identify is NOT called on app launch when user is NOT logged in', () async {
      // No stored token
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.getProvider(any())).thenAnswer((_) async => ProviderResponseModel(
            id: 'test-provider',
          ));

      // Create cubit
      authCubit = AuthCubit(
        mockAuthRepository,
        mockMfaRepository,
        mockPasskeyService,
        mockVerificationRepository,
        mockAuthStorage,
        mockPrefs,
        mockAnalytics,
        mockMixpanelService,
        mockRenewalStorage,
        mockRenewer,
        lifecycleBus,
      );

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify identify was NOT called
      verifyNever(() => mockMixpanelService.identify(any(), email: any(named: 'email')));

      await authCubit.close();
    });

    test('identify is called after successful login', () async {
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.getProvider(any())).thenAnswer((_) async => ProviderResponseModel(
            id: 'test-provider',
          ));

      when(() => mockAuthRepository.login(any(), password: any(named: 'password')))
          .thenAnswer((_) async => LoginResponseModel(token: 'jwt-token'));

      when(() => mockAuthRepository.getMyAccount()).thenAnswer((_) async => AccountSelfModel(
            'test-user-id',
            null, // billing
            null, // contact
            null, // billingCurrency
          ));

      when(() => mockAuthRepository.getMyProfile()).thenAnswer((_) async => ProfileResponseModel(
            ProfileModel(
              'test-user-id',
              'Test User',
              'test@example.com',
              null, // mfaMethod
              null, // favouriteLocations
              null, // emailVerifiedAt
            ),
          ));

      when(() => mockAuthRepository.getMobileFeatures()).thenAnswer((_) async => MobileUserSummaryModel());

      // Create cubit
      authCubit = AuthCubit(
        mockAuthRepository,
        mockMfaRepository,
        mockPasskeyService,
        mockVerificationRepository,
        mockAuthStorage,
        mockPrefs,
        mockAnalytics,
        mockMixpanelService,
        mockRenewalStorage,
        mockRenewer,
        lifecycleBus,
      );

      // Wait for initial state
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear any previous interactions
      clearInteractions(mockMixpanelService);

      // Perform login
      await authCubit.performLogin('test@example.com', 'password123');

      // Verify identify was called
      verify(() => mockMixpanelService.identify(
            'test-user-id',
            email: 'test@example.com',
          )).called(1);

      // Verify flush was called after identify
      verify(() => mockMixpanelService.flush()).called(1);

      await authCubit.close();
    });

    test('reset is called on logout', () async {
      // Setup logged-in state
      testAccountDetails.saveToSharedPrefs(mockPrefs);
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => 'test-token');
      when(() => mockAuthRepository.getProvider(any())).thenAnswer((_) async => ProviderResponseModel(
            id: 'test-provider',
          ));

      // Create cubit with logged-in state
      authCubit = AuthCubit(
        mockAuthRepository,
        mockMfaRepository,
        mockPasskeyService,
        mockVerificationRepository,
        mockAuthStorage,
        mockPrefs,
        mockAnalytics,
        mockMixpanelService,
        mockRenewalStorage,
        mockRenewer,
        lifecycleBus,
      );

      // Wait for initial state
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear previous interactions (identify from initial state)
      clearInteractions(mockMixpanelService);

      // Perform logout
      await authCubit.logout();

      // Verify flush was called before reset
      verify(() => mockMixpanelService.flush()).called(1);
      // Verify reset was called
      verify(() => mockMixpanelService.reset()).called(1);

      await authCubit.close();
    });
  });

  group('session revocation (reactive-401 logout)', () {
    AuthCubit buildCubit() => AuthCubit(
          mockAuthRepository,
          mockMfaRepository,
          mockPasskeyService,
          mockVerificationRepository,
          mockAuthStorage,
          mockPrefs,
          mockAnalytics,
          mockMixpanelService,
          mockRenewalStorage,
          mockRenewer,
          lifecycleBus,
        );

    test('SessionRevoked logs the user out', () async {
      testAccountDetails.saveToSharedPrefs(mockPrefs);
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => 'test-token');
      authCubit = buildCubit();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(authCubit.state, isA<LoggedIn>());

      lifecycleBus.publish(const SessionRevoked(expired: true));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(authCubit.state, isA<LoggedOut>());
      verify(() => mockAuthStorage.deleteAuthToken()).called(1);
      await authCubit.close();
    });

    test('concurrent SessionRevoked events collapse to a single logout', () async {
      testAccountDetails.saveToSharedPrefs(mockPrefs);
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => 'test-token');
      authCubit = buildCubit();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // A foreground burst can publish several before the first logout emits.
      lifecycleBus.publish(const SessionRevoked(expired: true));
      lifecycleBus.publish(const SessionRevoked(expired: true));
      lifecycleBus.publish(const SessionRevoked(expired: false));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(() => mockAuthStorage.deleteAuthToken()).called(1);
      await authCubit.close();
    });

    test('SessionRevoked while logged out is a no-op', () async {
      when(() => mockAuthStorage.readAuthToken()).thenAnswer((_) async => null);
      authCubit = buildCubit();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(authCubit.state, isA<LoggedOut>());

      lifecycleBus.publish(const SessionRevoked(expired: true));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verifyNever(() => mockAuthStorage.deleteAuthToken());
      await authCubit.close();
    });
  });
}
