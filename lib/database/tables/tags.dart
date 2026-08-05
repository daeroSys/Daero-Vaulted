import 'package:drift/drift.dart';

@TableIndex(name: 'idx_tags_name', columns: {#name})
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
