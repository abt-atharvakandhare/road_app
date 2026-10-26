// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_navigation_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletNavigationState {

 WalletTab get tab; int get refreshNonce;
/// Create a copy of WalletNavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletNavigationStateCopyWith<WalletNavigationState> get copyWith => _$WalletNavigationStateCopyWithImpl<WalletNavigationState>(this as WalletNavigationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletNavigationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletNavigationState&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.refreshNonce, _this.refreshNonce) || other.refreshNonce == _this.refreshNonce));
}


@override
int get hashCode {
  final _this = this as WalletNavigationState;
  return Object.hash(runtimeType,_this.tab,_this.refreshNonce);
}

@override
String toString() {
  final _this = this as WalletNavigationState;
  return 'WalletNavigationState(tab: ${_this.tab}, refreshNonce: ${_this.refreshNonce})';
}


}

/// @nodoc
abstract mixin class $WalletNavigationStateCopyWith<$Res>  {
  factory $WalletNavigationStateCopyWith(WalletNavigationState value, $Res Function(WalletNavigationState) _then) = _$WalletNavigationStateCopyWithImpl;
@useResult
$Res call({
 WalletTab tab, int refreshNonce
});




}
/// @nodoc
class _$WalletNavigationStateCopyWithImpl<$Res>
    implements $WalletNavigationStateCopyWith<$Res> {
  _$WalletNavigationStateCopyWithImpl(this._self, this._then);

  final WalletNavigationState _self;
  final $Res Function(WalletNavigationState) _then;

/// Create a copy of WalletNavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tab = null,Object? refreshNonce = null,}) {
  return _then(WalletNavigationState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as WalletTab,refreshNonce: null == refreshNonce ? _self.refreshNonce : refreshNonce // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletNavigationState].
extension WalletNavigationStatePatterns on WalletNavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletNavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletNavigationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletNavigationState value)  $default,){
final _that = this;
switch (_that) {
case _WalletNavigationState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletNavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _WalletNavigationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WalletTab tab,  int refreshNonce)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletNavigationState() when $default != null:
return $default(_that.tab,_that.refreshNonce);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WalletTab tab,  int refreshNonce)  $default,) {final _that = this;
switch (_that) {
case _WalletNavigationState():
return $default(_that.tab,_that.refreshNonce);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WalletTab tab,  int refreshNonce)?  $default,) {final _that = this;
switch (_that) {
case _WalletNavigationState() when $default != null:
return $default(_that.tab,_that.refreshNonce);case _:
  return null;

}
}

}

/// @nodoc


class _WalletNavigationState implements WalletNavigationState {
  const _WalletNavigationState({required this.tab, required this.refreshNonce});
  

@override final  WalletTab tab;
@override final  int refreshNonce;

/// Create a copy of WalletNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletNavigationStateCopyWith<_WalletNavigationState> get copyWith => __$WalletNavigationStateCopyWithImpl<_WalletNavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletNavigationState&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.refreshNonce, refreshNonce) || other.refreshNonce == refreshNonce));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tab,refreshNonce);
}

@override
String toString() {
    return 'WalletNavigationState(tab: $tab, refreshNonce: $refreshNonce)';
}


}

/// @nodoc
abstract mixin class _$WalletNavigationStateCopyWith<$Res> implements $WalletNavigationStateCopyWith<$Res> {
  factory _$WalletNavigationStateCopyWith(_WalletNavigationState value, $Res Function(_WalletNavigationState) _then) = __$WalletNavigationStateCopyWithImpl;
@override @useResult
$Res call({
 WalletTab tab, int refreshNonce
});




}
/// @nodoc
class __$WalletNavigationStateCopyWithImpl<$Res>
    implements _$WalletNavigationStateCopyWith<$Res> {
  __$WalletNavigationStateCopyWithImpl(this._self, this._then);

  final _WalletNavigationState _self;
  final $Res Function(_WalletNavigationState) _then;

/// Create a copy of WalletNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tab = null,Object? refreshNonce = null,}) {
  return _then(_WalletNavigationState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as WalletTab,refreshNonce: null == refreshNonce ? _self.refreshNonce : refreshNonce // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
