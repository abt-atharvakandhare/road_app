import 'dart:io';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:road_mobile/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_mobile/services/environment/config.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: false)
Future<void> configureDependencies() async {
  //
  // Dart in release mode seems to override the User-Agent header if we apply it in the api service interceptor.
  //
  getIt.registerSingletonAsync<Dio>(() async {
    final String userAgent = await generateUserAgent();
    return Dio(BaseOptions(headers: {'User-Agent': userAgent}));
  }, signalsReady: false);

  await getIt.isReady<Dio>();

  await getIt.init();
}

Future<String> generateUserAgent() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;

  String platformInfo;

  final deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final anrdoidInfo = await deviceInfoPlugin.androidInfo;
    platformInfo =
        'Android:${anrdoidInfo.version.release}; ${anrdoidInfo.manufacturer}; ${anrdoidInfo.model}; ${anrdoidInfo.product}';
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    platformInfo = '${iosInfo.systemName}:${iosInfo.systemVersion}; ${iosInfo.utsname.machine}';
  } else {
    platformInfo = HttpClient().userAgent ?? 'Unknown';
  }

  final userAgent = 'RoadMobile/$version ($platformInfo) ${F.providerName}';

  return userAgent;
}

@module
abstract class AppModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  @lazySingleton
  BiometricStorage get biometricStorage => BiometricStorage();
  @lazySingleton
  FlutterGooglePlacesSdk get googlePlacesApi => FlutterGooglePlacesSdk(
        Platform.isIOS ? Config.googleServicesApiKeyIos : Config.googleServicesApiKeyAndroid,
      );

  @preResolve
  Future<SharedPreferences> sharedPreferences() => SharedPreferences.getInstance();

  @preResolve
  Future<PackageInfo> packageInfo() => PackageInfo.fromPlatform();
}
