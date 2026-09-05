// lib/ui/bloch_sphere_painter.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// A CustomPainter that renders a wireframe Bloch sphere, state labels, and a state vector pointer.
class BlochSpherePainter extends CustomPainter {
  final double x;
  final double y;
  final double z;

  BlochSpherePainter({
    required this.x,
    required this.y,
    required this.z,
  });

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.38;

    // Brushes
    final spherePaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final equatorPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final vectorPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    // 1. Draw Sphere Outer Circle & Equator
    canvas.drawCircle(center, radius, spherePaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 0.6,
      ),
      equatorPaint,
    );

    // 2. Axis Projections
    final zTop = Offset(center.dx, center.dy - radius);
    final zBottom = Offset(center.dx, center.dy + radius);
    final xPos = Offset(center.dx - radius * 0.7, center.dy + radius * 0.35);
    final xNeg = Offset(center.dx + radius * 0.7, center.dy - radius * 0.35);
    final yPos = Offset(center.dx + radius * 0.85, center.dy + radius * 0.2);
    final yNeg = Offset(center.dx - radius * 0.85, center.dy - radius * 0.2);

    // 3. Draw Axis Lines
    canvas.drawLine(zBottom, zTop, axisPaint);
    canvas.drawLine(xNeg, xPos, axisPaint);
    canvas.drawLine(yNeg, yPos, axisPaint);

    // 4. Draw Pure Quantum State Labels
    _drawLabel(canvas, '|0⟩', Offset(zTop.dx, zTop.dy - 14), Colors.white);
    _drawLabel(canvas, '|1⟩', Offset(zBottom.dx, zBottom.dy + 14), Colors.white70);
    _drawLabel(canvas, '|+⟩', Offset(xPos.dx - 18, xPos.dy + 8), Colors.cyanAccent);
    _drawLabel(canvas, '|-⟩', Offset(xNeg.dx + 18, xNeg.dy - 8), Colors.cyan);
    _drawLabel(canvas, '|+i⟩', Offset(yPos.dx + 20, yPos.dy + 6), Colors.greenAccent);
    _drawLabel(canvas, '|-i⟩', Offset(yNeg.dx - 20, yNeg.dy - 6), Colors.green);

    // 5. Calculate State Vector 3D -> 2D Isometric Projection
    final targetX = center.dx + (y * 0.85 - x * 0.7) * radius;
    final targetY = center.dy - (z * radius) + (x * 0.35 + y * 0.2) * radius;
    final targetOffset = Offset(targetX, targetY);

    // 6. Draw State Vector Arrow & Endpoint
    canvas.drawLine(center, targetOffset, vectorPaint);
    canvas.drawCircle(targetOffset, 5.5, Paint()..color = Colors.amberAccent);
  }

  @override
  bool shouldRepaint(covariant BlochSpherePainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y || oldDelegate.z != z;
  }
}