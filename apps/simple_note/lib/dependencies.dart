import 'package:simple_note/app_constants.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/core/network/api_client.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:simple_note/features/notes/domain/repositories/in_memory_notes_repository.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

void initializedDependencies() {
  final di = SL();

  // Data Source
  di.registerLazy<ApiClient>(
    () => HttpApiClient(baseUrl: AppConstants.baseUrl),
  );
  di.registerLazy<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(di.get()),
  );

  // Repository
  di.registerLazy<NotesRepository>(() => InMemoryNotesRepository());

  // Controller
  // di.registerLazy<NotesController>(() => NotesController(di.get()));
}
