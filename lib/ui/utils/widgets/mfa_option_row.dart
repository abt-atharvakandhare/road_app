import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';

/// A bordered card row for a sign-in method/option: title, caption and a
/// trailing affordance. Shared between the signup "Secure Sign-in" step and
/// the settings security screen.
class MfaOptionRow extends StatelessWidget {
  const MfaOptionRow({
    super.key,
    required this.title,
    this.caption,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// A disabled row (e.g. not permitted by administrator policy) renders
  /// greyed out and ignores taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: RMColors.containerBorderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        enabled: enabled,
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: caption != null ? Text(caption!, style: Theme.of(context).textTheme.bodySmall) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// The "Set up"-style trailing text button of an [MfaOptionRow].
class MfaRowActionButton extends StatelessWidget {
  const MfaRowActionButton({super.key, required this.text, required this.onPressed, this.destructive = false});

  final String text;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: destructive ? RMColors.errorRed : RMColors.rmPrimaryColor)),
    );
  }
}
