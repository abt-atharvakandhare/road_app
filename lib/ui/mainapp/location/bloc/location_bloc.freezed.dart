// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationEvent()';
}


}

/// @nodoc
class $LocationEventCopyWith<$Res>  {
$LocationEventCopyWith(LocationEvent _, $Res Function(LocationEvent) __);
}


/// Adds pattern-matching-related methods to [LocationEvent].
extension LocationEventPatterns on LocationEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckServiceStatus value)?  checkServiceStatus,TResult Function( RequestPermission value)?  requestPermission,TResult Function( StartUpdates value)?  startUpdates,TResult Function( StopUpdates value)?  stopUpdates,TResult Function( LocationReceived value)?  locationReceived,TResult Function( UseDebugLocation value)?  useDebugLocation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckServiceStatus() when checkServiceStatus != null:
return checkServiceStatus(_that);case RequestPermission() when requestPermission != null:
return requestPermission(_that);case StartUpdates() when startUpdates != null:
return startUpdates(_that);case StopUpdates() when stopUpdates != null:
return stopUpdates(_that);case LocationReceived() when locationReceived != null:
return locationReceived(_that);case UseDebugLocation() when useDebugLocation != null:
return useDebugLocation(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckServiceStatus value)  checkServiceStatus,required TResult Function( RequestPermission value)  requestPermission,required TResult Function( StartUpdates value)  startUpdates,required TResult Function( StopUpdates value)  stopUpdates,required TResult Function( LocationReceived value)  locationReceived,required TResult Function( UseDebugLocation value)  useDebugLocation,}){
final _that = this;
switch (_that) {
case CheckServiceStatus():
return checkServiceStatus(_that);case RequestPermission():
return requestPermission(_that);case StartUpdates():
return startUpdates(_that);case StopUpdates():
return stopUpdates(_that);case LocationReceived():
return locationReceived(_that);case UseDebugLocation():
return useDebugLocation(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckServiceStatus value)?  checkServiceStatus,TResult? Function( RequestPermission value)?  requestPermission,TResult? Function( StartUpdates value)?  startUpdates,TResult? Function( StopUpdates value)?  stopUpdates,TResult? Function( LocationReceived value)?  locationReceived,TResult? Function( UseDebugLocation value)?  useDebugLocation,}){
final _that = this;
switch (_that) {
case CheckServiceStatus() when checkServiceStatus != null:
return checkServiceStatus(_that);case RequestPermission() when requestPermission != null:
return requestPermission(_that);case StartUpdates() when startUpdates != null:
return startUpdates(_that);case StopUpdates() when stopUpdates != null:
return stopUpdates(_that);case LocationReceived() when locationReceived != null:
return locationReceived(_that);case UseDebugLocation() when useDebugLocation != null:
return useDebugLocation(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checkServiceStatus,TResult Function()?  requestPermission,TResult Function()?  startUpdates,TResult Function()?  stopUpdates,TResult Function( UserLocation locationData)?  locationReceived,TResult Function( UserLocation? userLocation)?  useDebugLocation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CheckServiceStatus() when checkServiceStatus != null:
return checkServiceStatus();case RequestPermission() when requestPermission != null:
return requestPermission();case StartUpdates() when startUpdates != null:
return startUpdates();case StopUpdates() when stopUpdates != null:
return stopUpdates();case LocationReceived() when locationReceived != null:
return locationReceived(_that.locationData);case UseDebugLocation() when useDebugLocation != null:
return useDebugLocation(_that.userLocation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checkServiceStatus,required TResult Function()  requestPermission,required TResult Function()  startUpdates,required TResult Function()  stopUpdates,required TResult Function( UserLocation locationData)  locationReceived,required TResult Function( UserLocation? userLocation)  useDebugLocation,}) {final _that = this;
switch (_that) {
case CheckServiceStatus():
return checkServiceStatus();case RequestPermission():
return requestPermission();case StartUpdates():
return startUpdates();case StopUpdates():
return stopUpdates();case LocationReceived():
return locationReceived(_that.locationData);case UseDebugLocation():
return useDebugLocation(_that.userLocation);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checkServiceStatus,TResult? Function()?  requestPermission,TResult? Function()?  startUpdates,TResult? Function()?  stopUpdates,TResult? Function( UserLocation locationData)?  locationReceived,TResult? Function( UserLocation? userLocation)?  useDebugLocation,}) {final _that = this;
switch (_that) {
case CheckServiceStatus() when checkServiceStatus != null:
return checkServiceStatus();case RequestPermission() when requestPermission != null:
return requestPermission();case StartUpdates() when startUpdates != null:
return startUpdates();case StopUpdates() when stopUpdates != null:
return stopUpdates();case LocationReceived() when locationReceived != null:
return locationReceived(_that.locationData);case UseDebugLocation() when useDebugLocation != null:
return useDebugLocation(_that.userLocation);case _:
  return null;

}
}

}

/// @nodoc


class CheckServiceStatus implements LocationEvent {
  const CheckServiceStatus();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckServiceStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationEvent.checkServiceStatus()';
}


}




