import 'package:shelf/shelf.dart';

import '../responses/api_response.dart';

/// Returns the server health status.
class HealthController {
  const HealthController();

  Future<Response> check(Request request) async {
    return ApiResponse.success(
      message: 'Server is healthy.',
      data: {'alive': true},
    ).toShelfResponse();
  }
}
