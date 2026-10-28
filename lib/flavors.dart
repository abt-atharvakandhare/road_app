enum MapBrandFilterType { showAllFilterToBrand, showBrandFilterToAll, showBrandOnly }

enum Flavor {
  abt,
  eflux,
  elexon,
  opcharge,
  friwigo,
  ezdrive,
  nxt50five,
  ezdriveplus,
  vcityreunion,
  nxtmobility,
  mycomoly,
  maesev,
  kiachargenl,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.abt:
        return 'ABT Test';
      case Flavor.eflux:
        return 'E-Flux EV';
      case Flavor.elexon:
        return 'Elexon EV';
      case Flavor.opcharge:
        return 'Opcharge EV';
      case Flavor.friwigo:
        return 'FRIWIGO EV';
      case Flavor.ezdrive:
        return 'V-CiTY';
      case Flavor.nxt50five:
        return 'NXT 50five EV';
      case Flavor.ezdriveplus:
        return 'EZDrive+';
      case Flavor.vcityreunion:
        return 'V-City Réunion';
      case Flavor.nxtmobility:
        return 'NXT Charge';
      case Flavor.mycomoly:
        return 'myCoMoly';
      case Flavor.maesev:
        return 'MAES EV';
      case Flavor.kiachargenl:
        return 'Kia Charge NL';
    }
  }

  static String get appBrandName => brandNameOf(appFlavor);

  /// Static per-flavor lookup (not just the [appBrandName] getter) so the e2e
  /// suite can enumerate every brand name and assert no foreign brand leaks
  /// into a white-label build.
  static String brandNameOf(Flavor flavor) {
    switch (flavor) {
      case Flavor.abt:
        return 'ABT Test';
      case Flavor.eflux:
        return 'E-Flux';
      case Flavor.elexon:
        return 'Elexon';
      case Flavor.opcharge:
        return 'Opcharge';
      case Flavor.friwigo:
        return 'FRIWIGO';
      case Flavor.ezdrive:
        return 'V-CiTY';
      case Flavor.ezdriveplus:
        return 'EZDrive+';
      case Flavor.nxt50five:
        return 'NXT 50five';
      case Flavor.vcityreunion:
        return 'V-City Réunion';
      case Flavor.nxtmobility:
        return 'NXT Charge';
      case Flavor.mycomoly:
        return 'myCoMoly';
      case Flavor.maesev:
        return 'MAES EV';
      case Flavor.kiachargenl:
        return 'Kia Charge NL';
    }
  }

  static MapBrandFilterType get mapBrandFilterType {
    switch (appFlavor) {
      case Flavor.abt:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.eflux:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.elexon:
        return MapBrandFilterType.showBrandOnly;
      case Flavor.opcharge:
        return MapBrandFilterType.showBrandOnly;
      case Flavor.friwigo:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.ezdrive:
        return MapBrandFilterType.showBrandFilterToAll;
      case Flavor.ezdriveplus:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.nxt50five:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.vcityreunion:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.nxtmobility:
        return MapBrandFilterType.showBrandFilterToAll;
      case Flavor.mycomoly:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.maesev:
        return MapBrandFilterType.showAllFilterToBrand;
      case Flavor.kiachargenl:
        return MapBrandFilterType.showAllFilterToBrand;
    }
  }

  static String get providerName {
    switch (appFlavor) {
      case Flavor.abt:
        return 'abt';
      case Flavor.eflux:
        return 'e-flux';
      case Flavor.elexon:
        return 'elexon';
      case Flavor.opcharge:
        return 'opcharge';
      case Flavor.friwigo:
        return 'friwigo';
      case Flavor.ezdrive:
        return 'vitodrive';
      case Flavor.ezdriveplus:
        return 'ezdrive';
      case Flavor.nxt50five:
        return 'nxt50five';
      case Flavor.vcityreunion:
        return 'vcitylareunion';
      case Flavor.nxtmobility:
        return 'nxt-mobility';
      case Flavor.mycomoly:
        return 'comolygmbh';
      case Flavor.maesev:
        return 'maes';
      case Flavor.kiachargenl:
        return 'kianederland';
    }
  }

  // Return null for in-app signup
  static Uri? get signupLink {
    switch (appFlavor) {
      case Flavor.elexon:
        return Uri.parse('https://my.elexon-charging.com/signup');
      default:
        return null;
    }
  }

  static bool get isRemoteChargeEnabled {
    switch (appFlavor) {
      case Flavor.abt:
        return false;
      case Flavor.eflux:
      case Flavor.opcharge:
      case Flavor.friwigo:
      case Flavor.ezdrive:
      case Flavor.ezdriveplus:
      case Flavor.nxt50five:
      case Flavor.vcityreunion:
      case Flavor.nxtmobility:
      case Flavor.mycomoly:
      case Flavor.maesev:
      case Flavor.kiachargenl:
        return true;
      case Flavor.elexon:
        return false;
    }
  }

  static bool get restrictMapCallsToProvider {
    switch (appFlavor) {
      case Flavor.eflux:
      case Flavor.maesev:
        return false;
      default:
        return true;
    }
  }

  static bool get useIntercomForHelp {
    switch (appFlavor) {
      case Flavor.eflux:
        return true;
      default:
        return false;
    }
  }

  static String? get stagingApplePayMerchantId {
    switch (appFlavor) {
      case Flavor.eflux:
        return 'merchant.dev.road';
      case Flavor.ezdrive:
        return 'merchant.sandbox.road.vcity';
      case Flavor.vcityreunion:
        return 'merchant.re.v-city';
      case Flavor.nxtmobility:
        return 'merchant.nl.nxtmobility';
      case Flavor.maesev:
        return 'merchant.be.maesmobility.maesev';
      default:
        return null;
    }
  }

  static String? get productionApplePayMerchantId {
    switch (appFlavor) {
      case Flavor.eflux:
        return 'merchant.io.road';
      case Flavor.opcharge:
        return 'merchant.com.opcharge';
      case Flavor.friwigo:
        return 'merchant.com.friwigo';
      case Flavor.nxt50five:
        return 'merchant.nl.nxt50five';
      case Flavor.ezdrive:
        return 'merchant.fr.ezdrive.vcity';
      case Flavor.ezdriveplus:
        return 'merchant.fr.ezdrive.plus';
      case Flavor.vcityreunion:
        return 'merchant.re.v-city';
      case Flavor.nxtmobility:
        return 'merchant.nl.nxtmobility';
      case Flavor.mycomoly:
        return 'merchant.eu.comoly';
      case Flavor.maesev:
        return 'merchant.be.maesmobility.maesev';
      case Flavor.kiachargenl:
        return 'merchant.com.kiacharge';
      default:
        return null;
    }
  }

  static bool get showInvoices {
    switch (appFlavor) {
      case Flavor.opcharge:
        return false;
      case Flavor.maesev:
        return false;
      default:
        return true;
    }
  }
}
