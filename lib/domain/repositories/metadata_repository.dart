import '../entities/enums.dart';

abstract class MetadataRepository {
  Future<void> updateMetadata(
    String contentId, {
    String? title,
    String? creator,
    String? description,
    String? thumbnail,
    int? duration,
    String? language,
    required MetadataStatus status,
  });
}
