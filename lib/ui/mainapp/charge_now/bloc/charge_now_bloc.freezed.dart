// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'charge_now_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChargeNowState {

 UIFlow get flow;
/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargeNowStateCopyWith<ChargeNowState> get copyWith => _$ChargeNowStateCopyWithImpl<ChargeNowState>(this as ChargeNowState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChargeNowState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargeNowState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as ChargeNowState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as ChargeNowState;
  return 'ChargeNowState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $ChargeNowStateCopyWith<$Res>  {
  factory $ChargeNowStateCopyWith(ChargeNowState value, $Res Function(ChargeNowState) _then) = _$ChargeNowStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ChargeNowStateCopyWithImpl<$Res>
    implements $ChargeNowStateCopyWith<$Res> {
  _$ChargeNowStateCopyWithImpl(this._self, this._then);

  final ChargeNowState _self;
  final $Res Function(ChargeNowState) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChargeNowState].
extension ChargeNowStatePatterns on ChargeNowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConnectYourCar value)?  chargeFlowInitialScreen,TResult Function( Location value)?  location,TResult Function( IsThisYou value)?  isThisYou,TResult Function( SelectYourChargeStation value)?  selectYourChargeStation,TResult Function( ManualEvseIdInput value)?  manualEvseIdInput,TResult Function( ScanningQrCode value)?  scanningQrCode,TResult Function( StartChargingSession value)?  startChargingSession,TResult Function( ChargeSessionStarting value)?  chargeSessionStarting,TResult Function( CarIsCharging value)?  carIsCharging,TResult Function( ChargeSessionStopping value)?  chargeSessionStopping,TResult Function( ChargeSessionEnded value)?  chargeSessionEnded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConnectYourCar() when chargeFlowInitialScreen != null:
return chargeFlowInitialScreen(_that);case Location() when location != null:
return location(_that);case IsThisYou() when isThisYou != null:
return isThisYou(_that);case SelectYourChargeStation() when selectYourChargeStation != null:
return selectYourChargeStation(_that);case ManualEvseIdInput() when manualEvseIdInput != null:
return manualEvseIdInput(_that);case ScanningQrCode() when scanningQrCode != null:
return scanningQrCode(_that);case StartChargingSession() when startChargingSession != null:
return startChargingSession(_that);case ChargeSessionStarting() when chargeSessionStarting != null:
return chargeSessionStarting(_that);case CarIsCharging() when carIsCharging != null:
return carIsCharging(_that);case ChargeSessionStopping() when chargeSessionStopping != null:
return chargeSessionStopping(_that);case ChargeSessionEnded() when chargeSessionEnded != null:
return chargeSessionEnded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConnectYourCar value)  chargeFlowInitialScreen,required TResult Function( Location value)  location,required TResult Function( IsThisYou value)  isThisYou,required TResult Function( SelectYourChargeStation value)  selectYourChargeStation,required TResult Function( ManualEvseIdInput value)  manualEvseIdInput,required TResult Function( ScanningQrCode value)  scanningQrCode,required TResult Function( StartChargingSession value)  startChargingSession,required TResult Function( ChargeSessionStarting value)  chargeSessionStarting,required TResult Function( CarIsCharging value)  carIsCharging,required TResult Function( ChargeSessionStopping value)  chargeSessionStopping,required TResult Function( ChargeSessionEnded value)  chargeSessionEnded,}){
final _that = this;
switch (_that) {
case ConnectYourCar():
return chargeFlowInitialScreen(_that);case Location():
return location(_that);case IsThisYou():
return isThisYou(_that);case SelectYourChargeStation():
return selectYourChargeStation(_that);case ManualEvseIdInput():
return manualEvseIdInput(_that);case ScanningQrCode():
return scanningQrCode(_that);case StartChargingSession():
return startChargingSession(_that);case ChargeSessionStarting():
return chargeSessionStarting(_that);case CarIsCharging():
return carIsCharging(_that);case ChargeSessionStopping():
return chargeSessionStopping(_that);case ChargeSessionEnded():
return chargeSessionEnded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConnectYourCar value)?  chargeFlowInitialScreen,TResult? Function( Location value)?  location,TResult? Function( IsThisYou value)?  isThisYou,TResult? Function( SelectYourChargeStation value)?  selectYourChargeStation,TResult? Function( ManualEvseIdInput value)?  manualEvseIdInput,TResult? Function( ScanningQrCode value)?  scanningQrCode,TResult? Function( StartChargingSession value)?  startChargingSession,TResult? Function( ChargeSessionStarting value)?  chargeSessionStarting,TResult? Function( CarIsCharging value)?  carIsCharging,TResult? Function( ChargeSessionStopping value)?  chargeSessionStopping,TResult? Function( ChargeSessionEnded value)?  chargeSessionEnded,}){
final _that = this;
switch (_that) {
case ConnectYourCar() when chargeFlowInitialScreen != null:
return chargeFlowInitialScreen(_that);case Location() when location != null:
return location(_that);case IsThisYou() when isThisYou != null:
return isThisYou(_that);case SelectYourChargeStation() when selectYourChargeStation != null:
return selectYourChargeStation(_that);case ManualEvseIdInput() when manualEvseIdInput != null:
return manualEvseIdInput(_that);case ScanningQrCode() when scanningQrCode != null:
return scanningQrCode(_that);case StartChargingSession() when startChargingSession != null:
return startChargingSession(_that);case ChargeSessionStarting() when chargeSessionStarting != null:
return chargeSessionStarting(_that);case CarIsCharging() when carIsCharging != null:
return carIsCharging(_that);case ChargeSessionStopping() when chargeSessionStopping != null:
return chargeSessionStopping(_that);case ChargeSessionEnded() when chargeSessionEnded != null:
return chargeSessionEnded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow)?  chargeFlowInitialScreen,TResult Function( UserLocation? userLocation,  List<RemoteSessionAvailableModel> evseLocations,  UIFlow flow)?  location,TResult Function( StartChargingLocationMetadata evseLocation,  UIFlow flow)?  isThisYou,TResult Function( List<StartChargingLocationMetadata> evseLocations,  bool directFromInitialScreen,  ChargeStationSelectionSource source,  UIFlow flow,  String? loadingEvseId)?  selectYourChargeStation,TResult Function( UIFlow flow)?  manualEvseIdInput,TResult Function( UIFlow flow)?  scanningQrCode,TResult Function( StartChargingLocationMetadata chargingStartMetadata,  UnifiedPaymentCards cards,  UnifiedPaymentCard? selectedCard,  PreauthLimitsModel preAuthLimits,  UIFlow flow)?  startChargingSession,TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  DateTime attemptedStartTime,  UIFlow flow)?  chargeSessionStarting,TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  CurrentChargingValues? currentChargingValues,  UIFlow flow)?  carIsCharging,TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)?  chargeSessionStopping,TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)?  chargeSessionEnded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConnectYourCar() when chargeFlowInitialScreen != null:
return chargeFlowInitialScreen(_that.flow);case Location() when location != null:
return location(_that.userLocation,_that.evseLocations,_that.flow);case IsThisYou() when isThisYou != null:
return isThisYou(_that.evseLocation,_that.flow);case SelectYourChargeStation() when selectYourChargeStation != null:
return selectYourChargeStation(_that.evseLocations,_that.directFromInitialScreen,_that.source,_that.flow,_that.loadingEvseId);case ManualEvseIdInput() when manualEvseIdInput != null:
return manualEvseIdInput(_that.flow);case ScanningQrCode() when scanningQrCode != null:
return scanningQrCode(_that.flow);case StartChargingSession() when startChargingSession != null:
return startChargingSession(_that.chargingStartMetadata,_that.cards,_that.selectedCard,_that.preAuthLimits,_that.flow);case ChargeSessionStarting() when chargeSessionStarting != null:
return chargeSessionStarting(_that.session,_that.card,_that.attemptedStartTime,_that.flow);case CarIsCharging() when carIsCharging != null:
return carIsCharging(_that.session,_that.card,_that.currentChargingValues,_that.flow);case ChargeSessionStopping() when chargeSessionStopping != null:
return chargeSessionStopping(_that.session,_that.card,_that.flow);case ChargeSessionEnded() when chargeSessionEnded != null:
return chargeSessionEnded(_that.session,_that.card,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow)  chargeFlowInitialScreen,required TResult Function( UserLocation? userLocation,  List<RemoteSessionAvailableModel> evseLocations,  UIFlow flow)  location,required TResult Function( StartChargingLocationMetadata evseLocation,  UIFlow flow)  isThisYou,required TResult Function( List<StartChargingLocationMetadata> evseLocations,  bool directFromInitialScreen,  ChargeStationSelectionSource source,  UIFlow flow,  String? loadingEvseId)  selectYourChargeStation,required TResult Function( UIFlow flow)  manualEvseIdInput,required TResult Function( UIFlow flow)  scanningQrCode,required TResult Function( StartChargingLocationMetadata chargingStartMetadata,  UnifiedPaymentCards cards,  UnifiedPaymentCard? selectedCard,  PreauthLimitsModel preAuthLimits,  UIFlow flow)  startChargingSession,required TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  DateTime attemptedStartTime,  UIFlow flow)  chargeSessionStarting,required TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  CurrentChargingValues? currentChargingValues,  UIFlow flow)  carIsCharging,required TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)  chargeSessionStopping,required TResult Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)  chargeSessionEnded,}) {final _that = this;
switch (_that) {
case ConnectYourCar():
return chargeFlowInitialScreen(_that.flow);case Location():
return location(_that.userLocation,_that.evseLocations,_that.flow);case IsThisYou():
return isThisYou(_that.evseLocation,_that.flow);case SelectYourChargeStation():
return selectYourChargeStation(_that.evseLocations,_that.directFromInitialScreen,_that.source,_that.flow,_that.loadingEvseId);case ManualEvseIdInput():
return manualEvseIdInput(_that.flow);case ScanningQrCode():
return scanningQrCode(_that.flow);case StartChargingSession():
return startChargingSession(_that.chargingStartMetadata,_that.cards,_that.selectedCard,_that.preAuthLimits,_that.flow);case ChargeSessionStarting():
return chargeSessionStarting(_that.session,_that.card,_that.attemptedStartTime,_that.flow);case CarIsCharging():
return carIsCharging(_that.session,_that.card,_that.currentChargingValues,_that.flow);case ChargeSessionStopping():
return chargeSessionStopping(_that.session,_that.card,_that.flow);case ChargeSessionEnded():
return chargeSessionEnded(_that.session,_that.card,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow)?  chargeFlowInitialScreen,TResult? Function( UserLocation? userLocation,  List<RemoteSessionAvailableModel> evseLocations,  UIFlow flow)?  location,TResult? Function( StartChargingLocationMetadata evseLocation,  UIFlow flow)?  isThisYou,TResult? Function( List<StartChargingLocationMetadata> evseLocations,  bool directFromInitialScreen,  ChargeStationSelectionSource source,  UIFlow flow,  String? loadingEvseId)?  selectYourChargeStation,TResult? Function( UIFlow flow)?  manualEvseIdInput,TResult? Function( UIFlow flow)?  scanningQrCode,TResult? Function( StartChargingLocationMetadata chargingStartMetadata,  UnifiedPaymentCards cards,  UnifiedPaymentCard? selectedCard,  PreauthLimitsModel preAuthLimits,  UIFlow flow)?  startChargingSession,TResult? Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  DateTime attemptedStartTime,  UIFlow flow)?  chargeSessionStarting,TResult? Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  CurrentChargingValues? currentChargingValues,  UIFlow flow)?  carIsCharging,TResult? Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)?  chargeSessionStopping,TResult? Function( ChargingSessionModel session,  UnifiedPaymentCard? card,  UIFlow flow)?  chargeSessionEnded,}) {final _that = this;
switch (_that) {
case ConnectYourCar() when chargeFlowInitialScreen != null:
return chargeFlowInitialScreen(_that.flow);case Location() when location != null:
return location(_that.userLocation,_that.evseLocations,_that.flow);case IsThisYou() when isThisYou != null:
return isThisYou(_that.evseLocation,_that.flow);case SelectYourChargeStation() when selectYourChargeStation != null:
return selectYourChargeStation(_that.evseLocations,_that.directFromInitialScreen,_that.source,_that.flow,_that.loadingEvseId);case ManualEvseIdInput() when manualEvseIdInput != null:
return manualEvseIdInput(_that.flow);case ScanningQrCode() when scanningQrCode != null:
return scanningQrCode(_that.flow);case StartChargingSession() when startChargingSession != null:
return startChargingSession(_that.chargingStartMetadata,_that.cards,_that.selectedCard,_that.preAuthLimits,_that.flow);case ChargeSessionStarting() when chargeSessionStarting != null:
return chargeSessionStarting(_that.session,_that.card,_that.attemptedStartTime,_that.flow);case CarIsCharging() when carIsCharging != null:
return carIsCharging(_that.session,_that.card,_that.currentChargingValues,_that.flow);case ChargeSessionStopping() when chargeSessionStopping != null:
return chargeSessionStopping(_that.session,_that.card,_that.flow);case ChargeSessionEnded() when chargeSessionEnded != null:
return chargeSessionEnded(_that.session,_that.card,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class ConnectYourCar implements ChargeNowState {
  const ConnectYourCar({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectYourCarCopyWith<ConnectYourCar> get copyWith => _$ConnectYourCarCopyWithImpl<ConnectYourCar>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectYourCar&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'ChargeNowState.chargeFlowInitialScreen(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ConnectYourCarCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ConnectYourCarCopyWith(ConnectYourCar value, $Res Function(ConnectYourCar) _then) = _$ConnectYourCarCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ConnectYourCarCopyWithImpl<$Res>
    implements $ConnectYourCarCopyWith<$Res> {
  _$ConnectYourCarCopyWithImpl(this._self, this._then);

  final ConnectYourCar _self;
  final $Res Function(ConnectYourCar) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(ConnectYourCar(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class Location implements ChargeNowState {
  const Location(this.userLocation,  List<RemoteSessionAvailableModel> evseLocations, {this.flow = const UIFlow.established()}): _evseLocations = evseLocations;
  

 final  UserLocation? userLocation;
 final  List<RemoteSessionAvailableModel> _evseLocations;
 List<RemoteSessionAvailableModel> get evseLocations {
  if (_evseLocations is EqualUnmodifiableListView) return _evseLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evseLocations);
}

@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.userLocation, userLocation) || other.userLocation == userLocation)&&const DeepCollectionEquality().equals(other.evseLocations, _evseLocations)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userLocation,const DeepCollectionEquality().hash(_evseLocations),flow);
}

@override
String toString() {
    return 'ChargeNowState.location(userLocation: $userLocation, evseLocations: $evseLocations, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@override @useResult
$Res call({
 UserLocation? userLocation, List<RemoteSessionAvailableModel> evseLocations, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userLocation = freezed,Object? evseLocations = null,Object? flow = null,}) {
  return _then(Location(
freezed == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation?,null == evseLocations ? _self._evseLocations : evseLocations // ignore: cast_nullable_to_non_nullable
as List<RemoteSessionAvailableModel>,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class IsThisYou implements ChargeNowState {
  const IsThisYou(this.evseLocation, {this.flow = const UIFlow.established()});
  

 final  StartChargingLocationMetadata evseLocation;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IsThisYouCopyWith<IsThisYou> get copyWith => _$IsThisYouCopyWithImpl<IsThisYou>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IsThisYou&&(identical(other.evseLocation, evseLocation) || other.evseLocation == evseLocation)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,evseLocation,flow);
}

@override
String toString() {
    return 'ChargeNowState.isThisYou(evseLocation: $evseLocation, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $IsThisYouCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $IsThisYouCopyWith(IsThisYou value, $Res Function(IsThisYou) _then) = _$IsThisYouCopyWithImpl;
@override @useResult
$Res call({
 StartChargingLocationMetadata evseLocation, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$IsThisYouCopyWithImpl<$Res>
    implements $IsThisYouCopyWith<$Res> {
  _$IsThisYouCopyWithImpl(this._self, this._then);

  final IsThisYou _self;
  final $Res Function(IsThisYou) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? evseLocation = null,Object? flow = null,}) {
  return _then(IsThisYou(
null == evseLocation ? _self.evseLocation : evseLocation // ignore: cast_nullable_to_non_nullable
as StartChargingLocationMetadata,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class SelectYourChargeStation implements ChargeNowState {
  const SelectYourChargeStation( List<StartChargingLocationMetadata> evseLocations, this.directFromInitialScreen, {this.source = ChargeStationSelectionSource.manual, this.flow = const UIFlow.established(), this.loadingEvseId}): _evseLocations = evseLocations;
  

 final  List<StartChargingLocationMetadata> _evseLocations;
 List<StartChargingLocationMetadata> get evseLocations {
  if (_evseLocations is EqualUnmodifiableListView) return _evseLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evseLocations);
}

 final  bool directFromInitialScreen;
@JsonKey() final  ChargeStationSelectionSource source;
@override@JsonKey() final  UIFlow flow;
 final  String? loadingEvseId;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectYourChargeStationCopyWith<SelectYourChargeStation> get copyWith => _$SelectYourChargeStationCopyWithImpl<SelectYourChargeStation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectYourChargeStation&&const DeepCollectionEquality().equals(other.evseLocations, _evseLocations)&&(identical(other.directFromInitialScreen, directFromInitialScreen) || other.directFromInitialScreen == directFromInitialScreen)&&(identical(other.source, source) || other.source == source)&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.loadingEvseId, loadingEvseId) || other.loadingEvseId == loadingEvseId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_evseLocations),directFromInitialScreen,source,flow,loadingEvseId);
}

@override
String toString() {
    return 'ChargeNowState.selectYourChargeStation(evseLocations: $evseLocations, directFromInitialScreen: $directFromInitialScreen, source: $source, flow: $flow, loadingEvseId: $loadingEvseId)';
}


}

/// @nodoc
abstract mixin class $SelectYourChargeStationCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $SelectYourChargeStationCopyWith(SelectYourChargeStation value, $Res Function(SelectYourChargeStation) _then) = _$SelectYourChargeStationCopyWithImpl;
@override @useResult
$Res call({
 List<StartChargingLocationMetadata> evseLocations, bool directFromInitialScreen, ChargeStationSelectionSource source, UIFlow flow, String? loadingEvseId
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SelectYourChargeStationCopyWithImpl<$Res>
    implements $SelectYourChargeStationCopyWith<$Res> {
  _$SelectYourChargeStationCopyWithImpl(this._self, this._then);

  final SelectYourChargeStation _self;
  final $Res Function(SelectYourChargeStation) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? evseLocations = null,Object? directFromInitialScreen = null,Object? source = null,Object? flow = null,Object? loadingEvseId = freezed,}) {
  return _then(SelectYourChargeStation(
null == evseLocations ? _self._evseLocations : evseLocations // ignore: cast_nullable_to_non_nullable
as List<StartChargingLocationMetadata>,null == directFromInitialScreen ? _self.directFromInitialScreen : directFromInitialScreen // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as ChargeStationSelectionSource,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,loadingEvseId: freezed == loadingEvseId ? _self.loadingEvseId : loadingEvseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChargeNowState
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


class ManualEvseIdInput implements ChargeNowState {
  const ManualEvseIdInput({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManualEvseIdInputCopyWith<ManualEvseIdInput> get copyWith => _$ManualEvseIdInputCopyWithImpl<ManualEvseIdInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualEvseIdInput&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'ChargeNowState.manualEvseIdInput(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ManualEvseIdInputCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ManualEvseIdInputCopyWith(ManualEvseIdInput value, $Res Function(ManualEvseIdInput) _then) = _$ManualEvseIdInputCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ManualEvseIdInputCopyWithImpl<$Res>
    implements $ManualEvseIdInputCopyWith<$Res> {
  _$ManualEvseIdInputCopyWithImpl(this._self, this._then);

  final ManualEvseIdInput _self;
  final $Res Function(ManualEvseIdInput) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(ManualEvseIdInput(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class ScanningQrCode implements ChargeNowState {
  const ScanningQrCode({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanningQrCodeCopyWith<ScanningQrCode> get copyWith => _$ScanningQrCodeCopyWithImpl<ScanningQrCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanningQrCode&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'ChargeNowState.scanningQrCode(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ScanningQrCodeCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ScanningQrCodeCopyWith(ScanningQrCode value, $Res Function(ScanningQrCode) _then) = _$ScanningQrCodeCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ScanningQrCodeCopyWithImpl<$Res>
    implements $ScanningQrCodeCopyWith<$Res> {
  _$ScanningQrCodeCopyWithImpl(this._self, this._then);

  final ScanningQrCode _self;
  final $Res Function(ScanningQrCode) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(ScanningQrCode(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class StartChargingSession implements ChargeNowState {
  const StartChargingSession(this.chargingStartMetadata, this.cards, this.selectedCard, this.preAuthLimits, {this.flow = const UIFlow.established()});
  

 final  StartChargingLocationMetadata chargingStartMetadata;
 final  UnifiedPaymentCards cards;
 final  UnifiedPaymentCard? selectedCard;
 final  PreauthLimitsModel preAuthLimits;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartChargingSessionCopyWith<StartChargingSession> get copyWith => _$StartChargingSessionCopyWithImpl<StartChargingSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StartChargingSession&&(identical(other.chargingStartMetadata, chargingStartMetadata) || other.chargingStartMetadata == chargingStartMetadata)&&(identical(other.cards, cards) || other.cards == cards)&&(identical(other.selectedCard, selectedCard) || other.selectedCard == selectedCard)&&(identical(other.preAuthLimits, preAuthLimits) || other.preAuthLimits == preAuthLimits)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chargingStartMetadata,cards,selectedCard,preAuthLimits,flow);
}

@override
String toString() {
    return 'ChargeNowState.startChargingSession(chargingStartMetadata: $chargingStartMetadata, cards: $cards, selectedCard: $selectedCard, preAuthLimits: $preAuthLimits, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $StartChargingSessionCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $StartChargingSessionCopyWith(StartChargingSession value, $Res Function(StartChargingSession) _then) = _$StartChargingSessionCopyWithImpl;
@override @useResult
$Res call({
 StartChargingLocationMetadata chargingStartMetadata, UnifiedPaymentCards cards, UnifiedPaymentCard? selectedCard, PreauthLimitsModel preAuthLimits, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StartChargingSessionCopyWithImpl<$Res>
    implements $StartChargingSessionCopyWith<$Res> {
  _$StartChargingSessionCopyWithImpl(this._self, this._then);

  final StartChargingSession _self;
  final $Res Function(StartChargingSession) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chargingStartMetadata = null,Object? cards = null,Object? selectedCard = freezed,Object? preAuthLimits = null,Object? flow = null,}) {
  return _then(StartChargingSession(
null == chargingStartMetadata ? _self.chargingStartMetadata : chargingStartMetadata // ignore: cast_nullable_to_non_nullable
as StartChargingLocationMetadata,null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCards,freezed == selectedCard ? _self.selectedCard : selectedCard // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard?,null == preAuthLimits ? _self.preAuthLimits : preAuthLimits // ignore: cast_nullable_to_non_nullable
as PreauthLimitsModel,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class ChargeSessionStarting implements ChargeNowState {
  const ChargeSessionStarting(this.session, this.card, this.attemptedStartTime, {this.flow = const UIFlow.established()});
  

 final  ChargingSessionModel session;
 final  UnifiedPaymentCard? card;
 final  DateTime attemptedStartTime;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargeSessionStartingCopyWith<ChargeSessionStarting> get copyWith => _$ChargeSessionStartingCopyWithImpl<ChargeSessionStarting>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargeSessionStarting&&(identical(other.session, session) || other.session == session)&&(identical(other.card, card) || other.card == card)&&(identical(other.attemptedStartTime, attemptedStartTime) || other.attemptedStartTime == attemptedStartTime)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,card,attemptedStartTime,flow);
}

@override
String toString() {
    return 'ChargeNowState.chargeSessionStarting(session: $session, card: $card, attemptedStartTime: $attemptedStartTime, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ChargeSessionStartingCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ChargeSessionStartingCopyWith(ChargeSessionStarting value, $Res Function(ChargeSessionStarting) _then) = _$ChargeSessionStartingCopyWithImpl;
@override @useResult
$Res call({
 ChargingSessionModel session, UnifiedPaymentCard? card, DateTime attemptedStartTime, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ChargeSessionStartingCopyWithImpl<$Res>
    implements $ChargeSessionStartingCopyWith<$Res> {
  _$ChargeSessionStartingCopyWithImpl(this._self, this._then);

  final ChargeSessionStarting _self;
  final $Res Function(ChargeSessionStarting) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? card = freezed,Object? attemptedStartTime = null,Object? flow = null,}) {
  return _then(ChargeSessionStarting(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard?,null == attemptedStartTime ? _self.attemptedStartTime : attemptedStartTime // ignore: cast_nullable_to_non_nullable
as DateTime,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class CarIsCharging implements ChargeNowState {
  const CarIsCharging(this.session, this.card, this.currentChargingValues, {this.flow = const UIFlow.established()});
  

 final  ChargingSessionModel session;
 final  UnifiedPaymentCard? card;
 final  CurrentChargingValues? currentChargingValues;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarIsChargingCopyWith<CarIsCharging> get copyWith => _$CarIsChargingCopyWithImpl<CarIsCharging>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CarIsCharging&&(identical(other.session, session) || other.session == session)&&(identical(other.card, card) || other.card == card)&&(identical(other.currentChargingValues, currentChargingValues) || other.currentChargingValues == currentChargingValues)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,card,currentChargingValues,flow);
}

@override
String toString() {
    return 'ChargeNowState.carIsCharging(session: $session, card: $card, currentChargingValues: $currentChargingValues, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $CarIsChargingCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $CarIsChargingCopyWith(CarIsCharging value, $Res Function(CarIsCharging) _then) = _$CarIsChargingCopyWithImpl;
@override @useResult
$Res call({
 ChargingSessionModel session, UnifiedPaymentCard? card, CurrentChargingValues? currentChargingValues, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$CarIsChargingCopyWithImpl<$Res>
    implements $CarIsChargingCopyWith<$Res> {
  _$CarIsChargingCopyWithImpl(this._self, this._then);

  final CarIsCharging _self;
  final $Res Function(CarIsCharging) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? card = freezed,Object? currentChargingValues = freezed,Object? flow = null,}) {
  return _then(CarIsCharging(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard?,freezed == currentChargingValues ? _self.currentChargingValues : currentChargingValues // ignore: cast_nullable_to_non_nullable
as CurrentChargingValues?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class ChargeSessionStopping implements ChargeNowState {
  const ChargeSessionStopping(this.session, this.card, {this.flow = const UIFlow.established()});
  

 final  ChargingSessionModel session;
 final  UnifiedPaymentCard? card;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargeSessionStoppingCopyWith<ChargeSessionStopping> get copyWith => _$ChargeSessionStoppingCopyWithImpl<ChargeSessionStopping>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargeSessionStopping&&(identical(other.session, session) || other.session == session)&&(identical(other.card, card) || other.card == card)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,card,flow);
}

@override
String toString() {
    return 'ChargeNowState.chargeSessionStopping(session: $session, card: $card, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ChargeSessionStoppingCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ChargeSessionStoppingCopyWith(ChargeSessionStopping value, $Res Function(ChargeSessionStopping) _then) = _$ChargeSessionStoppingCopyWithImpl;
@override @useResult
$Res call({
 ChargingSessionModel session, UnifiedPaymentCard? card, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ChargeSessionStoppingCopyWithImpl<$Res>
    implements $ChargeSessionStoppingCopyWith<$Res> {
  _$ChargeSessionStoppingCopyWithImpl(this._self, this._then);

  final ChargeSessionStopping _self;
  final $Res Function(ChargeSessionStopping) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? card = freezed,Object? flow = null,}) {
  return _then(ChargeSessionStopping(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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


class ChargeSessionEnded implements ChargeNowState {
  const ChargeSessionEnded(this.session, this.card, {this.flow = const UIFlow.established()});
  

 final  ChargingSessionModel session;
 final  UnifiedPaymentCard? card;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargeSessionEndedCopyWith<ChargeSessionEnded> get copyWith => _$ChargeSessionEndedCopyWithImpl<ChargeSessionEnded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargeSessionEnded&&(identical(other.session, session) || other.session == session)&&(identical(other.card, card) || other.card == card)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session,card,flow);
}

@override
String toString() {
    return 'ChargeNowState.chargeSessionEnded(session: $session, card: $card, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ChargeSessionEndedCopyWith<$Res> implements $ChargeNowStateCopyWith<$Res> {
  factory $ChargeSessionEndedCopyWith(ChargeSessionEnded value, $Res Function(ChargeSessionEnded) _then) = _$ChargeSessionEndedCopyWithImpl;
@override @useResult
$Res call({
 ChargingSessionModel session, UnifiedPaymentCard? card, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ChargeSessionEndedCopyWithImpl<$Res>
    implements $ChargeSessionEndedCopyWith<$Res> {
  _$ChargeSessionEndedCopyWithImpl(this._self, this._then);

  final ChargeSessionEnded _self;
  final $Res Function(ChargeSessionEnded) _then;

/// Create a copy of ChargeNowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? card = freezed,Object? flow = null,}) {
  return _then(ChargeSessionEnded(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of ChargeNowState
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
mixin _$ChargeNowEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargeNowEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent()';
}


}

/// @nodoc
class $ChargeNowEventCopyWith<$Res>  {
$ChargeNowEventCopyWith(ChargeNowEvent _, $Res Function(ChargeNowEvent) __);
}


/// Adds pattern-matching-related methods to [ChargeNowEvent].
extension ChargeNowEventPatterns on ChargeNowEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CheckChargingStatus value)?  checkChargingStatus,TResult Function( ReceivedLocation value)?  receivedLocation,TResult Function( ShowMoreChargingStationsTapped value)?  showMoreChargingStationsTapped,TResult Function( ManualEvseIdInputTapped value)?  manualEvseIdInputTapped,TResult Function( ScanQrCodeTapped value)?  scanQrCodeTapped,TResult Function( ManualEvseIdSubmitted value)?  manualEvseIdSubmitted,TResult Function( InvalidQrCode value)?  invalidQrCode,TResult Function( SelectChargingStation value)?  selectChargingStation,TResult Function( ChargingStationSelected value)?  chargingStationSelected,TResult Function( ReloadPaymentCards value)?  reloadPaymentCards,TResult Function( SelectNewPaymentCard value)?  selectNewPaymentCard,TResult Function( StartCharging value)?  startCharging,TResult Function( CancelCharging value)?  cancelStartCharge,TResult Function( StopCharging value)?  stopCharging,TResult Function( BackButtonTapped value)?  backButtonTapped,TResult Function( ModalFlowDismissed value)?  modalFlowDismissed,TResult Function( ChargingStationSelectedFromMap value)?  chargingStationSelectedFromMap,TResult Function( ChargingLoggedOut value)?  loggedOut,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CheckChargingStatus() when checkChargingStatus != null:
return checkChargingStatus(_that);case ReceivedLocation() when receivedLocation != null:
return receivedLocation(_that);case ShowMoreChargingStationsTapped() when showMoreChargingStationsTapped != null:
return showMoreChargingStationsTapped(_that);case ManualEvseIdInputTapped() when manualEvseIdInputTapped != null:
return manualEvseIdInputTapped(_that);case ScanQrCodeTapped() when scanQrCodeTapped != null:
return scanQrCodeTapped(_that);case ManualEvseIdSubmitted() when manualEvseIdSubmitted != null:
return manualEvseIdSubmitted(_that);case InvalidQrCode() when invalidQrCode != null:
return invalidQrCode(_that);case SelectChargingStation() when selectChargingStation != null:
return selectChargingStation(_that);case ChargingStationSelected() when chargingStationSelected != null:
return chargingStationSelected(_that);case ReloadPaymentCards() when reloadPaymentCards != null:
return reloadPaymentCards(_that);case SelectNewPaymentCard() when selectNewPaymentCard != null:
return selectNewPaymentCard(_that);case StartCharging() when startCharging != null:
return startCharging(_that);case CancelCharging() when cancelStartCharge != null:
return cancelStartCharge(_that);case StopCharging() when stopCharging != null:
return stopCharging(_that);case BackButtonTapped() when backButtonTapped != null:
return backButtonTapped(_that);case ModalFlowDismissed() when modalFlowDismissed != null:
return modalFlowDismissed(_that);case ChargingStationSelectedFromMap() when chargingStationSelectedFromMap != null:
return chargingStationSelectedFromMap(_that);case ChargingLoggedOut() when loggedOut != null:
return loggedOut(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CheckChargingStatus value)  checkChargingStatus,required TResult Function( ReceivedLocation value)  receivedLocation,required TResult Function( ShowMoreChargingStationsTapped value)  showMoreChargingStationsTapped,required TResult Function( ManualEvseIdInputTapped value)  manualEvseIdInputTapped,required TResult Function( ScanQrCodeTapped value)  scanQrCodeTapped,required TResult Function( ManualEvseIdSubmitted value)  manualEvseIdSubmitted,required TResult Function( InvalidQrCode value)  invalidQrCode,required TResult Function( SelectChargingStation value)  selectChargingStation,required TResult Function( ChargingStationSelected value)  chargingStationSelected,required TResult Function( ReloadPaymentCards value)  reloadPaymentCards,required TResult Function( SelectNewPaymentCard value)  selectNewPaymentCard,required TResult Function( StartCharging value)  startCharging,required TResult Function( CancelCharging value)  cancelStartCharge,required TResult Function( StopCharging value)  stopCharging,required TResult Function( BackButtonTapped value)  backButtonTapped,required TResult Function( ModalFlowDismissed value)  modalFlowDismissed,required TResult Function( ChargingStationSelectedFromMap value)  chargingStationSelectedFromMap,required TResult Function( ChargingLoggedOut value)  loggedOut,}){
final _that = this;
switch (_that) {
case CheckChargingStatus():
return checkChargingStatus(_that);case ReceivedLocation():
return receivedLocation(_that);case ShowMoreChargingStationsTapped():
return showMoreChargingStationsTapped(_that);case ManualEvseIdInputTapped():
return manualEvseIdInputTapped(_that);case ScanQrCodeTapped():
return scanQrCodeTapped(_that);case ManualEvseIdSubmitted():
return manualEvseIdSubmitted(_that);case InvalidQrCode():
return invalidQrCode(_that);case SelectChargingStation():
return selectChargingStation(_that);case ChargingStationSelected():
return chargingStationSelected(_that);case ReloadPaymentCards():
return reloadPaymentCards(_that);case SelectNewPaymentCard():
return selectNewPaymentCard(_that);case StartCharging():
return startCharging(_that);case CancelCharging():
return cancelStartCharge(_that);case StopCharging():
return stopCharging(_that);case BackButtonTapped():
return backButtonTapped(_that);case ModalFlowDismissed():
return modalFlowDismissed(_that);case ChargingStationSelectedFromMap():
return chargingStationSelectedFromMap(_that);case ChargingLoggedOut():
return loggedOut(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CheckChargingStatus value)?  checkChargingStatus,TResult? Function( ReceivedLocation value)?  receivedLocation,TResult? Function( ShowMoreChargingStationsTapped value)?  showMoreChargingStationsTapped,TResult? Function( ManualEvseIdInputTapped value)?  manualEvseIdInputTapped,TResult? Function( ScanQrCodeTapped value)?  scanQrCodeTapped,TResult? Function( ManualEvseIdSubmitted value)?  manualEvseIdSubmitted,TResult? Function( InvalidQrCode value)?  invalidQrCode,TResult? Function( SelectChargingStation value)?  selectChargingStation,TResult? Function( ChargingStationSelected value)?  chargingStationSelected,TResult? Function( ReloadPaymentCards value)?  reloadPaymentCards,TResult? Function( SelectNewPaymentCard value)?  selectNewPaymentCard,TResult? Function( StartCharging value)?  startCharging,TResult? Function( CancelCharging value)?  cancelStartCharge,TResult? Function( StopCharging value)?  stopCharging,TResult? Function( BackButtonTapped value)?  backButtonTapped,TResult? Function( ModalFlowDismissed value)?  modalFlowDismissed,TResult? Function( ChargingStationSelectedFromMap value)?  chargingStationSelectedFromMap,TResult? Function( ChargingLoggedOut value)?  loggedOut,}){
final _that = this;
switch (_that) {
case CheckChargingStatus() when checkChargingStatus != null:
return checkChargingStatus(_that);case ReceivedLocation() when receivedLocation != null:
return receivedLocation(_that);case ShowMoreChargingStationsTapped() when showMoreChargingStationsTapped != null:
return showMoreChargingStationsTapped(_that);case ManualEvseIdInputTapped() when manualEvseIdInputTapped != null:
return manualEvseIdInputTapped(_that);case ScanQrCodeTapped() when scanQrCodeTapped != null:
return scanQrCodeTapped(_that);case ManualEvseIdSubmitted() when manualEvseIdSubmitted != null:
return manualEvseIdSubmitted(_that);case InvalidQrCode() when invalidQrCode != null:
return invalidQrCode(_that);case SelectChargingStation() when selectChargingStation != null:
return selectChargingStation(_that);case ChargingStationSelected() when chargingStationSelected != null:
return chargingStationSelected(_that);case ReloadPaymentCards() when reloadPaymentCards != null:
return reloadPaymentCards(_that);case SelectNewPaymentCard() when selectNewPaymentCard != null:
return selectNewPaymentCard(_that);case StartCharging() when startCharging != null:
return startCharging(_that);case CancelCharging() when cancelStartCharge != null:
return cancelStartCharge(_that);case StopCharging() when stopCharging != null:
return stopCharging(_that);case BackButtonTapped() when backButtonTapped != null:
return backButtonTapped(_that);case ModalFlowDismissed() when modalFlowDismissed != null:
return modalFlowDismissed(_that);case ChargingStationSelectedFromMap() when chargingStationSelectedFromMap != null:
return chargingStationSelectedFromMap(_that);case ChargingLoggedOut() when loggedOut != null:
return loggedOut(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checkChargingStatus,TResult Function( UserLocation? location,  List<String> partyIds)?  receivedLocation,TResult Function( UserLocation? location,  bool directFromInitialScreen,  List<String> partyIds)?  showMoreChargingStationsTapped,TResult Function()?  manualEvseIdInputTapped,TResult Function()?  scanQrCodeTapped,TResult Function( String evseId,  List<String> partyIds,  UserLocation? userLocation)?  manualEvseIdSubmitted,TResult Function( String errorMessage)?  invalidQrCode,TResult Function( ChargingConnector? connector)?  selectChargingStation,TResult Function( StartChargingLocationMetadata location)?  chargingStationSelected,TResult Function()?  reloadPaymentCards,TResult Function( UnifiedPaymentCard newCard)?  selectNewPaymentCard,TResult Function( StartChargingLocationMetadata startChargingMetadata,  UnifiedPaymentCard paymentCard,  PreauthLimitsModel preauthLimits)?  startCharging,TResult Function( ChargingSessionModel chargingSession)?  cancelStartCharge,TResult Function( ChargingSessionModel chargingSession)?  stopCharging,TResult Function()?  backButtonTapped,TResult Function()?  modalFlowDismissed,TResult Function( MapLocationV2 location,  Evse evse,  Connector connector)?  chargingStationSelectedFromMap,TResult Function()?  loggedOut,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CheckChargingStatus() when checkChargingStatus != null:
return checkChargingStatus();case ReceivedLocation() when receivedLocation != null:
return receivedLocation(_that.location,_that.partyIds);case ShowMoreChargingStationsTapped() when showMoreChargingStationsTapped != null:
return showMoreChargingStationsTapped(_that.location,_that.directFromInitialScreen,_that.partyIds);case ManualEvseIdInputTapped() when manualEvseIdInputTapped != null:
return manualEvseIdInputTapped();case ScanQrCodeTapped() when scanQrCodeTapped != null:
return scanQrCodeTapped();case ManualEvseIdSubmitted() when manualEvseIdSubmitted != null:
return manualEvseIdSubmitted(_that.evseId,_that.partyIds,_that.userLocation);case InvalidQrCode() when invalidQrCode != null:
return invalidQrCode(_that.errorMessage);case SelectChargingStation() when selectChargingStation != null:
return selectChargingStation(_that.connector);case ChargingStationSelected() when chargingStationSelected != null:
return chargingStationSelected(_that.location);case ReloadPaymentCards() when reloadPaymentCards != null:
return reloadPaymentCards();case SelectNewPaymentCard() when selectNewPaymentCard != null:
return selectNewPaymentCard(_that.newCard);case StartCharging() when startCharging != null:
return startCharging(_that.startChargingMetadata,_that.paymentCard,_that.preauthLimits);case CancelCharging() when cancelStartCharge != null:
return cancelStartCharge(_that.chargingSession);case StopCharging() when stopCharging != null:
return stopCharging(_that.chargingSession);case BackButtonTapped() when backButtonTapped != null:
return backButtonTapped();case ModalFlowDismissed() when modalFlowDismissed != null:
return modalFlowDismissed();case ChargingStationSelectedFromMap() when chargingStationSelectedFromMap != null:
return chargingStationSelectedFromMap(_that.location,_that.evse,_that.connector);case ChargingLoggedOut() when loggedOut != null:
return loggedOut();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checkChargingStatus,required TResult Function( UserLocation? location,  List<String> partyIds)  receivedLocation,required TResult Function( UserLocation? location,  bool directFromInitialScreen,  List<String> partyIds)  showMoreChargingStationsTapped,required TResult Function()  manualEvseIdInputTapped,required TResult Function()  scanQrCodeTapped,required TResult Function( String evseId,  List<String> partyIds,  UserLocation? userLocation)  manualEvseIdSubmitted,required TResult Function( String errorMessage)  invalidQrCode,required TResult Function( ChargingConnector? connector)  selectChargingStation,required TResult Function( StartChargingLocationMetadata location)  chargingStationSelected,required TResult Function()  reloadPaymentCards,required TResult Function( UnifiedPaymentCard newCard)  selectNewPaymentCard,required TResult Function( StartChargingLocationMetadata startChargingMetadata,  UnifiedPaymentCard paymentCard,  PreauthLimitsModel preauthLimits)  startCharging,required TResult Function( ChargingSessionModel chargingSession)  cancelStartCharge,required TResult Function( ChargingSessionModel chargingSession)  stopCharging,required TResult Function()  backButtonTapped,required TResult Function()  modalFlowDismissed,required TResult Function( MapLocationV2 location,  Evse evse,  Connector connector)  chargingStationSelectedFromMap,required TResult Function()  loggedOut,}) {final _that = this;
switch (_that) {
case CheckChargingStatus():
return checkChargingStatus();case ReceivedLocation():
return receivedLocation(_that.location,_that.partyIds);case ShowMoreChargingStationsTapped():
return showMoreChargingStationsTapped(_that.location,_that.directFromInitialScreen,_that.partyIds);case ManualEvseIdInputTapped():
return manualEvseIdInputTapped();case ScanQrCodeTapped():
return scanQrCodeTapped();case ManualEvseIdSubmitted():
return manualEvseIdSubmitted(_that.evseId,_that.partyIds,_that.userLocation);case InvalidQrCode():
return invalidQrCode(_that.errorMessage);case SelectChargingStation():
return selectChargingStation(_that.connector);case ChargingStationSelected():
return chargingStationSelected(_that.location);case ReloadPaymentCards():
return reloadPaymentCards();case SelectNewPaymentCard():
return selectNewPaymentCard(_that.newCard);case StartCharging():
return startCharging(_that.startChargingMetadata,_that.paymentCard,_that.preauthLimits);case CancelCharging():
return cancelStartCharge(_that.chargingSession);case StopCharging():
return stopCharging(_that.chargingSession);case BackButtonTapped():
return backButtonTapped();case ModalFlowDismissed():
return modalFlowDismissed();case ChargingStationSelectedFromMap():
return chargingStationSelectedFromMap(_that.location,_that.evse,_that.connector);case ChargingLoggedOut():
return loggedOut();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checkChargingStatus,TResult? Function( UserLocation? location,  List<String> partyIds)?  receivedLocation,TResult? Function( UserLocation? location,  bool directFromInitialScreen,  List<String> partyIds)?  showMoreChargingStationsTapped,TResult? Function()?  manualEvseIdInputTapped,TResult? Function()?  scanQrCodeTapped,TResult? Function( String evseId,  List<String> partyIds,  UserLocation? userLocation)?  manualEvseIdSubmitted,TResult? Function( String errorMessage)?  invalidQrCode,TResult? Function( ChargingConnector? connector)?  selectChargingStation,TResult? Function( StartChargingLocationMetadata location)?  chargingStationSelected,TResult? Function()?  reloadPaymentCards,TResult? Function( UnifiedPaymentCard newCard)?  selectNewPaymentCard,TResult? Function( StartChargingLocationMetadata startChargingMetadata,  UnifiedPaymentCard paymentCard,  PreauthLimitsModel preauthLimits)?  startCharging,TResult? Function( ChargingSessionModel chargingSession)?  cancelStartCharge,TResult? Function( ChargingSessionModel chargingSession)?  stopCharging,TResult? Function()?  backButtonTapped,TResult? Function()?  modalFlowDismissed,TResult? Function( MapLocationV2 location,  Evse evse,  Connector connector)?  chargingStationSelectedFromMap,TResult? Function()?  loggedOut,}) {final _that = this;
switch (_that) {
case CheckChargingStatus() when checkChargingStatus != null:
return checkChargingStatus();case ReceivedLocation() when receivedLocation != null:
return receivedLocation(_that.location,_that.partyIds);case ShowMoreChargingStationsTapped() when showMoreChargingStationsTapped != null:
return showMoreChargingStationsTapped(_that.location,_that.directFromInitialScreen,_that.partyIds);case ManualEvseIdInputTapped() when manualEvseIdInputTapped != null:
return manualEvseIdInputTapped();case ScanQrCodeTapped() when scanQrCodeTapped != null:
return scanQrCodeTapped();case ManualEvseIdSubmitted() when manualEvseIdSubmitted != null:
return manualEvseIdSubmitted(_that.evseId,_that.partyIds,_that.userLocation);case InvalidQrCode() when invalidQrCode != null:
return invalidQrCode(_that.errorMessage);case SelectChargingStation() when selectChargingStation != null:
return selectChargingStation(_that.connector);case ChargingStationSelected() when chargingStationSelected != null:
return chargingStationSelected(_that.location);case ReloadPaymentCards() when reloadPaymentCards != null:
return reloadPaymentCards();case SelectNewPaymentCard() when selectNewPaymentCard != null:
return selectNewPaymentCard(_that.newCard);case StartCharging() when startCharging != null:
return startCharging(_that.startChargingMetadata,_that.paymentCard,_that.preauthLimits);case CancelCharging() when cancelStartCharge != null:
return cancelStartCharge(_that.chargingSession);case StopCharging() when stopCharging != null:
return stopCharging(_that.chargingSession);case BackButtonTapped() when backButtonTapped != null:
return backButtonTapped();case ModalFlowDismissed() when modalFlowDismissed != null:
return modalFlowDismissed();case ChargingStationSelectedFromMap() when chargingStationSelectedFromMap != null:
return chargingStationSelectedFromMap(_that.location,_that.evse,_that.connector);case ChargingLoggedOut() when loggedOut != null:
return loggedOut();case _:
  return null;

}
}

}

/// @nodoc


class CheckChargingStatus implements ChargeNowEvent {
  const CheckChargingStatus();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckChargingStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.checkChargingStatus()';
}


}




/// @nodoc


class ReceivedLocation implements ChargeNowEvent {
  const ReceivedLocation(this.location,  List<String> partyIds): _partyIds = partyIds;
  

 final  UserLocation? location;
 final  List<String> _partyIds;
 List<String> get partyIds {
  if (_partyIds is EqualUnmodifiableListView) return _partyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partyIds);
}


/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivedLocationCopyWith<ReceivedLocation> get copyWith => _$ReceivedLocationCopyWithImpl<ReceivedLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivedLocation&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.partyIds, _partyIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location,const DeepCollectionEquality().hash(_partyIds));
}

@override
String toString() {
    return 'ChargeNowEvent.receivedLocation(location: $location, partyIds: $partyIds)';
}


}

/// @nodoc
abstract mixin class $ReceivedLocationCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $ReceivedLocationCopyWith(ReceivedLocation value, $Res Function(ReceivedLocation) _then) = _$ReceivedLocationCopyWithImpl;
@useResult
$Res call({
 UserLocation? location, List<String> partyIds
});




}
/// @nodoc
class _$ReceivedLocationCopyWithImpl<$Res>
    implements $ReceivedLocationCopyWith<$Res> {
  _$ReceivedLocationCopyWithImpl(this._self, this._then);

  final ReceivedLocation _self;
  final $Res Function(ReceivedLocation) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? partyIds = null,}) {
  return _then(ReceivedLocation(
freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UserLocation?,null == partyIds ? _self._partyIds : partyIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ShowMoreChargingStationsTapped implements ChargeNowEvent {
  const ShowMoreChargingStationsTapped(this.location, this.directFromInitialScreen,  List<String> partyIds): _partyIds = partyIds;
  

 final  UserLocation? location;
 final  bool directFromInitialScreen;
 final  List<String> _partyIds;
 List<String> get partyIds {
  if (_partyIds is EqualUnmodifiableListView) return _partyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partyIds);
}


/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowMoreChargingStationsTappedCopyWith<ShowMoreChargingStationsTapped> get copyWith => _$ShowMoreChargingStationsTappedCopyWithImpl<ShowMoreChargingStationsTapped>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowMoreChargingStationsTapped&&(identical(other.location, location) || other.location == location)&&(identical(other.directFromInitialScreen, directFromInitialScreen) || other.directFromInitialScreen == directFromInitialScreen)&&const DeepCollectionEquality().equals(other.partyIds, _partyIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location,directFromInitialScreen,const DeepCollectionEquality().hash(_partyIds));
}

@override
String toString() {
    return 'ChargeNowEvent.showMoreChargingStationsTapped(location: $location, directFromInitialScreen: $directFromInitialScreen, partyIds: $partyIds)';
}


}

/// @nodoc
abstract mixin class $ShowMoreChargingStationsTappedCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $ShowMoreChargingStationsTappedCopyWith(ShowMoreChargingStationsTapped value, $Res Function(ShowMoreChargingStationsTapped) _then) = _$ShowMoreChargingStationsTappedCopyWithImpl;
@useResult
$Res call({
 UserLocation? location, bool directFromInitialScreen, List<String> partyIds
});




}
/// @nodoc
class _$ShowMoreChargingStationsTappedCopyWithImpl<$Res>
    implements $ShowMoreChargingStationsTappedCopyWith<$Res> {
  _$ShowMoreChargingStationsTappedCopyWithImpl(this._self, this._then);

  final ShowMoreChargingStationsTapped _self;
  final $Res Function(ShowMoreChargingStationsTapped) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? directFromInitialScreen = null,Object? partyIds = null,}) {
  return _then(ShowMoreChargingStationsTapped(
freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as UserLocation?,null == directFromInitialScreen ? _self.directFromInitialScreen : directFromInitialScreen // ignore: cast_nullable_to_non_nullable
as bool,null == partyIds ? _self._partyIds : partyIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ManualEvseIdInputTapped implements ChargeNowEvent {
  const ManualEvseIdInputTapped();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualEvseIdInputTapped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.manualEvseIdInputTapped()';
}


}




/// @nodoc


class ScanQrCodeTapped implements ChargeNowEvent {
  const ScanQrCodeTapped();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanQrCodeTapped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.scanQrCodeTapped()';
}


}




/// @nodoc


class ManualEvseIdSubmitted implements ChargeNowEvent {
  const ManualEvseIdSubmitted(this.evseId,  List<String> partyIds, this.userLocation): _partyIds = partyIds;
  

 final  String evseId;
 final  List<String> _partyIds;
 List<String> get partyIds {
  if (_partyIds is EqualUnmodifiableListView) return _partyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_partyIds);
}

 final  UserLocation? userLocation;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManualEvseIdSubmittedCopyWith<ManualEvseIdSubmitted> get copyWith => _$ManualEvseIdSubmittedCopyWithImpl<ManualEvseIdSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ManualEvseIdSubmitted&&(identical(other.evseId, evseId) || other.evseId == evseId)&&const DeepCollectionEquality().equals(other.partyIds, _partyIds)&&(identical(other.userLocation, userLocation) || other.userLocation == userLocation));
}


@override
int get hashCode {
    return Object.hash(runtimeType,evseId,const DeepCollectionEquality().hash(_partyIds),userLocation);
}

@override
String toString() {
    return 'ChargeNowEvent.manualEvseIdSubmitted(evseId: $evseId, partyIds: $partyIds, userLocation: $userLocation)';
}


}

/// @nodoc
abstract mixin class $ManualEvseIdSubmittedCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $ManualEvseIdSubmittedCopyWith(ManualEvseIdSubmitted value, $Res Function(ManualEvseIdSubmitted) _then) = _$ManualEvseIdSubmittedCopyWithImpl;
@useResult
$Res call({
 String evseId, List<String> partyIds, UserLocation? userLocation
});




}
/// @nodoc
class _$ManualEvseIdSubmittedCopyWithImpl<$Res>
    implements $ManualEvseIdSubmittedCopyWith<$Res> {
  _$ManualEvseIdSubmittedCopyWithImpl(this._self, this._then);

  final ManualEvseIdSubmitted _self;
  final $Res Function(ManualEvseIdSubmitted) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? evseId = null,Object? partyIds = null,Object? userLocation = freezed,}) {
  return _then(ManualEvseIdSubmitted(
null == evseId ? _self.evseId : evseId // ignore: cast_nullable_to_non_nullable
as String,null == partyIds ? _self._partyIds : partyIds // ignore: cast_nullable_to_non_nullable
as List<String>,freezed == userLocation ? _self.userLocation : userLocation // ignore: cast_nullable_to_non_nullable
as UserLocation?,
  ));
}


}

/// @nodoc


class InvalidQrCode implements ChargeNowEvent {
  const InvalidQrCode(this.errorMessage);
  

 final  String errorMessage;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidQrCodeCopyWith<InvalidQrCode> get copyWith => _$InvalidQrCodeCopyWithImpl<InvalidQrCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidQrCode&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,errorMessage);
}

@override
String toString() {
    return 'ChargeNowEvent.invalidQrCode(errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $InvalidQrCodeCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $InvalidQrCodeCopyWith(InvalidQrCode value, $Res Function(InvalidQrCode) _then) = _$InvalidQrCodeCopyWithImpl;
@useResult
$Res call({
 String errorMessage
});




}
/// @nodoc
class _$InvalidQrCodeCopyWithImpl<$Res>
    implements $InvalidQrCodeCopyWith<$Res> {
  _$InvalidQrCodeCopyWithImpl(this._self, this._then);

  final InvalidQrCode _self;
  final $Res Function(InvalidQrCode) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorMessage = null,}) {
  return _then(InvalidQrCode(
null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SelectChargingStation implements ChargeNowEvent {
  const SelectChargingStation(this.connector);
  

 final  ChargingConnector? connector;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectChargingStationCopyWith<SelectChargingStation> get copyWith => _$SelectChargingStationCopyWithImpl<SelectChargingStation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectChargingStation&&(identical(other.connector, connector) || other.connector == connector));
}


@override
int get hashCode {
    return Object.hash(runtimeType,connector);
}

@override
String toString() {
    return 'ChargeNowEvent.selectChargingStation(connector: $connector)';
}


}

/// @nodoc
abstract mixin class $SelectChargingStationCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $SelectChargingStationCopyWith(SelectChargingStation value, $Res Function(SelectChargingStation) _then) = _$SelectChargingStationCopyWithImpl;
@useResult
$Res call({
 ChargingConnector? connector
});




}
/// @nodoc
class _$SelectChargingStationCopyWithImpl<$Res>
    implements $SelectChargingStationCopyWith<$Res> {
  _$SelectChargingStationCopyWithImpl(this._self, this._then);

  final SelectChargingStation _self;
  final $Res Function(SelectChargingStation) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? connector = freezed,}) {
  return _then(SelectChargingStation(
freezed == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as ChargingConnector?,
  ));
}


}

/// @nodoc


class ChargingStationSelected implements ChargeNowEvent {
  const ChargingStationSelected(this.location);
  

 final  StartChargingLocationMetadata location;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargingStationSelectedCopyWith<ChargingStationSelected> get copyWith => _$ChargingStationSelectedCopyWithImpl<ChargingStationSelected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargingStationSelected&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location);
}

@override
String toString() {
    return 'ChargeNowEvent.chargingStationSelected(location: $location)';
}


}

/// @nodoc
abstract mixin class $ChargingStationSelectedCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $ChargingStationSelectedCopyWith(ChargingStationSelected value, $Res Function(ChargingStationSelected) _then) = _$ChargingStationSelectedCopyWithImpl;
@useResult
$Res call({
 StartChargingLocationMetadata location
});




}
/// @nodoc
class _$ChargingStationSelectedCopyWithImpl<$Res>
    implements $ChargingStationSelectedCopyWith<$Res> {
  _$ChargingStationSelectedCopyWithImpl(this._self, this._then);

  final ChargingStationSelected _self;
  final $Res Function(ChargingStationSelected) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(ChargingStationSelected(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as StartChargingLocationMetadata,
  ));
}


}

/// @nodoc


class ReloadPaymentCards implements ChargeNowEvent {
  const ReloadPaymentCards();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReloadPaymentCards);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.reloadPaymentCards()';
}


}




/// @nodoc


class SelectNewPaymentCard implements ChargeNowEvent {
  const SelectNewPaymentCard(this.newCard);
  

 final  UnifiedPaymentCard newCard;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectNewPaymentCardCopyWith<SelectNewPaymentCard> get copyWith => _$SelectNewPaymentCardCopyWithImpl<SelectNewPaymentCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectNewPaymentCard&&(identical(other.newCard, newCard) || other.newCard == newCard));
}


@override
int get hashCode {
    return Object.hash(runtimeType,newCard);
}

@override
String toString() {
    return 'ChargeNowEvent.selectNewPaymentCard(newCard: $newCard)';
}


}

/// @nodoc
abstract mixin class $SelectNewPaymentCardCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $SelectNewPaymentCardCopyWith(SelectNewPaymentCard value, $Res Function(SelectNewPaymentCard) _then) = _$SelectNewPaymentCardCopyWithImpl;
@useResult
$Res call({
 UnifiedPaymentCard newCard
});




}
/// @nodoc
class _$SelectNewPaymentCardCopyWithImpl<$Res>
    implements $SelectNewPaymentCardCopyWith<$Res> {
  _$SelectNewPaymentCardCopyWithImpl(this._self, this._then);

  final SelectNewPaymentCard _self;
  final $Res Function(SelectNewPaymentCard) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? newCard = null,}) {
  return _then(SelectNewPaymentCard(
null == newCard ? _self.newCard : newCard // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard,
  ));
}


}

/// @nodoc


class StartCharging implements ChargeNowEvent {
  const StartCharging(this.startChargingMetadata, this.paymentCard, this.preauthLimits);
  

 final  StartChargingLocationMetadata startChargingMetadata;
 final  UnifiedPaymentCard paymentCard;
 final  PreauthLimitsModel preauthLimits;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartChargingCopyWith<StartCharging> get copyWith => _$StartChargingCopyWithImpl<StartCharging>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StartCharging&&(identical(other.startChargingMetadata, startChargingMetadata) || other.startChargingMetadata == startChargingMetadata)&&(identical(other.paymentCard, paymentCard) || other.paymentCard == paymentCard)&&(identical(other.preauthLimits, preauthLimits) || other.preauthLimits == preauthLimits));
}


@override
int get hashCode {
    return Object.hash(runtimeType,startChargingMetadata,paymentCard,preauthLimits);
}

@override
String toString() {
    return 'ChargeNowEvent.startCharging(startChargingMetadata: $startChargingMetadata, paymentCard: $paymentCard, preauthLimits: $preauthLimits)';
}


}

/// @nodoc
abstract mixin class $StartChargingCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $StartChargingCopyWith(StartCharging value, $Res Function(StartCharging) _then) = _$StartChargingCopyWithImpl;
@useResult
$Res call({
 StartChargingLocationMetadata startChargingMetadata, UnifiedPaymentCard paymentCard, PreauthLimitsModel preauthLimits
});




}
/// @nodoc
class _$StartChargingCopyWithImpl<$Res>
    implements $StartChargingCopyWith<$Res> {
  _$StartChargingCopyWithImpl(this._self, this._then);

  final StartCharging _self;
  final $Res Function(StartCharging) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startChargingMetadata = null,Object? paymentCard = null,Object? preauthLimits = null,}) {
  return _then(StartCharging(
null == startChargingMetadata ? _self.startChargingMetadata : startChargingMetadata // ignore: cast_nullable_to_non_nullable
as StartChargingLocationMetadata,null == paymentCard ? _self.paymentCard : paymentCard // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCard,null == preauthLimits ? _self.preauthLimits : preauthLimits // ignore: cast_nullable_to_non_nullable
as PreauthLimitsModel,
  ));
}


}

/// @nodoc


class CancelCharging implements ChargeNowEvent {
  const CancelCharging(this.chargingSession);
  

 final  ChargingSessionModel chargingSession;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelChargingCopyWith<CancelCharging> get copyWith => _$CancelChargingCopyWithImpl<CancelCharging>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelCharging&&(identical(other.chargingSession, chargingSession) || other.chargingSession == chargingSession));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chargingSession);
}

@override
String toString() {
    return 'ChargeNowEvent.cancelStartCharge(chargingSession: $chargingSession)';
}


}

/// @nodoc
abstract mixin class $CancelChargingCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $CancelChargingCopyWith(CancelCharging value, $Res Function(CancelCharging) _then) = _$CancelChargingCopyWithImpl;
@useResult
$Res call({
 ChargingSessionModel chargingSession
});




}
/// @nodoc
class _$CancelChargingCopyWithImpl<$Res>
    implements $CancelChargingCopyWith<$Res> {
  _$CancelChargingCopyWithImpl(this._self, this._then);

  final CancelCharging _self;
  final $Res Function(CancelCharging) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chargingSession = null,}) {
  return _then(CancelCharging(
null == chargingSession ? _self.chargingSession : chargingSession // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,
  ));
}


}

/// @nodoc


class StopCharging implements ChargeNowEvent {
  const StopCharging(this.chargingSession);
  

 final  ChargingSessionModel chargingSession;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StopChargingCopyWith<StopCharging> get copyWith => _$StopChargingCopyWithImpl<StopCharging>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StopCharging&&(identical(other.chargingSession, chargingSession) || other.chargingSession == chargingSession));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chargingSession);
}

