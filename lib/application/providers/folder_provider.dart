import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaulted/core/providers.dart';
import 'package:vaulted/data/repositories/folder_repository_impl.dart';
import 'package:vaulted/domain/entities/folder.dart';
import 'package:vaulted/domain/repositories/folder_repository.dart';
import 'auth_provider.dart';

import 'sync_provider.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return FolderRepositoryImpl(db.folderDao, syncRepo);
});

final foldersProvider = StreamNotifierProvider.autoDispose<FoldersNotifier, List<Folder>>(() {
  return FoldersNotifier();
});

class FoldersNotifier extends AutoDisposeStreamNotifier<List<Folder>> {
  @override
  Stream<List<Folder>> build() {
    final authState = ref.watch(authStateProvider).value;
    final userId = authState?.session?.user.id;
    if (userId == null) return Stream.value([]);
    
    final repo = ref.watch(folderRepositoryProvider);
    return repo.watchActiveFolders(userId);
  }

  Future<void> createFolder(String name, String? icon, String? color) async {
    final userId = await ref.read(authRepositoryProvider).getCurrentUserId();
    if (userId == null) return;
    
    final repo = ref.read(folderRepositoryProvider);
    final currentFolders = state.value ?? [];
    
    await repo.createFolder(userId, name, icon, color, currentFolders.length);
  }

  Future<void> updateFolder(String id, {String? name, String? icon, String? color}) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.updateFolder(id, name: name, icon: icon, color: color);
  }

  Future<void> deleteFolder(String id) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.softDeleteFolder(id);
  }

  Future<void> restoreFolder(String id) async {
    final repo = ref.read(folderRepositoryProvider);
    await repo.restoreFolder(id);
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
    
    // Optimistic UI is no longer needed because the Drift Stream will automatically
    // emit the newly ordered list instantly.
    
    // Background DB save
    final orderedIds = items.map((f) => f.id).toList();
    final repo = ref.read(folderRepositoryProvider);
    await repo.updateFolderPositions(orderedIds);
  }
}
