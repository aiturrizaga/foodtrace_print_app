import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../models/printer_config.dart';
import 'config_repository.dart';

/// SharedPreferences-backed implementation of [ConfigRepository].
class ConfigRepositoryImpl implements ConfigRepository {
  const ConfigRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<PrinterConfig> load() async {
    return PrinterConfig(
      printerIp: _prefs.getString(StorageKeys.printerIp) ?? '',
      printerModel:
          _prefs.getString(StorageKeys.printerModel) ??
          AppConstants.defaultPrinterModel,
      serverPort:
          _prefs.getInt(StorageKeys.serverPort) ??
          AppConstants.defaultServerPort,
      autoCut: _prefs.getBool(StorageKeys.autoCut) ?? true,
      autoStartServer: _prefs.getBool(StorageKeys.autoStartServer) ?? false,
      alwaysOnMode: _prefs.getBool(StorageKeys.alwaysOnMode) ?? false,
    );
  }

  @override
  Future<void> save(PrinterConfig config) async {
    await Future.wait([
      _prefs.setString(StorageKeys.printerIp, config.printerIp),
      _prefs.setString(StorageKeys.printerModel, config.printerModel),
      _prefs.setInt(StorageKeys.serverPort, config.serverPort),
      _prefs.setBool(StorageKeys.autoCut, config.autoCut),
      _prefs.setBool(StorageKeys.autoStartServer, config.autoStartServer),
      _prefs.setBool(StorageKeys.alwaysOnMode, config.alwaysOnMode),
    ]);
  }
}
