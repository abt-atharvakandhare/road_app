import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/charging/charging_connector.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loading_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_station_direct_line_map_widget.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../main_app_root_navigation_cubit.dart';
import '../bloc/charge_now_bloc.dart';

class SelectYourChargeStationWidget extends StatelessWidget {
  const SelectYourChargeStationWidget({super.key, required this.nearbyLocations, this.selectedConnector});

  final List<StartChargingLocationMetadata> nearbyLocations;
  final ChargingConnector? selectedConnector;

  @override
  Widget build(BuildContext context) {
    // All nearby locations are at the same physical location (same latLng),
    // just different EVSEs/connectors - so we only need one marker
    final firstLocation = nearbyLocations.isNotEmpty ? nearbyLocations.first : null;

    return Column(
      children: [
        SvgPicture.asset('assets/icons/charging_station.svg'),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.selectYourChargeStation, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        const RMSeparator(),
        if (firstLocation != null)
          RMStationDirectLineMapWidget(
            stationLocation: firstLocation.latLng,
            stationId: firstLocation.locationId,
            stationName: firstLocation.name,
            stationStatus: firstLocation.status,
            userLocation: firstLocation.searchLocation,
          ),
        const RMSeparator(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              children: [
                for (final location in nearbyLocations) ...[
                  _locationListTile(context, location),
                ],
                if (nearbyLocations.isEmpty) ...[
                  const SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.noStationsFound,
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.thereArentAnyStationsNearYourLocations,
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
                ],
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.modalFlowDismissed());

                      BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);

                      final locationState = BlocProvider.of<LocationBloc>(context).state;
                      switch (locationState) {
                        case LocationProvided(userLocation: final location):
                          BlocProvider.of<MapOverlayBloc>(context)
                              .add(MapOverlayEvent.waitForMapToSettle((context) async {
                            final mapBloc = BlocProvider.of<MapBloc>(context);
                            BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.loadSearchResults(
                              AppLocalizations.of(context)!.nearbyStations,
                              mapBloc.state.mapItems,
                              mapBloc.state.searchResultPinLocation,
                            ));
                          }));
                          BlocProvider.of<MapBloc>(context).add(MapEvent.moveMapToLocation(
                            location.latitude,
                            location.longitude,
                            const MapLocationPinSelection.none(),
                          ));
                        default:
                          break;
                      }
                    },
                    child: Center(
                        child: Text(
                      AppLocalizations.of(context)!.findMoreStationsNearby,
                      textAlign: TextAlign.center,
                    ))),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.manualEvseIdInputTapped());
                    },
                    child: Center(
                        child: Text(
                      AppLocalizations.of(context)!.manualEVSEIDInput,
                      textAlign: TextAlign.center,
                    )))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _locationListTile(BuildContext context, StartChargingLocationMetadata location) {
    return BlocBuilder<ChargeNowBloc, ChargeNowState>(
      buildWhen: (previous, current) {
        // Only rebuild when loading state changes for this specific location
        final prevLoading = previous is SelectYourChargeStation && previous.loadingEvseId == location.evseId;
        final currLoading = current is SelectYourChargeStation && current.loadingEvseId == location.evseId;
        return prevLoading != currLoading;
      },
      builder: (context, state) {
        final isLoading = state is SelectYourChargeStation && state.loadingEvseId == location.evseId;

        return Column(
          children: [
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: Text(location.address,
                      overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall)),
            ]),
            const SizedBox(height: 18),
            const RMSeparator(),
            RMLoadingInkwellButton(
              isLoading: isLoading,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              leadingIcon: RMChargingPortStatusIcon(chargePortStatus: location.status),
              leadingIconPadding: const EdgeInsets.only(right: 14),
              onPressed: () {
                BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.chargingStationSelected(location));
              },
              child: Text(location.displayId, style: Theme.of(context).textTheme.labelMedium),
            ),
            const RMSeparator(
              color: RMColors.separatorLightGrey,
            ),
          ],
        );
      },
    );
  }
}
