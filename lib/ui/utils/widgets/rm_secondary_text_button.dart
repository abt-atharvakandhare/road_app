import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMSecondaryTextButton extends StatelessWidget {
  const RMSecondaryTextButton({super.key, required this.onPressed, required this.child});

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            foregroundColor: RMColors.rmPrimaryColor,
            backgroundColor: Colors.transparent,
            side: BorderSide(color: RMColors.rmPrimaryColor),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(42)))),
        child: Container(
          width: double.infinity,
          height: 42,
          alignment: Alignment.center,
          child: child,
        ));
  }
}
