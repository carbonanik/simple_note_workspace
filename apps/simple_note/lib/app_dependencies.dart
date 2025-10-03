import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/domain/repositories/in_memory_notes_repository.dart';
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
  late final InMemoryNotesRepository notesRepository;
  late final NotesController notesController;

  @override
  void initState() {
    notesRepository = InMemoryNotesRepository();
    notesController = NotesController(notesRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
