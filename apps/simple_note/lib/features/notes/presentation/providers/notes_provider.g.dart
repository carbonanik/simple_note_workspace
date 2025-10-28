// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotesNotifier)
const notesProvider = NotesNotifierProvider._();

final class NotesNotifierProvider
    extends $AsyncNotifierProvider<NotesNotifier, List<NoteEntity>> {
  const NotesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesNotifierHash();

  @$internal
  @override
  NotesNotifier create() => NotesNotifier();
}

String _$notesNotifierHash() => r'2e01757bbb29610dc94b1a399437c55cc11dd03e';

abstract class _$NotesNotifier extends $AsyncNotifier<List<NoteEntity>> {
  FutureOr<List<NoteEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<NoteEntity>>, List<NoteEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<NoteEntity>>, List<NoteEntity>>,
              AsyncValue<List<NoteEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(noteDetail)
const noteDetailProvider = NoteDetailFamily._();

final class NoteDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<NoteEntity?>,
          NoteEntity?,
          FutureOr<NoteEntity?>
        >
    with $FutureModifier<NoteEntity?>, $FutureProvider<NoteEntity?> {
  const NoteDetailProvider._({
    required NoteDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'noteDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteDetailHash();

  @override
  String toString() {
    return r'noteDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NoteEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NoteEntity?> create(Ref ref) {
    final argument = this.argument as int;
    return noteDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteDetailHash() => r'f58fe352d4071a36e347311ae3bda1809f581476';

final class NoteDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NoteEntity?>, int> {
  const NoteDetailFamily._()
    : super(
        retry: null,
        name: r'noteDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NoteDetailProvider call(int noteId) =>
      NoteDetailProvider._(argument: noteId, from: this);

  @override
  String toString() => r'noteDetailProvider';
}
