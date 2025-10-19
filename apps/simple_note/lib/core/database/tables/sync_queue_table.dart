// lib/core/database/tables/sync_queue_table.dart
import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get entityId => integer()();
  TextColumn get entityType => text()(); // 'note', 'task', etc.
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text().nullable()(); // JSON data for create/update
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // 'pending', 'syncing', 'failed'
}
