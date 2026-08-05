abstract class FolderRepository {
  Future<List<dynamic>> getActiveFolders(String userId);
  Future<void> createFolder(String userId, String name, String? icon, String? color, int position);
  Future<void> updateFolder(String id, {String? name, String? icon, String? color, int? position});
  Future<void> softDeleteFolder(String id);
}
