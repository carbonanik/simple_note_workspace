// lib/features/notes/data/repositories/enhanced_hybrid_notes_repository.dart
import 'package:simple_note/core/sync/sync_service.dart';
import 'package:simple_note/features/notes/data/datasources/local/notes_local_datasource.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_network_datasource.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/models/notes_model.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class EnhancedHybridNotesRepository implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesNetworkDataSource networkDataSource;
  final SyncService syncService;

  EnhancedHybridNotesRepository({
    required this.localDataSource,
    required this.networkDataSource,
    required this.syncService,
  });

  /// Get notes - Always return local data, sync in background
  @override
  Future<List<NoteEntity>> getNotes() async {
    // 1. Get local data (instant response)
    final localModels = await localDataSource.getNotes();
    final localEntities = localModels.map((m) => m.toEntity()).toList();

    // 2. Trigger background sync (don't await)
    _backgroundSync();

    return localEntities;
  }

  /// Add note - Save locally, queue for sync
  @override
  Future<int> addNote(NoteEntity note) async {
    // 1. Save locally first
    final localId = await localDataSource.addNote(NoteModel.fromEntity(note));

    // 2. Try immediate sync
    try {
      final networkModel = await networkDataSource.createNote(
        NetworkNoteModel.fromEntity(note.copyWith(id: localId)),
      );

      // Update with server ID if different
      if (networkModel.id != null && networkModel.id != localId) {
        final updatedNote = note.copyWith(id: networkModel.id);
        await localDataSource.updateNote(NoteModel.fromEntity(updatedNote));
        return networkModel.id!;
      }
    } catch (e) {
      // Network failed - add to sync queue
      await syncService.addToSyncQueue(
        entityId: localId,
        entityType: 'note',
        operation: 'create',
        payload: note.toJson(),
      );
    }

    return localId;
  }

  /// Update note - Update locally, queue for sync
  @override
  Future<void> updateNote(NoteEntity note) async {
    // 1. Update locally first
    await localDataSource.updateNote(NoteModel.fromEntity(note));

    // 2. Try immediate sync
    try {
      await networkDataSource.updateNote(NetworkNoteModel.fromEntity(note));
    } catch (e) {
      // Network failed - add to sync queue
      await syncService.addToSyncQueue(
        entityId: note.id!,
        entityType: 'note',
        operation: 'update',
        payload: note.toJson(),
      );
    }
  }

  /// Delete note - Delete locally, queue for sync
  @override
  Future<void> deleteNote(int id) async {
    // 1. Delete locally first
    await localDataSource.deleteNote(id);

    // 2. Try immediate sync
    try {
      await networkDataSource.deleteNote(id);
    } catch (e) {
      // Network failed - add to sync queue
      await syncService.addToSyncQueue(
        entityId: id,
        entityType: 'note',
        operation: 'delete',
      );
    }
  }

  /// Get note by ID - Local first
  @override
  Future<NoteEntity?> getNoteById(int id) async {
    final localModel = await localDataSource.getNoteById(id);
    return localModel?.toEntity();
  }

  /// Background sync - silent fail
  Future<void> _backgroundSync() async {
    try {
      final networkModels = await networkDataSource.getNotes();

      for (final networkModel in networkModels) {
        final entity = networkModel.toEntity();
        final existingLocal = await localDataSource.getNoteById(entity.id!);

        if (existingLocal == null) {
          await localDataSource.addNote(NoteModel.fromEntity(entity));
        } else {
          final existingEntity = existingLocal.toEntity();
          if (_isNewerVersion(entity, existingEntity)) {
            await localDataSource.updateNote(NoteModel.fromEntity(entity));
          }
        }
      }
    } catch (e) {
      // Silent fail - user already has local data
    }
  }

  bool _isNewerVersion(NoteEntity serverNote, NoteEntity localNote) {
    if (serverNote.updatedAt == null || localNote.updatedAt == null) {
      return true;
    }
    return serverNote.updatedAt!.isAfter(localNote.updatedAt!);
  }
}

// Extension for NoteEntity to JSON (if not already implemented)
extension NoteEntityJson on NoteEntity {
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
