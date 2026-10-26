import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/model/locations/tariff_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tariff model ...', (tester) async {
    // Sunday 10 Sept 2023 10:30
    DateTime sun1030 = DateTime(2023, 9, 10, 10, 30);
    DateTime mon1030 = DateTime(2023, 9, 11, 10, 30);
    DateTime tue1030 = DateTime(2023, 9, 12, 10, 30);
    DateTime wed1030 = DateTime(2023, 9, 13, 10, 30);

    DateTime sun0959 = DateTime(2023, 9, 10, 9, 59);
    DateTime mon0959 = DateTime(2023, 9, 11, 9, 59);
    DateTime tue0959 = DateTime(2023, 9, 12, 9, 59);
    DateTime wed0959 = DateTime(2023, 9, 13, 9, 59);

    DateTime sun1000 = DateTime(2023, 9, 10, 10, 00);
    DateTime mon1000 = DateTime(2023, 9, 11, 10, 00);
    DateTime tue1000 = DateTime(2023, 9, 12, 10, 00);
    DateTime wed1000 = DateTime(2023, 9, 13, 10, 00);

    DateTime sun1100 = DateTime(2023, 9, 10, 11, 00);
    DateTime mon1100 = DateTime(2023, 9, 11, 11, 00);
    DateTime tue1100 = DateTime(2023, 9, 12, 11, 00);
    DateTime wed1100 = DateTime(2023, 9, 13, 11, 00);

    final tm0 = TariffItemModel(startTime: '10:00', endTime: '11:00');

    expect(tm0.isActiveAtTime(sun0959), false);
    expect(tm0.isActiveAtTime(mon0959), false);
    expect(tm0.isActiveAtTime(tue0959), false);
    expect(tm0.isActiveAtTime(wed0959), false);

    expect(tm0.isActiveAtTime(sun1000), true);
    expect(tm0.isActiveAtTime(mon1000), true);
    expect(tm0.isActiveAtTime(tue1000), true);
    expect(tm0.isActiveAtTime(wed1000), true);

    expect(tm0.isActiveAtTime(sun1030), true);
    expect(tm0.isActiveAtTime(mon1030), true);
    expect(tm0.isActiveAtTime(tue1030), true);
    expect(tm0.isActiveAtTime(wed1030), true);

    expect(tm0.isActiveAtTime(sun1100), false);
    expect(tm0.isActiveAtTime(mon1100), false);
    expect(tm0.isActiveAtTime(tue1100), false);
    expect(tm0.isActiveAtTime(wed1100), false);

    final tm2 = TariffItemModel(daysOfWeek: ['Monday', 'TUESDAY'], startTime: '10:00', endTime: '11:00');

    expect(tm2.isActiveAtTime(sun1030), false);
    expect(tm2.isActiveAtTime(mon1030), true);
    expect(tm2.isActiveAtTime(tue1030), true);
    expect(tm2.isActiveAtTime(wed1030), false);

    final tm3 = TariffItemModel(daysOfWeek: ['sunday', 'TUESDAY', 'asdasda']);

    expect(tm3.isActiveAtTime(sun1030), true);
    expect(tm3.isActiveAtTime(mon1030), false);
    expect(tm3.isActiveAtTime(tue1030), true);
    expect(tm3.isActiveAtTime(wed1030), false);

    final tm4 = TariffItemModel(startDate: '2023-09-11', endDate: '2023-09-12', startTime: '10:00', endTime: '11:00');

    expect(tm4.isActiveAtTime(sun1030), false);
    expect(tm4.isActiveAtTime(mon0959), false);
    expect(tm4.isActiveAtTime(mon1030), true);
    expect(tm4.isActiveAtTime(tue1030), false);
    expect(tm4.isActiveAtTime(tue1100), false);
    expect(tm4.isActiveAtTime(wed1030), false);

    final tm5 = TariffItemModel(startDate: '2022-02-01', endDate: '2023-08-03');
    expect(tm5.isActiveAtTime(sun1030), false);

    final tm6 = TariffItemModel(startDate: '2023-08-03');
    expect(tm6.isActiveAtTime(sun1030), true);

    final tm7 = TariffItemModel(startDate: '2023-11-01', endDate: '2023-11-03');
    expect(tm7.isActiveAtTime(sun1030), false);
  });

  testWidgets('dynamic pricing ...', (tester) async {
    await tester.runAsync(() async {
      final file = File('test_assets/json/dynamic_tariff_20230926.json');
      final fileString = await file.readAsString();

      final json = jsonDecode(fileString);
      final tariff = Tariff.fromJson(json);

      DateTime sept26at1100 = DateTime(2023, 9, 26, 11, 00);
      DateTime sept27at1100 = DateTime(2023, 9, 27, 11, 00);

      final tarifffModel = TariffModel.fromTariff(tariff, now: sept26at1100);
      expect(tarifffModel?.displayType, TariffDisplayType.dynamic);

      final threeItemssept26 = tarifffModel?.threeHourItemsAt(sept26at1100);
      expect(threeItemssept26 != null, true);

      // On Sept 27, the 24 hourly items (endDate=2023-09-27, exclusive) are all expired.
      // Only the base tariff item (no restrictions) survives, making it a fixedFee.
      final tariffModelSept27 = TariffModel.fromTariff(tariff, now: sept27at1100);
      expect(tariffModelSept27, isNotNull);
      expect(tariffModelSept27?.displayType, TariffDisplayType.fixedFee);
      expect(tariffModelSept27?.standardItem?.sessionPrice, 1.1 * 1.21);
      expect(tariffModelSept27?.standardItem?.kwhPrice, 0.73 * 1.21);

      final goeFile = File('test_assets/json/goereesepad_tariff.json');
      final goeJson = jsonDecode(await goeFile.readAsString());
      final goeTariff = Tariff.fromJson(goeJson);
      final goeTariffModel = TariffModel.fromTariff(goeTariff, now: sept26at1100);

      expect(goeTariffModel?.displayType, TariffDisplayType.fixedFee);
      final standardItem = goeTariffModel?.standardItem;
      expect(standardItem != null, true);

      final singleItemFile = File('test_assets/json/tariff_single_item_with_parking_time.json');
      final singleItemJson = jsonDecode(await singleItemFile.readAsString());
      final singleItemTariff = Tariff.fromJson(singleItemJson);
      final singleItemTariffModel = TariffModel.fromTariff(singleItemTariff, now: sept26at1100);

      expect(singleItemTariffModel?.displayType, TariffDisplayType.fixedFee);
      final singleItem = singleItemTariffModel?.standardItem;
      expect(singleItem != null, true);
      expect(singleItem?.kwhPrice, 0.55 * 1.21);
      expect(singleItem?.idleFeePrice, 4.8 * 1.21);
    });
  });

  testWidgets('rue de la jastree pricing ...', (tester) async {
    await tester.runAsync(() async {
      final file = File('test_assets/json/tariff_rue_de_la_jastree.json');
      final fileString = await file.readAsString();

      final json = jsonDecode(fileString);
      final tariff = Tariff.fromJson(json);

      DateTime sept26at1100 = DateTime(2023, 9, 26, 11, 00);

      final tariffModel = TariffModel.fromTariff(tariff, now: sept26at1100);

      expect(tariffModel?.displayType, TariffDisplayType.fixedFee);

      final standardItem = tariffModel?.standardItem;

      expect(standardItem != null, true);

      expect(standardItem?.kwhPrice, 0.473 * 1.21);
      expect(standardItem?.sessionPrice, 2.0 * 1.21);
      expect(standardItem?.timePrice, 2.0 * 1.21);
    });
  });

  testWidgets('coevorderweg 19 pricing ...', (tester) async {
    await tester.runAsync(() async {
      final file = File('test_assets/json/coevorderweg19.json');
      final fileString = await file.readAsString();

      final json = jsonDecode(fileString);
      final tariff = Tariff.fromJson(json);

      DateTime sept26at1100 = DateTime(2023, 9, 26, 11, 00);

      final tariffModel = TariffModel.fromTariff(tariff, now: sept26at1100);

      expect(tariffModel?.displayType, TariffDisplayType.scheduled);

      final activeItem = tariffModel?.itemActiveAt(sept26at1100);

      expect(activeItem != null, true);

      expect(activeItem?.kwhPrice, 0.4 * 1.21);
      expect(activeItem?.sessionPrice, null);
      expect(activeItem?.timePrice, 0.3 * 1.21);
      expect(activeItem?.idleFeePrice, 0.3 * 1.21);
    });
  });

  testWidgets('hullenbergweg 353 pricing ...', (tester) async {
    await tester.runAsync(() async {
      final file = File('test_assets/json/hullenbergweg353.json');
      final fileString = await file.readAsString();

      final json = jsonDecode(fileString);
      final tariff = Tariff.fromJson(json);

      DateTime sept26at1100 = DateTime(2023, 9, 26, 11, 00);

      final tariffModel = TariffModel.fromTariff(tariff, now: sept26at1100);

      expect(tariffModel?.displayType, TariffDisplayType.fixedFee);

      final activeItem = tariffModel?.itemActiveAt(sept26at1100);

      expect(activeItem != null, true);

      expect(activeItem?.kwhPrice, 1.0 * 1.21);
      expect(activeItem?.sessionPrice, 2.5 * 1.21);
    });
  });

  testWidgets('cdr additional charges ...', (tester) async {
    await tester.runAsync(() async {
      final file = File('test_assets/json/dynamic_tariff_20230926.json');
      final fileString = await file.readAsString();

      final json = jsonDecode(fileString);
      final tariff = Tariff.fromJson(json);

      DateTime sept26at1100 = DateTime(2023, 9, 26, 11, 00);

      // Test with no additional charges
      final tariffModelNoCharges = TariffModel.fromTariff(tariff, now: sept26at1100);
      expect(tariffModelNoCharges?.standardItem?.additionalCharges, null);

      // Test with additional charges
      final additionalCharges = [
        CdrAdditionalCharge(vat: 21.0, price: 2.0),
        CdrAdditionalCharge(vat: 21.0, price: 1.5),
      ];
      final tariffModelWithCharges =
          TariffModel.fromTariff(tariff, now: sept26at1100, additionalCharges: additionalCharges);

      expect(tariffModelWithCharges?.standardItem?.additionalCharges?.length, 2);
      expect(tariffModelWithCharges?.standardItem?.additionalCharges?[0].vat, 21.0);
      expect(tariffModelWithCharges?.standardItem?.additionalCharges?[0].price, 2.0);
      expect(tariffModelWithCharges?.standardItem?.additionalCharges?[1].vat, 21.0);
      expect(tariffModelWithCharges?.standardItem?.additionalCharges?[1].price, 1.5);

      // Test that additional charges are properly passed to all tariff items
      final threeHourItems = tariffModelWithCharges?.threeHourItemsAt(sept26at1100);
      expect(threeHourItems != null, true);
      for (final item in threeHourItems!) {
        expect(item.additionalCharges?.length, 2);
        expect(item.additionalCharges?[0].vat, 21.0);
        expect(item.additionalCharges?[0].price, 2.0);
        expect(item.additionalCharges?[1].vat, 21.0);
        expect(item.additionalCharges?[1].price, 1.5);
      }
    });
  });

  testWidgets('cdr additional charges with no tariff ...', (tester) async {
    await tester.runAsync(() async {
      // Test with no tariff but with additional charges
      final additionalCharges = [
        CdrAdditionalCharge(vat: 21.0, price: 2.0, currency: 'EUR'),
        CdrAdditionalCharge(vat: 21.0, price: 1.5, currency: 'EUR'),
      ];

      final tariffModel = TariffModel.fromTariff(null, additionalCharges: additionalCharges);

      expect(tariffModel != null, true);
      expect(tariffModel?.currency, 'EUR');
      expect(tariffModel?.standardItem?.additionalCharges?.length, 2);
      expect(tariffModel?.standardItem?.additionalCharges?[0].vat, 21.0);
      expect(tariffModel?.standardItem?.additionalCharges?[0].price, 2.0);
      expect(tariffModel?.standardItem?.additionalCharges?[1].vat, 21.0);
      expect(tariffModel?.standardItem?.additionalCharges?[1].price, 1.5);

      // Verify that other price fields are null
      expect(tariffModel?.standardItem?.kwhPrice, null);
      expect(tariffModel?.standardItem?.sessionPrice, null);
      expect(tariffModel?.standardItem?.timePrice, null);
      expect(tariffModel?.standardItem?.idleFeePrice, null);
    });
  });

  testWidgets('pruneExpired filters items with endDate+endTime in the past ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    // Item expired yesterday
    final expired = TariffItemModel(kwhPrice: 0.30, startDate: '2024-01-01', endDate: '2024-03-14', startTime: '00:00', endTime: '23:59');
    // Item still active
    final active = TariffItemModel(kwhPrice: 0.40, startDate: '2024-03-15', endDate: '2024-06-01', startTime: '00:00', endTime: '23:59');
    // Item with no restrictions (base tariff)
    final base = TariffItemModel(kwhPrice: 0.35);

    final result = TariffModel.pruneExpired([expired, active, base], now);
    expect(result.length, 2);
    expect(result.contains(active), true);
    expect(result.contains(base), true);
    expect(result.contains(expired), false);
  });

  testWidgets('pruneExpired filters items with endDate only (no endTime) ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    // Item with only endDate in the past (no endTime) — Greenflux pattern
    final expiredDateOnly = TariffItemModel(kwhPrice: 0.30, startDate: '2024-01-01', endDate: '2024-03-14');
    // Item with only endDate in the future (no endTime)
    final futureDateOnly = TariffItemModel(kwhPrice: 0.40, startDate: '2024-03-15', endDate: '2024-06-01');
    // Item with endDate == today (no endTime) — endDate is exclusive, so this is expired on today
    final todayEndDate = TariffItemModel(kwhPrice: 0.38, startDate: '2024-01-01', endDate: '2024-03-15');
    // Item with endDate == tomorrow (no endTime) — still active
    final tomorrowEndDate = TariffItemModel(kwhPrice: 0.39, startDate: '2024-01-01', endDate: '2024-03-16');
    // Item with no dates at all (base tariff)
    final base = TariffItemModel(kwhPrice: 0.35);

    final result = TariffModel.pruneExpired([expiredDateOnly, futureDateOnly, todayEndDate, tomorrowEndDate, base], now);
    expect(result.length, 3);
    expect(result.contains(expiredDateOnly), false);
    expect(result.contains(futureDateOnly), true);
    expect(result.contains(todayEndDate), false);
    expect(result.contains(tomorrowEndDate), true);
    expect(result.contains(base), true);
  });

  testWidgets('pruneExpired keeps items with no endDate ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    final noEnd = TariffItemModel(kwhPrice: 0.40, startDate: '2024-01-01');
    final noRestrictions = TariffItemModel(kwhPrice: 0.35);

    final result = TariffModel.pruneExpired([noEnd, noRestrictions], now);
    expect(result.length, 2);
  });

  testWidgets('pruneFarFuture hides items starting more than 7 days from now ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    // Item starting 8 days from now — too far, should be hidden
    final farFuture = TariffItemModel(kwhPrice: 0.50, startDate: '2024-03-23', endDate: '2024-04-01');
    // Item starting exactly 7 days from now — should be shown
    final sevenDays = TariffItemModel(kwhPrice: 0.45, startDate: '2024-03-22', endDate: '2024-04-01');
    // Item starting 3 days from now — should be shown
    final nearFuture = TariffItemModel(kwhPrice: 0.42, startDate: '2024-03-18', endDate: '2024-04-01');
    // Item with no startDate (base tariff) — always shown
    final base = TariffItemModel(kwhPrice: 0.35);
    // Currently active item — should be shown
    final current = TariffItemModel(kwhPrice: 0.40, startDate: '2024-03-01', endDate: '2024-03-20');

    final result = TariffModel.pruneFarFuture([farFuture, sevenDays, nearFuture, base, current], now);
    expect(result.length, 4);
    expect(result.contains(farFuture), false);
    expect(result.contains(sevenDays), true);
    expect(result.contains(nearFuture), true);
    expect(result.contains(base), true);
    expect(result.contains(current), true);
  });

  testWidgets('pruneFarFuture keeps items with startDate today or in the past ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    final past = TariffItemModel(kwhPrice: 0.40, startDate: '2024-03-01');
    final today = TariffItemModel(kwhPrice: 0.42, startDate: '2024-03-15');
    final noDate = TariffItemModel(kwhPrice: 0.35);

    final result = TariffModel.pruneFarFuture([past, today, noDate], now);
    expect(result.length, 3);
  });

  testWidgets('filtering reduces to 1 item makes displayType fixedFee ...', (tester) async {
    // Simulate a Greenflux station with an expired tariff and a current one.
    // After filtering the expired one, only 1 remains — should be fixedFee.
    final now = DateTime(2024, 3, 15, 12, 0);

    final tariff = Tariff(currency: 'EUR', elements: [
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.30, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-01-01', endDate: '2024-03-14'),
      ),
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.40, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-03-15', endDate: '2024-06-01'),
      ),
    ]);

    final model = TariffModel.fromTariff(tariff, now: now);
    expect(model, isNotNull);
    expect(model!.displayType, TariffDisplayType.fixedFee);
    expect(model.standardItem, isNotNull);
    expect(model.standardItem!.kwhPrice, 0.40 * 1.21);
  });

  testWidgets('filtering removes far-future tariff from display ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    final tariff = Tariff(currency: 'EUR', elements: [
      // Current tariff
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.40, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-03-01', endDate: '2024-04-01'),
      ),
      // Far future tariff (> 7 days away)
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.50, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-04-01', endDate: '2024-05-01'),
      ),
    ]);

    final model = TariffModel.fromTariff(tariff, now: now);
    expect(model, isNotNull);
    // Far future filtered, only 1 item remains
    expect(model!.displayType, TariffDisplayType.fixedFee);
    expect(model.standardItem!.kwhPrice, 0.40 * 1.21);
  });

  testWidgets('near-future tariff is shown alongside current ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    final tariff = Tariff(currency: 'EUR', elements: [
      // Current tariff (no date restriction = base)
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.40, type: 'ENERGY', vat: 21)],
      ),
      // Near future tariff (5 days away, within 7 day window)
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.50, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-03-20', endDate: '2024-05-01'),
      ),
    ]);

    final model = TariffModel.fromTariff(tariff, now: now);
    expect(model, isNotNull);
    // Both items kept
    expect(model!.displayType, TariffDisplayType.scheduled);
    expect(model.standardItem, isNotNull);
    expect(model.nonStandardItems.length, 1);
  });

  testWidgets('all items expired returns null tariff model ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    final tariff = Tariff(currency: 'EUR', elements: [
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.30, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-01-01', endDate: '2024-02-01'),
      ),
      TariffElementModel(
        priceComponentsCamelCase: [PriceComponent(price: 0.35, type: 'ENERGY', vat: 21)],
        restrictions: Restrictions(startDate: '2024-02-01', endDate: '2024-03-01'),
      ),
    ]);

    final model = TariffModel.fromTariff(tariff, now: now);
    // All items expired — model should be null (no valid pricing)
    expect(model, isNull);
  });

  testWidgets('malformed dates are safely kept (not pruned) ...', (tester) async {
    final now = DateTime(2024, 3, 15, 12, 0);

    // Items with unparseable dates should be kept as a safe fallback
    final malformedEnd = TariffItemModel(kwhPrice: 0.30, endDate: 'not-a-date');
    final malformedStart = TariffItemModel(kwhPrice: 0.40, startDate: 'garbage');
    final valid = TariffItemModel(kwhPrice: 0.35);

    final afterExpired = TariffModel.pruneExpired([malformedEnd, malformedStart, valid], now);
    expect(afterExpired.length, 3);

    final afterFuture = TariffModel.pruneFarFuture([malformedEnd, malformedStart, valid], now);
    expect(afterFuture.length, 3);
  });

}
