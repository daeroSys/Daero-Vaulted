import 'package:drift/drift.dart';
import 'users.dart';
import 'folders.dart';
import 'content.dart';

@TableIndex(name: 'idx_saved_items_user', columns: {#userId})
@TableIndex(name: 'idx_saved_items_folder', columns: {#folderId})
@TableIndex(name: 'idx_saved_items_content', columns: {#contentId})
@TableIndex(name: 'idx_saved_items_saved_at', columns: {#savedAt})
class SavedItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get folderId => text().nullable().references(Folders, #id)();
  TextColumn get contentId => text().references(Content, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get savedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
