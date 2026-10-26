import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_navigation_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_action_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/nearest_stations_screen.dart';

import 'widgets/home_screen_map_widget.dart';

class HomeRootScreen extends StatelessWidget {
  const HomeRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.startYourEVCharge, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.clickTheButtonBelow, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 35),
            BlocBuilder<ChargeNowBloc, ChargeNowState>(
              builder: (context, state) {
                final chargingSession = switch (state) {
                  ChargeSessionStarting(session: final session) => session,
                  CarIsCharging(session: final session) => session,
                  _ => null,
                };
                final chargingText = switch (state) {
                  ChargeSessionStarting() => AppLocalizations.of(context)!.sessionStarting,
                  CarIsCharging() => AppLocalizations.of(context)!.chargingInProgress,
                  _ => AppLocalizations.of(context)!.chargeNow,
                };
                return RMDecoratedActionButton(
                  icon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: chargingSession == null
                        ? SvgPicture.asset('assets/icons/lightning_bolt_18_24.svg')
                        : Lottie.asset('assets/lottie/home_session_charging.json'),
                  ),
                  onPressed: () {
                    getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.chargeNow);
                    ChargeNowRootScreen.pushAsModal(context);
                  },
                  gradientColors: chargingSession == null
                      ? null
                      : const [RMColors.activeChargeBlueGradientStart, RMColors.activeChargeBlueText],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // maxLines + ellipsis on the button copy (and the
                      // shortcut subtitles below): these lines are
                      // single-line by design, and several es/fr translations
                      // are long enough to wrap on a 360dp-wide screen —
                      // growing this fixed-height Column past the viewport
                      // (it overflowed by 20px in es before the map slot at
                      // the bottom could absorb it).
                      Text(
                        chargingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: RMColors.rmWhiteText),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chargingSession != null
                            ? (chargingSession.location?.address ?? AppLocalizations.of(context)!.unknownAddress)
                            : AppLocalizations.of(context)!.startAChargeSession,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: RMColors.rmWhiteText),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const RMSeparator(),
            RMInkwellButton(
              onPressed: () {
                getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.wallet);
                BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.wallet);
              },
              icon: SvgPicture.asset('assets/icons/credit_card_medium.svg'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.viewWallet, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.paymentsAndSessions,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const RMSeparator(),
            RMInkwellButton(
              onPressed: () {
                getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.mapSearch);
                BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);
              },
              icon: SvgPicture.asset('assets/icons/location_medium.svg'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.exploreStations, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.findEVChargingLocations,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const RMSeparator(),
            RMInkwellButton(
              onPressed: () {
                getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.highwayMode);
                NearestStationsScreen.pushAsFullScreen(context);
              },
              icon: SvgPicture.asset('assets/icons/highway_mode_medium.svg'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.highwayMode, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.stopAtNearestFastChargingStation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Only show map if there's at least 150px of available height
                  if (constraints.maxHeight < 140) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () =>
                        BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore),
                    child: const HomeScreenMapWidget(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
