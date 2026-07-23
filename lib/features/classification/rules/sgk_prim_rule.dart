import '../../../core/constants/document_enums.dart';
import '../models/extracted_document.dart';
import '../parsing/label_extraction.dart';
import 'classification_rule.dart';

final _periodPattern = RegExp(r'(\d{4})/(\d{1,2})');

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
    final personName = extractLabelValue(rawText, 'Unvan');
    final period = extractLabelValue(rawText, 'AİT OLDUĞU YIL / AY');
    final amount = extractAmountFromLabelLine(rawText, 'ÖDENECEK NET TUTAR');

    DateTime? dueDate;
    final periodMatch = period == null ? null : _periodPattern.firstMatch(period);
    if (periodMatch != null) {
      final year = int.parse(periodMatch.group(1)!);
      final month = int.parse(periodMatch.group(2)!);
      dueDate = sgkDueDate(year, month);
    }

    final headCount = extractLabelValue(rawText, 'Sigortalı Sayısı');
    final dayCount = extractLabelValue(rawText, 'Gün Sayısı');
    final metadata = <String, String>{
      'sigortaliSayisi': ?headCount,
      'gunSayisi': ?dayCount,
    };

    return ExtractedDocument(
      category: DocumentCategory.payment,
      docType: DocType.sgkPrim,
      period: period,
      amount: amount,
      dueDate: dueDate,
      personName: personName,
      metadata: metadata.isEmpty ? null : metadata,
      needsManualEntry: amount == null || dueDate == null,
      needsReminder: amount != null && amount > 0,
    );
  }
}
