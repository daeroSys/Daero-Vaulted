import 'package:drift/drift.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/entities/content.dart' as entity;
import '../../database/daos/content_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentDao _contentDao;

  ContentRepositoryImpl(this._contentDao);

  @override
  Future<entity.Content?> findContentByCanonicalUrl(String canonicalUrl) async {
    final driftContent = await _contentDao.getContentByCanonicalUrl(canonicalUrl);
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
      await _contentDao.insertContent(ContentCompanion(
        id: Value(content.id),
        platform: Value(content.platform),
        contentType: Value(content.type),
        url: Value(content.url),
        canonicalUrl: Value(content.canonicalUrl),
        createdAt: Value(content.createdAt),
        updatedAt: Value(content.updatedAt),
      ));
    }
    
    // 2. Create SavedItem
    final savedItemId = UuidUtils.generateV7();
    final now = DateTime.now().toUtc();
    
    await _contentDao.insertSavedItem(SavedItemsCompanion(
      id: Value(savedItemId),
      userId: Value(userId),
      folderId: Value(folderId),
      contentId: Value(content.id),
      notes: Value(notes ?? ''),
      savedAt: Value(now),
      updatedAt: Value(now),
    ));
    
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
  Future<void> updateSavedItem(String id, {String? folderId, String? notes, bool? isFavorite, bool? isArchived}) async {
    final existing = await _contentDao.getSavedItem(id);
    if (existing != null) {
      await _contentDao.updateSavedItem(existing.copyWith(
        folderId: Value(folderId ?? existing.folderId),
        notes: Value(notes ?? existing.notes),
        isFavorite: isFavorite ?? existing.isFavorite,
        isArchived: isArchived ?? existing.isArchived,
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
    }
  }

  @override
  Future<void> softDeleteSavedItem(String id) async {
    final existing = await _contentDao.getSavedItem(id);
    if (existing != null) {
      await _contentDao.updateSavedItem(existing.copyWith(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
    }
  }
}
