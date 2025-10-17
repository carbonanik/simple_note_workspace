import 'package:simple_note/core/network/custom_api_client.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';

abstract interface class NotesRemoteDataSource {
  Future<ApiResponse<List<NoteDto>>> getNotes();
  Future<ApiResponse<NoteDto>> getNoteById(int id);
  Future<ApiResponse<NoteDto>> createNote(NoteDto note);
  Future<ApiResponse<NoteDto>> updateNote(int id, NoteDto note);
  Future<ApiResponse<void>> deleteNote(int id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiClient apiClient;

  NotesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ApiResponse<List<NoteDto>>> getNotes() async {
    try {
      return await apiClient.get<List<NoteDto>>(
        '/notes/',
        fromJson: (json) => NoteDto.fromJsonList(json),
      );
    } catch (e) {
      throw ApiException('Failed to fetch notes: $e');
    }
  }

  @override
  Future<ApiResponse<NoteDto>> getNoteById(int id) async {
    try {
      final response = await apiClient.get<NoteDto>(
        '/notes/$id',
        fromJson: (json) => NoteDto.fromJson(json),
      );
      if (response.data == null) {
        throw ApiException('Note with id $id not found');
      }
      return response;
    } catch (e) {
      throw ApiException('Failed to fetch note with id $id: $e');
    }
  }

  @override
  Future<ApiResponse<NoteDto>> createNote(NoteDto note) async {
    try {
      return await apiClient.post<NoteDto>(
        '/notes/',
        body: note.toCreateJson(),
        fromJson: (json) => NoteDto.fromJson(json),
      );
    } catch (e) {
      throw ApiException('Failed to create note: $e');
    }
  }

  @override
  Future<ApiResponse<NoteDto>> updateNote(int id, NoteDto note) async {
    try {
      return await apiClient.put<NoteDto>(
        '/notes/$id',
        body: note.toJson(),
        fromJson: (json) => NoteDto.fromJson(json),
      );
    } catch (e) {
      throw ApiException('Failed to update note with id $id: $e');
    }
  }

  @override
  Future<ApiResponse<void>> deleteNote(int id) async {
    try {
      return await apiClient.delete('/notes/$id');
    } catch (e) {
      throw ApiException('Failed to delete note with id $id: $e');
    }
  }
}
