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
      title: 'Bloch Sphere Simulator',
      theme: ThemeData.dark(useMaterial3: true),
      home: const BlochSphereVisualizer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BlochSphereVisualizer extends StatefulWidget {
  const BlochSphereVisualizer({super.key});

  @override
  State<BlochSphereVisualizer> createState() => _BlochSphereVisualizerState();
}

class _BlochSphereVisualizerState extends State<BlochSphereVisualizer> {
  // Initialize quantum state to |0⟩
  QuantumState currentState = QuantumState([
    const Complex(1.0, 0.0),
    const Complex(0.0, 0.0),
  ]);

  void _applyGate(QuantumGate gate) {
    setState(() {
      currentState = currentState.applyGate(gate);
    });
  }

  void _resetState() {
    setState(() {
      currentState = QuantumState([
        const Complex(1.0, 0.0),
        const Complex(0.0, 0.0),
      ]);
    });
  }

  void _updateFromAngles(double theta, double phi) {
    setState(() {
      currentState = QuantumState.fromAngles(theta, phi);
    });
  }

  @override
  Widget build(BuildContext context) {
    final coords = currentState.toBlochCoordinates();
    final angles = currentState.toSphericalAngles();
    final theta = angles['theta']!;
    final phi = angles['phi']!;
    final prob0 = currentState.amplitudes[0].magnitudeSquared;
    final prob1 = currentState.amplitudes[1].magnitudeSquared;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloch Sphere Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to |0⟩',
            onPressed: _resetState,
          )
        ],
      ),
      body: Row(
        children: [
          // Left: Bloch Sphere Custom Paint with Axis State Labels
          Expanded(
            flex: 3,
            child: Center(
              child: CustomPaint(
                size: const Size(380, 380),
                painter: BlochSpherePainter(
                  x: coords['x']!,
                  y: coords['y']!,
                  z: coords['z']!,
                ),
              ),
            ),
          ),

          // Right: Dashboard, Angle Sliders & Gate Controls
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Current State Display ---
                  Text(
                    'Current State',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Text(
                      currentState.toDiracNotation(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 24),

                  // --- Interactive Angle Sliders (θ & φ) ---
                  Text(
                    'Spherical Angles (θ & φ)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('θ (0 ~ π): ${(theta).toStringAsFixed(2)} rad (${(theta * 180 / pi).toStringAsFixed(0)}°)'),
                    ],
                  ),
                  Slider(
                    value: theta.clamp(0.0, pi),
                    min: 0.0,
                    max: pi,
                    onChanged: (newTheta) => _updateFromAngles(newTheta, phi),
                  ),
                  Row(
                    children: [
                      Text('φ (0 ~ 2π): ${(phi).toStringAsFixed(2)} rad (${(phi * 180 / pi).toStringAsFixed(0)}°)'),
                    ],
                  ),
                  Slider(
                    value: phi.clamp(0.0, 2 * pi),
                    min: 0.0,
                    max: 2 * pi,
                    onChanged: (newPhi) => _updateFromAngles(theta, newPhi),
                  ),
                  const Divider(height: 24),

                  // --- Measurement Probabilities ---
                  Text(
                    'Measurement Probabilities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('|0⟩: ${(prob0 * 100).toStringAsFixed(1)}%'),
                  LinearProgressIndicator(value: prob0),
                  const SizedBox(height: 6),
                  Text('|1⟩: ${(prob1 * 100).toStringAsFixed(1)}%'),
                  LinearProgressIndicator(value: prob1),
                  const Divider(height: 24),

                  // --- Gate Buttons ---
                  Text(
                    'Apply Gate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _applyGate(QuantumGate.hadamard()),
                        child: const Text('H Gate'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyGate(QuantumGate.pauliX()),
                        child: const Text('X Gate'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyGate(QuantumGate.pauliY()),
                        child: const Text('Y Gate'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyGate(QuantumGate.pauliZ()),
                        child: const Text('Z Gate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}