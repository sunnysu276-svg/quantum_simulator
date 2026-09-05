import 'dart:math';
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

    int get length => amplitudes.length;

    String toDiracNotation({int fractionDigits = 3}) {
        if (length == 2) {
            String c0 = amplitudes[0].toFormattedString(fractionDigits: fractionDigits);
            String c1 = amplitudes[1].toFormattedString(fractionDigits: fractionDigits);
            return '|ψ⟩ = ($c0)|0⟩ + ($c1)|1⟩';
        }
        return toString();
    }

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
        if (length != other.length) {
            throw ArgumentError('States must have the same length for inner products.');
        }

        Complex result = Complex(0.0, 0.0);
        for (int i = 0; i < length; i++) {
            result += (amplitudes[i].conjugate * other.amplitudes[i]);
        }

        return result;
    }

    // Apply a quantum gate to the state
    QuantumState applyGate(QuantumGate gate) {
        int n = length;
        if (gate.length != n) {
            throw ArgumentError('Gate length (${gate.length}x${gate.length}) '
          'does not match state length ($n).');
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
        if (length != 2) {
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

    // |ψ⟩ = cos(θ/2)|0⟩ + e^(iφ)sin(θ/2)|1⟩
    factory QuantumState.fromAngles(double theta, double phi) {
        final c0 = Complex(cos(theta / 2), 0.0);
        final c1 = Complex(
            cos(phi) * sin(theta / 2), 
            sin(phi) * sin(theta / 2)
        );

        return QuantumState([c0, c1]);
    }

    Map<String, double> toSphericalAngles() {
        final coords = toBlochCoordinates();
        final x = coords['x']!;
        final y = coords['y']!;
        final z = coords['z']!;

        final theta = acos(z.clamp(-1.0, 1.0)); // θ ∈ [0, π]
        double phi = atan2(y, x); // φ ∈ [-π, π]
        if (phi < 0) phi += 2 * pi; // Map to [0, 2π)

        return {'theta': theta, 'phi': phi};
    }

    @override
    String toString() {
        return 'QuantumState(amplitudes: $amplitudes)';
    }
}