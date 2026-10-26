// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:biometric_storage/biometric_storage.dart' as _i705;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart' as _i373;
import 'package:injectable/injectable.dart' as _i526;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:road_mobile/services/analytics/analytics.dart' as _i223;
import 'package:road_mobile/services/analytics/mixpanel_service.dart' as _i51;
import 'package:road_mobile/services/car_screen/car_screen.dart' as _i701;
import 'package:road_mobile/services/di/injection.dart' as _i1046;
import 'package:road_mobile/services/environment/config_service.dart' as _i757;
import 'package:road_mobile/services/environment/environment.dart' as _i118;
import 'package:road_mobile/services/network/api_service.dart' as _i786;
import 'package:road_mobile/services/network/app_check_token_provider.dart'
    as _i44;
import 'package:road_mobile/services/network/auth_lifecycle_bus.dart' as _i279;
import 'package:road_mobile/services/network/auth_session_renewer.dart'
    as _i1024;
import 'package:road_mobile/services/network/auth_storage.dart' as _i127;
import 'package:road_mobile/services/network/auth_token_refresher.dart' as _i76;
import 'package:road_mobile/services/network/session_renewal_token_storage.dart'
    as _i1016;
import 'package:road_mobile/services/network/token_status_bus.dart' as _i411;
import 'package:road_mobile/services/notifications/fcm_token_refresh_service.dart'
    as _i535;
import 'package:road_mobile/services/notifications/incoming_notification_handler.dart'
    as _i862;
import 'package:road_mobile/services/passkey/passkey_service.dart' as _i53;
import 'package:road_mobile/services/payment/three_ds_service.dart' as _i402;
import 'package:road_mobile/services/timezone/timezone_service.dart' as _i912;
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_cubit.dart'
    as _i1034;
import 'package:road_mobile/ui/mainapp/account/subscreens/notifications/cubit/notifications_repo.dart'
    as _i766;
import 'package:road_mobile/ui/mainapp/account/subscreens/password/cubit/password_cubit.dart'
    as _i753;
import 'package:road_mobile/ui/mainapp/account/subscreens/password/cubit/password_repo.dart'
    as _i308;
import 'package:road_mobile/ui/mainapp/account/subscreens/security/cubit/security_cubit.dart'
    as _i35;
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_cubit.dart'
    as _i39;
import 'package:road_mobile/ui/mainapp/add_credit_card/cubit/add_credit_card_repo.dart'
    as _i282;
import 'package:road_mobile/ui/mainapp/app_links/cubit/app_links_cubit.dart'
    as _i250;
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart'
    as _i81;
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_repository.dart'
    as _i89;
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_cubit.dart'
    as _i479;
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart'
    as _i528;
import 'package:road_mobile/ui/mainapp/debug_controls/gps_simulation_service.dart'
    as _i262;
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_cubit.dart'
    as _i510;
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_repository.dart'
    as _i237;
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart' as _i330;
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_repository.dart'
    as _i52;
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart'
    as _i374;
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_repo.dart'
    as _i362;
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart'
    as _i395;
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_repository.dart'
    as _i83;
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart'
    as _i828;
import 'package:road_mobile/ui/mainapp/report_problem/cubit/report_problem_cubit.dart'
    as _i442;
import 'package:road_mobile/ui/mainapp/report_problem/data/report_problem_repository.dart'
    as _i1036;
import 'package:road_mobile/ui/mainapp/wallet/cubit/wallet_navigation_cubit.dart'
    as _i718;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/cubit/invoices_cubit.dart'
    as _i634;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/invoices/cubit/invoices_repository.dart'
    as _i848;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_cubit.dart'
    as _i972;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/payment_methods/cubit/payment_methods_repository.dart'
    as _i307;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/session_detail_cubit.dart'
    as _i63;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_cubit.dart'
    as _i453;
import 'package:road_mobile/ui/mainapp/wallet/subscreens/sessions/cubit/sessions_repository.dart'
    as _i601;
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart' as _i658;
import 'package:road_mobile/ui/onboarding/login/cubit/auth_repository.dart'
    as _i565;
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_factors_repository.dart'
    as _i899;
import 'package:road_mobile/ui/onboarding/login/cubit/mfa_repository.dart'
    as _i811;
import 'package:road_mobile/ui/onboarding/login/cubit/step_up_repository.dart'
    as _i579;
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_cubit.dart'
    as _i181;
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_mfa_setup_cubit.dart'
    as _i393;
import 'package:road_mobile/ui/onboarding/signup/cubit/signup_repository.dart'
    as _i771;
import 'package:road_mobile/ui/onboarding/signup/verification/verification_repository.dart'
    as _i86;
