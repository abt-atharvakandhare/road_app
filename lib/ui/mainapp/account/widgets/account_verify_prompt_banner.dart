import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class AccountVerifyPromptBanner extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const AccountVerifyPromptBanner({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: RMColors.activeChargeBlueText.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: RMColors.activeChargeBlueText.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: SvgPicture.asset('assets/icons/arrow_disclosure_right.svg',
                      colorFilter: ColorFilter.mode(
                        RMColors.rmPrimaryColor,
                        BlendMode.srcIn,
                      ))),
            ],
          ),
        ));
  }
}
