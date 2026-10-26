// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_overlay_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapOverlayEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapOverlayEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapOverlayEvent()';
}


}

/// @nodoc
class $MapOverlayEventCopyWith<$Res>  {
$MapOverlayEventCopyWith(MapOverlayEvent _, $Res Function(MapOverlayEvent) __);
}


/// Adds pattern-matching-related methods to [MapOverlayEvent].
extension MapOverlayEventPatterns on MapOverlayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchQuery value)?  searchQuery,TResult Function( ResetToInitial value)?  resetToInitial,TResult Function( WaitForMapToSettle value)?  waitForMapToSettle,TResult Function( LoadSearchResults value)?  loadSearchResults,TResult Function( MapLocationSelectedOnMap value)?  mapLocationSelectedOnMap,TResult Function( ShowMapLocation value)?  showMapLocation,TResult Function( MapLocationSelectedInSearch value)?  mapLocationSelectedInSearch,TResult Function( BackToChargingStationResults value)?  backToChargingStationResults,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchQuery() when searchQuery != null:
return searchQuery(_that);case ResetToInitial() when resetToInitial != null:
return resetToInitial(_that);case WaitForMapToSettle() when waitForMapToSettle != null:
return waitForMapToSettle(_that);case LoadSearchResults() when loadSearchResults != null:
return loadSearchResults(_that);case MapLocationSelectedOnMap() when mapLocationSelectedOnMap != null:
return mapLocationSelectedOnMap(_that);case ShowMapLocation() when showMapLocation != null:
return showMapLocation(_that);case MapLocationSelectedInSearch() when mapLocationSelectedInSearch != null:
return mapLocationSelectedInSearch(_that);case BackToChargingStationResults() when backToChargingStationResults != null:
return backToChargingStationResults(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchQuery value)  searchQuery,required TResult Function( ResetToInitial value)  resetToInitial,required TResult Function( WaitForMapToSettle value)  waitForMapToSettle,required TResult Function( LoadSearchResults value)  loadSearchResults,required TResult Function( MapLocationSelectedOnMap value)  mapLocationSelectedOnMap,required TResult Function( ShowMapLocation value)  showMapLocation,required TResult Function( MapLocationSelectedInSearch value)  mapLocationSelectedInSearch,required TResult Function( BackToChargingStationResults value)  backToChargingStationResults,}){
final _that = this;
switch (_that) {
case SearchQuery():
return searchQuery(_that);case ResetToInitial():
return resetToInitial(_that);case WaitForMapToSettle():
return waitForMapToSettle(_that);case LoadSearchResults():
return loadSearchResults(_that);case MapLocationSelectedOnMap():
return mapLocationSelectedOnMap(_that);case ShowMapLocation():
return showMapLocation(_that);case MapLocationSelectedInSearch():
return mapLocationSelectedInSearch(_that);case BackToChargingStationResults():
return backToChargingStationResults(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchQuery value)?  searchQuery,TResult? Function( ResetToInitial value)?  resetToInitial,TResult? Function( WaitForMapToSettle value)?  waitForMapToSettle,TResult? Function( LoadSearchResults value)?  loadSearchResults,TResult? Function( MapLocationSelectedOnMap value)?  mapLocationSelectedOnMap,TResult? Function( ShowMapLocation value)?  showMapLocation,TResult? Function( MapLocationSelectedInSearch value)?  mapLocationSelectedInSearch,TResult? Function( BackToChargingStationResults value)?  backToChargingStationResults,}){
final _that = this;
switch (_that) {
case SearchQuery() when searchQuery != null:
return searchQuery(_that);case ResetToInitial() when resetToInitial != null:
return resetToInitial(_that);case WaitForMapToSettle() when waitForMapToSettle != null:
return waitForMapToSettle(_that);case LoadSearchResults() when loadSearchResults != null:
return loadSearchResults(_that);case MapLocationSelectedOnMap() when mapLocationSelectedOnMap != null:
return mapLocationSelectedOnMap(_that);case ShowMapLocation() when showMapLocation != null:
return showMapLocation(_that);case MapLocationSelectedInSearch() when mapLocationSelectedInSearch != null:
return mapLocationSelectedInSearch(_that);case BackToChargingStationResults() when backToChargingStationResults != null:
return backToChargingStationResults(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String searchText)?  searchQuery,TResult Function()?  resetToInitial,TResult Function( dynamic Function(BuildContext context) onMapSettled)?  waitForMapToSettle,TResult Function( String? searchBoxText,  List<MapLocationItem> mapItems,  LatLng? mapPinPosition)?  loadSearchResults,TResult Function( MapLocationItem mapItem)?  mapLocationSelectedOnMap,TResult Function( List<MapLocationV2> mapLocations)?  showMapLocation,TResult Function( MapLocationsResponseModel mapLocations)?  mapLocationSelectedInSearch,TResult Function()?  backToChargingStationResults,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchQuery() when searchQuery != null:
return searchQuery(_that.searchText);case ResetToInitial() when resetToInitial != null:
return resetToInitial();case WaitForMapToSettle() when waitForMapToSettle != null:
return waitForMapToSettle(_that.onMapSettled);case LoadSearchResults() when loadSearchResults != null:
return loadSearchResults(_that.searchBoxText,_that.mapItems,_that.mapPinPosition);case MapLocationSelectedOnMap() when mapLocationSelectedOnMap != null:
return mapLocationSelectedOnMap(_that.mapItem);case ShowMapLocation() when showMapLocation != null:
return showMapLocation(_that.mapLocations);case MapLocationSelectedInSearch() when mapLocationSelectedInSearch != null:
return mapLocationSelectedInSearch(_that.mapLocations);case BackToChargingStationResults() when backToChargingStationResults != null:
return backToChargingStationResults();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String searchText)  searchQuery,required TResult Function()  resetToInitial,required TResult Function( dynamic Function(BuildContext context) onMapSettled)  waitForMapToSettle,required TResult Function( String? searchBoxText,  List<MapLocationItem> mapItems,  LatLng? mapPinPosition)  loadSearchResults,required TResult Function( MapLocationItem mapItem)  mapLocationSelectedOnMap,required TResult Function( List<MapLocationV2> mapLocations)  showMapLocation,required TResult Function( MapLocationsResponseModel mapLocations)  mapLocationSelectedInSearch,required TResult Function()  backToChargingStationResults,}) {final _that = this;
switch (_that) {
case SearchQuery():
return searchQuery(_that.searchText);case ResetToInitial():
return resetToInitial();case WaitForMapToSettle():
return waitForMapToSettle(_that.onMapSettled);case LoadSearchResults():
return loadSearchResults(_that.searchBoxText,_that.mapItems,_that.mapPinPosition);case MapLocationSelectedOnMap():
return mapLocationSelectedOnMap(_that.mapItem);case ShowMapLocation():
return showMapLocation(_that.mapLocations);case MapLocationSelectedInSearch():
return mapLocationSelectedInSearch(_that.mapLocations);case BackToChargingStationResults():
return backToChargingStationResults();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String searchText)?  searchQuery,TResult? Function()?  resetToInitial,TResult? Function( dynamic Function(BuildContext context) onMapSettled)?  waitForMapToSettle,TResult? Function( String? searchBoxText,  List<MapLocationItem> mapItems,  LatLng? mapPinPosition)?  loadSearchResults,TResult? Function( MapLocationItem mapItem)?  mapLocationSelectedOnMap,TResult? Function( List<MapLocationV2> mapLocations)?  showMapLocation,TResult? Function( MapLocationsResponseModel mapLocations)?  mapLocationSelectedInSearch,TResult? Function()?  backToChargingStationResults,}) {final _that = this;
switch (_that) {
case SearchQuery() when searchQuery != null:
return searchQuery(_that.searchText);case ResetToInitial() when resetToInitial != null:
return resetToInitial();case WaitForMapToSettle() when waitForMapToSettle != null:
return waitForMapToSettle(_that.onMapSettled);case LoadSearchResults() when loadSearchResults != null:
return loadSearchResults(_that.searchBoxText,_that.mapItems,_that.mapPinPosition);case MapLocationSelectedOnMap() when mapLocationSelectedOnMap != null:
return mapLocationSelectedOnMap(_that.mapItem);case ShowMapLocation() when showMapLocation != null:
return showMapLocation(_that.mapLocations);case MapLocationSelectedInSearch() when mapLocationSelectedInSearch != null:
return mapLocationSelectedInSearch(_that.mapLocations);case BackToChargingStationResults() when backToChargingStationResults != null:
return backToChargingStationResults();case _:
  return null;

}
}

}

