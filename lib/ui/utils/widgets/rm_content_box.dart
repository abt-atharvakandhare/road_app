import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMContentBox extends StatelessWidget {
  const RMContentBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = RMColors.rmPrimaryBackground,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      padding: padding,
      width: double.infinity,
      child: child,
    );
  }
}
