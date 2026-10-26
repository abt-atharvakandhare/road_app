// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationsChangeItem {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsChangeItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NotificationsChangeItem()';
}


}

/// @nodoc
class $NotificationsChangeItemCopyWith<$Res>  {
$NotificationsChangeItemCopyWith(NotificationsChangeItem _, $Res Function(NotificationsChangeItem) __);
}


/// Adds pattern-matching-related methods to [NotificationsChangeItem].
extension NotificationsChangeItemPatterns on NotificationsChangeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AllItems value)?  allItems,TResult Function( SingleItem value)?  singleItem,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AllItems() when allItems != null:
return allItems(_that);case SingleItem() when singleItem != null:
return singleItem(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AllItems value)  allItems,required TResult Function( SingleItem value)  singleItem,}){
final _that = this;
switch (_that) {
case AllItems():
return allItems(_that);case SingleItem():
return singleItem(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AllItems value)?  allItems,TResult? Function( SingleItem value)?  singleItem,}){
final _that = this;
switch (_that) {
case AllItems() when allItems != null:
return allItems(_that);case SingleItem() when singleItem != null:
return singleItem(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  allItems,TResult Function( StateOfChargeNotificationItem item)?  singleItem,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AllItems() when allItems != null:
return allItems();case SingleItem() when singleItem != null:
return singleItem(_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  allItems,required TResult Function( StateOfChargeNotificationItem item)  singleItem,}) {final _that = this;
switch (_that) {
case AllItems():
return allItems();case SingleItem():
return singleItem(_that.item);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  allItems,TResult? Function( StateOfChargeNotificationItem item)?  singleItem,}) {final _that = this;
switch (_that) {
case AllItems() when allItems != null:
return allItems();case SingleItem() when singleItem != null:
return singleItem(_that.item);case _:
  return null;

}
}

}

/// @nodoc


class AllItems extends NotificationsChangeItem {
  const AllItems(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AllItems);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NotificationsChangeItem.allItems()';
}


}




/// @nodoc


class SingleItem extends NotificationsChangeItem {
  const SingleItem(this.item): super._();
  

 final  StateOfChargeNotificationItem item;

/// Create a copy of NotificationsChangeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SingleItemCopyWith<SingleItem> get copyWith => _$SingleItemCopyWithImpl<SingleItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SingleItem&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode {
    return Object.hash(runtimeType,item);
}

@override
String toString() {
    return 'NotificationsChangeItem.singleItem(item: $item)';
}


}

/// @nodoc
abstract mixin class $SingleItemCopyWith<$Res> implements $NotificationsChangeItemCopyWith<$Res> {
  factory $SingleItemCopyWith(SingleItem value, $Res Function(SingleItem) _then) = _$SingleItemCopyWithImpl;
@useResult
$Res call({
 StateOfChargeNotificationItem item
});




}
/// @nodoc
class _$SingleItemCopyWithImpl<$Res>
    implements $SingleItemCopyWith<$Res> {
  _$SingleItemCopyWithImpl(this._self, this._then);

  final SingleItem _self;
  final $Res Function(SingleItem) _then;

/// Create a copy of NotificationsChangeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? item = null,}) {
  return _then(SingleItem(
null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as StateOfChargeNotificationItem,
  ));
}


}

/// @nodoc
mixin _$NotificationsState {

 bool get allNotifications; List<StateOfChargeNotificationItemState> get items; bool get initialLoading; UIFlow get flow;
/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsStateCopyWith<NotificationsState> get copyWith => _$NotificationsStateCopyWithImpl<NotificationsState>(this as NotificationsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationsState&&(identical(other.allNotifications, _this.allNotifications) || other.allNotifications == _this.allNotifications)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.initialLoading, _this.initialLoading) || other.initialLoading == _this.initialLoading)&&(identical(other.flow, _this.flow) || other.flow == _this.flow));
}


@override
int get hashCode {
  final _this = this as NotificationsState;
  return Object.hash(runtimeType,_this.allNotifications,const DeepCollectionEquality().hash(_this.items),_this.initialLoading,_this.flow);
}

@override
String toString() {
  final _this = this as NotificationsState;
  return 'NotificationsState(allNotifications: ${_this.allNotifications}, items: ${_this.items}, initialLoading: ${_this.initialLoading}, flow: ${_this.flow})';
}


}

