import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/defines.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/debug_controls/cubit/debug_controls_repo.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/ev_map_tools.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart' as overlay;
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart' as loc;
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/onboarding/login/login_screen.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/maps_utils.dart';
import 'package:road_mobile/ui/utils/widgets/rm_modal_info_dialog.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import 'bloc/map_bloc.dart';
import 'map_location_item.dart';
import '../favourites/favourites_widget.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  final searchResultMarkerId = const MarkerId('geocoding_result');
  bool debugLocationIsDirty = false;

  @override
  void initState() {
    super.initState();

    final mapBloc = BlocProvider.of<MapBloc>(context);
    if (mapBloc.mapBounds == null) {
      final locationState = BlocProvider.of<loc.LocationBloc>(context).state;
      final LatLng mapCenter = switch (locationState) {
        loc.LocationProvided(:final userLocation) => LatLng(userLocation.latitude, userLocation.longitude),
        _ => const LatLng(AppDefaults.defaultMapLatitude, AppDefaults.defaultMapLongitude),
      };

      mapBloc.mapBounds = RMLatLngBounds.fromCenterAndRadius(mapCenter.latitude, mapCenter.longitude, 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state.flow.isError) {
          getIt<ModalInfoDialogs>().showErrorDialog(context, state.flow.error);
        }
        switch (state) {
          case ChargingStations(:final moveToLocation) when moveToLocation != null:
            _moveCameraToLocation(context, moveToLocation, null, true);
            break;
          default:
            break;
        }
      },
      buildWhen: (previous, current) {
        if (debugLocationIsDirty) {
          debugLocationIsDirty = false;
          return true;
        }
        return previous.shouldRebuild(current);
      },
      builder: (context, state) {
        final Set<Marker> markers = switch (state) {
          ChargingStations(:final mapItems) => mapItems.map((mapLocationItem) {
              return mapLocationItem.toMarker(onTap: () async {
                final mapBloc = BlocProvider.of<MapBloc>(context);
                if (mapLocationItem.count > 1) {
                  if (mapBloc.zoomLevel == null || mapBloc.zoomLevel! <= 15) {
                    final newZoomLevel = mapBloc.zoomLevel != null ? (mapBloc.zoomLevel! + 1) : 15.0;
                    mapBloc.add(const MapEvent.removePinSelection(false));
                    BlocProvider.of<overlay.MapOverlayBloc>(context)
                        .add(const overlay.MapOverlayEvent.resetToInitial());
                    _moveCameraToLocation(context, mapLocationItem.position, newZoomLevel, false);
                    return;
                  }
                }

                log('Map item tapped: ${mapLocationItem.position.latitude}-${mapLocationItem.position.longitude}');
                BlocProvider.of<overlay.MapOverlayBloc>(context)
                    .add(overlay.MapOverlayEvent.mapLocationSelectedOnMap(mapLocationItem));

                mapBloc.add(MapEvent.userTappedLocation(mapLocationItem.position));

                // Let map bounds settle before moving - ToDo - this is the jumping map overlay issue
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  _moveCameraToLocation(context, mapLocationItem.position, null, true);
                }
              });
            }).toSet()
        };

        final locationState = BlocProvider.of<loc.LocationBloc>(context).state;
        final mapBloc = BlocProvider.of<MapBloc>(context);
        final lastMapCenter = mapBloc.lastMapCenter;
        final lastZoom = mapBloc.zoomLevel;

        final LatLng mapCenter = lastMapCenter ??
            switch (locationState) {
              loc.LocationProvided(:final userLocation) => LatLng(userLocation.latitude, userLocation.longitude),
              _ => const LatLng(AppDefaults.defaultMapLatitude, AppDefaults.defaultMapLongitude),
            };

        switch (state) {
          case ChargingStations(:final searchResultPinLocation) when searchResultPinLocation != null:
            markers.add(Marker(
              markerId: searchResultMarkerId,
              position: searchResultPinLocation,
              infoWindow: InfoWindow(title: AppLocalizations.of(context)!.searchLocation),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ));
            break;
          default:
            break;
        }

        if (getIt<DebugControlsRepo>().areDebugControlsEnabled) {
          switch (locationState) {
            case loc.LocationProvided(:final userLocation):
              markers.add(Marker(
                markerId: const MarkerId("user_location"),
                position: LatLng(userLocation.latitude, userLocation.longitude),
                infoWindow: const InfoWindow(title: "Debug location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                onTap: () {
                  BlocProvider.of<loc.LocationBloc>(context).add(const loc.LocationEvent.useDebugLocation(null));
                  debugLocationIsDirty = true;
                  _reloadMapData(context);
                },
              ));
              break;
            default:
              break;
          }
        }

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildMapWidget(CameraPosition(target: mapCenter, zoom: lastZoom ?? 16), markers),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                      heroTag: 'favourite_button',
                      onPressed: () => _showFavouriteStationsDialog(context),
                      backgroundColor: RMColors.lightGreyBackground,
                      child: SvgPicture.asset('assets/icons/favourite_on_large.svg',
                          colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn))),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                      heroTag: 'location_button',
                      onPressed: () => _moveCameraToCurrentLocationTapped(context),
                      backgroundColor: RMColors.lightGreyBackground,
                      child: const Icon(Icons.my_location, color: Colors.black54)),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildMapWidget(CameraPosition initialCameraPosition, Set<Marker> markers) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocConsumer<overlay.MapOverlayBloc, overlay.MapOverlayState>(
          listenWhen: (previous, current) =>
              previous.overlayIsShowing != current.overlayIsShowing && !current.overlayIsShowing,
          listener: (context, overlayState) async {
            if (!Platform.isIOS) {
              await Future.delayed(const Duration(milliseconds: 100)); // Let map bounds settle before moving
              if (context.mounted) {
                await _reloadMapData(context);
              }
            }
          },
          buildWhen: (previous, current) => previous.overlayIsShowing != current.overlayIsShowing,
          builder: (context, overlayState) {
            final mapId = Platform.isIOS ? '4c689d3047124208' : 'bc87b49eb207fbd3';
            return GoogleMap(
                rotateGesturesEnabled: false,
                onMapCreated: (controller) async {
                  _mapController = controller;
                },
                initialCameraPosition: initialCameraPosition,
                onCameraIdle: () async {
                  await _reloadMapData(context);
                },
                onLongPress: (argument) {
                  if (getIt<DebugControlsRepo>().areDebugControlsEnabled) {
                    final userLocation =
                        UserLocation(latitude: argument.latitude, longitude: argument.longitude, accuracy: 5);
                    BlocProvider.of<loc.LocationBloc>(context).add(loc.LocationEvent.useDebugLocation(userLocation));
                    debugLocationIsDirty = true;
                    _reloadMapData(context);
                  }
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                  ),
                },
                markers: markers,
                myLocationButtonEnabled: false, // Android draws this button in a bad location
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapId: mapId);
          });
    });
  }

  Future<void> _reloadMapData(BuildContext context) async {
    final visibleRegion = await _mapController?.getVisibleRegion();
    final zoomLevel = await _mapController?.getZoomLevel();

    if (context.mounted && visibleRegion != null && zoomLevel != null) {
      BlocProvider.of<MapBloc>(context).add(MapEvent.regionUpdated(mapBounds: visibleRegion, zoomLevel: zoomLevel));

      BlocProvider.of<overlay.MapOverlayBloc>(context).mapRegionUpdated(visibleRegion.northeast.latitude,
          visibleRegion.northeast.longitude, visibleRegion.southwest.latitude, visibleRegion.southwest.longitude);
    }
  }

  void _showFavouriteStationsDialog(BuildContext context) {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (!authState.isLoggedIn) {
      LoginScreen.pushAsModal(context);
      return;
    }
    FavouritesWidget.pushAsModal(context);
  }

  void _moveCameraToCurrentLocationTapped(BuildContext context) {
    final locationState = BlocProvider.of<loc.LocationBloc>(context).state;
    switch (locationState) {
      case loc.Initial():
        BlocProvider.of<loc.LocationBloc>(context).add(const loc.LocationEvent.checkServiceStatus());
        break;
      case loc.LocationProvided(:final userLocation):
        _moveCameraToLocation(context, LatLng(userLocation.latitude, userLocation.longitude), null, false);
        break;
      case loc.ShouldAskForPermission():
        BlocProvider.of<loc.LocationBloc>(context).add(const loc.LocationEvent.requestPermission());
        break;
      case loc.PermissionGranted():
        break;
      case loc.PermissionDenied():
        _sendUserToSettings(context, false);
        break;
      case loc.ServiceDisabled():
        _sendUserToSettings(context, true);
        break;
    }
  }

  // location is either disabled or denied
  void _sendUserToSettings(BuildContext context, bool locationIsDisabled) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.enableLocationServices),
            content: Text(
              AppLocalizations.of(context)!.pleaseAllowLocationUpdates,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.later),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppSettings.openAppSettings(
                      type: locationIsDisabled ? AppSettingsType.location : AppSettingsType.settings);
                },
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ],
          );
        });
  }

  void _moveCameraToLocation(BuildContext context, LatLng location, double? newZoomLevel, bool aboveOverlay) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final currentZoom = await controller.getZoomLevel();
    final visibleBounds = await controller.getVisibleRegion();
    final centerOfVisibleBounds = LatLng((visibleBounds.northeast.latitude + visibleBounds.southwest.latitude) / 2,
        (visibleBounds.northeast.longitude + visibleBounds.southwest.longitude) / 2);

    final CameraUpdate cameraUpdate;

    final bool targetDoesntCauseMapMove;
    if (aboveOverlay) {
      final visibleLatRange = visibleBounds.northeast.latitude - visibleBounds.southwest.latitude;
      final neScreenCoord = await controller.getScreenCoordinate(visibleBounds.northeast);
      final swScreenCoord = await controller.getScreenCoordinate(visibleBounds.southwest);
      final double visibleMapScreenRange = swScreenCoord.y.toDouble() - neScreenCoord.y.toDouble();

      if (!context.mounted) {
        return;
      }

      // Android returns the screen range in device pixels, iOS in points.
      final double targetScreenCoord;
      if (Platform.isAndroid) {
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        targetScreenCoord = 150.0 * devicePixelRatio; // Overlay will always leave us 300pt at the top
      } else {
        targetScreenCoord = 150.0;
      }

      double latOf200px = (targetScreenCoord / visibleMapScreenRange) * visibleLatRange;

      final latAt200PxDown = location.latitude - (visibleLatRange / 2) + latOf200px;
      final targetLatLng = LatLng(latAt200PxDown, location.longitude);

      targetDoesntCauseMapMove = centerOfVisibleBounds.isVeryCloseTo(targetLatLng);

      cameraUpdate = CameraUpdate.newLatLngZoom(targetLatLng, newZoomLevel ?? currentZoom);
    } else {
      targetDoesntCauseMapMove = centerOfVisibleBounds.isVeryCloseTo(location);

      cameraUpdate = CameraUpdate.newLatLngZoom(location, newZoomLevel ?? 15);
    }

    if (targetDoesntCauseMapMove && context.mounted) {
      // If the map probably won't move, reload the data to allow the overlay state machine to know that
      // the map has settled.
      await _reloadMapData(context);
    }

    controller.animateCamera(cameraUpdate);
  }
}
