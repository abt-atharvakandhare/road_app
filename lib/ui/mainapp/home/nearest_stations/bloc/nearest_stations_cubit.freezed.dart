// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nearest_stations_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NearestStationsState {

 List<MapLocationV2> get stations; UserLocation? get userLocation; String? get currentRoadName; bool get isLowSpeed; NearestStationsMode get mode; UIFlow get flow;/// Whether highway mode filtering is currently active (for carScreen mode)
/// This is true when speed >= 50 km/h and isHighwayAutoEnabled is true
 bool get isHighwayModeActive;
/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearestStationsStateCopyWith<NearestStationsState> get copyWith => _$NearestStationsStateCopyWithImpl<NearestStationsState>(this as NearestStationsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NearestStationsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NearestStationsState&&const DeepCollectionEquality().equals(other.stations, _this.stations)&&(identical(other.userLocation, _this.userLocation) || other.userLocation == _this.userLocation)&&(identical(other.currentRoadName, _this.currentRoadName) || other.currentRoadName == _this.currentRoadName)&&(identical(other.isLowSpeed, _this.isLowSpeed) || other.isLowSpeed == _this.isLowSpeed)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.flow, _this.flow) || other.flow == _this.flow)&&(identical(other.isHighwayModeActive, _this.isHighwayModeActive) || other.isHighwayModeActive == _this.isHighwayModeActive));
}


@override
int get hashCode {
  final _this = this as NearestStationsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.stations),_this.userLocation,_this.currentRoadName,_this.isLowSpeed,_this.mode,_this.flow,_this.isHighwayModeActive);
}

@override
String toString() {
  final _this = this as NearestStationsState;
  return 'NearestStationsState(stations: ${_this.stations}, userLocation: ${_this.userLocation}, currentRoadName: ${_this.currentRoadName}, isLowSpeed: ${_this.isLowSpeed}, mode: ${_this.mode}, flow: ${_this.flow}, isHighwayModeActive: ${_this.isHighwayModeActive})';
}


}

