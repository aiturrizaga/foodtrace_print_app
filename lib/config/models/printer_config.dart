/// Holds all user-configurable settings for the printer and server.
class PrinterConfig {
  const PrinterConfig({
    required this.printerIp,
    required this.printerModel,
    required this.serverPort,
    required this.autoCut,
    required this.autoStartServer,
    required this.alwaysOnMode,
  });

  final String printerIp;
  final String printerModel;
  final int serverPort;
  final bool autoCut;
  final bool autoStartServer;
  final bool alwaysOnMode;

  /// Returns a copy of this config with the given fields replaced.
  PrinterConfig copyWith({
    String? printerIp,
    String? printerModel,
    int? serverPort,
    bool? autoCut,
    bool? autoStartServer,
    bool? alwaysOnMode,
  }) {
    return PrinterConfig(
      printerIp: printerIp ?? this.printerIp,
      printerModel: printerModel ?? this.printerModel,
      serverPort: serverPort ?? this.serverPort,
      autoCut: autoCut ?? this.autoCut,
      autoStartServer: autoStartServer ?? this.autoStartServer,
      alwaysOnMode: alwaysOnMode ?? this.alwaysOnMode,
    );
  }
}
