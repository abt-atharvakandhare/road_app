import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class RMTextButton extends StatelessWidget {
  const RMTextButton(
      {super.key, required this.onPressed, required this.text, this.backgroundColor, this.isLoading = false});

  final void Function()? onPressed;
  final String text;
  final Color? backgroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
            foregroundColor: RMColors.rmWhiteText,
            backgroundColor: backgroundColor ?? RMColors.rmPrimaryColor,
            disabledForegroundColor: RMColors.rmWhiteText,
            disabledBackgroundColor: RMColors.rmPrimaryColor.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(42)))),
        child: Container(
          width: double.infinity,
          height: 42,
          alignment: Alignment.center,
          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text),
        ));
  }
}
