// test/core/quantum/gate_test.dart

import 'package:test/test.dart';
import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';

void main() {
  group('QuantumGate Tests', () {
    test('Pauli gates and Hadamard dimensions are 2x2', () {
      expect(QuantumGate.identity().dimension, equals(2));
      expect(QuantumGate.pauliX().dimension, equals(2));
      expect(QuantumGate.pauliY().dimension, equals(2));
      expect(QuantumGate.pauliZ().dimension, equals(2));
      expect(QuantumGate.hadamard().dimension, equals(2));
    });

    test('Tensor product of two 2x2 gates produces a 4x4 matrix', () {
      final h = QuantumGate.hadamard();
      final i = QuantumGate.identity();
      final hTensorI = h.tensorProduct(i);

      expect(hTensorI.dimension, equals(4));
      // Top-left block should match (1/√2) * I
      expect(hTensorI.matrix[0][0].real, closeTo(0.707106, 1e-5));
      expect(hTensorI.matrix[0][1].real, equals(0.0));
      expect(hTensorI.matrix[1][0].real, equals(0.0));
      expect(hTensorI.matrix[1][1].real, closeTo(0.707106, 1e-5));
    });
  });
}