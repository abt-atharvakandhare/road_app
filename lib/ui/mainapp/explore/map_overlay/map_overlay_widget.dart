import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/autocomplete_widget.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/widgets/initial_widget.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../map/bloc/map_bloc.dart';
import 'widgets/charging_location_details_widget.dart';
import 'widgets/search_results/search_results_widget.dart';

class MapOverlayWidget extends StatefulWidget {
  const MapOverlayWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MapOverlayWidgetState();
}

class _MapOverlayWidgetState extends State<MapOverlayWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      return;
    }

    // When the user taps the search field, we want to have the search results take over the screen.
    // Once they have, text changes drive the search. Focus also returns here whenever a dialog
    // closes, and re-running a failed query at that point would reopen its error dialog.
    final mapOverlayBloc = BlocProvider.of<MapOverlayBloc>(context);
    if (mapOverlayBloc.state is TypeAheadSearchResults) {
      return;
    }
    mapOverlayBloc.add(MapOverlayEvent.searchQuery(mapOverlayBloc.searchFieldController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapOverlayBloc, MapOverlayState>(listener: (context, mapOverlayState) {
      if (mapOverlayState.flow.isError) {
        getIt<ModalInfoDialogs>().showErrorDialog(context, mapOverlayState.flow.error);
      }

      switch (mapOverlayState) {
        case Initial():
          BlocProvider.of<MapOverlayBloc>(context).searchFieldController.clear();
          _focusNode.unfocus();
        case ShowChargingStationResults(:final searchBoxText?):
          _focusNode.unfocus();
          BlocProvider.of<MapOverlayBloc>(context).searchFieldController.text = searchBoxText;
        default:
          break;
      }
    }, builder: (context, mapOverlayState) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (previousChildren.isNotEmpty) previousChildren.first,
              ?currentChild,
            ],
          );
        },
        child: switch (mapOverlayState) {
          Initial() => InitialWidget(searchBoxWidget: _buildBasicSearchBox(context)),
          TypeAheadSearchResults(:final results) =>
            AutocompleteWidget(searchBoxWidget: _buildBasicSearchBox(context), results: results),
          WaitingForMapToSettle(:final onMapSettled) => BlocListener<MapBloc, MapState>(
              listener: (context, mapState) {
                if (!mapState.flow.isLoading) {
                  onMapSettled(context);
                }
              },
              child: const SizedBox(),
            ),
          ShowChargingStationResults(:final locations) =>
            SearchResultsWidget(searchBoxWidget: _buildBasicSearchBox(context), locations: locations),
          ShowChargingStation(:final mapLocations, :final fromFavourites) => ChargingLocationDetailsWidget(
              key: ValueKey(mapLocations.valueKeyString),
              mapLocations: mapLocations,
              resetOnClose: fromFavourites,
            ),
        },
      );
    });
  }

  Widget _buildBasicSearchBox(BuildContext context) {
    final mapOverlayBloc = BlocProvider.of<MapOverlayBloc>(context);
    return TextField(
      key: mapOverlayBloc.searchFieldKey,
      controller: mapOverlayBloc.searchFieldController,
      focusNode: _focusNode,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: RMColors.separatorDarkGrey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: RMColors.separatorDarkGrey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          labelText: AppLocalizations.of(context)!.searchAddressOrPlaceName,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: RMColors.searchTextGrey),
          suffixIcon: (mapOverlayBloc.searchFieldController.text.isEmpty)
              ? const Icon(Icons.search)
              : IconButton(
                  onPressed: () {
                    BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.resetToInitial());
                    BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(false));
                  },
                  icon: const Icon(Icons.close))),
      onChanged: (value) {
        BlocProvider.of<MapOverlayBloc>(context).add(MapOverlayEvent.searchQuery(value));
      },
      onSubmitted: (value) => _focusNode.unfocus(),
    );
  }
}
