import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getActiveFolders(String userId);
  Stream<List<Folder>> watchActiveFolders(String userId);
  Future<void> createFolder(String userId, String name, String? icon, String? color, int position);
  Future<void> updateFolder(String id, {String? name, String? icon, String? color, int? position});
  Future<void> softDeleteFolder(String id);
  Future<void> restoreFolder(String id);
  Future<void> updateFolderPositions(List<String> orderedFolderIds);
}
