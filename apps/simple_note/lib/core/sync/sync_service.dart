// lib/core/sync/sync_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:simple_note/core/database/drift_database.dart';
import 'package:simple_note/features/notes/data/datasources/local/notes_local_datasource.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_network_datasource.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/models/notes_model.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';

class SyncService {
  final AppDatabase database;
  final NotesLocalDataSource localDataSource;
  final NotesNetworkDataSource networkDataSource;

  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService({
    required this.database,
    required this.localDataSource,
    required this.networkDataSource,
  });

  /// Start periodic sync (every 5 minutes)
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncPendingChanges());
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  /// Add operation to sync queue
  Future<void> addToSyncQueue({
    required int entityId,
    required String entityType,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    await database
        .into(database.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            entityId: entityId,
            entityType: entityType,
            operation: operation,
            payload: Value(payload != null ? jsonEncode(payload) : null),
          ),
        );
  }

  /// Sync all pending changes
  Future<void> syncPendingChanges() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final pendingItems =
          await (database.select(database.syncQueue)
                ..where((t) => t.status.equals('pending'))
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
              .get();

      for (final item in pendingItems) {
        await _processSyncItem(item);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Process individual sync item
  Future<void> _processSyncItem(SyncQueueData item) async {
    try {
      // Mark as syncing
      await (database.update(database.syncQueue)
            ..where((t) => t.id.equals(item.id)))
          .write(const SyncQueueCompanion(status: Value('syncing')));

      // Process based on operation type
      switch (item.operation) {
        case 'create':
          await _syncCreate(item);
          break;
        case 'update':
          await _syncUpdate(item);
          break;
        case 'delete':
          await _syncDelete(item);
          break;
      }

      // Remove from queue after successful sync
      await (database.delete(
        database.syncQueue,
      )..where((t) => t.id.equals(item.id))).go();
    } catch (e) {
      // Mark as failed and increment retry count
      final newRetryCount = item.retryCount + 1;

      await (database.update(
        database.syncQueue,
      )..where((t) => t.id.equals(item.id))).write(
        SyncQueueCompanion(
          status: const Value('failed'),
          retryCount: Value(newRetryCount),
        ),
      );

      // Remove from queue if retry limit exceeded (e.g., 5 attempts)
      if (newRetryCount >= 5) {
        await (database.delete(
          database.syncQueue,
        )..where((t) => t.id.equals(item.id))).go();
      }
    }
  }

  /// Sync create operation
  Future<void> _syncCreate(SyncQueueData item) async {
    if (item.entityType == 'note' && item.payload != null) {
      final noteData = jsonDecode(item.payload!);
      final localNote = await localDataSource.getNoteById(item.entityId);

      if (localNote != null) {
        final entity = localNote.toEntity();
        final networkModel = await networkDataSource.createNote(
          NetworkNoteModel.fromEntity(entity),
        );

        // Update local with server ID if different
        if (networkModel.id != null && networkModel.id != item.entityId) {
          await localDataSource.updateNote(
            NoteModel.fromEntity(entity.copyWith(id: networkModel.id)),
          );
        }
      }
    }
  }

  /// Sync update operation
  Future<void> _syncUpdate(SyncQueueData item) async {
    if (item.entityType == 'note') {
      final localNote = await localDataSource.getNoteById(item.entityId);

      if (localNote != null) {
        await networkDataSource.updateNote(
          NetworkNoteModel.fromEntity(localNote.toEntity()),
        );
      }
    }
  }

  /// Sync delete operation
  Future<void> _syncDelete(SyncQueueData item) async {
    if (item.entityType == 'note') {
      await networkDataSource.deleteNote(item.entityId);
    }
  }

  /// Force sync all data from server
  Future<void> fullSync() async {
    try {
      // 1. Sync pending local changes first
      await syncPendingChanges();

      // 2. Get all notes from server
      final networkNotes = await networkDataSource.getNotes();
      final localNotes = await localDataSource.getNotes();

      // 3. Create maps for easy lookup
      final localNotesMap = {for (var note in localNotes) note.id: note};

      // 4. Sync server notes to local
      for (final networkNote in networkNotes) {
        final entity = networkNote.toEntity();
        final localNote = localNotesMap[entity.id];

        if (localNote == null) {
          // New note from server
          await localDataSource.addNote(NoteModel.fromEntity(entity));
        } else {
          // Check if server version is newer
          final localEntity = localNote.toEntity();
          if (_isNewerVersion(entity, localEntity)) {
            await localDataSource.updateNote(NoteModel.fromEntity(entity));
          }
        }
      }
    } catch (e) {
      print('Full sync failed: $e');
      rethrow;
    }
  }

  /// Check if note version is newer
  bool _isNewerVersion(NoteEntity serverNote, NoteEntity localNote) {
    if (serverNote.updatedAt == null || localNote.updatedAt == null) {
      return true;
    }
    return serverNote.updatedAt!.isAfter(localNote.updatedAt!);
  }

  /// Clean up old failed sync items (older than 7 days)
  Future<void> cleanupOldSyncItems() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    await (database.delete(database.syncQueue)..where(
          (t) =>
              t.status.equals('failed') &
              t.createdAt.isSmallerThanValue(cutoffDate),
        ))
        .go();
  }
}
