import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// QR code element that can be drawn on the label canvas.
class QrElement {
  const QrElement({required this.value, this.size = 240});

  final String value;
  final double size;

  /// Draws the QR code at [position] on [canvas].
  void draw(Canvas canvas, Offset position) {
    final qrCode = QrCode.fromData(
      data: value,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    final qrImage = QrImage(qrCode);

    final cellSize = size / qrImage.moduleCount;
    final paint = Paint()..color = Colors.black;

    for (int row = 0; row < qrImage.moduleCount; row++) {
      for (int col = 0; col < qrImage.moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              position.dx + col * cellSize,
              position.dy + row * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }
  }
}
