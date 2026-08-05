import 'package:drift/drift.dart';
import '../../domain/repositories/metadata_repository.dart';
import '../../domain/entities/enums.dart';
import '../../database/daos/metadata_dao.dart';
import '../../database/app_database.dart';
import '../../core/utils/uuid_utils.dart';

class MetadataRepositoryImpl implements MetadataRepository {
  final MetadataDao _metadataDao;

  MetadataRepositoryImpl(this._metadataDao);

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
      await _metadataDao.insertMetadata(ContentMetadataCompanion(
        id: Value(UuidUtils.generateV7()),
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
    }
  }
}
