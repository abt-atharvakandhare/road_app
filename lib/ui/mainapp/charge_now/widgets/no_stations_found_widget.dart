import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/mainapp/main_app_root_navigation_cubit.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';

class NoStationsFoundWidget extends StatelessWidget {
  const NoStationsFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/charging_station_large.svg',
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noStationsFound,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context)!.thereArentAnyStationsNearYou,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.modalFlowDismissed());
                BlocProvider.of<MainAppRootNavigationCubit>(context).switchToNavbarItem(NavbarItem.explore);
                BlocProvider.of<MapOverlayBloc>(context).add(const MapOverlayEvent.resetToInitial());
                BlocProvider.of<MapBloc>(context).add(const MapEvent.removePinSelection(false));
              },
              child: Text(AppLocalizations.of(context)!.exploreOrSearchForALocation))
        ],
      ),
    );
  }
}
