import 'package:drift/drift.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../database/daos/tag_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class TagRepositoryImpl implements TagRepository {
  final TagDao _tagDao;

  TagRepositoryImpl(this._tagDao);

  @override
  Future<void> createTag(String name) async {
    final existing = await _tagDao.getTagByName(name);
    if (existing == null) {
      await _tagDao.insertTag(TagsCompanion(
        id: Value(UuidUtils.generateV7()),
        name: Value(name),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    }
  }

  @override
  Future<List<dynamic>> getAllTags() async {
    return await _tagDao.getAllTags();
  }

  @override
  Future<void> assignTagToContent(String contentId, String tagId) async {
    await _tagDao.assignTagToContent(ContentTagsCompanion(
      contentId: Value(contentId),
      tagId: Value(tagId),
    ));
  }

  @override
  Future<void> removeTagFromContent(String contentId, String tagId) async {
    await _tagDao.removeTagFromContent(contentId, tagId);
  }
}
