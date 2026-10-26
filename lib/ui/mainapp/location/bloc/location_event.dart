part of 'location_bloc.dart';

@freezed
sealed class LocationEvent with _$LocationEvent {
  const factory LocationEvent.checkServiceStatus() = CheckServiceStatus;
  const factory LocationEvent.requestPermission() = RequestPermission;
  const factory LocationEvent.startUpdates() = StartUpdates;
  const factory LocationEvent.stopUpdates() = StopUpdates;
  const factory LocationEvent.locationReceived(UserLocation locationData) = LocationReceived;
  const factory LocationEvent.useDebugLocation(UserLocation? userLocation) = UseDebugLocation;
}
