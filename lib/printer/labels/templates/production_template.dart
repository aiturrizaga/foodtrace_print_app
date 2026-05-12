import 'dart:typed_data';
import 'package:flutter/material.dart' show FontWeight;

import '../base.dart';
import '../builders/label_canvas.dart';
import '../builders/styles/alignment.dart';
import '../builders/styles/text_style.dart';

/// Production batch label template.
///
/// Layout: centered uppercase header, separator, four fields (LOTE,
/// PRODUCCION, PRODUCTO, OPERADOR) with QR code positioned at the right.
class ProductionTemplate implements BaseTemplate {
  static const _qrFormat =
      '{lote}|{cantidad}|{producto_nombre}|{producto_presentacion}|{peso}|{produccion_iso}';

  @override
  String get displayName => 'Producción';

  @override
  Future<Uint8List> build(Map<String, String> data) async {
    return LabelCanvas(width: 696)
        .border(thickness: 4)
        .header(
          text: data['empresa'] ?? '',
          style: const LabelTextStyle(
            size: 42,
            weight: FontWeight.bold,
            transform: TextTransform.uppercase,
            alignment: LabelAlignment.center,
          ),
        )
        .separator(thickness: 3)
        .field(label: 'LOTE:', value: data['lote'] ?? '')
        .field(label: 'PRODUCCION:', value: data['produccion'] ?? '')
        .field(label: 'PRODUCTO:', value: data['producto'] ?? '')
        .field(label: 'OPERADOR:', value: data['operador'] ?? '')
        .qr(
          value: _buildQrValue(data),
          position: QrPosition.right,
          sizeRatio: 0.30,
        )
        .render();
  }

  String _buildQrValue(Map<String, String> data) {
    return _qrFormat.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) => data[m.group(1)] ?? '',
    );
  }
}
