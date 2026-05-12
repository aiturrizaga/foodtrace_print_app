import 'package:permission_handler/permission_handler.dart';

/// Handles battery optimization permission required for the HTTP server
/// to make outgoing TCP connections without being throttled by Android.
class BatteryOptimizationService {
  const BatteryOptimizationService();

  /// Returns true if the app is exempted from battery optimization.
  Future<bool> isExempted() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Requests the user to exempt the app from battery optimization.
  /// Returns true if granted.
  Future<bool> requestExemption() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }
}
