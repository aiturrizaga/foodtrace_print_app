import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../tasks/server_task_handler.dart';

/// Manages the Android foreground service that keeps the HTTP server
/// running even when the app is closed or the device restarts.
class ForegroundServerService {
  const ForegroundServerService();

  /// Initializes the foreground task configuration.
  /// Must be called once before starting the service.
  void initialize() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foodtrace_printer_server',
        channelName: 'Print Server',
        channelDescription:
            'Keeps the print server running so the web app can send jobs.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Returns true if the foreground service is currently running.
  Future<bool> isRunning() async {
    return FlutterForegroundTask.isRunningService;
  }

  /// Requests notification permission required by Android 13+.
  Future<bool> requestNotificationPermission() async {
    final status = await FlutterForegroundTask.checkNotificationPermission();
    if (status == NotificationPermission.granted) return true;

    final result = await FlutterForegroundTask.requestNotificationPermission();
    return result == NotificationPermission.granted;
  }

  /// Starts the foreground service. The server will keep running until [stop]
  /// is called, even if the user closes the app.
  Future<void> start() async {
    final hasPermission = await requestNotificationPermission();
    if (!hasPermission) {
      throw StateError('Notification permission is required.');
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'FoodTrace Printer',
      notificationText: 'Starting server...',
      callback: startCallback,
    );
  }

  /// Stops the foreground service and the server with it.
  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }

  /// Restarts the service (used when the user changes config like port).
  Future<void> restart() async {
    await stop();
    await Future.delayed(const Duration(milliseconds: 500));
    await start();
  }
}
