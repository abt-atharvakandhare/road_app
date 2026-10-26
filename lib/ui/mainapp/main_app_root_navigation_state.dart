part of 'main_app_root_navigation_cubit.dart';

enum NavbarItem {
  home,
  explore,
  chargeNow,
  wallet,
  account;

  static NavbarItem fromIndex(int index, BuildContext context) {
    return NavbarItem.values[index];
  }

  int toIndex(BuildContext context) {
    final int basicIndex = NavbarItem.values.indexOf(this);

    return basicIndex;
  }
}

class MainAppRootNavigationState extends Equatable {
  final NavbarItem navbarItem;

  const MainAppRootNavigationState(this.navbarItem);

  @override
  List<Object> get props => [navbarItem];
}
