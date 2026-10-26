import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMInkwellButton extends StatelessWidget {
  const RMInkwellButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
    this.iconPadding = const EdgeInsets.only(right: 20),
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry iconPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(child: child),
              if (icon != null)
                Padding(
                  padding: iconPadding,
                  child: icon,
                )
              else if (onPressed != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: RMColors.rmPrimaryColor,
                )
            ],
          ),
        ),
      ),
    );
  }
}
