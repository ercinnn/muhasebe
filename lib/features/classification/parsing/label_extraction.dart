import 'tr_date_parser.dart';
import 'tr_number_parser.dart';

final _amountPattern = RegExp(r'\d{1,3}(?:\.\d{3})*,\d{2}');

/// Extracts the value after `label:` on the first line containing it, e.g.
/// `extractLabelValue(text, 'Vergilendirme Dönemi')` for a line reading
/// "Vergilendirme Dönemi: 05/2026-05/2026" returns "05/2026-05/2026".
/// A bare "-" placeholder (common for an unused ADI field) is treated as
/// absent and returns null.
String? extractLabelValue(String text, String label) {
  final pattern = RegExp('${RegExp.escape(label)}\\s*:\\s*(.+)');
  final value = pattern.firstMatch(text)?.group(1)?.trim();
  if (value == null || value.isEmpty || value == '-') return null;
  return value;
}

/// Extracts every value following `label:` across the whole text (a label
/// that repeats once per table row/line item).
List<String> extractAllLabelValues(String text, String label) {
  final pattern = RegExp('${RegExp.escape(label)}\\s*:\\s*(\\S.*)');
  return pattern
      .allMatches(text)
      .map((m) => m.group(1)?.trim())
      .whereType<String>()
      .where((v) => v.isNotEmpty && v != '-')
      .toList();
}

/// Finds the line containing [label] and returns the last Turkish-formatted
/// amount on that line (the rightmost column in a totals row, e.g. TOPLAM).
double? extractAmountFromLabelLine(String text, String label) {
  for (final line in text.split('\n')) {
    if (!line.contains(label)) continue;
    final matches = _amountPattern.allMatches(line).toList();
    if (matches.isEmpty) continue;
    return parseTurkishNumber(matches.last.group(0)!);
  }
  return null;
}

/// Returns the earliest date among all values following `label:` in the
/// text (e.g. one "Vadesi:" per tax line item).
DateTime? extractEarliestDateForLabel(String text, String label) =>
    parseEarliestDate(extractAllLabelValues(text, label));

String? combineName(String? firstName, String? surnameOrTitle) {
  if (firstName == null) return surnameOrTitle;
  if (surnameOrTitle == null) return firstName;
  return '$firstName $surnameOrTitle';
}
