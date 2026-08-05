// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_dao.dart';

// ignore_for_file: type=lint
mixin _$FolderDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $FoldersTable get folders => attachedDatabase.folders;
  FolderDaoManager get managers => FolderDaoManager(this);
}

class FolderDaoManager {
  final _$FolderDaoMixin _db;
  FolderDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
}
