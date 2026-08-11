import 'package:uuid/uuid.dart';

class UuidUtils {
  static const Uuid _uuid = Uuid();

  /// Generates a UUIDv7.
  /// UUIDv7 features a time-ordered value field derived from the widely
  /// implemented and well known Unix Epoch timestamp source, providing
  /// improved database index locality over UUIDv4.
  static String generateV7() {
    return _uuid.v7();
  }
}
