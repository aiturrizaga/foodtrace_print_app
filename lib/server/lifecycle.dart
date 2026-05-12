import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../config/models/printer_config.dart';
import '../printer/models/print_data.dart';
import 'middlewares/cors_middleware.dart';
import 'router.dart';

/// Manages the lifecycle of the local HTTP server.
///
/// Provides start, stop, and restart operations for the server that
/// exposes the printer API to the local network.
class ServerLifecycle {
  ServerLifecycle({
    required this.getConfig,
    required this.checkPrinterReachable,
    required this.executePrint,
  });

  final PrinterConfig? Function() getConfig;
  final Future<bool> Function(PrinterConfig config) checkPrinterReachable;
  final Future<void> Function(PrintData print) executePrint;

  HttpServer? _server;

  bool get isRunning => _server != null;

  Future<void> start(int port) async {
    if (isRunning) throw StateError('Server is already running.');

    final router = buildRouter(
      getConfig: getConfig,
      checkPrinterReachable: checkPrinterReachable,
      executePrint: executePrint,
    );

    final pipeline = const Pipeline()
        .addMiddleware(corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router);

    _server = await shelf_io.serve(pipeline, InternetAddress.anyIPv4, port);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> restart(int port) async {
    await stop();
    await start(port);
  }
}
