/// Standardized error codes returned by the API.
///
/// These codes are stable identifiers that the frontend can use
/// to handle specific error scenarios without parsing messages.
enum ApiErrorCode {
  invalidRequest('INVALID_REQUEST'),
  templateNotFound('TEMPLATE_NOT_FOUND'),
  printerUnreachable('PRINTER_UNREACHABLE'),
  printerError('PRINTER_ERROR'),
  configNotAvailable('CONFIG_NOT_AVAILABLE'),
  internalError('INTERNAL_ERROR');

  const ApiErrorCode(this.value);
  final String value;
}
