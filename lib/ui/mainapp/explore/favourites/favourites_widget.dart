import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/favourites/bloc/favourites_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_shimmer_loader.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';
import '../map/bloc/map_bloc.dart';
import 'favourite_list_item.dart';

class FavouritesWidget extends StatefulWidget {
  final VoidCallback onExploreMap;

  const FavouritesWidget({super.key, required this.onExploreMap});

  static void pushAsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: FavouritesWidget(
            onExploreMap: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  @override
  State<FavouritesWidget> createState() => _FavouritesWidgetState();
}

class _FavouritesWidgetState extends State<FavouritesWidget> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FavouritesCubit>(context).loadFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavouritesCubit, FavouritesState>(
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await BlocProvider.of<FavouritesCubit>(context).loadFavourites();
                },
                child: state.stations.isEmpty
                    ? _buildEmptyState(context, state.flow.isLoading)
                    : _buildFavouritesList(context, state.stationIds, state.stations),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 9, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.favouriteStations,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: const Divider(
              color: RMColors.separatorDarkGrey,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLoading) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: RMShimmerLoader(
          isLoading: isLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              SvgPicture.asset('assets/icons/favourite_on_large.svg',
                  colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn)),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.yourFavouriteStationsWillShowUpHere,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.markStationsAsFavouriteByPressingTheHeartIcon,
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: RMColors.rmPrimaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavouritesList(BuildContext context, List<String> stationIds, List<MapLocationV2> stations) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stations.length + 1,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: const Divider(
          color: RMColors.separatorDarkGrey,
        ),
      ),
      itemBuilder: (context, index) {
        if (index == stations.length) {
          return const SizedBox.shrink();
        }
        final station = stations[index];
        return FavouriteListItem(
          location: station,
          isFavourite: stationIds.contains(station.id),
          onFavouriteToggle: () async {
            final isFavourite = stationIds.contains(station.id);
            final didToggle = await BlocProvider.of<FavouritesCubit>(context).toggleFavourite(station.id);
            if (context.mounted && didToggle) {
              showStyledSnackbar(
                context,
                SvgPicture.asset('assets/icons/favourite_on_small.svg',
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                isFavourite
                    ? AppLocalizations.of(context)!.removedFromYourFavourites
                    : AppLocalizations.of(context)!.stationAddedToYourFavourites,
                interrupt: true,
              );
            }
          },
          onTap: () {
            final latLng = station.geoLocation?.latLng;
            if (latLng == null) {
              log('latLng is null');
              return;
            }
            Navigator.of(context).pop();
            BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.waitForMapToSettle((context) {
              BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.showMapLocation([station]));
              if (station.id != null) {
                BlocProvider.of<MapBloc>(context).add(MapEvent.selectLocationWithId(station.id!));
              }
            }));
            BlocProvider.of<MapBloc>(context).add(MapEvent.moveMapToLocation(
              latLng.latitude,
              latLng.longitude,
              const MapLocationPinSelection.none(),
            ));
          },
        );
      },
    );
  }
}
