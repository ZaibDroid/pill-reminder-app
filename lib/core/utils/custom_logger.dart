import 'package:logger/logger.dart';

class CustomLogger {
  final String className;
  late final Logger _logger;

  CustomLogger({required this.className}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  void i(String message) {
    _logger.i('[$className] $message');
  }

  void d(String message) {
    _logger.d('[$className] $message');
  }

  void w(String message) {
    _logger.w('[$className] $message');
  }

  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$className] $message', error: error, stackTrace: stackTrace);
  }
}
