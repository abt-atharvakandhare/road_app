// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_credit_card_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddCreditCardState {

 UIFlow get flow;
/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddCreditCardStateCopyWith<AddCreditCardState> get copyWith => _$AddCreditCardStateCopyWithImpl<AddCreditCardState>(this as AddCreditCardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddCreditCardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddCreditCardState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as AddCreditCardState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as AddCreditCardState;
  return 'AddCreditCardState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $AddCreditCardStateCopyWith<$Res>  {
  factory $AddCreditCardStateCopyWith(AddCreditCardState value, $Res Function(AddCreditCardState) _then) = _$AddCreditCardStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$AddCreditCardStateCopyWithImpl<$Res>
    implements $AddCreditCardStateCopyWith<$Res> {
  _$AddCreditCardStateCopyWithImpl(this._self, this._then);

  final AddCreditCardState _self;
  final $Res Function(AddCreditCardState) _then;

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddCreditCardState].
extension AddCreditCardStatePatterns on AddCreditCardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( AddingCard value)?  addingCard,TResult Function( CardAdded value)?  cardAdded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case AddingCard() when addingCard != null:
return addingCard(_that);case CardAdded() when cardAdded != null:
return cardAdded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( AddingCard value)  addingCard,required TResult Function( CardAdded value)  cardAdded,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case AddingCard():
return addingCard(_that);case CardAdded():
return cardAdded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( AddingCard value)?  addingCard,TResult? Function( CardAdded value)?  cardAdded,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case AddingCard() when addingCard != null:
return addingCard(_that);case CardAdded() when cardAdded != null:
return cardAdded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow)?  initial,TResult Function( UIFlow flow)?  addingCard,TResult Function( String sourceWidget,  UIFlow flow)?  cardAdded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.flow);case AddingCard() when addingCard != null:
return addingCard(_that.flow);case CardAdded() when cardAdded != null:
return cardAdded(_that.sourceWidget,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow)  initial,required TResult Function( UIFlow flow)  addingCard,required TResult Function( String sourceWidget,  UIFlow flow)  cardAdded,}) {final _that = this;
switch (_that) {
case Initial():
return initial(_that.flow);case AddingCard():
return addingCard(_that.flow);case CardAdded():
return cardAdded(_that.sourceWidget,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow)?  initial,TResult? Function( UIFlow flow)?  addingCard,TResult? Function( String sourceWidget,  UIFlow flow)?  cardAdded,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.flow);case AddingCard() when addingCard != null:
return addingCard(_that.flow);case CardAdded() when cardAdded != null:
return cardAdded(_that.sourceWidget,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements AddCreditCardState {
  const Initial({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of AddCreditCardState
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
    return 'AddCreditCardState.initial(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $InitialCopyWith<$Res> implements $AddCreditCardStateCopyWith<$Res> {
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

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(Initial(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AddCreditCardState
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


class AddingCard implements AddCreditCardState {
  const AddingCard({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddingCardCopyWith<AddingCard> get copyWith => _$AddingCardCopyWithImpl<AddingCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddingCard&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'AddCreditCardState.addingCard(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $AddingCardCopyWith<$Res> implements $AddCreditCardStateCopyWith<$Res> {
  factory $AddingCardCopyWith(AddingCard value, $Res Function(AddingCard) _then) = _$AddingCardCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$AddingCardCopyWithImpl<$Res>
    implements $AddingCardCopyWith<$Res> {
  _$AddingCardCopyWithImpl(this._self, this._then);

  final AddingCard _self;
  final $Res Function(AddingCard) _then;

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(AddingCard(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AddCreditCardState
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


class CardAdded implements AddCreditCardState {
  const CardAdded({required this.sourceWidget, this.flow = const UIFlow.established()});
  

 final  String sourceWidget;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardAddedCopyWith<CardAdded> get copyWith => _$CardAddedCopyWithImpl<CardAdded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CardAdded&&(identical(other.sourceWidget, sourceWidget) || other.sourceWidget == sourceWidget)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sourceWidget,flow);
}

@override
String toString() {
    return 'AddCreditCardState.cardAdded(sourceWidget: $sourceWidget, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $CardAddedCopyWith<$Res> implements $AddCreditCardStateCopyWith<$Res> {
  factory $CardAddedCopyWith(CardAdded value, $Res Function(CardAdded) _then) = _$CardAddedCopyWithImpl;
@override @useResult
$Res call({
 String sourceWidget, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$CardAddedCopyWithImpl<$Res>
    implements $CardAddedCopyWith<$Res> {
  _$CardAddedCopyWithImpl(this._self, this._then);

  final CardAdded _self;
  final $Res Function(CardAdded) _then;

/// Create a copy of AddCreditCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceWidget = null,Object? flow = null,}) {
  return _then(CardAdded(
sourceWidget: null == sourceWidget ? _self.sourceWidget : sourceWidget // ignore: cast_nullable_to_non_nullable
as String,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AddCreditCardState
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
