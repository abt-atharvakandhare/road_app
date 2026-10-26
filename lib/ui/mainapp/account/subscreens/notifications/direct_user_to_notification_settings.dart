import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

Future<bool> directUserToNotificationSettings(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.enableNotifications),
          content: Text(
            AppLocalizations.of(context)!.pleaseAllowNotifications,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.later),
            ),
            TextButton(
              onPressed: () async {
                await AppSettings.openAppSettings(type: AppSettingsType.notification);
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(AppLocalizations.of(context)!.openSettings),
            ),
          ],
        );
      });
}
