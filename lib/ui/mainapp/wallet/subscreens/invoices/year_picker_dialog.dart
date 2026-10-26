import 'package:flutter/material.dart';

class YearPickerDialog extends StatefulWidget {
  const YearPickerDialog({super.key, required this.initialDate, required this.onYearSelected});

  final DateTime? initialDate;
  final ValueChanged<DateTime> onYearSelected;

  @override
  State<StatefulWidget> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<YearPickerDialog> {
  late DateTime? _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Year"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (_selectedYear != null) {
              widget.onYearSelected(_selectedYear!);
            }
          },
          child: const Text("Ok"),
        ),
      ],
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        // Need to use container to add size constraint.
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(DateTime.now().year - 10),
          lastDate: DateTime.now(),
          selectedDate: _selectedYear,
          onChanged: (DateTime dateTime) {
            setState(() {
              _selectedYear = dateTime;
            });
          },
        ),
      ),
    );
  }
}
