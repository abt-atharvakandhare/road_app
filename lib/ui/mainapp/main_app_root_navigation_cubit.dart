import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:road_mobile/services/analytics/mixpanel_events.dart';
import 'package:road_mobile/services/analytics/mixpanel_service.dart';
import 'package:road_mobile/services/di/injection.dart';

part 'main_app_root_navigation_state.dart';

class MainAppRootNavigationCubit extends Cubit<MainAppRootNavigationState> {
  final MixpanelService _mixpanelService = getIt<MixpanelService>();

  MainAppRootNavigationCubit() : super(const MainAppRootNavigationState(NavbarItem.home)) {
    // Track initial page view
    _trackPageView(NavbarItem.home);
  }

  void switchToNavbarItem(NavbarItem item) {
    emit(MainAppRootNavigationState(item));
    _trackPageView(item);
  }

  void _trackPageView(NavbarItem item) {
    final pageUrl = switch (item) {
      NavbarItem.home => MixpanelPageUrl.home,
      NavbarItem.explore => MixpanelPageUrl.map,
      NavbarItem.chargeNow => MixpanelPageUrl.chargeNow,
      NavbarItem.wallet => MixpanelPageUrl.wallet,
      NavbarItem.account => MixpanelPageUrl.account,
    };
    _mixpanelService.trackPageView(pageUrl);
  }
}
