import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/data/model/charging/charging_start_data_model.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/ui/utils/widgets/rm_station_direct_line_map_widget.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';
import 'package:road_mobile/ui/utils/widgets/tick_radio_list_tile.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';

class IsThisYouWidget extends StatelessWidget {
  const IsThisYouWidget({super.key, required this.selectedLocation});

  final StartChargingLocationMetadata selectedLocation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SvgPicture.asset('assets/icons/transparent_marker_tick.svg'),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.isThisYou),
          const SizedBox(height: 16),
          const RMSeparator(),
          RMStationDirectLineMapWidget(
            stationLocation: selectedLocation.latLng,
            stationId: selectedLocation.evseId,
            stationName: selectedLocation.name,
            stationStatus: selectedLocation.status,
            userLocation: selectedLocation.searchLocation,
          ),
          const RMSeparator(),
          RMContentBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              selectedLocation.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const RMSeparator(color: RMColors.separatorLightGrey, edgeInsets: EdgeInsets.only(top: 20.0)),
            TickRadioListTile<StartChargingLocationMetadata>(
              title: Text(
                selectedLocation.displayId,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              value: selectedLocation,
              groupValue: selectedLocation,
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: const EdgeInsets.all(0),
              onChanged: (value) {
                // BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.selectChargingStation(value));
              },
            ),
            const RMSeparator(edgeInsets: EdgeInsets.only(bottom: 20.0)),
            BlocBuilder<ChargeNowBloc, ChargeNowState>(
              builder: (context, state) {
                final isLoading = state.flow.isLoading;
                return RMTextButton(
                    isLoading: isLoading,
                    onPressed: () {
                      BlocProvider.of<ChargeNowBloc>(context)
                          .add(ChargeNowEvent.chargingStationSelected(selectedLocation));
                    },
                    text: AppLocalizations.of(context)!.yesThisIsMe);
              },
            ),
            TextButton(
                onPressed: () {
                  final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
                  BlocProvider.of<ChargeNowBloc>(context)
                      .add(ChargeNowEvent.showMoreChargingStationsTapped(null, false, partyIds));
                },
                child: Center(child: Text(AppLocalizations.of(context)!.noSelectDifferentStation))),
            const Center(child: SizedBox(width: 40, child: RMSeparator())),
            TextButton(
                onPressed: () {
                  BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.manualEvseIdInputTapped());
                },
                child: Center(child: Text(AppLocalizations.of(context)!.manualEVSEIDInput)))
          ])),
        ],
      ),
    );
  }
}
