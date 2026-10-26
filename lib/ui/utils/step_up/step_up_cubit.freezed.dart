// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step_up_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StepUpState {

 UIFlow get flow;
/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepUpStateCopyWith<StepUpState> get copyWith => _$StepUpStateCopyWithImpl<StepUpState>(this as StepUpState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StepUpState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepUpState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as StepUpState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as StepUpState;
  return 'StepUpState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $StepUpStateCopyWith<$Res>  {
  factory $StepUpStateCopyWith(StepUpState value, $Res Function(StepUpState) _then) = _$StepUpStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StepUpStateCopyWithImpl<$Res>
    implements $StepUpStateCopyWith<$Res> {
  _$StepUpStateCopyWithImpl(this._self, this._then);

  final StepUpState _self;
  final $Res Function(StepUpState) _then;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [StepUpState].
extension StepUpStatePatterns on StepUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( StepUpMethodPick value)?  methodPick,TResult Function( StepUpCodeEntry value)?  codeEntry,TResult Function( StepUpPasskey value)?  passkey,TResult Function( StepUpDeadEnd value)?  deadEnd,required TResult orElse(),}){
final _that = this;
switch (_that) {
case StepUpMethodPick() when methodPick != null:
return methodPick(_that);case StepUpCodeEntry() when codeEntry != null:
return codeEntry(_that);case StepUpPasskey() when passkey != null:
return passkey(_that);case StepUpDeadEnd() when deadEnd != null:
return deadEnd(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( StepUpMethodPick value)  methodPick,required TResult Function( StepUpCodeEntry value)  codeEntry,required TResult Function( StepUpPasskey value)  passkey,required TResult Function( StepUpDeadEnd value)  deadEnd,}){
final _that = this;
switch (_that) {
case StepUpMethodPick():
return methodPick(_that);case StepUpCodeEntry():
return codeEntry(_that);case StepUpPasskey():
return passkey(_that);case StepUpDeadEnd():
return deadEnd(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( StepUpMethodPick value)?  methodPick,TResult? Function( StepUpCodeEntry value)?  codeEntry,TResult? Function( StepUpPasskey value)?  passkey,TResult? Function( StepUpDeadEnd value)?  deadEnd,}){
final _that = this;
switch (_that) {
case StepUpMethodPick() when methodPick != null:
return methodPick(_that);case StepUpCodeEntry() when codeEntry != null:
return codeEntry(_that);case StepUpPasskey() when passkey != null:
return passkey(_that);case StepUpDeadEnd() when deadEnd != null:
return deadEnd(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow,  List<MfaFactorModel>? factors)?  methodPick,TResult Function( UIFlow flow,  MfaMethod method,  String? hint,  int? nextSendAfterSeconds,  bool canPickAnother)?  codeEntry,TResult Function( UIFlow flow,  bool noCredential,  bool canPickAnother)?  passkey,TResult Function( UIFlow flow)?  deadEnd,required TResult orElse(),}) {final _that = this;
switch (_that) {
case StepUpMethodPick() when methodPick != null:
return methodPick(_that.flow,_that.factors);case StepUpCodeEntry() when codeEntry != null:
return codeEntry(_that.flow,_that.method,_that.hint,_that.nextSendAfterSeconds,_that.canPickAnother);case StepUpPasskey() when passkey != null:
return passkey(_that.flow,_that.noCredential,_that.canPickAnother);case StepUpDeadEnd() when deadEnd != null:
return deadEnd(_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow,  List<MfaFactorModel>? factors)  methodPick,required TResult Function( UIFlow flow,  MfaMethod method,  String? hint,  int? nextSendAfterSeconds,  bool canPickAnother)  codeEntry,required TResult Function( UIFlow flow,  bool noCredential,  bool canPickAnother)  passkey,required TResult Function( UIFlow flow)  deadEnd,}) {final _that = this;
switch (_that) {
case StepUpMethodPick():
return methodPick(_that.flow,_that.factors);case StepUpCodeEntry():
return codeEntry(_that.flow,_that.method,_that.hint,_that.nextSendAfterSeconds,_that.canPickAnother);case StepUpPasskey():
return passkey(_that.flow,_that.noCredential,_that.canPickAnother);case StepUpDeadEnd():
return deadEnd(_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow,  List<MfaFactorModel>? factors)?  methodPick,TResult? Function( UIFlow flow,  MfaMethod method,  String? hint,  int? nextSendAfterSeconds,  bool canPickAnother)?  codeEntry,TResult? Function( UIFlow flow,  bool noCredential,  bool canPickAnother)?  passkey,TResult? Function( UIFlow flow)?  deadEnd,}) {final _that = this;
switch (_that) {
case StepUpMethodPick() when methodPick != null:
return methodPick(_that.flow,_that.factors);case StepUpCodeEntry() when codeEntry != null:
return codeEntry(_that.flow,_that.method,_that.hint,_that.nextSendAfterSeconds,_that.canPickAnother);case StepUpPasskey() when passkey != null:
return passkey(_that.flow,_that.noCredential,_that.canPickAnother);case StepUpDeadEnd() when deadEnd != null:
return deadEnd(_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class StepUpMethodPick implements StepUpState {
  const StepUpMethodPick({this.flow = const UIFlow.established(),  List<MfaFactorModel>? factors}): _factors = factors;
  

@override@JsonKey() final  UIFlow flow;
 final  List<MfaFactorModel>? _factors;
 List<MfaFactorModel>? get factors {
  final value = _factors;
  if (value == null) return null;
  if (_factors is EqualUnmodifiableListView) return _factors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepUpMethodPickCopyWith<StepUpMethodPick> get copyWith => _$StepUpMethodPickCopyWithImpl<StepUpMethodPick>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StepUpMethodPick&&(identical(other.flow, flow) || other.flow == flow)&&const DeepCollectionEquality().equals(other.factors, _factors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,const DeepCollectionEquality().hash(_factors));
}

@override
String toString() {
    return 'StepUpState.methodPick(flow: $flow, factors: $factors)';
}


}

/// @nodoc
abstract mixin class $StepUpMethodPickCopyWith<$Res> implements $StepUpStateCopyWith<$Res> {
  factory $StepUpMethodPickCopyWith(StepUpMethodPick value, $Res Function(StepUpMethodPick) _then) = _$StepUpMethodPickCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, List<MfaFactorModel>? factors
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StepUpMethodPickCopyWithImpl<$Res>
    implements $StepUpMethodPickCopyWith<$Res> {
  _$StepUpMethodPickCopyWithImpl(this._self, this._then);

  final StepUpMethodPick _self;
  final $Res Function(StepUpMethodPick) _then;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? factors = freezed,}) {
  return _then(StepUpMethodPick(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,factors: freezed == factors ? _self._factors : factors // ignore: cast_nullable_to_non_nullable
as List<MfaFactorModel>?,
  ));
}

/// Create a copy of StepUpState
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


class StepUpCodeEntry implements StepUpState {
  const StepUpCodeEntry({this.flow = const UIFlow.established(), required this.method, this.hint, this.nextSendAfterSeconds, this.canPickAnother = false});
  

@override@JsonKey() final  UIFlow flow;
 final  MfaMethod method;
 final  String? hint;
 final  int? nextSendAfterSeconds;
@JsonKey() final  bool canPickAnother;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepUpCodeEntryCopyWith<StepUpCodeEntry> get copyWith => _$StepUpCodeEntryCopyWithImpl<StepUpCodeEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StepUpCodeEntry&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.method, method) || other.method == method)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds)&&(identical(other.canPickAnother, canPickAnother) || other.canPickAnother == canPickAnother));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,method,hint,nextSendAfterSeconds,canPickAnother);
}

