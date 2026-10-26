import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'map_locations_response_model.dart';

enum TariffDisplayType { fixedFee, scheduled, dynamic }

class TariffModel {
  TariffModel(this.currency, this.name, this._items);

  static TariffModel? fromTariff(Tariff? tariff,
      {String? name, DateTime? now, List<CdrAdditionalCharge>? additionalCharges}) {
    if (tariff == null || tariff.currency == null || tariff.elements == null) {
      // If there are additional charges but no tariff, create a tariff model with just those charges
      if (additionalCharges != null && additionalCharges.isNotEmpty) {
        final emptyItem = TariffItemModel(additionalCharges: additionalCharges);
        final currency = tariff?.currency ?? additionalCharges.first.currency;
        if (currency != null) {
          return TariffModel(currency, name, [emptyItem]);
        }
      }
      return null;
    }
    List<TariffItemModel> allItems = [];

    for (final element in tariff.elements!) {
      final tariffElement = TariffItemModel.fromTariffElementModel(element);
      tariffElement.additionalCharges = additionalCharges;

      if ((tariffElement.kwhPrice == null || tariffElement.kwhPrice == 0) &&
          (tariffElement.sessionPrice == null || tariffElement.sessionPrice == 0) &&
          (tariffElement.timePrice == null || tariffElement.timePrice == 0) &&
          (tariffElement.idleFeePrice == null || tariffElement.idleFeePrice == 0)) {
        continue;
      }

      allItems.add(tariffElement);
    }

    final List<TariffItemModel> items;
    if (allItems.length == 1) {
      // If there is only 1 item, then no merging can be done. This certainly happens when all price
      // components are members of the same element.
      items = allItems;
    } else {
      items = mergeIdleFeesAndSeparateElements(allItems);
    }

    final effectiveNow = now ?? DateTime.now();
    final afterExpired = pruneExpired(items, effectiveNow);
    final prunedItems = pruneFarFuture(afterExpired, effectiveNow);

    if (prunedItems.isEmpty) {
      return null;
    }

    return TariffModel(tariff.currency!, name, prunedItems);
  }

  String currency;
  String? name;
  final List<TariffItemModel> _items;

  TariffItemModel? get standardItem {
    if (_items.length == 1) {
      return _items.first;
    }
    return _items.firstWhereOrNull((element) => !element.hasRestrictions);
  }

  List<TariffItemModel> get nonStandardItems {
    return _items.where((element) => element.hasRestrictions).toList();
  }

  static List<TariffItemModel> mergeIdleFeesAndSeparateElements(List<TariffItemModel> allItems) {
    final parkingFeeItems =
        allItems.where((element) => element.idleFeePrice != null && element.idleFeePrice! > 0).toList();
    final nonParkingFeeItems = allItems.where((element) => element.idleFeePrice == null).toList();

    if (parkingFeeItems.isEmpty && nonParkingFeeItems.length > 1) {
      // Merge multiple items into one if all restrictions match
      final firstItem = nonParkingFeeItems.first;
      final allMatch = nonParkingFeeItems.every((element) => element.dateAndTimeRestrictionsMatch(firstItem));

      if (allMatch) {
        final mergedItem = TariffItemModel();

        for (final item in nonParkingFeeItems) {
          mergedItem.kwhPrice = mergedItem.kwhPrice ?? item.kwhPrice;
          mergedItem.sessionPrice = mergedItem.sessionPrice ?? item.sessionPrice;
          mergedItem.timePrice = mergedItem.timePrice ?? item.timePrice;
          mergedItem.idleFeePrice = mergedItem.idleFeePrice ?? item.idleFeePrice;
          mergedItem.daysOfWeek = mergedItem.daysOfWeek ?? item.daysOfWeek;
          mergedItem.startDate = mergedItem.startDate ?? item.startDate;
          mergedItem.endDate = mergedItem.endDate ?? item.endDate;
          mergedItem.startTime = mergedItem.startTime ?? item.startTime;
          mergedItem.endTime = mergedItem.endTime ?? item.endTime;
          mergedItem.minDuration = mergedItem.minDuration ?? item.minDuration;
          mergedItem.maxDuration = mergedItem.maxDuration ?? item.maxDuration;
        }

        return [mergedItem];
      }
    }

    for (final parkingItem in parkingFeeItems) {
      final parent =
          nonParkingFeeItems.firstWhereOrNull((element) => element.dateAndTimeRestrictionsMatch(parkingItem));

      if (parent == null) {
        log('No parent for parking fee item.');
        nonParkingFeeItems.add(parkingItem);
      } else {
        parent.idleFeePrice = parkingItem.idleFeePrice;
        parent.minDuration = parkingItem.minDuration;
        parent.maxDuration = parkingItem.maxDuration;
      }
    }
    // ToDo - implement
    return nonParkingFeeItems;
  }

