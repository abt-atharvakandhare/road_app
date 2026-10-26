// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignupState {

 UIFlow get flow;
/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignupStateCopyWith<SignupState> get copyWith => _$SignupStateCopyWithImpl<SignupState>(this as SignupState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignupState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignupState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as SignupState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as SignupState;
  return 'SignupState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $SignupStateCopyWith<$Res>  {
  factory $SignupStateCopyWith(SignupState value, $Res Function(SignupState) _then) = _$SignupStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SignupStateCopyWithImpl<$Res>
    implements $SignupStateCopyWith<$Res> {
  _$SignupStateCopyWithImpl(this._self, this._then);

  final SignupState _self;
  final $Res Function(SignupState) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [SignupState].
extension SignupStatePatterns on SignupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateAccount value)?  createAccount,TResult Function( VerifyPhone value)?  verifyPhone,TResult Function( VerifyEmail value)?  verifyEmail,TResult Function( OfferAddPayment value)?  offerAddPayment,TResult Function( OfferMfaSetup value)?  offerMfaSetup,TResult Function( SignupCompleted value)?  completed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateAccount() when createAccount != null:
return createAccount(_that);case VerifyPhone() when verifyPhone != null:
return verifyPhone(_that);case VerifyEmail() when verifyEmail != null:
return verifyEmail(_that);case OfferAddPayment() when offerAddPayment != null:
return offerAddPayment(_that);case OfferMfaSetup() when offerMfaSetup != null:
return offerMfaSetup(_that);case SignupCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateAccount value)  createAccount,required TResult Function( VerifyPhone value)  verifyPhone,required TResult Function( VerifyEmail value)  verifyEmail,required TResult Function( OfferAddPayment value)  offerAddPayment,required TResult Function( OfferMfaSetup value)  offerMfaSetup,required TResult Function( SignupCompleted value)  completed,}){
final _that = this;
switch (_that) {
case CreateAccount():
return createAccount(_that);case VerifyPhone():
return verifyPhone(_that);case VerifyEmail():
return verifyEmail(_that);case OfferAddPayment():
return offerAddPayment(_that);case OfferMfaSetup():
return offerMfaSetup(_that);case SignupCompleted():
return completed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateAccount value)?  createAccount,TResult? Function( VerifyPhone value)?  verifyPhone,TResult? Function( VerifyEmail value)?  verifyEmail,TResult? Function( OfferAddPayment value)?  offerAddPayment,TResult? Function( OfferMfaSetup value)?  offerMfaSetup,TResult? Function( SignupCompleted value)?  completed,}){
final _that = this;
switch (_that) {
case CreateAccount() when createAccount != null:
return createAccount(_that);case VerifyPhone() when verifyPhone != null:
return verifyPhone(_that);case VerifyEmail() when verifyEmail != null:
return verifyEmail(_that);case OfferAddPayment() when offerAddPayment != null:
return offerAddPayment(_that);case OfferMfaSetup() when offerMfaSetup != null:
return offerMfaSetup(_that);case SignupCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow,  List<String> supportedCountries,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  createAccount,TResult Function( UIFlow flow,  String phoneNumber,  String phoneCountryCode,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  verifyPhone,TResult Function( UIFlow flow,  String email,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  verifyEmail,TResult Function( UIFlow flow,  int currentStep,  int totalSteps)?  offerAddPayment,TResult Function( UIFlow flow,  int currentStep,  int totalSteps)?  offerMfaSetup,TResult Function( UIFlow flow)?  completed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateAccount() when createAccount != null:
return createAccount(_that.flow,_that.supportedCountries,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyPhone() when verifyPhone != null:
return verifyPhone(_that.flow,_that.phoneNumber,_that.phoneCountryCode,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyEmail() when verifyEmail != null:
return verifyEmail(_that.flow,_that.email,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case OfferAddPayment() when offerAddPayment != null:
return offerAddPayment(_that.flow,_that.currentStep,_that.totalSteps);case OfferMfaSetup() when offerMfaSetup != null:
return offerMfaSetup(_that.flow,_that.currentStep,_that.totalSteps);case SignupCompleted() when completed != null:
return completed(_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow,  List<String> supportedCountries,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)  createAccount,required TResult Function( UIFlow flow,  String phoneNumber,  String phoneCountryCode,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)  verifyPhone,required TResult Function( UIFlow flow,  String email,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)  verifyEmail,required TResult Function( UIFlow flow,  int currentStep,  int totalSteps)  offerAddPayment,required TResult Function( UIFlow flow,  int currentStep,  int totalSteps)  offerMfaSetup,required TResult Function( UIFlow flow)  completed,}) {final _that = this;
switch (_that) {
case CreateAccount():
return createAccount(_that.flow,_that.supportedCountries,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyPhone():
return verifyPhone(_that.flow,_that.phoneNumber,_that.phoneCountryCode,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyEmail():
return verifyEmail(_that.flow,_that.email,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case OfferAddPayment():
return offerAddPayment(_that.flow,_that.currentStep,_that.totalSteps);case OfferMfaSetup():
return offerMfaSetup(_that.flow,_that.currentStep,_that.totalSteps);case SignupCompleted():
return completed(_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow,  List<String> supportedCountries,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  createAccount,TResult? Function( UIFlow flow,  String phoneNumber,  String phoneCountryCode,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  verifyPhone,TResult? Function( UIFlow flow,  String email,  List<VerificationType> requiredVerifications,  int currentStep,  int totalSteps)?  verifyEmail,TResult? Function( UIFlow flow,  int currentStep,  int totalSteps)?  offerAddPayment,TResult? Function( UIFlow flow,  int currentStep,  int totalSteps)?  offerMfaSetup,TResult? Function( UIFlow flow)?  completed,}) {final _that = this;
switch (_that) {
case CreateAccount() when createAccount != null:
return createAccount(_that.flow,_that.supportedCountries,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyPhone() when verifyPhone != null:
return verifyPhone(_that.flow,_that.phoneNumber,_that.phoneCountryCode,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case VerifyEmail() when verifyEmail != null:
return verifyEmail(_that.flow,_that.email,_that.requiredVerifications,_that.currentStep,_that.totalSteps);case OfferAddPayment() when offerAddPayment != null:
return offerAddPayment(_that.flow,_that.currentStep,_that.totalSteps);case OfferMfaSetup() when offerMfaSetup != null:
return offerMfaSetup(_that.flow,_that.currentStep,_that.totalSteps);case SignupCompleted() when completed != null:
return completed(_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class CreateAccount implements SignupState {
  const CreateAccount({this.flow = const UIFlow.established(),  List<String> supportedCountries = const [],  List<VerificationType> requiredVerifications = const [], this.currentStep = 1, this.totalSteps = 4}): _supportedCountries = supportedCountries,_requiredVerifications = requiredVerifications;
  

@override@JsonKey() final  UIFlow flow;
 final  List<String> _supportedCountries;
@JsonKey() List<String> get supportedCountries {
  if (_supportedCountries is EqualUnmodifiableListView) return _supportedCountries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedCountries);
}

 final  List<VerificationType> _requiredVerifications;
@JsonKey() List<VerificationType> get requiredVerifications {
  if (_requiredVerifications is EqualUnmodifiableListView) return _requiredVerifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredVerifications);
}

@JsonKey() final  int currentStep;
@JsonKey() final  int totalSteps;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateAccountCopyWith<CreateAccount> get copyWith => _$CreateAccountCopyWithImpl<CreateAccount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateAccount&&(identical(other.flow, flow) || other.flow == flow)&&const DeepCollectionEquality().equals(other.supportedCountries, _supportedCountries)&&const DeepCollectionEquality().equals(other.requiredVerifications, _requiredVerifications)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,const DeepCollectionEquality().hash(_supportedCountries),const DeepCollectionEquality().hash(_requiredVerifications),currentStep,totalSteps);
}

@override
String toString() {
    return 'SignupState.createAccount(flow: $flow, supportedCountries: $supportedCountries, requiredVerifications: $requiredVerifications, currentStep: $currentStep, totalSteps: $totalSteps)';
}


}

/// @nodoc
abstract mixin class $CreateAccountCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $CreateAccountCopyWith(CreateAccount value, $Res Function(CreateAccount) _then) = _$CreateAccountCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, List<String> supportedCountries, List<VerificationType> requiredVerifications, int currentStep, int totalSteps
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$CreateAccountCopyWithImpl<$Res>
    implements $CreateAccountCopyWith<$Res> {
  _$CreateAccountCopyWithImpl(this._self, this._then);

  final CreateAccount _self;
  final $Res Function(CreateAccount) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? supportedCountries = null,Object? requiredVerifications = null,Object? currentStep = null,Object? totalSteps = null,}) {
  return _then(CreateAccount(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,supportedCountries: null == supportedCountries ? _self._supportedCountries : supportedCountries // ignore: cast_nullable_to_non_nullable
as List<String>,requiredVerifications: null == requiredVerifications ? _self._requiredVerifications : requiredVerifications // ignore: cast_nullable_to_non_nullable
as List<VerificationType>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SignupState
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


class VerifyPhone implements SignupState {
  const VerifyPhone({this.flow = const UIFlow.established(), required this.phoneNumber, required this.phoneCountryCode,  List<VerificationType> requiredVerifications = const [], this.currentStep = 2, this.totalSteps = 4}): _requiredVerifications = requiredVerifications;
  

@override@JsonKey() final  UIFlow flow;
 final  String phoneNumber;
 final  String phoneCountryCode;
 final  List<VerificationType> _requiredVerifications;
@JsonKey() List<VerificationType> get requiredVerifications {
  if (_requiredVerifications is EqualUnmodifiableListView) return _requiredVerifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredVerifications);
}

@JsonKey() final  int currentStep;
@JsonKey() final  int totalSteps;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyPhoneCopyWith<VerifyPhone> get copyWith => _$VerifyPhoneCopyWithImpl<VerifyPhone>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyPhone&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.phoneCountryCode, phoneCountryCode) || other.phoneCountryCode == phoneCountryCode)&&const DeepCollectionEquality().equals(other.requiredVerifications, _requiredVerifications)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,phoneNumber,phoneCountryCode,const DeepCollectionEquality().hash(_requiredVerifications),currentStep,totalSteps);
}

@override
String toString() {
    return 'SignupState.verifyPhone(flow: $flow, phoneNumber: $phoneNumber, phoneCountryCode: $phoneCountryCode, requiredVerifications: $requiredVerifications, currentStep: $currentStep, totalSteps: $totalSteps)';
}


}

/// @nodoc
abstract mixin class $VerifyPhoneCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $VerifyPhoneCopyWith(VerifyPhone value, $Res Function(VerifyPhone) _then) = _$VerifyPhoneCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, String phoneNumber, String phoneCountryCode, List<VerificationType> requiredVerifications, int currentStep, int totalSteps
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$VerifyPhoneCopyWithImpl<$Res>
    implements $VerifyPhoneCopyWith<$Res> {
  _$VerifyPhoneCopyWithImpl(this._self, this._then);

  final VerifyPhone _self;
  final $Res Function(VerifyPhone) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? phoneNumber = null,Object? phoneCountryCode = null,Object? requiredVerifications = null,Object? currentStep = null,Object? totalSteps = null,}) {
  return _then(VerifyPhone(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,phoneCountryCode: null == phoneCountryCode ? _self.phoneCountryCode : phoneCountryCode // ignore: cast_nullable_to_non_nullable
as String,requiredVerifications: null == requiredVerifications ? _self._requiredVerifications : requiredVerifications // ignore: cast_nullable_to_non_nullable
as List<VerificationType>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SignupState
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


class VerifyEmail implements SignupState {
  const VerifyEmail({this.flow = const UIFlow.established(), required this.email,  List<VerificationType> requiredVerifications = const [], this.currentStep = 2, this.totalSteps = 4}): _requiredVerifications = requiredVerifications;
  

@override@JsonKey() final  UIFlow flow;
 final  String email;
 final  List<VerificationType> _requiredVerifications;
@JsonKey() List<VerificationType> get requiredVerifications {
  if (_requiredVerifications is EqualUnmodifiableListView) return _requiredVerifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredVerifications);
}

@JsonKey() final  int currentStep;
@JsonKey() final  int totalSteps;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyEmailCopyWith<VerifyEmail> get copyWith => _$VerifyEmailCopyWithImpl<VerifyEmail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyEmail&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.requiredVerifications, _requiredVerifications)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,email,const DeepCollectionEquality().hash(_requiredVerifications),currentStep,totalSteps);
}

@override
String toString() {
    return 'SignupState.verifyEmail(flow: $flow, email: $email, requiredVerifications: $requiredVerifications, currentStep: $currentStep, totalSteps: $totalSteps)';
}


}

/// @nodoc
abstract mixin class $VerifyEmailCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $VerifyEmailCopyWith(VerifyEmail value, $Res Function(VerifyEmail) _then) = _$VerifyEmailCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, String email, List<VerificationType> requiredVerifications, int currentStep, int totalSteps
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$VerifyEmailCopyWithImpl<$Res>
    implements $VerifyEmailCopyWith<$Res> {
  _$VerifyEmailCopyWithImpl(this._self, this._then);

  final VerifyEmail _self;
  final $Res Function(VerifyEmail) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? email = null,Object? requiredVerifications = null,Object? currentStep = null,Object? totalSteps = null,}) {
  return _then(VerifyEmail(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,requiredVerifications: null == requiredVerifications ? _self._requiredVerifications : requiredVerifications // ignore: cast_nullable_to_non_nullable
as List<VerificationType>,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SignupState
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


class OfferAddPayment implements SignupState {
  const OfferAddPayment({this.flow = const UIFlow.established(), this.currentStep = 4, this.totalSteps = 4});
  

@override@JsonKey() final  UIFlow flow;
@JsonKey() final  int currentStep;
@JsonKey() final  int totalSteps;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferAddPaymentCopyWith<OfferAddPayment> get copyWith => _$OfferAddPaymentCopyWithImpl<OfferAddPayment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferAddPayment&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,currentStep,totalSteps);
}

@override
String toString() {
    return 'SignupState.offerAddPayment(flow: $flow, currentStep: $currentStep, totalSteps: $totalSteps)';
}


}

/// @nodoc
abstract mixin class $OfferAddPaymentCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $OfferAddPaymentCopyWith(OfferAddPayment value, $Res Function(OfferAddPayment) _then) = _$OfferAddPaymentCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, int currentStep, int totalSteps
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$OfferAddPaymentCopyWithImpl<$Res>
    implements $OfferAddPaymentCopyWith<$Res> {
  _$OfferAddPaymentCopyWithImpl(this._self, this._then);

  final OfferAddPayment _self;
  final $Res Function(OfferAddPayment) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? currentStep = null,Object? totalSteps = null,}) {
  return _then(OfferAddPayment(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SignupState
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


class OfferMfaSetup implements SignupState {
  const OfferMfaSetup({this.flow = const UIFlow.established(), this.currentStep = 5, this.totalSteps = 5});
  

@override@JsonKey() final  UIFlow flow;
@JsonKey() final  int currentStep;
@JsonKey() final  int totalSteps;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferMfaSetupCopyWith<OfferMfaSetup> get copyWith => _$OfferMfaSetupCopyWithImpl<OfferMfaSetup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferMfaSetup&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,currentStep,totalSteps);
}

@override
String toString() {
    return 'SignupState.offerMfaSetup(flow: $flow, currentStep: $currentStep, totalSteps: $totalSteps)';
}


}

/// @nodoc
abstract mixin class $OfferMfaSetupCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $OfferMfaSetupCopyWith(OfferMfaSetup value, $Res Function(OfferMfaSetup) _then) = _$OfferMfaSetupCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, int currentStep, int totalSteps
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$OfferMfaSetupCopyWithImpl<$Res>
    implements $OfferMfaSetupCopyWith<$Res> {
  _$OfferMfaSetupCopyWithImpl(this._self, this._then);

  final OfferMfaSetup _self;
  final $Res Function(OfferMfaSetup) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? currentStep = null,Object? totalSteps = null,}) {
  return _then(OfferMfaSetup(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SignupState
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


class SignupCompleted implements SignupState {
  const SignupCompleted({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignupCompletedCopyWith<SignupCompleted> get copyWith => _$SignupCompletedCopyWithImpl<SignupCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SignupCompleted&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'SignupState.completed(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $SignupCompletedCopyWith<$Res> implements $SignupStateCopyWith<$Res> {
  factory $SignupCompletedCopyWith(SignupCompleted value, $Res Function(SignupCompleted) _then) = _$SignupCompletedCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$SignupCompletedCopyWithImpl<$Res>
    implements $SignupCompletedCopyWith<$Res> {
  _$SignupCompletedCopyWithImpl(this._self, this._then);

  final SignupCompleted _self;
  final $Res Function(SignupCompleted) _then;

/// Create a copy of SignupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(SignupCompleted(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of SignupState
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
