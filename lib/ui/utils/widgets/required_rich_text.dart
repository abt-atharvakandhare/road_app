import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

extension RequiredRichText on RichText {
  static RichText requiredText({bool isRequired = true, required List<TextSpan> children}) {
    final allSpans = children;

    if (isRequired) {
      allSpans.add(
        const TextSpan(
          text: '*',
          style: TextStyle(
            color: RMColors.destructiveRed,
          ),
        ),
      );
    }
    return RichText(text: TextSpan(children: allSpans));
  }

  static RichText requiredString({required String text, TextStyle? style}) {
    return requiredText(children: [TextSpan(text: text, style: style)]);
  }
}
