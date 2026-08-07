import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tags.dart';
import '../tables/content_tags.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags, ContentTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAllTags() => select(tags).get();
  
  Future<Tag?> getTagByName(String name) {
    return (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
  }
  
  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);
  
  Future<int> assignTagToContent(ContentTagsCompanion contentTag) => into(contentTags).insert(contentTag);
  
  Future<int> removeTagFromContent(String contentId, String tagId) {
    return (delete(contentTags)..where((t) => t.contentId.equals(contentId) & t.tagId.equals(tagId))).go();
  }
}
