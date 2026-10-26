// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_problem_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportProblemState {

 String? get locationId; String? get headerDisplayId; List<Evse> get availableEvses; String? get selectedEvseUid; String? get selectedConnectorId; List<IssueReportCategory> get categories; List<String> get unknownCategoryIds; IssueReportCategory? get selectedCategory; String? get selectedUnknownCategoryId; String get description; UIFlow get flow; bool get submitted;
/// Create a copy of ReportProblemState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportProblemStateCopyWith<ReportProblemState> get copyWith => _$ReportProblemStateCopyWithImpl<ReportProblemState>(this as ReportProblemState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReportProblemState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportProblemState&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.headerDisplayId, _this.headerDisplayId) || other.headerDisplayId == _this.headerDisplayId)&&const DeepCollectionEquality().equals(other.availableEvses, _this.availableEvses)&&(identical(other.selectedEvseUid, _this.selectedEvseUid) || other.selectedEvseUid == _this.selectedEvseUid)&&(identical(other.selectedConnectorId, _this.selectedConnectorId) || other.selectedConnectorId == _this.selectedConnectorId)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.unknownCategoryIds, _this.unknownCategoryIds)&&(identical(other.selectedCategory, _this.selectedCategory) || other.selectedCategory == _this.selectedCategory)&&(identical(other.selectedUnknownCategoryId, _this.selectedUnknownCategoryId) || other.selectedUnknownCategoryId == _this.selectedUnknownCategoryId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.flow, _this.flow) || other.flow == _this.flow)&&(identical(other.submitted, _this.submitted) || other.submitted == _this.submitted));
}


@override
int get hashCode {
  final _this = this as ReportProblemState;
  return Object.hash(runtimeType,_this.locationId,_this.headerDisplayId,const DeepCollectionEquality().hash(_this.availableEvses),_this.selectedEvseUid,_this.selectedConnectorId,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.unknownCategoryIds),_this.selectedCategory,_this.selectedUnknownCategoryId,_this.description,_this.flow,_this.submitted);
}

@override
String toString() {
  final _this = this as ReportProblemState;
  return 'ReportProblemState(locationId: ${_this.locationId}, headerDisplayId: ${_this.headerDisplayId}, availableEvses: ${_this.availableEvses}, selectedEvseUid: ${_this.selectedEvseUid}, selectedConnectorId: ${_this.selectedConnectorId}, categories: ${_this.categories}, unknownCategoryIds: ${_this.unknownCategoryIds}, selectedCategory: ${_this.selectedCategory}, selectedUnknownCategoryId: ${_this.selectedUnknownCategoryId}, description: ${_this.description}, flow: ${_this.flow}, submitted: ${_this.submitted})';
}


}

