import 'package:drift/drift.dart';

class RecentSearches extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get query => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
