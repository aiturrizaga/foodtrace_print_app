import 'package:shelf/shelf.dart';

import '../../config/models/printer_config.dart';
import '../../core/errors/failures.dart';
import '../../printer/models/print_data.dart';
import '../responses/api_response.dart';
import '../responses/error_codes.dart';

/// Handles printer-related endpoints: status check and test print.
class PrinterController {
  const PrinterController({
    required this.getConfig,
    required this.checkPrinterReachable,
    required this.executePrint,
  });

  final PrinterConfig? Function() getConfig;
  final Future<bool> Function(PrinterConfig config) checkPrinterReachable;
  final Future<void> Function(PrintData print) executePrint;

  /// GET /api/printer/status — checks if the printer is reachable.
  Future<Response> status(Request request) async {
    final config = getConfig();
    if (config == null) {
      return ApiResponse.failure(
        message: 'Printer configuration is not available.',
        code: ApiErrorCode.configNotAvailable,
      ).toShelfResponse(statusCode: 503);
    }

    final reachable = await checkPrinterReachable(config);
    return ApiResponse.success(
      message: reachable
          ? 'Printer is reachable.'
          : 'Printer is not reachable.',
      data: {
        'reachable': reachable,
        'ip': config.printerIp,
        'model': config.printerModel,
      },
    ).toShelfResponse();
  }

  /// POST /api/printer/test — prints a sample test label.
  Future<Response> test(Request request) async {
    try {
      final print = PrintData(
        templateName: 'produccion',
        copies: 1,
        data: const {
          'empresa': 'TEST PRINT',
          'lote': 'TEST-0000000001',
          'producto': 'Sample test label',
          'producto_nombre': 'Sample',
          'producto_presentacion': 'Test',
          'cantidad': '1',
          'produccion': '01/01/2026',
          'produccion_iso': '2026-01-01',
          'operador': 'System',
          'peso': '1',
        },
      );

      await executePrint(print);

      return ApiResponse.success(
        message: 'Test print sent successfully.',
      ).toShelfResponse();
    } on TemplateFailure catch (e) {
      return ApiResponse.failure(
        message: e.message,
        code: ApiErrorCode.templateNotFound,
      ).toShelfResponse(statusCode: 404);
    } on PrinterFailure catch (e) {
      return ApiResponse.failure(
        message: 'Test print failed.',
        code: ApiErrorCode.printerError,
        details: e.message,
      ).toShelfResponse(statusCode: 500);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Unexpected error.',
        code: ApiErrorCode.internalError,
        details: e.toString(),
      ).toShelfResponse(statusCode: 500);
    }
  }
}
