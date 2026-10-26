// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionDetailState {

 SessionModel? get detailSession; UIFlow get flow;
/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionDetailStateCopyWith<SessionDetailState> get copyWith => _$SessionDetailStateCopyWithImpl<SessionDetailState>(this as SessionDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailState&&(identical(other.detailSession, _this.detailSession) || other.detailSession == _this.detailSession)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as SessionDetailState;
  return Object.hash(runtimeType,_this.detailSession,_this.flow);
}

@override
String toString() {
  final _this = this as SessionDetailState;
  return 'SessionDetailState(detailSession: ${_this.detailSession}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $SessionDetailStateCopyWith<$Res>  {
  factory $SessionDetailStateCopyWith(SessionDetailState value, $Res Function(SessionDetailState) _then) = _$SessionDetailStateCopyWithImpl;
@useResult
$Res call({
 SessionModel? detailSession, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SessionDetailStateCopyWithImpl<$Res>
    implements $SessionDetailStateCopyWith<$Res> {
  _$SessionDetailStateCopyWithImpl(this._self, this._then);

  final SessionDetailState _self;
  final $Res Function(SessionDetailState) _then;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? detailSession = freezed,Object? flow = null,}) {
  return _then(SessionDetailState(
detailSession: freezed == detailSession ? _self.detailSession : detailSession // ignore: cast_nullable_to_non_nullable
as SessionModel?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionDetailState].
extension SessionDetailStatePatterns on SessionDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionDetailState value)  $default,){
final _that = this;
switch (_that) {
case _SessionDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionModel? detailSession,  UIFlow flow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionDetailState() when $default != null:
return $default(_that.detailSession,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionModel? detailSession,  UIFlow flow)  $default,) {final _that = this;
switch (_that) {
case _SessionDetailState():
return $default(_that.detailSession,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionModel? detailSession,  UIFlow flow)?  $default,) {final _that = this;
switch (_that) {
case _SessionDetailState() when $default != null:
return $default(_that.detailSession,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class _SessionDetailState implements SessionDetailState {
  const _SessionDetailState({this.detailSession, this.flow = const UIFlow.established()});
  

@override final  SessionModel? detailSession;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionDetailStateCopyWith<_SessionDetailState> get copyWith => __$SessionDetailStateCopyWithImpl<_SessionDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionDetailState&&(identical(other.detailSession, detailSession) || other.detailSession == detailSession)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,detailSession,flow);
}

@override
String toString() {
    return 'SessionDetailState(detailSession: $detailSession, flow: $flow)';
}


}

/// @nodoc
abstract mixin class _$SessionDetailStateCopyWith<$Res> implements $SessionDetailStateCopyWith<$Res> {
  factory _$SessionDetailStateCopyWith(_SessionDetailState value, $Res Function(_SessionDetailState) _then) = __$SessionDetailStateCopyWithImpl;
@override @useResult
$Res call({
 SessionModel? detailSession, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class __$SessionDetailStateCopyWithImpl<$Res>
    implements _$SessionDetailStateCopyWith<$Res> {
  __$SessionDetailStateCopyWithImpl(this._self, this._then);

  final _SessionDetailState _self;
  final $Res Function(_SessionDetailState) _then;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? detailSession = freezed,Object? flow = null,}) {
  return _then(_SessionDetailState(
detailSession: freezed == detailSession ? _self.detailSession : detailSession // ignore: cast_nullable_to_non_nullable
as SessionModel?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of SessionDetailState
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
