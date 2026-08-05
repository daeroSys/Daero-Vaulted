import 'package:drift/drift.dart';
import '../../domain/entities/enums.dart';

@TableIndex(name: 'idx_sync_queue_status', columns: {#syncStatus})
@TableIndex(name: 'idx_sync_queue_priority', columns: {#priority})
@TableIndex(name: 'idx_sync_queue_created_at', columns: {#createdAt})
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get syncOperation => textEnum<SyncOperation>()();
  TextColumn get priority => textEnum<SyncPriority>()();
  TextColumn get payload => text()(); // Store JSON as string
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  TextColumn get syncStatus => textEnum<SyncStatus>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
