import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_note/core/network/dio_client.dart';
import 'package:simple_note/core/network/model/api_response.dart';
import 'package:simple_note/features/notes/data/models/network_note_model.dart';

part 'notes_api_service.g.dart';

@RestApi()
abstract class NotesApiService {
  factory NotesApiService(Dio dio, {String baseUrl}) = _NotesApiService;

  @GET('/notes')
  Future<ApiResponse<List<NetworkNoteModel>>> getNotes();

  @GET('/notes/{id}')
  Future<ApiResponse<NetworkNoteModel>> getNoteById(@Path('id') int id);

  @POST('/notes')
  Future<ApiResponse<NetworkNoteModel>> createNote(
    @Body() Map<String, dynamic> note,
  );

  @PUT('/notes/{id}')
  Future<ApiResponse<NetworkNoteModel>> updateNote(
    @Path('id') int id,
    @Body() Map<String, dynamic> note,
  );

  @DELETE('/notes/{id}')
  Future<ApiResponse<void>> deleteNote(@Path('id') int id);
}

@riverpod
NotesApiService notesApiService(Ref ref) {
  final dio = ref.read(dioClientProvider);
  return NotesApiService(dio);
}
