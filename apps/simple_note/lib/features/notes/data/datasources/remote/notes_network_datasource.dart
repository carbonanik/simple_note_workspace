import 'package:dio/dio.dart';
import 'package:simple_note/core/network/exception/api_exception.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_api_service.dart';

class NotesNetworkDataSource {
  final NotesApiService apiService;

  NotesNetworkDataSource(this.apiService);

  Future<List<NetworkNoteModel>> getNotes() async {
    try {
      final response = await apiService.getNotes();

      return response.data!;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<NetworkNoteModel?> getNoteById(int id) async {
    try {
      final response = await apiService.getNoteById(id);

      return response.data;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<NetworkNoteModel> createNote(NetworkNoteModel note) async {
    try {
      final response = await apiService.createNote(note.toJson());

      return response.data!;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> updateNote(NetworkNoteModel note) async {
    try {
      await apiService.updateNote(note.id!, note.toJson());
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await apiService.deleteNote(id);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(Object e) {
    if (e is DioException) {
      print('----');
      print(e.response);
      print(e.message);
      print(e.error);
      // return ApiException.fromDioError(e);
    }
    // return ApiException(
    // message: 'An unexpected error occurred: ${e.toString()}',
    // );

    return e as Exception;
  }
}
