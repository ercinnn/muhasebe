import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import '../parsing/tr_date_parser.dart';
import 'classification_rule.dart';

// The real e-SGK "İşe Giriş Bildirgesi" PDF prints "İşe başlama tarihi"'s
// value on its own standalone line (nothing else on the line), well after
// the label itself — this distinguishes it from the document's own
// generation timestamp, which always trails other text on its line (e.g.
// "...kapsamındaki sigortalılar için) 16.04.2026 10:01:45").
final _standaloneDatePattern = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');

/// C) SGK İŞE GİRİŞ BİLDİRGESİ — info-category new-hire notice.
class SgkIseGirisRule implements ClassificationRule {
  @override
  bool matches(String rawText) => rawText.contains('SİGORTALI İŞE GİRİŞ BİLDİRGESİ');

  @override
  ExtractedDocument extract(String rawText) {
    final personName = extractSgkBildirgePersonName(rawText);

    DateTime? startDate;
    for (final line in rawText.split('\n')) {
      if (!_standaloneDatePattern.hasMatch(line.trim())) continue;
      startDate = parseTurkishDate(line.trim());
      break;
    }

    return ExtractedDocument(
      category: DocumentCategory.info,
      docType: DocType.iseGiris,
      // Reuses the shared `due_date` column (documents table has no
      // per-type date field) to carry the start date for the Bilgilendirme
      // screen's date display.
      dueDate: startDate,
      personName: personName,
      needsManualEntry: personName == null || startDate == null,
      needsReminder: false,
    );
  }
}
