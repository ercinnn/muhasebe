// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadDraft {

 String get id; String get fileName; Uint8List get fileBytes; UploadDraftStatus get status; String? get rawText; ExtractedDocument? get extracted; String? get selectedClientId; bool get isDuplicate; bool get usedOcr; String? get errorMessage;
/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadDraftCopyWith<UploadDraft> get copyWith => _$UploadDraftCopyWithImpl<UploadDraft>(this as UploadDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.fileBytes, fileBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.extracted, extracted) || other.extracted == extracted)&&(identical(other.selectedClientId, selectedClientId) || other.selectedClientId == selectedClientId)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.usedOcr, usedOcr) || other.usedOcr == usedOcr)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,fileName,const DeepCollectionEquality().hash(fileBytes),status,rawText,extracted,selectedClientId,isDuplicate,usedOcr,errorMessage);

@override
String toString() {
  return 'UploadDraft(id: $id, fileName: $fileName, fileBytes: $fileBytes, status: $status, rawText: $rawText, extracted: $extracted, selectedClientId: $selectedClientId, isDuplicate: $isDuplicate, usedOcr: $usedOcr, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $UploadDraftCopyWith<$Res>  {
  factory $UploadDraftCopyWith(UploadDraft value, $Res Function(UploadDraft) _then) = _$UploadDraftCopyWithImpl;
@useResult
$Res call({
 String id, String fileName, Uint8List fileBytes, UploadDraftStatus status, String? rawText, ExtractedDocument? extracted, String? selectedClientId, bool isDuplicate, bool usedOcr, String? errorMessage
});


$ExtractedDocumentCopyWith<$Res>? get extracted;

}
/// @nodoc
class _$UploadDraftCopyWithImpl<$Res>
    implements $UploadDraftCopyWith<$Res> {
  _$UploadDraftCopyWithImpl(this._self, this._then);

  final UploadDraft _self;
  final $Res Function(UploadDraft) _then;

/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileName = null,Object? fileBytes = null,Object? status = null,Object? rawText = freezed,Object? extracted = freezed,Object? selectedClientId = freezed,Object? isDuplicate = null,Object? usedOcr = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileBytes: null == fileBytes ? _self.fileBytes : fileBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadDraftStatus,rawText: freezed == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String?,extracted: freezed == extracted ? _self.extracted : extracted // ignore: cast_nullable_to_non_nullable
as ExtractedDocument?,selectedClientId: freezed == selectedClientId ? _self.selectedClientId : selectedClientId // ignore: cast_nullable_to_non_nullable
as String?,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,usedOcr: null == usedOcr ? _self.usedOcr : usedOcr // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedDocumentCopyWith<$Res>? get extracted {
    if (_self.extracted == null) {
    return null;
  }

  return $ExtractedDocumentCopyWith<$Res>(_self.extracted!, (value) {
    return _then(_self.copyWith(extracted: value));
  });
}
}


