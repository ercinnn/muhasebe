// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extracted_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExtractedDocument {

 DocumentCategory get category; DocType get docType; String? get period; double? get amount; DateTime? get dueDate; String? get fisNo; String? get personName; Map<String, String>? get metadata;// True when a required field couldn't be extracted confidently and the
// accountant must fill it in manually in the preview screen.
 bool get needsManualEntry;// False for info documents, and for payment documents with a zero
// (fully offset/mahsup) amount — no reminder should be scheduled.
 bool get needsReminder;
/// Create a copy of ExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedDocumentCopyWith<ExtractedDocument> get copyWith => _$ExtractedDocumentCopyWithImpl<ExtractedDocument>(this as ExtractedDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedDocument&&(identical(other.category, category) || other.category == category)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.period, period) || other.period == period)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.fisNo, fisNo) || other.fisNo == fisNo)&&(identical(other.personName, personName) || other.personName == personName)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.needsManualEntry, needsManualEntry) || other.needsManualEntry == needsManualEntry)&&(identical(other.needsReminder, needsReminder) || other.needsReminder == needsReminder));
}


@override
int get hashCode => Object.hash(runtimeType,category,docType,period,amount,dueDate,fisNo,personName,const DeepCollectionEquality().hash(metadata),needsManualEntry,needsReminder);

@override
String toString() {
  return 'ExtractedDocument(category: $category, docType: $docType, period: $period, amount: $amount, dueDate: $dueDate, fisNo: $fisNo, personName: $personName, metadata: $metadata, needsManualEntry: $needsManualEntry, needsReminder: $needsReminder)';
}


}

/// @nodoc
abstract mixin class $ExtractedDocumentCopyWith<$Res>  {
  factory $ExtractedDocumentCopyWith(ExtractedDocument value, $Res Function(ExtractedDocument) _then) = _$ExtractedDocumentCopyWithImpl;
@useResult
$Res call({
 DocumentCategory category, DocType docType, String? period, double? amount, DateTime? dueDate, String? fisNo, String? personName, Map<String, String>? metadata, bool needsManualEntry, bool needsReminder
});




}
/// @nodoc
class _$ExtractedDocumentCopyWithImpl<$Res>
    implements $ExtractedDocumentCopyWith<$Res> {
  _$ExtractedDocumentCopyWithImpl(this._self, this._then);

  final ExtractedDocument _self;
  final $Res Function(ExtractedDocument) _then;

/// Create a copy of ExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? docType = null,Object? period = freezed,Object? amount = freezed,Object? dueDate = freezed,Object? fisNo = freezed,Object? personName = freezed,Object? metadata = freezed,Object? needsManualEntry = null,Object? needsReminder = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DocumentCategory,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocType,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,fisNo: freezed == fisNo ? _self.fisNo : fisNo // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,needsManualEntry: null == needsManualEntry ? _self.needsManualEntry : needsManualEntry // ignore: cast_nullable_to_non_nullable
as bool,needsReminder: null == needsReminder ? _self.needsReminder : needsReminder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedDocument].
extension ExtractedDocumentPatterns on ExtractedDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedDocument value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  Map<String, String>? metadata,  bool needsManualEntry,  bool needsReminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedDocument() when $default != null:
return $default(_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.metadata,_that.needsManualEntry,_that.needsReminder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  Map<String, String>? metadata,  bool needsManualEntry,  bool needsReminder)  $default,) {final _that = this;
switch (_that) {
case _ExtractedDocument():
return $default(_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.metadata,_that.needsManualEntry,_that.needsReminder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocumentCategory category,  DocType docType,  String? period,  double? amount,  DateTime? dueDate,  String? fisNo,  String? personName,  Map<String, String>? metadata,  bool needsManualEntry,  bool needsReminder)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedDocument() when $default != null:
return $default(_that.category,_that.docType,_that.period,_that.amount,_that.dueDate,_that.fisNo,_that.personName,_that.metadata,_that.needsManualEntry,_that.needsReminder);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractedDocument implements ExtractedDocument {
  const _ExtractedDocument({required this.category, required this.docType, this.period, this.amount, this.dueDate, this.fisNo, this.personName, final  Map<String, String>? metadata, required this.needsManualEntry, required this.needsReminder}): _metadata = metadata;
  

@override final  DocumentCategory category;
@override final  DocType docType;
@override final  String? period;
@override final  double? amount;
@override final  DateTime? dueDate;
@override final  String? fisNo;
@override final  String? personName;
 final  Map<String, String>? _metadata;
@override Map<String, String>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// True when a required field couldn't be extracted confidently and the
// accountant must fill it in manually in the preview screen.
@override final  bool needsManualEntry;
// False for info documents, and for payment documents with a zero
// (fully offset/mahsup) amount — no reminder should be scheduled.
@override final  bool needsReminder;

/// Create a copy of ExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedDocumentCopyWith<_ExtractedDocument> get copyWith => __$ExtractedDocumentCopyWithImpl<_ExtractedDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedDocument&&(identical(other.category, category) || other.category == category)&&(identical(other.docType, docType) || other.docType == docType)&&(identical(other.period, period) || other.period == period)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.fisNo, fisNo) || other.fisNo == fisNo)&&(identical(other.personName, personName) || other.personName == personName)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.needsManualEntry, needsManualEntry) || other.needsManualEntry == needsManualEntry)&&(identical(other.needsReminder, needsReminder) || other.needsReminder == needsReminder));
}


@override
int get hashCode => Object.hash(runtimeType,category,docType,period,amount,dueDate,fisNo,personName,const DeepCollectionEquality().hash(_metadata),needsManualEntry,needsReminder);

@override
String toString() {
  return 'ExtractedDocument(category: $category, docType: $docType, period: $period, amount: $amount, dueDate: $dueDate, fisNo: $fisNo, personName: $personName, metadata: $metadata, needsManualEntry: $needsManualEntry, needsReminder: $needsReminder)';
}


}

/// @nodoc
abstract mixin class _$ExtractedDocumentCopyWith<$Res> implements $ExtractedDocumentCopyWith<$Res> {
  factory _$ExtractedDocumentCopyWith(_ExtractedDocument value, $Res Function(_ExtractedDocument) _then) = __$ExtractedDocumentCopyWithImpl;
@override @useResult
$Res call({
 DocumentCategory category, DocType docType, String? period, double? amount, DateTime? dueDate, String? fisNo, String? personName, Map<String, String>? metadata, bool needsManualEntry, bool needsReminder
});




}
/// @nodoc
class __$ExtractedDocumentCopyWithImpl<$Res>
    implements _$ExtractedDocumentCopyWith<$Res> {
  __$ExtractedDocumentCopyWithImpl(this._self, this._then);

  final _ExtractedDocument _self;
  final $Res Function(_ExtractedDocument) _then;

/// Create a copy of ExtractedDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? docType = null,Object? period = freezed,Object? amount = freezed,Object? dueDate = freezed,Object? fisNo = freezed,Object? personName = freezed,Object? metadata = freezed,Object? needsManualEntry = null,Object? needsReminder = null,}) {
  return _then(_ExtractedDocument(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as DocumentCategory,docType: null == docType ? _self.docType : docType // ignore: cast_nullable_to_non_nullable
as DocType,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,fisNo: freezed == fisNo ? _self.fisNo : fisNo // ignore: cast_nullable_to_non_nullable
as String?,personName: freezed == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,needsManualEntry: null == needsManualEntry ? _self.needsManualEntry : needsManualEntry // ignore: cast_nullable_to_non_nullable
as bool,needsReminder: null == needsReminder ? _self.needsReminder : needsReminder // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
