import 'dart:convert';
import 'package:shelf/shelf.dart';

import 'error_codes.dart';

/// Standardized API response format used across all endpoints.
///
/// Success: `{ "status": true,  "message": "...", "data": {...} }`
/// Error:   `{ "status": false, "message": "...", "data": null, "error": {...} }`
class ApiResponse {
  const ApiResponse._({
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  final bool status;
  final String message;
  final Object? data;
  final ApiError? error;

  /// Builds a successful response.
  factory ApiResponse.success({required String message, Object? data}) {
    return ApiResponse._(status: true, message: message, data: data);
  }

  /// Builds a failure response.
  factory ApiResponse.failure({
    required String message,
    required ApiErrorCode code,
    String? details,
  }) {
    return ApiResponse._(
      status: false,
      message: message,
      error: ApiError(code: code, details: details),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      if (error != null) 'error': error!.toJson(),
    };
  }

  /// Converts this response to a shelf [Response] with the given status code.
  Response toShelfResponse({int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class ApiError {
  const ApiError({required this.code, this.details});

  final ApiErrorCode code;
  final String? details;

  Map<String, dynamic> toJson() {
    return {'code': code.value, if (details != null) 'details': details};
  }
}
