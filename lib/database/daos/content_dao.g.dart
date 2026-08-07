// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_dao.dart';

// ignore_for_file: type=lint
mixin _$ContentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContentTable get content => attachedDatabase.content;
  $UsersTable get users => attachedDatabase.users;
  $FoldersTable get folders => attachedDatabase.folders;
  $SavedItemsTable get savedItems => attachedDatabase.savedItems;
  $ContentMetadataTable get contentMetadata => attachedDatabase.contentMetadata;
  ContentDaoManager get managers => ContentDaoManager(this);
}

class ContentDaoManager {
  final _$ContentDaoMixin _db;
  ContentDaoManager(this._db);
  $$ContentTableTableManager get content =>
      $$ContentTableTableManager(_db.attachedDatabase, _db.content);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$SavedItemsTableTableManager get savedItems =>
      $$SavedItemsTableTableManager(_db.attachedDatabase, _db.savedItems);
  $$ContentMetadataTableTableManager get contentMetadata =>
      $$ContentMetadataTableTableManager(
        _db.attachedDatabase,
        _db.contentMetadata,
      );
}
