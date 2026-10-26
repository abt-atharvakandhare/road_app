import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/model/locations/geo_location_result.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../../map/bloc/map_bloc.dart';
import '../bloc/map_overlay_bloc.dart';

class AutocompleteWidget extends StatelessWidget {
  const AutocompleteWidget({super.key, required this.searchBoxWidget, required this.results});

  final Widget searchBoxWidget;
  final List<GeoLocationResult>? results;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RMColors.rmPrimaryBackground,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                    onPressed: () {
                      BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.resetToInitial());
                      BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(false));
                    },
                    icon: const Icon(Icons.close)),
                const SizedBox(width: 10)
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: searchBoxWidget,
            ),
            const RMSeparator(edgeInsets: EdgeInsets.symmetric(horizontal: 24)),
            if (results != null) ...[
              Expanded(
                // The root Container(color:) above is a ColoredBox, and ListTile
                // paints its background + ink splashes on the nearest Material
                // ancestor. Without an intervening Material the ColoredBox hides
                // those effects (Flutter asserts this in debug builds). A
                // transparency Material gives the rows a Material to paint on
                // while keeping the panel background showing through.
                child: Material(
                  type: MaterialType.transparency,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: results!.isEmpty ? 1 : results!.length,
                    itemBuilder: (context, index) {
                      if (results!.isEmpty) {
                        return ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Row(
                            children: [
                              SvgPicture.asset('assets/icons/position_target.svg',
                                  colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn)),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.useMyCurrentPosition,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          onTap: () {
                            final target = switch (BlocProvider.of<LocationBloc>(context).state) {
                              LocationProvided(userLocation: final location) => location,
                              _ => null,
                            };

                            if (target == null) {
                              getIt<ModalInfoDialogs>()
                                  .showErrorDialog(context, RMApiError(cause: 'Location not available'));
                            } else {
                              BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.waitForMapToSettle((context) {
                                var searchLocation = BlocProvider.of<MapBloc>(context).state.searchResultPinLocation;
                                final locationState = BlocProvider.of<LocationBloc>(context).state;
                                if (locationState case LocationProvided(userLocation: final userLocation)) {
                                  searchLocation = LatLng(userLocation.latitude, userLocation.longitude);
                                }

                                BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.loadSearchResults(
                                  AppLocalizations.of(context)!.myCurrentPosition,
                                  BlocProvider.of<MapBloc>(context).state.mapItems,
                                  searchLocation,
                                ));
                              }));
                              BlocProvider.of<MapBloc>(context).add(MapEvent.moveMapToLocation(
                                  target.latitude, target.longitude, const MapLocationPinSelection.none()));
                            }
                          },
                        );
                      }

                      final GeoLocationResult result = results![index];

                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        title: Text(result.primaryText, style: Theme.of(context).textTheme.headlineSmall),
                        subtitle: Text(result.secondaryText,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400)),
                        onTap: () {
                          BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.waitForMapToSettle((context) {
                            BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.loadSearchResults(
                              result.primaryText,
                              BlocProvider.of<MapBloc>(context).state.mapItems,
                              BlocProvider.of<MapBloc>(context).state.searchResultPinLocation,
                            ));
                          }));
                          BlocProvider.of<MapBloc>(context).add(MapEvent.geoCodingResultSelected(result));
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const RMSeparator();
                    },
                  ),
                ),
              ),
              const RMSeparator(edgeInsets: EdgeInsets.symmetric(horizontal: 24)),
            ],
            if (results == null) const Spacer()
          ],
        ),
      ),
    );
  }
}