/// @nodoc
abstract mixin class $NearestStationsStateCopyWith<$Res>  {
  factory $NearestStationsStateCopyWith(NearestStationsState value, $Res Function(NearestStationsState) _then) = _$NearestStationsStateCopyWithImpl;
@useResult
$Res call({
 List<MapLocationV2> stations, UserLocation? userLocation, String? currentRoadName, bool isLowSpeed, NearestStationsMode mode, UIFlow flow, bool isHighwayModeActive
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$NearestStationsStateCopyWithImpl<$Res>
    implements $NearestStationsStateCopyWith<$Res> {
  _$NearestStationsStateCopyWithImpl(this._self, this._then);

  final NearestStationsState _self;
  final $Res Function(NearestStationsState) _then;

/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stations = null,Object? userLocation = freezed,Object? currentRoadName = freezed,Object? isLowSpeed = null,Object? mode = null,Object? flow = null,Object? isHighwayModeActive = null,}) {
  return _then(NearestStationsState(
stations: null == stations ? _self.stations : stations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,userLocation: freezed == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation?,currentRoadName: freezed == currentRoadName ? _self.currentRoadName : currentRoadName // ignore: cast_nullable_to_non_nullable
as String?,isLowSpeed: null == isLowSpeed ? _self.isLowSpeed : isLowSpeed // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NearestStationsMode,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,isHighwayModeActive: null == isHighwayModeActive ? _self.isHighwayModeActive : isHighwayModeActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [NearestStationsState].
extension NearestStationsStatePatterns on NearestStationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NearestStationsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NearestStationsState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NearestStationsState value)  $default,){
final _that = this;
switch (_that) {
case _NearestStationsState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NearestStationsState value)?  $default,){
final _that = this;
switch (_that) {
case _NearestStationsState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MapLocationV2> stations,  UserLocation? userLocation,  String? currentRoadName,  bool isLowSpeed,  NearestStationsMode mode,  UIFlow flow,  bool isHighwayModeActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NearestStationsState() when $default != null:
return $default(_that.stations,_that.userLocation,_that.currentRoadName,_that.isLowSpeed,_that.mode,_that.flow,_that.isHighwayModeActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MapLocationV2> stations,  UserLocation? userLocation,  String? currentRoadName,  bool isLowSpeed,  NearestStationsMode mode,  UIFlow flow,  bool isHighwayModeActive)  $default,) {final _that = this;
switch (_that) {
case _NearestStationsState():
return $default(_that.stations,_that.userLocation,_that.currentRoadName,_that.isLowSpeed,_that.mode,_that.flow,_that.isHighwayModeActive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MapLocationV2> stations,  UserLocation? userLocation,  String? currentRoadName,  bool isLowSpeed,  NearestStationsMode mode,  UIFlow flow,  bool isHighwayModeActive)?  $default,) {final _that = this;
switch (_that) {
case _NearestStationsState() when $default != null:
return $default(_that.stations,_that.userLocation,_that.currentRoadName,_that.isLowSpeed,_that.mode,_that.flow,_that.isHighwayModeActive);case _:
  return null;

}
}

}

/// @nodoc


class _NearestStationsState implements NearestStationsState {
  const _NearestStationsState({required  List<MapLocationV2> stations, this.userLocation, this.currentRoadName, this.isLowSpeed = false, this.mode = NearestStationsMode.highway, this.flow = const UIFlow.established(), this.isHighwayModeActive = false}): _stations = stations;
  

 final  List<MapLocationV2> _stations;
@override List<MapLocationV2> get stations {
  if (_stations is EqualUnmodifiableListView) return _stations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stations);
}

@override final  UserLocation? userLocation;
@override final  String? currentRoadName;
@override@JsonKey() final  bool isLowSpeed;
@override@JsonKey() final  NearestStationsMode mode;
@override@JsonKey() final  UIFlow flow;
/// Whether highway mode filtering is currently active (for carScreen mode)
/// This is true when speed >= 50 km/h and isHighwayAutoEnabled is true
@override@JsonKey() final  bool isHighwayModeActive;

/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NearestStationsStateCopyWith<_NearestStationsState> get copyWith => __$NearestStationsStateCopyWithImpl<_NearestStationsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NearestStationsState&&const DeepCollectionEquality().equals(other.stations, _stations)&&(identical(other.userLocation, userLocation) || other.userLocation == userLocation)&&(identical(other.currentRoadName, currentRoadName) || other.currentRoadName == currentRoadName)&&(identical(other.isLowSpeed, isLowSpeed) || other.isLowSpeed == isLowSpeed)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.isHighwayModeActive, isHighwayModeActive) || other.isHighwayModeActive == isHighwayModeActive));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_stations),userLocation,currentRoadName,isLowSpeed,mode,flow,isHighwayModeActive);
}

@override
String toString() {
    return 'NearestStationsState(stations: $stations, userLocation: $userLocation, currentRoadName: $currentRoadName, isLowSpeed: $isLowSpeed, mode: $mode, flow: $flow, isHighwayModeActive: $isHighwayModeActive)';
}


}

/// @nodoc
abstract mixin class _$NearestStationsStateCopyWith<$Res> implements $NearestStationsStateCopyWith<$Res> {
  factory _$NearestStationsStateCopyWith(_NearestStationsState value, $Res Function(_NearestStationsState) _then) = __$NearestStationsStateCopyWithImpl;
@override @useResult
$Res call({
 List<MapLocationV2> stations, UserLocation? userLocation, String? currentRoadName, bool isLowSpeed, NearestStationsMode mode, UIFlow flow, bool isHighwayModeActive
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class __$NearestStationsStateCopyWithImpl<$Res>
    implements _$NearestStationsStateCopyWith<$Res> {
  __$NearestStationsStateCopyWithImpl(this._self, this._then);

  final _NearestStationsState _self;
  final $Res Function(_NearestStationsState) _then;

/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stations = null,Object? userLocation = freezed,Object? currentRoadName = freezed,Object? isLowSpeed = null,Object? mode = null,Object? flow = null,Object? isHighwayModeActive = null,}) {
  return _then(_NearestStationsState(
stations: null == stations ? _self._stations : stations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,userLocation: freezed == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation?,currentRoadName: freezed == currentRoadName ? _self.currentRoadName : currentRoadName // ignore: cast_nullable_to_non_nullable
as String?,isLowSpeed: null == isLowSpeed ? _self.isLowSpeed : isLowSpeed // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NearestStationsMode,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,isHighwayModeActive: null == isHighwayModeActive ? _self.isHighwayModeActive : isHighwayModeActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of NearestStationsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}

// dart format on