/// @nodoc


class SearchQuery implements MapOverlayEvent {
  const SearchQuery(this.searchText);
  

 final  String searchText;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchQueryCopyWith<SearchQuery> get copyWith => _$SearchQueryCopyWithImpl<SearchQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchQuery&&(identical(other.searchText, searchText) || other.searchText == searchText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText);
}

@override
String toString() {
    return 'MapOverlayEvent.searchQuery(searchText: $searchText)';
}


}

/// @nodoc
abstract mixin class $SearchQueryCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $SearchQueryCopyWith(SearchQuery value, $Res Function(SearchQuery) _then) = _$SearchQueryCopyWithImpl;
@useResult
$Res call({
 String searchText
});




}
/// @nodoc
class _$SearchQueryCopyWithImpl<$Res>
    implements $SearchQueryCopyWith<$Res> {
  _$SearchQueryCopyWithImpl(this._self, this._then);

  final SearchQuery _self;
  final $Res Function(SearchQuery) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? searchText = null,}) {
  return _then(SearchQuery(
null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ResetToInitial implements MapOverlayEvent {
  const ResetToInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetToInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapOverlayEvent.resetToInitial()';
}


}




/// @nodoc


class WaitForMapToSettle implements MapOverlayEvent {
  const WaitForMapToSettle(this.onMapSettled);
  

 final  dynamic Function(BuildContext context) onMapSettled;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaitForMapToSettleCopyWith<WaitForMapToSettle> get copyWith => _$WaitForMapToSettleCopyWithImpl<WaitForMapToSettle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WaitForMapToSettle&&(identical(other.onMapSettled, onMapSettled) || other.onMapSettled == onMapSettled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,onMapSettled);
}

@override
String toString() {
    return 'MapOverlayEvent.waitForMapToSettle(onMapSettled: $onMapSettled)';
}


}

/// @nodoc
abstract mixin class $WaitForMapToSettleCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $WaitForMapToSettleCopyWith(WaitForMapToSettle value, $Res Function(WaitForMapToSettle) _then) = _$WaitForMapToSettleCopyWithImpl;
@useResult
$Res call({
 dynamic Function(BuildContext context) onMapSettled
});




}
/// @nodoc
class _$WaitForMapToSettleCopyWithImpl<$Res>
    implements $WaitForMapToSettleCopyWith<$Res> {
  _$WaitForMapToSettleCopyWithImpl(this._self, this._then);

  final WaitForMapToSettle _self;
  final $Res Function(WaitForMapToSettle) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? onMapSettled = null,}) {
  return _then(WaitForMapToSettle(
null == onMapSettled ? _self.onMapSettled : onMapSettled // ignore: cast_nullable_to_non_nullable
as dynamic Function(BuildContext context),
  ));
}


}

