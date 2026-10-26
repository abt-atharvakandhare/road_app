part of 'app_links_cubit.dart';

@freezed
class AppLinksState with _$AppLinksState {
  const factory AppLinksState.idle() = AppLinksIdle;
  const factory AppLinksState.showChargingStation(String stationId) = AppLinksShowChargingStation;
  const factory AppLinksState.showCharging() = AppLinksShowCharging;
  const factory AppLinksState.showSessions() = AppLinksShowSessions;
}
