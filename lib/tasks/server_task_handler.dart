import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/repositories/config_repository_impl.dart';
import '../printer/services/brother_printer_service.dart';
import '../server/lifecycle.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}

class ServerTaskHandler extends TaskHandler {
  ServerLifecycle? _lifecycle;
  final BrotherPrinterService _printerService = const BrotherPrinterService();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final prefs = await SharedPreferences.getInstance();
    final repository = ConfigRepositoryImpl(prefs);
    final config = await repository.load();

    // Copy certs from assets to documents directory on first run
    await _ensureCertsOnDisk();

    _lifecycle = ServerLifecycle(
      getConfig: () => config,
      checkPrinterReachable: _printerService.isReachable,
      executePrint: (job) => _printerService.print(job, config),
    );

    await _lifecycle!.start(config.serverPort);

    FlutterForegroundTask.updateService(
      notificationTitle: 'FoodTrace Printer',
      notificationText: 'Server running on port ${config.serverPort}',
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _lifecycle?.stop();
    _lifecycle = null;
  }

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {}

  Future<void> _ensureCertsOnDisk() async {
    final dir = await getApplicationDocumentsDirectory();
    final certFile = File('${dir.path}/fullchain.pem');
    final keyFile = File('${dir.path}/privkey.pem');

    if (!certFile.existsSync()) {
      final certBytes = await rootBundle.load('assets/certs/fullchain.pem');
      await certFile.writeAsBytes(certBytes.buffer.asUint8List());
    }

    if (!keyFile.existsSync()) {
      final keyBytes = await rootBundle.load('assets/certs/privkey.pem');
      await keyFile.writeAsBytes(keyBytes.buffer.asUint8List());
    }
  }
}
