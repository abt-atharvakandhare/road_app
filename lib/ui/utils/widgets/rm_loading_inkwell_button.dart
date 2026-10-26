import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

/// A variant of [RMInkwellButton] that supports a loading state.
///
/// When [isLoading] is true:
/// - The trailing icon/arrow is replaced with a spinner
/// - The child content is dimmed (opacity 0.5)
/// - Tap interaction is disabled
///
/// Layout: [leadingIcon?] [child (expanded)] [icon OR spinner OR arrow]
class RMLoadingInkwellButton extends StatelessWidget {
  const RMLoadingInkwellButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.leadingIcon,
    this.leadingIconPadding = const EdgeInsets.only(right: 20),
    this.icon,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
    this.iconPadding = const EdgeInsets.only(right: 20),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? leadingIcon;
  final EdgeInsetsGeometry leadingIconPadding;
  final Widget? icon;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry iconPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leadingIcon != null)
                Padding(
                  padding: leadingIconPadding,
                  child: leadingIcon,
                ),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLoading ? 0.5 : 1.0,
                  child: child,
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RMColors.rmPrimaryColor,
                  ),
                )
              else if (icon != null)
                Padding(
                  padding: iconPadding,
                  child: icon,
                )
              else if (onPressed != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: RMColors.rmPrimaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
