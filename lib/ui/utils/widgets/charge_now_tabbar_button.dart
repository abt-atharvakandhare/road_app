import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class ChargeNowTabbarButton extends StatelessWidget {
  const ChargeNowTabbarButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [RMColors.rmPrimaryColorAppGradientStart, RMColors.rmPrimaryColorAppGradientEnd])),
          child: Center(child: SvgPicture.asset('assets/icons/lightning_bolt_18_24.svg')),
        ),
        SizedBox(
          height: 46,
          width: 46,
          child: TextButton(
              onPressed: onPressed,
              style:
                  TextButton.styleFrom(shape: CircleBorder(side: BorderSide(width: 3, color: RMColors.rmPrimaryColor))),
              child: const SizedBox()),
        ),
      ],
    );
  }
}
