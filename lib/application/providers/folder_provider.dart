import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/data/repositories/folder_repository_impl.dart';
import 'package:vaulted/domain/entities/folder.dart';
import 'package:vaulted/domain/repositories/folder_repository.dart';
import 'auth_provider.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FolderRepositoryImpl(db.folderDao);
});

final foldersProvider = AsyncNotifierProvider<FoldersNotifier, List<Folder>>(() {
  return FoldersNotifier();
});

class FoldersNotifier extends AsyncNotifier<List<Folder>> {
  @override
  Future<List<Folder>> build() async {
    return _fetchFolders();
  }

  Future<List<Folder>> _fetchFolders() async {
    final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
    if (userId == null) return [];
    
    final repo = ref.read(folderRepositoryProvider);
    return await repo.getActiveFolders(userId);
  }

  Future<void> createFolder(String name, String? icon, String? color) async {
    final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
    if (userId == null) return;
    
    final repo = ref.read(folderRepositoryProvider);
    final currentFolders = state.value ?? [];
    
    await repo.createFolder(userId, name, icon, color, currentFolders.length);
    ref.invalidateSelf();
  }

  Future<void> updateFolder(String id, {String? name, String? icon, String? color}) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.updateFolder(id, name: name, icon: icon, color: color);
    ref.invalidateSelf();
  }

  Future<void> deleteFolder(String id) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.softDeleteFolder(id);
    ref.invalidateSelf();
  }

  Future<void> restoreFolder(String id) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.restoreFolder(id);
    ref.invalidateSelf();
  }

  Future<void> reorderFolders(int oldIndex, int newIndex) async {
    final currentList = state.value;
    if (currentList == null) return;

    final items = List<Folder>.from(currentList);
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    
    // Optimistic UI update
    state = AsyncValue.data(items);
    
    // Background DB save
    final orderedIds = items.map((f) => f.id).toList();
    final repo = ref.read(folderRepositoryProvider);
    await repo.updateFolderPositions(orderedIds);
  }
}