import 'package:road_mobile/ui/utils/step_up/step_up_cubit.dart' as _i910;
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart'
    as _i425;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i223.Analytics>(() => _i223.Analytics());
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences(),
      preResolve: true,
    );
    await gh.factoryAsync<_i655.PackageInfo>(
      () => appModule.packageInfo(),
      preResolve: true,
    );
    gh.factory<_i862.IncomingNotificationHandler>(
      () => _i862.IncomingNotificationHandler(),
    );
    gh.factory<_i912.TimezoneService>(() => _i912.TimezoneService());
    gh.singleton<_i262.GpsSimulationService>(
      () => _i262.GpsSimulationService(),
    );
    gh.lazySingleton<_i51.MixpanelService>(() => _i51.MixpanelService());
    gh.lazySingleton<_i701.CarScreen>(
      () => _i701.CarScreen(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i705.BiometricStorage>(() => appModule.biometricStorage);
    gh.lazySingleton<_i373.FlutterGooglePlacesSdk>(
      () => appModule.googlePlacesApi,
    );
    gh.lazySingleton<_i757.ConfigService>(() => _i757.ConfigService());
    gh.lazySingleton<_i118.Stage>(() => _i118.Stage());
    gh.lazySingleton<_i279.AuthLifecycleBus>(
      () => _i279.AuthLifecycleBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i411.TokenStatusBus>(
      () => _i411.TokenStatusBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i53.PasskeyService>(() => _i53.PasskeyService());
    gh.lazySingleton<_i250.AppLinksCubit>(() => _i250.AppLinksCubit());
    gh.lazySingleton<_i718.WalletNavigationCubit>(
      () => _i718.WalletNavigationCubit(),
    );
    gh.lazySingleton<_i1016.SessionRenewalTokenStorage>(
      () => _i1016.SessionRenewalTokenStorage(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i705.BiometricStorage>(),
      ),
    );
    gh.lazySingleton<_i44.AppCheckTokenProvider>(
      () => _i44.FirebaseAppCheckTokenProvider(),
    );
    gh.factory<_i425.ModalInfoDialogs>(
      () => _i425.ModalInfoDialogs(gh<_i223.Analytics>()),
    );
    gh.lazySingleton<_i127.AuthStorage>(
      () => _i127.AuthStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.singleton<_i528.DebugControlsRepo>(
      () => _i528.DebugControlsRepo(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i402.ThreeDsService>(
      () => _i402.ThreeDsService(gh<_i118.Stage>()),
    );
    gh.lazySingleton<_i828.LocationBloc>(
      () => _i828.LocationBloc(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i786.ApiService>(
      () => _i786.ApiService(
        gh<_i361.Dio>(),
        gh<_i118.Stage>(),
        gh<_i223.Analytics>(),
        gh<_i127.AuthStorage>(),
        gh<_i411.TokenStatusBus>(),
        gh<_i279.AuthLifecycleBus>(),
        gh<_i44.AppCheckTokenProvider>(),
      ),
    );
    gh.factory<_i86.VerificationRepository>(
      () => _i86.VerificationRepository(
        gh<_i786.ApiService>(),
        gh<_i223.Analytics>(),
      ),
    );
    gh.lazySingleton<_i52.MapRepository>(
      () => _i52.MapRepository(gh<_i786.ApiService>(), gh<_i223.Analytics>()),
    );
    gh.factory<_i308.PasswordRepo>(
      () => _i308.PasswordRepo(gh<_i786.ApiService>()),
    );
    gh.factory<_i237.FavouritesRepository>(
      () => _i237.FavouritesRepository(gh<_i786.ApiService>()),
    );
    gh.factory<_i362.MapOverlayRepo>(
      () => _i362.MapOverlayRepo(gh<_i786.ApiService>()),
    );
    gh.factory<_i771.SignupRepository>(
      () => _i771.SignupRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i766.NotificationsRepo>(
      () => _i766.NotificationsRepo(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i282.AddCreditCardRepository>(
      () => _i282.AddCreditCardRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i89.ChargeNowRepository>(
      () => _i89.ChargeNowRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i83.NearestStationsRepository>(
      () => _i83.NearestStationsRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i1036.ReportProblemRepository>(
      () => _i1036.ReportProblemRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i848.InvoicesRepository>(
      () => _i848.InvoicesRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i307.PaymentMethodsRepository>(
      () => _i307.PaymentMethodsRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i601.SessionsRepository>(
      () => _i601.SessionsRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i565.AuthRepository>(
      () => _i565.AuthRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i899.MfaFactorsRepository>(
      () => _i899.MfaFactorsRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i811.MfaRepository>(
      () => _i811.MfaRepository(gh<_i786.ApiService>()),
    );
    gh.lazySingleton<_i579.StepUpRepository>(
      () => _i579.StepUpRepository(gh<_i786.ApiService>()),
    );
    gh.factoryParam<
      _i395.NearestStationsCubit,
      _i395.NearestStationsConfig?,
      dynamic
    >(
      (config, _) => _i395.NearestStationsCubit(
        gh<_i83.NearestStationsRepository>(),
        gh<_i828.LocationBloc>(),
        config,
      ),
    );
    gh.factory<_i63.SessionDetailCubit>(
      () => _i63.SessionDetailCubit(gh<_i601.SessionsRepository>()),
    );
    gh.factory<_i453.SessionsCubit>(
      () => _i453.SessionsCubit(gh<_i601.SessionsRepository>()),
    );
    gh.lazySingleton<_i479.DebugControlsCubit>(
      () => _i479.DebugControlsCubit(
        gh<_i528.DebugControlsRepo>(),
        gh<_i262.GpsSimulationService>(),
        gh<_i828.LocationBloc>(),
      ),
    );
    gh.factoryParam<_i81.ChargeNowBloc, bool, dynamic>(
      (isInitiallyLoggedIn, _) => _i81.ChargeNowBloc(
        gh<_i89.ChargeNowRepository>(),
        gh<_i223.Analytics>(),
        gh<_i402.ThreeDsService>(),
        isInitiallyLoggedIn: isInitiallyLoggedIn,
      ),
    );
    gh.factoryParam<_i510.FavouritesCubit, bool, dynamic>(
      (isInitiallyLoggedIn, _) => _i510.FavouritesCubit(
        gh<_i237.FavouritesRepository>(),
        isInitiallyLoggedIn: isInitiallyLoggedIn,
      ),
    );
    gh.factory<_i35.SecurityCubit>(
      () => _i35.SecurityCubit(
        gh<_i899.MfaFactorsRepository>(),
        gh<_i53.PasskeyService>(),
      ),
    );
    gh.factory<_i393.SignupMfaSetupCubit>(
      () => _i393.SignupMfaSetupCubit(
        gh<_i899.MfaFactorsRepository>(),
        gh<_i53.PasskeyService>(),
      ),
    );
    gh.factory<_i330.MapBloc>(
      () => _i330.MapBloc(
        gh<_i52.MapRepository>(),
        gh<_i373.FlutterGooglePlacesSdk>(),
      ),
    );
    gh.factory<_i39.AddCreditCardCubit>(
      () => _i39.AddCreditCardCubit(gh<_i282.AddCreditCardRepository>()),
    );
    gh.factory<_i753.PasswordCubit>(
      () => _i753.PasswordCubit(gh<_i308.PasswordRepo>()),
    );
    gh.factory<_i1034.NotificationsCubit>(
      () => _i1034.NotificationsCubit(
        gh<_i766.NotificationsRepo>(),
        gh<_i127.AuthStorage>(),
      ),
    );
    gh.lazySingleton<_i535.FcmTokenRefreshService>(
      () => _i535.FcmTokenRefreshService(
        gh<_i766.NotificationsRepo>(),
        gh<_i127.AuthStorage>(),
      ),
    );
    gh.factory<_i374.MapOverlayBloc>(
      () => _i374.MapOverlayBloc(
        gh<_i373.FlutterGooglePlacesSdk>(),
        gh<_i362.MapOverlayRepo>(),
      ),
    );
    gh.lazySingleton<_i76.AuthTokenRefresher>(
      () => _i76.AuthTokenRefresher(
        gh<_i565.AuthRepository>(),
        gh<_i127.AuthStorage>(),
        gh<_i411.TokenStatusBus>(),
        gh<_i279.AuthLifecycleBus>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i442.ReportProblemCubit>(
      () => _i442.ReportProblemCubit(
        gh<_i1036.ReportProblemRepository>(),
        gh<_i89.ChargeNowRepository>(),
      ),
    );
    gh.factory<_i634.InvoicesCubit>(
      () => _i634.InvoicesCubit(gh<_i848.InvoicesRepository>()),
    );
    gh.factory<_i972.PaymentMethodsCubit>(
      () => _i972.PaymentMethodsCubit(
        gh<_i89.ChargeNowRepository>(),
        gh<_i307.PaymentMethodsRepository>(),
      ),
    );
    gh.lazySingleton<_i1024.AuthSessionRenewer>(
      () => _i1024.AuthSessionRenewer(
        gh<_i565.AuthRepository>(),
        gh<_i127.AuthStorage>(),
        gh<_i1016.SessionRenewalTokenStorage>(),
        gh<_i279.AuthLifecycleBus>(),
        gh<_i76.AuthTokenRefresher>(),
      ),
    );
    gh.factory<_i910.StepUpCubit>(
      () => _i910.StepUpCubit(
        gh<_i899.MfaFactorsRepository>(),
        gh<_i579.StepUpRepository>(),
        gh<_i53.PasskeyService>(),
      ),
    );
    gh.factory<_i181.SignupCubit>(
      () => _i181.SignupCubit(
        gh<_i771.SignupRepository>(),
        gh<_i86.VerificationRepository>(),
        gh<_i899.MfaFactorsRepository>(),
        gh<_i53.PasskeyService>(),
        gh<_i912.TimezoneService>(),
        gh<_i223.Analytics>(),
        gh<_i51.MixpanelService>(),
      ),
    );
    gh.factory<_i658.AuthCubit>(
      () => _i658.AuthCubit(
        gh<_i565.AuthRepository>(),
        gh<_i811.MfaRepository>(),
        gh<_i53.PasskeyService>(),
        gh<_i86.VerificationRepository>(),
        gh<_i127.AuthStorage>(),
        gh<_i460.SharedPreferences>(),
        gh<_i223.Analytics>(),
        gh<_i51.MixpanelService>(),
        gh<_i1016.SessionRenewalTokenStorage>(),
        gh<_i1024.AuthSessionRenewer>(),
        gh<_i279.AuthLifecycleBus>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i1046.AppModule {}
