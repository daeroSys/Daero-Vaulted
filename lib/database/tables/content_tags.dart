import 'package:drift/drift.dart';
import 'content.dart';
import 'tags.dart';

@TableIndex(name: 'idx_content_tags_content', columns: {#contentId})
@TableIndex(name: 'idx_content_tags_tag', columns: {#tagId})
class ContentTags extends Table {
  TextColumn get contentId => text().references(Content, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {contentId, tagId};
}
