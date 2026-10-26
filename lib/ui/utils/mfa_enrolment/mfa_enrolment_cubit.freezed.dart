// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mfa_enrolment_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MfaEnrolmentState implements DiagnosticableTreeMixin {

 UIFlow get flow;
/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaEnrolmentStateCopyWith<MfaEnrolmentState> get copyWith => _$MfaEnrolmentStateCopyWithImpl<MfaEnrolmentState>(this as MfaEnrolmentState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as MfaEnrolmentState;
  properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState'))
    ..add(DiagnosticsProperty('flow', _this.flow));
}

@override
bool operator ==(Object other) {
  final _this = this as MfaEnrolmentState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaEnrolmentState&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as MfaEnrolmentState;
  return Object.hash(runtimeType,_this.flow);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as MfaEnrolmentState;
  return 'MfaEnrolmentState(flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $MfaEnrolmentStateCopyWith<$Res>  {
  factory $MfaEnrolmentStateCopyWith(MfaEnrolmentState value, $Res Function(MfaEnrolmentState) _then) = _$MfaEnrolmentStateCopyWithImpl;
@useResult
$Res call({
 UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaEnrolmentStateCopyWithImpl<$Res>
    implements $MfaEnrolmentStateCopyWith<$Res> {
  _$MfaEnrolmentStateCopyWithImpl(this._self, this._then);

  final MfaEnrolmentState _self;
  final $Res Function(MfaEnrolmentState) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [MfaEnrolmentState].
extension MfaEnrolmentStatePatterns on MfaEnrolmentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MfaSetupMethodList value)?  methodList,TResult Function( MfaSetupEmailProof value)?  emailProof,TResult Function( MfaSetupTotp value)?  totpSetup,TResult Function( MfaSetupSmsVerify value)?  smsVerify,TResult Function( MfaSetupRecoveryCodes value)?  recoveryCodes,TResult Function( MfaSetupRecoveryEmailEntry value)?  recoveryEmailEntry,TResult Function( MfaSetupRecoveryEmailVerify value)?  recoveryEmailVerify,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MfaSetupMethodList() when methodList != null:
return methodList(_that);case MfaSetupEmailProof() when emailProof != null:
return emailProof(_that);case MfaSetupTotp() when totpSetup != null:
return totpSetup(_that);case MfaSetupSmsVerify() when smsVerify != null:
return smsVerify(_that);case MfaSetupRecoveryCodes() when recoveryCodes != null:
return recoveryCodes(_that);case MfaSetupRecoveryEmailEntry() when recoveryEmailEntry != null:
return recoveryEmailEntry(_that);case MfaSetupRecoveryEmailVerify() when recoveryEmailVerify != null:
return recoveryEmailVerify(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MfaSetupMethodList value)  methodList,required TResult Function( MfaSetupEmailProof value)  emailProof,required TResult Function( MfaSetupTotp value)  totpSetup,required TResult Function( MfaSetupSmsVerify value)  smsVerify,required TResult Function( MfaSetupRecoveryCodes value)  recoveryCodes,required TResult Function( MfaSetupRecoveryEmailEntry value)  recoveryEmailEntry,required TResult Function( MfaSetupRecoveryEmailVerify value)  recoveryEmailVerify,}){
final _that = this;
switch (_that) {
case MfaSetupMethodList():
return methodList(_that);case MfaSetupEmailProof():
return emailProof(_that);case MfaSetupTotp():
return totpSetup(_that);case MfaSetupSmsVerify():
return smsVerify(_that);case MfaSetupRecoveryCodes():
return recoveryCodes(_that);case MfaSetupRecoveryEmailEntry():
return recoveryEmailEntry(_that);case MfaSetupRecoveryEmailVerify():
return recoveryEmailVerify(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MfaSetupMethodList value)?  methodList,TResult? Function( MfaSetupEmailProof value)?  emailProof,TResult? Function( MfaSetupTotp value)?  totpSetup,TResult? Function( MfaSetupSmsVerify value)?  smsVerify,TResult? Function( MfaSetupRecoveryCodes value)?  recoveryCodes,TResult? Function( MfaSetupRecoveryEmailEntry value)?  recoveryEmailEntry,TResult? Function( MfaSetupRecoveryEmailVerify value)?  recoveryEmailVerify,}){
final _that = this;
switch (_that) {
case MfaSetupMethodList() when methodList != null:
return methodList(_that);case MfaSetupEmailProof() when emailProof != null:
return emailProof(_that);case MfaSetupTotp() when totpSetup != null:
return totpSetup(_that);case MfaSetupSmsVerify() when smsVerify != null:
return smsVerify(_that);case MfaSetupRecoveryCodes() when recoveryCodes != null:
return recoveryCodes(_that);case MfaSetupRecoveryEmailEntry() when recoveryEmailEntry != null:
return recoveryEmailEntry(_that);case MfaSetupRecoveryEmailVerify() when recoveryEmailVerify != null:
return recoveryEmailVerify(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( UIFlow flow,  MfaFactorsModel? factors)?  methodList,TResult Function( UIFlow flow,  MfaMethod pendingMethod,  int? nextSendAfterSeconds)?  emailProof,TResult Function( UIFlow flow,  MfaEnrolTotpBeginModel totp)?  totpSetup,TResult Function( UIFlow flow,  String factorId,  String? hint,  int? nextSendAfterSeconds)?  smsVerify,TResult Function( UIFlow flow,  List<String> codes)?  recoveryCodes,TResult Function( UIFlow flow)?  recoveryEmailEntry,TResult Function( UIFlow flow,  String factorId,  String email,  int? nextSendAfterSeconds)?  recoveryEmailVerify,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MfaSetupMethodList() when methodList != null:
return methodList(_that.flow,_that.factors);case MfaSetupEmailProof() when emailProof != null:
return emailProof(_that.flow,_that.pendingMethod,_that.nextSendAfterSeconds);case MfaSetupTotp() when totpSetup != null:
return totpSetup(_that.flow,_that.totp);case MfaSetupSmsVerify() when smsVerify != null:
return smsVerify(_that.flow,_that.factorId,_that.hint,_that.nextSendAfterSeconds);case MfaSetupRecoveryCodes() when recoveryCodes != null:
return recoveryCodes(_that.flow,_that.codes);case MfaSetupRecoveryEmailEntry() when recoveryEmailEntry != null:
return recoveryEmailEntry(_that.flow);case MfaSetupRecoveryEmailVerify() when recoveryEmailVerify != null:
return recoveryEmailVerify(_that.flow,_that.factorId,_that.email,_that.nextSendAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( UIFlow flow,  MfaFactorsModel? factors)  methodList,required TResult Function( UIFlow flow,  MfaMethod pendingMethod,  int? nextSendAfterSeconds)  emailProof,required TResult Function( UIFlow flow,  MfaEnrolTotpBeginModel totp)  totpSetup,required TResult Function( UIFlow flow,  String factorId,  String? hint,  int? nextSendAfterSeconds)  smsVerify,required TResult Function( UIFlow flow,  List<String> codes)  recoveryCodes,required TResult Function( UIFlow flow)  recoveryEmailEntry,required TResult Function( UIFlow flow,  String factorId,  String email,  int? nextSendAfterSeconds)  recoveryEmailVerify,}) {final _that = this;
switch (_that) {
case MfaSetupMethodList():
return methodList(_that.flow,_that.factors);case MfaSetupEmailProof():
return emailProof(_that.flow,_that.pendingMethod,_that.nextSendAfterSeconds);case MfaSetupTotp():
return totpSetup(_that.flow,_that.totp);case MfaSetupSmsVerify():
return smsVerify(_that.flow,_that.factorId,_that.hint,_that.nextSendAfterSeconds);case MfaSetupRecoveryCodes():
return recoveryCodes(_that.flow,_that.codes);case MfaSetupRecoveryEmailEntry():
return recoveryEmailEntry(_that.flow);case MfaSetupRecoveryEmailVerify():
return recoveryEmailVerify(_that.flow,_that.factorId,_that.email,_that.nextSendAfterSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( UIFlow flow,  MfaFactorsModel? factors)?  methodList,TResult? Function( UIFlow flow,  MfaMethod pendingMethod,  int? nextSendAfterSeconds)?  emailProof,TResult? Function( UIFlow flow,  MfaEnrolTotpBeginModel totp)?  totpSetup,TResult? Function( UIFlow flow,  String factorId,  String? hint,  int? nextSendAfterSeconds)?  smsVerify,TResult? Function( UIFlow flow,  List<String> codes)?  recoveryCodes,TResult? Function( UIFlow flow)?  recoveryEmailEntry,TResult? Function( UIFlow flow,  String factorId,  String email,  int? nextSendAfterSeconds)?  recoveryEmailVerify,}) {final _that = this;
switch (_that) {
case MfaSetupMethodList() when methodList != null:
return methodList(_that.flow,_that.factors);case MfaSetupEmailProof() when emailProof != null:
return emailProof(_that.flow,_that.pendingMethod,_that.nextSendAfterSeconds);case MfaSetupTotp() when totpSetup != null:
return totpSetup(_that.flow,_that.totp);case MfaSetupSmsVerify() when smsVerify != null:
return smsVerify(_that.flow,_that.factorId,_that.hint,_that.nextSendAfterSeconds);case MfaSetupRecoveryCodes() when recoveryCodes != null:
return recoveryCodes(_that.flow,_that.codes);case MfaSetupRecoveryEmailEntry() when recoveryEmailEntry != null:
return recoveryEmailEntry(_that.flow);case MfaSetupRecoveryEmailVerify() when recoveryEmailVerify != null:
return recoveryEmailVerify(_that.flow,_that.factorId,_that.email,_that.nextSendAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc


class MfaSetupMethodList with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupMethodList({this.flow = const UIFlow.established(), this.factors});
  

@override@JsonKey() final  UIFlow flow;
 final  MfaFactorsModel? factors;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupMethodListCopyWith<MfaSetupMethodList> get copyWith => _$MfaSetupMethodListCopyWithImpl<MfaSetupMethodList>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.methodList'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('factors', factors));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupMethodList&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.factors, factors) || other.factors == factors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,factors);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.methodList(flow: $flow, factors: $factors)';
}


}

/// @nodoc
abstract mixin class $MfaSetupMethodListCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupMethodListCopyWith(MfaSetupMethodList value, $Res Function(MfaSetupMethodList) _then) = _$MfaSetupMethodListCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, MfaFactorsModel? factors
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupMethodListCopyWithImpl<$Res>
    implements $MfaSetupMethodListCopyWith<$Res> {
  _$MfaSetupMethodListCopyWithImpl(this._self, this._then);

  final MfaSetupMethodList _self;
  final $Res Function(MfaSetupMethodList) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? factors = freezed,}) {
  return _then(MfaSetupMethodList(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as MfaFactorsModel?,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupEmailProof with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupEmailProof({this.flow = const UIFlow.established(), required this.pendingMethod, this.nextSendAfterSeconds});
  

@override@JsonKey() final  UIFlow flow;
 final  MfaMethod pendingMethod;
 final  int? nextSendAfterSeconds;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupEmailProofCopyWith<MfaSetupEmailProof> get copyWith => _$MfaSetupEmailProofCopyWithImpl<MfaSetupEmailProof>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.emailProof'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('pendingMethod', pendingMethod))..add(DiagnosticsProperty('nextSendAfterSeconds', nextSendAfterSeconds));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupEmailProof&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.pendingMethod, pendingMethod) || other.pendingMethod == pendingMethod)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,pendingMethod,nextSendAfterSeconds);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.emailProof(flow: $flow, pendingMethod: $pendingMethod, nextSendAfterSeconds: $nextSendAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $MfaSetupEmailProofCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupEmailProofCopyWith(MfaSetupEmailProof value, $Res Function(MfaSetupEmailProof) _then) = _$MfaSetupEmailProofCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, MfaMethod pendingMethod, int? nextSendAfterSeconds
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupEmailProofCopyWithImpl<$Res>
    implements $MfaSetupEmailProofCopyWith<$Res> {
  _$MfaSetupEmailProofCopyWithImpl(this._self, this._then);

  final MfaSetupEmailProof _self;
  final $Res Function(MfaSetupEmailProof) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? pendingMethod = null,Object? nextSendAfterSeconds = freezed,}) {
  return _then(MfaSetupEmailProof(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,pendingMethod: null == pendingMethod ? _self.pendingMethod : pendingMethod // ignore: cast_nullable_to_non_nullable
as MfaMethod,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupTotp with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupTotp({this.flow = const UIFlow.established(), required this.totp});
  

@override@JsonKey() final  UIFlow flow;
 final  MfaEnrolTotpBeginModel totp;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupTotpCopyWith<MfaSetupTotp> get copyWith => _$MfaSetupTotpCopyWithImpl<MfaSetupTotp>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.totpSetup'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('totp', totp));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupTotp&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.totp, totp) || other.totp == totp));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,totp);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.totpSetup(flow: $flow, totp: $totp)';
}


}

/// @nodoc
abstract mixin class $MfaSetupTotpCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupTotpCopyWith(MfaSetupTotp value, $Res Function(MfaSetupTotp) _then) = _$MfaSetupTotpCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, MfaEnrolTotpBeginModel totp
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupTotpCopyWithImpl<$Res>
    implements $MfaSetupTotpCopyWith<$Res> {
  _$MfaSetupTotpCopyWithImpl(this._self, this._then);

  final MfaSetupTotp _self;
  final $Res Function(MfaSetupTotp) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? totp = null,}) {
  return _then(MfaSetupTotp(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,totp: null == totp ? _self.totp : totp // ignore: cast_nullable_to_non_nullable
as MfaEnrolTotpBeginModel,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupSmsVerify with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupSmsVerify({this.flow = const UIFlow.established(), required this.factorId, this.hint, this.nextSendAfterSeconds});
  

@override@JsonKey() final  UIFlow flow;
 final  String factorId;
 final  String? hint;
 final  int? nextSendAfterSeconds;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupSmsVerifyCopyWith<MfaSetupSmsVerify> get copyWith => _$MfaSetupSmsVerifyCopyWithImpl<MfaSetupSmsVerify>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.smsVerify'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('factorId', factorId))..add(DiagnosticsProperty('hint', hint))..add(DiagnosticsProperty('nextSendAfterSeconds', nextSendAfterSeconds));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupSmsVerify&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,factorId,hint,nextSendAfterSeconds);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.smsVerify(flow: $flow, factorId: $factorId, hint: $hint, nextSendAfterSeconds: $nextSendAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $MfaSetupSmsVerifyCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupSmsVerifyCopyWith(MfaSetupSmsVerify value, $Res Function(MfaSetupSmsVerify) _then) = _$MfaSetupSmsVerifyCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, String factorId, String? hint, int? nextSendAfterSeconds
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupSmsVerifyCopyWithImpl<$Res>
    implements $MfaSetupSmsVerifyCopyWith<$Res> {
  _$MfaSetupSmsVerifyCopyWithImpl(this._self, this._then);

  final MfaSetupSmsVerify _self;
  final $Res Function(MfaSetupSmsVerify) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? factorId = null,Object? hint = freezed,Object? nextSendAfterSeconds = freezed,}) {
  return _then(MfaSetupSmsVerify(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupRecoveryCodes with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupRecoveryCodes({this.flow = const UIFlow.established(), required  List<String> codes}): _codes = codes;
  

@override@JsonKey() final  UIFlow flow;
 final  List<String> _codes;
 List<String> get codes {
  if (_codes is EqualUnmodifiableListView) return _codes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codes);
}


/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupRecoveryCodesCopyWith<MfaSetupRecoveryCodes> get copyWith => _$MfaSetupRecoveryCodesCopyWithImpl<MfaSetupRecoveryCodes>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.recoveryCodes'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('codes', codes));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupRecoveryCodes&&(identical(other.flow, flow) || other.flow == flow)&&const DeepCollectionEquality().equals(other.codes, _codes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,const DeepCollectionEquality().hash(_codes));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.recoveryCodes(flow: $flow, codes: $codes)';
}


}

/// @nodoc
abstract mixin class $MfaSetupRecoveryCodesCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupRecoveryCodesCopyWith(MfaSetupRecoveryCodes value, $Res Function(MfaSetupRecoveryCodes) _then) = _$MfaSetupRecoveryCodesCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, List<String> codes
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupRecoveryCodesCopyWithImpl<$Res>
    implements $MfaSetupRecoveryCodesCopyWith<$Res> {
  _$MfaSetupRecoveryCodesCopyWithImpl(this._self, this._then);

  final MfaSetupRecoveryCodes _self;
  final $Res Function(MfaSetupRecoveryCodes) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? codes = null,}) {
  return _then(MfaSetupRecoveryCodes(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,codes: null == codes ? _self._codes : codes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupRecoveryEmailEntry with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupRecoveryEmailEntry({this.flow = const UIFlow.established()});
  

@override@JsonKey() final  UIFlow flow;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupRecoveryEmailEntryCopyWith<MfaSetupRecoveryEmailEntry> get copyWith => _$MfaSetupRecoveryEmailEntryCopyWithImpl<MfaSetupRecoveryEmailEntry>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.recoveryEmailEntry'))
    ..add(DiagnosticsProperty('flow', flow));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupRecoveryEmailEntry&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.recoveryEmailEntry(flow: $flow)';
}


}

/// @nodoc
abstract mixin class $MfaSetupRecoveryEmailEntryCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupRecoveryEmailEntryCopyWith(MfaSetupRecoveryEmailEntry value, $Res Function(MfaSetupRecoveryEmailEntry) _then) = _$MfaSetupRecoveryEmailEntryCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupRecoveryEmailEntryCopyWithImpl<$Res>
    implements $MfaSetupRecoveryEmailEntryCopyWith<$Res> {
  _$MfaSetupRecoveryEmailEntryCopyWithImpl(this._self, this._then);

  final MfaSetupRecoveryEmailEntry _self;
  final $Res Function(MfaSetupRecoveryEmailEntry) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,}) {
  return _then(MfaSetupRecoveryEmailEntry(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of MfaEnrolmentState
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


class MfaSetupRecoveryEmailVerify with DiagnosticableTreeMixin implements MfaEnrolmentState {
  const MfaSetupRecoveryEmailVerify({this.flow = const UIFlow.established(), required this.factorId, required this.email, this.nextSendAfterSeconds});
  

@override@JsonKey() final  UIFlow flow;
 final  String factorId;
 final  String email;
 final  int? nextSendAfterSeconds;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupRecoveryEmailVerifyCopyWith<MfaSetupRecoveryEmailVerify> get copyWith => _$MfaSetupRecoveryEmailVerifyCopyWithImpl<MfaSetupRecoveryEmailVerify>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'MfaEnrolmentState.recoveryEmailVerify'))
    ..add(DiagnosticsProperty('flow', flow))..add(DiagnosticsProperty('factorId', factorId))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('nextSendAfterSeconds', nextSendAfterSeconds));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetupRecoveryEmailVerify&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.email, email) || other.email == email)&&(identical(other.nextSendAfterSeconds, nextSendAfterSeconds) || other.nextSendAfterSeconds == nextSendAfterSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flow,factorId,email,nextSendAfterSeconds);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'MfaEnrolmentState.recoveryEmailVerify(flow: $flow, factorId: $factorId, email: $email, nextSendAfterSeconds: $nextSendAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $MfaSetupRecoveryEmailVerifyCopyWith<$Res> implements $MfaEnrolmentStateCopyWith<$Res> {
  factory $MfaSetupRecoveryEmailVerifyCopyWith(MfaSetupRecoveryEmailVerify value, $Res Function(MfaSetupRecoveryEmailVerify) _then) = _$MfaSetupRecoveryEmailVerifyCopyWithImpl;
@override @useResult
$Res call({
 UIFlow flow, String factorId, String email, int? nextSendAfterSeconds
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$MfaSetupRecoveryEmailVerifyCopyWithImpl<$Res>
    implements $MfaSetupRecoveryEmailVerifyCopyWith<$Res> {
  _$MfaSetupRecoveryEmailVerifyCopyWithImpl(this._self, this._then);

  final MfaSetupRecoveryEmailVerify _self;
  final $Res Function(MfaSetupRecoveryEmailVerify) _then;

/// Create a copy of MfaEnrolmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? factorId = null,Object? email = null,Object? nextSendAfterSeconds = freezed,}) {
  return _then(MfaSetupRecoveryEmailVerify(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,nextSendAfterSeconds: freezed == nextSendAfterSeconds ? _self.nextSendAfterSeconds : nextSendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of MfaEnrolmentState
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
