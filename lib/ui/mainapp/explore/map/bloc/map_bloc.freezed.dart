// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapState {

 List<MapLocationItem> get mapItems; LatLng? get moveToLocation; LatLng? get searchResultPinLocation; MapSelection get selection; UIFlow get flow;
/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapStateCopyWith<MapState> get copyWith => _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState&&const DeepCollectionEquality().equals(other.mapItems, _this.mapItems)&&(identical(other.moveToLocation, _this.moveToLocation) || other.moveToLocation == _this.moveToLocation)&&(identical(other.searchResultPinLocation, _this.searchResultPinLocation) || other.searchResultPinLocation == _this.searchResultPinLocation)&&(identical(other.selection, _this.selection) || other.selection == _this.selection)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as MapState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.mapItems),_this.moveToLocation,_this.searchResultPinLocation,_this.selection,_this.flow);
}

@override
String toString() {
  final _this = this as MapState;
  return 'MapState(mapItems: ${_this.mapItems}, moveToLocation: ${_this.moveToLocation}, searchResultPinLocation: ${_this.searchResultPinLocation}, selection: ${_this.selection}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res>  {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) = _$MapStateCopyWithImpl;
@useResult
$Res call({
 List<MapLocationItem> mapItems, LatLng? moveToLocation, LatLng? searchResultPinLocation, MapSelection selection, UIFlow flow
});


$MapSelectionCopyWith<$Res> get selection;$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MapStateCopyWithImpl<$Res>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._self, this._then);

  final MapState _self;
  final $Res Function(MapState) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mapItems = null,Object? moveToLocation = freezed,Object? searchResultPinLocation = freezed,Object? selection = null,Object? flow = null,}) {
  return _then(MapState.chargingStations(
mapItems: null == mapItems ? _self.mapItems : mapItems // ignore: cast_nullable_to_non_nullable
as List<MapLocationItem>,moveToLocation: freezed == moveToLocation ? _self.moveToLocation : moveToLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,searchResultPinLocation: freezed == searchResultPinLocation ? _self.searchResultPinLocation : searchResultPinLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as MapSelection,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapSelectionCopyWith<$Res> get selection {
  
  return $MapSelectionCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapState].
extension MapStatePatterns on MapState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChargingStations value)?  chargingStations,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChargingStations() when chargingStations != null:
return chargingStations(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChargingStations value)  chargingStations,}){
final _that = this;
switch (_that) {
case ChargingStations():
return chargingStations(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChargingStations value)?  chargingStations,}){
final _that = this;
switch (_that) {
case ChargingStations() when chargingStations != null:
return chargingStations(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<MapLocationItem> mapItems,  LatLng? moveToLocation,  LatLng? searchResultPinLocation,  MapSelection selection,  UIFlow flow)?  chargingStations,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChargingStations() when chargingStations != null:
return chargingStations(_that.mapItems,_that.moveToLocation,_that.searchResultPinLocation,_that.selection,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<MapLocationItem> mapItems,  LatLng? moveToLocation,  LatLng? searchResultPinLocation,  MapSelection selection,  UIFlow flow)  chargingStations,}) {final _that = this;
switch (_that) {
case ChargingStations():
return chargingStations(_that.mapItems,_that.moveToLocation,_that.searchResultPinLocation,_that.selection,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<MapLocationItem> mapItems,  LatLng? moveToLocation,  LatLng? searchResultPinLocation,  MapSelection selection,  UIFlow flow)?  chargingStations,}) {final _that = this;
switch (_that) {
case ChargingStations() when chargingStations != null:
return chargingStations(_that.mapItems,_that.moveToLocation,_that.searchResultPinLocation,_that.selection,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class ChargingStations implements MapState {
  const ChargingStations({required  List<MapLocationItem> mapItems, this.moveToLocation, this.searchResultPinLocation, this.selection = const MapSelection.none(), this.flow = const UIFlow.established()}): _mapItems = mapItems;
  

 final  List<MapLocationItem> _mapItems;
@override List<MapLocationItem> get mapItems {
  if (_mapItems is EqualUnmodifiableListView) return _mapItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapItems);
}

@override final  LatLng? moveToLocation;
@override final  LatLng? searchResultPinLocation;
@override@JsonKey() final  MapSelection selection;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargingStationsCopyWith<ChargingStations> get copyWith => _$ChargingStationsCopyWithImpl<ChargingStations>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargingStations&&const DeepCollectionEquality().equals(other.mapItems, _mapItems)&&(identical(other.moveToLocation, moveToLocation) || other.moveToLocation == moveToLocation)&&(identical(other.searchResultPinLocation, searchResultPinLocation) || other.searchResultPinLocation == searchResultPinLocation)&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_mapItems),moveToLocation,searchResultPinLocation,selection,flow);
}

