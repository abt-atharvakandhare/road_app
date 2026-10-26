import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';

import '../../data/model/charging/charging_sessions_response_model.dart';
import 'colors.dart';

extension StringPresentation on String {
  String get capitalized {
    if (length < 2) {
      return toUpperCase();
    }
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension ChargingSessionModelPresentation on ChargingSessionModel {
  String chargingDurationString(BuildContext context) {
    final duration = mspSession?.durationSeconds;
    if (duration == null) {
      return AppLocalizations.of(context)!.hAndMin(0, 0);
    }

    return duration.toInt().toDaysHoursMinutesString(context);
  }
}

extension RoundingUp on NumberFormat {
  // Round 3.025 to 3.03 rather than 3.02. Dirty. #disappointingDart
  String formatRoundingMidUp(double value) => format(value + 0.000001);
}

extension ChargingDuration on int {
  String toDaysHoursMinutesString(BuildContext context) {
    var remainingSeconds = this;
    final days = remainingSeconds ~/ (60 * 60 * 24);
    remainingSeconds -= days * 60 * 60 * 24;
    final hours = remainingSeconds ~/ (60 * 60);
    remainingSeconds -= hours * 60 * 60;
    final minutes = remainingSeconds ~/ 60;

    var durationString = '';
    if (days >= 1) {
      durationString += '${AppLocalizations.of(context)!.nDays(days)} ';
    }

    if (hours >= 1) {
      durationString += '${AppLocalizations.of(context)!.nHours(hours)} ';
    }

    if (minutes >= 1) {
      durationString += AppLocalizations.of(context)!.nMinutes(minutes);
    }

    if (days == 0 && hours == 0 && minutes == 0) {
      durationString += AppLocalizations.of(context)!.lessThanAMinute;
    }

    return durationString;
  }
}

extension TariffDisplay on TariffItemModel {
  String dynamicPriceString(BuildContext context, String currency) {
    return '$startTime - $endTime ';
  }

  List<Text>? tariffText(BuildContext context, String currency, TextStyle? style) {
    final currencyFormat = NumberFormat.simpleCurrency(name: currency);
    final spans = <TextSpan>[];
    final additionalFeeSpans = <TextSpan>[];

    if (kwhPrice != null && kwhPrice! > 0) {
      final kwhPriceString = currencyFormat.formatRoundingMidUp(kwhPrice!);
      spans.add(TextSpan(text: '$kwhPriceString / kWh', style: style));
    }

    if (sessionPrice != null && sessionPrice! > 0) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: '  |  ', style: style?.copyWith(color: RMColors.rmDisabledGray)));
      }

      final flatPriceString = currencyFormat.formatRoundingMidUp(sessionPrice!);
      spans.add(TextSpan(text: '$flatPriceString / ${AppLocalizations.of(context)!.session}', style: style));
    }

    if (timePrice != null && timePrice! > 0) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: '  |  ', style: style?.copyWith(color: RMColors.rmDisabledGray)));
      }

      final timePriceString = currencyFormat.formatRoundingMidUp(timePrice!);
      spans.add(TextSpan(text: '$timePriceString / ${AppLocalizations.of(context)!.hour}', style: style));
    }

    if (idleFeePrice != null && idleFeePrice! > 0) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: '  |  ', style: style?.copyWith(color: RMColors.rmDisabledGray)));
      }

      final idleFeePriceString = currencyFormat.formatRoundingMidUp(idleFeePrice!);
      spans.add(TextSpan(text: '$idleFeePriceString / ${AppLocalizations.of(context)!.hourIdleFee}', style: style));

      if (minDuration != null && minDuration! > 60) {
        final timeInMinutes = minDuration! ~/ 60;
        spans.add(TextSpan(text: '  |  ', style: style?.copyWith(color: RMColors.rmDisabledGray)));
        spans.add(TextSpan(text: '$timeInMinutes ${AppLocalizations.of(context)!.minWaitBeforeIdleFee}', style: style));
      }
    }

    if (additionalCharges != null && additionalCharges!.isNotEmpty) {
      for (final charge in additionalCharges!) {
        if (additionalFeeSpans.isNotEmpty) {
          additionalFeeSpans.add(TextSpan(text: '  |  ', style: style?.copyWith(color: RMColors.rmDisabledGray)));
        }

        final priceWithVat = charge.price * (1 + ((charge.vat) / 100.0));
        final priceString = currencyFormat.formatRoundingMidUp(priceWithVat);
        additionalFeeSpans
            .add(TextSpan(text: '$priceString ${AppLocalizations.of(context)!.additionalFee}', style: style));
      }
    }

    final result = <Text>[];

    if (spans.isEmpty) {
      result.add(Text(AppLocalizations.of(context)!.noTariffAvailable, style: style));
    } else {
      result.add(Text.rich(TextSpan(children: spans)));
    }

    if (additionalFeeSpans.isNotEmpty) {
      result.add(Text.rich(TextSpan(children: additionalFeeSpans)));
    }

    return result.isEmpty ? null : result;
  }

  String? dayAndTimeString(BuildContext context) {
    var result = '';
    if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      for (final dayOfWeek in daysOfWeek!) {
        if (result.isNotEmpty) {
          result += ', ';
        }
        result += dayOfWeek.capitalized;
      }

      if (startTime != null && endTime != null) {
        if (result.isNotEmpty) {
          result += ', ';
        }

        result += '$startTime - $endTime';
      }
    }

    if (result.isEmpty && startDate != null) {
      result += startDate!;

      if (endDate != null) {
        result += ' - $endDate';
      }
    }

    if (result.isEmpty && startTime != null && endTime != null) {
      result += '$startTime - $endTime';
    }

    return result.isEmpty ? null : result;
  }
}

extension MaxPowerDouble on double? {
  String? get maxPowerKwFormattedString {
    if (this == null) {
      return null;
    }

    return '${this!.toStringAsFixed(0)} kW';
  }
}

extension HoursAndMinutes on double? {
  String? hoursAndMinutesStringFromSeconds(BuildContext context) {
    if (this == null) {
      return null;
    }

    final hours = this! ~/ 3600;
    final minutes = (this! - hours * 3600) ~/ 60;

    return AppLocalizations.of(context)!.hAndMin(hours, minutes);
  }
}