  static List<TariffItemModel> pruneExpired(List<TariffItemModel> allItems, DateTime now) {
    final nowDateOnly = DateUtils.dateOnly(now);
    final prunedItems = <TariffItemModel>[];

    for (final item in allItems) {
      if (item.endDate != null) {
        final endDateParsed = DateTime.tryParse(item.endDate!);
        // endDate is treated as exclusive (consistent with isActiveOnDateRange).
        // If now's date is on or after endDate, the item is expired.
        if (endDateParsed != null && !nowDateOnly.isBefore(endDateParsed)) {
          continue;
        }
      }

      prunedItems.add(item);
    }

    return prunedItems;
  }

  static List<TariffItemModel> pruneFarFuture(List<TariffItemModel> allItems, DateTime now) {
    final nowDateOnly = DateUtils.dateOnly(now);
    final prunedItems = <TariffItemModel>[];

    for (final item in allItems) {
      if (item.startDate != null) {
        final startDateParsed = DateTime.tryParse(item.startDate!);
        if (startDateParsed != null && startDateParsed.isAfter(nowDateOnly)) {
          // Item starts in the future — only show if within 7-day window
          final sevenDaysBefore = startDateParsed.subtract(const Duration(days: 7));
          if (nowDateOnly.isBefore(sevenDaysBefore)) {
            continue;
          }
        }
      }

      prunedItems.add(item);
    }

    return prunedItems;
  }

  TariffDisplayType get displayType {
    if (_items.length < 2) {
      return TariffDisplayType.fixedFee;
    } else if (_items.length >= 24) {
      bool have24OneHourItems = true;
      for (var index = 0; index < 23; index++) {
        // check if 24 items in a row are 1 hour apart
        final item = _items[index];

        if (item.timeInterval != 60) {
          have24OneHourItems = false;
          break;
        }
      }

      return have24OneHourItems ? TariffDisplayType.dynamic : TariffDisplayType.scheduled;
    } else {
      return TariffDisplayType.scheduled;
    }
  }

  List<TariffItemModel>? get threeHourItems {
    return threeHourItemsAt(DateTime.now());
  }

  List<TariffItemModel>? threeHourItemsAt(DateTime dateTime) {
    final previousHour = dateTime.subtract(const Duration(hours: 1));
    final nextHour = dateTime.add(const Duration(hours: 1));

    final previousHourItem =
        _items.firstWhereOrNull((element) => element.isActiveAtTime(previousHour) && element.startTime != null);
    final thisHourItem =
        _items.firstWhereOrNull((element) => element.isActiveAtTime(dateTime) && element.startTime != null);
    final nextHourItem =
        _items.firstWhereOrNull((element) => element.isActiveAtTime(nextHour) && element.startTime != null);

    if (previousHourItem != null && thisHourItem != null && nextHourItem != null) {
      return [previousHourItem, thisHourItem, nextHourItem];
    }

    return null;
  }

  TariffItemModel? itemActiveAt(DateTime dateTime) {
    final itemsWithrestrictions = _items.where((element) => element.hasRestrictions).toList();
    final activeRestrictionsItem =
        itemsWithrestrictions.firstWhereOrNull((element) => element.isActiveAtTime(dateTime));

    if (activeRestrictionsItem != null) {
      return activeRestrictionsItem;
    }

    return _items.firstWhereOrNull((element) => element.isActiveAtTime(dateTime));
  }
}

class TariffItemModel {
  double? kwhPrice;
  double? sessionPrice;
  double? timePrice;
  double? idleFeePrice;
  List<CdrAdditionalCharge>? additionalCharges;

  List<String>? daysOfWeek;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  int? minDuration;
  int? maxDuration;

  TariffItemModel({
    this.kwhPrice,
    this.sessionPrice,
    this.timePrice,
    this.idleFeePrice,
    this.additionalCharges,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.minDuration,
    this.maxDuration,
  });

  factory TariffItemModel.fromTariffElementModel(TariffElementModel element) {
    final tariffItem = TariffItemModel();

    for (var priceComponent in element.priceComponents ?? []) {
      switch (priceComponent.type) {
        case 'FLAT':
          tariffItem.sessionPrice = priceComponent.price * (1 + ((priceComponent.vat ?? 0) / 100.0));
          break;
        case 'TIME':
          tariffItem.timePrice = priceComponent.price * (1 + ((priceComponent.vat ?? 0) / 100.0));
          break;
        case 'PARKING_TIME':
          tariffItem.idleFeePrice = priceComponent.price * (1 + ((priceComponent.vat ?? 0) / 100.0));
          break;
        case 'ENERGY':
          tariffItem.kwhPrice = priceComponent.price * (1 + ((priceComponent.vat ?? 0) / 100.0));
          break;
      }
    }

    if (element.restrictions != null) {
      tariffItem.startTime = element.restrictions!.startTime;
      tariffItem.endTime = element.restrictions!.endTime;
      tariffItem.startDate = element.restrictions!.startDate;
      tariffItem.endDate = element.restrictions!.endDate;
      tariffItem.daysOfWeek = element.restrictions!.dayOfWeek;
      tariffItem.minDuration = element.restrictions!.minDuration;
      tariffItem.maxDuration = element.restrictions!.maxDuration;
    }

    return tariffItem;
  }

