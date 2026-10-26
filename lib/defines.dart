class Defines {
  static bool intercomEnabled = true;
  static bool liveActivitiesEnabled = true;

  // Kill switch for `GET /1/active-sessions/current-charging-values/{id}`.
  // BE currently surfaces raw cumulative meter readings through this endpoint
  // (no MeterStart subtraction), which produces nonsense kWh values mid-session
  // and races the BE Live Activity push. While off, the app sources kWh from
  // `activeSession.kwh` on the list endpoint instead — same field the BE push
  // uses, so Dart and BE updates stay in sync. Flip back on once BE is fixed.
  static bool currentChargingValuesEndpointEnabled = false;

  // Session filter feature flags - enable when backend supports these filters
  static bool showChargeCardFilter = false;
  static bool showPaymentMethodFilter = false;
}

class AppDefaults {
  static const double defaultMapLatitude = 52.3709363;
  static const double defaultMapLongitude = 4.8876122;
}

class InfraProviderIdPostfix {
  static const String eFlux = 'EFL';
}
