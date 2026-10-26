import 'package:flutter/material.dart';

import '../colors.dart';

class RMSeparator extends StatelessWidget {
  const RMSeparator({super.key, this.color, this.edgeInsets});

  final Color? color;
  final EdgeInsets? edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets ?? const EdgeInsets.all(0),
      child: Container(
        height: 1,
        color: color ?? RMColors.separatorDarkGrey,
      ),
    );
  }
}
