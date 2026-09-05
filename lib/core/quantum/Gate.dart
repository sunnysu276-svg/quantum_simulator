import 'package:quantum_simulator/core/math/Complex.dart';

class QuantumGate {
    final List<List<Complex>> matrix;

    QuantumGate(this.matrix);

    int get length => matrix.length;

    // --- Factory Constructors ---

    // Identity Gate (I)
    factory QuantumGate.identity() {
        return QuantumGate([
            [const Complex(1.0, 0.0), const Complex(0.0, 0.0)], 
            [const Complex(0.0, 0.0), const Complex(1.0, 0.0)]
        ]);
    }

    // Pauli-X Gate (NOT Gate)
    // X = [[0, 1], [1, 0]]
    factory QuantumGate.pauliX() {
        return QuantumGate([
            [const Complex(0, 0), const Complex(1, 0)], 
            [const Complex(1, 0), const Complex(0, 0)]
        ]);
    }

    // Pauli-Y Gate
    // Y = [[0, -i], [i, 0]]
    factory QuantumGate.pauliY() {
        return QuantumGate([
            [const Complex(0, 0), const Complex(0, -1)],
            [const Complex(0, 1), const Complex(0, 0)]
        ]);
    }

    // Pauli-Z Gate (Phase Flip Gate)
    // Z = [[1, 0], [0, -1]]
    factory QuantumGate.pauliZ() {
        return QuantumGate([
            [const Complex(1, 0), const Complex(0, 0)],
            [const Complex(0, 0), const Complex(-1, 0)]
        ]);
    }

    // Hadamard Gate
    // H = (1/√2) * [[1, 1], [1, -1]]
    factory QuantumGate.hadamard() {
        double invSqrt2 = 1.0 / 1.4142135623730951; // 1 / √2
        return QuantumGate([
            [Complex(invSqrt2, 0), Complex(invSqrt2, 0)],
            [Complex(invSqrt2, 0), Complex(-invSqrt2, 0)],
        ]);
    }

    factory QuantumGate.cnot() {
        return QuantumGate([
            [Complex(1, 0), Complex(0, 0), Complex(0, 0), Complex(0, 0)], 
            [Complex(0, 0), Complex(1, 0), Complex(0, 0), Complex(0, 0)], 
            [Complex(0, 0), Complex(0, 0), Complex(0, 0), Complex(1, 0)], 
            [Complex(0, 0), Complex(0, 0), Complex(1, 0), Complex(0, 0)]
        ]);
    }

    // Tensor product of two gate matrices: A ⊗ B.
    QuantumGate tensorProduct(QuantumGate other) {
        int dimA = length;
        int dimB = other.length;
        int newDim = dimA * dimB;

        List<List<Complex>> newMatrix = List.generate(newDim, 
            (_) => List.filled(newDim, const Complex(0.0, 0.0))
        );

        for (int i = 0; i < dimA; i++) {
            for (int j = 0; j < dimA; j++) {
                for (int k = 0; k < dimB; k++) {
                    for (int l = 0; l < dimB; l++) {
                        newMatrix[i * dimB + k][j * dimB + l] = matrix[i][j] * other.matrix[k][l];
                    }
                }
            }
        }

        return QuantumGate(newMatrix);
    }
}