import 'package:simple_note/core/network/exception/api_exception.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_api_service.dart';

class NotesNetworkDataSource {
  final NotesApiService apiService;

  NotesNetworkDataSource(this.apiService);

  Future<List<NetworkNoteModel>> getNotes() async {
    try {
      final response = await apiService.getNotes();

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message ?? 'Failed to fetch notes',
          statusCode: response.statusCode,
        );
      }

      return response.data!;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<NetworkNoteModel?> getNoteById(int id) async {
    try {
      final response = await apiService.getNoteById(id);

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to fetch note',
          statusCode: response.statusCode,
        );
      }

      return response.data;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<NetworkNoteModel> createNote(NetworkNoteModel note) async {
    try {
      final response = await apiService.createNote(note.toJson());

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.message ?? 'Failed to create note',
          statusCode: response.statusCode,
        );
      }

      return response.data!;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> updateNote(NetworkNoteModel note) async {
    try {
      final response = await apiService.updateNote(note.id!, note.toJson());

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to update note',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      final response = await apiService.deleteNote(id);

      if (!response.success) {
        throw ApiException(
          message: response.message ?? 'Failed to delete note',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(Object e) {
    if (e is ApiException) {
      return e;
    }
    return ApiException(
      message: 'An unexpected error occurred: ${e.toString()}',
    );
  }
}
