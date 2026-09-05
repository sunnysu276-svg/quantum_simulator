// test/core/quantum/state_test.dart

import 'package:test/test.dart';
import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';
import 'package:quantum_simulator/core/quantum/State.dart';

void main() {
  group('QuantumState Tests', () {
    test('isNormalized validates total probability equals 1.0', () {
      final validState = QuantumState([
        const Complex(0.6, 0.0),
        const Complex(0.8, 0.0), // 0.36 + 0.64 = 1.0
      ]);
      final invalidState = QuantumState([
        const Complex(1.0, 0.0),
        const Complex(1.0, 0.0), // 1.0 + 1.0 = 2.0
      ]);

      expect(validState.isNormalized(), isTrue);
      expect(invalidState.isNormalized(), isFalse);
    });

    test('innerProduct of orthogonal states is zero', () {
      final state0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final state1 = QuantumState([const Complex(0, 0), const Complex(1, 0)]);

      final innerProd = state0.innerProduct(state1);
      expect(innerProd.real, equals(0.0));
      expect(innerProd.imag, equals(0.0));
    });

    test('Pauli-X gate flips |0⟩ to |1⟩', () {
      final state0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final result = state0.applyGate(QuantumGate.pauliX());

      expect(result.amplitudes[0].real, equals(0.0));
      expect(result.amplitudes[1].real, equals(1.0));
      expect(result.isNormalized(), isTrue);
    });

    test('Hadamard gate creates equal superposition from |0⟩', () {
      final state0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final plusState = state0.applyGate(QuantumGate.hadamard());

      expect(plusState.amplitudes[0].magnitudeSquared, closeTo(0.5, 1e-5));
      expect(plusState.amplitudes[1].magnitudeSquared, closeTo(0.5, 1e-5));
      expect(plusState.isNormalized(), isTrue);
    });

    test('toBlochCoordinates produces accurate 3D positions', () {
      final state0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final coords0 = state0.toBlochCoordinates();
      expect(coords0['x'], closeTo(0.0, 1e-5));
      expect(coords0['y'], closeTo(0.0, 1e-5));
      expect(coords0['z'], closeTo(1.0, 1e-5));

      final plusState = state0.applyGate(QuantumGate.hadamard());
      final coordsPlus = plusState.toBlochCoordinates();
      expect(coordsPlus['x'], closeTo(1.0, 1e-5));
      expect(coordsPlus['y'], closeTo(0.0, 1e-5));
      expect(coordsPlus['z'], closeTo(0.0, 1e-5));
    });

    test('tensorProduct combines two 1-qubit states into 4-amplitude state', () {
      final q0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
      final q1 = QuantumState([const Complex(0, 0), const Complex(1, 0)]);
      final combined = q0.tensorProduct(q1); // |01⟩

      expect(combined.length, equals(4));
      expect(combined.amplitudes[0].magnitudeSquared, equals(0.0)); // |00⟩
      expect(combined.amplitudes[1].magnitudeSquared, equals(1.0)); // |01⟩
      expect(combined.amplitudes[2].magnitudeSquared, equals(0.0)); // |10⟩
      expect(combined.amplitudes[3].magnitudeSquared, equals(0.0)); // |11⟩
      expect(combined.isNormalized(), isTrue);
    });

    test('toDiracNotation formats |0⟩ state correctly', () {
      final state0 = QuantumState([
        const Complex(1.0, 0.0),
        const Complex(0.0, 0.0),
      ]);

      expect(state0.toDiracNotation(), equals('|ψ⟩ = (1)|0⟩ + (0)|1⟩'));
    });
  });
}