// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessions_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionsState {

 List<SessionModel>? get activeSessions; List<SessionModel>? get allSessions; int? get selectedYear; int? get selectedMonth; String? get selectedChargeCardTokenId; String? get selectedPaymentMethod; SessionStats? get stats; UIFlow get flow;
/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionsStateCopyWith<SessionsState> get copyWith => _$SessionsStateCopyWithImpl<SessionsState>(this as SessionsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionsState&&const DeepCollectionEquality().equals(other.activeSessions, _this.activeSessions)&&const DeepCollectionEquality().equals(other.allSessions, _this.allSessions)&&(identical(other.selectedYear, _this.selectedYear) || other.selectedYear == _this.selectedYear)&&(identical(other.selectedMonth, _this.selectedMonth) || other.selectedMonth == _this.selectedMonth)&&(identical(other.selectedChargeCardTokenId, _this.selectedChargeCardTokenId) || other.selectedChargeCardTokenId == _this.selectedChargeCardTokenId)&&(identical(other.selectedPaymentMethod, _this.selectedPaymentMethod) || other.selectedPaymentMethod == _this.selectedPaymentMethod)&&(identical(other.stats, _this.stats) || other.stats == _this.stats)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as SessionsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.activeSessions),const DeepCollectionEquality().hash(_this.allSessions),_this.selectedYear,_this.selectedMonth,_this.selectedChargeCardTokenId,_this.selectedPaymentMethod,_this.stats,_this.flow);
}

