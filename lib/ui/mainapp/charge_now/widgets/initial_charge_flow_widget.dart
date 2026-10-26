import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_loading_inkwell_button.dart';
import 'package:road_mobile/ui/utils/widgets/rm_separator.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

import '../bloc/charge_now_bloc.dart';

class InitialChargeFlowWidget extends StatelessWidget {
  const InitialChargeFlowWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: RMContentBox(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/charge_now_lightning_bolt.svg'),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.chargeNow,
            ),
            const SizedBox(height: 40),
            const RMSeparator(),
            // RMInkwellButton(
            //     onPressed: () {
            //       final initialLocation = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
            //       BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.receivedLocation(initialLocation));
            //     },
            //     icon: SvgPicture.asset('assets/icons/charge_now_car.svg'),
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 20),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(AppLocalizations.of(context)!.imAllPluggedInToTheEvStation,
            //               style: Theme.of(context).textTheme.labelLarge),
            //           const SizedBox(height: 6),
            //           Text(AppLocalizations.of(context)!.automaticallyDetectMyConnection,
            //               style: Theme.of(context).textTheme.labelMedium),
            //         ],
            //       ),
            //     )),
            // const RMSeparator(),
            BlocBuilder<ChargeNowBloc, ChargeNowState>(
              builder: (context, state) {
                return RMLoadingInkwellButton(
                    isLoading: state.flow.isLoading,
                    onPressed: () {
                      getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.nearbyStations);
                      final location = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
                      final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
                      BlocProvider.of<ChargeNowBloc>(context)
                          .add(ChargeNowEvent.showMoreChargingStationsTapped(location, true, partyIds));
                    },
                    icon: SvgPicture.asset('assets/icons/charge_now_fuel_pump.svg'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.findNearbyEvStations,
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          Text(AppLocalizations.of(context)!.chooseFromAListOfNearbyConnectors,
                              style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    ));
              },
            ),
            const RMSeparator(),
            RMInkwellButton(
                onPressed: () {
                  getIt<MixpanelService>().trackButtonClick(MixpanelButtonName.evseIdInput);
                  BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.manualEvseIdInputTapped());
                },
                icon: SvgPicture.asset('assets/icons/charge_now_qr_code.svg'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.manuallyInputStationId,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(AppLocalizations.of(context)!.inputTheStationIdFromTheSticker,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                )),
            const RMSeparator(),
            RMInkwellButton(
                onPressed: () {
                  BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.scanQrCodeTapped());
                },
                icon: SvgPicture.asset('assets/icons/charge_now_qr_camera.svg'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.scanStationQrCode,
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Text(AppLocalizations.of(context)!.useCameraToIdentifyStationId,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                )),
            const RMSeparator(),
          ],
        )),
      ),
    );
  }
}
