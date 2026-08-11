import 'package:drift/drift.dart';
import '../../domain/entities/folder.dart' as entity;
import '../../domain/repositories/folder_repository.dart';
import '../../database/daos/folder_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderDao _folderDao;
  final SyncRepository _syncRepository;

  FolderRepositoryImpl(this._folderDao, this._syncRepository);

  @override
  Future<List<entity.Folder>> getActiveFolders(String userId) async {
    final driftFolders = await _folderDao.getActiveFolders(userId);
    return driftFolders
        .map(
          (f) => entity.Folder(
            id: f.id,
            userId: f.userId,
            name: f.name,
            icon: f.icon,
            color: f.color,
            position: f.position,
            createdAt: f.createdAt,
            updatedAt: f.updatedAt,
            deletedAt: f.deletedAt,
          ),
        )
        .toList();
  }

  @override
  Stream<List<entity.Folder>> watchActiveFolders(String userId) {
    return _folderDao.watchActiveFolders(userId).map((driftFolders) {
      return driftFolders
          .map(
            (f) => entity.Folder(
              id: f.id,
              userId: f.userId,
              name: f.name,
              icon: f.icon,
              color: f.color,
              position: f.position,
              createdAt: f.createdAt,
              updatedAt: f.updatedAt,
              deletedAt: f.deletedAt,
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> createFolder(
    String userId,
    String name,
    String? icon,
    String? color,
    int position,
  ) async {
    final id = UuidUtils.generateV7();
    final now = DateTime.now().toUtc();

    await _folderDao.insertFolder(
      FoldersCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(name),
        icon: Value(icon),
        color: Value(color),
        position: Value(position),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await _syncRepository
        .queueMutation('folders', id, SyncOperation.create, SyncPriority.high, {
          'id': id,
          'user_id': userId,
          'name': name,
          'icon': icon,
          'color': color,
          'position': position,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
        });
  }

  @override
  Future<void> updateFolder(
    String id, {
    String? name,
    String? icon,
    String? color,
    int? position,
  }) async {
    final existing = await _folderDao.getFolderById(id);
    if (existing != null) {
      final now = DateTime.now().toUtc();
      final updated = existing.copyWith(
        name: name ?? existing.name,
        icon: Value(icon ?? existing.icon),
        color: Value(color ?? existing.color),
        position: position ?? existing.position,
        updatedAt: now,
      );

      await _folderDao.updateFolder(updated.toCompanion(true));

      await _syncRepository.queueMutation(
        'folders',
        id,
        SyncOperation.update,
        SyncPriority.normal,
        {
          'id': updated.id,
          'user_id': updated.userId,
          'name': updated.name,
          'icon': updated.icon,
          'color': updated.color,
          'position': updated.position,
          'created_at': updated.createdAt.toIso8601String(),
          'updated_at': updated.updatedAt.toIso8601String(),
          'deleted_at': updated.deletedAt?.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> softDeleteFolder(String id) async {
    final now = DateTime.now().toUtc();
    await _folderDao.softDeleteFolder(id, now);

    final existing = await _folderDao.getFolderById(id);
    if (existing != null) {
      await _syncRepository.queueMutation(
        'folders',
        id,
        SyncOperation
            .update, // Or soft delete logic, typically update in supabase with deleted_at
        SyncPriority.normal,
        {
          'id': existing.id,
          'user_id': existing.userId,
          'name': existing.name,
          'icon': existing.icon,
          'color': existing.color,
          'position': existing.position,
          'created_at': existing.createdAt.toIso8601String(),
          'updated_at': existing.updatedAt.toIso8601String(),
          'deleted_at': existing.deletedAt?.toIso8601String(),
        },
      );
    }
  }

  @override
  Future<void> restoreFolder(String id) async {
    await _folderDao.restoreFolder(id);

    final existing = await _folderDao.getFolderById(id);
    if (existing != null) {
      await _syncRepository.queueMutation(
        'folders',
        id,
        SyncOperation.restore,
        SyncPriority.normal,
        {
          'id': existing.id,
          'user_id': existing.userId,
          'name': existing.name,
          'icon': existing.icon,
          'color': existing.color,
          'position': existing.position,
          'created_at': existing.createdAt.toIso8601String(),
          'updated_at': existing.updatedAt.toIso8601String(),
          'deleted_at': null,
        },
      );
    }
  }

  @override
  Future<void> updateFolderPositions(List<String> orderedFolderIds) async {
    await _folderDao.updateFolderPositions(orderedFolderIds);

    // Queue mutations for each updated folder
    for (final id in orderedFolderIds) {
      final existing = await _folderDao.getFolderById(id);
      if (existing != null) {
        await _syncRepository.queueMutation(
          'folders',
          id,
          SyncOperation.update,
          SyncPriority.low,
          {
            'id': existing.id,
            'user_id': existing.userId,
            'name': existing.name,
            'icon': existing.icon,
            'color': existing.color,
            'position': existing.position,
            'created_at': existing.createdAt.toIso8601String(),
            'updated_at': existing.updatedAt.toIso8601String(),
            'deleted_at': existing.deletedAt?.toIso8601String(),
          },
        );
      }
    }
  }
}