@override
String toString() {
    return 'ChargeNowEvent.stopCharging(chargingSession: $chargingSession)';
}


}

/// @nodoc
abstract mixin class $StopChargingCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $StopChargingCopyWith(StopCharging value, $Res Function(StopCharging) _then) = _$StopChargingCopyWithImpl;
@useResult
$Res call({
 ChargingSessionModel chargingSession
});




}
/// @nodoc
class _$StopChargingCopyWithImpl<$Res>
    implements $StopChargingCopyWith<$Res> {
  _$StopChargingCopyWithImpl(this._self, this._then);

  final StopCharging _self;
  final $Res Function(StopCharging) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chargingSession = null,}) {
  return _then(StopCharging(
null == chargingSession ? _self.chargingSession : chargingSession // ignore: cast_nullable_to_non_nullable
as ChargingSessionModel,
  ));
}


}

/// @nodoc


class BackButtonTapped implements ChargeNowEvent {
  const BackButtonTapped();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BackButtonTapped);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.backButtonTapped()';
}


}




/// @nodoc


class ModalFlowDismissed implements ChargeNowEvent {
  const ModalFlowDismissed();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ModalFlowDismissed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.modalFlowDismissed()';
}


}




/// @nodoc


class ChargingStationSelectedFromMap implements ChargeNowEvent {
  const ChargingStationSelectedFromMap(this.location, this.evse, this.connector);
  

