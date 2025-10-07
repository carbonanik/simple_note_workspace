import 'package:simple_note/core/network/api_client.dart';
import 'package:simple_note/core/network/api_response.dart';
import 'package:simple_note/features/notes/data/models/note_dto.dart';

abstract interface class NotesRemoteDataSource {
  Future<List<NoteDto>> getNotes();
  Future<NoteDto> getNoteById(int id);
  Future<NoteDto> createNote(NoteDto note);
  Future<NoteDto> updateNote(int id, NoteDto note);
  Future<void> deleteNote(int id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiClient apiClient;

  NotesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<NoteDto>> getNotes() async {
    try {
      final response = await apiClient.get<ApiResponse<List<NoteDto>>>(
        '/notes/',
        fromJson: (value) {
          return ApiResponse.fromJson(value, (data) {
            return (data as List)
                .map((item) => NoteDto.fromJson(item))
                .toList();
          });
        },
      );
      return response.data;
    } catch (e) {
      throw ApiException('Failed to fetch notes: $e');
    }
  }

  @override
  Future<NoteDto> getNoteById(int id) async {
    try {
      final response = await apiClient.get<NoteDto>(
        '/notes/$id',
        fromJson: NoteDto.fromJson,
      );
      return response;
    } catch (e) {
      throw ApiException('Failed to fetch note with id $id: $e');
    }
  }

  @override
  Future<NoteDto> createNote(NoteDto note) async {
    try {
      final response = await apiClient.post<NoteDto>(
        '/notes/',
        body: note.toCreateJson(),
        fromJson: NoteDto.fromJson,
      );
      return response;
    } catch (e) {
      throw ApiException('Failed to create note: $e');
    }
  }

  @override
  Future<NoteDto> updateNote(int id, NoteDto note) async {
    try {
      final response = await apiClient.put<NoteDto>(
        '/notes/$id',
        body: note.toJson(),
        fromJson: NoteDto.fromJson,
      );
      return response;
    } catch (e) {
      throw ApiException('Failed to update note with id $id: $e');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await apiClient.delete('/notes/$id');
    } catch (e) {
      throw ApiException('Failed to delete note with id $id: $e');
    }
  }
}
