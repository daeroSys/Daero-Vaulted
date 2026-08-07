import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/content_metadata.dart';

part 'metadata_dao.g.dart';

@DriftAccessor(tables: [ContentMetadata])
class MetadataDao extends DatabaseAccessor<AppDatabase> with _$MetadataDaoMixin {
  MetadataDao(super.db);

  Future<ContentMetadataData?> getMetadataByContentId(String contentId) {
    return (select(contentMetadata)..where((t) => t.contentId.equals(contentId))).getSingleOrNull();
  }
  
  Future<int> insertMetadata(ContentMetadataCompanion metadata) => into(contentMetadata).insert(metadata);
  
  Future<bool> updateMetadata(ContentMetadataCompanion metadata) => update(contentMetadata).replace(metadata);
}
