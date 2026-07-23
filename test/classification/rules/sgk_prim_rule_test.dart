import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/classification/rules/sgk_prim_rule.dart';

import '../fixtures.dart';

void main() {
  final rule = SgkPrimRule();

  group('matches', () {
    test('true for an SGK prim accrual notice', () {
      expect(rule.matches(sgkPrimText), isTrue);
    });

    test('false for unrelated text', () {
      expect(rule.matches(unrelatedText), isFalse);
    });
  });

  test('extracts unvan, period, amount', () {
    final doc = rule.extract(sgkPrimText);
    expect(doc.category, DocumentCategory.payment);
    expect(doc.docType, DocType.sgkPrim);
    expect(doc.personName, 'YILMAZ TİCARET LTD. ŞTİ.');
    expect(doc.period, '2026/06');
    expect(doc.amount, 45230.50);
    expect(doc.needsManualEntry, isFalse);
    expect(doc.needsReminder, isTrue);
  });

  group('sgkDueDate (dönemi takip eden ayın son günü)', () {
    test('regular month: 2026/06 -> 31/07/2026', () {
      expect(sgkDueDate(2026, 6), DateTime(2026, 7, 31));
      expect(rule.extract(sgkPrimText).dueDate, DateTime(2026, 7, 31));
    });

    test('year rollover: 2026/12 -> 31/01/2027', () {
      expect(sgkDueDate(2026, 12), DateTime(2027, 1, 31));
      expect(rule.extract(sgkPrimYearRolloverText).dueDate, DateTime(2027, 1, 31));
    });

    test('leap year: 2028/01 -> 29/02/2028', () {
      expect(sgkDueDate(2028, 1), DateTime(2028, 2, 29));
      expect(rule.extract(sgkPrimLeapYearText).dueDate, DateTime(2028, 2, 29));
    });
  });
}
