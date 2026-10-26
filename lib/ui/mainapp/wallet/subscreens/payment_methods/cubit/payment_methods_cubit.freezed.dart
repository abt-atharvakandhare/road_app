// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_methods_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMethodsState {

 UnifiedPaymentCards? get cards; UIFlow get flow;
/// Create a copy of PaymentMethodsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodsStateCopyWith<PaymentMethodsState> get copyWith => _$PaymentMethodsStateCopyWithImpl<PaymentMethodsState>(this as PaymentMethodsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentMethodsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodsState&&(identical(other.cards, _this.cards) || other.cards == _this.cards)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as PaymentMethodsState;
  return Object.hash(runtimeType,_this.cards,_this.flow);
}

@override
String toString() {
  final _this = this as PaymentMethodsState;
  return 'PaymentMethodsState(cards: ${_this.cards}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $PaymentMethodsStateCopyWith<$Res>  {
  factory $PaymentMethodsStateCopyWith(PaymentMethodsState value, $Res Function(PaymentMethodsState) _then) = _$PaymentMethodsStateCopyWithImpl;
@useResult
$Res call({
 UnifiedPaymentCards? cards, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$PaymentMethodsStateCopyWithImpl<$Res>
    implements $PaymentMethodsStateCopyWith<$Res> {
  _$PaymentMethodsStateCopyWithImpl(this._self, this._then);

  final PaymentMethodsState _self;
  final $Res Function(PaymentMethodsState) _then;

/// Create a copy of PaymentMethodsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cards = freezed,Object? flow = null,}) {
  return _then(PaymentMethodsState.paymentMethods(
cards: freezed == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCards?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of PaymentMethodsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentMethodsState].
extension PaymentMethodsStatePatterns on PaymentMethodsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentMethods value)?  paymentMethods,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentMethods() when paymentMethods != null:
return paymentMethods(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentMethods value)  paymentMethods,}){
final _that = this;
switch (_that) {
case PaymentMethods():
return paymentMethods(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentMethods value)?  paymentMethods,}){
final _that = this;
switch (_that) {
case PaymentMethods() when paymentMethods != null:
return paymentMethods(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UnifiedPaymentCards? cards,  UIFlow flow)?  paymentMethods,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentMethods() when paymentMethods != null:
return paymentMethods(_that.cards,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UnifiedPaymentCards? cards,  UIFlow flow)  paymentMethods,}) {final _that = this;
switch (_that) {
case PaymentMethods():
return paymentMethods(_that.cards,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UnifiedPaymentCards? cards,  UIFlow flow)?  paymentMethods,}) {final _that = this;
switch (_that) {
case PaymentMethods() when paymentMethods != null:
return paymentMethods(_that.cards,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class PaymentMethods implements PaymentMethodsState {
  const PaymentMethods({this.cards, this.flow = const UIFlow.established()});
  

@override final  UnifiedPaymentCards? cards;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of PaymentMethodsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodsCopyWith<PaymentMethods> get copyWith => _$PaymentMethodsCopyWithImpl<PaymentMethods>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethods&&(identical(other.cards, cards) || other.cards == cards)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cards,flow);
}

@override
String toString() {
    return 'PaymentMethodsState.paymentMethods(cards: $cards, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodsCopyWith<$Res> implements $PaymentMethodsStateCopyWith<$Res> {
  factory $PaymentMethodsCopyWith(PaymentMethods value, $Res Function(PaymentMethods) _then) = _$PaymentMethodsCopyWithImpl;
@override @useResult
$Res call({
 UnifiedPaymentCards? cards, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$PaymentMethodsCopyWithImpl<$Res>
    implements $PaymentMethodsCopyWith<$Res> {
  _$PaymentMethodsCopyWithImpl(this._self, this._then);

  final PaymentMethods _self;
  final $Res Function(PaymentMethods) _then;

/// Create a copy of PaymentMethodsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cards = freezed,Object? flow = null,}) {
  return _then(PaymentMethods(
cards: freezed == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as UnifiedPaymentCards?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of PaymentMethodsState
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
