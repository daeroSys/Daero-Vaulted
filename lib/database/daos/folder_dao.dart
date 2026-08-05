import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/folders.dart';

part 'folder_dao.g.dart';

@DriftAccessor(tables: [Folders])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(AppDatabase db) : super(db);

  Future<List<Folder>> getActiveFolders(String userId) {
    return (select(folders)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.position)])
    ).get();
  }
  
  Future<Folder?> getFolderById(String id) {
    return (select(folders)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
  
  Future<int> insertFolder(FoldersCompanion folder) => into(folders).insert(folder);
  
  Future<bool> updateFolder(FoldersCompanion folder) => update(folders).replace(folder);
  
  Future<int> softDeleteFolder(String id, DateTime deletedAt) {
    return (update(folders)..where((t) => t.id.equals(id)))
        .write(FoldersCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
  }
}
