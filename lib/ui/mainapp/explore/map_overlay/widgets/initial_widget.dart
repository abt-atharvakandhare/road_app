import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';

import '../../map/bloc/map_bloc.dart';
import '../map_filter_screen.dart';
import '../../../home/nearest_stations/nearest_stations_screen.dart';

class InitialWidget extends StatelessWidget {
  const InitialWidget({super.key, required this.searchBoxWidget});

  final Widget searchBoxWidget;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: SizedBox(
                  height: 48,
                  child: Row(children: [
                    Expanded(child: searchBoxWidget),
                    const SizedBox(width: 8),
                    // Nearest Stations button
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: RMColors.rmWhiteText,
                            border: Border.all(color: RMColors.separatorDarkGrey, width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(10))),
                        child: IconButton(
                            onPressed: () {
                              NearestStationsScreen.pushAsNearestStations(context);
                            },
                            icon: SvgPicture.asset('assets/icons/list_icon.svg', width: 16, height: 16))),
                    const SizedBox(width: 8),
                    // Filter button with badge
                    Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: RMColors.rmWhiteText,
                            border: Border.all(color: RMColors.separatorDarkGrey, width: 1),
                            borderRadius: const BorderRadius.all(Radius.circular(10))),
                        child: Stack(alignment: Alignment.topRight, children: [
                          IconButton(
                              onPressed: () {
                                MapFilterScreen.pushAsModal(context);
                              },
                              icon: SvgPicture.asset('assets/icons/maps_filter.svg')),
                          BlocBuilder<MapBloc, MapState>(builder: (context, state) {
                            final filterCount = BlocProvider.of<MapBloc>(context).mapFilters.activeFilterCount;
                            return IgnorePointer(
                                child: AnimatedContainer(
                                    width: filterCount > 0 ? 18 : 0,
                                    height: filterCount > 0 ? 18 : 0,
                                    curve: filterCount > 0 ? Curves.bounceIn : Curves.bounceOut,
                                    duration: const Duration(milliseconds: 500),
                                    child: Badge(
                                        backgroundColor: RMColors.rmPrimaryColor,
                                        label: Text('$filterCount',
                                            style: const TextStyle(
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontFamily: 'Inter')))));
                          })
                        ]))
                  ]))))
    ]);
  }
}
