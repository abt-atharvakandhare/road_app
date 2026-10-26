// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debug_controls_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DebugControlsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DebugControlsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DebugControlsState()';
}


}

/// @nodoc
class $DebugControlsStateCopyWith<$Res>  {
$DebugControlsStateCopyWith(DebugControlsState _, $Res Function(DebugControlsState) __);
}


/// Adds pattern-matching-related methods to [DebugControlsState].
extension DebugControlsStatePatterns on DebugControlsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DebugControlsDisabled value)?  disabled,TResult Function( DebugControlsEnabled value)?  enabled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DebugControlsDisabled() when disabled != null:
return disabled(_that);case DebugControlsEnabled() when enabled != null:
return enabled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DebugControlsDisabled value)  disabled,required TResult Function( DebugControlsEnabled value)  enabled,}){
final _that = this;
switch (_that) {
case DebugControlsDisabled():
return disabled(_that);case DebugControlsEnabled():
return enabled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DebugControlsDisabled value)?  disabled,TResult? Function( DebugControlsEnabled value)?  enabled,}){
final _that = this;
switch (_that) {
case DebugControlsDisabled() when disabled != null:
return disabled(_that);case DebugControlsEnabled() when enabled != null:
return enabled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  disabled,TResult Function( StageTarget stageTarget,  bool showAllStationsOnAllFlavors,  bool isGpsSimulating,  double gpsSimulationSpeed,  double gpsSimulationBearing,  double? currentSimulatedLat,  double? currentSimulatedLng)?  enabled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DebugControlsDisabled() when disabled != null:
return disabled();case DebugControlsEnabled() when enabled != null:
return enabled(_that.stageTarget,_that.showAllStationsOnAllFlavors,_that.isGpsSimulating,_that.gpsSimulationSpeed,_that.gpsSimulationBearing,_that.currentSimulatedLat,_that.currentSimulatedLng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  disabled,required TResult Function( StageTarget stageTarget,  bool showAllStationsOnAllFlavors,  bool isGpsSimulating,  double gpsSimulationSpeed,  double gpsSimulationBearing,  double? currentSimulatedLat,  double? currentSimulatedLng)  enabled,}) {final _that = this;
switch (_that) {
case DebugControlsDisabled():
return disabled();case DebugControlsEnabled():
return enabled(_that.stageTarget,_that.showAllStationsOnAllFlavors,_that.isGpsSimulating,_that.gpsSimulationSpeed,_that.gpsSimulationBearing,_that.currentSimulatedLat,_that.currentSimulatedLng);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  disabled,TResult? Function( StageTarget stageTarget,  bool showAllStationsOnAllFlavors,  bool isGpsSimulating,  double gpsSimulationSpeed,  double gpsSimulationBearing,  double? currentSimulatedLat,  double? currentSimulatedLng)?  enabled,}) {final _that = this;
switch (_that) {
case DebugControlsDisabled() when disabled != null:
return disabled();case DebugControlsEnabled() when enabled != null:
return enabled(_that.stageTarget,_that.showAllStationsOnAllFlavors,_that.isGpsSimulating,_that.gpsSimulationSpeed,_that.gpsSimulationBearing,_that.currentSimulatedLat,_that.currentSimulatedLng);case _:
  return null;

}
}

}

/// @nodoc


class DebugControlsDisabled implements DebugControlsState {
  const DebugControlsDisabled();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DebugControlsDisabled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DebugControlsState.disabled()';
}


}




/// @nodoc


class DebugControlsEnabled implements DebugControlsState {
  const DebugControlsEnabled(this.stageTarget, this.showAllStationsOnAllFlavors, {this.isGpsSimulating = false, this.gpsSimulationSpeed = 100.0, this.gpsSimulationBearing = 0.0, this.currentSimulatedLat, this.currentSimulatedLng});
  

