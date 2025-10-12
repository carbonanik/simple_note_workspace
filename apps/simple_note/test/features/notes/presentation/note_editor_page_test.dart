import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/presentation/pages/note_editor_page.dart';

void main() {
  // final note = NoteEntity(id: 10, title: 'My Note', content: 'Some content');

  testWidgets('NoteEditorPage loads note data into text fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: NoteEditorFlow()));

    // Check AppBar title
    expect(find.text('Note Editor'), findsOneWidget);

    // Fields contain note data
    expect(find.widgetWithText(TextField, 'My Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Some content'), findsOneWidget);
  });
}
