import 'package:drift/drift.dart';
import '../app_database.dart';

import '../tables/content.dart';
import '../tables/content_metadata.dart';
import '../tables/saved_items.dart';
import '../tables/recent_searches.dart';

part 'search_dao.g.dart';

@DriftAccessor(
  include: {'../search.drift'},
  tables: [SavedItems, Content, ContentMetadata, RecentSearches],
)
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  Future<List<String>> searchContentIds(String query) async {
    final rows = await customSelect(
      'SELECT contentId FROM fts_search WHERE fts_search MATCH ? ORDER BY rank',
      variables: [Variable.withString(query)],
    ).get();
    return rows.map((r) => r.read<String>('contentId')).toList();
  }

  Selectable<TypedResult> searchSavedItemsQuery(List<String> matchContentIds, String userId) {
    return select(savedItems).join([
      innerJoin(content, content.id.equalsExp(savedItems.contentId)),
      leftOuterJoin(
          contentMetadata, contentMetadata.contentId.equalsExp(content.id)),
    ])..where(
        savedItems.contentId.isIn(matchContentIds) & 
        savedItems.userId.equals(userId) & 
        savedItems.deletedAt.isNull()
      );
  }

  Future<List<String>> getRecentSearches(String userId) {
    final q = select(recentSearches)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
      ..limit(10);
    return q.map((r) => r.query).get();
  }

  Future<void> addRecentSearch(String userId, String searchQuery, String id) async {
    await into(recentSearches).insert(
      RecentSearche(
        id: id,
        userId: userId,
        query: searchQuery,
        timestamp: DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  
  Future<void> updateSearchIndex({
    required String contentId,
    String? title,
    String? creator,
    String? description,
    String? notes,
    String? tags,
  }) async {
    await deleteFromSearchIndex(contentId);
    await insertIntoSearchIndex(
      contentId: contentId,
      title: title,
      creator: creator,
      description: description,
      notes: notes,
      tags: tags,
    );
  }
  
  Future<int> insertIntoSearchIndex({
    required String contentId,
    String? title,
    String? creator,
    String? description,
    String? notes,
    String? tags,
  }) {
    return customInsert(
      'INSERT INTO fts_search (contentId, title, creator, description, notes, tags) VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(contentId),
        Variable.withString(title ?? ''),
        Variable.withString(creator ?? ''),
        Variable.withString(description ?? ''),
        Variable.withString(notes ?? ''),
        Variable.withString(tags ?? ''),
      ],
    );
  }
  
  Future<void> deleteFromSearchIndex(String contentId) async {
    // In FTS5, you can only delete by rowid.
    final result = await customSelect(
      'SELECT rowid FROM fts_search WHERE contentId = ?',
      variables: [Variable.withString(contentId)],
    ).getSingleOrNull();

    if (result != null) {
      final rowid = result.read<int>('rowid');
      await customStatement(
        'DELETE FROM fts_search WHERE rowid = ?',
        [Variable.withInt(rowid)],
      );
    }
  }
}