 final  MapLocationV2 location;
 final  Evse evse;
 final  Connector connector;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChargingStationSelectedFromMapCopyWith<ChargingStationSelectedFromMap> get copyWith => _$ChargingStationSelectedFromMapCopyWithImpl<ChargingStationSelectedFromMap>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargingStationSelectedFromMap&&(identical(other.location, location) || other.location == location)&&(identical(other.evse, evse) || other.evse == evse)&&(identical(other.connector, connector) || other.connector == connector));
}


@override
int get hashCode {
    return Object.hash(runtimeType,location,evse,connector);
}

@override
String toString() {
    return 'ChargeNowEvent.chargingStationSelectedFromMap(location: $location, evse: $evse, connector: $connector)';
}


}

/// @nodoc
abstract mixin class $ChargingStationSelectedFromMapCopyWith<$Res> implements $ChargeNowEventCopyWith<$Res> {
  factory $ChargingStationSelectedFromMapCopyWith(ChargingStationSelectedFromMap value, $Res Function(ChargingStationSelectedFromMap) _then) = _$ChargingStationSelectedFromMapCopyWithImpl;
@useResult
$Res call({
 MapLocationV2 location, Evse evse, Connector connector
});




}
/// @nodoc
class _$ChargingStationSelectedFromMapCopyWithImpl<$Res>
    implements $ChargingStationSelectedFromMapCopyWith<$Res> {
  _$ChargingStationSelectedFromMapCopyWithImpl(this._self, this._then);

  final ChargingStationSelectedFromMap _self;
  final $Res Function(ChargingStationSelectedFromMap) _then;

/// Create a copy of ChargeNowEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,Object? evse = null,Object? connector = null,}) {
  return _then(ChargingStationSelectedFromMap(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as MapLocationV2,null == evse ? _self.evse : evse // ignore: cast_nullable_to_non_nullable
as Evse,null == connector ? _self.connector : connector // ignore: cast_nullable_to_non_nullable
as Connector,
  ));
}


}

/// @nodoc


class ChargingLoggedOut implements ChargeNowEvent {
  const ChargingLoggedOut();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChargingLoggedOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChargeNowEvent.loggedOut()';
}


}




// dart format on
