import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/features/classification/parsing/tr_date_parser.dart';

void main() {
  group('parseTurkishDate', () {
    test('slash and dot separators parse to the same date', () {
      final slash = parseTurkishDate('23/07/2026');
      final dot = parseTurkishDate('23.07.2026');
      expect(slash, DateTime(2026, 7, 23));
      expect(dot, DateTime(2026, 7, 23));
    });

    test('rejects an out-of-range day instead of rolling over', () {
      expect(parseTurkishDate('31/02/2026'), isNull);
    });

    test('returns null for malformed input', () {
      expect(parseTurkishDate('not a date'), isNull);
    });
  });

  group('parseEarliestDate', () {
    test('picks the earliest date from an unordered list', () {
      final earliest = parseEarliestDate(['26/08/2026', '20/08/2026', '30/08/2026']);
      expect(earliest, DateTime(2026, 8, 20));
    });

    test('ignores unparseable entries', () {
      final earliest = parseEarliestDate(['not a date', '20/08/2026']);
      expect(earliest, DateTime(2026, 8, 20));
    });

    test('returns null for an empty or all-invalid list', () {
      expect(parseEarliestDate([]), isNull);
      expect(parseEarliestDate(['x', 'y']), isNull);
    });
  });
}