@override
String toString() {
    return 'StepUpState.codeEntry(flow: $flow, method: $method, hint: $hint, nextSendAfterSeconds: $nextSendAfterSeconds, canPickAnother: $canPickAnother)';
}


}

/// @nodoc
abstract mixin class $StepUpCodeEntryCopyWith<$Res> implements $StepUpStateCopyWith<$Res> {
  factory $StepUpCodeEntryCopyWith(StepUpCodeEntry value, $Res Function(StepUpCodeEntry) _then) = _$StepUpCodeEntryCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, MfaMethod method, String? hint, int? nextSendAfterSeconds, bool canPickAnother
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StepUpCodeEntryCopyWithImpl<$Res>
    implements $StepUpCodeEntryCopyWith<$Res> {
  _$StepUpCodeEntryCopyWithImpl(this._self, this._then);

  final StepUpCodeEntry _self;
  final $Res Function(StepUpCodeEntry) _then;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? method = null,Object? hint = freezed,Object? nextSendAfterSeconds = freezed,Object? canPickAnother = null,}) {
  return _then(StepUpCodeEntry(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as MfaMethod,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,canPickAnother: null == canPickAnother ? _self.canPickAnother : canPickAnother // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of StepUpState
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


class StepUpPasskey implements StepUpState {
  const StepUpPasskey({this.flow = const UIFlow.established(), this.noCredential = false, this.canPickAnother = false});
  

@override@JsonKey() final  UIFlow flow;
@JsonKey() final  bool noCredential;
@JsonKey() final  bool canPickAnother;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepUpPasskeyCopyWith<StepUpPasskey> get copyWith => _$StepUpPasskeyCopyWithImpl<StepUpPasskey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StepUpPasskey&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.noCredential, noCredential) || other.noCredential == noCredential)&&(identical(other.canPickAnother, canPickAnother) || other.canPickAnother == canPickAnother));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,noCredential,canPickAnother);
}

