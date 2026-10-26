import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:road_mobile/l10n/app_localizations.dart';

@injectable
class ModalInfoDialogs {
  ModalInfoDialogs(this._analytics);
  final Analytics? _analytics;

  void showErrorDialog(BuildContext context, RMApiError error) {
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    _analytics?.logErrorDialogShown(error.cause);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(
          AppLocalizations.of(context)!.somethingWentWrong + error.causeString(context),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void showTextDialog(BuildContext context, String text, {String? title}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: title != null ? Text(title) : Text(AppLocalizations.of(context)!.error),
        content: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}
