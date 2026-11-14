import 'package:flutter_test/flutter_test.dart';
import 'package:lead_tracker/core/validators.dart';

void main() {
  group('emailValidator', () {
    test('accepts empty (optional)', () {
      expect(emailValidator(''), isNull);
      expect(emailValidator(null), isNull);
    });
    test('accepts valid email', () {
      expect(emailValidator('user@example.com'), isNull);
    });
    test('rejects invalid email', () {
      expect(emailValidator('not-an-email'), isNotNull);
      expect(emailValidator('a@b'), isNotNull);
    });
  });

  group('phoneValidator', () {
    test('requires value by default', () {
      expect(phoneValidator(''), isNotNull);
    });
    test('accepts valid 10-digit Indian mobile', () {
      expect(phoneValidator('9876543210'), isNull);
      expect(phoneValidator('6123456789'), isNull);
    });
    test('rejects wrong length or prefix', () {
      expect(phoneValidator('12345'), isNotNull);
      expect(phoneValidator('5876543210'), isNotNull); // starts with 5
    });
  });

  group('signupPasswordValidator', () {
    test('requires letter and number', () {
      expect(signupPasswordValidator('abcdef'), isNotNull);
      expect(signupPasswordValidator('123456'), isNotNull);
      expect(signupPasswordValidator('abc123'), isNull);
    });
    test('requires min length', () {
      expect(signupPasswordValidator('a1b'), isNotNull);
    });
  });

  group('nameValidator', () {
    test('requires min 2 chars', () {
      expect(nameValidator('A'), isNotNull);
      expect(nameValidator('Al'), isNull);
    });
  });
}
