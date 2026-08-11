import 'package:uuid/uuid.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/content.dart' as entity;
import '../../database/daos/search_dao.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDao _searchDao;

  SearchRepositoryImpl(this._searchDao);

  @override
  Future<List<entity.SavedItemView>> search(String userId, String query) async {
    final matchContentIds = await _searchDao.searchContentIds(query);
    if (matchContentIds.isEmpty) return [];

    final rows = await _searchDao
        .searchSavedItemsQuery(matchContentIds, userId)
        .get();

    return rows.map((row) {
      final savedItemData = row.readTable(_searchDao.savedItems);
      final contentData = row.readTable(_searchDao.content);
      final metadataData = row.readTableOrNull(_searchDao.contentMetadata);

      return entity.SavedItemView(
        savedItem: entity.SavedItem(
          id: savedItemData.id,
          userId: savedItemData.userId,
          folderId: savedItemData.folderId,
          contentId: savedItemData.contentId,
          notes: savedItemData.notes ?? '',
          isFavorite: savedItemData.isFavorite,
          isArchived: savedItemData.isArchived,
          savedAt: savedItemData.savedAt,
          updatedAt: savedItemData.updatedAt,
          deletedAt: savedItemData.deletedAt,
        ),
        content: entity.Content(
          id: contentData.id,
          platform: contentData.platform,
          type: contentData.contentType,
          url: contentData.url,
          canonicalUrl: contentData.canonicalUrl,
          createdAt: contentData.createdAt,
          updatedAt: contentData.updatedAt,
          deletedAt: contentData.deletedAt,
        ),
        title: metadataData?.title,
        description: metadataData?.description,
        thumbnail: metadataData?.thumbnail,
        duration: metadataData?.duration,
      );
    }).toList();
  }

  @override
  Future<void> indexContent(
    String contentId,
    String title,
    String description,
    String creator,
    String notes,
    List<String> tags,
  ) async {
    await _searchDao.updateSearchIndex(
      contentId: contentId,
      title: title,
      description: description,
      creator: creator,
      notes: notes,
      tags: tags.join(' '),
    );
  }

  @override
  Future<List<String>> getRecentSearches(String userId) async {
    return await _searchDao.getRecentSearches(userId);
  }

  @override
  Future<void> addRecentSearch(String userId, String query) async {
    if (query.trim().isEmpty) return;
    await _searchDao.addRecentSearch(userId, query.trim(), const Uuid().v7());
  }
}
