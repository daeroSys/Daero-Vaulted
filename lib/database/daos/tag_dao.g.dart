// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_dao.dart';

// ignore_for_file: type=lint
mixin _$TagDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $ContentTable get content => attachedDatabase.content;
  $ContentTagsTable get contentTags => attachedDatabase.contentTags;
  TagDaoManager get managers => TagDaoManager(this);
}

class TagDaoManager {
  final _$TagDaoMixin _db;
  TagDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ContentTableTableManager get content =>
      $$ContentTableTableManager(_db.attachedDatabase, _db.content);
  $$ContentTagsTableTableManager get contentTags =>
      $$ContentTagsTableTableManager(_db.attachedDatabase, _db.contentTags);
}
