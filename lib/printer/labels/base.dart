import 'dart:typed_data';

/// Contract that every label template must implement.
abstract interface class BaseTemplate {
  /// Builds the label image and returns it as PNG bytes.
  Future<Uint8List> build(Map<String, String> data);

  /// Human-readable name shown in the UI.
  String get displayName;
}
