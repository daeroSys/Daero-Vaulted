// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dao.dart';

// ignore_for_file: type=lint
mixin _$SearchDaoMixin on DatabaseAccessor<AppDatabase> {
  FtsSearch get ftsSearch => attachedDatabase.ftsSearch;
  $UsersTable get users => attachedDatabase.users;
  $FoldersTable get folders => attachedDatabase.folders;
  $ContentTable get content => attachedDatabase.content;
  $SavedItemsTable get savedItems => attachedDatabase.savedItems;
  $ContentMetadataTable get contentMetadata => attachedDatabase.contentMetadata;
  $RecentSearchesTable get recentSearches => attachedDatabase.recentSearches;
  Future<int> insertOrReplaceFts(
    String contentId,
    String title,
    String creator,
    String description,
    String notes,
    String tags,
  ) {
    return customInsert(
      'INSERT OR REPLACE INTO fts_search (contentId, title, creator, description, notes, tags) VALUES (?1, ?2, ?3, ?4, ?5, ?6)',
      variables: [
        Variable<String>(contentId),
        Variable<String>(title),
        Variable<String>(creator),
        Variable<String>(description),
        Variable<String>(notes),
        Variable<String>(tags),
      ],
      updates: {ftsSearch},
    );
  }

  Selectable<String> matchFts(String query) {
    return customSelect(
      'SELECT contentId FROM fts_search WHERE fts_search MATCH ?1 ORDER BY rank',
      variables: [Variable<String>(query)],
      readsFrom: {ftsSearch},
    ).map((QueryRow row) => row.read<String>('contentId'));
  }

  SearchDaoManager get managers => SearchDaoManager(this);
}

class SearchDaoManager {
  final _$SearchDaoMixin _db;
  SearchDaoManager(this._db);
  $FtsSearchTableManager get ftsSearch =>
      $FtsSearchTableManager(_db.attachedDatabase, _db.ftsSearch);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$ContentTableTableManager get content =>
      $$ContentTableTableManager(_db.attachedDatabase, _db.content);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db.attachedDatabase, _db.savedItems);
  $$ContentMetadataTableTableManager get contentMetadata =>
      $$ContentMetadataTableTableManager(
        _db.attachedDatabase,
        _db.contentMetadata,
      );
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(
        _db.attachedDatabase,
        _db.recentSearches,
      );
}
