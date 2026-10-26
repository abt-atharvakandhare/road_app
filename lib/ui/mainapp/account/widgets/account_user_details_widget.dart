import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:road_mobile/ui/utils/colors.dart';

class AccountUserDetailsWidget extends StatelessWidget {
  const AccountUserDetailsWidget({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: RMColors.rmBlackText),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/account_user_icon.svg'),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                Text(email, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
