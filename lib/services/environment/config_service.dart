import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:road_mobile/services/environment/config.dart';

@lazySingleton
class ConfigService {
  final _configChannel = const MethodChannel('io.e-flux.mobile/config');

  Future<void> initialize() async {
    try {
      // Set Google Services key based on environment
      final googleServicesKey = Platform.isIOS ? Config.googleServicesApiKeyIos : Config.googleServicesApiKeyAndroid;

      await _configChannel.invokeMethod('setGoogleServicesKey', googleServicesKey);
    } on PlatformException catch (e) {
      log('Failed to set Google Services key: ${e.message}');
    }
  }
}
