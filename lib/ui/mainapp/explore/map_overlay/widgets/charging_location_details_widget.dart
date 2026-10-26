import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';
import 'package:road_mobile/flavors.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/charge_now/charge_now_root_screen.dart';
import 'package:road_mobile/ui/mainapp/report_problem/widgets/report_problem_entry_link.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/onboarding/widgets/signup_now_widget.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/ui/utils/widgets/rm_evse_connector_accordion.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_details_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_secondary_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_location_pictures_accordion.dart';
import 'package:road_mobile/ui/utils/widgets/rm_street_view_accordion.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/widgets/snackbar.dart';

import '../../favourites/bloc/favourites_cubit.dart';
import '../../map/bloc/map_bloc.dart';
import '../bloc/map_overlay_bloc.dart';

const double _maxWidgetHeight = 0.66; // Fully extended, give 1/3 of the space available to the map.
const double estimatedHeaderHeight = 80;

class ChargingLocationDetailsWidget extends StatefulWidget {
  // Can the map and the map drawer get out of sync? Harmen's bug whereby 2 charging stations,
  // but one shows in the drawer as available.
  const ChargingLocationDetailsWidget({super.key, required this.mapLocations, required this.resetOnClose});

  final List<MapLocationV2> mapLocations;
  final bool resetOnClose;

  @override
  State<ChargingLocationDetailsWidget> createState() => _ChargingLocationDetailsWidgetState();
}

