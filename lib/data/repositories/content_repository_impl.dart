import 'package:drift/drift.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/entities/content.dart' as entity;
import '../../database/daos/content_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentDao _contentDao;
  final SyncRepository _syncRepository;

  ContentRepositoryImpl(this._contentDao, this._syncRepository);

  @override
  Future<entity.Content?> findContentByCanonicalUrl(String canonicalUrl) async {
    final driftContent = await _contentDao.getContentByCanonicalUrl(
      canonicalUrl,
    );
    if (driftContent == null) return null;
    return entity.Content(
      id: driftContent.id,
      platform: driftContent.platform,
      type: driftContent.contentType,
      url: driftContent.url,
      canonicalUrl: driftContent.canonicalUrl,
      createdAt: driftContent.createdAt,
      updatedAt: driftContent.updatedAt,
      deletedAt: driftContent.deletedAt,
    );
  }

  @override
  Future<entity.SavedItem> saveItem({
    required String userId,
    required entity.Content content,
    String? folderId,
    String? notes,
  }) async {
    // 1. Ensure content exists in DB
    final existingContent = await _contentDao.getContentById(content.id);
    if (existingContent == null) {
      await _contentDao.insertContent(
        ContentCompanion(
          id: Value(content.id),
          platform: Value(content.platform),
          contentType: Value(content.type),
          url: Value(content.url),
          canonicalUrl: Value(content.canonicalUrl),
          createdAt: Value(content.createdAt),
          updatedAt: Value(content.updatedAt),
        ),
      );

      await _syncRepository.queueMutation(
        'content',
        content.id,
        SyncOperation.create,
        SyncPriority.high,
        {
          'id': content.id,
          'platform': content
              .platform
              .name, // assuming platform and type need string conversion matching DB schema
          'content_type': content.type.name,
          'url': content.url,
          'canonical_url': content.canonicalUrl,
          'created_at': content.createdAt.toIso8601String(),
          'updated_at': content.updatedAt.toIso8601String(),
          'deleted_at': null,
        },
      );
    }

    // 2. Create SavedItem
    final savedItemId = UuidUtils.generateV7();
    final now = DateTime.now().toUtc();

    await _contentDao.insertSavedItem(
      SavedItemsCompanion(
        id: Value(savedItemId),
        userId: Value(userId),
        folderId: Value(folderId),
        contentId: Value(content.id),
        notes: Value(notes ?? ''),
        savedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await _syncRepository.queueMutation(
      'saved_items',
      savedItemId,
      SyncOperation.create,
      SyncPriority.high,
      {
        'id': savedItemId,
        'user_id': userId,
        'folder_id': folderId,
        'content_id': content.id,
        'notes': notes ?? '',
        'is_favorite': false,
        'is_archived': false,
        'saved_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'deleted_at': null,
      },
    );

    return entity.SavedItem(
      id: savedItemId,
      userId: userId,
      folderId: folderId,
      contentId: content.id,
      notes: notes ?? '',
      savedAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateSavedItem(
    String id, {
    String? folderId,
    String? notes,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    final existing = await _contentDao.getSavedItem(id);
    if (existing != null) {
      final now = DateTime.now().toUtc();
      final updated = existing.copyWith(
        folderId: Value(folderId ?? existing.folderId),
        notes: Value(notes ?? existing.notes),
        isFavorite: isFavorite ?? existing.isFavorite,
        isArchived: isArchived ?? existing.isArchived,
        updatedAt: now,
      );
      await _contentDao.updateSavedItem(updated.toCompanion(true));

      await _syncRepository.queueMutation(
        'saved_items',
        id,
        SyncOperation.update,
        SyncPriority.normal,
        {
          'id': updated.id,
          'user_id': updated.userId,
          'folder_id': updated.folderId,
          'content_id': updated.contentId,
          'notes': updated.notes,
          'is_favorite': updated.isFavorite,
          'is_archived': updated.isArchived,
          'saved_at': updated.savedAt.toIso8601String(),
          'updated_at': updated.updatedAt.toIso8601String(),
          'deleted_at': updated.deletedAt?.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> softDeleteSavedItem(String id) async {
    final existing = await _contentDao.getSavedItem(id);
    if (existing != null) {
      final now = DateTime.now().toUtc();
      final updated = existing.copyWith(deletedAt: Value(now), updatedAt: now);
      await _contentDao.updateSavedItem(updated.toCompanion(true));

      await _syncRepository.queueMutation(
        'saved_items',
        id,
        SyncOperation.update, // Or soft delete
        SyncPriority.normal,
        {
          'id': updated.id,
          'user_id': updated.userId,
          'folder_id': updated.folderId,
          'content_id': updated.contentId,
          'notes': updated.notes,
          'is_favorite': updated.isFavorite,
          'is_archived': updated.isArchived,
          'saved_at': updated.savedAt.toIso8601String(),
          'updated_at': updated.updatedAt.toIso8601String(),
          'deleted_at': updated.deletedAt?.toIso8601String(),
        },
      );
    }
  }

  @override
  Stream<List<entity.SavedItemView>> watchItemsInFolder(String folderId) {
    return _contentDao.watchItemsInFolderQuery(folderId).map((rows) {
      return rows.map((row) {
        final savedItemData = row.readTable(_contentDao.savedItems);
        final contentData = row.readTable(_contentDao.content);
        final metadataData = row.readTableOrNull(_contentDao.contentMetadata);

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
    });
  }

  @override
  Stream<List<entity.SavedItemView>> watchRecentItems({int limit = 5}) {
    return _contentDao.watchRecentItemsQuery(limit).map((rows) {
      return rows.map((row) {
        final savedItemData = row.readTable(_contentDao.savedItems);
        final contentData = row.readTable(_contentDao.content);
        final metadataData = row.readTableOrNull(_contentDao.contentMetadata);

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
    });
  }

  @override
  Future<int> getTotalSavedItemsCount(String userId) async {
    return _contentDao.countSavedItems(userId);
  }
}
