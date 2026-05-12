import '../models/printer_config.dart';

/// Abstract contract for reading and writing printer configuration.
abstract interface class ConfigRepository {
  /// Loads the saved config, or returns defaults if none is saved.
  Future<PrinterConfig> load();

  /// Persists the given [config] to local storage.
  Future<void> save(PrinterConfig config);
}
