import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class OptionsBottomSheetEntry<T> {
  const OptionsBottomSheetEntry({required this.value, required this.label});

  final T value;
  final String label;
}

/// Simple bottom sheet that lets the user pick one of [entries] and pops the
/// selected value. Used for the connector + problem-type pickers in the Report
/// a Problem flow.
class OptionsBottomSheet<T> extends StatelessWidget {
  const OptionsBottomSheet({
    super.key,
    required this.title,
    required this.entries,
    required this.selectedValue,
  });

  final String title;
  final List<OptionsBottomSheetEntry<T>> entries;
  final T? selectedValue;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<OptionsBottomSheetEntry<T>> entries,
    required T? selectedValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => OptionsBottomSheet<T>(
        title: title,
        entries: entries,
        selectedValue: selectedValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(child: Text(title, style: textTheme.headlineSmall)),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context)!.close,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: RMColors.separatorLightGrey),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: RMColors.separatorLightGrey),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final selected = entry.value == selectedValue;
                return ListTile(
                  title: Text(entry.label, style: textTheme.titleSmall),
                  trailing: selected ? Icon(Icons.check, color: RMColors.rmPrimaryColor) : null,
                  onTap: () => Navigator.of(context).pop(entry.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
