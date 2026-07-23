import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../classification/models/extracted_document.dart';

part 'upload_draft.freezed.dart';

enum UploadDraftStatus { parsing, needsReview, sending, sent, error }

/// One selected PDF's state as it moves through parse -> preview/correct
/// -> pick client -> send.
@freezed
abstract class UploadDraft with _$UploadDraft {
  const factory UploadDraft({
    required String id,
    required String fileName,
    required Uint8List fileBytes,
    required UploadDraftStatus status,
    String? rawText,
    ExtractedDocument? extracted,
    String? selectedClientId,
    @Default(false) bool isDuplicate,
    @Default(false) bool usedOcr,
    String? errorMessage,
  }) = _UploadDraft;
}
