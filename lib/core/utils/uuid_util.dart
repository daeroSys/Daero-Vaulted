import 'package:uuid/uuid.dart';

class UuidUtil {
  static const Uuid _uuid = Uuid();

  /// Generates a UUID v7
  static String generate() {
    return _uuid.v7();
  }
}
