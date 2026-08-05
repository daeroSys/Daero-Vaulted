import 'package:drift/drift.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/entities/enums.dart';
import '../../database/daos/content_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentDao _contentDao;

  ContentRepositoryImpl(this._contentDao);

  @override
  Future<void> saveContent({
    required String userId,
    required String url,
    required String canonicalUrl,
    required Platform platform,
    required ContentType type,
    String? folderId,
    String? notes,
  }) async {
    // Deduplication logic
    ContentData? content = await _contentDao.getContentByCanonicalUrl(canonicalUrl);
    
    if (content == null) {
      final newContentId = UuidUtils.generateV7();
      await _contentDao.insertContent(ContentCompanion(
        id: Value(newContentId),
        platform: Value(platform),
        contentType: Value(type),
        url: Value(url),
        canonicalUrl: Value(canonicalUrl),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
      content = await _contentDao.getContentById(newContentId);
    }
    
    await _contentDao.insertSavedItem(SavedItemsCompanion(
      id: Value(UuidUtils.generateV7()),
      userId: Value(userId),
      folderId: Value(folderId),
      contentId: Value(content!.id),
      notes: Value(notes),
      savedAt: Value(DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
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
