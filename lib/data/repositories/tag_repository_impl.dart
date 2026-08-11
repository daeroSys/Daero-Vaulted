import 'package:drift/drift.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../database/daos/tag_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';

class TagRepositoryImpl implements TagRepository {
  final TagDao _tagDao;
  final SyncRepository _syncRepository;

  TagRepositoryImpl(this._tagDao, this._syncRepository);

  @override
  Future<void> createTag(String name) async {
    final existing = await _tagDao.getTagByName(name);
    if (existing == null) {
      final id = UuidUtils.generateV7();
      final now = DateTime.now().toUtc();

      await _tagDao.insertTag(
        TagsCompanion(
          id: Value(id),
          name: Value(name),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await _syncRepository.queueMutation(
        'tags',
        id,
        SyncOperation.create,
        SyncPriority.normal,
        {
          'id': id,
          'name': name,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<List<dynamic>> getAllTags() async {
    return await _tagDao.getAllTags();
  }

  @override
  Future<void> assignTagToContent(String contentId, String tagId) async {
    await _tagDao.assignTagToContent(
      ContentTagsCompanion(contentId: Value(contentId), tagId: Value(tagId)),
    );

    await _syncRepository.queueMutation(
      'content_tags',
      '${contentId}_$tagId',
      SyncOperation.create,
      SyncPriority.normal,
      {'content_id': contentId, 'tag_id': tagId},
    );
  }

  @override
  Future<void> removeTagFromContent(String contentId, String tagId) async {
    await _tagDao.removeTagFromContent(contentId, tagId);

    await _syncRepository.queueMutation(
      'content_tags',
      '${contentId}_$tagId',
      SyncOperation.delete,
      SyncPriority.normal,
      {'content_id': contentId, 'tag_id': tagId},
    );
  }
}
