import '../../core/constants/document_enums.dart';
import 'models/extracted_document.dart';
import 'rules/classification_rule.dart';
import 'rules/sgk_ise_giris_rule.dart';
import 'rules/sgk_isten_cikis_rule.dart';
import 'rules/sgk_prim_rule.dart';
import 'rules/tax_accrual_rule.dart';

/// Tries each rule in order (A: tax accrual, B: SGK prim, C: SGK işe giriş,
/// D: SGK işten ayrılış); the first match wins. No match -> unclassified
/// with needsManualEntry so the accountant fills the preview form by hand.
class DocumentClassifier {
  DocumentClassifier({List<ClassificationRule>? rules})
    : _rules = rules ?? [TaxAccrualRule(), SgkPrimRule(), SgkIseGirisRule(), SgkIstenCikisRule()];

  final List<ClassificationRule> _rules;

  ExtractedDocument classify(String rawText) {
    for (final rule in _rules) {
      if (rule.matches(rawText)) {
        return rule.extract(rawText);
      }
    }
    return const ExtractedDocument(
      category: DocumentCategory.unclassified,
      docType: DocType.other,
      needsManualEntry: true,
      needsReminder: false,
    );
  }
}
