// lib/main.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quantum_simulator/core/math/Complex.dart';
import 'package:quantum_simulator/core/quantum/Gate.dart';
import 'package:quantum_simulator/core/quantum/State.dart';
import 'package:quantum_simulator/ui/bloch_sphere_painter.dart';

void main() {
  runApp(const QuantumSimulatorApp());
}

class QuantumSimulatorApp extends StatelessWidget {
  const QuantumSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantum Algorithm Explainer',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MainQuantumDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainQuantumDashboard extends StatefulWidget {
  const MainQuantumDashboard({super.key});

  @override
  State<MainQuantumDashboard> createState() => _MainQuantumDashboardState();
}

class _MainQuantumDashboardState extends State<MainQuantumDashboard> {
  // Mode: 0 = Single Qubit, 1 = Bell State Lab
  int _selectedMode = 1;

  // --- Single Qubit State ---
  QuantumState singleQubitState = QuantumState([
    const Complex(1.0, 0.0),
    const Complex(0.0, 0.0),
  ]);

  // --- 2-Qubit Bell State Step Engine ---
  int _bellStep = 0;
  late List<QuantumState> _bellHistory;
  final List<String> _bellStepExplanations = [
    'Initial State: Both qubits initialized to |00⟩. Qubits are completely independent.',
    'Hadamard on q0: Creates equal superposition (|0⟩ + |1⟩)/√2 on q0. System state is (|00⟩ + |10⟩)/√2.',
    'CNOT Gate: Entangles q0 and q1. Target q1 flips if q0 is |1⟩. Generates Bell State (|00⟩ + |11⟩)/√2!',
  ];

  @override
  void initState() {
    super.initState();
    _initBellHistory();
  }

  void _initBellHistory() {
    // Step 0: |00⟩
    final q0 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
    final q1 = QuantumState([const Complex(1, 0), const Complex(0, 0)]);
    final state00 = q0.tensorProduct(q1);

    // Step 1: H ⊗ I
    final hTensorI = QuantumGate.hadamard().tensorProduct(QuantumGate.identity());
    final stateStep1 = state00.applyGate(hTensorI);

    // Step 2: CNOT
    final stateStep2 = stateStep1.applyGate(QuantumGate.cnot());

    _bellHistory = [state00, stateStep1, stateStep2];
    _bellStep = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quantum Visualizer & Algorithm Explainer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Single Qubit')),
              ButtonSegment(value: 1, label: Text('Bell State Lab (2-Qubit)')),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedMode = newSelection.first;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _selectedMode == 0 ? _buildSingleQubitView() : _buildBellStateView(),
    );
  }

  // ================= 2-Qubit Bell State View =================
  Widget _buildBellStateView() {
    final state = _bellHistory[_bellStep];
    final coordsQ0 = state.toQubitBlochCoordinates(0);
    final coordsQ1 = state.toQubitBlochCoordinates(1);

    final probs = List.generate(4, (i) => state.amplitudes[i].magnitudeSquared);
    final labels = ['|00⟩', '|01⟩', '|10⟩', '|11⟩'];

    return Row(
      children: [
        // Left: Dual Bloch Spheres
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Qubit 0 (Control)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                      ),
                      const SizedBox(height: 12),
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: BlochSpherePainter(
                          x: coordsQ0['x']!,
                          y: coordsQ0['y']!,
                          z: coordsQ0['z']!,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Qubit 1 (Target)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                      ),
                      const SizedBox(height: 12),
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: BlochSpherePainter(
                          x: coordsQ1['x']!,
                          y: coordsQ1['y']!,
                          z: coordsQ1['z']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_bellStep == 2) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purpleAccent),
                  ),
                  child: const Text(
                    '⚡ Maximum Entanglement Created (Vectors shrink to center: Mixed State)',
                    style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Right: Step Player & Probabilities
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_bellStep + 1} of 3',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _bellStep > 0
                              ? () {
                                  setState(() => _bellStep--);
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _bellStep < 2
                              ? () {
                                  setState(() => _bellStep++);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Explanation Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                  ),
                  child: Text(
                    _bellStepExplanations[_bellStep],
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
                const Divider(height: 28),

                // State Equation
                const Text('Current State Vector', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Text(
                    state.toDiracNotation(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      color: Colors.lightGreenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 28),

                // 4-Basis Probabilities Bar Chart
                const Text('Measurement Probabilities', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (int i = 0; i < 4; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(labels[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                      Text('${(probs[i] * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: probs[i],
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: probs[i] > 0 ? Colors.cyanAccent : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= 1-Qubit View =================
  Widget _buildSingleQubitView() {
    final coords = singleQubitState.toBlochCoordinates();
    final angles = singleQubitState.toSphericalAngles();
    final theta = angles['theta']!;
    final phi = angles['phi']!;
    final prob0 = singleQubitState.amplitudes[0].magnitudeSquared;
    final prob1 = singleQubitState.amplitudes[1].magnitudeSquared;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: CustomPaint(
              size: const Size(360, 360),
              painter: BlochSpherePainter(
                x: coords['x']!,
                y: coords['y']!,
                z: coords['z']!,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current State', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Text(
                    singleQubitState.toDiracNotation(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 24),
                Text('θ (0 ~ π): ${(theta).toStringAsFixed(2)} rad (${(theta * 180 / pi).toStringAsFixed(0)}°)'),
                Slider(
                  value: theta.clamp(0.0, pi),
                  min: 0.0,
                  max: pi,
                  onChanged: (newTheta) {
                    setState(() {
                      singleQubitState = QuantumState.fromAngles(newTheta, phi);
                    });
                  },
                ),
                Text('φ (0 ~ 2π): ${(phi).toStringAsFixed(2)} rad (${(phi * 180 / pi).toStringAsFixed(0)}°)'),
                Slider(
                  value: phi.clamp(0.0, 2 * pi),
                  min: 0.0,
                  max: 2 * pi,
                  onChanged: (newPhi) {
                    setState(() {
                      singleQubitState = QuantumState.fromAngles(theta, newPhi);
                    });
                  },
                ),
                const Divider(height: 24),
                Text('|0⟩: ${(prob0 * 100).toStringAsFixed(1)}%'),
                LinearProgressIndicator(value: prob0),
                const SizedBox(height: 8),
                Text('|1⟩: ${(prob1 * 100).toStringAsFixed(1)}%'),
                LinearProgressIndicator(value: prob1),
                const Divider(height: 24),
                const Text('Apply Gate', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => singleQubitState = singleQubitState.applyGate(QuantumGate.hadamard())),
                      child: const Text('H Gate'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => singleQubitState = singleQubitState.applyGate(QuantumGate.pauliX())),
                      child: const Text('X Gate'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => singleQubitState = singleQubitState.applyGate(QuantumGate.pauliY())),
                      child: const Text('Y Gate'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => singleQubitState = singleQubitState.applyGate(QuantumGate.pauliZ())),
                      child: const Text('Z Gate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}