/// @nodoc
abstract mixin class $NotificationsStateCopyWith<$Res>  {
  factory $NotificationsStateCopyWith(NotificationsState value, $Res Function(NotificationsState) _then) = _$NotificationsStateCopyWithImpl;
@useResult
$Res call({
 bool allNotifications, List<StateOfChargeNotificationItemState> items, bool initialLoading, UIFlow flow
});


$UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$NotificationsStateCopyWithImpl<$Res>
    implements $NotificationsStateCopyWith<$Res> {
  _$NotificationsStateCopyWithImpl(this._self, this._then);

  final NotificationsState _self;
  final $Res Function(NotificationsState) _then;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allNotifications = null,Object? items = null,Object? initialLoading = null,Object? flow = null,}) {
  return _then(NotificationsState.notifications(
allNotifications: null == allNotifications ? _self.allNotifications : allNotifications // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StateOfChargeNotificationItemState>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}
/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UIFlowCopyWith<$Res> get flow {
  
  return $UIFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}
}


/// Adds pattern-matching-related methods to [NotificationsState].
extension NotificationsStatePatterns on NotificationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Notifications value)?  notifications,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Notifications() when notifications != null:
return notifications(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Notifications value)  notifications,}){
final _that = this;
switch (_that) {
case Notifications():
return notifications(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Notifications value)?  notifications,}){
final _that = this;
switch (_that) {
case Notifications() when notifications != null:
return notifications(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool allNotifications,  List<StateOfChargeNotificationItemState> items,  bool initialLoading,  UIFlow flow)?  notifications,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Notifications() when notifications != null:
return notifications(_that.allNotifications,_that.items,_that.initialLoading,_that.flow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool allNotifications,  List<StateOfChargeNotificationItemState> items,  bool initialLoading,  UIFlow flow)  notifications,}) {final _that = this;
switch (_that) {
case Notifications():
return notifications(_that.allNotifications,_that.items,_that.initialLoading,_that.flow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool allNotifications,  List<StateOfChargeNotificationItemState> items,  bool initialLoading,  UIFlow flow)?  notifications,}) {final _that = this;
switch (_that) {
case Notifications() when notifications != null:
return notifications(_that.allNotifications,_that.items,_that.initialLoading,_that.flow);case _:
  return null;

}
}

}

/// @nodoc


class Notifications implements NotificationsState {
  const Notifications({required this.allNotifications, required  List<StateOfChargeNotificationItemState> items, this.initialLoading = false, this.flow = const UIFlow.established()}): _items = items;
  

@override final  bool allNotifications;
 final  List<StateOfChargeNotificationItemState> _items;
@override List<StateOfChargeNotificationItemState> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool initialLoading;
@override@JsonKey() final  UIFlow flow;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationsCopyWith<Notifications> get copyWith => _$NotificationsCopyWithImpl<Notifications>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Notifications&&(identical(other.allNotifications, allNotifications) || other.allNotifications == allNotifications)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.initialLoading, initialLoading) || other.initialLoading == initialLoading)&&(identical(other.flow, flow) || other.flow == flow));
}


@override
int get hashCode {
    return Object.hash(runtimeType,allNotifications,const DeepCollectionEquality().hash(_items),initialLoading,flow);
}

@override
String toString() {
    return 'NotificationsState.notifications(allNotifications: $allNotifications, items: $items, initialLoading: $initialLoading, flow: $flow)';
}


}

/// @nodoc
abstract mixin class $NotificationsCopyWith<$Res> implements $NotificationsStateCopyWith<$Res> {
  factory $NotificationsCopyWith(Notifications value, $Res Function(Notifications) _then) = _$NotificationsCopyWithImpl;
@override @useResult
$Res call({
 bool allNotifications, List<StateOfChargeNotificationItemState> items, bool initialLoading, UIFlow flow
});


@override $UIFlowCopyWith<$Res> get flow;

}
/// @nodoc
class _$NotificationsCopyWithImpl<$Res>
    implements $NotificationsCopyWith<$Res> {
  _$NotificationsCopyWithImpl(this._self, this._then);

  final Notifications _self;
  final $Res Function(Notifications) _then;

/// Create a copy of NotificationsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allNotifications = null,Object? items = null,Object? initialLoading = null,Object? flow = null,}) {
  return _then(Notifications(
allNotifications: null == allNotifications ? _self.allNotifications : allNotifications // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StateOfChargeNotificationItemState>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as UIFlow,
  ));
}

/// Create a copy of NotificationsState
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
