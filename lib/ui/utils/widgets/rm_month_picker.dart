import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RmMonthPicker extends StatefulWidget {
  const RmMonthPicker({super.key, required this.initialMonth, required this.onMonthSelected});

  /// Month number (1-12)
  final int initialMonth;
  final ValueChanged<int> onMonthSelected;

  @override
  State<StatefulWidget> createState() => RmMonthPickerState();
}

class RmMonthPickerState extends State<RmMonthPicker> {
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
  }

  String _getMonthName(int month) {
    // Create a DateTime with the given month to get localized month name
    final date = DateTime(0, month);
    return DateFormat.MMMM().format(date);
  }

  String _getShortMonthName(int month) {
    final date = DateTime(0, month);
    return DateFormat.MMM().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final monthWidgets = List.generate(12, (index) {
      final month = index + 1;
      return TextButton(
        onPressed: () => setState(() {
          selectedMonth = month;
        }),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedMonth == month ? RMColors.selectedBlueGreen : null,
              ),
              child: const SizedBox(),
            ),
            Text(
              _getShortMonthName(month),
              style: TextStyle(fontSize: 14, color: selectedMonth != month ? RMColors.rmPrimaryColor : Colors.black),
            ),
          ],
        ),
      );
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              color: RMColors.rmPrimaryColor,
              width: double.infinity,
              height: 103,
              child: Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(_getMonthName(selectedMonth), style: const TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  GridView.count(shrinkWrap: true, crossAxisCount: 4, children: monthWidgets),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onMonthSelected(selectedMonth);
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
