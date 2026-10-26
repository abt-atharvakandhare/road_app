import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/car_screen/car_screen.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/services/network/session_renewal_token_storage.dart';
import 'package:road_mobile/theme_data.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_screen.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import 'ui/onboarding/splash_screen/splash_screen.dart';
import 'ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/phrase_localizations.dart';

/// Routes the session-expired dialog through the dedicated text dialog so the
/// title reads "Session expired" instead of the generic "Error" used by the
/// shared [ModalInfoDialogs.showErrorDialog] path.
void _showSessionExpiredDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  getIt<ModalInfoDialogs>().showTextDialog(
    context,
    l10n.sessionExpiredMessage,
    title: l10n.sessionExpiredTitle,
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: F.title,
      // Deliberately disabled in ALL debug builds (release/profile never show
      // it): BrowserStack Espresso runs build debug, and their session videos
      // are uploaded to Google Play as FGS store-review evidence — the DEBUG
      // banner must not appear in them. Trade-off: local debug builds lose the
      // at-a-glance banner cue too.
      debugShowCheckedModeBanner: false,
      localizationsDelegates: PhraseLocalizations.localizationsDelegates,
      supportedLocales: PhraseLocalizations.supportedLocales,
      theme: ThemeFactory.themeData,
      builder: (context, child) => _CarScreenLocalizationsBridge(child: child ?? const SizedBox.shrink()),
      home: const AppRootWidget(),
    );
  }
}

/// Pushes the Phrase-wrapped AppLocalizations into context-less services
/// whenever the localizations delegate produces a new instance (locale
/// change, Phrase OTA update). These services have no BuildContext so they
/// can't reach Phrase-wrapped strings any other way —
/// `lookupAppLocalizations` bypasses PhraseLocalizations and only sees the
/// baked-in ARB.
class _CarScreenLocalizationsBridge extends StatelessWidget {
  const _CarScreenLocalizationsBridge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      getIt<CarScreen>().updateLocalizations(l10n);
      getIt<SessionRenewalTokenStorage>().updateLocalizations(l10n);
    }
    return child;
  }
}

class AppRootWidget extends StatefulWidget {
  const AppRootWidget({super.key});

  @override
  State<AppRootWidget> createState() => _AppRootWidgetState();
}

class _AppRootWidgetState extends State<AppRootWidget> {
  final mainAppViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
        if (state is LoggedOut && state.sessionExpired) {
          _showSessionExpiredDialog(context);
          context.read<AuthCubit>().acknowledgeSessionExpired();
        }
        if (state is LoggedIn && state.sessionEnding) {
          final l10n = AppLocalizations.of(context)!;
          showStyledSnackbar(
            context,
            SvgPicture.asset('assets/icons/warning_triangle.svg'),
            l10n.signInExpiringMessage,
          );
          context.read<AuthCubit>().acknowledgeSessionEnding();
        }
      },
      builder: (context, state) {
        return switch (state) {
          ShowSplash() => const SplashScreen(),
          LoggedIn() => MainAppRootScreen(key: mainAppViewKey),
          LoggedOut() => MainAppRootScreen(key: mainAppViewKey),
        };
      },
    );
  }
}
