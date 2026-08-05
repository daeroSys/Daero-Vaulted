import '../entities/enums.dart';

abstract class ContentRepository {
  Future<void> saveContent({
    required String userId,
    required String url,
    required String canonicalUrl,
    required Platform platform,
    required ContentType type,
    String? folderId,
    String? notes,
  });
  
  Future<void> updateSavedItem(String id, {String? folderId, String? notes, bool? isFavorite, bool? isArchived});
  Future<void> softDeleteSavedItem(String id);
}