@override
String toString() {
    return 'MapState.chargingStations(mapItems: $mapItems, moveToLocation: $moveToLocation, searchResultPinLocation: $searchResultPinLocation, selection: $selection, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ChargingStationsCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory $ChargingStationsCopyWith(ChargingStations value, $Res Function(ChargingStations) _then) = _$ChargingStationsCopyWithImpl;
@override @useResult
$Res call({
 List<MapLocationItem> mapItems, LatLng? moveToLocation, LatLng? searchResultPinLocation, MapSelection selection, UIFlow flow
});


@override $MapSelectionCopyWith<$Res> get selection;@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ChargingStationsCopyWithImpl<$Res>
    implements $ChargingStationsCopyWith<$Res> {
  _$ChargingStationsCopyWithImpl(this._self, this._then);

  final ChargingStations _self;
  final $Res Function(ChargingStations) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mapItems = null,Object? moveToLocation = freezed,Object? searchResultPinLocation = freezed,Object? selection = null,Object? flow = null,}) {
  return _then(ChargingStations(
mapItems: null == mapItems ? _self._mapItems : mapItems // ignore: cast_nullable_to_non_nullable
as List<MapLocationItem>,moveToLocation: freezed == moveToLocation ? _self.moveToLocation : moveToLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,searchResultPinLocation: freezed == searchResultPinLocation ? _self.searchResultPinLocation : searchResultPinLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as MapSelection,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapSelectionCopyWith<$Res> get selection {
  
  return $MapSelectionCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}

/// @nodoc
mixin _$MapLocationPinSelection {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLocationPinSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapLocationPinSelection()';
}


}

/// @nodoc
class $MapLocationPinSelectionCopyWith<$Res>  {
$MapLocationPinSelectionCopyWith(MapLocationPinSelection _, $Res Function(MapLocationPinSelection) __);
}


/// Adds pattern-matching-related methods to [MapLocationPinSelection].
extension MapLocationPinSelectionPatterns on MapLocationPinSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _None value)?  none,TResult Function( _EvseLocationIfPresent value)?  evseLocationIfPresent,TResult Function( _LocationId value)?  locationId,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _None() when none != null:
return none(_that);case _EvseLocationIfPresent() when evseLocationIfPresent != null:
return evseLocationIfPresent(_that);case _LocationId() when locationId != null:
return locationId(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _None value)  none,required TResult Function( _EvseLocationIfPresent value)  evseLocationIfPresent,required TResult Function( _LocationId value)  locationId,}){
final _that = this;
switch (_that) {
case _None():
return none(_that);case _EvseLocationIfPresent():
return evseLocationIfPresent(_that);case _LocationId():
return locationId(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _None value)?  none,TResult? Function( _EvseLocationIfPresent value)?  evseLocationIfPresent,TResult? Function( _LocationId value)?  locationId,}){
final _that = this;
switch (_that) {
case _None() when none != null:
return none(_that);case _EvseLocationIfPresent() when evseLocationIfPresent != null:
return evseLocationIfPresent(_that);case _LocationId() when locationId != null:
return locationId(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function()?  evseLocationIfPresent,TResult Function( String id)?  locationId,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _None() when none != null:
return none();case _EvseLocationIfPresent() when evseLocationIfPresent != null:
return evseLocationIfPresent();case _LocationId() when locationId != null:
return locationId(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function()  evseLocationIfPresent,required TResult Function( String id)  locationId,}) {final _that = this;
switch (_that) {
case _None():
return none();case _EvseLocationIfPresent():
return evseLocationIfPresent();case _LocationId():
return locationId(_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function()?  evseLocationIfPresent,TResult? Function( String id)?  locationId,}) {final _that = this;
switch (_that) {
case _None() when none != null:
return none();case _EvseLocationIfPresent() when evseLocationIfPresent != null:
return evseLocationIfPresent();case _LocationId() when locationId != null:
return locationId(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _None implements MapLocationPinSelection {
  const _None();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _None);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapLocationPinSelection.none()';
}


}




/// @nodoc


class _EvseLocationIfPresent implements MapLocationPinSelection {
  const _EvseLocationIfPresent();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvseLocationIfPresent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapLocationPinSelection.evseLocationIfPresent()';
}


}




/// @nodoc


class _LocationId implements MapLocationPinSelection {
  const _LocationId(this.id);
  

 final  String id;

/// Create a copy of MapLocationPinSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationIdCopyWith<_LocationId> get copyWith => __$LocationIdCopyWithImpl<_LocationId>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationId&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'MapLocationPinSelection.locationId(id: $id)';
}


}

/// @nodoc
abstract mixin class _$LocationIdCopyWith<$Res> implements $MapLocationPinSelectionCopyWith<$Res> {
  factory _$LocationIdCopyWith(_LocationId value, $Res Function(_LocationId) _then) = __$LocationIdCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class __$LocationIdCopyWithImpl<$Res>
    implements _$LocationIdCopyWith<$Res> {
  __$LocationIdCopyWithImpl(this._self, this._then);

  final _LocationId _self;
  final $Res Function(_LocationId) _then;

/// Create a copy of MapLocationPinSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_LocationId(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MapEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapEvent()';
}


}

/// @nodoc
class $MapEventCopyWith<$Res>  {
$MapEventCopyWith(MapEvent _, $Res Function(MapEvent) __);
}


/// Adds pattern-matching-related methods to [MapEvent].
extension MapEventPatterns on MapEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RemovePinSelection value)?  removePinSelection,TResult Function( UserTappedLocation value)?  userTappedLocation,TResult Function( SelectLocationWithId value)?  selectLocationWithId,TResult Function( RegionUpdated value)?  regionUpdated,TResult Function( MapFiltersChanged value)?  mapFiltersChanged,TResult Function( MapFiltersApplied value)?  mapFiltersApplied,TResult Function( MoveMapToLocation value)?  moveMapToLocation,TResult Function( GeoCodingResultSelected value)?  geoCodingResultSelected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RemovePinSelection() when removePinSelection != null:
return removePinSelection(_that);case UserTappedLocation() when userTappedLocation != null:
return userTappedLocation(_that);case SelectLocationWithId() when selectLocationWithId != null:
return selectLocationWithId(_that);case RegionUpdated() when regionUpdated != null:
return regionUpdated(_that);case MapFiltersChanged() when mapFiltersChanged != null:
return mapFiltersChanged(_that);case MapFiltersApplied() when mapFiltersApplied != null:
return mapFiltersApplied(_that);case MoveMapToLocation() when moveMapToLocation != null:
return moveMapToLocation(_that);case GeoCodingResultSelected() when geoCodingResultSelected != null:
return geoCodingResultSelected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RemovePinSelection value)  removePinSelection,required TResult Function( UserTappedLocation value)  userTappedLocation,required TResult Function( SelectLocationWithId value)  selectLocationWithId,required TResult Function( RegionUpdated value)  regionUpdated,required TResult Function( MapFiltersChanged value)  mapFiltersChanged,required TResult Function( MapFiltersApplied value)  mapFiltersApplied,required TResult Function( MoveMapToLocation value)  moveMapToLocation,required TResult Function( GeoCodingResultSelected value)  geoCodingResultSelected,}){
final _that = this;
switch (_that) {
case RemovePinSelection():
return removePinSelection(_that);case UserTappedLocation():
return userTappedLocation(_that);case SelectLocationWithId():
return selectLocationWithId(_that);case RegionUpdated():
return regionUpdated(_that);case MapFiltersChanged():
return mapFiltersChanged(_that);case MapFiltersApplied():
return mapFiltersApplied(_that);case MoveMapToLocation():
return moveMapToLocation(_that);case GeoCodingResultSelected():
return geoCodingResultSelected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RemovePinSelection value)?  removePinSelection,TResult? Function( UserTappedLocation value)?  userTappedLocation,TResult? Function( SelectLocationWithId value)?  selectLocationWithId,TResult? Function( RegionUpdated value)?  regionUpdated,TResult? Function( MapFiltersChanged value)?  mapFiltersChanged,TResult? Function( MapFiltersApplied value)?  mapFiltersApplied,TResult? Function( MoveMapToLocation value)?  moveMapToLocation,TResult? Function( GeoCodingResultSelected value)?  geoCodingResultSelected,}){
final _that = this;
switch (_that) {
case RemovePinSelection() when removePinSelection != null:
return removePinSelection(_that);case UserTappedLocation() when userTappedLocation != null:
return userTappedLocation(_that);case SelectLocationWithId() when selectLocationWithId != null:
return selectLocationWithId(_that);case RegionUpdated() when regionUpdated != null:
return regionUpdated(_that);case MapFiltersChanged() when mapFiltersChanged != null:
return mapFiltersChanged(_that);case MapFiltersApplied() when mapFiltersApplied != null:
return mapFiltersApplied(_that);case MoveMapToLocation() when moveMapToLocation != null:
return moveMapToLocation(_that);case GeoCodingResultSelected() when geoCodingResultSelected != null:
return geoCodingResultSelected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool backToGeocodingSelection)?  removePinSelection,TResult Function( LatLng location)?  userTappedLocation,TResult Function( String locationId)?  selectLocationWithId,TResult Function( LatLngBounds mapBounds,  double zoomLevel)?  regionUpdated,TResult Function( ChargingLocationFilters newFilters)?  mapFiltersChanged,TResult Function( ChargingLocationFilters newFilters)?  mapFiltersApplied,TResult Function( double latitude,  double longitude,  MapLocationPinSelection pinSelection)?  moveMapToLocation,TResult Function( GeoLocationResult selectedResult)?  geoCodingResultSelected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RemovePinSelection() when removePinSelection != null:
return removePinSelection(_that.backToGeocodingSelection);case UserTappedLocation() when userTappedLocation != null:
return userTappedLocation(_that.location);case SelectLocationWithId() when selectLocationWithId != null:
return selectLocationWithId(_that.locationId);case RegionUpdated() when regionUpdated != null:
return regionUpdated(_that.mapBounds,_that.zoomLevel);case MapFiltersChanged() when mapFiltersChanged != null:
return mapFiltersChanged(_that.newFilters);case MapFiltersApplied() when mapFiltersApplied != null:
return mapFiltersApplied(_that.newFilters);case MoveMapToLocation() when moveMapToLocation != null:
return moveMapToLocation(_that.latitude,_that.longitude,_that.pinSelection);case GeoCodingResultSelected() when geoCodingResultSelected != null:
return geoCodingResultSelected(_that.selectedResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool backToGeocodingSelection)  removePinSelection,required TResult Function( LatLng location)  userTappedLocation,required TResult Function( String locationId)  selectLocationWithId,required TResult Function( LatLngBounds mapBounds,  double zoomLevel)  regionUpdated,required TResult Function( ChargingLocationFilters newFilters)  mapFiltersChanged,required TResult Function( ChargingLocationFilters newFilters)  mapFiltersApplied,required TResult Function( double latitude,  double longitude,  MapLocationPinSelection pinSelection)  moveMapToLocation,required TResult Function( GeoLocationResult selectedResult)  geoCodingResultSelected,}) {final _that = this;
switch (_that) {
case RemovePinSelection():
return removePinSelection(_that.backToGeocodingSelection);case UserTappedLocation():
return userTappedLocation(_that.location);case SelectLocationWithId():
return selectLocationWithId(_that.locationId);case RegionUpdated():
return regionUpdated(_that.mapBounds,_that.zoomLevel);case MapFiltersChanged():
return mapFiltersChanged(_that.newFilters);case MapFiltersApplied():
return mapFiltersApplied(_that.newFilters);case MoveMapToLocation():
return moveMapToLocation(_that.latitude,_that.longitude,_that.pinSelection);case GeoCodingResultSelected():
return geoCodingResultSelected(_that.selectedResult);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool backToGeocodingSelection)?  removePinSelection,TResult? Function( LatLng location)?  userTappedLocation,TResult? Function( String locationId)?  selectLocationWithId,TResult? Function( LatLngBounds mapBounds,  double zoomLevel)?  regionUpdated,TResult? Function( ChargingLocationFilters newFilters)?  mapFiltersChanged,TResult? Function( ChargingLocationFilters newFilters)?  mapFiltersApplied,TResult? Function( double latitude,  double longitude,  MapLocationPinSelection pinSelection)?  moveMapToLocation,TResult? Function( GeoLocationResult selectedResult)?  geoCodingResultSelected,}) {final _that = this;
switch (_that) {
case RemovePinSelection() when removePinSelection != null:
return removePinSelection(_that.backToGeocodingSelection);case UserTappedLocation() when userTappedLocation != null:
return userTappedLocation(_that.location);case SelectLocationWithId() when selectLocationWithId != null:
return selectLocationWithId(_that.locationId);case RegionUpdated() when regionUpdated != null:
return regionUpdated(_that.mapBounds,_that.zoomLevel);case MapFiltersChanged() when mapFiltersChanged != null:
return mapFiltersChanged(_that.newFilters);case MapFiltersApplied() when mapFiltersApplied != null:
return mapFiltersApplied(_that.newFilters);case MoveMapToLocation() when moveMapToLocation != null:
return moveMapToLocation(_that.latitude,_that.longitude,_that.pinSelection);case GeoCodingResultSelected() when geoCodingResultSelected != null:
return geoCodingResultSelected(_that.selectedResult);case _:
  return null;

}
}

}

