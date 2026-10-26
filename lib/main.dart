import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:road_mobile/bootstrap.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/intercom/intercom_utils.dart';
import 'app.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/environment/config_service.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';

import 'services/notifications/fcm_token_refresh_service.dart';
import 'services/notifications/incoming_notification_handler.dart';

/// Headless entrypoint for the Android Auto engine.
///
/// Executed natively by CarFlutterEngineManager when a car session starts
/// while the phone app is not running, so the car screen can load nearby
/// charging stations without any phone interaction. No FlutterView is ever
/// attached, so this must not call runApp — only the core services the
/// CarScreen pipeline needs are started.
///
/// Must live in this root library: only main.dart's transitive imports are
/// compiled into the app bundle, so an entrypoint in an unimported file
/// fails at runtime with "library not found" (vm:entry-point does not help).
@pragma('vm:entry-point')
Future<void> carScreenMain() async {
  await bootstrapCore();
}

Future<void> main() async {
  // Preserve splash screen while app initializes. bootstrapCore() also calls
  // ensureInitialized (it must be self-sufficient for the headless entrypoint);
  // the call is idempotent, and here it must happen before bootstrapCore's
  // awaits so the splash is preserved ahead of the first frame.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final core = await bootstrapCore();
  final authCubit = core.authCubit;

  if (Platform.isIOS) {
    final configService = getIt<ConfigService>();
    await configService.initialize();
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Try to use latest Android map renderer. Legacy is not supported anymore.
  // https://stackoverflow.com/questions/77235849/how-to-correctly-initialize-latest-renderer-in-android-google-maps-flutter
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    try {
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    } catch (e) {
      // Can happen with hot reload. Just log it and continue.
      log('Failed to initialize latest Android map renderer.');
    }
  }

  final notificationHandler = getIt<IncomingNotificationHandler>();
  notificationHandler.initializeNotificationHandler();

  if (authCubit.state.isLoggedIn) {
    getIt<FcmTokenRefreshService>().startListening();
  }

  await IntercomUtils.initialize();

  // Initialize Mixpanel analytics
  final mixpanelService = getIt<MixpanelService>();
  await mixpanelService.initialize(getIt<Stage>());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider.value(value: core.favouritesCubit),
      ],
      child: const App(),
    ),
  );

  // Remove splash screen after Flutter has rendered the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    FlutterNativeSplash.remove();
  });
}
