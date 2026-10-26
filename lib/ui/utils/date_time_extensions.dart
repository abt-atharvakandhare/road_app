import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

extension RMDateTime on DateTime {
  /// Return a string that shows time elapsed between a date and now, in a format such as '2h 50min'
  String timeElapsed(BuildContext context, DateTime? stopRequestedTime) {
    final targetTime = stopRequestedTime ?? DateTime.now();
    final difference = targetTime.difference(this);
    final hours = difference.inHours;
    final minutes = difference.inMinutes - hours * 60;
    return AppLocalizations.of(context)!.hAndMin(hours, minutes);
  }

  /// Return a string that formats the date in a format such as 'Jan 18, 9:20 AM'
  String get monthDayTimeMeridiem {
    return DateFormat('MMM d, h:mm a').format(this);
  }

  /// Return a string that formats the date in a format such as 'September 2023'
  String get monthYear {
    return DateFormat('MMMM y').format(this);
  }

  /// Return a string that formats the date in a format such as 'Jan 18, 14:20'
  /// The time is in 24h format
  String get monthDayTime24h {
    return DateFormat('MMM d, HH:mm').format(this);
  }

  ///  Return a string that formats the date in a format such as 'Tuesday, 25th July'
  String get dayDateMonth {
    return DateFormat('EEEE, d MMMM').format(this);
  }

  /// Return a string that formats the date in a format such as '10:20 AM, February 20, 2023'
  String get timeMeridiemMonthDayYear {
    return DateFormat('h:mm a, MMMM d, y').format(this);
  }

  bool isSameMonthAndYear(DateTime other) {
    return year == other.year && month == other.month;
  }
}

extension IntToMonth on int? {
  String get monthName {
    if (this == null) {
      return '';
    }
    return DateFormat('MMMM').format(DateTime(2023, this!));
  }
}
