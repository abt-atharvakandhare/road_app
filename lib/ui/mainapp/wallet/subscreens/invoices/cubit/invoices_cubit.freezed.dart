// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoices_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvoicesState {

 List<InvoiceModel>? get allInvoices; DateTime? get allInvoicesYearFilter; UIFlow get flow;
/// Create a copy of InvoicesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoicesStateCopyWith<InvoicesState> get copyWith => _$InvoicesStateCopyWithImpl<InvoicesState>(this as InvoicesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InvoicesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoicesState&&const DeepCollectionEquality().equals(other.allInvoices, _this.allInvoices)&&(identical(other.allInvoicesYearFilter, _this.allInvoicesYearFilter) || other.allInvoicesYearFilter == _this.allInvoicesYearFilter)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as InvoicesState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.allInvoices),_this.allInvoicesYearFilter,_this.flow);
}

@override
String toString() {
  final _this = this as InvoicesState;
  return 'InvoicesState(allInvoices: ${_this.allInvoices}, allInvoicesYearFilter: ${_this.allInvoicesYearFilter}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $InvoicesStateCopyWith<$Res>  {
  factory $InvoicesStateCopyWith(InvoicesState value, $Res Function(InvoicesState) _then) = _$InvoicesStateCopyWithImpl;
@useResult
$Res call({
 List<InvoiceModel>? allInvoices, DateTime? allInvoicesYearFilter, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$InvoicesStateCopyWithImpl<$Res>
    implements $InvoicesStateCopyWith<$Res> {
  _$InvoicesStateCopyWithImpl(this._self, this._then);

  final InvoicesState _self;
  final $Res Function(InvoicesState) _then;

/// Create a copy of InvoicesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allInvoices = freezed,Object? allInvoicesYearFilter = freezed,Object? flow = null,}) {
  return _then(InvoicesState.initial(
allInvoices: freezed == allInvoices ? _self.allInvoices : allInvoices // ignore: cast_nullable_to_non_nullable
as List<InvoiceModel>?,allInvoicesYearFilter: freezed == allInvoicesYearFilter ? _self.allInvoicesYearFilter : allInvoicesYearFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of InvoicesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [InvoicesState].
extension InvoicesStatePatterns on InvoicesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<InvoiceModel>? allInvoices,  DateTime? allInvoicesYearFilter,  UIFlow flow)?  initial,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.allInvoices,_that.allInvoicesYearFilter,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<InvoiceModel>? allInvoices,  DateTime? allInvoicesYearFilter,  UIFlow flow)  initial,}) {final _that = this;
switch (_that) {
case Initial():
return initial(_that.allInvoices,_that.allInvoicesYearFilter,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<InvoiceModel>? allInvoices,  DateTime? allInvoicesYearFilter,  UIFlow flow)?  initial,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that.allInvoices,_that.allInvoicesYearFilter,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements InvoicesState {
  const Initial({ List<InvoiceModel>? allInvoices, this.allInvoicesYearFilter, this.flow = const UIFlow.established()}): _allInvoices = allInvoices;
  

 final  List<InvoiceModel>? _allInvoices;
@override List<InvoiceModel>? get allInvoices {
  final value = _allInvoices;
  if (value == null) return null;
  if (_allInvoices is EqualUnmodifiableListView) return _allInvoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? allInvoicesYearFilter;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of InvoicesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitialCopyWith<Initial> get copyWith => _$InitialCopyWithImpl<Initial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial&&const DeepCollectionEquality().equals(other.allInvoices, _allInvoices)&&(identical(other.allInvoicesYearFilter, allInvoicesYearFilter) || other.allInvoicesYearFilter == allInvoicesYearFilter)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_allInvoices),allInvoicesYearFilter,flow);
}

@override
String toString() {
    return 'InvoicesState.initial(allInvoices: $allInvoices, allInvoicesYearFilter: $allInvoicesYearFilter, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $InitialCopyWith<$Res> implements $InvoicesStateCopyWith<$Res> {
  factory $InitialCopyWith(Initial value, $Res Function(Initial) _then) = _$InitialCopyWithImpl;
@override @useResult
$Res call({
 List<InvoiceModel>? allInvoices, DateTime? allInvoicesYearFilter, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$InitialCopyWithImpl<$Res>
    implements $InitialCopyWith<$Res> {
  _$InitialCopyWithImpl(this._self, this._then);

  final Initial _self;
  final $Res Function(Initial) _then;

/// Create a copy of InvoicesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allInvoices = freezed,Object? allInvoicesYearFilter = freezed,Object? flow = null,}) {
  return _then(Initial(
allInvoices: freezed == allInvoices ? _self._allInvoices : allInvoices // ignore: cast_nullable_to_non_nullable
as List<InvoiceModel>?,allInvoicesYearFilter: freezed == allInvoicesYearFilter ? _self.allInvoicesYearFilter : allInvoicesYearFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of InvoicesState
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
