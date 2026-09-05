class Complex {
    final double real;
    final double imag;

    // "const" Constructor
    const Complex(this.real, this.imag);

    // Complex Conjugate
    Complex get conjugate => Complex(real, -imag);

    // Magnitude Squared
    double get magnitudeSquared => real * real + imag * imag;

    // Complex Addition
    Complex operator +(Complex other) {
        return Complex(real + other.real, imag + other.imag);
    }

    // Complex Multiplication
    Complex operator *(Complex other) {
        return Complex(
            real * other.real - imag * other.imag,
            real * other.imag + imag * other.real
        );
    }

    // Format the complex number to concise strings (e.g. "0.707", "0.707i", "0.5+0.5i")
    String toFormattedString({int fractionDigits = 3}) {
        String formatValue(double val) {
        // Check if it represents an integer value (e.g., 1.0 -> 1, 0.0 -> 0)
        if ((val - val.roundToDouble()).abs() < 1e-6) {
            return val.round().toString();
        }
        return val.toStringAsFixed(fractionDigits);
        }

        final isRealZero = (real - 0.0).abs() < 1e-6;
        final isImagZero = (imag - 0.0).abs() < 1e-6;

        if (isRealZero && isImagZero) return '0';

        if (isImagZero) {
        return formatValue(real);
        }

        if (isRealZero) {
        return '${formatValue(imag)}i';
        }

        final rStr = formatValue(real);
        final iVal = imag.abs();
        final sign = imag > 0 ? '+' : '-';
        final iStr = '${formatValue(iVal)}i';

        return '$rStr $sign $iStr';
    }

    @override
    String toString() {
        if (imag == 0) return real.toString();
        if (real == 0) return '${imag}i';
        
        if (imag > 0) {
        return '$real + ${imag}i';
        } else {
        return '$real - ${imag.abs()}i';
        }
    }

}