@override
String toString() {
    return 'StepUpState.passkey(flow: $flow, noCredential: $noCredential, canPickAnother: $canPickAnother)';
}


}

/// @nodoc
abstract mixin class $StepUpPasskeyCopyWith<$Res> implements $StepUpStateCopyWith<$Res> {
  factory $StepUpPasskeyCopyWith(StepUpPasskey value, $Res Function(StepUpPasskey) _then) = _$StepUpPasskeyCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, bool noCredential, bool canPickAnother
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StepUpPasskeyCopyWithImpl<$Res>
    implements $StepUpPasskeyCopyWith<$Res> {
  _$StepUpPasskeyCopyWithImpl(this._self, this._then);

  final StepUpPasskey _self;
  final $Res Function(StepUpPasskey) _then;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? noCredential = null,Object? canPickAnother = null,}) {
  return _then(StepUpPasskey(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,noCredential: null == noCredential ? _self.noCredential : noCredential // ignore: cast_nullable_to_non_nullable
as bool,canPickAnother: null == canPickAnother ? _self.canPickAnother : canPickAnother // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of StepUpState
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


class StepUpDeadEnd implements StepUpState {
  const StepUpDeadEnd({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepUpDeadEndCopyWith<StepUpDeadEnd> get copyWith => _$StepUpDeadEndCopyWithImpl<StepUpDeadEnd>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StepUpDeadEnd&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'StepUpState.deadEnd(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $StepUpDeadEndCopyWith<$Res> implements $StepUpStateCopyWith<$Res> {
  factory $StepUpDeadEndCopyWith(StepUpDeadEnd value, $Res Function(StepUpDeadEnd) _then) = _$StepUpDeadEndCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$StepUpDeadEndCopyWithImpl<$Res>
    implements $StepUpDeadEndCopyWith<$Res> {
  _$StepUpDeadEndCopyWithImpl(this._self, this._then);

  final StepUpDeadEnd _self;
  final $Res Function(StepUpDeadEnd) _then;

/// Create a copy of StepUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(StepUpDeadEnd(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of StepUpState
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
