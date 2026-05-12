import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../styles/text_style.dart';

/// A label + value pair rendered as two lines.
class FieldElement {
  const FieldElement({
    required this.label,
    required this.value,
    this.labelStyle = const LabelTextStyle(size: 28),
    this.valueStyle = const LabelTextStyle(size: 34, weight: FontWeight.bold),
    this.lineGap = 6,
  });

  final String label;
  final String value;
  final LabelTextStyle labelStyle;
  final LabelTextStyle valueStyle;
  final double lineGap;

  /// Draws the field on [canvas] starting at [y] within [maxWidth].
  /// Returns the new vertical position after drawing.
  double draw(Canvas canvas, double y, double maxWidth, double startX) {
    final labelPainter = _buildPainter(label, labelStyle, maxWidth);
    final valuePainter = _buildPainter(value, valueStyle, maxWidth);

    labelPainter.paint(canvas, Offset(startX, y));
    y += labelPainter.height + lineGap;

    valuePainter.paint(canvas, Offset(startX, y));
    y += valuePainter.height;

    return y;
  }

  /// Calculates the total height of this field within [maxWidth].
  double height(double maxWidth) {
    final labelPainter = _buildPainter(label, labelStyle, maxWidth);
    final valuePainter = _buildPainter('$value:', valueStyle, maxWidth);
    return labelPainter.height + lineGap + valuePainter.height;
  }

  TextPainter _buildPainter(
    String text,
    LabelTextStyle style,
    double maxWidth,
  ) {
    final transformed = style.applyTransform(text);
    return TextPainter(
      text: TextSpan(
        text: transformed,
        style: TextStyle(
          color: style.color == LabelColor.red ? Colors.red : Colors.black,
          fontSize: style.size.toDouble(),
          fontWeight: style.weight,
          fontStyle: style.italic ? FontStyle.italic : FontStyle.normal,
          decoration: style.underline
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
  }
}