/// @nodoc


class LoadSearchResults implements MapOverlayEvent {
  const LoadSearchResults(this.searchBoxText,  List<MapLocationItem> mapItems, this.mapPinPosition): _mapItems = mapItems;
  

 final  String? searchBoxText;
 final  List<MapLocationItem> _mapItems;
 List<MapLocationItem> get mapItems {
  if (_mapItems is EqualUnmodifiableListView) return _mapItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapItems);
}

 final  LatLng? mapPinPosition;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadSearchResultsCopyWith<LoadSearchResults> get copyWith => _$LoadSearchResultsCopyWithImpl<LoadSearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadSearchResults&&(identical(other.searchBoxText, searchBoxText) || other.searchBoxText == searchBoxText)&&const DeepCollectionEquality().equals(other.mapItems, _mapItems)&&(identical(other.mapPinPosition, mapPinPosition) || other.mapPinPosition == mapPinPosition));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchBoxText,const DeepCollectionEquality().hash(_mapItems),mapPinPosition);
}

@override
String toString() {
    return 'MapOverlayEvent.loadSearchResults(searchBoxText: $searchBoxText, mapItems: $mapItems, mapPinPosition: $mapPinPosition)';
}


}

/// @nodoc
abstract mixin class $LoadSearchResultsCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $LoadSearchResultsCopyWith(LoadSearchResults value, $Res Function(LoadSearchResults) _then) = _$LoadSearchResultsCopyWithImpl;
@useResult
$Res call({
 String? searchBoxText, List<MapLocationItem> mapItems, LatLng? mapPinPosition
});




}
/// @nodoc
class _$LoadSearchResultsCopyWithImpl<$Res>
    implements $LoadSearchResultsCopyWith<$Res> {
  _$LoadSearchResultsCopyWithImpl(this._self, this._then);

  final LoadSearchResults _self;
  final $Res Function(LoadSearchResults) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? searchBoxText = freezed,Object? mapItems = null,Object? mapPinPosition = freezed,}) {
  return _then(LoadSearchResults(
freezed == searchBoxText ? _self.searchBoxText : searchBoxText // ignore: cast_nullable_to_non_nullable
as String?,null == mapItems ? _self._mapItems : mapItems // ignore: cast_nullable_to_non_nullable
as List<MapLocationItem>,freezed == mapPinPosition ? _self.mapPinPosition : mapPinPosition // ignore: cast_nullable_to_non_nullable
as LatLng?,
  ));
}


}

