// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favourites_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavouritesState {

 List<String> get stationIds; List<MapLocationV2> get stations; UIFlow get flow;
/// Create a copy of FavouritesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavouritesStateCopyWith<FavouritesState> get copyWith => _$FavouritesStateCopyWithImpl<FavouritesState>(this as FavouritesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FavouritesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavouritesState&&const DeepCollectionEquality().equals(other.stationIds, _this.stationIds)&&const DeepCollectionEquality().equals(other.stations, _this.stations)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as FavouritesState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.stationIds),const DeepCollectionEquality().hash(_this.stations),_this.flow);
}

@override
String toString() {
  final _this = this as FavouritesState;
  return 'FavouritesState(stationIds: ${_this.stationIds}, stations: ${_this.stations}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $FavouritesStateCopyWith<$Res>  {
  factory $FavouritesStateCopyWith(FavouritesState value, $Res Function(FavouritesState) _then) = _$FavouritesStateCopyWithImpl;
@useResult
$Res call({
 List<String> stationIds, List<MapLocationV2> stations, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$FavouritesStateCopyWithImpl<$Res>
    implements $FavouritesStateCopyWith<$Res> {
  _$FavouritesStateCopyWithImpl(this._self, this._then);

  final FavouritesState _self;
  final $Res Function(FavouritesState) _then;

/// Create a copy of FavouritesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stationIds = null,Object? stations = null,Object? flow = null,}) {
  return _then(FavouritesState.favourites(
stationIds: null == stationIds ? _self.stationIds : stationIds // ignore: cast_nullable_to_non_nullable
as List<String>,stations: null == stations ? _self.stations : stations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of FavouritesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavouritesState].
extension FavouritesStatePatterns on FavouritesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Favourites value)?  favourites,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Favourites() when favourites != null:
return favourites(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Favourites value)  favourites,}){
final _that = this;
switch (_that) {
case Favourites():
return favourites(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Favourites value)?  favourites,}){
final _that = this;
switch (_that) {
case Favourites() when favourites != null:
return favourites(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> stationIds,  List<MapLocationV2> stations,  UIFlow flow)?  favourites,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Favourites() when favourites != null:
return favourites(_that.stationIds,_that.stations,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> stationIds,  List<MapLocationV2> stations,  UIFlow flow)  favourites,}) {final _that = this;
switch (_that) {
case Favourites():
return favourites(_that.stationIds,_that.stations,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> stationIds,  List<MapLocationV2> stations,  UIFlow flow)?  favourites,}) {final _that = this;
switch (_that) {
case Favourites() when favourites != null:
return favourites(_that.stationIds,_that.stations,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Favourites implements FavouritesState {
  const Favourites({required  List<String> stationIds, required  List<MapLocationV2> stations, this.flow = const UIFlow.established()}): _stationIds = stationIds,_stations = stations;
  

 final  List<String> _stationIds;
@override List<String> get stationIds {
  if (_stationIds is EqualUnmodifiableListView) return _stationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stationIds);
}

 final  List<MapLocationV2> _stations;
@override List<MapLocationV2> get stations {
  if (_stations is EqualUnmodifiableListView) return _stations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stations);
}

@override@JsonKey() final  UIFlow flow;

/// Create a copy of FavouritesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavouritesCopyWith<Favourites> get copyWith => _$FavouritesCopyWithImpl<Favourites>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Favourites&&const DeepCollectionEquality().equals(other.stationIds, _stationIds)&&const DeepCollectionEquality().equals(other.stations, _stations)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_stationIds),const DeepCollectionEquality().hash(_stations),flow);
}

@override
String toString() {
    return 'FavouritesState.favourites(stationIds: $stationIds, stations: $stations, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $FavouritesCopyWith<$Res> implements $FavouritesStateCopyWith<$Res> {
  factory $FavouritesCopyWith(Favourites value, $Res Function(Favourites) _then) = _$FavouritesCopyWithImpl;
@override @useResult
$Res call({
 List<String> stationIds, List<MapLocationV2> stations, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$FavouritesCopyWithImpl<$Res>
    implements $FavouritesCopyWith<$Res> {
  _$FavouritesCopyWithImpl(this._self, this._then);

  final Favourites _self;
  final $Res Function(Favourites) _then;

/// Create a copy of FavouritesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stationIds = null,Object? stations = null,Object? flow = null,}) {
  return _then(Favourites(
stationIds: null == stationIds ? _self._stationIds : stationIds // ignore: cast_nullable_to_non_nullable
as List<String>,stations: null == stations ? _self._stations : stations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of FavouritesState
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
