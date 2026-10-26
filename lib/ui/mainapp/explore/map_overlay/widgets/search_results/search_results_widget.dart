import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/ui/mainapp/explore/map/map_location_item.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../../map/bloc/map_bloc.dart';
import '../../bloc/map_overlay_bloc.dart';

const double _maxWidgetHeight = 0.66; // Fully extended, give 1/3 of the space available to the map.

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key, required this.searchBoxWidget, required this.locations});

  final Widget searchBoxWidget;
  final List<MapLocationsResponseModel> locations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: double.infinity,
            color: RMColors.rmPrimaryBackground,
            child: BlocBuilder<MapBloc, MapState>(builder: (context, state) {
              return switch (state) {
                ChargingStations(
                  mapItems: final mapItems,
                  moveToLocation: _,
                  searchResultPinLocation: final searchResultPinLocation,
                  selection: _,
                  flow: _,
                ) =>
                  mapItems.isNotEmpty
                      ? _buildListOfResults(mapItems, searchResultPinLocation, constraints.maxHeight * _maxWidgetHeight)
                      : _buildNoResultsFound(context),
              };
            })),
      ]);
    });
  }

  Widget _buildNoResultsFound(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: searchBoxWidget,
        ),
        const RMSeparator(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20, 0, 0),
          child: Text(AppLocalizations.of(context)!.noChargeStationsFound,
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
          child: TextButton(
              onPressed: () {
                BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.resetToInitial());
                BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(false));
              },
              child: Text(AppLocalizations.of(context)!.trySearchingForAnotherLocation)),
        )
      ],
    );
  }

  Widget _buildListOfResults(List<MapLocationItem> mapItems, LatLng? pinLocation, double maxHeight) {
    const double estimatedHeaderHeight = 120;

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: searchBoxWidget,
        ),
        const RMSeparator(edgeInsets: EdgeInsets.symmetric(horizontal: 24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SearchResultsListWidget(
              locations: locations, pinLocation: pinLocation, maxHeight: maxHeight - estimatedHeaderHeight),
        ),
      ],
    );
  }
}

class SearchResultsListWidget extends StatelessWidget {
  const SearchResultsListWidget(
      {super.key, required this.locations, required this.pinLocation, required this.maxHeight});

  final List<MapLocationsResponseModel> locations;
  final LatLng? pinLocation;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemCount: locations.length < 3 ? locations.length : 3,
          itemBuilder: (context, index) {
            final result = locations[index];
            return _locationListTile(context, result);
          },
        ));
  }

  Widget _locationListTile(BuildContext context, MapLocationsResponseModel locations) {
    return InkWell(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: Text(locations.locationAddress,
                  overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: RMColors.rmPrimaryColor,
            )
          ]),
          const SizedBox(height: 18),
          const RMSeparator(),
          for (final location in locations.data) ...[
            for (final evse in location.evses) ...[
              for (final connector in evse.connectors) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(children: [
                    RMChargingPortStatusIcon(chargePortStatus: evse.chargingPortAvailability),
                    const SizedBox(width: 14),
                    Text(evse.uniqueEvseConnectorStringFor(connector), style: Theme.of(context).textTheme.labelMedium)
                  ]),
                ),
                const RMSeparator(),
              ],
            ]
          ],
        ],
      ),
      onTap: () {
        final geoLocation = locations.geoLocation;
        if (geoLocation != null) {
          BlocProvider.of<MapBloc>(context).add(MapEvent.moveMapToLocation(
            geoLocation.coordinates[1],
            geoLocation.coordinates[0],
            const MapLocationPinSelection.evseLocationIfPresent(),
          ));
        }

        BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.mapLocationSelectedInSearch(locations));
      },
    );
  }
}
