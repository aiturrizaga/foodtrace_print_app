/// Supported Brother QL media configurations used by the printer service.
///
/// Continuous media has a variable label length, which is determined by the
/// rendered image. [lengthMm] is therefore null for continuous rolls.
class PrinterMedia {
  const PrinterMedia({
    required this.id,
    required this.name,
    required this.description,
    required this.widthMm,
    required this.lengthMm,
    required this.isContinuous,
    required this.isRedBlack,
  });

  final String id;
  final String name;
  final String description;
  final double widthMm;
  final double? lengthMm;
  final bool isContinuous;
  final bool isRedBlack;

  /// 62 mm continuous white paper tape (Brother W62 / DK-22205 family).
  static const continuous62 = PrinterMedia(
    id: 'w62',
    name: '62 mm Continuous',
    description: 'White paper tape',
    widthMm: 62,
    lengthMm: null,
    isContinuous: true,
    isRedBlack: false,
  );

  /// 62 mm continuous black/red paper tape (Brother W62RB).
  static const continuous62RedBlack = PrinterMedia(
    id: 'w62rb',
    name: '62 mm Continuous R/B',
    description: 'Black/red paper tape',
    widthMm: 62,
    lengthMm: null,
    isContinuous: true,
    isRedBlack: true,
  );

  static const List<PrinterMedia> supported = [
    continuous62,
    continuous62RedBlack,
  ];

  static PrinterMedia fromId(String? id) {
    return supported.firstWhere(
      (media) => media.id == id,
      orElse: () => continuous62,
    );
  }

  /// User-facing summary for compact settings rows.
  String get displayValue => isRedBlack ? '62 mm • R/B' : '62 mm • White';
}
