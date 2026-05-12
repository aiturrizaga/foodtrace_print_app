import 'package:shelf/shelf.dart';

import '../../config/models/printer_config.dart';
import '../responses/api_response.dart';
import '../responses/error_codes.dart';

/// Returns the current printer configuration.
class ConfigController {
  const ConfigController(this._getConfig);

  final PrinterConfig? Function() _getConfig;

  Future<Response> get(Request request) async {
    final config = _getConfig();
    if (config == null) {
      return ApiResponse.failure(
        message: 'Printer configuration is not available.',
        code: ApiErrorCode.configNotAvailable,
      ).toShelfResponse(statusCode: 503);
    }

    return ApiResponse.success(
      message: 'Configuration retrieved successfully.',
      data: {
        'printerModel': config.printerModel,
        'printerIp': config.printerIp,
        'serverPort': config.serverPort,
        'autoCut': config.autoCut,
      },
    ).toShelfResponse();
  }
}
