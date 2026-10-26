import 'package:flutter/material.dart';

enum IconLabelRowType {
  medium,
  small,
}

/// An icon followed by a label. Multiple column items will have it icons aligned.
class IconLabelRow extends StatelessWidget {
  const IconLabelRow({
    super.key,
    required this.icon,
    required this.label,
    this.type = IconLabelRowType.medium,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final Widget icon;
  final String label;
  final IconLabelRowType type;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          SizedBox(width: 20, child: icon),
          const SizedBox(width: 14),
          Text(
            label,
            style: type == IconLabelRowType.medium
                ? Theme.of(context).textTheme.labelMedium
                : Theme.of(context).textTheme.labelSmall,
          )
        ],
      ),
    );
  }
}
