import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../../core/errors/failures.dart';
import '../../printer/models/print_data.dart';
import '../responses/api_response.dart';
import '../responses/error_codes.dart';

/// Handles the main print endpoint that receives jobs from the web app.
class PrintController {
  const PrintController({required this.executePrint});

  final Future<void> Function(PrintData print) executePrint;

  /// POST /api/print — receives a print job and forwards it to the printer.
  Future<Response> print(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final print = PrintData(
        templateName: json['template'] as String,
        copies: json['copies'] as int? ?? 1,
        data: (json['data'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );

      await executePrint(print);

      return ApiResponse.success(
        message: 'Print sent successfully.',
        data: {'template': print.templateName, 'copies': print.copies},
      ).toShelfResponse();
    } on FormatException catch (e) {
      return ApiResponse.failure(
        message: 'Invalid request body.',
        code: ApiErrorCode.invalidRequest,
        details: e.message,
      ).toShelfResponse(statusCode: 400);
    } on TemplateFailure catch (e) {
      return ApiResponse.failure(
        message: e.message,
        code: ApiErrorCode.templateNotFound,
      ).toShelfResponse(statusCode: 404);
    } on PrinterFailure catch (e) {
      return ApiResponse.failure(
        message: 'Print job failed.',
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
