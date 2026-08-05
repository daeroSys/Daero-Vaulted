import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/content.dart';
import '../tables/saved_items.dart';

part 'content_dao.g.dart';

@DriftAccessor(tables: [Content, SavedItems])
class ContentDao extends DatabaseAccessor<AppDatabase> with _$ContentDaoMixin {
  ContentDao(AppDatabase db) : super(db);

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
}