/// Adds pattern-matching-related methods to [UploadDraft].
extension UploadDraftPatterns on UploadDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadDraft value)  $default,){
final _that = this;
switch (_that) {
case _UploadDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadDraft value)?  $default,){
final _that = this;
switch (_that) {
case _UploadDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileName,  Uint8List fileBytes,  UploadDraftStatus status,  String? rawText,  ExtractedDocument? extracted,  String? selectedClientId,  bool isDuplicate,  bool usedOcr,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadDraft() when $default != null:
return $default(_that.id,_that.fileName,_that.fileBytes,_that.status,_that.rawText,_that.extracted,_that.selectedClientId,_that.isDuplicate,_that.usedOcr,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileName,  Uint8List fileBytes,  UploadDraftStatus status,  String? rawText,  ExtractedDocument? extracted,  String? selectedClientId,  bool isDuplicate,  bool usedOcr,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _UploadDraft():
return $default(_that.id,_that.fileName,_that.fileBytes,_that.status,_that.rawText,_that.extracted,_that.selectedClientId,_that.isDuplicate,_that.usedOcr,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileName,  Uint8List fileBytes,  UploadDraftStatus status,  String? rawText,  ExtractedDocument? extracted,  String? selectedClientId,  bool isDuplicate,  bool usedOcr,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _UploadDraft() when $default != null:
return $default(_that.id,_that.fileName,_that.fileBytes,_that.status,_that.rawText,_that.extracted,_that.selectedClientId,_that.isDuplicate,_that.usedOcr,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _UploadDraft implements UploadDraft {
  const _UploadDraft({required this.id, required this.fileName, required this.fileBytes, required this.status, this.rawText, this.extracted, this.selectedClientId, this.isDuplicate = false, this.usedOcr = false, this.errorMessage});
  

@override final  String id;
@override final  String fileName;
@override final  Uint8List fileBytes;
@override final  UploadDraftStatus status;
@override final  String? rawText;
@override final  ExtractedDocument? extracted;
@override final  String? selectedClientId;
@override@JsonKey() final  bool isDuplicate;
@override@JsonKey() final  bool usedOcr;
@override final  String? errorMessage;

/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadDraftCopyWith<_UploadDraft> get copyWith => __$UploadDraftCopyWithImpl<_UploadDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&const DeepCollectionEquality().equals(other.fileBytes, fileBytes)&&(identical(other.status, status) || other.status == status)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.extracted, extracted) || other.extracted == extracted)&&(identical(other.selectedClientId, selectedClientId) || other.selectedClientId == selectedClientId)&&(identical(other.isDuplicate, isDuplicate) || other.isDuplicate == isDuplicate)&&(identical(other.usedOcr, usedOcr) || other.usedOcr == usedOcr)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,fileName,const DeepCollectionEquality().hash(fileBytes),status,rawText,extracted,selectedClientId,isDuplicate,usedOcr,errorMessage);

@override
String toString() {
  return 'UploadDraft(id: $id, fileName: $fileName, fileBytes: $fileBytes, status: $status, rawText: $rawText, extracted: $extracted, selectedClientId: $selectedClientId, isDuplicate: $isDuplicate, usedOcr: $usedOcr, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$UploadDraftCopyWith<$Res> implements $UploadDraftCopyWith<$Res> {
  factory _$UploadDraftCopyWith(_UploadDraft value, $Res Function(_UploadDraft) _then) = __$UploadDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileName, Uint8List fileBytes, UploadDraftStatus status, String? rawText, ExtractedDocument? extracted, String? selectedClientId, bool isDuplicate, bool usedOcr, String? errorMessage
});


@override $ExtractedDocumentCopyWith<$Res>? get extracted;

}
/// @nodoc
class __$UploadDraftCopyWithImpl<$Res>
    implements _$UploadDraftCopyWith<$Res> {
  __$UploadDraftCopyWithImpl(this._self, this._then);

  final _UploadDraft _self;
  final $Res Function(_UploadDraft) _then;

/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileName = null,Object? fileBytes = null,Object? status = null,Object? rawText = freezed,Object? extracted = freezed,Object? selectedClientId = freezed,Object? isDuplicate = null,Object? usedOcr = null,Object? errorMessage = freezed,}) {
  return _then(_UploadDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileBytes: null == fileBytes ? _self.fileBytes : fileBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadDraftStatus,rawText: freezed == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String?,extracted: freezed == extracted ? _self.extracted : extracted // ignore: cast_nullable_to_non_nullable
as ExtractedDocument?,selectedClientId: freezed == selectedClientId ? _self.selectedClientId : selectedClientId // ignore: cast_nullable_to_non_nullable
as String?,isDuplicate: null == isDuplicate ? _self.isDuplicate : isDuplicate // ignore: cast_nullable_to_non_nullable
as bool,usedOcr: null == usedOcr ? _self.usedOcr : usedOcr // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UploadDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExtractedDocumentCopyWith<$Res>? get extracted {
    if (_self.extracted == null) {
    return null;
  }

  return $ExtractedDocumentCopyWith<$Res>(_self.extracted!, (value) {
    return _then(_self.copyWith(extracted: value));
  });
}
}

// dart format on