@override
String toString() {
  final _this = this as SessionsState;
  return 'SessionsState(activeSessions: ${_this.activeSessions}, allSessions: ${_this.allSessions}, selectedYear: ${_this.selectedYear}, selectedMonth: ${_this.selectedMonth}, selectedChargeCardTokenId: ${_this.selectedChargeCardTokenId}, selectedPaymentMethod: ${_this.selectedPaymentMethod}, stats: ${_this.stats}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $SessionsStateCopyWith<$Res>  {
  factory $SessionsStateCopyWith(SessionsState value, $Res Function(SessionsState) _then) = _$SessionsStateCopyWithImpl;
@useResult
$Res call({
 List<SessionModel>? activeSessions, List<SessionModel>? allSessions, int? selectedYear, int? selectedMonth, String? selectedChargeCardTokenId, String? selectedPaymentMethod, SessionStats? stats, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SessionsStateCopyWithImpl<$Res>
    implements $SessionsStateCopyWith<$Res> {
  _$SessionsStateCopyWithImpl(this._self, this._then);

  final SessionsState _self;
  final $Res Function(SessionsState) _then;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeSessions = freezed,Object? allSessions = freezed,Object? selectedYear = freezed,Object? selectedMonth = freezed,Object? selectedChargeCardTokenId = freezed,Object? selectedPaymentMethod = freezed,Object? stats = freezed,Object? flow = null,}) {
  return _then(SessionsState(
activeSessions: freezed == activeSessions ? _self.activeSessions : activeSessions // ignore: cast_nullable_to_non_nullable
as List<SessionModel>?,allSessions: freezed == allSessions ? _self.allSessions : allSessions // ignore: cast_nullable_to_non_nullable
as List<SessionModel>?,selectedYear: freezed == selectedYear ? _self.selectedYear : selectedYear // ignore: cast_nullable_to_non_nullable
as int?,selectedMonth: freezed == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as int?,selectedChargeCardTokenId: freezed == selectedChargeCardTokenId ? _self.selectedChargeCardTokenId : selectedChargeCardTokenId // ignore: cast_nullable_to_non_nullable
as String?,selectedPaymentMethod: freezed == selectedPaymentMethod ? _self.selectedPaymentMethod : selectedPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SessionStats?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionsState].
extension SessionsStatePatterns on SessionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( Sessions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case Sessions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( Sessions value)  $default,){
final _that = this;
switch (_that) {
case Sessions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( Sessions value)?  $default,){
final _that = this;
switch (_that) {
case Sessions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SessionModel>? activeSessions,  List<SessionModel>? allSessions,  int? selectedYear,  int? selectedMonth,  String? selectedChargeCardTokenId,  String? selectedPaymentMethod,  SessionStats? stats,  UIFlow flow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case Sessions() when $default != null:
return $default(_that.activeSessions,_that.allSessions,_that.selectedYear,_that.selectedMonth,_that.selectedChargeCardTokenId,_that.selectedPaymentMethod,_that.stats,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SessionModel>? activeSessions,  List<SessionModel>? allSessions,  int? selectedYear,  int? selectedMonth,  String? selectedChargeCardTokenId,  String? selectedPaymentMethod,  SessionStats? stats,  UIFlow flow)  $default,) {final _that = this;
switch (_that) {
case Sessions():
return $default(_that.activeSessions,_that.allSessions,_that.selectedYear,_that.selectedMonth,_that.selectedChargeCardTokenId,_that.selectedPaymentMethod,_that.stats,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SessionModel>? activeSessions,  List<SessionModel>? allSessions,  int? selectedYear,  int? selectedMonth,  String? selectedChargeCardTokenId,  String? selectedPaymentMethod,  SessionStats? stats,  UIFlow flow)?  $default,) {final _that = this;
switch (_that) {
case Sessions() when $default != null:
return $default(_that.activeSessions,_that.allSessions,_that.selectedYear,_that.selectedMonth,_that.selectedChargeCardTokenId,_that.selectedPaymentMethod,_that.stats,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Sessions extends SessionsState {
  const Sessions({ List<SessionModel>? activeSessions,  List<SessionModel>? allSessions, this.selectedYear, this.selectedMonth, this.selectedChargeCardTokenId, this.selectedPaymentMethod, this.stats, this.flow = const UIFlow.established()}): _activeSessions = activeSessions,_allSessions = allSessions,super._();
  

 final  List<SessionModel>? _activeSessions;
@override List<SessionModel>? get activeSessions {
  final value = _activeSessions;
  if (value == null) return null;
  if (_activeSessions is EqualUnmodifiableListView) return _activeSessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<SessionModel>? _allSessions;
@override List<SessionModel>? get allSessions {
  final value = _allSessions;
  if (value == null) return null;
  if (_allSessions is EqualUnmodifiableListView) return _allSessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? selectedYear;
@override final  int? selectedMonth;
@override final  String? selectedChargeCardTokenId;
@override final  String? selectedPaymentMethod;
@override final  SessionStats? stats;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionsCopyWith<Sessions> get copyWith => _$SessionsCopyWithImpl<Sessions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Sessions&&const DeepCollectionEquality().equals(other.activeSessions, _activeSessions)&&const DeepCollectionEquality().equals(other.allSessions, _allSessions)&&(identical(other.selectedYear, selectedYear) || other.selectedYear == selectedYear)&&(identical(other.selectedMonth, selectedMonth) || other.selectedMonth == selectedMonth)&&(identical(other.selectedChargeCardTokenId, selectedChargeCardTokenId) || other.selectedChargeCardTokenId == selectedChargeCardTokenId)&&(identical(other.selectedPaymentMethod, selectedPaymentMethod) || other.selectedPaymentMethod == selectedPaymentMethod)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_activeSessions),const DeepCollectionEquality().hash(_allSessions),selectedYear,selectedMonth,selectedChargeCardTokenId,selectedPaymentMethod,stats,flow);
}

@override
String toString() {
    return 'SessionsState(activeSessions: $activeSessions, allSessions: $allSessions, selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedChargeCardTokenId: $selectedChargeCardTokenId, selectedPaymentMethod: $selectedPaymentMethod, stats: $stats, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $SessionsCopyWith<$Res> implements $SessionsStateCopyWith<$Res> {
  factory $SessionsCopyWith(Sessions value, $Res Function(Sessions) _then) = _$SessionsCopyWithImpl;
@override @useResult
$Res call({
 List<SessionModel>? activeSessions, List<SessionModel>? allSessions, int? selectedYear, int? selectedMonth, String? selectedChargeCardTokenId, String? selectedPaymentMethod, SessionStats? stats, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SessionsCopyWithImpl<$Res>
    implements $SessionsCopyWith<$Res> {
  _$SessionsCopyWithImpl(this._self, this._then);

  final Sessions _self;
  final $Res Function(Sessions) _then;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeSessions = freezed,Object? allSessions = freezed,Object? selectedYear = freezed,Object? selectedMonth = freezed,Object? selectedChargeCardTokenId = freezed,Object? selectedPaymentMethod = freezed,Object? stats = freezed,Object? flow = null,}) {
  return _then(Sessions(
activeSessions: freezed == activeSessions ? _self._activeSessions : activeSessions // ignore: cast_nullable_to_non_nullable
as List<SessionModel>?,allSessions: freezed == allSessions ? _self._allSessions : allSessions // ignore: cast_nullable_to_non_nullable
as List<SessionModel>?,selectedYear: freezed == selectedYear ? _self.selectedYear : selectedYear // ignore: cast_nullable_to_non_nullable
as int?,selectedMonth: freezed == selectedMonth ? _self.selectedMonth : selectedMonth // ignore: cast_nullable_to_non_nullable
as int?,selectedChargeCardTokenId: freezed == selectedChargeCardTokenId ? _self.selectedChargeCardTokenId : selectedChargeCardTokenId // ignore: cast_nullable_to_non_nullable
as String?,selectedPaymentMethod: freezed == selectedPaymentMethod ? _self.selectedPaymentMethod : selectedPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SessionStats?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of SessionsState
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
