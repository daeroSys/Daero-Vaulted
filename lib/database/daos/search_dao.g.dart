// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dao.dart';

// ignore_for_file: type=lint
mixin _$SearchDaoMixin on DatabaseAccessor<AppDatabase> {
  FtsSearch get ftsSearch => attachedDatabase.ftsSearch;
  SearchDaoManager get managers => SearchDaoManager(this);
}

class SearchDaoManager {
  final _$SearchDaoMixin _db;
  SearchDaoManager(this._db);
  $FtsSearchTableManager get ftsSearch =>
      $FtsSearchTableManager(_db.attachedDatabase, _db.ftsSearch);
}
