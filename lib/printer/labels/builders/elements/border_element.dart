import 'package:flutter/material.dart';

/// Outer border drawn around the label.
class BorderElement {
  const BorderElement({this.thickness = 6, this.color = Colors.black});

  final double thickness;
  final Color color;

  void draw(Canvas canvas, double width, double height) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    canvas.drawRect(
      Rect.fromLTWH(
        thickness / 2,
        thickness / 2,
        width - thickness,
        height - thickness,
      ),
      paint,
    );
  }
}
