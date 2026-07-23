final _dateSeparatorPattern = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$');

/// Parses "23/07/2026" or "23.07.2026" (DD/MM/YYYY or DD.MM.YYYY) into a
/// [DateTime]. Returns null for unparseable or out-of-range input (e.g.
/// "31/02/2026") rather than throwing.
DateTime? parseTurkishDate(String input) {
  final match = _dateSeparatorPattern.firstMatch(input.trim());
  if (match == null) return null;

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  if (month < 1 || month > 12) return null;

  final date = DateTime(year, month, day);
  // DateTime silently rolls over invalid days (e.g. 31/02 -> 03/03); reject those.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// Parses every string in [rawDates] and returns the earliest successfully
/// parsed date, or null if none parse. Used for the tax accrual notice's
/// "VADESİ" column, which can list one due date per line item.
DateTime? parseEarliestDate(Iterable<String> rawDates) {
  final parsed = rawDates.map(parseTurkishDate).whereType<DateTime>().toList()..sort();
  return parsed.isEmpty ? null : parsed.first;
}
