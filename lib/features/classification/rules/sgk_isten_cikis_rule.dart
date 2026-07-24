import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import '../parsing/tr_date_parser.dart';
import 'classification_rule.dart';

// The real e-SGK "İşten Ayrılış Bildirgesi" PDF prints "İşten Ayrılış
// Tarihi"'s value at the START of a line, immediately followed by the next
// field's leftover item number (e.g. "30.04.2026 16") rather than alone on
// its own line — unlike the İşe Giriş bildirgesi's start date. Anchoring on
// line-start (rather than a bare `firstMatch` over the whole text) skips
// past the static form boilerplate date ("01.10.2008 Tarihinden Önce
// Hizmeti...") that appears earlier in the document.
final _leadingDatePattern = RegExp(r'^(\d{2}\.\d{2}\.\d{4})\s');

/// D) SGK İŞTEN AYRILIŞ BİLDİRGESİ — info-category termination notice.
class SgkIstenCikisRule implements ClassificationRule {
  @override
  bool matches(String rawText) => rawText.contains('SİGORTALI İŞTEN AYRILIŞ BİLDİRGESİ');

  @override
  ExtractedDocument extract(String rawText) {
    final personName = extractSgkBildirgePersonName(rawText);

    DateTime? endDate;
    for (final line in rawText.split('\n')) {
      final match = _leadingDatePattern.firstMatch(line);
      if (match == null) continue;
      endDate = parseTurkishDate(match.group(1)!);
      break;
    }

    return ExtractedDocument(
      category: DocumentCategory.info,
      docType: DocType.istenCikis,
      // See SgkIseGirisRule — reuses the shared due_date column.
      dueDate: endDate,
      personName: personName,
      needsManualEntry: personName == null || endDate == null,
      needsReminder: false,
    );
  }
}
