import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/classification/rules/sgk_ise_giris_rule.dart';

import '../fixtures.dart';

void main() {
  final rule = SgkIseGirisRule();

  test('matches only the işe giriş bildirgesi', () {
    expect(rule.matches(sgkIseGirisText), isTrue);
    expect(rule.matches(sgkIstenCikisText), isFalse);
    expect(rule.matches(unrelatedText), isFalse);
  });

  test('extracts employee name and start date as info category', () {
    final doc = rule.extract(sgkIseGirisText);
    expect(doc.category, DocumentCategory.info);
    expect(doc.docType, DocType.iseGiris);
    expect(doc.personName, 'AHMET YILMAZ');
    expect(doc.dueDate, DateTime(2026, 7, 1));
    expect(doc.needsReminder, isFalse);
    expect(doc.needsManualEntry, isFalse);
  });
}
