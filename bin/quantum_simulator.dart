// bin/quantum_simulator.dart

import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/State.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';

void main() {
  print('=== 1. Bloch Sphere Coordinates Test ===');
  
  // Test |0⟩ -> Expect (0, 0, 1)
  var state0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
  print('|0⟩ Bloch Coords: ${state0.toBlochCoordinates()}');

  // Test |+⟩ = H|0⟩ -> Expect (1, 0, 0)
  var statePlus = state0.applyGate(QuantumGate.hadamard());
  print('|+⟩ Bloch Coords: ${statePlus.toBlochCoordinates()}');

  print('\n=== 2. Tensor Product Test (2-Qubit System) ===');
  
  // q0 = |0⟩, q1 = |0⟩
  var q0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
  var q1 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);

  // Combined state: |00⟩ = |0⟩ ⊗ |0⟩
  var state00 = q0.tensorProduct(q1);
  print('|00⟩ state amplitudes: $state00');

  // Apply (H ⊗ I) to |00⟩: creates (|00⟩ + |10⟩) / √2
  var hGate = QuantumGate.hadamard();
  var iGate = QuantumGate.identity();
  var hTensorI = hGate.tensorProduct(iGate);

  var resultState = state00.applyGate(hTensorI);
  print('\nAfter applying (H ⊗ I) to |00⟩:');
  print('Amplitudes: $resultState');
  print('Is Normalized? ${resultState.isNormalized()}');
}