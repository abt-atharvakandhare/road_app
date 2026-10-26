import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/services/notifications/fcm_token_refresh_service.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/utils/widgets/charge_now_tabbar_button.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';

import 'account/account_root_screen.dart';
import 'app_links/cubit/app_links_cubit.dart';
import 'charge_now/bloc/charge_now_bloc.dart';
import 'charge_now/charge_now_root_screen.dart';
import 'explore/explore_root_screen.dart';
import 'explore/favourites/bloc/favourites_cubit.dart';
import 'explore/map/bloc/map_bloc.dart';
import 'explore/map_overlay/bloc/map_overlay_bloc.dart';
import 'home/home_root_screen.dart';
import 'main_app_root_navigation_cubit.dart';
import 'wallet/cubit/wallet_navigation_cubit.dart';
import 'wallet/wallet_root_screen.dart';

class MainAppRootScreen extends StatelessWidget {
  const MainAppRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainAppRootNavigationCubit()),
        BlocProvider.value(value: getIt<LocationBloc>()),
        BlocProvider(
          create: (context) => getIt<ChargeNowBloc>(
            param1: BlocProvider.of<AuthCubit>(context).state.isLoggedIn,
          ),
        ),
        BlocProvider(create: (context) => getIt<MapBloc>()),
        BlocProvider(create: (context) => getIt<MapOverlayBloc>()),
        BlocProvider.value(value: context.read<FavouritesCubit>()),
        BlocProvider.value(value: getIt<AppLinksCubit>()),
      ],
      child: BlocBuilder<MainAppRootNavigationCubit, MainAppRootNavigationState>(builder: (context, state) {
        return Scaffold(
            resizeToAvoidBottomInset: state.navbarItem != NavbarItem.home,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: RMColors.rmPrimaryBackground,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/bar_home.svg',
                    colorFilter: ColorFilter.mode(
                        state.navbarItem == NavbarItem.home ? RMColors.rmBlackText : RMColors.disabledIconGrey,
                        BlendMode.srcIn),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/bar_map.svg',
                    colorFilter: ColorFilter.mode(
                        state.navbarItem == NavbarItem.explore ? RMColors.rmBlackText : RMColors.disabledIconGrey,
                        BlendMode.srcIn),
                  ),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: ChargeNowTabbarButton(
                    onPressed: () {
                      ChargeNowRootScreen.pushAsModal(context);
                    },
                  ),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/bar_card.svg',
                    colorFilter: ColorFilter.mode(
                        state.navbarItem == NavbarItem.wallet ? RMColors.rmBlackText : RMColors.disabledIconGrey,
                        BlendMode.srcIn),
                  ),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/bar_profile.svg',
                    colorFilter: ColorFilter.mode(
                        state.navbarItem == NavbarItem.account ? RMColors.rmBlackText : RMColors.disabledIconGrey,
                        BlendMode.srcIn),
                  ),
                  label: 'Account',
                ),
              ],
              currentIndex: state.navbarItem.toIndex(context),
              selectedItemColor: Colors.amber[800],
              onTap: (index) {
                if (index == 2) {
                  // Tab button is slightly larger than overlaid button.
                  ChargeNowRootScreen.pushAsModal(context);
                  return;
                }
                BlocProvider.of<MainAppRootNavigationCubit>(context)
                    .switchToNavbarItem(NavbarItem.fromIndex(index, context));
              },
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<AuthCubit, AuthState>(
                  listenWhen: (previous, current) {
                    final wasLoggedIn = previous.isLoggedIn;
                    final isLoggedIn = current.isLoggedIn;
                    return wasLoggedIn != isLoggedIn;
                  },
                  listener: (context, state) {
                    if (state.isLoggedIn) {
                      BlocProvider.of<FavouritesCubit>(context).loadFavourites();
                      BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.checkChargingStatus());
                      getIt<FcmTokenRefreshService>().startListening();
                    } else {
                      BlocProvider.of<FavouritesCubit>(context).clearFavourites();
                      BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.loggedOut());
                      getIt<FcmTokenRefreshService>().stopListening();
                    }
                  },
                ),
                BlocListener<AppLinksCubit, AppLinksState>(
                  listener: (context, state) {
                    switch (state) {
                      case AppLinksShowChargingStation(:final stationId):
                        final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
                        final userLocation = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
                        ChargeNowRootScreen.pushAsModal(context,
                            chargeEvent: ChargeNowEvent.manualEvseIdSubmitted(stationId, partyIds, userLocation));
                        BlocProvider.of<AppLinksCubit>(context).linkHandled();
                      case AppLinksShowCharging():
                        ChargeNowRootScreen.pushAsModal(context,
                            chargeEvent: const ChargeNowEvent.checkChargingStatus());
                        BlocProvider.of<AppLinksCubit>(context).linkHandled();
                      case AppLinksShowSessions():
                        // Pulse WalletNavigationCubit first so when WalletRootScreen
                        // mounts (if navbar wasn't already on wallet) it reads the
                        // latest state and drives its TabController to Sessions.
                        // The same nonce change is what triggers SessionsScreen's
                        // refresh listener when it's already mounted.
                        getIt<WalletNavigationCubit>().requestShowSessions();
                        BlocProvider.of<MainAppRootNavigationCubit>(context)
                            .switchToNavbarItem(NavbarItem.wallet);
                        BlocProvider.of<AppLinksCubit>(context).linkHandled();
                      case AppLinksIdle():
                        break;
                    }
                  },
                ),
              ],
              child: Builder(builder: (context) {
                switch (state.navbarItem) {
                  case NavbarItem.home:
                    return HomeRootScreen();
                  case NavbarItem.explore:
                    return const ExploreRootScreen();
                  case NavbarItem.chargeNow:
                    return const Text('Modal charge now');
                  case NavbarItem.wallet:
                    return const WalletRootScreen();
                  case NavbarItem.account:
                    return const AccountRootScreen();
                }
              }),
            ));
      }),
    );
  }
}
