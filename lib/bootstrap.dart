import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phrase/phrase.dart';
import 'package:road_mobile/services/car_screen/car_screen.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/environment/config.dart';
import 'package:road_mobile/services/network/api_service.dart';
import 'package:road_mobile/services/network/auth_session_renewer.dart';
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';

import 'flavors.dart';

/// Core services created by [bootstrapCore] that entrypoints need access to.
class CoreServices {
  const CoreServices({required this.authCubit, required this.favouritesCubit});

  final AuthCubit authCubit;
  final FavouritesCubit favouritesCubit;
}

/// Initializes everything shared between the phone app ([main]) and the
/// headless Android Auto engine ([carScreenMain]): environment, Firebase,
/// dependency injection, auth session, and the car screen service.
///
/// Phone-only concerns (splash, orientation, maps renderer, notifications,
/// Intercom, Mixpanel, runApp) stay in main().
Future<CoreServices> bootstrapCore() async {
  F.appFlavor = Flavor.values.firstWhere((element) => element.name == appFlavor);

  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  try {
    final fbapp = await Firebase.initializeApp();
    log('Firebase project initialized: ${fbapp.options.projectId}');

    // Debug providers in debug/profile builds: attestation would fail there
    // (unsigned/re-signed binaries, e2e, BrowserStack), and registered debug
    // tokens keep those builds working against the backend gate.
    const useDebugAttestation = kDebugMode || kProfileMode;
    await FirebaseAppCheck.instance.activate(
      providerAndroid: useDebugAttestation ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
      providerApple:
          useDebugAttestation ? const AppleDebugProvider() : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (errorDetails) async {
      // Record as NON-fatal: these framework errors are caught by Flutter and
      // don't terminate the app (the chained presentError below just logs /
      // shows the debug error widget). recordFlutterError keeps `fatal` false;
      // recordFlutterFatalError would mark every one as a crash and wreck the
      // crash-free-users metric. Matches the fatal:false convention used
      // everywhere else in the app.
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      previousOnError?.call(errorDetails);
    };
  } catch (e) {
    log('Error initializing Firebase: $e');
  }

  await configureDependencies();

  final authCubit = getIt<AuthCubit>();

  final sessionRenewer = getIt<AuthSessionRenewer>();

  // Wire reactive-401 recovery into the network layer: on a JWT-rejected 401
  // the interceptor renews via this callback (single-flight) and retries the
  // original request transparently, or — if renewal fails — publishes
  // SessionRevoked, which AuthCubit turns into a logout.
  getIt<ApiService>().setRecover(() => sessionRenewer.tryRenew());

  PlatformDispatcher.instance.onError = (error, stack) {
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    log('Unhandled Platform error: $error\n$stack');
    // Record as NON-fatal: we return true just below (= "handled"), so the app
    // keeps running and the user never experiences a crash. fatal:true would
    // count these recovered errors against crash-free-users, which is exactly
    // why everything was showing up as a crash in Crashlytics.
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };

  Phrase.setup(Config.phraseDistributionId, Config.phraseProductionSecret);

  // Start the car screen service and pass cubit instances.
  // FavouritesCubit is created here (not in MainAppRootScreen) so it's
  // available even when CarPlay/Android Auto connects before the main
  // app UI is shown. Pass the current auth state so the cubit only
  // auto-loads when the user is already authenticated (e.g. cached
  // session). MainAppRootScreen's auth listener handles the runtime
  // loggedOut → loggedIn transition.
  final favouritesCubit = getIt<FavouritesCubit>(param1: authCubit.state.isLoggedIn);
  final carScreen = getIt<CarScreen>();
  carScreen.registerAuthCubit(authCubit);
  carScreen.registerFavouritesCubit(favouritesCubit);

  return CoreServices(authCubit: authCubit, favouritesCubit: favouritesCubit);
}