 final  StageTarget stageTarget;
 final  bool showAllStationsOnAllFlavors;
@JsonKey() final  bool isGpsSimulating;
@JsonKey() final  double gpsSimulationSpeed;
@JsonKey() final  double gpsSimulationBearing;
 final  double? currentSimulatedLat;
 final  double? currentSimulatedLng;

/// Create a copy of DebugControlsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebugControlsEnabledCopyWith<DebugControlsEnabled> get copyWith => _$DebugControlsEnabledCopyWithImpl<DebugControlsEnabled>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DebugControlsEnabled&&(identical(other.stageTarget, stageTarget) || other.stageTarget == stageTarget)&&(identical(other.showAllStationsOnAllFlavors, showAllStationsOnAllFlavors) || other.showAllStationsOnAllFlavors == showAllStationsOnAllFlavors)&&(identical(other.isGpsSimulating, isGpsSimulating) || other.isGpsSimulating == isGpsSimulating)&&(identical(other.gpsSimulationSpeed, gpsSimulationSpeed) || other.gpsSimulationSpeed == gpsSimulationSpeed)&&(identical(other.gpsSimulationBearing, gpsSimulationBearing) || other.gpsSimulationBearing == gpsSimulationBearing)&&(identical(other.currentSimulatedLat, currentSimulatedLat) || other.currentSimulatedLat == currentSimulatedLat)&&(identical(other.currentSimulatedLng, currentSimulatedLng) || other.currentSimulatedLng == currentSimulatedLng));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stageTarget,showAllStationsOnAllFlavors,isGpsSimulating,gpsSimulationSpeed,gpsSimulationBearing,currentSimulatedLat,currentSimulatedLng);
}

@override
String toString() {
    return 'DebugControlsState.enabled(stageTarget: $stageTarget, showAllStationsOnAllFlavors: $showAllStationsOnAllFlavors, isGpsSimulating: $isGpsSimulating, gpsSimulationSpeed: $gpsSimulationSpeed, gpsSimulationBearing: $gpsSimulationBearing, currentSimulatedLat: $currentSimulatedLat, currentSimulatedLng: $currentSimulatedLng)';
}


}

/// @nodoc
abstract mixin class $DebugControlsEnabledCopyWith<$Res> implements $DebugControlsStateCopyWith<$Res> {
  factory $DebugControlsEnabledCopyWith(DebugControlsEnabled value, $Res Function(DebugControlsEnabled) _then) = _$DebugControlsEnabledCopyWithImpl;
@useResult
$Res call({
 StageTarget stageTarget, bool showAllStationsOnAllFlavors, bool isGpsSimulating, double gpsSimulationSpeed, double gpsSimulationBearing, double? currentSimulatedLat, double? currentSimulatedLng
});




}
/// @nodoc
class _$DebugControlsEnabledCopyWithImpl<$Res>
    implements $DebugControlsEnabledCopyWith<$Res> {
  _$DebugControlsEnabledCopyWithImpl(this._self, this._then);

  final DebugControlsEnabled _self;
  final $Res Function(DebugControlsEnabled) _then;

/// Create a copy of DebugControlsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stageTarget = null,Object? showAllStationsOnAllFlavors = null,Object? isGpsSimulating = null,Object? gpsSimulationSpeed = null,Object? gpsSimulationBearing = null,Object? currentSimulatedLat = freezed,Object? currentSimulatedLng = freezed,}) {
  return _then(DebugControlsEnabled(
null == stageTarget ? _self.stageTarget : stageTarget // ignore: cast_nullable_to_non_nullable
as StageTarget,null == showAllStationsOnAllFlavors ? _self.showAllStationsOnAllFlavors : showAllStationsOnAllFlavors // ignore: cast_nullable_to_non_nullable
as bool,isGpsSimulating: null == isGpsSimulating ? _self.isGpsSimulating : isGpsSimulating // ignore: cast_nullable_to_non_nullable
as bool,gpsSimulationSpeed: null == gpsSimulationSpeed ? _self.gpsSimulationSpeed : gpsSimulationSpeed // ignore: cast_nullable_to_non_nullable
as double,gpsSimulationBearing: null == gpsSimulationBearing ? _self.gpsSimulationBearing : gpsSimulationBearing // ignore: cast_nullable_to_non_nullable
as double,currentSimulatedLat: freezed == currentSimulatedLat ? _self.currentSimulatedLat : currentSimulatedLat // ignore: cast_nullable_to_non_nullable
as double?,currentSimulatedLng: freezed == currentSimulatedLng ? _self.currentSimulatedLng : currentSimulatedLng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
