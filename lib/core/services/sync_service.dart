import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';
import 'connectivity_service.dart';

class SyncService {
  final SyncRepository _syncRepository;
  final ConnectivityService _connectivityService;
  final SupabaseClient _supabaseClient;
  final Logger _logger = Logger('SyncService');

  bool _isSyncing = false;

  SyncService({
    required this._syncRepository,
    required this._connectivityService,
    required this._supabaseClient,
  }) {
    _init();
  }

  void _init() {
    _connectivityService.isOnlineStream.listen((isOnline) {
      if (isOnline) {
        processQueue();
      }
    });

    _syncRepository.watchPendingMutations().listen((mutations) {
      if (mutations.isNotEmpty) {
        processQueue();
      }
    });
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    final isOnline = await _connectivityService.checkIsOnline();
    if (!isOnline) {
      _logger.info('Device is offline, skipping sync.');
      return;
    }

    _isSyncing = true;
    try {
      final pendingItems = await _syncRepository.getPendingMutations();
      if (pendingItems.isEmpty) {
        _logger.info('No pending mutations to sync.');
        return;
      }

      _logger.info('Found ${pendingItems.length} pending mutations. Starting sync...');
      
      for (final item in pendingItems) {
        await _processItem(item);
      }
    } catch (e, stackTrace) {
      _logger.severe('Error processing sync queue', e, stackTrace);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processItem(dynamic item) async {
    try {
      // Assuming item is a SyncQueueData object (from drift)
      final String id = item.id;
      final String entityType = item.entityType;
      final SyncOperation operation = item.syncOperation;
      final Map<String, dynamic> payload = jsonDecode(item.payload);
      
      // Mark as running
      await _syncRepository.markMutationStatus(id, SyncStatus.running);
      
      final table = _supabaseClient.from(entityType);
      
      switch (operation) {
        case SyncOperation.create:
        case SyncOperation.update:
        case SyncOperation.restore:
          // Last-Write-Wins based on updatedAt is typically handled by upserting
          await table.upsert(payload);
          break;
        case SyncOperation.delete:
          final String entityId = item.entityId;
          await table.delete().eq('id', entityId);
          break;
        case SyncOperation.metadataRefresh:
          await table.upsert(payload);
          break;
      }
      
      // Mark as synced
      await _syncRepository.markMutationStatus(id, SyncStatus.synced);
      _logger.info('Successfully synced mutation $id ($entityType - ${operation.name})');
      
    } catch (e) {
      _logger.warning('Failed to sync item ${item.id}', e);
      // Mark as retrying or failed based on retry count (simplification: just mark retrying for now, rely on exponential backoff or next trigger)
      await _syncRepository.markMutationStatus(item.id, SyncStatus.retrying);
    }
  }
}