/// @nodoc
abstract mixin class $ReportProblemStateCopyWith<$Res>  {
  factory $ReportProblemStateCopyWith(ReportProblemState value, $Res Function(ReportProblemState) _then) = _$ReportProblemStateCopyWithImpl;
@useResult
$Res call({
 String? locationId, String? headerDisplayId, List<Evse> availableEvses, String? selectedEvseUid, String? selectedConnectorId, List<IssueReportCategory> categories, List<String> unknownCategoryIds, IssueReportCategory? selectedCategory, String? selectedUnknownCategoryId, String description, UIFlow flow, bool submitted
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$ReportProblemStateCopyWithImpl<$Res>
    implements $ReportProblemStateCopyWith<$Res> {
  _$ReportProblemStateCopyWithImpl(this._self, this._then);

  final ReportProblemState _self;
  final $Res Function(ReportProblemState) _then;

/// Create a copy of ReportProblemState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = freezed,Object? headerDisplayId = freezed,Object? availableEvses = null,Object? selectedEvseUid = freezed,Object? selectedConnectorId = freezed,Object? categories = null,Object? unknownCategoryIds = null,Object? selectedCategory = freezed,Object? selectedUnknownCategoryId = freezed,Object? description = null,Object? flow = null,Object? submitted = null,}) {
  return _then(ReportProblemState(
locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,headerDisplayId: freezed == headerDisplayId ? _self.headerDisplayId : headerDisplayId // ignore: cast_nullable_to_non_nullable
as String?,availableEvses: null == availableEvses ? _self.availableEvses : availableEvses // ignore: cast_nullable_to_non_nullable
as List<Evse>,selectedEvseUid: freezed == selectedEvseUid ? _self.selectedEvseUid : selectedEvseUid // ignore: cast_nullable_to_non_nullable
as String?,selectedConnectorId: freezed == selectedConnectorId ? _self.selectedConnectorId : selectedConnectorId // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<IssueReportCategory>,unknownCategoryIds: null == unknownCategoryIds ? _self.unknownCategoryIds : unknownCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as IssueReportCategory?,selectedUnknownCategoryId: freezed == selectedUnknownCategoryId ? _self.selectedUnknownCategoryId : selectedUnknownCategoryId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ReportProblemState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportProblemState].
extension ReportProblemStatePatterns on ReportProblemState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportProblemState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportProblemState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportProblemState value)  $default,){
final _that = this;
switch (_that) {
case _ReportProblemState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportProblemState value)?  $default,){
final _that = this;
switch (_that) {
case _ReportProblemState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? locationId,  String? headerDisplayId,  List<Evse> availableEvses,  String? selectedEvseUid,  String? selectedConnectorId,  List<IssueReportCategory> categories,  List<String> unknownCategoryIds,  IssueReportCategory? selectedCategory,  String? selectedUnknownCategoryId,  String description,  UIFlow flow,  bool submitted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportProblemState() when $default != null:
return $default(_that.locationId,_that.headerDisplayId,_that.availableEvses,_that.selectedEvseUid,_that.selectedConnectorId,_that.categories,_that.unknownCategoryIds,_that.selectedCategory,_that.selectedUnknownCategoryId,_that.description,_that.flow,_that.submitted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? locationId,  String? headerDisplayId,  List<Evse> availableEvses,  String? selectedEvseUid,  String? selectedConnectorId,  List<IssueReportCategory> categories,  List<String> unknownCategoryIds,  IssueReportCategory? selectedCategory,  String? selectedUnknownCategoryId,  String description,  UIFlow flow,  bool submitted)  $default,) {final _that = this;
switch (_that) {
case _ReportProblemState():
return $default(_that.locationId,_that.headerDisplayId,_that.availableEvses,_that.selectedEvseUid,_that.selectedConnectorId,_that.categories,_that.unknownCategoryIds,_that.selectedCategory,_that.selectedUnknownCategoryId,_that.description,_that.flow,_that.submitted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? locationId,  String? headerDisplayId,  List<Evse> availableEvses,  String? selectedEvseUid,  String? selectedConnectorId,  List<IssueReportCategory> categories,  List<String> unknownCategoryIds,  IssueReportCategory? selectedCategory,  String? selectedUnknownCategoryId,  String description,  UIFlow flow,  bool submitted)?  $default,) {final _that = this;
switch (_that) {
case _ReportProblemState() when $default != null:
return $default(_that.locationId,_that.headerDisplayId,_that.availableEvses,_that.selectedEvseUid,_that.selectedConnectorId,_that.categories,_that.unknownCategoryIds,_that.selectedCategory,_that.selectedUnknownCategoryId,_that.description,_that.flow,_that.submitted);case _:
  return null;

}
}

}

/// @nodoc


class _ReportProblemState implements ReportProblemState {
  const _ReportProblemState({this.locationId, this.headerDisplayId,  List<Evse> availableEvses = const [], this.selectedEvseUid, this.selectedConnectorId,  List<IssueReportCategory> categories = IssueReportCategory.values,  List<String> unknownCategoryIds = const [], this.selectedCategory, this.selectedUnknownCategoryId, this.description = '', this.flow = const UIFlow.established(), this.submitted = false}): _availableEvses = availableEvses,_categories = categories,_unknownCategoryIds = unknownCategoryIds;
  

@override final  String? locationId;
@override final  String? headerDisplayId;
 final  List<Evse> _availableEvses;
@override@JsonKey() List<Evse> get availableEvses {
  if (_availableEvses is EqualUnmodifiableListView) return _availableEvses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableEvses);
}

@override final  String? selectedEvseUid;
@override final  String? selectedConnectorId;
 final  List<IssueReportCategory> _categories;
@override@JsonKey() List<IssueReportCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<String> _unknownCategoryIds;
@override@JsonKey() List<String> get unknownCategoryIds {
  if (_unknownCategoryIds is EqualUnmodifiableListView) return _unknownCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unknownCategoryIds);
}

@override final  IssueReportCategory? selectedCategory;
@override final  String? selectedUnknownCategoryId;
@override@JsonKey() final  String description;
@override@JsonKey() final  UIFlow flow;
@override@JsonKey() final  bool submitted;

/// Create a copy of ReportProblemState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportProblemStateCopyWith<_ReportProblemState> get copyWith => __$ReportProblemStateCopyWithImpl<_ReportProblemState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportProblemState&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.headerDisplayId, headerDisplayId) || other.headerDisplayId == headerDisplayId)&&const DeepCollectionEquality().equals(other.availableEvses, _availableEvses)&&(identical(other.selectedEvseUid, selectedEvseUid) || other.selectedEvseUid == selectedEvseUid)&&(identical(other.selectedConnectorId, selectedConnectorId) || other.selectedConnectorId == selectedConnectorId)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.unknownCategoryIds, _unknownCategoryIds)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedUnknownCategoryId, selectedUnknownCategoryId) || other.selectedUnknownCategoryId == selectedUnknownCategoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.submitted, submitted) || other.submitted == submitted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locationId,headerDisplayId,const DeepCollectionEquality().hash(_availableEvses),selectedEvseUid,selectedConnectorId,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_unknownCategoryIds),selectedCategory,selectedUnknownCategoryId,description,flow,submitted);
}

@override
String toString() {
    return 'ReportProblemState(locationId: $locationId, headerDisplayId: $headerDisplayId, availableEvses: $availableEvses, selectedEvseUid: $selectedEvseUid, selectedConnectorId: $selectedConnectorId, categories: $categories, unknownCategoryIds: $unknownCategoryIds, selectedCategory: $selectedCategory, selectedUnknownCategoryId: $selectedUnknownCategoryId, description: $description, flow: $flow, submitted: $submitted)';
}


}

/// @nodoc
abstract mixin class _$ReportProblemStateCopyWith<$Res> implements $ReportProblemStateCopyWith<$Res> {
  factory _$ReportProblemStateCopyWith(_ReportProblemState value, $Res Function(_ReportProblemState) _then) = __$ReportProblemStateCopyWithImpl;
@override @useResult
$Res call({
 String? locationId, String? headerDisplayId, List<Evse> availableEvses, String? selectedEvseUid, String? selectedConnectorId, List<IssueReportCategory> categories, List<String> unknownCategoryIds, IssueReportCategory? selectedCategory, String? selectedUnknownCategoryId, String description, UIFlow flow, bool submitted
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class __$ReportProblemStateCopyWithImpl<$Res>
    implements _$ReportProblemStateCopyWith<$Res> {
  __$ReportProblemStateCopyWithImpl(this._self, this._then);

  final _ReportProblemState _self;
  final $Res Function(_ReportProblemState) _then;

/// Create a copy of ReportProblemState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = freezed,Object? headerDisplayId = freezed,Object? availableEvses = null,Object? selectedEvseUid = freezed,Object? selectedConnectorId = freezed,Object? categories = null,Object? unknownCategoryIds = null,Object? selectedCategory = freezed,Object? selectedUnknownCategoryId = freezed,Object? description = null,Object? flow = null,Object? submitted = null,}) {
  return _then(_ReportProblemState(
locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,headerDisplayId: freezed == headerDisplayId ? _self.headerDisplayId : headerDisplayId // ignore: cast_nullable_to_non_nullable
as String?,availableEvses: null == availableEvses ? _self._availableEvses : availableEvses // ignore: cast_nullable_to_non_nullable
as List<Evse>,selectedEvseUid: freezed == selectedEvseUid ? _self.selectedEvseUid : selectedEvseUid // ignore: cast_nullable_to_non_nullable
as String?,selectedConnectorId: freezed == selectedConnectorId ? _self.selectedConnectorId : selectedConnectorId // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<IssueReportCategory>,unknownCategoryIds: null == unknownCategoryIds ? _self._unknownCategoryIds : unknownCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as IssueReportCategory?,selectedUnknownCategoryId: freezed == selectedUnknownCategoryId ? _self.selectedUnknownCategoryId : selectedUnknownCategoryId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ReportProblemState
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
