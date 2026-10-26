// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_address_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddAddressData {

 String get street; String get houseNumber; String get postCode; String get city;
/// Create a copy of AddAddressData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddAddressDataCopyWith<AddAddressData> get copyWith => _$AddAddressDataCopyWithImpl<AddAddressData>(this as AddAddressData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddAddressData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddAddressData&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.houseNumber, _this.houseNumber) || other.houseNumber == _this.houseNumber)&&(identical(other.postCode, _this.postCode) || other.postCode == _this.postCode)&&(identical(other.city, _this.city) || other.city == _this.city));
}


@override
int get hashCode {
  final _this = this as AddAddressData;
  return Object.hash(runtimeType,_this.street,_this.houseNumber,_this.postCode,_this.city);
}

@override
String toString() {
  final _this = this as AddAddressData;
  return 'AddAddressData(street: ${_this.street}, houseNumber: ${_this.houseNumber}, postCode: ${_this.postCode}, city: ${_this.city})';
}


}

/// @nodoc
abstract mixin class $AddAddressDataCopyWith<$Res>  {
  factory $AddAddressDataCopyWith(AddAddressData value, $Res Function(AddAddressData) _then) = _$AddAddressDataCopyWithImpl;
@useResult
$Res call({
 String street, String houseNumber, String postCode, String city
});




}
/// @nodoc
class _$AddAddressDataCopyWithImpl<$Res>
    implements $AddAddressDataCopyWith<$Res> {
  _$AddAddressDataCopyWithImpl(this._self, this._then);

  final AddAddressData _self;
  final $Res Function(AddAddressData) _then;

/// Create a copy of AddAddressData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? houseNumber = null,Object? postCode = null,Object? city = null,}) {
  return _then(AddAddressData(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,houseNumber: null == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String,postCode: null == postCode ? _self.postCode : postCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AddAddressData].
extension AddAddressDataPatterns on AddAddressData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( AddAddressDataData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddAddressDataData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( AddAddressDataData value)  $default,){
final _that = this;
switch (_that) {
case AddAddressDataData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( AddAddressDataData value)?  $default,){
final _that = this;
switch (_that) {
case AddAddressDataData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String houseNumber,  String postCode,  String city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddAddressDataData() when $default != null:
return $default(_that.street,_that.houseNumber,_that.postCode,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String houseNumber,  String postCode,  String city)  $default,) {final _that = this;
switch (_that) {
case AddAddressDataData():
return $default(_that.street,_that.houseNumber,_that.postCode,_that.city);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String houseNumber,  String postCode,  String city)?  $default,) {final _that = this;
switch (_that) {
case AddAddressDataData() when $default != null:
return $default(_that.street,_that.houseNumber,_that.postCode,_that.city);case _:
  return null;

}
}

}

/// @nodoc


class AddAddressDataData implements AddAddressData {
   AddAddressDataData({required this.street, required this.houseNumber, required this.postCode, required this.city});
  

@override final  String street;
@override final  String houseNumber;
@override final  String postCode;
@override final  String city;

/// Create a copy of AddAddressData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddAddressDataDataCopyWith<AddAddressDataData> get copyWith => _$AddAddressDataDataCopyWithImpl<AddAddressDataData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddAddressDataData&&(identical(other.street, street) || other.street == street)&&(identical(other.houseNumber, houseNumber) || other.houseNumber == houseNumber)&&(identical(other.postCode, postCode) || other.postCode == postCode)&&(identical(other.city, city) || other.city == city));
}


@override
int get hashCode {
    return Object.hash(runtimeType,street,houseNumber,postCode,city);
}

@override
String toString() {
    return 'AddAddressData(street: $street, houseNumber: $houseNumber, postCode: $postCode, city: $city)';
}


}

/// @nodoc
abstract mixin class $AddAddressDataDataCopyWith<$Res> implements $AddAddressDataCopyWith<$Res> {
  factory $AddAddressDataDataCopyWith(AddAddressDataData value, $Res Function(AddAddressDataData) _then) = _$AddAddressDataDataCopyWithImpl;
@override @useResult
$Res call({
 String street, String houseNumber, String postCode, String city
});




}
/// @nodoc
class _$AddAddressDataDataCopyWithImpl<$Res>
    implements $AddAddressDataDataCopyWith<$Res> {
  _$AddAddressDataDataCopyWithImpl(this._self, this._then);

  final AddAddressDataData _self;
  final $Res Function(AddAddressDataData) _then;

/// Create a copy of AddAddressData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? houseNumber = null,Object? postCode = null,Object? city = null,}) {
  return _then(AddAddressDataData(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,houseNumber: null == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String,postCode: null == postCode ? _self.postCode : postCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
