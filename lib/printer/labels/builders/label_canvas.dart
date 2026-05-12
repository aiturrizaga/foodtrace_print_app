import 'dart:typed_data';
import 'dart:ui' as ui;

import 'elements/border_element.dart';
import 'elements/field_element.dart';
import 'elements/header_element.dart';
import 'elements/qr_element.dart';
import 'elements/separator_element.dart';
import 'styles/text_style.dart';

/// Position where the QR code is rendered within the label.
enum QrPosition { right, bottom }

/// Builds a label using a fluent API and renders it as PNG bytes.
///
/// Example:
/// ```
/// LabelCanvas(width: 696)
///   .border()
///   .header(text: 'COMPANY')
///   .separator()
///   .field(label: 'LOTE', value: 'LOT-001')
///   .qr(value: 'LOT-001', position: QrPosition.right)
///   .render();
/// ```
class LabelCanvas {
  LabelCanvas({
    required this.width,
    this.margin = 20,
    this.rowGap = 14,
    this.columnGap = 12,
  });

  final double width;
  final double margin;
  final double rowGap;
  final double columnGap;

  final List<_Operation> _operations = [];
  BorderElement? _border;
  _QrConfig? _qrConfig;

  // Fluent API

  LabelCanvas border({double thickness = 6}) {
    _border = BorderElement(thickness: thickness);
    return this;
  }

  LabelCanvas header({required String text, LabelTextStyle? style}) {
    _operations.add(
      _HeaderOp(
        HeaderElement(
          text: text,
          style: style ?? const LabelTextStyle(size: 46),
        ),
      ),
    );
    return this;
  }

  LabelCanvas separator({double thickness = 3}) {
    _operations.add(_SeparatorOp(SeparatorElement(thickness: thickness)));
    return this;
  }

  LabelCanvas field({
    required String label,
    required String value,
    LabelTextStyle? labelStyle,
    LabelTextStyle? valueStyle,
  }) {
    _operations.add(
      _FieldOp(
        FieldElement(
          label: label,
          value: value,
          labelStyle: labelStyle ?? const LabelTextStyle(size: 28),
          valueStyle: valueStyle ?? const LabelTextStyle(size: 34),
        ),
      ),
    );
    return this;
  }

  LabelCanvas qr({
    required String value,
    QrPosition position = QrPosition.right,
    double sizeRatio = 0.35,
  }) {
    _qrConfig = _QrConfig(
      value: value,
      position: position,
      sizeRatio: sizeRatio,
    );
    return this;
  }

  // Rendering

  Future<Uint8List> render() async {
    final qrSize = _qrConfig != null ? width * _qrConfig!.sizeRatio : 0.0;
    final dataWidth = _qrConfig?.position == QrPosition.right
        ? width - margin * 2 - qrSize - columnGap
        : width - margin * 2;

    final totalHeight = _calculateHeight(dataWidth, qrSize);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);

    canvas.drawRect(ui.Rect.fromLTWH(0, 0, width, totalHeight), paint);

    _drawOperations(canvas, dataWidth, totalHeight, qrSize);
    _border?.draw(canvas, width, totalHeight);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), totalHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // Internal layout

  double _calculateHeight(double dataWidth, double qrSize) {
    double y = margin;
    for (final op in _operations) {
      y += op.height(width, dataWidth, margin) + rowGap;
    }

    final qrEndY = _qrConfig?.position == QrPosition.bottom
        ? y + qrSize + rowGap
        : y;

    final fieldsEndY = y;
    final qrSideEndY = _qrConfig?.position == QrPosition.right
        ? margin + qrSize + rowGap
        : 0.0;

    final contentEnd = [
      fieldsEndY,
      qrEndY,
      qrSideEndY,
    ].reduce((a, b) => a > b ? a : b);

    return contentEnd + margin;
  }

  void _drawOperations(
    ui.Canvas canvas,
    double dataWidth,
    double totalHeight,
    double qrSize,
  ) {
    double y = margin;
    final startX = margin.toDouble();

    for (final op in _operations) {
      y = op.draw(canvas, y, width, dataWidth, margin, startX);
      y += rowGap;
    }

    if (_qrConfig != null) {
      final qrElement = QrElement(value: _qrConfig!.value, size: qrSize);
      final position = _resolveQrPosition(qrSize, totalHeight);
      qrElement.draw(canvas, position);
    }
  }

  ui.Offset _resolveQrPosition(double qrSize, double totalHeight) {
    if (_qrConfig!.position == QrPosition.right) {
      return ui.Offset(width - margin - qrSize, margin + 100);
    }
    return ui.Offset((width - qrSize) / 2, totalHeight - margin - qrSize);
  }
}

// Internal operation wrappers

abstract class _Operation {
  double draw(
    ui.Canvas canvas,
    double y,
    double width,
    double dataWidth,
    double margin,
    double startX,
  );
  double height(double width, double dataWidth, double margin);
}

class _HeaderOp extends _Operation {
  _HeaderOp(this.element);
  final HeaderElement element;

  @override
  double draw(canvas, y, width, dataWidth, margin, startX) {
    return element.draw(canvas, y, width, margin);
  }

  @override
  double height(width, dataWidth, margin) {
    return element.height(width, margin);
  }
}

class _SeparatorOp extends _Operation {
  _SeparatorOp(this.element);
  final SeparatorElement element;

  @override
  double draw(canvas, y, width, dataWidth, margin, startX) {
    return element.draw(canvas, y, width, margin);
  }

  @override
  double height(width, dataWidth, margin) => element.height;
}

class _FieldOp extends _Operation {
  _FieldOp(this.element);
  final FieldElement element;

  @override
  double draw(canvas, y, width, dataWidth, margin, startX) {
    return element.draw(canvas, y, dataWidth, startX);
  }

  @override
  double height(width, dataWidth, margin) {
    return element.height(dataWidth);
  }
}

class _QrConfig {
  const _QrConfig({
    required this.value,
    required this.position,
    required this.sizeRatio,
  });

  final String value;
  final QrPosition position;
  final double sizeRatio;
}
