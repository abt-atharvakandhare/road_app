class EvseIdExtractor {
  static String? extractEvseIdFromDashboardUrl(String url) {
    // Support both http and https
    final supportedPrefixes = [
      'https://dashboard.e-flux.io/evse/',
      'http://dashboard.e-flux.io/evse/',
      'https://chargestation.road.io/evse/',
      'http://chargestation.road.io/evse/',
      'https://dashboard.e-flux.nl/evse/',
      'http://dashboard.e-flux.nl/evse/',
    ];

    String? remainingPath;
    for (final prefix in supportedPrefixes) {
      if (url.startsWith(prefix)) {
        remainingPath = url.substring(prefix.length);
        break;
      }
    }

    if (remainingPath == null || remainingPath.isEmpty) {
      return null;
    }

    // Remove query parameters, fragments, and trailing slashes
    final queryIndex = remainingPath.indexOf('?');
    final fragmentIndex = remainingPath.indexOf('#');

    var endIndex = remainingPath.length;
    if (queryIndex != -1) {
      endIndex = queryIndex;
    }
    if (fragmentIndex != -1 && fragmentIndex < endIndex) {
      endIndex = fragmentIndex;
    }

    remainingPath = remainingPath.substring(0, endIndex);

    // Remove trailing slashes
    remainingPath = remainingPath.replaceAll(RegExp(r'/+$'), '');

    // Extract the last 7 or more digits
    final regex = RegExp(r'(\d{7,})$');
    final match = regex.firstMatch(remainingPath);

    return match?.group(1);
  }
}
