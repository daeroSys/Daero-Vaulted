import 'package:drift/drift.dart';
import '../../domain/entities/enums.dart';

@TableIndex(name: 'idx_content_canonical_url', columns: {#canonicalUrl})
@TableIndex(name: 'idx_content_deleted_at', columns: {#deletedAt})
class Content extends Table {
  TextColumn get id => text()();
  TextColumn get platform => textEnum<Platform>()();
  TextColumn get contentType => textEnum<ContentType>()();
  TextColumn get url => text()();
  TextColumn get canonicalUrl => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
