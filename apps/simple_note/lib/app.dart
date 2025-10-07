import 'package:flutter/material.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/features/notes/presentation/controllers/notes_controller.dart';
import 'package:simple_note/features/notes/presentation/pages/notes_page.dart';
import 'package:simple_state/simple_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateProvider(
      notifier: NotesController(SL().get()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: NotesPage(),
      ),
    );
  }
}
