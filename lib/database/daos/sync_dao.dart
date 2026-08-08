import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue.dart';
import '../../domain/entities/enums.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<List<SyncQueueData>> getPendingSyncItems() {
    return (select(syncQueue)
      ..where((t) => t.syncStatus.isIn([SyncStatus.pending.name, SyncStatus.retrying.name]))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority), // Requires proper enum mapping logic in SQL if relying on strings, but we can sort in Dart later if needed.
        (t) => OrderingTerm(expression: t.createdAt)
      ])
    ).get();
  }
  
  Stream<List<SyncQueueData>> watchPendingSyncItems() {
    return (select(syncQueue)
      ..where((t) => t.syncStatus.isIn([SyncStatus.pending.name, SyncStatus.retrying.name]))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority),
        (t) => OrderingTerm(expression: t.createdAt)
      ])
    ).watch();
  }
  
  Future<int> insertSyncItem(SyncQueueCompanion item) => into(syncQueue).insert(item);
  
  Future<bool> updateSyncItem(SyncQueueCompanion item) => update(syncQueue).replace(item);
  
  Future<int> deleteSyncItem(String id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }
}