/// @nodoc


class RemovePinSelection implements MapEvent {
  const RemovePinSelection(this.backToGeocodingSelection);
  

 final  bool backToGeocodingSelection;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemovePinSelectionCopyWith<RemovePinSelection> get copyWith => _$RemovePinSelectionCopyWithImpl<RemovePinSelection>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemovePinSelection&&(identical(other.backToGeocodingSelection, backToGeocodingSelection) || other.backToGeocodingSelection == backToGeocodingSelection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,backToGeocodingSelection);
}

@override
String toString() {
    return 'MapEvent.removePinSelection(backToGeocodingSelection: $backToGeocodingSelection)';
}


}

/// @nodoc
abstract mixin class $RemovePinSelectionCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $RemovePinSelectionCopyWith(RemovePinSelection value, $Res Function(RemovePinSelection) _then) = _$RemovePinSelectionCopyWithImpl;
@useResult
$Res call({
 bool backToGeocodingSelection
});




}
/// @nodoc
class _$RemovePinSelectionCopyWithImpl<$Res>
    implements $RemovePinSelectionCopyWith<$Res> {
  _$RemovePinSelectionCopyWithImpl(this._self, this._then);

  final RemovePinSelection _self;
  final $Res Function(RemovePinSelection) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? backToGeocodingSelection = null,}) {
  return _then(RemovePinSelection(
null == backToGeocodingSelection ? _self.backToGeocodingSelection : backToGeocodingSelection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class UserTappedLocation implements MapEvent {
  const UserTappedLocation(this.location);
  

 final  LatLng location;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserTappedLocationCopyWith<UserTappedLocation> get copyWith => _$UserTappedLocationCopyWithImpl<UserTappedLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UserTappedLocation&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location);
}

@override
String toString() {
    return 'MapEvent.userTappedLocation(location: $location)';
}


}

/// @nodoc
abstract mixin class $UserTappedLocationCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $UserTappedLocationCopyWith(UserTappedLocation value, $Res Function(UserTappedLocation) _then) = _$UserTappedLocationCopyWithImpl;
@useResult
$Res call({
 LatLng location
});




}
/// @nodoc
class _$UserTappedLocationCopyWithImpl<$Res>
    implements $UserTappedLocationCopyWith<$Res> {
  _$UserTappedLocationCopyWithImpl(this._self, this._then);

  final UserTappedLocation _self;
  final $Res Function(UserTappedLocation) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(UserTappedLocation(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,
  ));
}


}

