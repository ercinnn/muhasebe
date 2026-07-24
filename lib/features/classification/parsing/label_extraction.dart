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

/// Extracts the value following [label] when both share one line with no
/// colon between them — the layout GİB's tahakkuk fişi PDFs actually use
/// (e.g. a line reading "ADI ERÇİN" rather than "ADI: ERÇİN"). Matching is
/// anchored to the start of the line so a label that is a suffix of another
/// (e.g. "ADI" inside "SOYADI (UNVANI)") can't match on the wrong line. A
/// bare "-" placeholder is treated as absent and returns null.
String? extractLineStartValue(String text, String label) {
  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (!line.startsWith(label)) continue;
    var rest = line.substring(label.length);
    if (rest.isNotEmpty && !rest.startsWith(RegExp(r'[\s:]'))) continue;
    rest = rest.trim();
    if (rest.startsWith(':')) rest = rest.substring(1).trim();
    if (rest.isEmpty || rest == '-') return null;
    return rest;
  }
  return null;
}

final _taxPeriodPattern = RegExp(r'\d{2}/\d{4}-\d{2}/\d{4}');

/// Extracts the "MM/YYYY-MM/YYYY" tax period token found anywhere in the
/// text. GİB tahakkuk fişi PDFs print this value on its own row, separated
/// from the "Vergilendirme Dönemi" column header by the PDF's text
/// extraction order, so it can't be matched as a same-line label/value pair.
String? extractTaxPeriod(String text) => _taxPeriodPattern.firstMatch(text)?.group(0);

final _trailingDatePattern = RegExp(r'(\d{2}/\d{2}/\d{4})\s*$');

/// Extracts every due date from the tax line-item rows and returns the
/// earliest. Each row ends with a DD/MM/YYYY "Vadesi" date and also contains
/// a Turkish amount, which distinguishes it from unrelated date-bearing
/// rows (e.g. the Kabul Tarihi/Düzenleme Tarihi row).
DateTime? extractEarliestRowDueDate(String text) {
  final dates = <String>[];
  for (final line in text.split('\n')) {
    if (!_amountPattern.hasMatch(line)) continue;
    final match = _trailingDatePattern.firstMatch(line.trim());
    if (match != null) dates.add(match.group(1)!);
  }
  return parseEarliestDate(dates);
}

final _fisNoPattern = RegExp(r'\b\d{8}[0-9A-Za-z]{6,}\b');

/// Extracts the barcode-encoded receipt number ("Fiş No"). GİB's tahakkuk
/// fişi PDFs don't print a "Fiş No:" label at all — the receipt number is
/// the alphanumeric code under the barcode (an 8-digit date prefix followed
/// by an office/sequence code, e.g. "2026072201Y7m0000088").
String? extractFisNo(String text) => _fisNoPattern.firstMatch(text)?.group(0);
