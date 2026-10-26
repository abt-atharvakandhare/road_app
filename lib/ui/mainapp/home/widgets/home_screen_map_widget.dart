import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_mobile/defines.dart';

import '../../location/bloc/location_bloc.dart';

class HomeScreenMapWidget extends StatefulWidget {
  const HomeScreenMapWidget({super.key});

  @override
  State<HomeScreenMapWidget> createState() => _HomeScreenMapWidgetState();
}

class _HomeScreenMapWidgetState extends State<HomeScreenMapWidget> {
  GoogleMapController? _mapController;
  LatLng? _lastMapPosition;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: AbsorbPointer(
        child: BlocConsumer<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state case LocationProvided(:final userLocation)) {
                _lastMapPosition = LatLng(userLocation.latitude, userLocation.longitude);
                _mapController?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(userLocation.latitude, userLocation.longitude), zoom: 16)));
              }
            },
            buildWhen: (_, _) => false,
            builder: (context, state) {
              final LatLng mapCenter = switch (state) {
                LocationProvided(:final userLocation) => LatLng(userLocation.latitude, userLocation.longitude),
                _ => const LatLng(AppDefaults.defaultMapLatitude, AppDefaults.defaultMapLongitude),
              };

              return GoogleMap(
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: mapCenter,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;

                    if (_lastMapPosition != null) {
                      _mapController?.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(target: _lastMapPosition!, zoom: 16)));
                    } else if (state case LocationProvided(:final userLocation)) {
                      _mapController?.moveCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: LatLng(userLocation.latitude, userLocation.longitude), zoom: 16)));
                    }
                  });
            }),
      ),
    );
  }
}
