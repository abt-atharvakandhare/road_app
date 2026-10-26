import 'package:flutter/material.dart';

import '../colors.dart';

class RMDrawerHandle extends StatelessWidget {
  const RMDrawerHandle({super.key, this.color, this.edgeInsets});

  final Color? color;
  final EdgeInsets? edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: edgeInsets ?? const EdgeInsets.all(0),
        child: Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: color ?? RMColors.separatorDarkGrey,
          ),
        ),
      ),
    );
  }
}
