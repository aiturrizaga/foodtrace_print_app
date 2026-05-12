import 'package:flutter/material.dart';

/// Horizontal separator line.
class SeparatorElement {
  const SeparatorElement({this.thickness = 3, this.color = Colors.black});

  final double thickness;
  final Color color;

  double draw(Canvas canvas, double y, double width, double margin) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    canvas.drawLine(Offset(margin, y), Offset(width - margin, y), paint);
    return y + thickness;
  }

  double get height => thickness;
}
