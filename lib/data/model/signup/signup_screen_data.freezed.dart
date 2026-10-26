// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_screen_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignupScreenData {

 String get firstName; String get lastName; String get phoneNumber; String get email; String get password; Country get residenceCountry; Country get phoneCountry; bool get acceptTos; bool get acceptProcessData; bool get iWantToReceiveNews;
/// Create a copy of SignupScreenData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignupScreenDataCopyWith<SignupScreenData> get copyWith => _$SignupScreenDataCopyWithImpl<SignupScreenData>(this as SignupScreenData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignupScreenData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignupScreenData&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.phoneNumber, _this.phoneNumber) || other.phoneNumber == _this.phoneNumber)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.residenceCountry, _this.residenceCountry) || other.residenceCountry == _this.residenceCountry)&&(identical(other.phoneCountry, _this.phoneCountry) || other.phoneCountry == _this.phoneCountry)&&(identical(other.acceptTos, _this.acceptTos) || other.acceptTos == _this.acceptTos)&&(identical(other.acceptProcessData, _this.acceptProcessData) || other.acceptProcessData == _this.acceptProcessData)&&(identical(other.iWantToReceiveNews, _this.iWantToReceiveNews) || other.iWantToReceiveNews == _this.iWantToReceiveNews));
}


@override
int get hashCode {
  final _this = this as SignupScreenData;
  return Object.hash(runtimeType,_this.firstName,_this.lastName,_this.phoneNumber,_this.email,_this.password,_this.residenceCountry,_this.phoneCountry,_this.acceptTos,_this.acceptProcessData,_this.iWantToReceiveNews);
}

@override
String toString() {
  final _this = this as SignupScreenData;
  return 'SignupScreenData(firstName: ${_this.firstName}, lastName: ${_this.lastName}, phoneNumber: ${_this.phoneNumber}, email: ${_this.email}, password: ${_this.password}, residenceCountry: ${_this.residenceCountry}, phoneCountry: ${_this.phoneCountry}, acceptTos: ${_this.acceptTos}, acceptProcessData: ${_this.acceptProcessData}, iWantToReceiveNews: ${_this.iWantToReceiveNews})';
}


}

/// @nodoc
abstract mixin class $SignupScreenDataCopyWith<$Res>  {
  factory $SignupScreenDataCopyWith(SignupScreenData value, $Res Function(SignupScreenData) _then) = _$SignupScreenDataCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, String phoneNumber, String email, String password, Country residenceCountry, Country phoneCountry, bool acceptTos, bool acceptProcessData, bool iWantToReceiveNews
});




}
/// @nodoc
class _$SignupScreenDataCopyWithImpl<$Res>
    implements $SignupScreenDataCopyWith<$Res> {
  _$SignupScreenDataCopyWithImpl(this._self, this._then);

  final SignupScreenData _self;
  final $Res Function(SignupScreenData) _then;

/// Create a copy of SignupScreenData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = null,Object? phoneNumber = null,Object? email = null,Object? password = null,Object? residenceCountry = null,Object? phoneCountry = null,Object? acceptTos = null,Object? acceptProcessData = null,Object? iWantToReceiveNews = null,}) {
  return _then(SignupScreenData(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,residenceCountry: null == residenceCountry ? _self.residenceCountry : residenceCountry // ignore: cast_nullable_to_non_nullable
as Country,phoneCountry: null == phoneCountry ? _self.phoneCountry : phoneCountry // ignore: cast_nullable_to_non_nullable
as Country,acceptTos: null == acceptTos ? _self.acceptTos : acceptTos // ignore: cast_nullable_to_non_nullable
as bool,acceptProcessData: null == acceptProcessData ? _self.acceptProcessData : acceptProcessData // ignore: cast_nullable_to_non_nullable
as bool,iWantToReceiveNews: null == iWantToReceiveNews ? _self.iWantToReceiveNews : iWantToReceiveNews // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignupScreenData].
extension SignupScreenDataPatterns on SignupScreenData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignupScreenData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignupScreenData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignupScreenData value)  $default,){
final _that = this;
switch (_that) {
case _SignupScreenData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignupScreenData value)?  $default,){
final _that = this;
switch (_that) {
case _SignupScreenData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String phoneNumber,  String email,  String password,  Country residenceCountry,  Country phoneCountry,  bool acceptTos,  bool acceptProcessData,  bool iWantToReceiveNews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignupScreenData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.email,_that.password,_that.residenceCountry,_that.phoneCountry,_that.acceptTos,_that.acceptProcessData,_that.iWantToReceiveNews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String lastName,  String phoneNumber,  String email,  String password,  Country residenceCountry,  Country phoneCountry,  bool acceptTos,  bool acceptProcessData,  bool iWantToReceiveNews)  $default,) {final _that = this;
switch (_that) {
case _SignupScreenData():
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.email,_that.password,_that.residenceCountry,_that.phoneCountry,_that.acceptTos,_that.acceptProcessData,_that.iWantToReceiveNews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String lastName,  String phoneNumber,  String email,  String password,  Country residenceCountry,  Country phoneCountry,  bool acceptTos,  bool acceptProcessData,  bool iWantToReceiveNews)?  $default,) {final _that = this;
switch (_that) {
case _SignupScreenData() when $default != null:
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.email,_that.password,_that.residenceCountry,_that.phoneCountry,_that.acceptTos,_that.acceptProcessData,_that.iWantToReceiveNews);case _:
  return null;

}
}

}

