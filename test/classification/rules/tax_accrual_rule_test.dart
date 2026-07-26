import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/classification/rules/tax_accrual_rule.dart';

import '../fixtures.dart';

void main() {
  final rule = TaxAccrualRule();

  group('matches', () {
    test('true for a tax accrual notice', () {
      expect(rule.matches(kdvTaxAccrualText), isTrue);
    });

    test('false for unrelated text', () {
      expect(rule.matches(unrelatedText), isFalse);
    });
  });

  group('extract — KDV', () {
    final doc = rule.extract(kdvTaxAccrualText);

    test('classifies as payment/kdv', () {
      expect(doc.category, DocumentCategory.payment);
      expect(doc.docType, DocType.kdv);
    });

    test('extracts period, amount, due date, fiş no, person name', () {
      expect(doc.period, '05/2026-05/2026');
      expect(doc.amount, 1939.70);
      expect(doc.dueDate, DateTime(2026, 6, 26));
      expect(doc.fisNo, '2026072201Y7m0000088');
      expect(doc.personName, 'YILMAZ TİCARET LTD. ŞTİ.');
    });

    test('needs no manual entry and schedules a reminder', () {
      expect(doc.needsManualEntry, isFalse);
      expect(doc.needsReminder, isTrue);
    });
  });

  test('individual taxpayer combines ADI + SOYADI (ÜNVANI) into personName', () {
    final doc = rule.extract(individualKdvTaxAccrualText);
    expect(doc.personName, 'ERÇİN ÇAKALOĞLU');
  });

  test('KDV tevkifatı, geçici vergi doc types resolve correctly', () {
    expect(rule.extract(multiRowTaxAccrualText).docType, DocType.kdv2);
    expect(rule.extract(geciciVergiTaxAccrualText).docType, DocType.geciciVergi);
  });

  test('multi-line-item notice picks the earliest VADESİ and sums TOPLAM', () {
    final doc = rule.extract(multiRowTaxAccrualText);
    expect(doc.dueDate, DateTime(2026, 8, 20));
    expect(doc.amount, 970.25);
  });

  group('mahsup edge case (0,00 total)', () {
    final doc = rule.extract(mahsupTaxAccrualText);

    test('still classified as payment with amount 0', () {
      expect(doc.category, DocumentCategory.payment);
      expect(doc.amount, 0.0);
    });

    test('no reminder needed and no manual entry required', () {
      expect(doc.needsReminder, isFalse);
      expect(doc.needsManualEntry, isFalse);
    });
  });

  group('missing TOPLAM row', () {
    final doc = rule.extract(missingToplamTaxAccrualText);

    test('does not throw and flags manual entry', () {
      expect(doc.amount, isNull);
      expect(doc.needsManualEntry, isTrue);
      expect(doc.needsReminder, isFalse);
    });

    test('other fields still extracted', () {
      expect(doc.docType, DocType.muhtasar);
      expect(doc.dueDate, DateTime(2026, 5, 26));
    });
  });
}
