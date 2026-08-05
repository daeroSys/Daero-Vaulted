import 'dart:io' show File;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables/users.dart';
import 'tables/folders.dart';
import 'tables/content.dart';
import 'tables/content_metadata.dart';
import 'tables/tags.dart';
import 'tables/content_tags.dart';
import 'tables/saved_items.dart';
import 'tables/sync_queue.dart';

import '../domain/entities/enums.dart';

import 'daos/user_dao.dart';
import 'daos/folder_dao.dart';
import 'daos/content_dao.dart';
import 'daos/metadata_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/search_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Folders,
    Content,
    ContentMetadata,
    Tags,
    ContentTags,
    SavedItems,
    SyncQueue,
  ],
  daos: [
    UserDao,
    FolderDao,
    ContentDao,
    MetadataDao,
    TagDao,
    SyncDao,
    SearchDao,
  ],
  include: {'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vaulted.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
