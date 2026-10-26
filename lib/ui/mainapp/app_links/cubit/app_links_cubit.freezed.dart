// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_links_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLinksState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinksState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AppLinksState()';
}


}

/// @nodoc
class $AppLinksStateCopyWith<$Res>  {
$AppLinksStateCopyWith(AppLinksState _, $Res Function(AppLinksState) __);
}


/// Adds pattern-matching-related methods to [AppLinksState].
extension AppLinksStatePatterns on AppLinksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AppLinksIdle value)?  idle,TResult Function( AppLinksShowChargingStation value)?  showChargingStation,TResult Function( AppLinksShowCharging value)?  showCharging,TResult Function( AppLinksShowSessions value)?  showSessions,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AppLinksIdle() when idle != null:
return idle(_that);case AppLinksShowChargingStation() when showChargingStation != null:
return showChargingStation(_that);case AppLinksShowCharging() when showCharging != null:
return showCharging(_that);case AppLinksShowSessions() when showSessions != null:
return showSessions(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AppLinksIdle value)  idle,required TResult Function( AppLinksShowChargingStation value)  showChargingStation,required TResult Function( AppLinksShowCharging value)  showCharging,required TResult Function( AppLinksShowSessions value)  showSessions,}){
final _that = this;
switch (_that) {
case AppLinksIdle():
return idle(_that);case AppLinksShowChargingStation():
return showChargingStation(_that);case AppLinksShowCharging():
return showCharging(_that);case AppLinksShowSessions():
return showSessions(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AppLinksIdle value)?  idle,TResult? Function( AppLinksShowChargingStation value)?  showChargingStation,TResult? Function( AppLinksShowCharging value)?  showCharging,TResult? Function( AppLinksShowSessions value)?  showSessions,}){
final _that = this;
switch (_that) {
case AppLinksIdle() when idle != null:
return idle(_that);case AppLinksShowChargingStation() when showChargingStation != null:
return showChargingStation(_that);case AppLinksShowCharging() when showCharging != null:
return showCharging(_that);case AppLinksShowSessions() when showSessions != null:
return showSessions(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String stationId)?  showChargingStation,TResult Function()?  showCharging,TResult Function()?  showSessions,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AppLinksIdle() when idle != null:
return idle();case AppLinksShowChargingStation() when showChargingStation != null:
return showChargingStation(_that.stationId);case AppLinksShowCharging() when showCharging != null:
return showCharging();case AppLinksShowSessions() when showSessions != null:
return showSessions();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String stationId)  showChargingStation,required TResult Function()  showCharging,required TResult Function()  showSessions,}) {final _that = this;
switch (_that) {
case AppLinksIdle():
return idle();case AppLinksShowChargingStation():
return showChargingStation(_that.stationId);case AppLinksShowCharging():
return showCharging();case AppLinksShowSessions():
return showSessions();case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String stationId)?  showChargingStation,TResult? Function()?  showCharging,TResult? Function()?  showSessions,}) {final _that = this;
switch (_that) {
case AppLinksIdle() when idle != null:
return idle();case AppLinksShowChargingStation() when showChargingStation != null:
return showChargingStation(_that.stationId);case AppLinksShowCharging() when showCharging != null:
return showCharging();case AppLinksShowSessions() when showSessions != null:
return showSessions();case _:
  return null;

}
}

}

/// @nodoc


class AppLinksIdle implements AppLinksState {
  const AppLinksIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinksIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AppLinksState.idle()';
}


}




/// @nodoc


class AppLinksShowChargingStation implements AppLinksState {
  const AppLinksShowChargingStation(this.stationId);
  

 final  String stationId;

/// Create a copy of AppLinksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLinksShowChargingStationCopyWith<AppLinksShowChargingStation> get copyWith => _$AppLinksShowChargingStationCopyWithImpl<AppLinksShowChargingStation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinksShowChargingStation&&(identical(other.stationId, stationId) || other.stationId == stationId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stationId);
}

@override
String toString() {
    return 'AppLinksState.showChargingStation(stationId: $stationId)';
}


}

/// @nodoc
abstract mixin class $AppLinksShowChargingStationCopyWith<$Res> implements $AppLinksStateCopyWith<$Res> {
  factory $AppLinksShowChargingStationCopyWith(AppLinksShowChargingStation value, $Res Function(AppLinksShowChargingStation) _then) = _$AppLinksShowChargingStationCopyWithImpl;
@useResult
$Res call({
 String stationId
});




}
/// @nodoc
class _$AppLinksShowChargingStationCopyWithImpl<$Res>
    implements $AppLinksShowChargingStationCopyWith<$Res> {
  _$AppLinksShowChargingStationCopyWithImpl(this._self, this._then);

  final AppLinksShowChargingStation _self;
  final $Res Function(AppLinksShowChargingStation) _then;

/// Create a copy of AppLinksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stationId = null,}) {
  return _then(AppLinksShowChargingStation(
null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AppLinksShowCharging implements AppLinksState {
  const AppLinksShowCharging();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinksShowCharging);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AppLinksState.showCharging()';
}


}




/// @nodoc


class AppLinksShowSessions implements AppLinksState {
  const AppLinksShowSessions();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLinksShowSessions);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AppLinksState.showSessions()';
}


}




// dart format on
