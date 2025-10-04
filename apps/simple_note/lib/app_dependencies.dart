import 'package:flutter/material.dart';
import 'package:simple_note/core/network/api_client.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:simple_note/features/notes/domain/repositories/network_note_repository.dart';
import 'package:simple_note/features/notes/presentation/controllers/notes_controller.dart';

class AppDependencies extends StatefulWidget {
  final Widget child;
  const AppDependencies({super.key, required this.child});

  @override
  State<AppDependencies> createState() => _AppDependenciesState();

  static NotesController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppDependenciesState>();
    if (state == null) {
      throw Exception('No AppDependencies found in context');
    } else {
      return state.notesController;
    }
  }
}

class _AppDependenciesState extends State<AppDependencies> {
  late final ApiClient apiClient;
  late final NotesRemoteDataSource dataSource;
  late final NetworkNotesRepository notesRepository;
  late final NotesController notesController;

  @override
  void initState() {
    apiClient = HttpApiClient(baseUrl: 'http://localhost:8000/v1/');
    dataSource = NotesRemoteDataSourceImpl(apiClient);
    notesRepository = NetworkNotesRepository(dataSource);
    notesController = NotesController(notesRepository);
    notesController.getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