class _ChargingLocationDetailsWidgetState extends State<ChargingLocationDetailsWidget> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool haveOrCanAddCreditCard = false;
    bool isLoggedIn = false;

    final authState = BlocProvider.of<AuthCubit>(context).state;
    switch (authState) {
      case LoggedIn(:final profile):
        haveOrCanAddCreditCard = F.isRemoteChargeEnabled && (profile.hasCreditCard || profile.canAddCreditCard);
        isLoggedIn = true;
      default:
        break;
    }

    List<Widget> scrollableWidgets = [];

    // Location details. We assume for a LocationMapItem, which is a group of locations sharing the exact same LatLng,
    // that all locations are the same.

    final location = widget.mapLocations[pageIndex];

    String availabilityCountString = location.availabilityCountString;

    scrollableWidgets.addAll([
      RMLocationDetailsWidget(
        location: location,
        locationAvailability: location.chargingStatus,
        availabilityCountString: availabilityCountString,
      ),
      const SizedBox(height: 10),
      const RMSeparator(color: RMColors.rmDisabledGray),
    ]);

    final languageCode = Localizations.localeOf(context).languageCode;

    // Sort EVSEs: available first, then charging, then unavailable
    final sortedEvses = List<Evse>.from(location.evses)
      ..sort((a, b) {
        const order = {
          ChargingPortAvailability.available: 0,
          ChargingPortAvailability.charging: 1,
          ChargingPortAvailability.notAvailable: 2,
        };
        return (order[a.chargingPortAvailability] ?? 2)
            .compareTo(order[b.chargingPortAvailability] ?? 2);
      });

    // Add the EVSEs as accordions
    for (final evse in sortedEvses) {
      for (final connector in evse.connectors) {
        final tariffModel = TariffModel.fromTariff(connector.tariff, additionalCharges: location.cdrAdditionalCharges);
        final specialTariffModels = (evse.userSpecialTariffs ?? [])
            .map(
              (e) => TariffModel.fromTariff(
                e.tariff,
                name: e.getTariffNameForLanguage(languageCode),
                additionalCharges: location.cdrAdditionalCharges,
              ),
            )
            .toList();

        final showChargeNow = evse.stationSupportsRfidCharging ||
            (evse.stationSupportsCreditCardCharging && haveOrCanAddCreditCard);

        scrollableWidgets.addAll([
          RMEvseConnectorAccordion(
            key: ValueKey('${pageIndex}_${evse.evseId}_${connector.id}'),
            evse: evse,
            connector: connector,
            location: location,
            tariffModel: tariffModel,
            specialTariffModels: specialTariffModels,
            showChargeNow: showChargeNow,
            onChargeNowPressed: () {
              _onChargeNowTapped(context, location, evse, connector, isLoggedIn);
            },
          ),
          const RMSeparator(color: RMColors.separatorLightGrey),
        ]);
      }
    }

    // OCPI pictures take precedence (DRI-770); Street View is the fallback for
    // locations without any (DRI-749).
    final locationImages = location.images ?? const <LocationImage>[];
    final streetViewLatLng = location.geoLocation?.latLng;
    if (locationImages.isNotEmpty) {
      scrollableWidgets.addAll([
        RMLocationPicturesAccordion(
          key: ValueKey('location_pictures_${pageIndex}_${location.id}'),
          images: locationImages,
        ),
        const RMSeparator(color: RMColors.separatorLightGrey),
      ]);
    } else if (streetViewLatLng != null) {
      scrollableWidgets.addAll([
        RMStreetViewAccordion(
          key: ValueKey('street_view_${pageIndex}_${location.id}'),
          latitude: streetViewLatLng.latitude,
          longitude: streetViewLatLng.longitude,
        ),
        const RMSeparator(color: RMColors.separatorLightGrey),
      ]);
    }

    scrollableWidgets.addAll([
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: RMSecondaryTextButton(
              onPressed: () {
                final latLng = location.geoLocation?.latLng;
                if (latLng != null) {
                  _openMapsSheet(context, latLng.latitude, latLng.longitude, location.address ?? 'Charging Location');
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/directions.svg',
                    colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.getDirections),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildShareButton(context, location),
        ],
      ),
      const SizedBox(height: 20),
      ReportProblemEntryLink(
        prompt: ReportProblemPrompt.station,
        locationId: location.id ?? '',
      ),
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: RMColors.rmPrimaryBackground,
          // Header
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeadItem(context, location),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const RMSeparator(),
                    // Scrollable content
                    Container(
                      padding: const EdgeInsets.only(right: 24),
                      constraints: BoxConstraints(
                        maxHeight: (constraints.maxHeight * _maxWidgetHeight) - estimatedHeaderHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: scrollableWidgets,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.only(right: 22),
      onPressed: () {
        if (widget.resetOnClose) {
          BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.resetToInitial());
          BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(false));
        } else {
          BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.backToChargingStationResults());
          BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(true));
        }
      },
      icon: const Icon(Icons.close, size: 29),
    );
  }

  Widget _buildHeadItem(BuildContext context, MapLocationV2 location) {
    if (widget.mapLocations.length >= 2) {
      return IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [..._buildPageSwitcher(context), const Spacer(), _buildCloseButton(context)]),
              _buildAddressLine(context, location),
            ],
          ),
        ),
      );
    } else {
      return Row(
        children: [
          const SizedBox(width: 16),
          _buildAddressLine(context, location),
          Align(alignment: Alignment.centerRight, child: _buildCloseButton(context)),
        ],
      );
    }
  }

  List<Widget> _buildPageSwitcher(BuildContext context) {
    return [
      IconButton(
        onPressed: pageIndex == 0
            ? null
            : () {
                if (pageIndex > 0) {
                  setState(() {
                    pageIndex--;
                  });
                }
              },
        icon: const Icon(Icons.chevron_left),
      ),
      Text('${pageIndex + 1} / ${widget.mapLocations.length}', style: Theme.of(context).textTheme.headlineSmall),
      IconButton(
        onPressed: pageIndex == widget.mapLocations.length - 1
            ? null
            : () {
                if (pageIndex < widget.mapLocations.length - 1) {
                  setState(() {
                    pageIndex++;
                  });
                }
              },
        icon: const Icon(Icons.chevron_right),
      ),
      const Spacer(),
    ];
  }

  Widget _buildAddressLine(BuildContext context, MapLocationV2 location) {
    final isLoggedIn = BlocProvider.of<AuthCubit>(context).state.isLoggedIn;

    return Expanded(
      child: Row(
        children: [
          BlocBuilder<FavouritesCubit, FavouritesState>(
            builder: (context, state) {
              final isFavourite = isLoggedIn && state.isFavourite(location.id);
              return IconButton(
                onPressed: () {
                  _onFavouriteTapped(context, location);
                },
                icon: SvgPicture.asset(
                  isFavourite ? 'assets/icons/favourite_on_small.svg' : 'assets/icons/favourite_off_small.svg',
                  colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location.address ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _onFavouriteTapped(BuildContext context, MapLocationV2 location) async {
    final locationId = location.id;
    if (locationId == null) {
      log('Location ID is null');
      return;
    }

    final isLoggedIn = BlocProvider.of<AuthCubit>(context).state.isLoggedIn;

    if (!isLoggedIn) {
      LoginScreen.pushAsModal(context);
    } else {
      final isFavourite = BlocProvider.of<FavouritesCubit>(context).state.isFavourite(locationId);
      final didToggle = await BlocProvider.of<FavouritesCubit>(context).toggleFavourite(locationId);

      if (context.mounted && didToggle) {
        showStyledSnackbar(
          context,
          SvgPicture.asset(
            'assets/icons/favourite_on_small.svg',
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          isFavourite
              ? AppLocalizations.of(context)!.removedFromYourFavourites
              : AppLocalizations.of(context)!.stationAddedToYourFavourites,
          interrupt: true,
        );
      }
    }
  }

  Widget _buildShareButton(BuildContext context, MapLocationV2 location) {
    return Builder(
      builder: (buttonContext) {
        return SizedBox(
          width: 48,
          height: 48,
          child: TextButton(
            onPressed: () {
              _onShareTapped(buttonContext, location);
            },
            style: TextButton.styleFrom(
              foregroundColor: RMColors.rmPrimaryColor,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              side: BorderSide(color: RMColors.rmPrimaryColor),
              shape: const CircleBorder(),
            ),
            child: Icon(
              Platform.isIOS ? Icons.ios_share : Icons.share,
              size: 20,
              semanticLabel: AppLocalizations.of(buttonContext)!.shareLocation,
            ),
          ),
        );
      },
    );
  }

  void _onShareTapped(BuildContext buttonContext, MapLocationV2 location) {
    final latLng = location.geoLocation?.latLng;
    if (latLng == null) {
      log('Cannot share location without coordinates');
      return;
    }

    // On iPad the share sheet is a popover anchored to the originating rect.
    final box = buttonContext.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}';
    final address = location.address;
    final text = (address == null || address.isEmpty) ? mapsUrl : '$address\n$mapsUrl';

    SharePlus.instance.share(ShareParams(text: text, subject: address, sharePositionOrigin: sharePositionOrigin));
  }

  void _openMapsSheet(BuildContext context, double latitude, double longitude, String title) async {
    try {
      final location = LocationCoords(latitude, longitude, title: title);
      final availableMaps = installedMapsFor(
        markerMaps: await MapLauncher.marker(location).getSupportedMaps(MapApp.all),
        directionsMaps: await MapLauncher.directions(location).getSupportedMaps(MapApp.all),
      );

      if (!context.mounted) {
        return;
      }

      if (availableMaps.isEmpty) {
        final error = RMApiError(cause: 'No map applications installed');
        getIt<ModalInfoDialogs>().showErrorDialog(context, error);
        return;
      }

      if (availableMaps.length == 1) {
        availableMaps.first.show();
        return;
      }

      showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(AppLocalizations.of(context)!.chooseRoutingApp),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(24, 16, 24, 0), child: RMSeparator()),
                  for (final (index, map) in availableMaps.indexed) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        onTap: () {
                          map.show();
                          Navigator.pop(context);
                        },
                        title: Text(map.name, style: Theme.of(context).textTheme.headlineSmall),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Image.memory(map.iconBytes, height: 30.0, width: 30.0),
                        ),
                      ),
                    ),
                    if (index < availableMaps.length - 1)
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: RMSeparator()),
                  ],
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      log('Error opening maps: $e');
    }
  }

  void _onChargeNowTapped(
    BuildContext context,
    MapLocationV2 location,
    Evse evse,
    Connector connector,
    bool isLoggedIn,
  ) {
    final event = ChargeNowEvent.chargingStationSelectedFromMap(location, evse, connector);
    if (!isLoggedIn) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return const SignupNowWidget(
            motivation: SignupNowMotivation.makePayments,
            style: SignupNowStyle.singleContainer,
          );
        },
      );
    } else {
      ChargeNowRootScreen.pushAsModal(context, chargeEvent: event);
    }
  }
}

/// The installed map apps to offer for a location, each launchable via [SupportedMap.show].
///
/// Apps that can drop a pin come from [markerMaps]. Navigation-only apps (Waze, Flitsmeister,
/// Citymapper, ...) reject marker requests, so they come from [directionsMaps] and open
/// directions to the location.
@visibleForTesting
List<SupportedMap> installedMapsFor({
  required List<SupportedMap> markerMaps,
  required List<SupportedMap> directionsMaps,
}) {
  final markerMapIds = {for (final map in markerMaps) map.map.id};
  return [
    ...markerMaps,
    ...directionsMaps.where((map) => !markerMapIds.contains(map.map.id)),
  ].where((map) => map.isInstalled).toList();
}