/// @nodoc


class SelectLocationWithId implements MapEvent {
  const SelectLocationWithId(this.locationId);
  

 final  String locationId;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectLocationWithIdCopyWith<SelectLocationWithId> get copyWith => _$SelectLocationWithIdCopyWithImpl<SelectLocationWithId>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectLocationWithId&&(identical(other.locationId, locationId) || other.locationId == locationId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locationId);
}

@override
String toString() {
    return 'MapEvent.selectLocationWithId(locationId: $locationId)';
}


}

/// @nodoc
abstract mixin class $SelectLocationWithIdCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $SelectLocationWithIdCopyWith(SelectLocationWithId value, $Res Function(SelectLocationWithId) _then) = _$SelectLocationWithIdCopyWithImpl;
@useResult
$Res call({
 String locationId
});




}
/// @nodoc
class _$SelectLocationWithIdCopyWithImpl<$Res>
    implements $SelectLocationWithIdCopyWith<$Res> {
  _$SelectLocationWithIdCopyWithImpl(this._self, this._then);

  final SelectLocationWithId _self;
  final $Res Function(SelectLocationWithId) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? locationId = null,}) {
  return _then(SelectLocationWithId(
null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RegionUpdated implements MapEvent {
  const RegionUpdated({required this.mapBounds, required this.zoomLevel});
  

 final  LatLngBounds mapBounds;
 final  double zoomLevel;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegionUpdatedCopyWith<RegionUpdated> get copyWith => _$RegionUpdatedCopyWithImpl<RegionUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RegionUpdated&&(identical(other.mapBounds, mapBounds) || other.mapBounds == mapBounds)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mapBounds,zoomLevel);
}

@override
String toString() {
    return 'MapEvent.regionUpdated(mapBounds: $mapBounds, zoomLevel: $zoomLevel)';
}


}

/// @nodoc
abstract mixin class $RegionUpdatedCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $RegionUpdatedCopyWith(RegionUpdated value, $Res Function(RegionUpdated) _then) = _$RegionUpdatedCopyWithImpl;
@useResult
$Res call({
 LatLngBounds mapBounds, double zoomLevel
});




}
/// @nodoc
class _$RegionUpdatedCopyWithImpl<$Res>
    implements $RegionUpdatedCopyWith<$Res> {
  _$RegionUpdatedCopyWithImpl(this._self, this._then);

  final RegionUpdated _self;
  final $Res Function(RegionUpdated) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mapBounds = null,Object? zoomLevel = null,}) {
  return _then(RegionUpdated(
mapBounds: null == mapBounds ? _self.mapBounds : mapBounds // ignore: cast_nullable_to_non_nullable
as LatLngBounds,zoomLevel: null == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class MapFiltersChanged implements MapEvent {
  const MapFiltersChanged(this.newFilters);
  

 final  ChargingLocationFilters newFilters;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapFiltersChangedCopyWith<MapFiltersChanged> get copyWith => _$MapFiltersChangedCopyWithImpl<MapFiltersChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapFiltersChanged&&(identical(other.newFilters, newFilters) || other.newFilters == newFilters));
}


@override
int get hashCode {
    return Object.hash(runtimeType,newFilters);
}

@override
String toString() {
    return 'MapEvent.mapFiltersChanged(newFilters: $newFilters)';
}


}

/// @nodoc
abstract mixin class $MapFiltersChangedCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $MapFiltersChangedCopyWith(MapFiltersChanged value, $Res Function(MapFiltersChanged) _then) = _$MapFiltersChangedCopyWithImpl;
@useResult
$Res call({
 ChargingLocationFilters newFilters
});




}
/// @nodoc
class _$MapFiltersChangedCopyWithImpl<$Res>
    implements $MapFiltersChangedCopyWith<$Res> {
  _$MapFiltersChangedCopyWithImpl(this._self, this._then);

  final MapFiltersChanged _self;
  final $Res Function(MapFiltersChanged) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newFilters = null,}) {
  return _then(MapFiltersChanged(
null == newFilters ? _self.newFilters : newFilters // ignore: cast_nullable_to_non_nullable
as ChargingLocationFilters,
  ));
}


}

