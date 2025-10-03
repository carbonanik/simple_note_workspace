import 'package:flutter/material.dart';
import 'package:simple_note/app_dependencies.dart';
import 'package:simple_note/features/notes/presentation/pages/notes_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppDependencies(child: NotesPage()),
    );
  }
}
