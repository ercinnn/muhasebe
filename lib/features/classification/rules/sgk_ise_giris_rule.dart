import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import '../parsing/tr_date_parser.dart';
import 'classification_rule.dart';

/// C) SGK İŞE GİRİŞ BİLDİRGESİ — info-category new-hire notice.
class SgkIseGirisRule implements ClassificationRule {
  @override
  bool matches(String rawText) => rawText.contains('SİGORTALI İŞE GİRİŞ BİLDİRGESİ');

  @override
  ExtractedDocument extract(String rawText) {
    final personName = extractLabelValue(rawText, 'Adı Soyadı');
    final startDateRaw = extractLabelValue(rawText, 'İşe Başlama Tarihi');
    final startDate = startDateRaw == null ? null : parseTurkishDate(startDateRaw);
    final occupationCode = extractLabelValue(rawText, 'Meslek Kodu');

    return ExtractedDocument(
      category: DocumentCategory.info,
      docType: DocType.iseGiris,
      // Reuses the shared `due_date` column (documents table has no
      // per-type date field) to carry the start date for the Bilgilendirme
      // screen's date display.
      dueDate: startDate,
      personName: personName,
      metadata: occupationCode == null ? null : {'meslekKodu': occupationCode},
      needsManualEntry: personName == null || startDate == null,
      needsReminder: false,
    );
  }
}
