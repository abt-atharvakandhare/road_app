// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordState {

 UIFlow get flow;
/// Create a copy of PasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordStateCopyWith<PasswordState> get copyWith => _$PasswordStateCopyWithImpl<PasswordState>(this as PasswordState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PasswordState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as PasswordState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as PasswordState;
  return 'PasswordState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $PasswordStateCopyWith<$Res>  {
  factory $PasswordStateCopyWith(PasswordState value, $Res Function(PasswordState) _then) = _$PasswordStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$PasswordStateCopyWithImpl<$Res>
    implements $PasswordStateCopyWith<$Res> {
  _$PasswordStateCopyWithImpl(this._self, this._then);

  final PasswordState _self;
  final $Res Function(PasswordState) _then;

/// Create a copy of PasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(PasswordState.password(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of PasswordState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [PasswordState].
extension PasswordStatePatterns on PasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Password value)?  password,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Password() when password != null:
return password(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Password value)  password,}){
final _that = this;
switch (_that) {
case Password():
return password(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Password value)?  password,}){
final _that = this;
switch (_that) {
case Password() when password != null:
return password(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow)?  password,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Password() when password != null:
return password(_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow)  password,}) {final _that = this;
switch (_that) {
case Password():
return password(_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow)?  password,}) {final _that = this;
switch (_that) {
case Password() when password != null:
return password(_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Password implements PasswordState {
  const Password({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of PasswordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordCopyWith<Password> get copyWith => _$PasswordCopyWithImpl<Password>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Password&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'PasswordState.password(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $PasswordCopyWith<$Res> implements $PasswordStateCopyWith<$Res> {
  factory $PasswordCopyWith(Password value, $Res Function(Password) _then) = _$PasswordCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$PasswordCopyWithImpl<$Res>
    implements $PasswordCopyWith<$Res> {
  _$PasswordCopyWithImpl(this._self, this._then);

  final Password _self;
  final $Res Function(Password) _then;

/// Create a copy of PasswordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(Password(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of PasswordState
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
