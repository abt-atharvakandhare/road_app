import 'package:flutter/material.dart';

import 'colors.dart';

extension RMBoxDecoration on BoxDecoration {
  static final rmBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: RMColors.separatorDarkGrey),
    color: Colors.white,
  );

  static final rmBoxDecorationDisabled = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: RMColors.separatorDarkGrey),
    color: RMColors.colorSelectorDisabledGrey,
  );
}
