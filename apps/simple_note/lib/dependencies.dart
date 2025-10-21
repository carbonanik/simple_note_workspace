import 'package:simple_note/app_constants.dart';
import 'package:simple_note/core/database/drift_database.dart';
import 'package:simple_note/core/network/dio_client.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/features/notes/data/datasources/local/notes_local_datasource.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_api_service.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_network_datasource.dart';
import 'package:simple_note/features/notes/data/repositories/network_note_repository.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

void initializedDependencies() {
  final di = SL();

  // Data Source
  di.registerLazy(() => AppDatabase());
  di.registerLazy(() => NotesLocalDataSource(di.get()));
  di.registerLazy(
    () => NotesApiService(DioClient.create(baseUrl: AppConstants.baseUrl)),
  );

  di.registerLazy(() => NotesNetworkDataSource(di.get()));

  // Repository
  di.registerLazy<NotesRepository>(() => NetworkNotesRepository(di.get()));
}
