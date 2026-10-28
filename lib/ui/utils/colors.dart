import 'package:flutter/material.dart';
import 'package:road_mobile/flavors.dart';

extension RMColors on Colors {
  static const Color rmPrimaryBackground = Color(0xFFF6FAFC);
  static const Color rmWhiteText = Color(0xFFFFFFFF);
  static const Color rmBlackText = Color(0xFF2A2A2A);
  static const Color rmDarkText = Color(0xFF131313);
  static const Color rmGreen = Color(0xff20E300);
  static const Color rmDisabledGray = Color(0xFFCCCCCC);
  static const Color searchTextGrey = Color(0xFF666666);
  static const Color separatorDarkGrey = Color(0xFFDDDDDD);
  static const Color separatorLightGrey = Color(0xFFEEEEEE);
  static const Color disabledIconGrey = Color(0xFFA2A2A2);
  static const Color colorSelectorDisabledGrey = Color(0xFFF1F1F1);
  static const Color sliderGrey = Color(0xFFE8E8E8);
  static const Color containerBorderGrey = Color(0xFFE5E7EB);
  static const Color warningBlueBackground = Color(0xFFEBF2FA);
  static const Color warningBlueBorder = Color(0xFFBDD2F3);
  static const Color activeChargeBlueGradientStart = Color(0xFF1434CB);
  static const Color activeChargeBlueText = Color(0xFF005CEE);
  static const Color destructiveRed = Color(0xFFEB001B);
  static const Color errorRed = Color(0xFFAD141F);
  static const Color activeGreen = Color(0xFF009A44);
  static const Color selectedBlueGreen = Color(0xFF63D7C6);
  static const Color progressBarBackground = Color(0xFFD9D9D9);
  static const Color progressBarGradientStart = Color(0xFFD5DE4C);
  static const Color progressBarGradientEnd = Color(0xFF00F10A);
  static const Color verifiedGreen = Color(0xFF21BA45);

  static const Color chargingAvailable = Color(0xFF3FE724);
  static const Color chargingUnavailable = Color(0xFF6393F2);
  static const Color chargingUnknown = Color(0xFFDB4437);

  static const Color chargingMarkerAvailable = Color(0xFF56BA38);
  static const Color chargingMarkerUnavailable = Color(0xFF0000FF);
  static const Color chargingMarkerUnknown = Color(0xFFDE4E47);
  static const Color chargingMarkerSelected = Color(0xFF2A2A2A);