  bool dateAndTimeRestrictionsMatch(TariffItemModel other) {
    return startDate == other.startDate &&
        endDate == other.endDate &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  bool get hasRestrictions {
    return daysOfWeek?.isNotEmpty == true ||
        startDate != null ||
        endDate != null ||
        startTime != null ||
        endTime != null;
  }

  bool get isActiveNow {
    return isActiveAtTime(DateTime.now());
  }

  DateTime? get startDateTime {
    if (startDate == null || startTime == null) {
      return null;
    }

    return DateTime.tryParse('$startDate $startTime');
  }

  DateTime? get endDateTime {
    if (endDate == null || endTime == null) {
      return null;
    }

    final inclusiveEndDateTime = DateTime.tryParse('$endDate $endTime');
    final exclusiveEndDateTime = inclusiveEndDateTime?.subtract(const Duration(days: 1));
    return exclusiveEndDateTime;
  }

  int? get timeInterval {
    if (startTime == null || endTime == null) {
      return null;
    }

    final startSplit = startTime!.split(':');
    final endSplit = endTime!.split(':');

    if (startSplit.length != 2 || endSplit.length != 2) {
      return null;
    }

    final startHour = int.tryParse(startSplit.first);
    final startMinute = int.tryParse(startSplit.last);
    var endHour = int.tryParse(endSplit.first);
    final endMinute = int.tryParse(endSplit.last);

    if (startHour == null || startMinute == null || endHour == null || endMinute == null) {
      return null;
    }

    if (endHour == 0) {
      endHour = 24;
    }

    return ((endHour - startHour) * 60) + endMinute - startMinute;
  }

  int? weekDayNumberFromString(String weekDayString) {
    switch (weekDayString.toUpperCase()) {
      case 'MONDAY':
        return DateTime.monday;
      case 'TUESDAY':
        return DateTime.tuesday;
      case 'WEDNESDAY':
        return DateTime.wednesday;
      case 'THURSDAY':
        return DateTime.thursday;
      case 'FRIDAY':
        return DateTime.friday;
      case 'SATURDAY':
        return DateTime.saturday;
      case 'SUNDAY':
        return DateTime.sunday;
    }

    return null;
  }

  bool isActiveOnDayOfWeek(DateTime time) {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      return true;
    }

    final nowDayOfWeek = time.weekday;

    DateTime.sunday;

    for (final dayOfWeek in daysOfWeek!) {
      final dayOfWeekInt = weekDayNumberFromString(dayOfWeek);
      if (dayOfWeekInt == null) {
        log('Invalid day of week for tariff item.');
        continue;
      }

      if (dayOfWeekInt == nowDayOfWeek) {
        return true;
      }
    }

    return false;
  }

  bool isActiveOnDateRange(DateTime time) {
    if (startDate == null && endDate == null) {
      return true;
    }

    final startDateTime = startDate != null ? DateTime.tryParse(startDate!) : null;
    final endDateTime = endDate != null ? DateTime.tryParse(endDate!) : null;

    if (startDateTime == null && endDateTime == null) {
      log('Invalid start or end date for tariff item.');
      return false;
    }

    final onlyDate = DateUtils.dateOnly(time);

    if (startDateTime != null && endDateTime != null) {
      return onlyDate.isAtSameMomentAs(startDateTime) ||
          (onlyDate.isAfter(startDateTime) && onlyDate.isBefore(endDateTime));
    }

    if (startDateTime != null) {
      return onlyDate.isAtSameMomentAs(startDateTime) || onlyDate.isAfter(startDateTime);
    }

    if (endDateTime != null) {
      return onlyDate.isBefore(endDateTime);
    }

    log('ERROR: Should not reach this point.');
    return false;
  }

  bool isActiveOnTimeRange(DateTime time) {
    if (startTime == null || endTime == null) {
      return true;
    }

    final startSplit = startTime!.split(':');
    final endSplit = endTime!.split(':');

    if (startSplit.length != 2 || endSplit.length != 2) {
      log('Invalid start or end time for tariff item.');
      return false;
    }

    final startHour = int.tryParse(startSplit.first);
    final startMinute = int.tryParse(startSplit.last);
    final endHour = int.tryParse(endSplit.first);
    final endMinute = int.tryParse(endSplit.last);

    if (startHour == null || startMinute == null || endHour == null || endMinute == null) {
      log('Invalid start or end time for tariff item.');
      return false;
    }

    final startTimeWithDate = DateTime(time.year, time.month, time.day, startHour, startMinute);
    final endTimeWithDate = DateTime(time.year, time.month, time.day, endHour, endMinute);

    return time.isAtSameMomentAs(startTimeWithDate) ||
        (time.isAfter(startTimeWithDate) && time.isBefore(endTimeWithDate));
  }

  bool isActiveAtTime(DateTime time) {
    if (daysOfWeek == null && startTime == null && endTime == null && startDate == null && endDate == null) {
      return true;
    }

    bool passesDayOfWeekTest = isActiveOnDayOfWeek(time);
    if (!passesDayOfWeekTest) return false;

    bool passesDateTest = isActiveOnDateRange(time);
    if (!passesDateTest) return false;

    bool passesTimeTest = isActiveOnTimeRange(time);
    return passesTimeTest;
  }
}
