import 'dart:async';

import 'package:simple_note/features/notes/data/datasources/local/notes_local_datasource.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_network_datasource.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/models/notes_model.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class HybridNotesRepository implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesNetworkDataSource networkDataSource;

  HybridNotesRepository({
    required this.localDataSource,
    required this.networkDataSource,
  });

  /// Get notes - Offline first approach
  /// Returns local data immediately, syncs in background
  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      // 1. Get local data first (fast response)
      final localModels = await localDataSource.getNotes();
      final localEntities = localModels.map((m) => m.toEntity()).toList();

      // 2. Sync from network in background (don't await)
      unawaited(_syncNotesFromNetwork());

      // 3. Return local data immediately
      return localEntities;
    } catch (e) {
      // If local fails, try network as fallback
      return _getNotesFromNetwork();
    }
  }

  /// Add note - Save locally first, sync to network
  @override
  Future<int> addNote(NoteEntity note) async {
    try {
      // 1. Save to local database first (offline support)
      final localId = await localDataSource.addNote(NoteModel.fromEntity(note));

      // 2. Try to sync to network
      try {
        final networkModel = await networkDataSource.createNote(
          NetworkNoteModel.fromEntity(note.copyWith(id: localId)),
        );

        // 3. Update local with server ID if different
        if (networkModel.id != null && networkModel.id != localId) {
          final updatedNote = note.copyWith(id: networkModel.id);
          await localDataSource.updateNote(NoteModel.fromEntity(updatedNote));
          return networkModel.id!;
        }
      } catch (networkError) {
        // Network failed, but local save succeeded
        // Mark for later sync if you implement sync queue
        _markForSync(localId, SyncOperation.create);
      }

      return localId;
    } catch (e) {
      rethrow;
    }
  }

  /// Update note - Update locally first, sync to network
  @override
  Future<void> updateNote(NoteEntity note) async {
    try {
      // 1. Update local first
      await localDataSource.updateNote(NoteModel.fromEntity(note));

      // 2. Try to sync to network
      try {
        await networkDataSource.updateNote(NetworkNoteModel.fromEntity(note));
      } catch (networkError) {
        // Network failed, but local update succeeded
        _markForSync(note.id!, SyncOperation.update);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete note - Delete locally first, sync to network
  @override
  Future<void> deleteNote(int id) async {
    try {
      // 1. Delete from local first
      await localDataSource.deleteNote(id);

      // 2. Try to sync deletion to network
      try {
        await networkDataSource.deleteNote(id);
      } catch (networkError) {
        // Network failed, but local deletion succeeded
        _markForSync(id, SyncOperation.delete);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get note by ID - Check local first
  @override
  Future<NoteEntity?> getNoteById(int id) async {
    try {
      // 1. Try local first
      final localModel = await localDataSource.getNoteById(id);
      if (localModel != null) {
        return localModel.toEntity();
      }

      // 2. If not in local, try network
      final networkModel = await networkDataSource.getNoteById(id);
      if (networkModel != null) {
        // Save to local for offline access
        await localDataSource.addNote(
          NoteModel.fromEntity(networkModel.toEntity()),
        );
        return networkModel.toEntity();
      }

      return null;
    } catch (e) {
      // Try local as fallback
      final localModel = await localDataSource.getNoteById(id);
      return localModel?.toEntity();
    }
  }

  /// Background sync from network to local
  Future<void> _syncNotesFromNetwork() async {
    try {
      final networkModels = await networkDataSource.getNotes();

      for (final networkModel in networkModels) {
        final entity = networkModel.toEntity();
        final existingLocal = await localDataSource.getNoteById(entity.id!);

        if (existingLocal == null) {
          // New note from server, add to local
          await localDataSource.addNote(NoteModel.fromEntity(entity));
        } else {
          // Note exists, update if server version is newer
          final existingEntity = existingLocal.toEntity();
          if (_isNewerVersion(entity, existingEntity)) {
            await localDataSource.updateNote(NoteModel.fromEntity(entity));
          }
        }
      }
    } catch (e) {
      // Silent fail - we already returned local data
      print('Background sync failed: $e');
    }
  }

  /// Fallback: Get notes from network only
  Future<List<NoteEntity>> _getNotesFromNetwork() async {
    final networkModels = await networkDataSource.getNotes();

    // Save to local for future offline access
    for (final model in networkModels) {
      try {
        await localDataSource.addNote(NoteModel.fromEntity(model.toEntity()));
      } catch (e) {
        // Ignore duplicates
      }
    }

    return networkModels.map((m) => m.toEntity()).toList();
  }

  /// Check if note version is newer
  bool _isNewerVersion(NoteEntity serverNote, NoteEntity localNote) {
    if (serverNote.updatedAt == null || localNote.updatedAt == null) {
      return true;
    }
    return serverNote.updatedAt!.isAfter(localNote.updatedAt!);
  }

  /// Mark note for later sync (implement with sync queue)
  void _markForSync(int id, SyncOperation operation) {
    // TODO: Implement sync queue to track pending operations
    // This allows syncing when network becomes available
    print('Marked for sync: $operation on note $id');
  }
}

enum SyncOperation { create, update, delete }
