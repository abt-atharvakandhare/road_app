import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/mainapp/explore/map/bloc/map_bloc.dart';
import 'package:road_mobile/ui/mainapp/explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'package:road_mobile/ui/utils/widgets/bottom_loading_widget.dart';

import 'map/map_widget.dart';
import 'map_overlay/map_overlay_widget.dart';

class ExploreRootScreen extends StatefulWidget {
  const ExploreRootScreen({super.key});

  @override
  State<ExploreRootScreen> createState() => _ExploreRootScreenState();
}

class _ExploreRootScreenState extends State<ExploreRootScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Keep map modal pushes within the map area.
    return NavigatorPopHandler(
      onPopWithResult: (result) => _navigatorKey.currentState!.pop(result),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            return _buildMapScreen();
          });
        },
      ),
    );
  }

  Widget _buildMapScreen() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const MapWidget(),
        const MapOverlayWidget(),
        BlocBuilder<MapBloc, MapState>(
          builder: (mapContext, mapState) {
            return BlocBuilder<MapOverlayBloc, MapOverlayState>(
              builder: (mapOverlaycontext, mapOverlayState) {
                return BottomLoadingWidget(isLoading: mapState.flow.isLoading || mapOverlayState.flow.isLoading);
              },
            );
          },
        )
      ],
    );
  }
}
