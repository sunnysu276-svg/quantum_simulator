// test/core/quantum/gate_test.dart

import 'package:test/test.dart';
import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';
import 'package:quantum_simulator/core/quantum/State.dart';

void main() {
  group('QuantumGate Tests', () {
    test('Pauli gates and Hadamard dimensions are 2x2', () {
      expect(QuantumGate.identity().length, equals(2));
      expect(QuantumGate.pauliX().length, equals(2));
      expect(QuantumGate.pauliY().length, equals(2));
      expect(QuantumGate.pauliZ().length, equals(2));
      expect(QuantumGate.hadamard().length, equals(2));
    });

    test('Tensor product of two 2x2 gates produces a 4x4 matrix', () {
      final h = QuantumGate.hadamard();
      final i = QuantumGate.identity();
      final hTensorI = h.tensorProduct(i);

      expect(hTensorI.length, equals(4));
      expect(hTensorI.matrix[0][0].real, closeTo(0.707106, 1e-5));
      expect(hTensorI.matrix[0][1].real, equals(0.0));
      expect(hTensorI.matrix[1][0].real, equals(0.0));
      expect(hTensorI.matrix[1][1].real, closeTo(0.707106, 1e-5));
    });

    test('CNOT gate flips target only when control is 1', () {
      final cnot = QuantumGate.cnot();

      // State |10⟩: control=1, target=0 -> Expect |11⟩
      final state10 = QuantumState([
        const Complex(0, 0), // |00⟩
        const Complex(0, 0), // |01⟩
        const Complex(1, 0), // |10⟩
        const Complex(0, 0), // |11⟩
      ]);

      final result = state10.applyGate(cnot);

      expect(result.amplitudes[0].real, equals(0.0));
      expect(result.amplitudes[1].real, equals(0.0));
      expect(result.amplitudes[2].real, equals(0.0));
      expect(result.amplitudes[3].real, equals(1.0)); // Flipped to |11⟩
      expect(result.isNormalized(), isTrue);
    });

    test('Hadamard and CNOT prepare Bell State (|00⟩ + |11⟩) / √2', () {
      // Step 1: Initial state |00⟩
      final q0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final q1 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final state00 = q0.tensorProduct(q1);

      // Step 2: Apply (H ⊗ I) to create (|00⟩ + |10⟩) / √2
      final hTensorI = QuantumGate.hadamard().tensorProduct(QuantumGate.identity());
      final superposition = state00.applyGate(hTensorI);

      // Step 3: Apply CNOT to create Bell State (|00⟩ + |11⟩) / √2
      final bellState = superposition.applyGate(QuantumGate.cnot());

      expect(bellState.length, equals(4));
      // |00⟩ amplitude ~ 1/√2
      expect(bellState.amplitudes[0].magnitudeSquared, closeTo(0.5, 1e-5));
      // |01⟩ amplitude = 0
      expect(bellState.amplitudes[1].magnitudeSquared, closeTo(0.0, 1e-5));
      // |10⟩ amplitude = 0
      expect(bellState.amplitudes[2].magnitudeSquared, closeTo(0.0, 1e-5));
      // |11⟩ amplitude ~ 1/√2
      expect(bellState.amplitudes[3].magnitudeSquared, closeTo(0.5, 1e-5));
      expect(bellState.isNormalized(), isTrue);
    });
  });
}