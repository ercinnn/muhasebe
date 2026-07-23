import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/features/classification/parsing/tr_number_parser.dart';

void main() {
  group('parseTurkishNumber', () {
    test('parses thousands + decimal separators', () {
      expect(parseTurkishNumber('1.939,70'), 1939.70);
      expect(parseTurkishNumber('19.421,64'), 19421.64);
    });

    test('parses zero', () {
      expect(parseTurkishNumber('0,00'), 0.0);
    });

    test('parses a plain integer with no separators', () {
      expect(parseTurkishNumber('1500'), 1500.0);
    });

    test('returns null for malformed input instead of throwing', () {
      expect(parseTurkishNumber('abc'), isNull);
      expect(parseTurkishNumber(''), isNull);
      expect(() => parseTurkishNumber('abc'), returnsNormally);
    });
  });
}
