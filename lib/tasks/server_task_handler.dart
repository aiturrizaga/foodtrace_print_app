import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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
}
