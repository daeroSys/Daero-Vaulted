import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final Logger _logger = Logger('Vaulted');

  static void init() {
    if (kReleaseMode) {
      Logger.root.level = Level.WARNING;
    } else {
      Logger.root.level = Level.ALL;
    }

    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static void d(String message) => _logger.fine(message);
  static void i(String message) => _logger.info(message);
  static void w(String message) => _logger.warning(message);
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}
