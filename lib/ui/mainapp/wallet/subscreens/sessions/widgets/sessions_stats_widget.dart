import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/data/model/sessions/sessions_model.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class SessionsStatsWidget extends StatelessWidget {
  const SessionsStatsWidget({super.key, required this.stats, required this.totalSessions});

  final SessionStats? stats;
  final int totalSessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Row 1: Total sessions & Total Energy
        _StatsRow(
          leftItem: _StatItem(
            value: NumberFormat.decimalPattern().format(totalSessions),
            label: l10n.totalSessions,
            icon: SvgPicture.asset('assets/icons/sessions_car.svg', width: 18, height: 18),
          ),
          rightItem: _StatItem(
            value: _formatKwh(stats?.totalKwh),
            label: l10n.totalEnergy,
            icon: SvgPicture.asset('assets/icons/sessions_total_energy_lightning.svg', width: 18, height: 18),
          ),
          showTopBorder: true,
          showBottomBorder: true,
        ),
        // Row 2: Total time & Cost
        _StatsRow(
          leftItem: _StatItem(
            value: _formatDuration(stats?.totalDurationSeconds, l10n),
            label: l10n.totalTime,
            icon: SvgPicture.asset('assets/icons/sessions_total_time_clock.svg', width: 18, height: 18),
          ),
          rightItem: _CostStatItem(
            value: _formatCost(stats),
            label: l10n.totalCost,
            icon: SvgPicture.asset('assets/icons/sessions_cost_coins.svg', width: 18, height: 18),
            tooltipText: l10n.costTooltipText,
          ),
          showBottomBorder: true,
        ),
      ],
    );
  }

  String _formatKwh(double? kwh) {
    if (kwh == null) return '-';
    final formatter = NumberFormat.decimalPattern();
    return '${formatter.format(kwh.round())} kWh';
  }

  String _formatDuration(double? seconds, AppLocalizations l10n) {
    if (seconds == null) return '-';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return l10n.hAndMin(hours, minutes);
    }
    return l10n.nMinutes(minutes);
  }

  String _formatCost(SessionStats? stats) {
    if (stats?.totalCosts == null) return '-';
    final currencyFormat = NumberFormat.simpleCurrency(name: stats!.currency);
    return currencyFormat.format(stats.totalCosts!);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.leftItem,
    required this.rightItem,
    this.showTopBorder = false,
    this.showBottomBorder = false,
  });

  final Widget leftItem;
  final Widget rightItem;
  final bool showTopBorder;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(color: RMColors.separatorDarkGrey, width: 1);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: showTopBorder ? borderSide : BorderSide.none,
                bottom: showBottomBorder ? borderSide : BorderSide.none,
              ),
            ),
            child: leftItem,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: showTopBorder ? borderSide : BorderSide.none,
                bottom: showBottomBorder ? borderSide : BorderSide.none,
              ),
            ),
            child: rightItem,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: RMColors.rmBlackText,
                    letterSpacing: -0.144,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: RMColors.rmDarkText),
                ),
              ],
            ),
          ),
          icon,
        ],
      ),
    );
  }
}

class _CostStatItem extends StatelessWidget {
  const _CostStatItem({required this.value, required this.label, required this.icon, required this.tooltipText});

  final String value;
  final String label;
  final Widget icon;
  final String tooltipText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: RMColors.rmBlackText,
                    letterSpacing: -0.144,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: RMColors.rmDarkText),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _showInfoBottomSheet(context),
                      child: Icon(Icons.help_outline, size: 14, color: RMColors.searchTextGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          icon,
        ],
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalCost,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: RMColors.rmBlackText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: RMColors.rmBlackText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Separator
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 1)),
            // Description text
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
              child: Text(
                tooltipText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14, color: RMColors.rmBlackText, height: 1.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
