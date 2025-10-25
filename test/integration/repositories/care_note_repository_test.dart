import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/repositories/drift/care_note_repository.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';

import '../test_database_helper.dart';
import '../../helpers/test_date_utils.dart';

/// Integration tests for CareNoteRepository (Drift version).
///
/// These tests use a real in-memory database to test the full stack
/// from repository through to actual database operations.
void main() {
  late AppDatabase database;
  late CareNoteRepository careNoteRepo;
  late SquirrelRepository squirrelRepo;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    careNoteRepo = CareNoteRepository(database);
    squirrelRepo = SquirrelRepository(database);
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('CareNoteRepository - Add Care Note', () {
    test('should add care note successfully', () async {
      // Add squirrel first
      final squirrel = Squirrel.create(name: 'Nutkin', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add care note
      final note = CareNote.create(
        squirrelId: squirrel.id,
        content: 'First medical checkup completed',
        noteType: CareNoteType.medical,
      );

      await careNoteRepo.addCareNote(note);

      // Verify
      final retrievedNote = await careNoteRepo.getCareNote(note.id);
      expect(retrievedNote, isNotNull);
      expect(retrievedNote!.content, equals('First medical checkup completed'));
      expect(retrievedNote.noteType, equals(CareNoteType.medical));
      expect(retrievedNote.squirrelId, equals(squirrel.id));
    });

    test('should persist all care note fields correctly', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final createdAt = dateWithTime(12, 10, 30);
      final note = CareNote(
        id: 'note-1',
        squirrelId: squirrel.id,
        content: 'Important medical observation',
        noteType: CareNoteType.medical,
        createdAt: createdAt,
        photoPath: '/path/to/photo.jpg',
        isImportant: true,
      );

      await careNoteRepo.addCareNote(note);

      final retrieved = await careNoteRepo.getCareNote(note.id);
      expect(retrieved!.id, equals('note-1'));
      expect(retrieved.content, equals('Important medical observation'));
      expect(retrieved.noteType, equals(CareNoteType.medical));
      expect(retrieved.photoPath, equals('/path/to/photo.jpg'));
      expect(retrieved.isImportant, isTrue);
      expect(retrieved.createdAt, equals(createdAt));
    });

    test('should throw when adding note for non-existent squirrel', () async {
      final note = CareNote.create(
        squirrelId: 'non-existent-id',
        content: 'This should fail',
        noteType: CareNoteType.general,
      );

      expect(
        () => careNoteRepo.addCareNote(note),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CareNoteRepository - Query Care Notes', () {
    test('should get all care notes for squirrel ordered by date', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add multiple notes
      final note1 = CareNote(
        id: 'note-1',
        squirrelId: squirrel.id,
        content: 'First note',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(-2, 10, 0),
      );

      final note2 = CareNote(
        id: 'note-2',
        squirrelId: squirrel.id,
        content: 'Second note',
        noteType: CareNoteType.medical,
        createdAt: dateWithTime(-2, 14, 0),
      );

      await careNoteRepo.addCareNote(note1);
      await careNoteRepo.addCareNote(note2);

      final notes = await careNoteRepo.getCareNotes(squirrel.id);

      expect(notes, hasLength(2));
      // Should be ordered newest first
      expect(notes[0].id, equals('note-2'));
      expect(notes[1].id, equals('note-1'));
    });

    test('should return empty list when squirrel has no notes', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final notes = await careNoteRepo.getCareNotes(squirrel.id);

      expect(notes, isEmpty);
    });

    test('should get care notes filtered by type', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add notes of different types
      final medicalNote = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Medical note',
        noteType: CareNoteType.medical,
      );

      final behavioralNote = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Behavioral note',
        noteType: CareNoteType.behavioral,
      );

      final generalNote = CareNote.create(
        squirrelId: squirrel.id,
        content: 'General note',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(medicalNote);
      await careNoteRepo.addCareNote(behavioralNote);
      await careNoteRepo.addCareNote(generalNote);

      // Get only medical notes
      final medicalNotes = await careNoteRepo.getCareNotesByType(
        squirrel.id,
        CareNoteType.medical,
      );

      expect(medicalNotes, hasLength(1));
      expect(medicalNotes.first.content, equals('Medical note'));
    });

    test('should get only important care notes', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add important and regular notes
      final importantNote = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Important note',
        noteType: CareNoteType.medical,
        isImportant: true,
      );

      final regularNote = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Regular note',
        noteType: CareNoteType.general,
        isImportant: false,
      );

      await careNoteRepo.addCareNote(importantNote);
      await careNoteRepo.addCareNote(regularNote);

      final importantNotes = await careNoteRepo.getImportantCareNotes(
        squirrel.id,
      );

      expect(importantNotes, hasLength(1));
      expect(importantNotes.first.content, equals('Important note'));
      expect(importantNotes.first.isImportant, isTrue);
    });

    test('should get recent care notes across all squirrels', () async {
      // Add two squirrels
      final squirrel1 = Squirrel.create(
        name: 'Squirrel 1',
        foundDate: daysAgo(2),
      );
      final squirrel2 = Squirrel.create(
        name: 'Squirrel 2',
        foundDate: daysAgo(2),
      );

      await squirrelRepo.addSquirrel(squirrel1);
      await squirrelRepo.addSquirrel(squirrel2);

      // Add notes for both
      final note1 = CareNote(
        id: 'note-1',
        squirrelId: squirrel1.id,
        content: 'Note from squirrel 1',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(-2, 10, 0),
      );

      final note2 = CareNote(
        id: 'note-2',
        squirrelId: squirrel2.id,
        content: 'Note from squirrel 2',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(-2, 14, 0),
      );

      await careNoteRepo.addCareNote(note1);
      await careNoteRepo.addCareNote(note2);

      final recentNotes = await careNoteRepo.getRecentCareNotes(limit: 10);

      expect(recentNotes, hasLength(2));
      // Should be ordered newest first
      expect(recentNotes[0].squirrelId, equals(squirrel2.id));
      expect(recentNotes[1].squirrelId, equals(squirrel1.id));
    });

    test('should respect limit when getting recent notes', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add 5 notes
      for (int i = 0; i < 5; i++) {
        final note = CareNote(
          id: 'note-$i',
          squirrelId: squirrel.id,
          content: 'Note $i',
          noteType: CareNoteType.general,
          createdAt: dateWithTime(-2, 10 + i, 0),
        );
        await careNoteRepo.addCareNote(note);
      }

      final recentNotes = await careNoteRepo.getRecentCareNotes(limit: 3);

      expect(recentNotes, hasLength(3));
    });
  });

  group('CareNoteRepository - Date Range Queries', () {
    test('should get care notes within date range', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add notes on different days
      final note1 = CareNote(
        id: 'note-1',
        squirrelId: squirrel.id,
        content: 'Note 1',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(7, 10, 0),
      );

      final note2 = CareNote(
        id: 'note-2',
        squirrelId: squirrel.id,
        content: 'Note 2',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(12, 10, 0),
      );

      final note3 = CareNote(
        id: 'note-3',
        squirrelId: squirrel.id,
        content: 'Note 3',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(17, 10, 0),
      );

      await careNoteRepo.addCareNote(note1);
      await careNoteRepo.addCareNote(note2);
      await careNoteRepo.addCareNote(note3);

      // Query for notes between Jan 12 and Jan 18
      final notes = await careNoteRepo.getCareNotesInRange(
        squirrel.id,
        daysFromNow(9),
        daysFromNow(15),
      );

      expect(notes, hasLength(1));
      expect(notes.first.id, equals('note-2'));
    });

    test('should return empty list when no notes in range', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final note = CareNote(
        id: 'note-1',
        squirrelId: squirrel.id,
        content: 'Note 1',
        noteType: CareNoteType.general,
        createdAt: dateWithTime(7, 10, 0),
      );

      await careNoteRepo.addCareNote(note);

      // Query for different date range
      final notes = await careNoteRepo.getCareNotesInRange(
        squirrel.id,
        daysFromNow(29),
        daysFromNow(56),
      );

      expect(notes, isEmpty);
    });
  });

  group('CareNoteRepository - Search', () {
    test('should search care notes by content', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add notes with different content
      final note1 = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Weight increased significantly',
        noteType: CareNoteType.general,
      );

      final note2 = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Started eating solid food',
        noteType: CareNoteType.feeding,
      );

      final note3 = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Weight stable this week',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(note1);
      await careNoteRepo.addCareNote(note2);
      await careNoteRepo.addCareNote(note3);

      // Search for "weight"
      final results = await careNoteRepo.searchCareNotes(squirrel.id, 'weight');

      expect(results, hasLength(2));
      expect(
        results.every((n) => n.content.toLowerCase().contains('weight')),
        isTrue,
      );
    });

    test('should search across all squirrels', () async {
      final squirrel1 = Squirrel.create(
        name: 'Squirrel 1',
        foundDate: daysAgo(2),
      );
      final squirrel2 = Squirrel.create(
        name: 'Squirrel 2',
        foundDate: daysAgo(2),
      );

      await squirrelRepo.addSquirrel(squirrel1);
      await squirrelRepo.addSquirrel(squirrel2);

      final note1 = CareNote.create(
        squirrelId: squirrel1.id,
        content: 'Medical checkup completed',
        noteType: CareNoteType.medical,
      );

      final note2 = CareNote.create(
        squirrelId: squirrel2.id,
        content: 'Medical treatment ongoing',
        noteType: CareNoteType.medical,
      );

      final note3 = CareNote.create(
        squirrelId: squirrel1.id,
        content: 'Behavioral improvement noted',
        noteType: CareNoteType.behavioral,
      );

      await careNoteRepo.addCareNote(note1);
      await careNoteRepo.addCareNote(note2);
      await careNoteRepo.addCareNote(note3);

      final results = await careNoteRepo.searchAllCareNotes('medical');

      expect(results, hasLength(2));
    });

    test('should return empty list when no matches found', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final note = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Regular observation',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(note);

      final results = await careNoteRepo.searchCareNotes(
        squirrel.id,
        'medical',
      );

      expect(results, isEmpty);
    });
  });

  group('CareNoteRepository - Filter by Photos', () {
    test('should get only care notes with photos', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add notes with and without photos
      final noteWithPhoto = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Note with photo',
        noteType: CareNoteType.general,
        photoPath: '/path/to/photo.jpg',
      );

      final noteWithoutPhoto = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Note without photo',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(noteWithPhoto);
      await careNoteRepo.addCareNote(noteWithoutPhoto);

      final notesWithPhotos = await careNoteRepo.getCareNotesWithPhotos(
        squirrel.id,
      );

      expect(notesWithPhotos, hasLength(1));
      expect(notesWithPhotos.first.photoPath, isNotNull);
    });
  });

  group('CareNoteRepository - Analytics', () {
    test('should get care note counts by type', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add notes of different types
      await careNoteRepo.addCareNote(
        CareNote.create(
          squirrelId: squirrel.id,
          content: 'Medical 1',
          noteType: CareNoteType.medical,
        ),
      );

      await careNoteRepo.addCareNote(
        CareNote.create(
          squirrelId: squirrel.id,
          content: 'Medical 2',
          noteType: CareNoteType.medical,
        ),
      );

      await careNoteRepo.addCareNote(
        CareNote.create(
          squirrelId: squirrel.id,
          content: 'Behavioral 1',
          noteType: CareNoteType.behavioral,
        ),
      );

      final counts = await careNoteRepo.getCareNoteCountsByType(squirrel.id);

      expect(counts[CareNoteType.medical], equals(2));
      expect(counts[CareNoteType.behavioral], equals(1));
    });
  });

  group('CareNoteRepository - Update', () {
    test('should update care note successfully', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final original = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Original content',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(original);

      // Update
      final updated = original.copyWith(
        content: 'Updated content',
        isImportant: true,
      );

      final success = await careNoteRepo.updateCareNote(updated);

      expect(success, isTrue);

      final retrieved = await careNoteRepo.getCareNote(original.id);
      expect(retrieved!.content, equals('Updated content'));
      expect(retrieved.isImportant, isTrue);
    });

    test('should return false when updating non-existent note', () async {
      final note = CareNote(
        id: 'non-existent',
        squirrelId: 'sq-1',
        content: 'Test',
        noteType: CareNoteType.general,
        createdAt: DateTime.now(),
      );

      final success = await careNoteRepo.updateCareNote(note);

      expect(success, isFalse);
    });
  });

  group('CareNoteRepository - Delete', () {
    test('should delete care note successfully', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final note = CareNote.create(
        squirrelId: squirrel.id,
        content: 'To be deleted',
        noteType: CareNoteType.general,
      );

      await careNoteRepo.addCareNote(note);

      // Verify exists
      var retrieved = await careNoteRepo.getCareNote(note.id);
      expect(retrieved, isNotNull);

      // Delete
      final success = await careNoteRepo.deleteCareNote(note.id);

      expect(success, isTrue);

      // Verify deleted
      retrieved = await careNoteRepo.getCareNote(note.id);
      expect(retrieved, isNull);
    });

    test('should return false when deleting non-existent note', () async {
      final success = await careNoteRepo.deleteCareNote('non-existent-id');

      expect(success, isFalse);
    });

    test('should delete all care notes for squirrel', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add multiple notes
      for (int i = 0; i < 3; i++) {
        await careNoteRepo.addCareNote(
          CareNote.create(
            squirrelId: squirrel.id,
            content: 'Note $i',
            noteType: CareNoteType.general,
          ),
        );
      }

      // Verify notes exist
      var notes = await careNoteRepo.getCareNotes(squirrel.id);
      expect(notes, hasLength(3));

      // Delete all notes for squirrel
      final deletedCount = await careNoteRepo.deleteCareNotesForSquirrel(
        squirrel.id,
      );

      expect(deletedCount, equals(3));

      // Verify all deleted
      notes = await careNoteRepo.getCareNotes(squirrel.id);
      expect(notes, isEmpty);
    });
  });

  group('CareNoteRepository - Reactive Streams', () {
    test('should watch care notes for squirrel', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final stream = careNoteRepo.watchCareNotes(squirrel.id);

      final notes = <List<CareNote>>[];
      final subscription = stream.listen((data) {
        notes.add(data);
      });

      // Wait for initial empty state
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notes.last, isEmpty);

      // Add a note
      final note = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Test note',
        noteType: CareNoteType.general,
      );
      await careNoteRepo.addCareNote(note);

      // Wait for stream update
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notes.last, hasLength(1));

      await subscription.cancel();
    });

    test('should watch important care notes only', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final stream = careNoteRepo.watchImportantCareNotes(squirrel.id);

      final notes = <List<CareNote>>[];
      final subscription = stream.listen((data) {
        notes.add(data);
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Add regular note (should not appear in stream)
      await careNoteRepo.addCareNote(
        CareNote.create(
          squirrelId: squirrel.id,
          content: 'Regular note',
          noteType: CareNoteType.general,
          isImportant: false,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(notes.last, isEmpty);

      // Add important note (should appear)
      await careNoteRepo.addCareNote(
        CareNote.create(
          squirrelId: squirrel.id,
          content: 'Important note',
          noteType: CareNoteType.medical,
          isImportant: true,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(notes.last, hasLength(1));
      expect(notes.last.first.isImportant, isTrue);

      await subscription.cancel();
    });

    test('should watch single care note by ID', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final note = CareNote.create(
        squirrelId: squirrel.id,
        content: 'Original content',
        noteType: CareNoteType.general,
      );
      await careNoteRepo.addCareNote(note);

      final stream = careNoteRepo.watchCareNote(note.id);

      final updates = <CareNote?>[];
      final subscription = stream.listen((data) {
        updates.add(data);
      });

      await Future.delayed(const Duration(milliseconds: 100));
      expect(updates.last, isNotNull);
      expect(updates.last!.content, equals('Original content'));

      // Update the note
      final updated = note.copyWith(content: 'Updated content');
      await careNoteRepo.updateCareNote(updated);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(updates.last!.content, equals('Updated content'));

      await subscription.cancel();
    });
  });
}
