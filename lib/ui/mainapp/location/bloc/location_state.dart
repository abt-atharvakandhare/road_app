part of 'location_bloc.dart';

@freezed
sealed class LocationState with _$LocationState {
  const factory LocationState.initial() = Initial;
  const factory LocationState.serviceDisabled() = ServiceDisabled;
  const factory LocationState.shouldAskForPermission() = ShouldAskForPermission;
  const factory LocationState.shouldDirectToSettings() = PermissionDenied;
  const factory LocationState.permissionGranted() = PermissionGranted;
  const factory LocationState.locationProvided({required UserLocation userLocation}) = LocationProvided;
}

extension LocationSupport on LocationState {
  UserLocation? get lastKnownLocation => switch (this) {
        LocationProvided(:final userLocation) => userLocation,
        _ => null,
      };
}
