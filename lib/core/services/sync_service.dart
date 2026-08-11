import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/enums.dart';
import 'connectivity_service.dart';

import '../../database/app_database.dart';
import 'package:drift/drift.dart';

class SyncService {
  final SyncRepository _syncRepository;
  final ConnectivityService _connectivityService;
  final SupabaseClient _supabaseClient;
  final AppDatabase _db;
  final Logger _logger = Logger('SyncService');

  bool _isSyncing = false;

  SyncService({
    required SyncRepository syncRepository,
    required ConnectivityService connectivityService,
    required SupabaseClient supabaseClient,
    required AppDatabase db,
  }) : _syncRepository = syncRepository,
       _connectivityService = connectivityService,
       _supabaseClient = supabaseClient,
       _db = db {
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

      _logger.info(
        'Found ${pendingItems.length} pending mutations. Starting sync...',
      );

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
      _logger.info(
        'Successfully synced mutation $id ($entityType - ${operation.name})',
      );
    } catch (e) {
      _logger.warning('Failed to sync item ${item.id}', e);
      // Mark as retrying or failed based on retry count (simplification: just mark retrying for now, rely on exponential backoff or next trigger)
      await _syncRepository.markMutationStatus(item.id, SyncStatus.retrying);
    }
  }

  Future<void> syncDown(String userId) async {
    final isOnline = await _connectivityService.checkIsOnline();
    if (!isOnline) {
      _logger.info('Device is offline, skipping syncDown.');
      return;
    }

    try {
      _logger.info('Starting syncDown for user $userId');

      // 1. Fetch folders
      final foldersData = await _supabaseClient
          .from('folders')
          .select()
          .eq('user_id', userId);
      await _db.batch((batch) {
        for (final row in foldersData) {
          batch.insert(
            _db.folders,
            FoldersCompanion.insert(
              id: row['id'],
              userId: row['user_id'],
              name: row['name'],
              icon: Value(row['icon']),
              color: Value(row['color']),
              position: row['position'] ?? 0,
              createdAt: DateTime.parse(row['created_at']),
              updatedAt: DateTime.parse(row['updated_at']),
              deletedAt: Value(
                row['deleted_at'] != null
                    ? DateTime.parse(row['deleted_at'])
                    : null,
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      // 2. Fetch saved_items with joined content and metadata
      final savedItemsData = await _supabaseClient
          .from('saved_items')
          .select('*, content(*, content_metadata(*))')
          .eq('user_id', userId);

      await _db.batch((batch) {
        for (final row in savedItemsData) {
          // Insert content first
          final contentRow = row['content'];
          if (contentRow != null) {
            batch.insert(
              _db.content,
              ContentCompanion.insert(
                id: contentRow['id'],
                platform: Platform.values.byName(contentRow['platform']),
                contentType: ContentType.values.byName(
                  contentRow['content_type'],
                ),
                url: contentRow['url'],
                canonicalUrl: contentRow['canonical_url'],
                createdAt: DateTime.parse(contentRow['created_at']),
                updatedAt: DateTime.parse(contentRow['updated_at']),
                deletedAt: Value(
                  contentRow['deleted_at'] != null
                      ? DateTime.parse(contentRow['deleted_at'])
                      : null,
                ),
              ),
              mode: InsertMode.insertOrReplace,
            );

            // Insert content_metadata if it exists
            final metadataList =
                contentRow['content_metadata'] as List<dynamic>?;
            if (metadataList != null && metadataList.isNotEmpty) {
              final metadataRow = metadataList.first;
              batch.insert(
                _db.contentMetadata,
                ContentMetadataCompanion.insert(
                  id: metadataRow['id'],
                  contentId: metadataRow['content_id'],
                  title: Value(metadataRow['title']),
                  creator: Value(metadataRow['creator']),
                  description: Value(metadataRow['description']),
                  thumbnail: Value(metadataRow['thumbnail']),
                  duration: Value(metadataRow['duration']),
                  language: Value(metadataRow['language']),
                  metadataStatus: MetadataStatus.values.byName(
                    metadataRow['metadata_status'],
                  ),
                  lastFetched: Value(
                    metadataRow['last_fetched'] != null
                        ? DateTime.parse(metadataRow['last_fetched'])
                        : null,
                  ),
                  updatedAt: metadataRow['updated_at'] != null
                      ? DateTime.parse(metadataRow['updated_at'])
                      : DateTime.now(),
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }

          // Insert saved_item
          batch.insert(
            _db.savedItems,
            SavedItemsCompanion.insert(
              id: row['id'],
              userId: row['user_id'],
              folderId: Value(row['folder_id']),
              contentId: row['content_id'],
              notes: Value(row['notes']),
              isFavorite: Value(row['is_favorite'] ?? false),
              isArchived: Value(row['is_archived'] ?? false),
              savedAt: DateTime.parse(row['saved_at']),
              updatedAt: DateTime.parse(row['updated_at']),
              deletedAt: Value(
                row['deleted_at'] != null
                    ? DateTime.parse(row['deleted_at'])
                    : null,
              ),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      // Update Search Index for all synced items
      for (final row in savedItemsData) {
        final contentRow = row['content'];
        if (contentRow != null) {
          final metadataList = contentRow['content_metadata'] as List<dynamic>?;
          final metadataRow = (metadataList != null && metadataList.isNotEmpty)
              ? metadataList.first
              : null;

          await _db.searchDao.updateSearchIndex(
            contentId: contentRow['id'],
            title: metadataRow?['title'] as String?,
            creator: metadataRow?['creator'] as String?,
            description: metadataRow?['description'] as String?,
            notes: row['notes'] as String?,
          );
        }
      }

      _logger.info('Successfully completed syncDown for user $userId');
    } catch (e, stackTrace) {
      _logger.severe('Failed to syncDown data', e, stackTrace);
    }
  }
}
