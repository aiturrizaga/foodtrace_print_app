/// App-wide constants used across the entire application.
class AppConstants {
  AppConstants._();

  static const String appName = 'FoodTrace Printer';
  static const int defaultServerPort = 8080;
  static const String defaultPrinterModel = 'QL-810W';

  static const List<String> supportedPrinterModels = [
    'QL-810W',
    'QL-820NWB',
    'QL-800',
  ];
}
