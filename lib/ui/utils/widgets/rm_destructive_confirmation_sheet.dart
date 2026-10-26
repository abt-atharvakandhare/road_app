import 'package:flutter/material.dart';
import 'package:road_mobile/ui/utils/colors.dart';
import 'package:road_mobile/ui/utils/widgets/rm_drawer_handle.dart';
import 'package:road_mobile/ui/utils/widgets/rm_text_button.dart';

class RMDestructiveConfirmationSheet extends StatelessWidget {
  const RMDestructiveConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmationButtonText,
    required this.cancelButtonText,
    this.warningText,
  });

  final String title;
  final String message;
  final String confirmationButtonText;
  final String cancelButtonText;
  final String? warningText;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmationButtonText,
    required String cancelButtonText,
    String? warningText,
  }) async {
    final result = await showModalBottomSheet<bool>(
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (context) => RMDestructiveConfirmationSheet(
        title: title,
        message: message,
        confirmationButtonText: confirmationButtonText,
        cancelButtonText: cancelButtonText,
        warningText: warningText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const RMDrawerHandle(),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.labelMedium),
            if (warningText != null) ...[
              const SizedBox(height: 16),
              Text(warningText!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            RMTextButton(
              onPressed: () => Navigator.of(context).pop(true),
              text: confirmationButtonText,
              backgroundColor: RMColors.destructiveRed,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