/// @nodoc


class MapFiltersApplied implements MapEvent {
  const MapFiltersApplied(this.newFilters);
  

 final  ChargingLocationFilters newFilters;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapFiltersAppliedCopyWith<MapFiltersApplied> get copyWith => _$MapFiltersAppliedCopyWithImpl<MapFiltersApplied>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapFiltersApplied&&(identical(other.newFilters, newFilters) || other.newFilters == newFilters));
}


@override
int get hashCode {
    return Object.hash(runtimeType,newFilters);
}

@override
String toString() {
    return 'MapEvent.mapFiltersApplied(newFilters: $newFilters)';
}


}

/// @nodoc
abstract mixin class $MapFiltersAppliedCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $MapFiltersAppliedCopyWith(MapFiltersApplied value, $Res Function(MapFiltersApplied) _then) = _$MapFiltersAppliedCopyWithImpl;
@useResult
$Res call({
 ChargingLocationFilters newFilters
});




}
/// @nodoc
class _$MapFiltersAppliedCopyWithImpl<$Res>
    implements $MapFiltersAppliedCopyWith<$Res> {
  _$MapFiltersAppliedCopyWithImpl(this._self, this._then);

  final MapFiltersApplied _self;
  final $Res Function(MapFiltersApplied) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newFilters = null,}) {
  return _then(MapFiltersApplied(
null == newFilters ? _self.newFilters : newFilters // ignore: cast_nullable_to_non_nullable
as ChargingLocationFilters,
  ));
}


}

