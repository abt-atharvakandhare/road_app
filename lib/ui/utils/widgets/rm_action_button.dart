import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMDecoratedActionButton extends StatelessWidget {
  const RMDecoratedActionButton({
    super.key,
    this.onPressed,
    this.icon,
    this.gradientColors,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget? icon;
  final List<Color>? gradientColors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradientColorsInUse = gradientColors ?? [RMColors.rmPrimaryColor, RMColors.rmPrimaryColorAppGradientEnd];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: gradientColorsInUse,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RMActionButton(
        onPressed: onPressed,
        icon: icon,
        arrowIcon: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: Colors.white,
        ),
        child: child,
      ),
    );
  }
}

class RMActionButton extends StatelessWidget {
  const RMActionButton(
      {super.key, required this.onPressed, required this.child, required this.icon, required this.arrowIcon});

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final Icon arrowIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(10),
          ))),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            // Expanded (not child + Spacer, matching RMInkwellButton): gives
            // the child a bounded width so long translations wrap or ellipsize
            // inside the button instead of overflowing the Row past the icons
            // (fr "Commencer une session de charge" overflowed by 16px on a
            // 360dp-wide screen).
            Expanded(child: Align(alignment: Alignment.centerLeft, child: child)),
            ?icon,
            if (onPressed != null) arrowIcon,
          ],
        ),
      ),
    );
  }
}
