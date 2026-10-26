import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/environment/environment.dart';
import 'package:road_mobile/services/environment/config.dart';

enum ThreeDsResult {
  /// 3DS completed successfully and a token was returned.
  success,

  /// The user cancelled the 3DS challenge (e.g. pressed back).
  cancelled,

  /// 3DS failed or errored. In the charging flow this may still be OK
  /// since webhooks handle the backend side.
  error,
}

@lazySingleton
class ThreeDsService {
  final Stage _stage;

  ThreeDsService(this._stage);

  static const _paymentChannel = MethodChannel('io.e-flux.mobile/payments');

  /// Presents the 3DS challenge web view for the given [redirectUrl].
  ///
  /// Returns a [ThreeDsOutcome] with the result status and optional token.
  ///
  /// Note: This uses Checkout's Frames SDK which is designed for the card-tokenization
  /// 3DS flow. When used for payment-session 3DS (e.g. during charging), the SDK
  /// returns a ThreeDSError/404 after the redirect because it tries to extract a token
  /// that doesn't exist in that flow. The 3DS challenge itself completes fine and
  /// webhooks handle the backend side. Ideally this should be replaced with a plain
  /// WebView that just loads the URL and detects the success/failure redirect, without
  /// the token extraction step.
  Future<ThreeDsOutcome> performThreeDs(String redirectUrl) async {
    final params = {
      'environment': _stage.target.name,
      'threeDsUrl': redirectUrl,
      'apiKey': _stage.target == StageTarget.staging
          ? Config.checkoutSandboxPublicKey
          : Config.checkoutProductionPublicKey,
    };

    final result = await _paymentChannel.invokeMethod<String>('performThreeDS', params);
    log('3DS result: $result');

    if (result == null || result.startsWith('ERROR:')) {
      return ThreeDsOutcome(ThreeDsResult.error, null);
    }

    if (result == 'CANCELLED') {
      return ThreeDsOutcome(ThreeDsResult.cancelled, null);
    }

    return ThreeDsOutcome(ThreeDsResult.success, result);
  }
}

class ThreeDsOutcome {
  final ThreeDsResult result;
  final String? token;

  ThreeDsOutcome(this.result, this.token);
}
