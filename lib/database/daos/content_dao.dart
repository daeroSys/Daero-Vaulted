import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/content.dart';
import '../tables/saved_items.dart';
import '../tables/content_metadata.dart';

part 'content_dao.g.dart';

@DriftAccessor(tables: [Content, SavedItems, ContentMetadata])
class ContentDao extends DatabaseAccessor<AppDatabase> with _$ContentDaoMixin {
  ContentDao(super.db);

  Future<ContentData?> getContentById(String id) {
    return (select(content)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
  
  Future<ContentData?> getContentByCanonicalUrl(String url) {
    return (select(content)..where((t) => t.canonicalUrl.equals(url))).getSingleOrNull();
  }
  
  Future<int> insertContent(ContentCompanion entry) => into(content).insert(entry);
  
  Future<bool> updateContent(ContentCompanion entry) => update(content).replace(entry);
  
  // SavedItems
  Future<int> insertSavedItem(SavedItemsCompanion item) => into(savedItems).insert(item);
  
  Future<bool> updateSavedItem(SavedItemsCompanion item) => update(savedItems).replace(item);
  
  Future<SavedItem?> getSavedItem(String id) {
    return (select(savedItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<TypedResult>> watchItemsInFolderQuery(String folderId) {
    final query = select(savedItems).join([
      innerJoin(content, content.id.equalsExp(savedItems.contentId)),
      leftOuterJoin(contentMetadata, contentMetadata.contentId.equalsExp(content.id)),
    ])
    ..where(savedItems.folderId.equals(folderId) & savedItems.deletedAt.isNull());
    
    query.orderBy([OrderingTerm.desc(savedItems.savedAt)]);
    return query.watch();
  }

  Stream<List<TypedResult>> watchRecentItemsQuery(int limit) {
    final query = select(savedItems).join([
      innerJoin(content, content.id.equalsExp(savedItems.contentId)),
      leftOuterJoin(contentMetadata, contentMetadata.contentId.equalsExp(content.id)),
    ])
    ..where(savedItems.deletedAt.isNull());
    
    query.orderBy([OrderingTerm.desc(savedItems.savedAt)]);
    query.limit(limit);
    return query.watch();
  }
}
