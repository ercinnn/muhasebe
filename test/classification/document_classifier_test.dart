import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/classification/document_classifier.dart';

import 'fixtures.dart';

void main() {
  final classifier = DocumentClassifier();

  test('routes each known document type to the correct rule', () {
    expect(classifier.classify(kdvTaxAccrualText).docType, DocType.kdv);
    expect(classifier.classify(sgkPrimText).docType, DocType.sgkPrim);
    expect(classifier.classify(sgkIseGirisText).docType, DocType.iseGiris);
    expect(classifier.classify(sgkIstenCikisText).docType, DocType.istenCikis);
  });

  test('unrelated text is unclassified and flagged for manual entry', () {
    final doc = classifier.classify(unrelatedText);
    expect(doc.category, DocumentCategory.unclassified);
    expect(doc.docType, DocType.other);
    expect(doc.needsManualEntry, isTrue);
    expect(doc.needsReminder, isFalse);
  });

  test('rule precedence: a tax accrual notice is never misread as an SGK notice', () {
    final doc = classifier.classify(kdvTaxAccrualText);
    expect(doc.docType, isNot(DocType.sgkPrim));
    expect(doc.category, DocumentCategory.payment);
  });
}