/// @nodoc


class RequestPermission implements LocationEvent {
  const RequestPermission();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestPermission);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationEvent.requestPermission()';
}


}




/// @nodoc


class StartUpdates implements LocationEvent {
  const StartUpdates();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StartUpdates);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationEvent.startUpdates()';
}


}




/// @nodoc


class StopUpdates implements LocationEvent {
  const StopUpdates();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StopUpdates);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationEvent.stopUpdates()';
}


}




/// @nodoc


class LocationReceived implements LocationEvent {
  const LocationReceived(this.locationData);
  

 final  UserLocation locationData;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationReceivedCopyWith<LocationReceived> get copyWith => _$LocationReceivedCopyWithImpl<LocationReceived>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationReceived&&(identical(other.locationData, locationData) || other.locationData == locationData));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locationData);
}

@override
String toString() {
    return 'LocationEvent.locationReceived(locationData: $locationData)';
}


}

/// @nodoc
abstract mixin class $LocationReceivedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $LocationReceivedCopyWith(LocationReceived value, $Res Function(LocationReceived) _then) = _$LocationReceivedCopyWithImpl;
@useResult
$Res call({
 UserLocation locationData
});




}
/// @nodoc
class _$LocationReceivedCopyWithImpl<$Res>
    implements $LocationReceivedCopyWith<$Res> {
  _$LocationReceivedCopyWithImpl(this._self, this._then);

  final LocationReceived _self;
  final $Res Function(LocationReceived) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locationData = null,}) {
  return _then(LocationReceived(
null == locationData ? _self.locationData : locationData // ignore: cast_nullable_to_non_nullable
as UserLocation,
  ));
}


}

/// @nodoc


class UseDebugLocation implements LocationEvent {
  const UseDebugLocation(this.userLocation);
  

 final  UserLocation? userLocation;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UseDebugLocationCopyWith<UseDebugLocation> get copyWith => _$UseDebugLocationCopyWithImpl<UseDebugLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UseDebugLocation&&(identical(other.userLocation, userLocation) || other.userLocation == userLocation));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userLocation);
}

@override
String toString() {
    return 'LocationEvent.useDebugLocation(userLocation: $userLocation)';
}


}

/// @nodoc
abstract mixin class $UseDebugLocationCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $UseDebugLocationCopyWith(UseDebugLocation value, $Res Function(UseDebugLocation) _then) = _$UseDebugLocationCopyWithImpl;
@useResult
$Res call({
 UserLocation? userLocation
});




}
/// @nodoc
class _$UseDebugLocationCopyWithImpl<$Res>
    implements $UseDebugLocationCopyWith<$Res> {
  _$UseDebugLocationCopyWithImpl(this._self, this._then);

  final UseDebugLocation _self;
  final $Res Function(UseDebugLocation) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userLocation = freezed,}) {
  return _then(UseDebugLocation(
freezed == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation?,
  ));
}


}

/// @nodoc
mixin _$LocationState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState()';
}


}

/// @nodoc
class $LocationStateCopyWith<$Res>  {
$LocationStateCopyWith(LocationState _, $Res Function(LocationState) __);
}