/// @nodoc


class MoveMapToLocation implements MapEvent {
  const MoveMapToLocation(this.latitude, this.longitude, this.pinSelection);
  

 final  double latitude;
 final  double longitude;
 final  MapLocationPinSelection pinSelection;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveMapToLocationCopyWith<MoveMapToLocation> get copyWith => _$MoveMapToLocationCopyWithImpl<MoveMapToLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveMapToLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.pinSelection, pinSelection) || other.pinSelection == pinSelection));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latitude,longitude,pinSelection);
}

@override
String toString() {
    return 'MapEvent.moveMapToLocation(latitude: $latitude, longitude: $longitude, pinSelection: $pinSelection)';
}


}

/// @nodoc
abstract mixin class $MoveMapToLocationCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $MoveMapToLocationCopyWith(MoveMapToLocation value, $Res Function(MoveMapToLocation) _then) = _$MoveMapToLocationCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, MapLocationPinSelection pinSelection
});


$MapLocationPinSelectionCopyWith<$Res> get pinSelection;

}
/// @nodoc
class _$MoveMapToLocationCopyWithImpl<$Res>
    implements $MoveMapToLocationCopyWith<$Res> {
  _$MoveMapToLocationCopyWithImpl(this._self, this._then);

  final MoveMapToLocation _self;
  final $Res Function(MoveMapToLocation) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? pinSelection = null,}) {
  return _then(MoveMapToLocation(
null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,null == pinSelection ? _self.pinSelection : pinSelection // ignore: cast_nullable_to_non_nullable
as MapLocationPinSelection,
  ));
}

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapLocationPinSelectionCopyWith<$Res> get pinSelection {
  
  return $MapLocationPinSelectionCopyWith<$Res>(_self.pinSelection, (value) {
    return _then(_self.copyWith(pinSelection: value));
  });
}
}

