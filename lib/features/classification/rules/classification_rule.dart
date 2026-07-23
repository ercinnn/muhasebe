import '../models/extracted_document.dart';

abstract interface class ClassificationRule {
  /// Whether [rawText] (a PDF's full extracted text) matches this document
  /// type. Checked before [extract] is ever called.
  bool matches(String rawText);

  /// Extracts fields from [rawText]. Only called when [matches] is true.
  ExtractedDocument extract(String rawText);
}
