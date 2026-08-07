import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';
import '../../database/daos/sync_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncDao _syncDao;

  SyncRepositoryImpl(this._syncDao);

  @override
  Future<void> queueMutation(String entityType, String entityId, SyncOperation operation, SyncPriority priority, Map<String, dynamic> payload) async {
    await _syncDao.insertSyncItem(SyncQueueCompanion(
      id: Value(UuidUtils.generateV7()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      syncOperation: Value(operation),
      priority: Value(priority),
      payload: Value(jsonEncode(payload)),
      syncStatus: const Value(SyncStatus.pending),
      createdAt: Value(DateTime.now().toUtc()),
    ));
  }

  @override
  Future<List<dynamic>> getPendingMutations() async {
    return await _syncDao.getPendingSyncItems();
  }

  @override
  Future<void> markMutationStatus(String id, SyncStatus status) async {
    final results = await _syncDao.select(_syncDao.syncQueue).get();
    final existing = results.where((item) => item.id == id).firstOrNull;
    
    if (existing != null) {
      await _syncDao.updateSyncItem(existing.copyWith(
        syncStatus: status,
        lastAttempt: Value(DateTime.now().toUtc()),
      ).toCompanion(true));
    }
  }
}
