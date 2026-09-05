// test/core/math/complex_test.dart

import 'package:test/test.dart';
import 'package:quantum_simulator/core/math/Complex.dart';

void main() {
  group('Complex Number Tests', () {
    test('Addition correctly sums real and imaginary parts', () {
      final c1 = const Complex(1.0, 2.0);
      final c2 = const Complex(3.0, 4.0);
      final result = c1 + c2;

      expect(result.real, equals(4.0));
      expect(result.imag, equals(6.0));
    });

    test('Multiplication satisfies (a+bi)(c+di) formula', () {
      final c1 = const Complex(1.0, 2.0);
      final c2 = const Complex(3.0, 4.0);
      // (1*3 - 2*4) + (1*4 + 2*3)i = -5 + 10i
      final result = c1 * c2;

      expect(result.real, equals(-5.0));
      expect(result.imag, equals(10.0));
    });

    test('Conjugate flips only imaginary part', () {
      final c = const Complex(2.5, -3.5);
      final conj = c.conjugate;

      expect(conj.real, equals(2.5));
      expect(conj.imag, equals(3.5));
    });

    test('magnitudeSquared calculates |c|² correctly', () {
      final c = const Complex(3.0, 4.0);
      // 3² + 4² = 25
      expect(c.magnitudeSquared, equals(25.0));
    });
  });

  group('Complex toFormattedString Tests', () {
    test('Pure real number with zero imaginary part should format cleanly', () {
      const c1 = Complex(1.0, 0.0);
      const c0 = Complex(0.0, 0.0);

      expect(c1.toFormattedString(), equals('1'));
      expect(c0.toFormattedString(), equals('0'));
    });

    test('Pure imaginary number with zero real part should format with i', () {
      const c = Complex(0.0, 1.0);
      const cNeg = Complex(0.0, -1.0);

      expect(c.toFormattedString(), equals('1i'));
      expect(cNeg.toFormattedString(), equals('-1i'));
    });

    test('Mixed real and imaginary numbers should format as a + bi', () {
      const c = Complex(0.7071, 0.7071);
      expect(c.toFormattedString(fractionDigits: 3), equals('0.707 + 0.707i'));
    });
  });
}