// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapSelection {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapSelection()';
}


}

/// @nodoc
class $MapSelectionCopyWith<$Res>  {
$MapSelectionCopyWith(MapSelection _, $Res Function(MapSelection) __);
}


/// Adds pattern-matching-related methods to [MapSelection].
extension MapSelectionPatterns on MapSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MapSelectionNone value)?  none,TResult Function( MapSelectionById value)?  byId,TResult Function( MapSelectionByLocation value)?  byLocation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MapSelectionNone() when none != null:
return none(_that);case MapSelectionById() when byId != null:
return byId(_that);case MapSelectionByLocation() when byLocation != null:
return byLocation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MapSelectionNone value)  none,required TResult Function( MapSelectionById value)  byId,required TResult Function( MapSelectionByLocation value)  byLocation,}){
final _that = this;
switch (_that) {
case MapSelectionNone():
return none(_that);case MapSelectionById():
return byId(_that);case MapSelectionByLocation():
return byLocation(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MapSelectionNone value)?  none,TResult? Function( MapSelectionById value)?  byId,TResult? Function( MapSelectionByLocation value)?  byLocation,}){
final _that = this;
switch (_that) {
case MapSelectionNone() when none != null:
return none(_that);case MapSelectionById() when byId != null:
return byId(_that);case MapSelectionByLocation() when byLocation != null:
return byLocation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( String locationId)?  byId,TResult Function( LatLng location)?  byLocation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MapSelectionNone() when none != null:
return none();case MapSelectionById() when byId != null:
return byId(_that.locationId);case MapSelectionByLocation() when byLocation != null:
return byLocation(_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( String locationId)  byId,required TResult Function( LatLng location)  byLocation,}) {final _that = this;
switch (_that) {
case MapSelectionNone():
return none();case MapSelectionById():
return byId(_that.locationId);case MapSelectionByLocation():
return byLocation(_that.location);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( String locationId)?  byId,TResult? Function( LatLng location)?  byLocation,}) {final _that = this;
switch (_that) {
case MapSelectionNone() when none != null:
return none();case MapSelectionById() when byId != null:
return byId(_that.locationId);case MapSelectionByLocation() when byLocation != null:
return byLocation(_that.location);case _:
  return null;

}
}

}

/// @nodoc


class MapSelectionNone implements MapSelection {
  const MapSelectionNone();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSelectionNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapSelection.none()';
}


}




/// @nodoc


class MapSelectionById implements MapSelection {
  const MapSelectionById(this.locationId);
  

 final  String locationId;

/// Create a copy of MapSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapSelectionByIdCopyWith<MapSelectionById> get copyWith => _$MapSelectionByIdCopyWithImpl<MapSelectionById>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSelectionById&&(identical(other.locationId, locationId) || other.locationId == locationId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locationId);
}

@override
String toString() {
    return 'MapSelection.byId(locationId: $locationId)';
}


}

/// @nodoc
abstract mixin class $MapSelectionByIdCopyWith<$Res> implements $MapSelectionCopyWith<$Res> {
  factory $MapSelectionByIdCopyWith(MapSelectionById value, $Res Function(MapSelectionById) _then) = _$MapSelectionByIdCopyWithImpl;
@useResult
$Res call({
 String locationId
});




}
/// @nodoc
class _$MapSelectionByIdCopyWithImpl<$Res>
    implements $MapSelectionByIdCopyWith<$Res> {
  _$MapSelectionByIdCopyWithImpl(this._self, this._then);

  final MapSelectionById _self;
  final $Res Function(MapSelectionById) _then;

/// Create a copy of MapSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locationId = null,}) {
  return _then(MapSelectionById(
null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MapSelectionByLocation implements MapSelection {
  const MapSelectionByLocation(this.location);
  

 final  LatLng location;

/// Create a copy of MapSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapSelectionByLocationCopyWith<MapSelectionByLocation> get copyWith => _$MapSelectionByLocationCopyWithImpl<MapSelectionByLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSelectionByLocation&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location);
}

@override
String toString() {
    return 'MapSelection.byLocation(location: $location)';
}


}

/// @nodoc
abstract mixin class $MapSelectionByLocationCopyWith<$Res> implements $MapSelectionCopyWith<$Res> {
  factory $MapSelectionByLocationCopyWith(MapSelectionByLocation value, $Res Function(MapSelectionByLocation) _then) = _$MapSelectionByLocationCopyWithImpl;
@useResult
$Res call({
 LatLng location
});




}
/// @nodoc
class _$MapSelectionByLocationCopyWithImpl<$Res>
    implements $MapSelectionByLocationCopyWith<$Res> {
  _$MapSelectionByLocationCopyWithImpl(this._self, this._then);

  final MapSelectionByLocation _self;
  final $Res Function(MapSelectionByLocation) _then;

/// Create a copy of MapSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(MapSelectionByLocation(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,
  ));
}


}

// dart format on
