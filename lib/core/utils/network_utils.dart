import 'dart:io';

/// Utility functions for network operations.
class NetworkUtils {
  NetworkUtils._();

  /// Validates whether [ip] is a valid IPv4 address.
  static bool isValidIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    return parts.every((part) {
      final number = int.tryParse(part);
      return number != null && number >= 0 && number <= 255;
    });
  }

  /// Validates whether [port] is within the valid port range.
  static bool isValidPort(int port) => port >= 1024 && port <= 65535;

  /// Attempts a TCP connection to [ip]:[port] to check if the printer is reachable.
  /// Returns true if reachable within [timeout].
  static Future<bool> isPrinterReachable(
    String ip,
    int port, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
