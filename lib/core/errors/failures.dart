/// Base class for all application failures.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Failure related to printer connection or communication.
class PrinterFailure extends Failure {
  const PrinterFailure(super.message);
}

/// Failure related to the internal HTTP server.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure related to loading or parsing a label template.
class TemplateFailure extends Failure {
  const TemplateFailure(super.message);
}

/// Failure related to reading or writing configuration.
class ConfigFailure extends Failure {
  const ConfigFailure(super.message);
}
