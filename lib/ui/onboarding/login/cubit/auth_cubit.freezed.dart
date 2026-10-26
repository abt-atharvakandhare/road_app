// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 UIFlow get flow;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ShowSplash value)?  showSplash,TResult Function( LoggedOut value)?  loggedOut,TResult Function( LoggedIn value)?  loggedIn,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ShowSplash() when showSplash != null:
return showSplash(_that);case LoggedOut() when loggedOut != null:
return loggedOut(_that);case LoggedIn() when loggedIn != null:
return loggedIn(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ShowSplash value)  showSplash,required TResult Function( LoggedOut value)  loggedOut,required TResult Function( LoggedIn value)  loggedIn,}){
final _that = this;
switch (_that) {
case ShowSplash():
return showSplash(_that);case LoggedOut():
return loggedOut(_that);case LoggedIn():
return loggedIn(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ShowSplash value)?  showSplash,TResult? Function( LoggedOut value)?  loggedOut,TResult? Function( LoggedIn value)?  loggedIn,}){
final _that = this;
switch (_that) {
case ShowSplash() when showSplash != null:
return showSplash(_that);case LoggedOut() when loggedOut != null:
return loggedOut(_that);case LoggedIn() when loggedIn != null:
return loggedIn(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow)?  showSplash,TResult Function( ProviderResponseModel? providerModel,  TwoFactorAuth? twoFactorAuth,  bool sessionExpired,  UIFlow flow)?  loggedOut,TResult Function( AccountDetailsModel profile,  String token,  bool sessionEnding,  UIFlow flow)?  loggedIn,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ShowSplash() when showSplash != null:
return showSplash(_that.flow);case LoggedOut() when loggedOut != null:
return loggedOut(_that.providerModel,_that.twoFactorAuth,_that.sessionExpired,_that.flow);case LoggedIn() when loggedIn != null:
return loggedIn(_that.profile,_that.token,_that.sessionEnding,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow)  showSplash,required TResult Function( ProviderResponseModel? providerModel,  TwoFactorAuth? twoFactorAuth,  bool sessionExpired,  UIFlow flow)  loggedOut,required TResult Function( AccountDetailsModel profile,  String token,  bool sessionEnding,  UIFlow flow)  loggedIn,}) {final _that = this;
switch (_that) {
case ShowSplash():
return showSplash(_that.flow);case LoggedOut():
return loggedOut(_that.providerModel,_that.twoFactorAuth,_that.sessionExpired,_that.flow);case LoggedIn():
return loggedIn(_that.profile,_that.token,_that.sessionEnding,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow)?  showSplash,TResult? Function( ProviderResponseModel? providerModel,  TwoFactorAuth? twoFactorAuth,  bool sessionExpired,  UIFlow flow)?  loggedOut,TResult? Function( AccountDetailsModel profile,  String token,  bool sessionEnding,  UIFlow flow)?  loggedIn,}) {final _that = this;
switch (_that) {
case ShowSplash() when showSplash != null:
return showSplash(_that.flow);case LoggedOut() when loggedOut != null:
return loggedOut(_that.providerModel,_that.twoFactorAuth,_that.sessionExpired,_that.flow);case LoggedIn() when loggedIn != null:
return loggedIn(_that.profile,_that.token,_that.sessionEnding,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class ShowSplash implements AuthState {
  const ShowSplash({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowSplashCopyWith<ShowSplash> get copyWith => _$ShowSplashCopyWithImpl<ShowSplash>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowSplash&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString() {
    return 'AuthState.showSplash(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $ShowSplashCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $ShowSplashCopyWith(ShowSplash value, $Res Function(ShowSplash) _then) = _$ShowSplashCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ShowSplashCopyWithImpl<$Res>
    implements $ShowSplashCopyWith<$Res> {
  _$ShowSplashCopyWithImpl(this._self, this._then);

  final ShowSplash _self;
  final $Res Function(ShowSplash) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(ShowSplash(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AuthState
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


class LoggedOut implements AuthState {
  const LoggedOut({this.providerModel, this.twoFactorAuth, this.sessionExpired = false, this.flow = const UIFlow.established()});
  

 final  ProviderResponseModel? providerModel;
 final  TwoFactorAuth? twoFactorAuth;
@JsonKey() final  bool sessionExpired;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedOutCopyWith<LoggedOut> get copyWith => _$LoggedOutCopyWithImpl<LoggedOut>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedOut&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel)&&(identical(other.twoFactorAuth, twoFactorAuth) || other.twoFactorAuth == twoFactorAuth)&&(identical(other.sessionExpired, sessionExpired) || other.sessionExpired == sessionExpired)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,providerModel,twoFactorAuth,sessionExpired,flow);
}

@override
String toString() {
    return 'AuthState.loggedOut(providerModel: $providerModel, twoFactorAuth: $twoFactorAuth, sessionExpired: $sessionExpired, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $LoggedOutCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $LoggedOutCopyWith(LoggedOut value, $Res Function(LoggedOut) _then) = _$LoggedOutCopyWithImpl;
@override @useResult
$Res call({
 ProviderResponseModel? providerModel, TwoFactorAuth? twoFactorAuth, bool sessionExpired, UIFlow flow
});


$TwoFactorAuthCopyWith<$Res>? get twoFactorAuth;@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$LoggedOutCopyWithImpl<$Res>
    implements $LoggedOutCopyWith<$Res> {
  _$LoggedOutCopyWithImpl(this._self, this._then);

  final LoggedOut _self;
  final $Res Function(LoggedOut) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerModel = freezed,Object? twoFactorAuth = freezed,Object? sessionExpired = null,Object? flow = null,}) {
  return _then(LoggedOut(
providerModel: freezed == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel?,twoFactorAuth: freezed == twoFactorAuth ? _self.twoFactorAuth : twoFactorAuth // ignore: cast_nullable_to_non_nullable
as TwoFactorAuth?,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TwoFactorAuthCopyWith<$Res>? get twoFactorAuth {
    if (_self.twoFactorAuth == null) {
    return null;
  }

  return $TwoFactorAuthCopyWith<$Res>(_self.twoFactorAuth!, (value) {
    return _then(_self.copyWith(twoFactorAuth: value));
  });
}/// Create a copy of AuthState
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


class LoggedIn implements AuthState {
  const LoggedIn(this.profile, this.token, {this.sessionEnding = false, this.flow = const UIFlow.established()});
  

 final  AccountDetailsModel profile;
 final  String token;
@JsonKey() final  bool sessionEnding;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedInCopyWith<LoggedIn> get copyWith => _$LoggedInCopyWithImpl<LoggedIn>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedIn&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.token, token) || other.token == token)&&(identical(other.sessionEnding, sessionEnding) || other.sessionEnding == sessionEnding)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profile,token,sessionEnding,flow);
}

@override
String toString() {
    return 'AuthState.loggedIn(profile: $profile, token: $token, sessionEnding: $sessionEnding, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $LoggedInCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $LoggedInCopyWith(LoggedIn value, $Res Function(LoggedIn) _then) = _$LoggedInCopyWithImpl;
@override @useResult
$Res call({
 AccountDetailsModel profile, String token, bool sessionEnding, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$LoggedInCopyWithImpl<$Res>
    implements $LoggedInCopyWith<$Res> {
  _$LoggedInCopyWithImpl(this._self, this._then);

  final LoggedIn _self;
  final $Res Function(LoggedIn) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? token = null,Object? sessionEnding = null,Object? flow = null,}) {
  return _then(LoggedIn(
null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as AccountDetailsModel,null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,sessionEnding: null == sessionEnding ? _self.sessionEnding : sessionEnding // ignore: cast_nullable_to_non_nullable
as bool,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of AuthState
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
mixin _$TwoFactorAuth {

 String get email; ProviderResponseModel get providerModel;
/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthCopyWith<TwoFactorAuth> get copyWith => _$TwoFactorAuthCopyWithImpl<TwoFactorAuth>(this as TwoFactorAuth, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TwoFactorAuth;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuth&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.providerModel, _this.providerModel) || other.providerModel == _this.providerModel));
}


@override
int get hashCode {
  final _this = this as TwoFactorAuth;
  return Object.hash(runtimeType,_this.email,_this.providerModel);
}

@override
String toString() {
  final _this = this as TwoFactorAuth;
  return 'TwoFactorAuth(email: ${_this.email}, providerModel: ${_this.providerModel})';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthCopyWith<$Res>  {
  factory $TwoFactorAuthCopyWith(TwoFactorAuth value, $Res Function(TwoFactorAuth) _then) = _$TwoFactorAuthCopyWithImpl;
@useResult
$Res call({
 String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthCopyWithImpl<$Res>
    implements $TwoFactorAuthCopyWith<$Res> {
  _$TwoFactorAuthCopyWithImpl(this._self, this._then);

  final TwoFactorAuth _self;
  final $Res Function(TwoFactorAuth) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? providerModel = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}

}


/// Adds pattern-matching-related methods to [TwoFactorAuth].
extension TwoFactorAuthPatterns on TwoFactorAuth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TwoFactorAuthOtp value)?  authenticatorApp,TResult Function( TwoFactorAuthSms value)?  sms,TResult Function( TwoFactorAuthUseBackupCode value)?  useBackupCode,TResult Function( TwoFactorAuthMethodPicker value)?  methodPicker,TResult Function( TwoFactorAuthPendingTotp value)?  pendingTotp,TResult Function( TwoFactorAuthPendingSms value)?  pendingSms,TResult Function( TwoFactorAuthPendingPasskey value)?  pendingPasskey,TResult Function( TwoFactorAuthPendingRecoveryCode value)?  pendingRecoveryCode,TResult Function( TwoFactorAuthVerifyEmail value)?  verifyEmail,TResult Function( TwoFactorAuthEnrolIntro value)?  enrolIntro,TResult Function( TwoFactorAuthEnrolEmailProof value)?  enrolEmailProof,TResult Function( TwoFactorAuthEnrolMethodPicker value)?  enrolMethodPicker,TResult Function( TwoFactorAuthEnrolTotp value)?  enrolTotp,TResult Function( TwoFactorAuthEnrolSms value)?  enrolSms,TResult Function( TwoFactorAuthEnrolPasskey value)?  enrolPasskey,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TwoFactorAuthOtp() when authenticatorApp != null:
return authenticatorApp(_that);case TwoFactorAuthSms() when sms != null:
return sms(_that);case TwoFactorAuthUseBackupCode() when useBackupCode != null:
return useBackupCode(_that);case TwoFactorAuthMethodPicker() when methodPicker != null:
return methodPicker(_that);case TwoFactorAuthPendingTotp() when pendingTotp != null:
return pendingTotp(_that);case TwoFactorAuthPendingSms() when pendingSms != null:
return pendingSms(_that);case TwoFactorAuthPendingPasskey() when pendingPasskey != null:
return pendingPasskey(_that);case TwoFactorAuthPendingRecoveryCode() when pendingRecoveryCode != null:
return pendingRecoveryCode(_that);case TwoFactorAuthVerifyEmail() when verifyEmail != null:
return verifyEmail(_that);case TwoFactorAuthEnrolIntro() when enrolIntro != null:
return enrolIntro(_that);case TwoFactorAuthEnrolEmailProof() when enrolEmailProof != null:
return enrolEmailProof(_that);case TwoFactorAuthEnrolMethodPicker() when enrolMethodPicker != null:
return enrolMethodPicker(_that);case TwoFactorAuthEnrolTotp() when enrolTotp != null:
return enrolTotp(_that);case TwoFactorAuthEnrolSms() when enrolSms != null:
return enrolSms(_that);case TwoFactorAuthEnrolPasskey() when enrolPasskey != null:
return enrolPasskey(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TwoFactorAuthOtp value)  authenticatorApp,required TResult Function( TwoFactorAuthSms value)  sms,required TResult Function( TwoFactorAuthUseBackupCode value)  useBackupCode,required TResult Function( TwoFactorAuthMethodPicker value)  methodPicker,required TResult Function( TwoFactorAuthPendingTotp value)  pendingTotp,required TResult Function( TwoFactorAuthPendingSms value)  pendingSms,required TResult Function( TwoFactorAuthPendingPasskey value)  pendingPasskey,required TResult Function( TwoFactorAuthPendingRecoveryCode value)  pendingRecoveryCode,required TResult Function( TwoFactorAuthVerifyEmail value)  verifyEmail,required TResult Function( TwoFactorAuthEnrolIntro value)  enrolIntro,required TResult Function( TwoFactorAuthEnrolEmailProof value)  enrolEmailProof,required TResult Function( TwoFactorAuthEnrolMethodPicker value)  enrolMethodPicker,required TResult Function( TwoFactorAuthEnrolTotp value)  enrolTotp,required TResult Function( TwoFactorAuthEnrolSms value)  enrolSms,required TResult Function( TwoFactorAuthEnrolPasskey value)  enrolPasskey,}){
final _that = this;
switch (_that) {
case TwoFactorAuthOtp():
return authenticatorApp(_that);case TwoFactorAuthSms():
return sms(_that);case TwoFactorAuthUseBackupCode():
return useBackupCode(_that);case TwoFactorAuthMethodPicker():
return methodPicker(_that);case TwoFactorAuthPendingTotp():
return pendingTotp(_that);case TwoFactorAuthPendingSms():
return pendingSms(_that);case TwoFactorAuthPendingPasskey():
return pendingPasskey(_that);case TwoFactorAuthPendingRecoveryCode():
return pendingRecoveryCode(_that);case TwoFactorAuthVerifyEmail():
return verifyEmail(_that);case TwoFactorAuthEnrolIntro():
return enrolIntro(_that);case TwoFactorAuthEnrolEmailProof():
return enrolEmailProof(_that);case TwoFactorAuthEnrolMethodPicker():
return enrolMethodPicker(_that);case TwoFactorAuthEnrolTotp():
return enrolTotp(_that);case TwoFactorAuthEnrolSms():
return enrolSms(_that);case TwoFactorAuthEnrolPasskey():
return enrolPasskey(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TwoFactorAuthOtp value)?  authenticatorApp,TResult? Function( TwoFactorAuthSms value)?  sms,TResult? Function( TwoFactorAuthUseBackupCode value)?  useBackupCode,TResult? Function( TwoFactorAuthMethodPicker value)?  methodPicker,TResult? Function( TwoFactorAuthPendingTotp value)?  pendingTotp,TResult? Function( TwoFactorAuthPendingSms value)?  pendingSms,TResult? Function( TwoFactorAuthPendingPasskey value)?  pendingPasskey,TResult? Function( TwoFactorAuthPendingRecoveryCode value)?  pendingRecoveryCode,TResult? Function( TwoFactorAuthVerifyEmail value)?  verifyEmail,TResult? Function( TwoFactorAuthEnrolIntro value)?  enrolIntro,TResult? Function( TwoFactorAuthEnrolEmailProof value)?  enrolEmailProof,TResult? Function( TwoFactorAuthEnrolMethodPicker value)?  enrolMethodPicker,TResult? Function( TwoFactorAuthEnrolTotp value)?  enrolTotp,TResult? Function( TwoFactorAuthEnrolSms value)?  enrolSms,TResult? Function( TwoFactorAuthEnrolPasskey value)?  enrolPasskey,}){
final _that = this;
switch (_that) {
case TwoFactorAuthOtp() when authenticatorApp != null:
return authenticatorApp(_that);case TwoFactorAuthSms() when sms != null:
return sms(_that);case TwoFactorAuthUseBackupCode() when useBackupCode != null:
return useBackupCode(_that);case TwoFactorAuthMethodPicker() when methodPicker != null:
return methodPicker(_that);case TwoFactorAuthPendingTotp() when pendingTotp != null:
return pendingTotp(_that);case TwoFactorAuthPendingSms() when pendingSms != null:
return pendingSms(_that);case TwoFactorAuthPendingPasskey() when pendingPasskey != null:
return pendingPasskey(_that);case TwoFactorAuthPendingRecoveryCode() when pendingRecoveryCode != null:
return pendingRecoveryCode(_that);case TwoFactorAuthVerifyEmail() when verifyEmail != null:
return verifyEmail(_that);case TwoFactorAuthEnrolIntro() when enrolIntro != null:
return enrolIntro(_that);case TwoFactorAuthEnrolEmailProof() when enrolEmailProof != null:
return enrolEmailProof(_that);case TwoFactorAuthEnrolMethodPicker() when enrolMethodPicker != null:
return enrolMethodPicker(_that);case TwoFactorAuthEnrolTotp() when enrolTotp != null:
return enrolTotp(_that);case TwoFactorAuthEnrolSms() when enrolSms != null:
return enrolSms(_that);case TwoFactorAuthEnrolPasskey() when enrolPasskey != null:
return enrolPasskey(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String mfaToken,  String email,  ProviderResponseModel providerModel)?  authenticatorApp,TResult Function( String mfaToken,  String mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)?  sms,TResult Function( String mfaToken,  String? mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)?  useBackupCode,TResult Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)?  methodPicker,TResult Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)?  pendingTotp,TResult Function( MfaPendingChallengeModel challenge,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  pendingSms,TResult Function( MfaPendingChallengeModel challenge,  bool noCredential,  String email,  ProviderResponseModel providerModel)?  pendingPasskey,TResult Function( MfaPendingChallengeModel challenge,  String? smsHint,  String email,  ProviderResponseModel providerModel)?  pendingRecoveryCode,TResult Function( String pendingId,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  verifyEmail,TResult Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)?  enrolIntro,TResult Function( MfaEnrolmentModel enrolment,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  enrolEmailProof,TResult Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)?  enrolMethodPicker,TResult Function( MfaEnrolmentModel enrolment,  MfaEnrolTotpBeginModel totp,  String email,  ProviderResponseModel providerModel)?  enrolTotp,TResult Function( MfaEnrolmentModel enrolment,  String factorId,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  enrolSms,TResult Function( MfaEnrolmentModel enrolment,  bool deviceHasPasskey,  String email,  ProviderResponseModel providerModel)?  enrolPasskey,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TwoFactorAuthOtp() when authenticatorApp != null:
return authenticatorApp(_that.mfaToken,_that.email,_that.providerModel);case TwoFactorAuthSms() when sms != null:
return sms(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthUseBackupCode() when useBackupCode != null:
return useBackupCode(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthMethodPicker() when methodPicker != null:
return methodPicker(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingTotp() when pendingTotp != null:
return pendingTotp(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingSms() when pendingSms != null:
return pendingSms(_that.challenge,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthPendingPasskey() when pendingPasskey != null:
return pendingPasskey(_that.challenge,_that.noCredential,_that.email,_that.providerModel);case TwoFactorAuthPendingRecoveryCode() when pendingRecoveryCode != null:
return pendingRecoveryCode(_that.challenge,_that.smsHint,_that.email,_that.providerModel);case TwoFactorAuthVerifyEmail() when verifyEmail != null:
return verifyEmail(_that.pendingId,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolIntro() when enrolIntro != null:
return enrolIntro(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolEmailProof() when enrolEmailProof != null:
return enrolEmailProof(_that.enrolment,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolMethodPicker() when enrolMethodPicker != null:
return enrolMethodPicker(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolTotp() when enrolTotp != null:
return enrolTotp(_that.enrolment,_that.totp,_that.email,_that.providerModel);case TwoFactorAuthEnrolSms() when enrolSms != null:
return enrolSms(_that.enrolment,_that.factorId,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolPasskey() when enrolPasskey != null:
return enrolPasskey(_that.enrolment,_that.deviceHasPasskey,_that.email,_that.providerModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String mfaToken,  String email,  ProviderResponseModel providerModel)  authenticatorApp,required TResult Function( String mfaToken,  String mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)  sms,required TResult Function( String mfaToken,  String? mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)  useBackupCode,required TResult Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)  methodPicker,required TResult Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)  pendingTotp,required TResult Function( MfaPendingChallengeModel challenge,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)  pendingSms,required TResult Function( MfaPendingChallengeModel challenge,  bool noCredential,  String email,  ProviderResponseModel providerModel)  pendingPasskey,required TResult Function( MfaPendingChallengeModel challenge,  String? smsHint,  String email,  ProviderResponseModel providerModel)  pendingRecoveryCode,required TResult Function( String pendingId,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)  verifyEmail,required TResult Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)  enrolIntro,required TResult Function( MfaEnrolmentModel enrolment,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)  enrolEmailProof,required TResult Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)  enrolMethodPicker,required TResult Function( MfaEnrolmentModel enrolment,  MfaEnrolTotpBeginModel totp,  String email,  ProviderResponseModel providerModel)  enrolTotp,required TResult Function( MfaEnrolmentModel enrolment,  String factorId,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)  enrolSms,required TResult Function( MfaEnrolmentModel enrolment,  bool deviceHasPasskey,  String email,  ProviderResponseModel providerModel)  enrolPasskey,}) {final _that = this;
switch (_that) {
case TwoFactorAuthOtp():
return authenticatorApp(_that.mfaToken,_that.email,_that.providerModel);case TwoFactorAuthSms():
return sms(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthUseBackupCode():
return useBackupCode(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthMethodPicker():
return methodPicker(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingTotp():
return pendingTotp(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingSms():
return pendingSms(_that.challenge,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthPendingPasskey():
return pendingPasskey(_that.challenge,_that.noCredential,_that.email,_that.providerModel);case TwoFactorAuthPendingRecoveryCode():
return pendingRecoveryCode(_that.challenge,_that.smsHint,_that.email,_that.providerModel);case TwoFactorAuthVerifyEmail():
return verifyEmail(_that.pendingId,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolIntro():
return enrolIntro(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolEmailProof():
return enrolEmailProof(_that.enrolment,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolMethodPicker():
return enrolMethodPicker(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolTotp():
return enrolTotp(_that.enrolment,_that.totp,_that.email,_that.providerModel);case TwoFactorAuthEnrolSms():
return enrolSms(_that.enrolment,_that.factorId,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolPasskey():
return enrolPasskey(_that.enrolment,_that.deviceHasPasskey,_that.email,_that.providerModel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String mfaToken,  String email,  ProviderResponseModel providerModel)?  authenticatorApp,TResult? Function( String mfaToken,  String mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)?  sms,TResult? Function( String mfaToken,  String? mfaPhoneNumber,  String email,  ProviderResponseModel providerModel)?  useBackupCode,TResult? Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)?  methodPicker,TResult? Function( MfaPendingChallengeModel challenge,  String email,  ProviderResponseModel providerModel)?  pendingTotp,TResult? Function( MfaPendingChallengeModel challenge,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  pendingSms,TResult? Function( MfaPendingChallengeModel challenge,  bool noCredential,  String email,  ProviderResponseModel providerModel)?  pendingPasskey,TResult? Function( MfaPendingChallengeModel challenge,  String? smsHint,  String email,  ProviderResponseModel providerModel)?  pendingRecoveryCode,TResult? Function( String pendingId,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  verifyEmail,TResult? Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)?  enrolIntro,TResult? Function( MfaEnrolmentModel enrolment,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  enrolEmailProof,TResult? Function( MfaEnrolmentModel enrolment,  String email,  ProviderResponseModel providerModel)?  enrolMethodPicker,TResult? Function( MfaEnrolmentModel enrolment,  MfaEnrolTotpBeginModel totp,  String email,  ProviderResponseModel providerModel)?  enrolTotp,TResult? Function( MfaEnrolmentModel enrolment,  String factorId,  String? hint,  int? nextSendAfterSeconds,  String email,  ProviderResponseModel providerModel)?  enrolSms,TResult? Function( MfaEnrolmentModel enrolment,  bool deviceHasPasskey,  String email,  ProviderResponseModel providerModel)?  enrolPasskey,}) {final _that = this;
switch (_that) {
case TwoFactorAuthOtp() when authenticatorApp != null:
return authenticatorApp(_that.mfaToken,_that.email,_that.providerModel);case TwoFactorAuthSms() when sms != null:
return sms(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthUseBackupCode() when useBackupCode != null:
return useBackupCode(_that.mfaToken,_that.mfaPhoneNumber,_that.email,_that.providerModel);case TwoFactorAuthMethodPicker() when methodPicker != null:
return methodPicker(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingTotp() when pendingTotp != null:
return pendingTotp(_that.challenge,_that.email,_that.providerModel);case TwoFactorAuthPendingSms() when pendingSms != null:
return pendingSms(_that.challenge,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthPendingPasskey() when pendingPasskey != null:
return pendingPasskey(_that.challenge,_that.noCredential,_that.email,_that.providerModel);case TwoFactorAuthPendingRecoveryCode() when pendingRecoveryCode != null:
return pendingRecoveryCode(_that.challenge,_that.smsHint,_that.email,_that.providerModel);case TwoFactorAuthVerifyEmail() when verifyEmail != null:
return verifyEmail(_that.pendingId,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolIntro() when enrolIntro != null:
return enrolIntro(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolEmailProof() when enrolEmailProof != null:
return enrolEmailProof(_that.enrolment,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolMethodPicker() when enrolMethodPicker != null:
return enrolMethodPicker(_that.enrolment,_that.email,_that.providerModel);case TwoFactorAuthEnrolTotp() when enrolTotp != null:
return enrolTotp(_that.enrolment,_that.totp,_that.email,_that.providerModel);case TwoFactorAuthEnrolSms() when enrolSms != null:
return enrolSms(_that.enrolment,_that.factorId,_that.hint,_that.nextSendAfterSeconds,_that.email,_that.providerModel);case TwoFactorAuthEnrolPasskey() when enrolPasskey != null:
return enrolPasskey(_that.enrolment,_that.deviceHasPasskey,_that.email,_that.providerModel);case _:
  return null;

}
}

}

/// @nodoc


class TwoFactorAuthOtp extends TwoFactorAuth {
  const TwoFactorAuthOtp({required this.mfaToken, required this.email, required this.providerModel}): super._();
  

 final  String mfaToken;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthOtpCopyWith<TwoFactorAuthOtp> get copyWith => _$TwoFactorAuthOtpCopyWithImpl<TwoFactorAuthOtp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthOtp&&(identical(other.mfaToken, mfaToken) || other.mfaToken == mfaToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mfaToken,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.authenticatorApp(mfaToken: $mfaToken, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthOtpCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthOtpCopyWith(TwoFactorAuthOtp value, $Res Function(TwoFactorAuthOtp) _then) = _$TwoFactorAuthOtpCopyWithImpl;
@override @useResult
$Res call({
 String mfaToken, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthOtpCopyWithImpl<$Res>
    implements $TwoFactorAuthOtpCopyWith<$Res> {
  _$TwoFactorAuthOtpCopyWithImpl(this._self, this._then);

  final TwoFactorAuthOtp _self;
  final $Res Function(TwoFactorAuthOtp) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mfaToken = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthOtp(
mfaToken: null == mfaToken ? _self.mfaToken : mfaToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthSms extends TwoFactorAuth {
  const TwoFactorAuthSms({required this.mfaToken, required this.mfaPhoneNumber, required this.email, required this.providerModel}): super._();
  

 final  String mfaToken;
 final  String mfaPhoneNumber;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthSmsCopyWith<TwoFactorAuthSms> get copyWith => _$TwoFactorAuthSmsCopyWithImpl<TwoFactorAuthSms>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthSms&&(identical(other.mfaToken, mfaToken) || other.mfaToken == mfaToken)&&(identical(other.mfaPhoneNumber, mfaPhoneNumber) || other.mfaPhoneNumber == mfaPhoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mfaToken,mfaPhoneNumber,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.sms(mfaToken: $mfaToken, mfaPhoneNumber: $mfaPhoneNumber, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthSmsCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthSmsCopyWith(TwoFactorAuthSms value, $Res Function(TwoFactorAuthSms) _then) = _$TwoFactorAuthSmsCopyWithImpl;
@override @useResult
$Res call({
 String mfaToken, String mfaPhoneNumber, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthSmsCopyWithImpl<$Res>
    implements $TwoFactorAuthSmsCopyWith<$Res> {
  _$TwoFactorAuthSmsCopyWithImpl(this._self, this._then);

  final TwoFactorAuthSms _self;
  final $Res Function(TwoFactorAuthSms) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mfaToken = null,Object? mfaPhoneNumber = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthSms(
mfaToken: null == mfaToken ? _self.mfaToken : mfaToken // ignore: cast_nullable_to_non_nullable
as String,mfaPhoneNumber: null == mfaPhoneNumber ? _self.mfaPhoneNumber : mfaPhoneNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthUseBackupCode extends TwoFactorAuth {
  const TwoFactorAuthUseBackupCode({required this.mfaToken, required this.mfaPhoneNumber, required this.email, required this.providerModel}): super._();
  

 final  String mfaToken;
 final  String? mfaPhoneNumber;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthUseBackupCodeCopyWith<TwoFactorAuthUseBackupCode> get copyWith => _$TwoFactorAuthUseBackupCodeCopyWithImpl<TwoFactorAuthUseBackupCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthUseBackupCode&&(identical(other.mfaToken, mfaToken) || other.mfaToken == mfaToken)&&(identical(other.mfaPhoneNumber, mfaPhoneNumber) || other.mfaPhoneNumber == mfaPhoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mfaToken,mfaPhoneNumber,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.useBackupCode(mfaToken: $mfaToken, mfaPhoneNumber: $mfaPhoneNumber, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthUseBackupCodeCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthUseBackupCodeCopyWith(TwoFactorAuthUseBackupCode value, $Res Function(TwoFactorAuthUseBackupCode) _then) = _$TwoFactorAuthUseBackupCodeCopyWithImpl;
@override @useResult
$Res call({
 String mfaToken, String? mfaPhoneNumber, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthUseBackupCodeCopyWithImpl<$Res>
    implements $TwoFactorAuthUseBackupCodeCopyWith<$Res> {
  _$TwoFactorAuthUseBackupCodeCopyWithImpl(this._self, this._then);

  final TwoFactorAuthUseBackupCode _self;
  final $Res Function(TwoFactorAuthUseBackupCode) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mfaToken = null,Object? mfaPhoneNumber = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthUseBackupCode(
mfaToken: null == mfaToken ? _self.mfaToken : mfaToken // ignore: cast_nullable_to_non_nullable
as String,mfaPhoneNumber: freezed == mfaPhoneNumber ? _self.mfaPhoneNumber : mfaPhoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthMethodPicker extends TwoFactorAuth {
  const TwoFactorAuthMethodPicker({required this.challenge, required this.email, required this.providerModel}): super._();
  

 final  MfaPendingChallengeModel challenge;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthMethodPickerCopyWith<TwoFactorAuthMethodPicker> get copyWith => _$TwoFactorAuthMethodPickerCopyWithImpl<TwoFactorAuthMethodPicker>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthMethodPicker&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challenge,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.methodPicker(challenge: $challenge, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthMethodPickerCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthMethodPickerCopyWith(TwoFactorAuthMethodPicker value, $Res Function(TwoFactorAuthMethodPicker) _then) = _$TwoFactorAuthMethodPickerCopyWithImpl;
@override @useResult
$Res call({
 MfaPendingChallengeModel challenge, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthMethodPickerCopyWithImpl<$Res>
    implements $TwoFactorAuthMethodPickerCopyWith<$Res> {
  _$TwoFactorAuthMethodPickerCopyWithImpl(this._self, this._then);

  final TwoFactorAuthMethodPicker _self;
  final $Res Function(TwoFactorAuthMethodPicker) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthMethodPicker(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as MfaPendingChallengeModel,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthPendingTotp extends TwoFactorAuth {
  const TwoFactorAuthPendingTotp({required this.challenge, required this.email, required this.providerModel}): super._();
  

 final  MfaPendingChallengeModel challenge;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthPendingTotpCopyWith<TwoFactorAuthPendingTotp> get copyWith => _$TwoFactorAuthPendingTotpCopyWithImpl<TwoFactorAuthPendingTotp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthPendingTotp&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challenge,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.pendingTotp(challenge: $challenge, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthPendingTotpCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthPendingTotpCopyWith(TwoFactorAuthPendingTotp value, $Res Function(TwoFactorAuthPendingTotp) _then) = _$TwoFactorAuthPendingTotpCopyWithImpl;
@override @useResult
$Res call({
 MfaPendingChallengeModel challenge, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthPendingTotpCopyWithImpl<$Res>
    implements $TwoFactorAuthPendingTotpCopyWith<$Res> {
  _$TwoFactorAuthPendingTotpCopyWithImpl(this._self, this._then);

  final TwoFactorAuthPendingTotp _self;
  final $Res Function(TwoFactorAuthPendingTotp) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthPendingTotp(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as MfaPendingChallengeModel,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthPendingSms extends TwoFactorAuth {
  const TwoFactorAuthPendingSms({required this.challenge, this.hint, this.nextSendAfterSeconds, required this.email, required this.providerModel}): super._();
  

 final  MfaPendingChallengeModel challenge;
 final  String? hint;
 final  int? nextSendAfterSeconds;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthPendingSmsCopyWith<TwoFactorAuthPendingSms> get copyWith => _$TwoFactorAuthPendingSmsCopyWithImpl<TwoFactorAuthPendingSms>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthPendingSms&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challenge,hint,nextSendAfterSeconds,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.pendingSms(challenge: $challenge, hint: $hint, nextSendAfterSeconds: $nextSendAfterSeconds, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthPendingSmsCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthPendingSmsCopyWith(TwoFactorAuthPendingSms value, $Res Function(TwoFactorAuthPendingSms) _then) = _$TwoFactorAuthPendingSmsCopyWithImpl;
@override @useResult
$Res call({
 MfaPendingChallengeModel challenge, String? hint, int? nextSendAfterSeconds, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthPendingSmsCopyWithImpl<$Res>
    implements $TwoFactorAuthPendingSmsCopyWith<$Res> {
  _$TwoFactorAuthPendingSmsCopyWithImpl(this._self, this._then);

  final TwoFactorAuthPendingSms _self;
  final $Res Function(TwoFactorAuthPendingSms) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? hint = freezed,Object? nextSendAfterSeconds = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthPendingSms(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as MfaPendingChallengeModel,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthPendingPasskey extends TwoFactorAuth {
  const TwoFactorAuthPendingPasskey({required this.challenge, this.noCredential = false, required this.email, required this.providerModel}): super._();
  

 final  MfaPendingChallengeModel challenge;
@JsonKey() final  bool noCredential;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthPendingPasskeyCopyWith<TwoFactorAuthPendingPasskey> get copyWith => _$TwoFactorAuthPendingPasskeyCopyWithImpl<TwoFactorAuthPendingPasskey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthPendingPasskey&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.noCredential, noCredential) || other.noCredential == noCredential)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challenge,noCredential,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.pendingPasskey(challenge: $challenge, noCredential: $noCredential, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthPendingPasskeyCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthPendingPasskeyCopyWith(TwoFactorAuthPendingPasskey value, $Res Function(TwoFactorAuthPendingPasskey) _then) = _$TwoFactorAuthPendingPasskeyCopyWithImpl;
@override @useResult
$Res call({
 MfaPendingChallengeModel challenge, bool noCredential, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthPendingPasskeyCopyWithImpl<$Res>
    implements $TwoFactorAuthPendingPasskeyCopyWith<$Res> {
  _$TwoFactorAuthPendingPasskeyCopyWithImpl(this._self, this._then);

  final TwoFactorAuthPendingPasskey _self;
  final $Res Function(TwoFactorAuthPendingPasskey) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? noCredential = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthPendingPasskey(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as MfaPendingChallengeModel,noCredential: null == noCredential ? _self.noCredential : noCredential // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthPendingRecoveryCode extends TwoFactorAuth {
  const TwoFactorAuthPendingRecoveryCode({required this.challenge, this.smsHint, required this.email, required this.providerModel}): super._();
  

 final  MfaPendingChallengeModel challenge;
 final  String? smsHint;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthPendingRecoveryCodeCopyWith<TwoFactorAuthPendingRecoveryCode> get copyWith => _$TwoFactorAuthPendingRecoveryCodeCopyWithImpl<TwoFactorAuthPendingRecoveryCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthPendingRecoveryCode&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.smsHint, smsHint) || other.smsHint == smsHint)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,challenge,smsHint,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.pendingRecoveryCode(challenge: $challenge, smsHint: $smsHint, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthPendingRecoveryCodeCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthPendingRecoveryCodeCopyWith(TwoFactorAuthPendingRecoveryCode value, $Res Function(TwoFactorAuthPendingRecoveryCode) _then) = _$TwoFactorAuthPendingRecoveryCodeCopyWithImpl;
@override @useResult
$Res call({
 MfaPendingChallengeModel challenge, String? smsHint, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthPendingRecoveryCodeCopyWithImpl<$Res>
    implements $TwoFactorAuthPendingRecoveryCodeCopyWith<$Res> {
  _$TwoFactorAuthPendingRecoveryCodeCopyWithImpl(this._self, this._then);

  final TwoFactorAuthPendingRecoveryCode _self;
  final $Res Function(TwoFactorAuthPendingRecoveryCode) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? smsHint = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthPendingRecoveryCode(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as MfaPendingChallengeModel,smsHint: freezed == smsHint ? _self.smsHint : smsHint // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthVerifyEmail extends TwoFactorAuth {
  const TwoFactorAuthVerifyEmail({required this.pendingId, this.nextSendAfterSeconds, required this.email, required this.providerModel}): super._();
  

 final  String pendingId;
 final  int? nextSendAfterSeconds;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthVerifyEmailCopyWith<TwoFactorAuthVerifyEmail> get copyWith => _$TwoFactorAuthVerifyEmailCopyWithImpl<TwoFactorAuthVerifyEmail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthVerifyEmail&&(identical(other.pendingId, pendingId) || other.pendingId == pendingId)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pendingId,nextSendAfterSeconds,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.verifyEmail(pendingId: $pendingId, nextSendAfterSeconds: $nextSendAfterSeconds, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthVerifyEmailCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthVerifyEmailCopyWith(TwoFactorAuthVerifyEmail value, $Res Function(TwoFactorAuthVerifyEmail) _then) = _$TwoFactorAuthVerifyEmailCopyWithImpl;
@override @useResult
$Res call({
 String pendingId, int? nextSendAfterSeconds, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthVerifyEmailCopyWithImpl<$Res>
    implements $TwoFactorAuthVerifyEmailCopyWith<$Res> {
  _$TwoFactorAuthVerifyEmailCopyWithImpl(this._self, this._then);

  final TwoFactorAuthVerifyEmail _self;
  final $Res Function(TwoFactorAuthVerifyEmail) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingId = null,Object? nextSendAfterSeconds = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthVerifyEmail(
pendingId: null == pendingId ? _self.pendingId : pendingId // ignore: cast_nullable_to_non_nullable
as String,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolIntro extends TwoFactorAuth {
  const TwoFactorAuthEnrolIntro({required this.enrolment, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolIntroCopyWith<TwoFactorAuthEnrolIntro> get copyWith => _$TwoFactorAuthEnrolIntroCopyWithImpl<TwoFactorAuthEnrolIntro>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolIntro&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolIntro(enrolment: $enrolment, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolIntroCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolIntroCopyWith(TwoFactorAuthEnrolIntro value, $Res Function(TwoFactorAuthEnrolIntro) _then) = _$TwoFactorAuthEnrolIntroCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolIntroCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolIntroCopyWith<$Res> {
  _$TwoFactorAuthEnrolIntroCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolIntro _self;
  final $Res Function(TwoFactorAuthEnrolIntro) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolIntro(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolEmailProof extends TwoFactorAuth {
  const TwoFactorAuthEnrolEmailProof({required this.enrolment, this.nextSendAfterSeconds, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
 final  int? nextSendAfterSeconds;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolEmailProofCopyWith<TwoFactorAuthEnrolEmailProof> get copyWith => _$TwoFactorAuthEnrolEmailProofCopyWithImpl<TwoFactorAuthEnrolEmailProof>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolEmailProof&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,nextSendAfterSeconds,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolEmailProof(enrolment: $enrolment, nextSendAfterSeconds: $nextSendAfterSeconds, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolEmailProofCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolEmailProofCopyWith(TwoFactorAuthEnrolEmailProof value, $Res Function(TwoFactorAuthEnrolEmailProof) _then) = _$TwoFactorAuthEnrolEmailProofCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, int? nextSendAfterSeconds, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolEmailProofCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolEmailProofCopyWith<$Res> {
  _$TwoFactorAuthEnrolEmailProofCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolEmailProof _self;
  final $Res Function(TwoFactorAuthEnrolEmailProof) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? nextSendAfterSeconds = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolEmailProof(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolMethodPicker extends TwoFactorAuth {
  const TwoFactorAuthEnrolMethodPicker({required this.enrolment, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolMethodPickerCopyWith<TwoFactorAuthEnrolMethodPicker> get copyWith => _$TwoFactorAuthEnrolMethodPickerCopyWithImpl<TwoFactorAuthEnrolMethodPicker>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolMethodPicker&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolMethodPicker(enrolment: $enrolment, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolMethodPickerCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolMethodPickerCopyWith(TwoFactorAuthEnrolMethodPicker value, $Res Function(TwoFactorAuthEnrolMethodPicker) _then) = _$TwoFactorAuthEnrolMethodPickerCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolMethodPickerCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolMethodPickerCopyWith<$Res> {
  _$TwoFactorAuthEnrolMethodPickerCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolMethodPicker _self;
  final $Res Function(TwoFactorAuthEnrolMethodPicker) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolMethodPicker(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolTotp extends TwoFactorAuth {
  const TwoFactorAuthEnrolTotp({required this.enrolment, required this.totp, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
 final  MfaEnrolTotpBeginModel totp;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolTotpCopyWith<TwoFactorAuthEnrolTotp> get copyWith => _$TwoFactorAuthEnrolTotpCopyWithImpl<TwoFactorAuthEnrolTotp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolTotp&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.totp, totp) || other.totp == totp)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,totp,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolTotp(enrolment: $enrolment, totp: $totp, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolTotpCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolTotpCopyWith(TwoFactorAuthEnrolTotp value, $Res Function(TwoFactorAuthEnrolTotp) _then) = _$TwoFactorAuthEnrolTotpCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, MfaEnrolTotpBeginModel totp, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolTotpCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolTotpCopyWith<$Res> {
  _$TwoFactorAuthEnrolTotpCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolTotp _self;
  final $Res Function(TwoFactorAuthEnrolTotp) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? totp = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolTotp(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,totp: null == totp ? _self.totp : totp // ignore: cast_nullable_to_non_nullable
as MfaEnrolTotpBeginModel,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolSms extends TwoFactorAuth {
  const TwoFactorAuthEnrolSms({required this.enrolment, required this.factorId, this.hint, this.nextSendAfterSeconds, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
 final  String factorId;
 final  String? hint;
 final  int? nextSendAfterSeconds;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolSmsCopyWith<TwoFactorAuthEnrolSms> get copyWith => _$TwoFactorAuthEnrolSmsCopyWithImpl<TwoFactorAuthEnrolSms>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolSms&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,factorId,hint,nextSendAfterSeconds,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolSms(enrolment: $enrolment, factorId: $factorId, hint: $hint, nextSendAfterSeconds: $nextSendAfterSeconds, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolSmsCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolSmsCopyWith(TwoFactorAuthEnrolSms value, $Res Function(TwoFactorAuthEnrolSms) _then) = _$TwoFactorAuthEnrolSmsCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, String factorId, String? hint, int? nextSendAfterSeconds, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolSmsCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolSmsCopyWith<$Res> {
  _$TwoFactorAuthEnrolSmsCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolSms _self;
  final $Res Function(TwoFactorAuthEnrolSms) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? factorId = null,Object? hint = freezed,Object? nextSendAfterSeconds = freezed,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolSms(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

/// @nodoc


class TwoFactorAuthEnrolPasskey extends TwoFactorAuth {
  const TwoFactorAuthEnrolPasskey({required this.enrolment, this.deviceHasPasskey = false, required this.email, required this.providerModel}): super._();
  

 final  MfaEnrolmentModel enrolment;
@JsonKey() final  bool deviceHasPasskey;
@override final  String email;
@override final  ProviderResponseModel providerModel;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TwoFactorAuthEnrolPasskeyCopyWith<TwoFactorAuthEnrolPasskey> get copyWith => _$TwoFactorAuthEnrolPasskeyCopyWithImpl<TwoFactorAuthEnrolPasskey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TwoFactorAuthEnrolPasskey&&(identical(other.enrolment, enrolment) || other.enrolment == enrolment)&&(identical(other.deviceHasPasskey, deviceHasPasskey) || other.deviceHasPasskey == deviceHasPasskey)&&(identical(other.email, email) || other.email == email)&&(identical(other.providerModel, providerModel) || other.providerModel == providerModel));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enrolment,deviceHasPasskey,email,providerModel);
}

@override
String toString() {
    return 'TwoFactorAuth.enrolPasskey(enrolment: $enrolment, deviceHasPasskey: $deviceHasPasskey, email: $email, providerModel: $providerModel)';
}


}

/// @nodoc
abstract mixin class $TwoFactorAuthEnrolPasskeyCopyWith<$Res> implements $TwoFactorAuthCopyWith<$Res> {
  factory $TwoFactorAuthEnrolPasskeyCopyWith(TwoFactorAuthEnrolPasskey value, $Res Function(TwoFactorAuthEnrolPasskey) _then) = _$TwoFactorAuthEnrolPasskeyCopyWithImpl;
@override @useResult
$Res call({
 MfaEnrolmentModel enrolment, bool deviceHasPasskey, String email, ProviderResponseModel providerModel
});




}
/// @nodoc
class _$TwoFactorAuthEnrolPasskeyCopyWithImpl<$Res>
    implements $TwoFactorAuthEnrolPasskeyCopyWith<$Res> {
  _$TwoFactorAuthEnrolPasskeyCopyWithImpl(this._self, this._then);

  final TwoFactorAuthEnrolPasskey _self;
  final $Res Function(TwoFactorAuthEnrolPasskey) _then;

/// Create a copy of TwoFactorAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enrolment = null,Object? deviceHasPasskey = null,Object? email = null,Object? providerModel = null,}) {
  return _then(TwoFactorAuthEnrolPasskey(
enrolment: null == enrolment ? _self.enrolment : enrolment // ignore: cast_nullable_to_non_nullable
as MfaEnrolmentModel,deviceHasPasskey: null == deviceHasPasskey ? _self.deviceHasPasskey : deviceHasPasskey // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,providerModel: null == providerModel ? _self.providerModel : providerModel // ignore: cast_nullable_to_non_nullable
as ProviderResponseModel,
  ));
}


}

// dart format on
