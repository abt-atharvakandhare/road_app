// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_flow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UIFlow {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UIFlow);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UIFlow()';
}


}

/// @nodoc
class $UIFlowCopyWith<$Res>  {
$UIFlowCopyWith(UIFlow _, $Res Function(UIFlow) __);
}


/// Adds pattern-matching-related methods to [UIFlow].
extension UIFlowPatterns on UIFlow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UIFlowEstablished value)?  established,TResult Function( UIFlowLoading value)?  loading,TResult Function( UIFlowError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UIFlowEstablished() when established != null:
return established(_that);case UIFlowLoading() when loading != null:
return loading(_that);case UIFlowError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UIFlowEstablished value)  established,required TResult Function( UIFlowLoading value)  loading,required TResult Function( UIFlowError value)  error,}){
final _that = this;
switch (_that) {
case UIFlowEstablished():
return established(_that);case UIFlowLoading():
return loading(_that);case UIFlowError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UIFlowEstablished value)?  established,TResult? Function( UIFlowLoading value)?  loading,TResult? Function( UIFlowError value)?  error,}){
final _that = this;
switch (_that) {
case UIFlowEstablished() when established != null:
return established(_that);case UIFlowLoading() when loading != null:
return loading(_that);case UIFlowError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  established,TResult Function()?  loading,TResult Function( RMApiError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UIFlowEstablished() when established != null:
return established();case UIFlowLoading() when loading != null:
return loading();case UIFlowError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  established,required TResult Function()  loading,required TResult Function( RMApiError error)  error,}) {final _that = this;
switch (_that) {
case UIFlowEstablished():
return established();case UIFlowLoading():
return loading();case UIFlowError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  established,TResult? Function()?  loading,TResult? Function( RMApiError error)?  error,}) {final _that = this;
switch (_that) {
case UIFlowEstablished() when established != null:
return established();case UIFlowLoading() when loading != null:
return loading();case UIFlowError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class UIFlowEstablished extends UIFlow {
  const UIFlowEstablished(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UIFlowEstablished);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UIFlow.established()';
}


}




/// @nodoc


class UIFlowLoading extends UIFlow {
  const UIFlowLoading(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UIFlowLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'UIFlow.loading()';
}


}




/// @nodoc


class UIFlowError extends UIFlow {
  const UIFlowError(this.error): super._();
  

 final  RMApiError error;

/// Create a copy of UIFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UIFlowErrorCopyWith<UIFlowError> get copyWith => _$UIFlowErrorCopyWithImpl<UIFlowError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UIFlowError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'UIFlow.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $UIFlowErrorCopyWith<$Res> implements $UIFlowCopyWith<$Res> {
  factory $UIFlowErrorCopyWith(UIFlowError value, $Res Function(UIFlowError) _then) = _$UIFlowErrorCopyWithImpl;
@useResult
$Res call({
 RMApiError error
});




}
/// @nodoc
class _$UIFlowErrorCopyWithImpl<$Res>
    implements $UIFlowErrorCopyWith<$Res> {
  _$UIFlowErrorCopyWithImpl(this._self, this._then);

  final UIFlowError _self;
  final $Res Function(UIFlowError) _then;

/// Create a copy of UIFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(UIFlowError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as RMApiError,
  ));
}


}

// dart format on
