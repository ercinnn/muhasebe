// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentRecord {

 String get id; DateTime get createdAt; String get accountantId; String get clientId; DocumentCategory get category; DocType get docType; String? get period; double? get amount; DateTime? get dueDate; String? get fisNo; String? get personName; String get storagePath; DocumentStatus get status; DateTime? get paidAt; DateTime? get seenAt;
/// Create a copy of DocumentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentRecordCopyWith<DocumentRecord> get copyWith => _$DocumentRecordCopyWithImpl<DocumentRecord>(this as DocumentRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.accountantId, accountantId) || other.accountantId == accountantId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.category, category) || other.category == category)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.period, period) || other.period == period)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.fisNo, fisNo) || other.fisNo == fisNo)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.status, status) || other.status == status)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,accountantId,clientId,category,docType,period,amount,dueDate,fisNo,personName,storagePath,status,paidAt,seenAt);

@override
String toString() {
  return 'DocumentRecord(id: $id, createdAt: $createdAt, accountantId: $accountantId, clientId: $clientId, category: $category, docType: $docType, period: $period, amount: $amount, dueDate: $dueDate, fisNo: $fisNo, personName: $personName, storagePath: $storagePath, status: $status, paidAt: $paidAt, seenAt: $seenAt)';
}


}

/// @nodoc
abstract mixin class $DocumentRecordCopyWith<$Res>  {
  factory $DocumentRecordCopyWith(DocumentRecord value, $Res Function(DocumentRecord) _then) = _$DocumentRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String accountantId, String clientId, DocumentCategory category, DocType docType, String? period, double? amount, DateTime? dueDate, String? fisNo, String? personName, String storagePath, DocumentStatus status, DateTime? paidAt, DateTime? seenAt
});




}
/// @nodoc
class _$DocumentRecordCopyWithImpl<$Res>
    implements $DocumentRecordCopyWith<$Res> {
  _$DocumentRecordCopyWithImpl(this._self, this._then);

  final DocumentRecord _self;
  final $Res Function(DocumentRecord) _then;

/// Create a copy of DocumentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? accountantId = null,Object? clientId = null,Object? category = null,Object? docType = null,Object? period = freezed,Object? amount = freezed,Object? dueDate = freezed,Object? fisNo = freezed,Object? personName = freezed,Object? storagePath = null,Object? status = null,Object? paidAt = freezed,Object? seenAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountantId: null == accountantId ? _self.accountantId : accountantId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DocumentCategory,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocType,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,fisNo: freezed == fisNo ? _self.fisNo : fisNo // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentRecord].
extension DocumentRecordPatterns on DocumentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentRecord value)  $default,){
final _that = this;
switch (_that) {
case _DocumentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String accountantId,  String clientId,  DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  String storagePath,  DocumentStatus status,  DateTime? paidAt,  DateTime? seenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentRecord() when $default != null:
return $default(_that.id,_that.createdAt,_that.accountantId,_that.clientId,_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.storagePath,_that.status,_that.paidAt,_that.seenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String accountantId,  String clientId,  DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  String storagePath,  DocumentStatus status,  DateTime? paidAt,  DateTime? seenAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentRecord():
return $default(_that.id,_that.createdAt,_that.accountantId,_that.clientId,_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.storagePath,_that.status,_that.paidAt,_that.seenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String accountantId,  String clientId,  DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  String storagePath,  DocumentStatus status,  DateTime? paidAt,  DateTime? seenAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentRecord() when $default != null:
return $default(_that.id,_that.createdAt,_that.accountantId,_that.clientId,_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.storagePath,_that.status,_that.paidAt,_that.seenAt);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentRecord implements DocumentRecord {
  const _DocumentRecord({required this.id, required this.createdAt, required this.accountantId, required this.clientId, required this.category, required this.docType, this.period, this.amount, this.dueDate, this.fisNo, this.personName, required this.storagePath, required this.status, this.paidAt, this.seenAt});
  

@override final  String id;
@override final  DateTime createdAt;
@override final  String accountantId;
@override final  String clientId;
@override final  DocumentCategory category;
@override final  DocType docType;
@override final  String? period;
@override final  double? amount;
@override final  DateTime? dueDate;
@override final  String? fisNo;
@override final  String? personName;
@override final  String storagePath;
@override final  DocumentStatus status;
@override final  DateTime? paidAt;
@override final  DateTime? seenAt;

/// Create a copy of DocumentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentRecordCopyWith<_DocumentRecord> get copyWith => __$DocumentRecordCopyWithImpl<_DocumentRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.accountantId, accountantId) || other.accountantId == accountantId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.category, category) || other.category == category)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.period, period) || other.period == period)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.fisNo, fisNo) || other.fisNo == fisNo)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.status, status) || other.status == status)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt,accountantId,clientId,category,docType,period,amount,dueDate,fisNo,personName,storagePath,status,paidAt,seenAt);

@override
String toString() {
  return 'DocumentRecord(id: $id, createdAt: $createdAt, accountantId: $accountantId, clientId: $clientId, category: $category, docType: $docType, period: $period, amount: $amount, dueDate: $dueDate, fisNo: $fisNo, personName: $personName, storagePath: $storagePath, status: $status, paidAt: $paidAt, seenAt: $seenAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentRecordCopyWith<$Res> implements $DocumentRecordCopyWith<$Res> {
  factory _$DocumentRecordCopyWith(_DocumentRecord value, $Res Function(_DocumentRecord) _then) = __$DocumentRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String accountantId, String clientId, DocumentCategory category, DocType docType, String? period, double? amount, DateTime? dueDate, String? fisNo, String? personName, String storagePath, DocumentStatus status, DateTime? paidAt, DateTime? seenAt
});




}
/// @nodoc
class __$DocumentRecordCopyWithImpl<$Res>
    implements _$DocumentRecordCopyWith<$Res> {
  __$DocumentRecordCopyWithImpl(this._self, this._then);

  final _DocumentRecord _self;
  final $Res Function(_DocumentRecord) _then;

/// Create a copy of DocumentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? accountantId = null,Object? clientId = null,Object? category = null,Object? docType = null,Object? period = freezed,Object? amount = freezed,Object? dueDate = freezed,Object? fisNo = freezed,Object? personName = freezed,Object? storagePath = null,Object? status = null,Object? paidAt = freezed,Object? seenAt = freezed,}) {
  return _then(_DocumentRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountantId: null == accountantId ? _self.accountantId : accountantId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DocumentCategory,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocType,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,fisNo: freezed == fisNo ? _self.fisNo : fisNo // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
