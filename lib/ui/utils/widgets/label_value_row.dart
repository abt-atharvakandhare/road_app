import 'package:flutter/material.dart';

/// An icon followed by a label. Multiple column items will have it icons aligned.
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final String label;
  final Widget value;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
          value,
        ],
      ),
    );
  }
}
