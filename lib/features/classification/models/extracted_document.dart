import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/document_enums.dart';

part 'extracted_document.freezed.dart';

/// Result of running [DocumentClassifier] over a PDF's raw extracted text.
/// Pure data — no Flutter/IO dependency, so it stays testable with plain
/// `dart test`.
@freezed
abstract class ExtractedDocument with _$ExtractedDocument {
  const factory ExtractedDocument({
    required DocumentCategory category,
    required DocType docType,
    String? period,
    double? amount,
    DateTime? dueDate,
    String? fisNo,
    String? personName,
    Map<String, String>? metadata,
    // True when a required field couldn't be extracted confidently and the
    // accountant must fill it in manually in the preview screen.
    required bool needsManualEntry,
    // False for info documents, and for payment documents with a zero
    // (fully offset/mahsup) amount — no reminder should be scheduled.
    required bool needsReminder,
  }) = _ExtractedDocument;
}
