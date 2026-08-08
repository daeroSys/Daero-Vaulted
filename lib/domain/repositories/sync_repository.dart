import '../entities/enums.dart';

abstract class SyncRepository {
  Future<void> queueMutation(String entityType, String entityId, SyncOperation operation, SyncPriority priority, Map<String, dynamic> payload);
  Future<List<dynamic>> getPendingMutations();
  Stream<List<dynamic>> watchPendingMutations();
  Future<void> markMutationStatus(String id, SyncStatus status);
}
