import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import 'classification_rule.dart';

/// A) VERGİ TAHAKKUK FİŞİ — payment-category tax accrual notices issued by
/// the Ministry of Treasury and Finance (GİB): KDV, Muhtasar, KDV
/// tevkifatı, Geçici Vergi, Damga Vergisi.
class TaxAccrualRule implements ClassificationRule {
  static const _taxTypeToDocType = <String, DocType>{
    'GERÇEK USULDE KATMA DEĞER VERGİSİ': DocType.kdv,
    'KATMA DEĞER VERGİSİ TEVKİFATI': DocType.kdv2,
    'GELİR VERGİSİ S. (MUHTASAR)': DocType.muhtasar,
    'GELİR GEÇİCİ VERGİ': DocType.geciciVergi,
    'DAMGA VERGİSİ': DocType.damga,
  };

  @override
  bool matches(String rawText) =>
      rawText.contains('TAHAKKUK FİŞİ') && rawText.contains('HAZİNE VE MALİYE BAKANLIĞI');

  @override
  ExtractedDocument extract(String rawText) {
    String? taxTypeLabel;
    for (final label in _taxTypeToDocType.keys) {
      if (rawText.contains(label)) {
        taxTypeLabel = label;
        break;
      }
    }
    final docType = taxTypeLabel == null ? DocType.other : _taxTypeToDocType[taxTypeLabel]!;

    final personName = combineName(
      extractLineStartValue(rawText, 'ADI'),
      extractLineStartValue(rawText, 'SOYADI (UNVANI)'),
    );
    final period = extractTaxPeriod(rawText);
    final amount = extractAmountFromLabelLine(rawText, 'TOPLAM');
    final dueDate = extractEarliestRowDueDate(rawText);
    final fisNo = extractFisNo(rawText);

    return ExtractedDocument(
      category: DocumentCategory.payment,
      docType: docType,
      period: period,
      amount: amount,
      dueDate: dueDate,
      fisNo: fisNo,
      personName: personName,
      metadata: taxTypeLabel == null ? null : {'taxTypeLabel': taxTypeLabel},
      needsManualEntry: docType == DocType.other || amount == null,
      // Fully offset (mahsup) notices post a 0,00 total — no reminder needed.
      needsReminder: amount != null && amount > 0,
    );
  }
}
