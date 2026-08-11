import '../entities/content.dart';

abstract class ContentRepository {
  Future<Content?> findContentByCanonicalUrl(String canonicalUrl);

  Future<SavedItem> saveItem({
    required String userId,
    required Content content,
    String? folderId,
    String? notes,
  });

  Future<void> updateSavedItem(
    String id, {
    String? folderId,
    String? notes,
    bool? isFavorite,
    bool? isArchived,
  });
  Future<void> softDeleteSavedItem(String id);
  Future<int> getTotalSavedItemsCount(String userId);

  Stream<List<SavedItemView>> watchItemsInFolder(String folderId);
  Stream<List<SavedItemView>> watchRecentItems({int limit = 5});
}
