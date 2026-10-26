import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/locations/map_locations_response_model.dart';
import 'package:road_mobile/data/user_location/user_location.dart';
import 'package:road_mobile/ui/utils/charging_port_availability.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/facility_icons.dart';
import 'package:road_mobile/ui/utils/string_presentation.dart';
import 'package:road_mobile/ui/utils/widgets/rm_charging_port_status_icon.dart';

class ChargingStationListItem extends StatelessWidget {
  final MapLocationV2 location;
  final VoidCallback? onTap;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final UserLocation? userLocation;
  final bool showDistance;

  const ChargingStationListItem({
    super.key,
    required this.location,
    this.onTap,
    this.leadingWidget,
    this.trailingWidget,
    this.userLocation,
    this.showDistance = false,
  });

  String _formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    } else {
      final km = distanceMeters / 1000;
      if (km < 10) {
        return '${km.toStringAsFixed(1)} km';
      } else {
        return '${km.toStringAsFixed(0)} km';
      }
    }
  }

  Widget _buildBadge(BuildContext context, String text, {Widget? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[icon, const SizedBox(width: 4)],
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String? _getPricePerKwh() {
    // First try to get price from connector tariffs
    for (final evse in location.evses) {
      for (final connector in evse.connectors) {
        if (connector.tariff != null) {
          final price = _extractPriceFromTariff(connector.tariff!);
          if (price != null) return price;
        }
      }
    }

    // Fall back to user special tariffs if no connector tariffs
    for (final evse in location.evses) {
      if (evse.userSpecialTariffs != null && evse.userSpecialTariffs!.isNotEmpty) {
        final tariff = evse.userSpecialTariffs!.first.tariff;
        if (tariff != null) {
          final price = _extractPriceFromTariff(tariff);
          if (price != null) return price;
        }
      }
    }

    return null;
  }

  String? _extractPriceFromTariff(Tariff tariff) {
    if (tariff.elements == null || tariff.elements!.isEmpty) return null;

    // Look for ENERGY type price component in the first element
    final element = tariff.elements!.first;
    final priceComponents = element.priceComponentsCamelCase ?? element.priceComponentsSnakeCase;

    if (priceComponents != null) {
      for (final component in priceComponents) {
        if (component.type == 'ENERGY') {
          final vat = component.vat ?? 0;
          final priceWithVat = component.price * (1 + (vat / 100.0));
          final currencyFormat = NumberFormat.simpleCurrency(name: tariff.currency ?? 'EUR');
          return '${currencyFormat.formatRoundingMidUp(priceWithVat)}/kWh';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate distance if user location is available
    String? distanceText;
    if (showDistance && userLocation != null && location.geoLocation != null) {
      final stationLocation = UserLocation(
        latitude: location.geoLocation!.coordinates[1],
        longitude: location.geoLocation!.coordinates[0],
        accuracy: 0,
      );
      final distance = userLocation!.distanceToOtherLocation(stationLocation).toDouble();
      distanceText = _formatDistance(distance);
    }

    // Get maximum power across all available EVSEs
    String? maxPowerText;
    if (location.evses.isNotEmpty) {
      final maxPowerKw = location.evses.fold<double>(0, (max, evse) {
        // Only include power from available EVSEs
        if (evse.chargingPortAvailability == ChargingPortAvailability.available) {
          final power = evse.maxPower ?? 0;
          return power > max ? power : max;
        }
        return max;
      });
      if (maxPowerKw > 0) {
        maxPowerText = '${maxPowerKw.toInt()} kW';
      }
    }

    final pricePerKwh = _getPricePerKwh();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leadingWidget != null) ...[leadingWidget!, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operator Name (or location name as fallback)
                  Text(
                    location.subOperator?.name ?? location.name ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600, // Semi-bold
                    ),
                  ),
                  // Address (only show if different from displayed title and not empty)
                  if (location.address != null &&
                      location.address!.isNotEmpty &&
                      location.address != (location.subOperator?.name ?? location.name)) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatAddress(location),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Badge Row
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      // Availability Badge
                      _buildBadge(
                        context,
                        location.availabilityWithTotal,
                        icon: RMChargingPortStatusIcon(chargePortStatus: location.chargingStatus),
                      ),
                      // Power Badge
                      if (maxPowerText != null) _buildBadge(context, maxPowerText),
                      // Price Badge (when available)
                      if (pricePerKwh != null) _buildBadge(context, pricePerKwh),
                      // Facility Icons
                      ...FacilityIcons.getIconPaths(
                        location.facilities,
                      ).map((iconPath) => SvgPicture.asset(iconPath, width: 16, height: 16)),
                    ],
                  ),
                ],
              ),
            ),
            // Distance
            if (distanceText != null) ...[
              const SizedBox(width: 8),
              Text(distanceText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(width: 12),
            // Chevron
            if (trailingWidget != null)
              trailingWidget!
            else
              Icon(Icons.chevron_right, color: RMColors.rmPrimaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatAddress(MapLocationV2 location) {
    final address = location.address ?? '';
    final city = location.city;
    if (city != null && city.isNotEmpty && !address.contains(city)) {
      return '$address, $city';
    }
    return address;
  }
}
