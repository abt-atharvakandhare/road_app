import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_inkwell_button.dart';

class AccountLinkWidget extends StatelessWidget {
  const AccountLinkWidget(
      {super.key,
      required this.text,
      this.rightIcon = 'assets/icons/open_external_link.svg',
      required this.leftIcon,
      required this.onPressed});

  final String leftIcon;
  final String text;
  final String rightIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RMInkwellButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        icon: SvgPicture.asset(rightIcon, colorFilter: ColorFilter.mode(RMColors.rmPrimaryColor, BlendMode.srcIn)),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 18, child: SvgPicture.asset(leftIcon)),
                const SizedBox(width: 12),
                Text(text, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ],
        ));
  }
}
