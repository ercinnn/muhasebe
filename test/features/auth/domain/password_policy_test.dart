import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/features/auth/domain/password_policy.dart';

void main() {
  group('validatePasswordStrength', () {
    test('accepts a password meeting all requirements', () {
      expect(validatePasswordStrength('Sifre123'), isNull);
    });

    test('rejects passwords under 8 characters', () {
      expect(validatePasswordStrength('Aa1'), isNotNull);
    });

    test('rejects passwords missing a lowercase letter', () {
      expect(validatePasswordStrength('SIFRE123'), isNotNull);
    });

    test('rejects passwords missing an uppercase letter', () {
      expect(validatePasswordStrength('sifre123'), isNotNull);
    });

    test('rejects passwords missing a digit', () {
      expect(validatePasswordStrength('SifreSifre'), isNotNull);
    });

    test('rejects null/empty input', () {
      expect(validatePasswordStrength(null), isNotNull);
      expect(validatePasswordStrength(''), isNotNull);
    });
  });
}
