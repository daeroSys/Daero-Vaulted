import 'package:drift/drift.dart';
import '../../domain/repositories/metadata_repository.dart';
import '../../domain/entities/enums.dart';
import '../../database/daos/metadata_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

import '../../domain/repositories/sync_repository.dart';

class MetadataRepositoryImpl implements MetadataRepository {
  final MetadataDao _metadataDao;
  final SyncRepository _syncRepository;

  MetadataRepositoryImpl(this._metadataDao, this._syncRepository);

  @override
  Future<void> updateMetadata(
    String contentId, {
    String? title,
    String? creator,
    String? description,
    String? thumbnail,
    int? duration,
    String? language,
    required MetadataStatus status,
  }) async {
    final existing = await _metadataDao.getMetadataByContentId(contentId);
    
    if (existing == null) {
      final newId = UuidUtils.generateV7();
      
      await _metadataDao.insertMetadata(ContentMetadataCompanion(
        id: Value(newId),
        contentId: Value(contentId),
        title: Value(title),
        creator: Value(creator),
        description: Value(description),
        thumbnail: Value(thumbnail),
        duration: Value(duration),
        language: Value(language),
        metadataStatus: Value(status),
        lastFetched: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
      
      await _syncRepository.queueMutation(
        'content_metadata',
        newId,
        SyncOperation.create,
        SyncPriority.low,
        {
          'id': newId,
          'content_id': contentId,
          'title': title,
          'creator': creator,
          'description': description,
          'thumbnail': thumbnail,
          'duration': duration,
          'language': language,
          'metadata_status': status.name,
          'last_fetched': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } else {
      await _metadataDao.updateMetadata(existing.copyWith(
        title: Value(title ?? existing.title),
        creator: Value(creator ?? existing.creator),
        description: Value(description ?? existing.description),
        thumbnail: Value(thumbnail ?? existing.thumbnail),
        duration: Value(duration ?? existing.duration),
        language: Value(language ?? existing.language),
        metadataStatus: status,
        lastFetched: Value(DateTime.now().toUtc()),
        updatedAt: DateTime.now().toUtc(),
      ).toCompanion(true));
      
      await _syncRepository.queueMutation(
        'content_metadata',
        existing.id,
        SyncOperation.update,
        SyncPriority.low,
        {
          'id': existing.id,
          'content_id': contentId,
          'title': title ?? existing.title,
          'creator': creator ?? existing.creator,
          'description': description ?? existing.description,
          'thumbnail': thumbnail ?? existing.thumbnail,
          'duration': duration ?? existing.duration,
          'language': language ?? existing.language,
          'metadata_status': status.name,
          'last_fetched': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }
  }
}
