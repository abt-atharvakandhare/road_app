import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_navigation_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class LowSpeedStateWidget extends StatelessWidget {
  const LowSpeedStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Highway icon
            SvgPicture.asset('assets/icons/highway_mode_medium.svg', width: 48, height: 32),
            const SizedBox(height: 32),
            // Main title - 24px Semi Bold matches bodyMedium
            Text(
              AppLocalizations.of(context)!.highwayModeAvailableWhileDriving,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(letterSpacing: -0.192),
            ),
            const SizedBox(height: 24),
            // Separator line
            Container(height: 1, width: 140, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            // Subtitle - 14px Semi Bold matches titleSmall
            Text(
              AppLocalizations.of(context)!.youCanAlwaysFindNearbyStations,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            // Link button - 12px Semi Bold
            TextButton(
              onPressed: () {
                // Close the screen
                Navigator.of(context).pop();

                // Switch to explore tab
                BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);

                // Navigate to map with nearby stations
                final locationState = BlocProvider.of<LocationBloc>(context).state;
                switch (locationState) {
                  case LocationProvided(userLocation: final location):
                    BlocProvider.of<MapOverlayBloc>(context).add(
                      MapOverlayEvent.waitForMapToSettle((ctx) {
                        final mapBloc = BlocProvider.of<MapBloc>(ctx);
                        BlocProvider.of<MapOverlayBloc>(ctx).add(
                          MapOverlayEvent.loadSearchResults(
                            AppLocalizations.of(ctx)!.nearbyStations,
                            mapBloc.state.mapItems,
                            mapBloc.state.searchResultPinLocation,
                          ),
                        );
                        mapBloc.add(
                          MapEvent.moveMapToLocation(
                            location.latitude,
                            location.longitude,
                            const MapLocationPinSelection.none(),
                          ),
                        );
                      }),
                    );
                  default:
                    break;
                }
              },
              child: Text(
                AppLocalizations.of(context)!.findStationsNearby,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(color: RMColors.rmPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
