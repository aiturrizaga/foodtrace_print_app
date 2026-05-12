import 'package:shelf/shelf.dart';

/// CORS middleware that allows the web app to call the local server
/// from the browser regardless of origin.
Middleware corsMiddleware() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await handler(request);
      return response.change(headers: headers);
    };
  };
}