/// @nodoc


class MapLocationSelectedOnMap implements MapOverlayEvent {
  const MapLocationSelectedOnMap(this.mapItem);
  

 final  MapLocationItem mapItem;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapLocationSelectedOnMapCopyWith<MapLocationSelectedOnMap> get copyWith => _$MapLocationSelectedOnMapCopyWithImpl<MapLocationSelectedOnMap>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLocationSelectedOnMap&&(identical(other.mapItem, mapItem) || other.mapItem == mapItem));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mapItem);
}

@override
String toString() {
    return 'MapOverlayEvent.mapLocationSelectedOnMap(mapItem: $mapItem)';
}


}

/// @nodoc
abstract mixin class $MapLocationSelectedOnMapCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $MapLocationSelectedOnMapCopyWith(MapLocationSelectedOnMap value, $Res Function(MapLocationSelectedOnMap) _then) = _$MapLocationSelectedOnMapCopyWithImpl;
@useResult
$Res call({
 MapLocationItem mapItem
});




}
/// @nodoc
class _$MapLocationSelectedOnMapCopyWithImpl<$Res>
    implements $MapLocationSelectedOnMapCopyWith<$Res> {
  _$MapLocationSelectedOnMapCopyWithImpl(this._self, this._then);

  final MapLocationSelectedOnMap _self;
  final $Res Function(MapLocationSelectedOnMap) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mapItem = null,}) {
  return _then(MapLocationSelectedOnMap(
null == mapItem ? _self.mapItem : mapItem // ignore: cast_nullable_to_non_nullable
as MapLocationItem,
  ));
}


}

/// @nodoc


class ShowMapLocation implements MapOverlayEvent {
  const ShowMapLocation( List<MapLocationV2> mapLocations): _mapLocations = mapLocations;
  

 final  List<MapLocationV2> _mapLocations;
 List<MapLocationV2> get mapLocations {
  if (_mapLocations is EqualUnmodifiableListView) return _mapLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapLocations);
}


/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowMapLocationCopyWith<ShowMapLocation> get copyWith => _$ShowMapLocationCopyWithImpl<ShowMapLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowMapLocation&&const DeepCollectionEquality().equals(other.mapLocations, _mapLocations));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_mapLocations));
}

@override
String toString() {
    return 'MapOverlayEvent.showMapLocation(mapLocations: $mapLocations)';
}


}

/// @nodoc
abstract mixin class $ShowMapLocationCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $ShowMapLocationCopyWith(ShowMapLocation value, $Res Function(ShowMapLocation) _then) = _$ShowMapLocationCopyWithImpl;
@useResult
$Res call({
 List<MapLocationV2> mapLocations
});




}
/// @nodoc
class _$ShowMapLocationCopyWithImpl<$Res>
    implements $ShowMapLocationCopyWith<$Res> {
  _$ShowMapLocationCopyWithImpl(this._self, this._then);

  final ShowMapLocation _self;
  final $Res Function(ShowMapLocation) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mapLocations = null,}) {
  return _then(ShowMapLocation(
null == mapLocations ? _self._mapLocations : mapLocations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,
  ));
}


}

