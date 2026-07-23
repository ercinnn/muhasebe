import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import '../parsing/tr_date_parser.dart';
import 'classification_rule.dart';

/// D) SGK İŞTEN AYRILIŞ BİLDİRGESİ — info-category termination notice.
class SgkIstenCikisRule implements ClassificationRule {
  @override
  bool matches(String rawText) => rawText.contains('SİGORTALI İŞTEN AYRILIŞ BİLDİRGESİ');

  @override
  ExtractedDocument extract(String rawText) {
    final personName = extractLabelValue(rawText, 'Adı Soyadı');
    final endDateRaw = extractLabelValue(rawText, 'İşten Ayrılış Tarihi');
    final endDate = endDateRaw == null ? null : parseTurkishDate(endDateRaw);

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
