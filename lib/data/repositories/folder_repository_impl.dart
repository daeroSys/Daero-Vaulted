import 'package:drift/drift.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../database/daos/folder_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderDao _folderDao;

  FolderRepositoryImpl(this._folderDao);

  @override
  Future<List<dynamic>> getActiveFolders(String userId) async {
    return await _folderDao.getActiveFolders(userId);
  }

  @override
  Future<void> createFolder(String userId, String name, String? icon, String? color, int position) async {
    await _folderDao.insertFolder(FoldersCompanion(
      id: Value(UuidUtils.generateV7()),
      userId: Value(userId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      position: Value(position),
      createdAt: Value(DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  @override
  Future<void> updateFolder(String id, {String? name, String? icon, String? color, int? position}) async {
    final existing = await _folderDao.getFolderById(id);
    if (existing != null) {
      await _folderDao.updateFolder(existing.copyWith(
        name: name ?? existing.name,
        icon: Value(icon ?? existing.icon),
        color: Value(color ?? existing.color),
        position: position ?? existing.position,
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
    }
  }

  @override
  Future<void> softDeleteFolder(String id) async {
    await _folderDao.softDeleteFolder(id, DateTime.now().toUtc());
  }
}