/// @nodoc


class MapLocationSelectedInSearch implements MapOverlayEvent {
  const MapLocationSelectedInSearch(this.mapLocations);
  

 final  MapLocationsResponseModel mapLocations;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapLocationSelectedInSearchCopyWith<MapLocationSelectedInSearch> get copyWith => _$MapLocationSelectedInSearchCopyWithImpl<MapLocationSelectedInSearch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLocationSelectedInSearch&&(identical(other.mapLocations, mapLocations) || other.mapLocations == mapLocations));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mapLocations);
}

@override
String toString() {
    return 'MapOverlayEvent.mapLocationSelectedInSearch(mapLocations: $mapLocations)';
}


}

/// @nodoc
abstract mixin class $MapLocationSelectedInSearchCopyWith<$Res> implements $MapOverlayEventCopyWith<$Res> {
  factory $MapLocationSelectedInSearchCopyWith(MapLocationSelectedInSearch value, $Res Function(MapLocationSelectedInSearch) _then) = _$MapLocationSelectedInSearchCopyWithImpl;
@useResult
$Res call({
 MapLocationsResponseModel mapLocations
});




}
/// @nodoc
class _$MapLocationSelectedInSearchCopyWithImpl<$Res>
    implements $MapLocationSelectedInSearchCopyWith<$Res> {
  _$MapLocationSelectedInSearchCopyWithImpl(this._self, this._then);

  final MapLocationSelectedInSearch _self;
  final $Res Function(MapLocationSelectedInSearch) _then;

/// Create a copy of MapOverlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mapLocations = null,}) {
  return _then(MapLocationSelectedInSearch(
null == mapLocations ? _self.mapLocations : mapLocations // ignore: cast_nullable_to_non_nullable
as MapLocationsResponseModel,
  ));
}


}

/// @nodoc


class BackToChargingStationResults implements MapOverlayEvent {
  const BackToChargingStationResults();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BackToChargingStationResults);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MapOverlayEvent.backToChargingStationResults()';
}


}




