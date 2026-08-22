import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';

class QuantumState {
    // The list of quantum probability amplitudes
    final List<Complex> amplitudes;

    QuantumState(this.amplitudes) {
        if (amplitudes.isEmpty) {
            throw ArgumentError('Quantum state cannot be empty.');
        }
    }

    int get dimension => amplitudes.length;

    // Verify if the quantum state is normalized
    bool isNormalized({double tolerance = 1e-5}) {
        double totalProbability = 0.0;
        for (var amplitude in amplitudes) {
            totalProbability += amplitude.magnitudeSquared;
        }

        return (totalProbability - 1.0).abs() < tolerance;
    }

    // Return the total probability sum (for debugging)
    double get totalProbability {
        double sum = 0.0;
        for (var amplitude in amplitudes) {
            sum += amplitude.magnitudeSquared;
        }
        return sum;
    }

    // Inner Product
    Complex innerProduct(QuantumState other) {
        if (dimension != other.dimension) {
            throw ArgumentError('States must have the same length for inner products.');
        }

        Complex result = Complex(0.0, 0.0);
        for (int i = 0; i < dimension; i++) {
            result += (amplitudes[i].conjugate * other.amplitudes[i]);
        }

        return result;
    }

    // Apply a quantum gate to the state
    QuantumState applyGate(QuantumGate gate) {
        int n = dimension;
        if (gate.dimension != n) {
            throw ArgumentError('Gate dimension (${gate.dimension}x${gate.dimension}) '
          'does not match state dimension ($n).');
        }

        List<Complex> newAmplitudes = List.filled(n, const Complex(0.0, 0.0));

        for (int i = 0; i < n; i++) {
            Complex sum = Complex(0.0, 0.0);
            for (int j = 0; j < n; j++) {
                sum += (gate.matrix[i][j] * amplitudes[j]);
            }
            newAmplitudes[i] = sum;
        }

        return QuantumState(newAmplitudes);
    }

    /// Calculates (x, y, z) coordinates on the Bloch Sphere for a 1-qubit state.
    /// Uses sandwich multiplication: x = ⟨ψ|X|ψ⟩, y = ⟨ψ|Y|ψ⟩, z = ⟨ψ|Z|ψ⟩.
    Map<String, double> toBlochCoordinates() {
        if (dimension != 2) {
            throw UnsupportedError('Bloch sphere representation only applies to 1-qubit states.');
        }

        var xGate = QuantumGate.pauliX();
        var yGate = QuantumGate.pauliY();
        var zGate = QuantumGate.pauliZ();

        double x = innerProduct(applyGate(xGate)).real;
        double y = innerProduct(applyGate(yGate)).real;
        double z = innerProduct(applyGate(zGate)).real;

        return {'x': x, 'y': y, 'z': z};
    }

    // Tensor product of this state and another state: |this⟩ ⊗ |other⟩.
    QuantumState tensorProduct(QuantumState other) {
        List<Complex> newAmplitudes = [];
        for (Complex a in amplitudes) {
            for (Complex b in other.amplitudes) {
                newAmplitudes.add(a * b);
            }
        }

        return QuantumState(newAmplitudes);
    }

    @override
    String toString() {
        return 'QuantumState(amplitudes: $amplitudes)';
    }
}