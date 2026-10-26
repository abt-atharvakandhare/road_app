import 'package:flutter/material.dart';

import 'ui/utils/colors.dart';

class ThemeFactory {
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: RMColors.rmPrimaryColor,
        error: RMColors.errorRed,
      ),
      primarySwatch: RMColors.primarySwatch,
      primaryColor: RMColors.rmPrimaryColor,
      scaffoldBackgroundColor: RMColors.rmPrimaryBackground,
      appBarTheme:
          const AppBarTheme(backgroundColor: RMColors.rmPrimaryBackground, elevation: 0, scrolledUnderElevation: 0),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: RMColors.separatorDarkGrey),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: RMColors.separatorDarkGrey),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: RMColors.rmPrimaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          errorStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: RMColors.errorRed,
            fontFamily: 'Inter',
          )),
      textTheme: const TextTheme(
          bodyLarge:
              TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          bodyMedium:
              TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          bodySmall: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: RMColors.rmBlackText,
              fontFamily: 'Inter'),
          headlineMedium:
              TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          headlineSmall:
              TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          labelLarge:
              TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          titleSmall:
              TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          labelMedium:
              TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: RMColors.rmBlackText, fontFamily: 'Inter'),
          labelSmall:
              TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500, color: RMColors.rmBlackText, fontFamily: 'Inter')),
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return RMColors.rmGreen;
        }
        return RMColors.rmDisabledGray;
      })),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return RMColors.rmDisabledGray;
        }
        return RMColors.rmPrimaryColor;
      }))),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return RMColors.rmPrimaryColor;
          }
          return RMColors.rmWhiteText;
        }),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 2),
      datePickerTheme: const DatePickerThemeData(yearStyle: TextStyle(fontSize: 16.0, color: RMColors.rmBlackText)),
      tabBarTheme: TabBarThemeData(
        labelColor: RMColors.rmBlackText,
        unselectedLabelColor: RMColors.searchTextGrey,
        labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
        labelStyle: const TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: RMColors.rmBlackText),
        unselectedLabelStyle: const TextStyle(
            fontSize: 16.0, fontWeight: FontWeight.w600, fontFamily: 'Inter', color: RMColors.searchTextGrey),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: RMColors.rmPrimaryColor, width: 2),
        ),
        dividerColor: RMColors.separatorLightGrey,
        dividerHeight: 2,
      ),
    );
  }
}
