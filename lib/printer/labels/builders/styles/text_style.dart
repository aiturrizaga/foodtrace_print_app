import 'package:flutter/material.dart' show FontWeight;

import 'alignment.dart';

/// Text transformation applied before drawing.
enum TextTransform { none, uppercase, lowercase, capitalize }

/// Color used for text rendering. `red` only works on bicolor rolls.
enum LabelColor { black, red }

/// Style configuration for any text element on the label.
class LabelTextStyle {
  const LabelTextStyle({
    this.size = 28,
    this.weight = FontWeight.normal,
    this.italic = false,
    this.underline = false,
    this.transform = TextTransform.none,
    this.alignment = LabelAlignment.left,
    this.color = LabelColor.black,
  });

  final int size;
  final FontWeight weight;
  final bool italic;
  final bool underline;
  final TextTransform transform;
  final LabelAlignment alignment;
  final LabelColor color;

  /// Applies the configured text transform to [text].
  String applyTransform(String text) {
    return switch (transform) {
      TextTransform.uppercase => text.toUpperCase(),
      TextTransform.lowercase => text.toLowerCase(),
      TextTransform.capitalize => _capitalize(text),
      TextTransform.none => text,
    };
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