/// @nodoc


class GeoCodingResultSelected implements MapEvent {
  const GeoCodingResultSelected(this.selectedResult);
  

 final  GeoLocationResult selectedResult;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeoCodingResultSelectedCopyWith<GeoCodingResultSelected> get copyWith => _$GeoCodingResultSelectedCopyWithImpl<GeoCodingResultSelected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GeoCodingResultSelected&&(identical(other.selectedResult, selectedResult) || other.selectedResult == selectedResult));
}


@override
int get hashCode {
    return Object.hash(runtimeType,selectedResult);
}

@override
String toString() {
    return 'MapEvent.geoCodingResultSelected(selectedResult: $selectedResult)';
}


}

/// @nodoc
abstract mixin class $GeoCodingResultSelectedCopyWith<$Res> implements $MapEventCopyWith<$Res> {
  factory $GeoCodingResultSelectedCopyWith(GeoCodingResultSelected value, $Res Function(GeoCodingResultSelected) _then) = _$GeoCodingResultSelectedCopyWithImpl;
@useResult
$Res call({
 GeoLocationResult selectedResult
});




}
/// @nodoc
class _$GeoCodingResultSelectedCopyWithImpl<$Res>
    implements $GeoCodingResultSelectedCopyWith<$Res> {
  _$GeoCodingResultSelectedCopyWithImpl(this._self, this._then);

  final GeoCodingResultSelected _self;
  final $Res Function(GeoCodingResultSelected) _then;

/// Create a copy of MapEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedResult = null,}) {
  return _then(GeoCodingResultSelected(
null == selectedResult ? _self.selectedResult : selectedResult // ignore: cast_nullable_to_non_nullable
as GeoLocationResult,
  ));
}


}

// dart format on