/// @nodoc


class _SignupScreenData implements SignupScreenData {
   _SignupScreenData({required this.firstName, required this.lastName, required this.phoneNumber, required this.email, required this.password, required this.residenceCountry, required this.phoneCountry, required this.acceptTos, required this.acceptProcessData, required this.iWantToReceiveNews});
  

@override final  String firstName;
@override final  String lastName;
@override final  String phoneNumber;
@override final  String email;
@override final  String password;
@override final  Country residenceCountry;
@override final  Country phoneCountry;
@override final  bool acceptTos;
@override final  bool acceptProcessData;
@override final  bool iWantToReceiveNews;

/// Create a copy of SignupScreenData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignupScreenDataCopyWith<_SignupScreenData> get copyWith => __$SignupScreenDataCopyWithImpl<_SignupScreenData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignupScreenData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.residenceCountry, residenceCountry) || other.residenceCountry == residenceCountry)&&(identical(other.phoneCountry, phoneCountry) || other.phoneCountry == phoneCountry)&&(identical(other.acceptTos, acceptTos) || other.acceptTos == acceptTos)&&(identical(other.acceptProcessData, acceptProcessData) || other.acceptProcessData == acceptProcessData)&&(identical(other.iWantToReceiveNews, iWantToReceiveNews) || other.iWantToReceiveNews == iWantToReceiveNews));
}


@override
int get hashCode {
    return Object.hash(runtimeType,firstName,lastName,phoneNumber,email,password,residenceCountry,phoneCountry,acceptTos,acceptProcessData,iWantToReceiveNews);
}

@override
String toString() {
    return 'SignupScreenData(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, email: $email, password: $password, residenceCountry: $residenceCountry, phoneCountry: $phoneCountry, acceptTos: $acceptTos, acceptProcessData: $acceptProcessData, iWantToReceiveNews: $iWantToReceiveNews)';
}


}

/// @nodoc
abstract mixin class _$SignupScreenDataCopyWith<$Res> implements $SignupScreenDataCopyWith<$Res> {
  factory _$SignupScreenDataCopyWith(_SignupScreenData value, $Res Function(_SignupScreenData) _then) = __$SignupScreenDataCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String lastName, String phoneNumber, String email, String password, Country residenceCountry, Country phoneCountry, bool acceptTos, bool acceptProcessData, bool iWantToReceiveNews
});




}
/// @nodoc
class __$SignupScreenDataCopyWithImpl<$Res>
    implements _$SignupScreenDataCopyWith<$Res> {
  __$SignupScreenDataCopyWithImpl(this._self, this._then);

  final _SignupScreenData _self;
  final $Res Function(_SignupScreenData) _then;

/// Create a copy of SignupScreenData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? phoneNumber = null,Object? email = null,Object? password = null,Object? residenceCountry = null,Object? phoneCountry = null,Object? acceptTos = null,Object? acceptProcessData = null,Object? iWantToReceiveNews = null,}) {
  return _then(_SignupScreenData(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,residenceCountry: null == residenceCountry ? _self.residenceCountry : residenceCountry // ignore: cast_nullable_to_non_nullable
as Country,phoneCountry: null == phoneCountry ? _self.phoneCountry : phoneCountry // ignore: cast_nullable_to_non_nullable
as Country,acceptTos: null == acceptTos ? _self.acceptTos : acceptTos // ignore: cast_nullable_to_non_nullable
as bool,acceptProcessData: null == acceptProcessData ? _self.acceptProcessData : acceptProcessData // ignore: cast_nullable_to_non_nullable
as bool,iWantToReceiveNews: null == iWantToReceiveNews ? _self.iWantToReceiveNews : iWantToReceiveNews // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
