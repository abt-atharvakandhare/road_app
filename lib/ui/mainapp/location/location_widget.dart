import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return switch (state) {
          Initial() => Center(
              child: Text(AppLocalizations.of(context)!.initialisingLocationService),
            ),
          ShouldAskForPermission() => Column(mainAxisSize: MainAxisSize.min, children: [
              Text(AppLocalizations.of(context)!.grantLocationPermissionToUseThisFeature),
              RMTextButton(
                  onPressed: () {
                    BlocProvider.of<LocationBloc>(context).add(const LocationEvent.requestPermission());
                  },
                  text: AppLocalizations.of(context)!.requestPermission),
            ]),
          PermissionDenied() => Center(
              child: Text(
                  AppLocalizations.of(context)!.locationPermissionDeniedForThisAppPleaseEnableItInYourDeviceSettings),
            ),
          PermissionGranted() => Center(
              child: Text(AppLocalizations.of(context)!.locationPermissionGranted),
            ),
          LocationProvided(:final userLocation) => Center(
              child: Text('locationProvided: $userLocation'),
            ),
          ServiceDisabled() => Center(
              child: Text(AppLocalizations.of(context)!.locationServicesHaveBeenDisabledForThisApp),
            ),
        };
      },
    );
  }
}
