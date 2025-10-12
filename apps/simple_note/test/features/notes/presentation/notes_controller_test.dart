import 'package:flutter_test/flutter_test.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';
import 'package:simple_note/features/notes/presentation/controllers/notes_controller.dart';

class MockNotesRepository implements NotesRepository {
  List<NoteEntity> _notes = [];
  bool _shouldThrowError = false;
  String _errorMessage = 'Mock error occurred';
  Duration _delay = Duration.zero;

  void setNotes(List<NoteEntity> notes) {
    _notes = List.from(notes);
  }

  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    if (message != null) {
      _errorMessage = message;
    }
  }

  void setDelay(Duration delay) {
    _delay = delay;
  }

  void reset() {
    _notes = [];
    _shouldThrowError = false;
    _errorMessage = 'Mock error occurred';
    _delay = Duration.zero;
  }

  Future<void> _simulateDelay() async {
    if (_delay > Duration.zero) {
      await Future.delayed(_delay);
    }
  }

  void _checkError() {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    await _simulateDelay();
    _checkError();
    return List.from(_notes);
  }

  @override
  Future<int> addNote(NoteEntity note) async {
    await _simulateDelay();
    _checkError();
    _notes.add(note);
    return note.id!;
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await _simulateDelay();
    _checkError();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    } else {
      throw Exception('Note with id ${note.id} not found');
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    await _simulateDelay();
    _checkError();
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes.removeAt(index);
    } else {
      throw Exception('Note with id $id not found');
    }
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    await _simulateDelay();
    _checkError();
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  int get callCount => _notes.length;
}

void main() {
  late MockNotesRepository mockRepository;
  late NotesController controller;

  setUp(() {
    mockRepository = MockNotesRepository();
    controller = NotesController(mockRepository);
  });

  tearDown(() {
    controller.dispose();
    mockRepository.reset();
  });

  // group('NotesController -', () {
  //   test('initial state is initial', () {
  //     expect(controller.status, NotesStatus.initial);
  //     expect(controller.notes.isEmpty, true);
  //     expect(controller.errorMessage, null);
  //   });

  //   test('loads notes successfully', () async {
  //     // Arrange
  //     final testNotes = [
  //       NoteEntity(id: 1, title: 'Test Note', content: 'Test Content'),
  //     ];
  //     mockRepository.setNotes(testNotes);

  //     // Act
  //     controller.getNotes();
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.isSuccess, true);
  //     expect(controller.notes.length, 1);
  //     expect(controller.notes.first.title, 'Test Note');
  //   });

  //   test('shows loading state when loading notes', () async {
  //     // Arrange
  //     final note = NoteEntity(
  //       id: 1,
  //       title: 'Test Note',
  //       content: 'Test Content',
  //     );
  //     mockRepository.setNotes([note]);
  //     mockRepository.setDelay(Duration(milliseconds: 100));

  //     // Act
  //     controller.getNotes();

  //     // Assert
  //     expect(controller.isLoading, true);
  //     expect(controller.notes.length, 0);
  //     await Future.delayed(Duration(milliseconds: 200));
  //     expect(controller.isLoading, false);
  //     expect(controller.isSuccess, true);
  //     expect(controller.notes.length, 1);
  //   });

  //   test('handles error when loading notes fails', () async {
  //     // Arrange
  //     mockRepository.setShouldThrowError(true, 'Network error');

  //     // Act
  //     controller.getNotes();
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.hasError, true);
  //     expect(controller.errorMessage, contains('Network error'));
  //   });

  //   test('adds note successfully', () async {
  //     // Arrange
  //     mockRepository.setNotes([]);
  //     final newNote = NoteEntity(
  //       id: 2,
  //       title: 'New Note',
  //       content: 'New Content',
  //     );

  //     // Act
  //     await controller.addNote(newNote);
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.notes.length, 1);
  //     expect(controller.notes.first.title, 'New Note');
  //     expect(controller.isSuccess, true);
  //   });

  //   test('handles error when adding note fails', () async {
  //     // Arrange
  //     mockRepository.setNotes([]);
  //     mockRepository.setShouldThrowError(true, 'Failed to add note');

  //     final newNote = NoteEntity(
  //       id: 2,
  //       title: 'New Note',
  //       content: 'New Content',
  //     );

  //     // Act
  //     await controller.addNote(newNote);
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.hasError, true);
  //     expect(controller.errorMessage, contains('Failed to add note'));
  //   });

  //   test('updates note successfully', () async {
  //     // Arrange
  //     final initialNote = NoteEntity(
  //       id: 1,
  //       title: 'Original',
  //       content: 'Original Content',
  //     );
  //     mockRepository.setNotes([initialNote]);

  //     final updatedNote = NoteEntity(
  //       id: 1,
  //       title: 'Updated',
  //       content: 'Updated Content',
  //     );

  //     // Act
  //     await controller.updateNote(updatedNote);
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.notes.first.title, 'Updated');
  //     expect(controller.notes.first.content, 'Updated Content');
  //   });

  //   test('deletes note successfully', () async {
  //     // Arrange
  //     final notes = [
  //       NoteEntity(id: 1, title: 'Note 1', content: 'Content 1'),
  //       NoteEntity(id: 2, title: 'Note 2', content: 'Content 2'),
  //     ];
  //     mockRepository.setNotes(notes);

  //     // Act
  //     await controller.deleteNote(1);
  //     await Future.delayed(Duration.zero);

  //     // Assert
  //     expect(controller.notes.length, 1);
  //     expect(controller.notes.first.id, '2');
  //   });

  //   test('simulates network delay', () async {
  //     // Arrange
  //     mockRepository.setDelay(Duration(milliseconds: 100));
  //     mockRepository.setNotes([]);

  //     // Act
  //     final stopwatch = Stopwatch()..start();
  //     await controller.getNotes();
  //     stopwatch.stop();

  //     // Assert
  //     expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
  //     expect(controller.isSuccess, true);
  //   });
  // });
}
