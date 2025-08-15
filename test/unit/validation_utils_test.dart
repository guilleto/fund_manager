import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils Tests', () {
    group('Email Validation', () {
      test('should validate correct email addresses', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          '123@example.com',
        ];

        for (final email in validEmails) {
          expect(ValidationUtils.isValidEmail(email), true);
        }
      });

      test('should reject invalid email addresses', () {
        final invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user@.com',
          'user..name@example.com',
        ];

        for (final email in invalidEmails) {
          expect(ValidationUtils.isValidEmail(email), false);
        }
      });

      test('should return error message for empty email', () {
        final result = ValidationUtils.validateEmail('');
        expect(result, 'El email es requerido');
      });

      test('should return error message for null email', () {
        final result = ValidationUtils.validateEmail(null);
        expect(result, 'El email es requerido');
      });

      test('should return error message for invalid email', () {
        final result = ValidationUtils.validateEmail('invalid-email');
        expect(result, 'Ingrese un email válido');
      });

      test('should return null for valid email', () {
        final result = ValidationUtils.validateEmail('test@example.com');
        expect(result, null);
      });
    });

    group('Password Validation', () {
      test('should validate correct passwords', () {
        final validPasswords = [
          'Password123',
          'MySecurePass1',
          'ComplexP@ss1',
        ];

        for (final password in validPasswords) {
          expect(ValidationUtils.isValidPassword(password), true);
        }
      });

      test('should reject invalid passwords', () {
        final invalidPasswords = [
          'password', // Sin mayúscula ni número
          'PASSWORD', // Sin minúscula ni número
          'Password', // Sin número
          'pass123', // Sin mayúscula
          'Pass', // Muy corta
        ];

        for (final password in invalidPasswords) {
          expect(ValidationUtils.isValidPassword(password), false);
        }
      });

      test('should return error message for empty password', () {
        final result = ValidationUtils.validatePassword('');
        expect(result, 'La contraseña es requerida');
      });

      test('should return error message for short password', () {
        final result = ValidationUtils.validatePassword('Pass1');
        expect(result, 'La contraseña debe tener al menos 8 caracteres');
      });

      test('should return error message for invalid password', () {
        final result = ValidationUtils.validatePassword('password');
        expect(result, 'La contraseña debe contener al menos una letra mayúscula, una minúscula y un número');
      });

      test('should return null for valid password', () {
        final result = ValidationUtils.validatePassword('Password123');
        expect(result, null);
      });
    });

    group('Required Field Validation', () {
      test('should return error message for empty value', () {
        final result = ValidationUtils.validateRequired('', 'Campo');
        expect(result, 'Campo es requerido');
      });

      test('should return error message for null value', () {
        final result = ValidationUtils.validateRequired(null, 'Campo');
        expect(result, 'Campo es requerido');
      });

      test('should return error message for whitespace only', () {
        final result = ValidationUtils.validateRequired('   ', 'Campo');
        expect(result, 'Campo es requerido');
      });

      test('should return null for valid value', () {
        final result = ValidationUtils.validateRequired('Valid Value', 'Campo');
        expect(result, null);
      });
    });

    group('Length Validation', () {
      test('should validate minimum length', () {
        final result = ValidationUtils.validateMinLength('abc', 5, 'Campo');
        expect(result, 'Campo debe tener al menos 5 caracteres');
      });

      test('should validate maximum length', () {
        final result = ValidationUtils.validateMaxLength('abcdef', 3, 'Campo');
        expect(result, 'Campo no puede tener más de 3 caracteres');
      });

      test('should return null for valid length', () {
        final result = ValidationUtils.validateMinLength('abcdef', 5, 'Campo');
        expect(result, null);
      });
    });

    group('Amount Validation', () {
      test('should validate correct amounts', () {
        final validAmounts = [
          '100',
          '100.50',
          '1000.00',
          '0.01',
        ];

        for (final amount in validAmounts) {
          expect(ValidationUtils.isValidAmount(amount), true);
        }
      });

      test('should reject invalid amounts', () {
        final invalidAmounts = [
          '100.123', // Más de 2 decimales
          'abc',
          '100.',
          '.50',
          '-100',
        ];

        for (final amount in invalidAmounts) {
          expect(ValidationUtils.isValidAmount(amount), false);
        }
      });

      test('should return error message for invalid amount', () {
        final result = ValidationUtils.validateAmount('abc');
        expect(result, 'Ingrese un monto válido');
      });

      test('should return error message for zero amount', () {
        final result = ValidationUtils.validateAmount('0');
        expect(result, 'El monto debe ser mayor a 0');
      });

      test('should return null for valid amount', () {
        final result = ValidationUtils.validateAmount('100.50');
        expect(result, null);
      });
    });

    group('Percentage Validation', () {
      test('should validate correct percentages', () {
        final validPercentages = [
          '0',
          '50',
          '100',
          '50.5',
          '99.99',
        ];

        for (final percentage in validPercentages) {
          expect(ValidationUtils.isValidPercentage(percentage), true);
        }
      });

      test('should reject invalid percentages', () {
        final invalidPercentages = [
          '101',
          '150.5',
          '-10',
          'abc',
          '50.123',
        ];

        for (final percentage in invalidPercentages) {
          expect(ValidationUtils.isValidPercentage(percentage), false);
        }
      });

      test('should return error message for invalid percentage', () {
        final result = ValidationUtils.validatePercentage('150');
        expect(result, 'Ingrese un porcentaje válido (0-100)');
      });

      test('should return null for valid percentage', () {
        final result = ValidationUtils.validatePercentage('50.5');
        expect(result, null);
      });
    });
  });
}
