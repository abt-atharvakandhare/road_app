import 'package:intl/intl.dart';
import 'package:road_mobile/data/charging_connector_types.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';

/// Helper class for grouping connector data when building connector rows.
class ConnectorGroup {
  int available = 0;
  int total = 0;
  double maxPowerKw = 0;
}

/// Extract the primary kWh price from the first connector with ENERGY tariff data.
/// Returns a formatted string like "€0.45/kWh" or empty string if no tariff available.
String extractPriceText(MapLocationV2 location, AppLocalizations l10n) {
  for (final evse in location.evses) {
    for (final connector in evse.connectors) {
      final tariff = connector.tariff;
      if (tariff == null || tariff.elements == null || tariff.elements!.isEmpty) continue;

      final element = tariff.elements!.first;
      final priceComponents = element.priceComponents;
      if (priceComponents == null) continue;

      for (final component in priceComponents) {
        if (component.type == 'ENERGY' && component.price > 0) {
          final vat = component.vat ?? 0;
          final priceWithVat = component.price * (1 + (vat / 100.0));
          final currencyFormat = NumberFormat.simpleCurrency(name: tariff.currency ?? 'EUR');
          return l10n.carScreenPricePerKwh(currencyFormat.formatRoundingMidUp(priceWithVat));
        }
      }
    }
  }
  return '';
}

/// Build connector breakdown rows grouped by connector standard.
/// Returns a list of maps like: [{"title": "CCS connector - 300 kW", "detail": "3/10 available"}]
List<Map<String, String>> buildConnectorRows(MapLocationV2 location, AppLocalizations l10n) {
  final groups = <String, ConnectorGroup>{};

  for (final evse in location.evses) {
    if (evse.connectors.isEmpty) continue;
    final connector = evse.connectors.first;
    final standard = connector.standard ?? 'UNKNOWN';

    final group = groups.putIfAbsent(standard, () => ConnectorGroup());
    group.total++;
    if (evse.chargingPortAvailability == ChargingPortAvailability.available) {
      group.available++;
    }
    final power = connector.maxPower ?? evse.maxPower ?? 0;
    if (power > group.maxPowerKw) {
      group.maxPowerKw = power;
    }
  }

  return groups.entries.map((entry) {
    final connectorName = ChargingConnectorTypes.humanReadableNameFor(entry.key);
    final group = entry.value;
    return {
      'title': '$connectorName - ${group.maxPowerKw.toInt()} kW',
      'detail': l10n.carScreenAvailabilityCount(group.available, group.total),
    };
  }).toList();
}
