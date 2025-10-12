import 'package:simple_note/app_constants.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/core/network/api_client.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:simple_note/features/notes/data/repositories/network_note_repository.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

void initializedDependencies() {
  final di = SL();

  // Config
  di.register(() => AppConstants.baseUrl, key: 'baseUrl');
  di.register<ResponseAdapter>(() => WrappedResponseAdapter());

  // Data Source
  di.registerLazy<ApiClient>(
    () => HttpApiClient(
      baseUrl: di.get(key: 'baseUrl'),
      responseAdapter: di.get<ResponseAdapter>(),
    ),
  );
  di.registerLazy<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(di.get()),
  );

  // Repository
  di.registerLazy<NotesRepository>(() => NetworkNotesRepository(di.get()));
}
