import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_note/features/notes/presentation/pages/notes_page.dart';

void main() {
  testWidgets('NotesPage shows all notes in grid', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesPage()));

    // Verify AppBar title
    expect(find.text('Notes'), findsOneWidget);

    // Verify all notes are displayed
    expect(find.text('Note 1'), findsOneWidget);
    expect(find.text('Content 1'), findsOneWidget);

    expect(find.text('Note 2'), findsOneWidget);
    expect(find.text('Content 2'), findsOneWidget);

    expect(find.text('Note 3'), findsOneWidget);
    expect(find.text('Content 3'), findsOneWidget);

    // Grid layout check: ensures cards exist
    expect(find.byType(Card), findsNWidgets(3));
  });
}