/// Adds pattern-matching-related methods to [LocationState].
extension LocationStatePatterns on LocationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( ServiceDisabled value)?  serviceDisabled,TResult Function( ShouldAskForPermission value)?  shouldAskForPermission,TResult Function( PermissionDenied value)?  shouldDirectToSettings,TResult Function( PermissionGranted value)?  permissionGranted,TResult Function( LocationProvided value)?  locationProvided,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case ServiceDisabled() when serviceDisabled != null:
return serviceDisabled(_that);case ShouldAskForPermission() when shouldAskForPermission != null:
return shouldAskForPermission(_that);case PermissionDenied() when shouldDirectToSettings != null:
return shouldDirectToSettings(_that);case PermissionGranted() when permissionGranted != null:
return permissionGranted(_that);case LocationProvided() when locationProvided != null:
return locationProvided(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( ServiceDisabled value)  serviceDisabled,required TResult Function( ShouldAskForPermission value)  shouldAskForPermission,required TResult Function( PermissionDenied value)  shouldDirectToSettings,required TResult Function( PermissionGranted value)  permissionGranted,required TResult Function( LocationProvided value)  locationProvided,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case ServiceDisabled():
return serviceDisabled(_that);case ShouldAskForPermission():
return shouldAskForPermission(_that);case PermissionDenied():
return shouldDirectToSettings(_that);case PermissionGranted():
return permissionGranted(_that);case LocationProvided():
return locationProvided(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( ServiceDisabled value)?  serviceDisabled,TResult? Function( ShouldAskForPermission value)?  shouldAskForPermission,TResult? Function( PermissionDenied value)?  shouldDirectToSettings,TResult? Function( PermissionGranted value)?  permissionGranted,TResult? Function( LocationProvided value)?  locationProvided,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case ServiceDisabled() when serviceDisabled != null:
return serviceDisabled(_that);case ShouldAskForPermission() when shouldAskForPermission != null:
return shouldAskForPermission(_that);case PermissionDenied() when shouldDirectToSettings != null:
return shouldDirectToSettings(_that);case PermissionGranted() when permissionGranted != null:
return permissionGranted(_that);case LocationProvided() when locationProvided != null:
return locationProvided(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  serviceDisabled,TResult Function()?  shouldAskForPermission,TResult Function()?  shouldDirectToSettings,TResult Function()?  permissionGranted,TResult Function( UserLocation userLocation)?  locationProvided,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case ServiceDisabled() when serviceDisabled != null:
return serviceDisabled();case ShouldAskForPermission() when shouldAskForPermission != null:
return shouldAskForPermission();case PermissionDenied() when shouldDirectToSettings != null:
return shouldDirectToSettings();case PermissionGranted() when permissionGranted != null:
return permissionGranted();case LocationProvided() when locationProvided != null:
return locationProvided(_that.userLocation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  serviceDisabled,required TResult Function()  shouldAskForPermission,required TResult Function()  shouldDirectToSettings,required TResult Function()  permissionGranted,required TResult Function( UserLocation userLocation)  locationProvided,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case ServiceDisabled():
return serviceDisabled();case ShouldAskForPermission():
return shouldAskForPermission();case PermissionDenied():
return shouldDirectToSettings();case PermissionGranted():
return permissionGranted();case LocationProvided():
return locationProvided(_that.userLocation);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  serviceDisabled,TResult? Function()?  shouldAskForPermission,TResult? Function()?  shouldDirectToSettings,TResult? Function()?  permissionGranted,TResult? Function( UserLocation userLocation)?  locationProvided,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case ServiceDisabled() when serviceDisabled != null:
return serviceDisabled();case ShouldAskForPermission() when shouldAskForPermission != null:
return shouldAskForPermission();case PermissionDenied() when shouldDirectToSettings != null:
return shouldDirectToSettings();case PermissionGranted() when permissionGranted != null:
return permissionGranted();case LocationProvided() when locationProvided != null:
return locationProvided(_that.userLocation);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements LocationState {
  const Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState.initial()';
}


}




/// @nodoc


class ServiceDisabled implements LocationState {
  const ServiceDisabled();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceDisabled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState.serviceDisabled()';
}


}




/// @nodoc


class ShouldAskForPermission implements LocationState {
  const ShouldAskForPermission();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShouldAskForPermission);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState.shouldAskForPermission()';
}


}




/// @nodoc


class PermissionDenied implements LocationState {
  const PermissionDenied();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDenied);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState.shouldDirectToSettings()';
}


}




/// @nodoc


class PermissionGranted implements LocationState {
  const PermissionGranted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionGranted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LocationState.permissionGranted()';
}


}




/// @nodoc


class LocationProvided implements LocationState {
  const LocationProvided({required this.userLocation});
  

 final  UserLocation userLocation;

/// Create a copy of LocationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationProvidedCopyWith<LocationProvided> get copyWith => _$LocationProvidedCopyWithImpl<LocationProvided>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationProvided&&(identical(other.userLocation, userLocation) || other.userLocation == userLocation));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userLocation);
}

@override
String toString() {
    return 'LocationState.locationProvided(userLocation: $userLocation)';
}


}

/// @nodoc
abstract mixin class $LocationProvidedCopyWith<$Res> implements $LocationStateCopyWith<$Res> {
  factory $LocationProvidedCopyWith(LocationProvided value, $Res Function(LocationProvided) _then) = _$LocationProvidedCopyWithImpl;
@useResult
$Res call({
 UserLocation userLocation
});




}
/// @nodoc
class _$LocationProvidedCopyWithImpl<$Res>
    implements $LocationProvidedCopyWith<$Res> {
  _$LocationProvidedCopyWithImpl(this._self, this._then);

  final LocationProvided _self;
  final $Res Function(LocationProvided) _then;

/// Create a copy of LocationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userLocation = null,}) {
  return _then(LocationProvided(
userLocation: null == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation,
  ));
}


}

// dart format on
