import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/data/model/locations/remote_sessions_available_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/location_widget.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';

import '../bloc/charge_now_bloc.dart';
import 'no_stations_found_widget.dart';

class DetectLocationWidget extends StatelessWidget {
  const DetectLocationWidget({super.key, required this.searchLocation, required this.searchLocations});

  final UserLocation? searchLocation;
  final List<RemoteSessionAvailableModel> searchLocations;

  @override
  Widget build(BuildContext context) {
    return RMContentBox(
      child: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          log('Listener: Location State: $state');

          if (state case LocationProvided(userLocation: final location)) {
            final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
            BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.receivedLocation(location, partyIds));
          }
        },
        builder: (context, state) {
          log('Builder: Location State: $state');
          return switch (state) {
            LocationProvided() => const NoStationsFoundWidget(),
            PermissionGranted() => const NoStationsFoundWidget(),
            _ => const LocationWidget(),
          };
        },
      ),
    );
  }
}