  static Color get rmPrimaryColor {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const Color(0xFF4070C5);
      case Flavor.eflux:
        return const Color(0xFFFF3D00);
      case Flavor.elexon:
        return const Color(0xFF153E35);
      case Flavor.opcharge:
        return const Color(0xFFB1C800);
      case Flavor.friwigo:
        return const Color(0xFF75A5E9);
      case Flavor.ezdrive:
        return const Color(0xFF0E5D92);
      case Flavor.ezdriveplus:
        return const Color(0xFF9ACC0E);
      case Flavor.nxt50five:
        return const Color(0xFF82BC41);
      case Flavor.vcityreunion:
        return const Color(0xFF00823E);
      case Flavor.nxtmobility:
        return const Color(0xFF001F66);
      case Flavor.mycomoly:
        return const Color(0xFF142643);
      case Flavor.maesev:
        return const Color(0xFF056938);
      case Flavor.kiachargenl:
        return const Color(0xFF05141F);
    }
  }

  static Color get rmPrimaryColorSplashScreenGradientStart {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const Color(0xFF779DEA);
      case Flavor.eflux:
        return const Color(0xFFFF3D00);
      case Flavor.elexon:
        return const Color(0xFF153E35);
      case Flavor.opcharge:
        return const Color(0xFFB1C800);
      case Flavor.friwigo:
        return const Color(0xFF75A5E9);
      case Flavor.ezdrive:
        return const Color(0xFFF6FAFC);
      case Flavor.ezdriveplus:
        return const Color(0xFFFFFFFF);
      case Flavor.nxt50five:
        return const Color(0xFF002856);
      case Flavor.vcityreunion:
        return const Color(0xFFF6FAFC);
      case Flavor.nxtmobility:
        return const Color(0xFF001F66);
      case Flavor.mycomoly:
        return const Color(0xFF142643);
      case Flavor.maesev:
        return const Color(0xFF056938);
      case Flavor.kiachargenl:
        return const Color(0xFF05141F);
    }
  }

  static Color get rmPrimaryColorSplashScreenGradientEnd {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const Color(0xFF3E66BB);
      case Flavor.eflux:
        return const Color(0xFFFF8500);
      case Flavor.elexon:
        return const Color(0xFF004A2C);
      case Flavor.opcharge:
        return const Color(0xFFF4F5F8);
      case Flavor.friwigo:
        return const Color(0xFF5BC0DE);
      case Flavor.ezdrive:
        return const Color(0xFFF6FAFC);
      case Flavor.ezdriveplus:
        return const Color(0xFFFFFFFF);
      case Flavor.nxt50five:
        return const Color(0xFF82BC41);
      case Flavor.vcityreunion:
        return const Color(0xFFF6FAFC);
      case Flavor.nxtmobility:
        return const Color(0xFF001F66);
      case Flavor.mycomoly:
        return const Color(0xFF1B5E6C);
      case Flavor.maesev:
        return const Color(0xFF056938);
      case Flavor.kiachargenl:
        return const Color(0xFF05141F);
    }
  }

  static Color get rmPrimaryColorAppGradientStart {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const Color(0xFF91AFEA);
      case Flavor.eflux:
        return const Color(0xFFFF3D00);
      case Flavor.elexon:
        return const Color(0xFF153E35);
      case Flavor.opcharge:
        return const Color(0xFFB1C800);
      case Flavor.friwigo:
        return const Color(0xFF75A5E9);
      case Flavor.ezdrive:
        return const Color(0xFF0E5D92);
      case Flavor.ezdriveplus:
        return const Color(0xFF6EA037);
      case Flavor.nxt50five:
        return const Color(0xFF6EA037);
      case Flavor.vcityreunion:
        return const Color(0xFF00823E);
      case Flavor.nxtmobility:
        return const Color(0xFF001F66);
      case Flavor.mycomoly:
        return const Color(0xFF142643);
      case Flavor.maesev:
        return const Color(0xFF056938);
      case Flavor.kiachargenl:
        return const Color(0xFF05141F);
    }
  }

  static Color get rmPrimaryColorAppGradientEnd {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const Color(0xFF4585FF);
      case Flavor.eflux:
        return const Color(0xFFFF8500);
      case Flavor.elexon:
        return const Color(0xFF004A2C);
      case Flavor.opcharge:
        return const Color(0xFFBDD600);
      case Flavor.friwigo:
        return const Color(0xFF5BC0DE);
      case Flavor.ezdrive:
        return const Color(0xFF008236);
      case Flavor.ezdriveplus:
        return const Color(0xFF82BC41);
      case Flavor.nxt50five:
        return const Color(0xFF82BC41);
      case Flavor.vcityreunion:
        return const Color(0xFF086AA5);
      case Flavor.nxtmobility:
        return const Color(0xFF001F66);
      case Flavor.mycomoly:
        return const Color(0xFF1B5E6C);
      case Flavor.maesev:
        return const Color(0xFF056938);
      case Flavor.kiachargenl:
        return const Color(0xFF05141F);
    }
  }

  static MaterialColor get primarySwatch {
    switch (F.appFlavor) {
      case Flavor.abt:
        return const MaterialColor(0xFFFF3D00, <int, Color>{
          50: Color(0xFFA6C2F5),
          100: Color(0xFF779DEA),
          200: Color(0xFF5281CC),
          300: Color(0xFF2C5EAB),
          400: Color(0xFF265EBE),
          500: Color(0xFF2452BE),
          600: Color(0xFF2D74EE),
          700: Color(0xFF0C51BB),
          800: Color(0xFF0849AF),
          900: Color(0xFF0F3383),
        });
      case Flavor.eflux:
        return const MaterialColor(0xFFFF3D00, <int, Color>{
          50: Color(0xFFFFF3E0),
          100: Color(0xFFFFE0B2),
          200: Color(0xFFFFCC80),
          300: Color(0xFFFFB74D),
          400: Color(0xFFFFA726),
          500: Color(0xFFFF9800),
          600: Color(0xFFFB8C00),
          700: Color(0xFFF57C00),
          800: Color(0xFFEF6C00),
          900: Color(0xFFE65100),
        });
      case Flavor.elexon:
        return const MaterialColor(0xFF153E35, <int, Color>{
          50: Color(0xFFE0F2F1),
          100: Color(0xFFB2DFDB),
          200: Color(0xFF80CBC4),
          300: Color(0xFF4DB6AC),
          400: Color(0xFF26A69A),
          500: Color(0xFF009688),
          600: Color(0xFF00897B),
          700: Color(0xFF00796B),
          800: Color(0xFF00695C),
          900: Color(0xFF004D40),
        });
      case Flavor.opcharge:
        return const MaterialColor(0xFFB1C800, <int, Color>{
          50: Color(0xFFF9FBE7),
          100: Color(0xFFF0F7C2),
          200: Color(0xFFE6EE9A),
          300: Color(0xFFDCE46F),
          400: Color(0xFFD4DE4D),
          500: Color(0xFFB1C800),
          600: Color(0xFFA3B200),
          700: Color(0xFF92A000),
          800: Color(0xFF819300),
          900: Color(0xFF6B7A00),
        });
      case Flavor.friwigo:
        return const MaterialColor(0xFF75A5E9, <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF2196F3),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1),
        });
      case Flavor.ezdrive:
        return const MaterialColor(0xFF0E5D92, <int, Color>{
          50: Color(0xFFE1F2F8),
          100: Color(0xFFB3E5FC),
          200: Color(0xFF81D4FA),
          300: Color(0xFF4FC3F7),
          400: Color(0xFF29B6F6),
          500: Color(0xFF03A9F4),
          600: Color(0xFF039BE5),
          700: Color(0xFF0288D1),
          800: Color(0xFF0277BD),
          900: Color(0xFF01579B),
        });
      case Flavor.ezdriveplus:
        return const MaterialColor(0xFF6EA037, <int, Color>{
          50: Color(0xFFF1F8E9),
          100: Color(0xFFDCEDC8),
          200: Color(0xFFC5E1A5),
          300: Color(0xFFAED581),
          400: Color(0xFF9CCC65),
          500: Color(0xFF8BC34A),
          600: Color(0xFF7CB342),
          700: Color(0xFF689F38),
          800: Color(0xFF558B2F),
          900: Color(0xFF33691E),
        });
      case Flavor.nxt50five:
        return const MaterialColor(0xFF82BC41, <int, Color>{
          50: Color(0xFFE8F5E9),
          100: Color(0xFFC8E6C9),
          200: Color(0xFFA5D6A7),
          300: Color(0xFF81C784),
          400: Color(0xFF66BB6A),
          500: Color(0xFF4CAF50),
          600: Color(0xFF43A047),
          700: Color(0xFF388E3C),
          800: Color(0xFF2E7D32),
          900: Color(0xFF1B5E20),
        });
      case Flavor.vcityreunion:
        return const MaterialColor(0xFF00823E, <int, Color>{
          50: Color(0xFFE0F3EB),
          100: Color(0xFFB3E1CC),
          200: Color(0xFF80CEAA),
          300: Color(0xFF4DBA88),
          400: Color(0xFF26AB6F),
          500: Color(0xFF00823E),
          600: Color(0xFF00763A),
          700: Color(0xFF006834),
          800: Color(0xFF005A2E),
          900: Color(0xFF00401F),
        });
      case Flavor.nxtmobility:
        return const MaterialColor(0xFF001F66, <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF2196F3),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1),
        });
      case Flavor.mycomoly:
        return const MaterialColor(0xFF142643, <int, Color>{
          50: Color(0xFFE4E6EB),
          100: Color(0xFFBBC0CC),
          200: Color(0xFF8E97AA),
          300: Color(0xFF616D87),
          400: Color(0xFF3F4D6C),
          500: Color(0xFF142643),
          600: Color(0xFF111F3A),
          700: Color(0xFF0D1931),
          800: Color(0xFF0A1427),
          900: Color(0xFF050B1A),
        });
      case Flavor.maesev:
        return const MaterialColor(0xFF056938, <int, Color>{
          50: Color(0xFFE6F2EC),
          100: Color(0xFFC2E0D1),
          200: Color(0xFF9ACCB3),
          300: Color(0xFF72B895),
          400: Color(0xFF53A97E),
          500: Color(0xFF056938),
          600: Color(0xFF045F33),
          700: Color(0xFF03542D),
          800: Color(0xFF024927),
          900: Color(0xFF01361C),
        });
      case Flavor.kiachargenl:
        return const MaterialColor(0xFF05141F, <int, Color>{
          50: Color(0xFFF2F3F4),
          100: Color(0xFFE6E8E9),
          200: Color(0xFFCDD0D2),
          300: Color(0xFF9BA1A5),
          400: Color(0xFF697279),
          500: Color(0xFF05141F),
          600: Color(0xFF04121C),
          700: Color(0xFF041019),
          800: Color(0xFF040E16),
          900: Color(0xFF030C13),
        });
    }
  }

  static const Color blue = Color(0xff0d345c);

  static const yellowColor = Color(0xffF6C83B);
  static const translucentYellowColor = Color(0x30e7b11f);
  static const darkBackground = Color(0xff2d2b2b);
  static const lightButtonBackgroundColor = Color(0xffffffff);
  static const lightGreyBackground = Color(0xffF5F5F5);
  static const primaryTextColor = Color(0xff231f20); // black primary color
}
