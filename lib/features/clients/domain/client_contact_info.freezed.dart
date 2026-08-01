// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_contact_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClientContactInfo {

 String get clientId; String? get phone; String? get address; String? get notes;
/// Create a copy of ClientContactInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientContactInfoCopyWith<ClientContactInfo> get copyWith => _$ClientContactInfoCopyWithImpl<ClientContactInfo>(this as ClientContactInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientContactInfo&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,clientId,phone,address,notes);

@override
String toString() {
  return 'ClientContactInfo(clientId: $clientId, phone: $phone, address: $address, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ClientContactInfoCopyWith<$Res>  {
  factory $ClientContactInfoCopyWith(ClientContactInfo value, $Res Function(ClientContactInfo) _then) = _$ClientContactInfoCopyWithImpl;
@useResult
$Res call({
 String clientId, String? phone, String? address, String? notes
});




}
/// @nodoc
class _$ClientContactInfoCopyWithImpl<$Res>
    implements $ClientContactInfoCopyWith<$Res> {
  _$ClientContactInfoCopyWithImpl(this._self, this._then);

  final ClientContactInfo _self;
  final $Res Function(ClientContactInfo) _then;

/// Create a copy of ClientContactInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? phone = freezed,Object? address = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientContactInfo].
extension ClientContactInfoPatterns on ClientContactInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientContactInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientContactInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientContactInfo value)  $default,){
final _that = this;
switch (_that) {
case _ClientContactInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientContactInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ClientContactInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientId,  String? phone,  String? address,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientContactInfo() when $default != null:
return $default(_that.clientId,_that.phone,_that.address,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientId,  String? phone,  String? address,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ClientContactInfo():
return $default(_that.clientId,_that.phone,_that.address,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientId,  String? phone,  String? address,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ClientContactInfo() when $default != null:
return $default(_that.clientId,_that.phone,_that.address,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _ClientContactInfo implements ClientContactInfo {
  const _ClientContactInfo({required this.clientId, this.phone, this.address, this.notes});
  

@override final  String clientId;
@override final  String? phone;
@override final  String? address;
@override final  String? notes;

/// Create a copy of ClientContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientContactInfoCopyWith<_ClientContactInfo> get copyWith => __$ClientContactInfoCopyWithImpl<_ClientContactInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientContactInfo&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,clientId,phone,address,notes);

@override
String toString() {
  return 'ClientContactInfo(clientId: $clientId, phone: $phone, address: $address, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ClientContactInfoCopyWith<$Res> implements $ClientContactInfoCopyWith<$Res> {
  factory _$ClientContactInfoCopyWith(_ClientContactInfo value, $Res Function(_ClientContactInfo) _then) = __$ClientContactInfoCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String? phone, String? address, String? notes
});




}
/// @nodoc
class __$ClientContactInfoCopyWithImpl<$Res>
    implements _$ClientContactInfoCopyWith<$Res> {
  __$ClientContactInfoCopyWithImpl(this._self, this._then);

  final _ClientContactInfo _self;
  final $Res Function(_ClientContactInfo) _then;

/// Create a copy of ClientContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? phone = freezed,Object? address = freezed,Object? notes = freezed,}) {
  return _then(_ClientContactInfo(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
