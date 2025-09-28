import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_note/features/notes/presentation/pages/notes_page.dart';
import 'package:simple_note/features/notes/presentation/pages/note_editor_page.dart';

void main() {
  final note = NoteEntity(id: '10', title: 'My Note', content: 'Some content');

  testWidgets('NoteEditorPage loads note data into text fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: NoteEditorPage(note: note)));

    // Check AppBar title
    expect(find.text('Note Editor'), findsOneWidget);

    // Fields contain note data
    expect(find.widgetWithText(TextField, 'My Note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Some content'), findsOneWidget);
  });

  testWidgets('Tapping save button navigates back to NotesPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: NoteEditorPage(note: note)));

    // Tap the save button
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Should navigate to NotesPage
    expect(find.byType(NotesPage), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });
}
