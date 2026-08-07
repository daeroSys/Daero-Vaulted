import 'package:drift/drift.dart';
import '../app_database.dart';

part 'search_dao.g.dart';

@DriftAccessor(include: {'../search.drift'})
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  Future<List<QueryRow>> search(String query) {
    // Note: To prevent SQL injection in match queries, ensure query is properly escaped.
    return customSelect(
      'SELECT * FROM fts_search WHERE fts_search MATCH ?',
      variables: [Variable.withString(query)],
    ).get();
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
    await customStatement(
      'DELETE FROM fts_search WHERE contentId = ?',
      [Variable.withString(contentId)],
    );
  }
}
