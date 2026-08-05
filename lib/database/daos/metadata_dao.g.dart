// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_dao.dart';

// ignore_for_file: type=lint
mixin _$MetadataDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContentTable get content => attachedDatabase.content;
  $ContentMetadataTable get contentMetadata => attachedDatabase.contentMetadata;
  MetadataDaoManager get managers => MetadataDaoManager(this);
}

class MetadataDaoManager {
  final _$MetadataDaoMixin _db;
  MetadataDaoManager(this._db);
  $$ContentTableTableManager get content =>
      $$ContentTableTableManager(_db.attachedDatabase, _db.content);
  $$ContentMetadataTableTableManager get contentMetadata =>
      $$ContentMetadataTableTableManager(
        _db.attachedDatabase,
        _db.contentMetadata,
      );
}