/// @nodoc
mixin _$MapOverlayState {

 UIFlow get flow;
/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapOverlayStateCopyWith<MapOverlayState> get copyWith => _$MapOverlayStateCopyWithImpl<MapOverlayState>(this as MapOverlayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MapOverlayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapOverlayState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as MapOverlayState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as MapOverlayState;
  return 'MapOverlayState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $MapOverlayStateCopyWith<$Res>  {
  factory $MapOverlayStateCopyWith(MapOverlayState value, $Res Function(MapOverlayState) _then) = _$MapOverlayStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MapOverlayStateCopyWithImpl<$Res>
    implements $MapOverlayStateCopyWith<$Res> {
  _$MapOverlayStateCopyWithImpl(this._self, this._then);

  final MapOverlayState _self;
  final $Res Function(MapOverlayState) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapOverlayState].
extension MapOverlayStatePatterns on MapOverlayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( TypeAheadSearchResults value)?  typeaheadSearchResults,TResult Function( WaitingForMapToSettle value)?  waitingForMapToSettle,TResult Function( ShowChargingStationResults value)?  showChargingStationResults,TResult Function( ShowChargingStation value)?  showChargingStation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case TypeAheadSearchResults() when typeaheadSearchResults != null:
return typeaheadSearchResults(_that);case WaitingForMapToSettle() when waitingForMapToSettle != null:
return waitingForMapToSettle(_that);case ShowChargingStationResults() when showChargingStationResults != null:
return showChargingStationResults(_that);case ShowChargingStation() when showChargingStation != null:
return showChargingStation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( TypeAheadSearchResults value)  typeaheadSearchResults,required TResult Function( WaitingForMapToSettle value)  waitingForMapToSettle,required TResult Function( ShowChargingStationResults value)  showChargingStationResults,required TResult Function( ShowChargingStation value)  showChargingStation,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case TypeAheadSearchResults():
return typeaheadSearchResults(_that);case WaitingForMapToSettle():
return waitingForMapToSettle(_that);case ShowChargingStationResults():
return showChargingStationResults(_that);case ShowChargingStation():
return showChargingStation(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( TypeAheadSearchResults value)?  typeaheadSearchResults,TResult? Function( WaitingForMapToSettle value)?  waitingForMapToSettle,TResult? Function( ShowChargingStationResults value)?  showChargingStationResults,TResult? Function( ShowChargingStation value)?  showChargingStation,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case TypeAheadSearchResults() when typeaheadSearchResults != null:
return typeaheadSearchResults(_that);case WaitingForMapToSettle() when waitingForMapToSettle != null:
return waitingForMapToSettle(_that);case ShowChargingStationResults() when showChargingStationResults != null:
return showChargingStationResults(_that);case ShowChargingStation() when showChargingStation != null:
return showChargingStation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow)?  initial,TResult Function( String searchText,  List<GeoLocationResult> results,  UIFlow flow)?  typeaheadSearchResults,TResult Function( dynamic Function(BuildContext context) onMapSettled,  UIFlow flow)?  waitingForMapToSettle,TResult Function( List<MapLocationsResponseModel> locations,  String? searchBoxText,  LatLng? mapPinPosition,  UIFlow flow)?  showChargingStationResults,TResult Function( List<MapLocationV2> mapLocations,  bool fromFavourites,  UIFlow flow)?  showChargingStation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.flow);case TypeAheadSearchResults() when typeaheadSearchResults != null:
return typeaheadSearchResults(_that.searchText,_that.results,_that.flow);case WaitingForMapToSettle() when waitingForMapToSettle != null:
return waitingForMapToSettle(_that.onMapSettled,_that.flow);case ShowChargingStationResults() when showChargingStationResults != null:
return showChargingStationResults(_that.locations,_that.searchBoxText,_that.mapPinPosition,_that.flow);case ShowChargingStation() when showChargingStation != null:
return showChargingStation(_that.mapLocations,_that.fromFavourites,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow)  initial,required TResult Function( String searchText,  List<GeoLocationResult> results,  UIFlow flow)  typeaheadSearchResults,required TResult Function( dynamic Function(BuildContext context) onMapSettled,  UIFlow flow)  waitingForMapToSettle,required TResult Function( List<MapLocationsResponseModel> locations,  String? searchBoxText,  LatLng? mapPinPosition,  UIFlow flow)  showChargingStationResults,required TResult Function( List<MapLocationV2> mapLocations,  bool fromFavourites,  UIFlow flow)  showChargingStation,}) {final _that = this;
switch (_that) {
case Initial():
return initial(_that.flow);case TypeAheadSearchResults():
return typeaheadSearchResults(_that.searchText,_that.results,_that.flow);case WaitingForMapToSettle():
return waitingForMapToSettle(_that.onMapSettled,_that.flow);case ShowChargingStationResults():
return showChargingStationResults(_that.locations,_that.searchBoxText,_that.mapPinPosition,_that.flow);case ShowChargingStation():
return showChargingStation(_that.mapLocations,_that.fromFavourites,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow)?  initial,TResult? Function( String searchText,  List<GeoLocationResult> results,  UIFlow flow)?  typeaheadSearchResults,TResult? Function( dynamic Function(BuildContext context) onMapSettled,  UIFlow flow)?  waitingForMapToSettle,TResult? Function( List<MapLocationsResponseModel> locations,  String? searchBoxText,  LatLng? mapPinPosition,  UIFlow flow)?  showChargingStationResults,TResult? Function( List<MapLocationV2> mapLocations,  bool fromFavourites,  UIFlow flow)?  showChargingStation,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.flow);case TypeAheadSearchResults() when typeaheadSearchResults != null:
return typeaheadSearchResults(_that.searchText,_that.results,_that.flow);case WaitingForMapToSettle() when waitingForMapToSettle != null:
return waitingForMapToSettle(_that.onMapSettled,_that.flow);case ShowChargingStationResults() when showChargingStationResults != null:
return showChargingStationResults(_that.locations,_that.searchBoxText,_that.mapPinPosition,_that.flow);case ShowChargingStation() when showChargingStation != null:
return showChargingStation(_that.mapLocations,_that.fromFavourites,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements MapOverlayState {
  const Initial({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitialCopyWith<Initial> get copyWith => _$InitialCopyWithImpl<Initial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'MapOverlayState.initial(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $InitialCopyWith<$Res> implements $MapOverlayStateCopyWith<$Res> {
  factory $InitialCopyWith(Initial value, $Res Function(Initial) _then) = _$InitialCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$InitialCopyWithImpl<$Res>
    implements $InitialCopyWith<$Res> {
  _$InitialCopyWithImpl(this._self, this._then);

  final Initial _self;
  final $Res Function(Initial) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(Initial(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapOverlayState
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


class TypeAheadSearchResults implements MapOverlayState {
  const TypeAheadSearchResults(this.searchText,  List<GeoLocationResult> results, {this.flow = const UIFlow.established()}): _results = results;
  

 final  String searchText;
 final  List<GeoLocationResult> _results;
 List<GeoLocationResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TypeAheadSearchResultsCopyWith<TypeAheadSearchResults> get copyWith => _$TypeAheadSearchResultsCopyWithImpl<TypeAheadSearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TypeAheadSearchResults&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,const DeepCollectionEquality().hash(_results),flow);
}

@override
String toString() {
    return 'MapOverlayState.typeaheadSearchResults(searchText: $searchText, results: $results, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $TypeAheadSearchResultsCopyWith<$Res> implements $MapOverlayStateCopyWith<$Res> {
  factory $TypeAheadSearchResultsCopyWith(TypeAheadSearchResults value, $Res Function(TypeAheadSearchResults) _then) = _$TypeAheadSearchResultsCopyWithImpl;
@override @useResult
$Res call({
 String searchText, List<GeoLocationResult> results, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$TypeAheadSearchResultsCopyWithImpl<$Res>
    implements $TypeAheadSearchResultsCopyWith<$Res> {
  _$TypeAheadSearchResultsCopyWithImpl(this._self, this._then);

  final TypeAheadSearchResults _self;
  final $Res Function(TypeAheadSearchResults) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? results = null,Object? flow = null,}) {
  return _then(TypeAheadSearchResults(
null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<GeoLocationResult>,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapOverlayState
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


class WaitingForMapToSettle implements MapOverlayState {
  const WaitingForMapToSettle(this.onMapSettled, {this.flow = const UIFlow.established()});
  

 final  dynamic Function(BuildContext context) onMapSettled;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaitingForMapToSettleCopyWith<WaitingForMapToSettle> get copyWith => _$WaitingForMapToSettleCopyWithImpl<WaitingForMapToSettle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WaitingForMapToSettle&&(identical(other.onMapSettled, onMapSettled) || other.onMapSettled == onMapSettled)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,onMapSettled,flow);
}

@override
String toString() {
    return 'MapOverlayState.waitingForMapToSettle(onMapSettled: $onMapSettled, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $WaitingForMapToSettleCopyWith<$Res> implements $MapOverlayStateCopyWith<$Res> {
  factory $WaitingForMapToSettleCopyWith(WaitingForMapToSettle value, $Res Function(WaitingForMapToSettle) _then) = _$WaitingForMapToSettleCopyWithImpl;
@override @useResult
$Res call({
 dynamic Function(BuildContext context) onMapSettled, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$WaitingForMapToSettleCopyWithImpl<$Res>
    implements $WaitingForMapToSettleCopyWith<$Res> {
  _$WaitingForMapToSettleCopyWithImpl(this._self, this._then);

  final WaitingForMapToSettle _self;
  final $Res Function(WaitingForMapToSettle) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onMapSettled = null,Object? flow = null,}) {
  return _then(WaitingForMapToSettle(
null == onMapSettled ? _self.onMapSettled : onMapSettled // ignore: cast_nullable_to_non_nullable
as dynamic Function(BuildContext context),flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapOverlayState
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


class ShowChargingStationResults implements MapOverlayState {
  const ShowChargingStationResults({required  List<MapLocationsResponseModel> locations, this.searchBoxText, this.mapPinPosition, this.flow = const UIFlow.established()}): _locations = locations;
  

 final  List<MapLocationsResponseModel> _locations;
 List<MapLocationsResponseModel> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

 final  String? searchBoxText;
 final  LatLng? mapPinPosition;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowChargingStationResultsCopyWith<ShowChargingStationResults> get copyWith => _$ShowChargingStationResultsCopyWithImpl<ShowChargingStationResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowChargingStationResults&&const DeepCollectionEquality().equals(other.locations, _locations)&&(identical(other.searchBoxText, searchBoxText) || other.searchBoxText == searchBoxText)&&(identical(other.mapPinPosition, mapPinPosition) || other.mapPinPosition == mapPinPosition)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_locations),searchBoxText,mapPinPosition,flow);
}

@override
String toString() {
    return 'MapOverlayState.showChargingStationResults(locations: $locations, searchBoxText: $searchBoxText, mapPinPosition: $mapPinPosition, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ShowChargingStationResultsCopyWith<$Res> implements $MapOverlayStateCopyWith<$Res> {
  factory $ShowChargingStationResultsCopyWith(ShowChargingStationResults value, $Res Function(ShowChargingStationResults) _then) = _$ShowChargingStationResultsCopyWithImpl;
@override @useResult
$Res call({
 List<MapLocationsResponseModel> locations, String? searchBoxText, LatLng? mapPinPosition, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ShowChargingStationResultsCopyWithImpl<$Res>
    implements $ShowChargingStationResultsCopyWith<$Res> {
  _$ShowChargingStationResultsCopyWithImpl(this._self, this._then);

  final ShowChargingStationResults _self;
  final $Res Function(ShowChargingStationResults) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locations = null,Object? searchBoxText = freezed,Object? mapPinPosition = freezed,Object? flow = null,}) {
  return _then(ShowChargingStationResults(
locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocationsResponseModel>,searchBoxText: freezed == searchBoxText ? _self.searchBoxText : searchBoxText // ignore: cast_nullable_to_non_nullable
as String?,mapPinPosition: freezed == mapPinPosition ? _self.mapPinPosition : mapPinPosition // ignore: cast_nullable_to_non_nullable
as LatLng?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapOverlayState
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


class ShowChargingStation implements MapOverlayState {
  const ShowChargingStation({required  List<MapLocationV2> mapLocations, required this.fromFavourites, this.flow = const UIFlow.established()}): _mapLocations = mapLocations;
  

 final  List<MapLocationV2> _mapLocations;
 List<MapLocationV2> get mapLocations {
  if (_mapLocations is EqualUnmodifiableListView) return _mapLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapLocations);
}

 final  bool fromFavourites;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowChargingStationCopyWith<ShowChargingStation> get copyWith => _$ShowChargingStationCopyWithImpl<ShowChargingStation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowChargingStation&&const DeepCollectionEquality().equals(other.mapLocations, _mapLocations)&&(identical(other.fromFavourites, fromFavourites) || other.fromFavourites == fromFavourites)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_mapLocations),fromFavourites,flow);
}

@override
String toString() {
    return 'MapOverlayState.showChargingStation(mapLocations: $mapLocations, fromFavourites: $fromFavourites, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ShowChargingStationCopyWith<$Res> implements $MapOverlayStateCopyWith<$Res> {
  factory $ShowChargingStationCopyWith(ShowChargingStation value, $Res Function(ShowChargingStation) _then) = _$ShowChargingStationCopyWithImpl;
@override @useResult
$Res call({
 List<MapLocationV2> mapLocations, bool fromFavourites, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ShowChargingStationCopyWithImpl<$Res>
    implements $ShowChargingStationCopyWith<$Res> {
  _$ShowChargingStationCopyWithImpl(this._self, this._then);

  final ShowChargingStation _self;
  final $Res Function(ShowChargingStation) _then;

/// Create a copy of MapOverlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mapLocations = null,Object? fromFavourites = null,Object? flow = null,}) {
  return _then(ShowChargingStation(
mapLocations: null == mapLocations ? _self._mapLocations : mapLocations // ignore: cast_nullable_to_non_nullable
as List<MapLocationV2>,fromFavourites: null == fromFavourites ? _self.fromFavourites : fromFavourites // ignore: cast_nullable_to_non_nullable
as bool,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MapOverlayState
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
