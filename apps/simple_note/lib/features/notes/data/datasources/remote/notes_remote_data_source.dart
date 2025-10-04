import 'package:simple_note/core/network/api_client.dart';
import 'package:simple_note/core/network/api_response.dart';
import 'package:simple_note/features/notes/data/datasources/remote/note_model.dart';

abstract interface class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> getNoteById(int id);
  Future<NoteModel> createNote(NoteModel note);
  Future<NoteModel> updateNote(int id, NoteModel note);
  Future<void> deleteNote(int id);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiClient apiClient;

  NotesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await apiClient.get<ApiResponse<List<NoteModel>>>(
        '/notes/',
        fromJson: (value) {
          return ApiResponse.fromJson(value, (data) {
            return (data as List)
                .map((item) => NoteModel.fromJson(item))
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
  Future<NoteModel> getNoteById(int id) async {
    try {
      final response = await apiClient.get<NoteModel>(
        '/notes/$id',
        fromJson: NoteModel.fromJson,
      );
      return response;
    } catch (e) {
      throw ApiException('Failed to fetch note with id $id: $e');
    }
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      final response = await apiClient.post<NoteModel>(
        '/notes/',
        body: note.toCreateJson(),
        fromJson: NoteModel.fromJson,
      );
      return response;
    } catch (e) {
      throw ApiException('Failed to create note: $e');
    }
  }

  @override
  Future<NoteModel> updateNote(int id, NoteModel note) async {
    try {
      final response = await apiClient.put<NoteModel>(
        '/notes/$id',
        body: note.toJson(),
        fromJson: NoteModel.fromJson,
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
