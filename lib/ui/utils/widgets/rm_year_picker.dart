import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RmYearPicker extends StatefulWidget {
  const RmYearPicker({
    super.key,
    required this.initialYear,
    required this.onYearSelected,
  });

  final int initialYear;
  final ValueChanged<int> onYearSelected;

  @override
  State<StatefulWidget> createState() => RmYearPickerState();
}

class RmYearPickerState extends State<RmYearPicker> {
  static const yearsToShow = 12;
  late int selectedYear;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(yearsToShow, (index) => now.year - 11 + index);
    final yearWidgets = years.map((year) {
      return TextButton(
        onPressed: () => setState(() {
          selectedYear = year;
        }),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedYear == year ? RMColors.selectedBlueGreen : null,
              ),
              child: const SizedBox(),
            ),
            Text('$year',
                style: TextStyle(fontSize: 16, color: selectedYear != year ? RMColors.rmPrimaryColor : Colors.black)),
          ],
        ),
      );
    }).toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            alignment: Alignment.centerLeft,
            color: RMColors.rmPrimaryColor,
            width: double.infinity,
            height: 103,
            child: Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Text('$selectedYear', style: const TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: yearWidgets,
                ),
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
                            child: Text(AppLocalizations.of(context)!.cancel)),
                        TextButton(
                            onPressed: () {
                              widget.onYearSelected(selectedYear);
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)!.ok)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
