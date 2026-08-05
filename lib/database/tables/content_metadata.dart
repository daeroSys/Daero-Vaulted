import 'package:drift/drift.dart';
import 'content.dart';
import '../../domain/entities/enums.dart';

@TableIndex(name: 'idx_content_metadata_status', columns: {#metadataStatus})
class ContentMetadata extends Table {
  TextColumn get id => text()();
  TextColumn get contentId => text().references(Content, #id)();
  TextColumn get title => text().nullable()();
  TextColumn get creator => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnail => text().nullable()();
  IntColumn get duration => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get metadataStatus => textEnum<MetadataStatus>()();
  DateTimeColumn get lastFetched => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
