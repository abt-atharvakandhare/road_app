import 'dart:developer' show log;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/ui/mainapp/explore/widgets/charging_station_list_item.dart';
import 'package:road_mobile/ui/mainapp/home/nearest_stations/widgets/low_speed_state_widget.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_navigation_cubit.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_cubit.dart';

class NearestStationsScreen extends StatefulWidget {
  final VoidCallback onExploreMap;

  const NearestStationsScreen({super.key, required this.onExploreMap});

  /// Push the screen in highway mode (speed-based, 50kW filter, heading, compass)
  static void pushAsFullScreen(BuildContext context) {
    _push(
      context,
      mode: NearestStationsMode.highway,
      onExploreMap: () {
        BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);
      },
    );
  }

  /// Push the screen in nearest mode (map filters, no speed check, always show)
  static void pushAsNearestStations(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final mapFilters = mapBloc.mapFilters.apiMapWithWorkarounds.cast<String, dynamic>();

    _push(context, mode: NearestStationsMode.nearest, mapFilters: mapFilters, onExploreMap: () {});
  }

  static void _push(
    BuildContext context, {
    required NearestStationsMode mode,
    Map<String, dynamic>? mapFilters,
    required VoidCallback onExploreMap,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (routeContext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: BlocProvider.of<MapBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<MapOverlayBloc>(context)),
              BlocProvider.value(value: BlocProvider.of<MainAppRootNavigationCubit>(context)),
              BlocProvider.value(value: BlocProvider.of<LocationBloc>(context)),
              BlocProvider.value(value: getIt<DebugControlsCubit>()),
              BlocProvider(
                create: (_) => getIt<NearestStationsCubit>(
                  param1: NearestStationsConfig(stationLimit: 20, mode: mode, mapFilters: mapFilters),
                ),
              ),
            ],
            child: NearestStationsScreen(
              onExploreMap: () {
                Navigator.of(routeContext).pop();
                onExploreMap();
              },
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<NearestStationsScreen> createState() => _NearestStationsScreenState();
}

class _NearestStationsScreenState extends State<NearestStationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch stations on init
    BlocProvider.of<NearestStationsCubit>(context).refresh();
  }

  /// Convert heading in degrees to compass direction using l10n strings
  String _getCompassDirection(double heading, BuildContext context) {
    // Normalize heading to 0-360 range
    final normalizedHeading = heading % 360;

    // Divide into 8 sectors (45 degrees each)
    final index = ((normalizedHeading + 22.5) / 45).floor() % 8;

    final localizations = AppLocalizations.of(context)!;

    switch (index) {
      case 0:
        return localizations.compassDirectionNorth;
      case 1:
        return localizations.compassDirectionNorthEast;
      case 2:
        return localizations.compassDirectionEast;
      case 3:
        return localizations.compassDirectionSouthEast;
      case 4:
        return localizations.compassDirectionSouth;
      case 5:
        return localizations.compassDirectionSouthWest;
      case 6:
        return localizations.compassDirectionWest;
      case 7:
        return localizations.compassDirectionNorthWest;
      default:
        return localizations.compassDirectionNorth;
    }
  }

  /// Build direction indicator with compass (only shown in highway mode)
  Widget? _buildDirectionIndicator(double? heading, BuildContext context) {
    if (heading == null) return null;

    final direction = _getCompassDirection(heading, context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          direction,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: RMColors.rmBlackText),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: heading * math.pi / 180, // Convert degrees to radians
          child: SvgPicture.asset('assets/icons/highway_compass.svg', width: 28, height: 28),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<NearestStationsCubit, NearestStationsState>(
          builder: (context, state) {
            // Hide title in low speed state (under 50km/h)
            if (state.isLowSpeed) {
              return const SizedBox.shrink();
            }

            // Choose title based on mode
            final title = state.mode == NearestStationsMode.highway
                ? AppLocalizations.of(context)!.fastStationsWithPower
                : AppLocalizations.of(context)!.nearestStations;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                // Only show road name in highway mode
                if (state.mode == NearestStationsMode.highway &&
                    state.currentRoadName != null &&
                    state.currentRoadName!.isNotEmpty)
                  Text(
                    AppLocalizations.of(context)!.onRoad(state.currentRoadName!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<NearestStationsCubit, NearestStationsState>(
            builder: (context, state) {
              // Only show direction indicator in highway mode (not low speed, not nearest mode) and heading is available
              if (state.mode == NearestStationsMode.highway &&
                  !state.isLowSpeed &&
                  state.userLocation?.heading != null) {
                final indicator = _buildDirectionIndicator(state.userLocation!.heading, context);
                if (indicator != null) {
                  return Padding(padding: const EdgeInsets.only(right: 16.0), child: indicator);
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        centerTitle: false,
      ),
      body: BlocConsumer<NearestStationsCubit, NearestStationsState>(
        listener: (context, state) {
          if (state.flow.isError) {
            getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await BlocProvider.of<NearestStationsCubit>(context).refresh();
                  },
                  child: Stack(
                    children: [
                      RMShimmerLoader(
                        isLoading: state.flow.isLoading && state.stations.isEmpty,
                        template: ShimmerTemplate.stationList,
                        child: state.isLowSpeed
                            ? const LowSpeedStateWidget()
                            : state.stations.isEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                      child: Center(child: _buildEmptyContent(context)),
                                    ),
                                  );
                                },
                              )
                            : _buildStationsListContent(context, state.stations, state.userLocation),
                      ),
                      BottomLoadingWidget(isLoading: state.flow.isLoading && state.stations.isNotEmpty),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildDebugFab(context),
    );
  }

  Widget? _buildDebugFab(BuildContext context) {
    return BlocBuilder<DebugControlsCubit, DebugControlsState>(
      builder: (context, debugState) {
        // Only show FAB when debug controls are enabled
        if (debugState is! DebugControlsEnabled) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () {
            if (debugState.isGpsSimulating) {
              BlocProvider.of<DebugControlsCubit>(context).stopGpsSimulation();
            } else {
              BlocProvider.of<DebugControlsCubit>(context).startGpsSimulation();
            }
          },
          backgroundColor: debugState.isGpsSimulating ? Colors.red : RMColors.rmPrimaryColor,
          icon: Icon(debugState.isGpsSimulating ? Icons.stop : Icons.play_arrow, color: Colors.white),
          label: Text(
            debugState.isGpsSimulating ? 'Stop GPS Sim' : 'Start GPS Sim',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.location_off, size: 64, color: RMColors.rmPrimaryColor),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.noNearbyStations,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.noChargingStationsFoundNearby,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: widget.onExploreMap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: RMColors.rmPrimaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            AppLocalizations.of(context)!.exploreMap,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: RMColors.rmPrimaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStationsListContent(BuildContext context, List<MapLocationV2> stations, UserLocation? userLocation) {
    return BlocBuilder<NearestStationsCubit, NearestStationsState>(
      builder: (context, state) {
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: false,
          itemCount: stations.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, color: RMColors.separatorDarkGrey, indent: 24, endIndent: 0),
          itemBuilder: (context, index) {
            final station = stations[index];
            return ChargingStationListItem(
              location: station,
              userLocation: userLocation,
              showDistance: true,
              onTap: () => _handleStationTap(context, station, state.mode),
            );
          },
        );
      },
    );
  }

  void _handleStationTap(BuildContext context, MapLocationV2 station, NearestStationsMode mode) {
    final latLng = station.geoLocation?.latLng;
    if (latLng == null) {
      log('latLng is null');
      return;
    }

    final mapLocationPinSelection = station.id == null
        ? MapLocationPinSelection.none()
        : MapLocationPinSelection.locationId(station.id!);

    // Close the screen first
    Navigator.of(context).pop();

    // Define action to show station on map
    void showStationOnMap(BuildContext ctx) {
      final mapBloc = BlocProvider.of<MapBloc>(ctx);
      final mapOverlayBloc = BlocProvider.of<MapOverlayBloc>(ctx);

      mapOverlayBloc.add(MapOverlayEvent.showMapLocation([station]));
      mapBloc.add(MapEvent.moveMapToLocation(latLng.latitude, latLng.longitude, mapLocationPinSelection));
    }

    if (mode == NearestStationsMode.nearest) {
      // Nearest mode: Already on map tab, execute immediately
      showStationOnMap(context);
    } else {
      // Highway mode: Switch to explore tab, then wait for map to settle
      BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);
      BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.waitForMapToSettle(showStationOnMap));
    }
  }
}
