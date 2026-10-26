import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../colors.dart';

void showStyledSnackbar(BuildContext context, SvgPicture icon, String message, {bool interrupt = false}) {
  if (interrupt && context.mounted) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  final snackBar = SnackBar(
    content: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 15),
          Flexible(
            child: Text(message, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    ),
    backgroundColor: RMColors.rmBlackText,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
