/// Parses a Turkish-formatted decimal number, e.g. "19.421,64" (`.` as
/// thousands separator, `,` as decimal separator), into a [double].
/// Returns null for unparseable input rather than throwing.
double? parseTurkishNumber(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(normalized);
}
