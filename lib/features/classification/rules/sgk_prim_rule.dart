import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import 'classification_rule.dart';

final _periodPattern = RegExp(r'\b(\d{4})/(\d{1,2})\b');

/// Last day of the month following [year]/[month] — SGK prim accrual
/// notices don't print a due date, so it's computed from the period.
/// E.g. 2026/06 -> 31/07/2026; 2026/12 -> 31/01/2027; 2028/01 -> 29/02/2028.
DateTime sgkDueDate(int year, int month) {
  final nextMonth = month == 12 ? 1 : month + 1;
  final nextYear = month == 12 ? year + 1 : year;
  final monthAfterNext = nextMonth == 12 ? 1 : nextMonth + 1;
  final yearAfterNext = nextMonth == 12 ? nextYear + 1 : nextYear;
  // Day 0 of monthAfterNext == last day of nextMonth.
  return DateTime(yearAfterNext, monthAfterNext, 0);
}

/// B) SGK PRİM TAHAKKUK FİŞİ — payment-category social security premium
/// accrual notices.
class SgkPrimRule implements ClassificationRule {
  @override
  bool matches(String rawText) =>
      rawText.contains('SOSYAL GÜVENLİK KURUMU') &&
      rawText.contains('TAHAKKUK') &&
      rawText.contains('PRİM TUTARI');

  @override
  ExtractedDocument extract(String rawText) {
    // "AİT OLDUĞU YIL / AY" isn't followed by its value on the same line —
    // e-SGK's tahakkuk fişi dumps every field's label, then every field's
    // value, in a different order. The period is the only "YYYY/MM" token
    // in the document, so it's found directly rather than via its label.
    final periodMatch = _periodPattern.firstMatch(rawText);
    final period = periodMatch?.group(0);

    DateTime? dueDate;
    if (periodMatch != null) {
      final year = int.parse(periodMatch.group(1)!);
      final month = int.parse(periodMatch.group(2)!);
      dueDate = sgkDueDate(year, month);
    }

    // "Unvanı" isn't on the same line as its value either. In the fixed
    // template, the employer name is printed two lines above the period
    // value (Unvanı, Belge Kabul Tarihi, AİT OLDUĞU YIL / AY, in that order).
    String? personName;
    if (period != null) {
      final lines = rawText.split('\n');
      final periodIndex = lines.indexWhere((line) => line.trim() == period);
      if (periodIndex >= 2) {
        final candidate = lines[periodIndex - 2].trim();
        if (candidate.isNotEmpty) personName = candidate;
      }
    }

    // "ÖDENECEK NET TUTAR" is always the final figure printed on the page.
    final amount = extractLastAmount(rawText);

    return ExtractedDocument(
      category: DocumentCategory.payment,
      docType: DocType.sgkPrim,
      period: period,
      amount: amount,
      dueDate: dueDate,
      personName: personName,
      needsManualEntry: amount == null || dueDate == null,
      needsReminder: amount != null && amount > 0,
    );
  }
}
