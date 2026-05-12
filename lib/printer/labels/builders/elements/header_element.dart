import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../styles/alignment.dart';
import '../styles/text_style.dart';

/// Header element rendered at the top of the label.
class HeaderElement {
  const HeaderElement({
    required this.text,
    this.style = const LabelTextStyle(
      size: 46,
      weight: FontWeight.bold,
      alignment: LabelAlignment.center,
    ),
  });

  final String text;
  final LabelTextStyle style;

  /// Draws the header on [canvas] at vertical position [y] within [width].
  /// Returns the new vertical position after drawing.
  double draw(Canvas canvas, double y, double width, double margin) {
    final painter = _buildPainter(width - margin * 2);
    final x = _resolveX(painter, width, margin);
    painter.paint(canvas, Offset(x, y));
    return y + painter.height;
  }

  /// Calculates the height required to render this element.
  double height(double width, double margin) {
    return _buildPainter(width - margin * 2).height;
  }

  TextPainter _buildPainter(double maxWidth) {
    final transformed = style.applyTransform(text);
    final painter = TextPainter(
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
      textAlign: _toTextAlign(style.alignment),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return painter;
  }

  double _resolveX(TextPainter painter, double width, double margin) {
    return switch (style.alignment) {
      LabelAlignment.left => margin,
      LabelAlignment.right => width - margin - painter.width,
      LabelAlignment.center => (width - painter.width) / 2,
    };
  }

  TextAlign _toTextAlign(LabelAlignment a) {
    return switch (a) {
      LabelAlignment.left => TextAlign.left,
      LabelAlignment.center => TextAlign.center,
      LabelAlignment.right => TextAlign.right,
    };
  }
}
