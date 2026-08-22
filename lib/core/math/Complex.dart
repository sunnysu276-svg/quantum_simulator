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
            real * other.imag - imag * other.real
        );
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