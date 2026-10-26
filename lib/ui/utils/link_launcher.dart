import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:road_mobile/services/di/injection.dart';
import 'package:road_mobile/ui/utils/rm_api_error.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/rm_modal_info_dialog.dart';

void launchProviderUri(BuildContext context, Uri? uri) {
  if (uri != null) {
    log('Launching URI: $uri');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    getIt<ModalInfoDialogs>().showErrorDialog(context, RMApiError(cause: 'Link URL is not provided'));
  }
}
