import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/models/printer_config.dart';
import '../printer/models/print_data.dart';
import 'controllers/config_controller.dart';
import 'controllers/health_controller.dart';
import 'controllers/print_controller.dart';
import 'controllers/printer_controller.dart';
import 'controllers/info_controller.dart';

/// Builds the application router with all available API endpoints.
///
/// All endpoints are prefixed with `/api`.
Handler buildRouter({
  required PrinterConfig? Function() getConfig,
  required Future<bool> Function(PrinterConfig config) checkPrinterReachable,
  required Future<void> Function(PrintData print) executePrint,
}) {
  final healthController = const HealthController();
  final appInfoController = const AppInfoController();
  final configController = ConfigController(getConfig);
  final printerController = PrinterController(
    getConfig: getConfig,
    checkPrinterReachable: checkPrinterReachable,
    executePrint: executePrint,
  );
  final printController = PrintController(executePrint: executePrint);

  final apiRouter = Router()
    ..get('/health', healthController.check)
    ..get('/info', appInfoController.get)
    ..get('/config', configController.get)
    ..get('/printer/status', printerController.status)
    ..post('/printer/test', printerController.test)
    ..post('/print', printController.print);

  final rootRouter = Router()..mount('/api', apiRouter.call);

  return rootRouter.call;
}
