import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class SwitchItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;

  const SwitchItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Text(title, style: Theme.of(context).textTheme.bodySmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12))
          : null,
      trailing: Switch.adaptive(
        activeThumbColor: RMColors.rmPrimaryColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
