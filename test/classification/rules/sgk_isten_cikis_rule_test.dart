import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/classification/rules/sgk_isten_cikis_rule.dart';

import '../fixtures.dart';

void main() {
  final rule = SgkIstenCikisRule();

  test('matches only the işten ayrılış bildirgesi', () {
    expect(rule.matches(sgkIstenCikisText), isTrue);
    expect(rule.matches(sgkIseGirisText), isFalse);
    expect(rule.matches(unrelatedText), isFalse);
  });

  test('extracts employee name and termination date as info category', () {
    final doc = rule.extract(sgkIstenCikisText);
    expect(doc.category, DocumentCategory.info);
    expect(doc.docType, DocType.istenCikis);
    expect(doc.personName, 'AHMET YILMAZ');
    expect(doc.dueDate, DateTime(2026, 7, 15));
    expect(doc.needsReminder, isFalse);
    expect(doc.needsManualEntry, isFalse);
  });
}
