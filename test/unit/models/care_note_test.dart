import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/models/care_note.dart';

void main() {
  group('CareNoteType', () {
    test('should have correct value and display name for each type', () {
      expect(CareNoteType.medical.value, equals('medical'));
      expect(CareNoteType.medical.displayName, equals('Medical'));

      expect(CareNoteType.behavioral.value, equals('behavioral'));
      expect(CareNoteType.behavioral.displayName, equals('Behavioral'));

      expect(CareNoteType.feeding.value, equals('feeding'));
      expect(CareNoteType.feeding.displayName, equals('Feeding'));

      expect(CareNoteType.development.value, equals('development'));
      expect(CareNoteType.development.displayName, equals('Development'));

      expect(CareNoteType.general.value, equals('general'));
      expect(CareNoteType.general.displayName, equals('General'));

      expect(CareNoteType.release.value, equals('release'));
      expect(CareNoteType.release.displayName, equals('Release Prep'));
    });

    test('should parse valid care note type from string', () {
      expect(CareNoteType.fromString('medical'), equals(CareNoteType.medical));
      expect(
        CareNoteType.fromString('behavioral'),
        equals(CareNoteType.behavioral),
      );
      expect(CareNoteType.fromString('feeding'), equals(CareNoteType.feeding));
      expect(
        CareNoteType.fromString('development'),
        equals(CareNoteType.development),
      );
      expect(CareNoteType.fromString('general'), equals(CareNoteType.general));
      expect(CareNoteType.fromString('release'), equals(CareNoteType.release));
    });

    test('should default to general for invalid type string', () {
      expect(CareNoteType.fromString('invalid'), equals(CareNoteType.general));
      expect(CareNoteType.fromString(''), equals(CareNoteType.general));
    });

    test('should convert to display name in toString', () {
      expect(CareNoteType.medical.toString(), equals('Medical'));
      expect(CareNoteType.behavioral.toString(), equals('Behavioral'));
      expect(CareNoteType.feeding.toString(), equals('Feeding'));
    });
  });

  group('CareNote - Factory Constructor', () {
    test('should create care note with generated UUID', () {
      final note1 = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test note',
        noteType: CareNoteType.medical,
      );

      final note2 = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test note',
        noteType: CareNoteType.medical,
      );

      // Should have different IDs
      expect(note1.id, isNot(equals(note2.id)));
      // IDs should be non-empty strings
      expect(note1.id, isNotEmpty);
      expect(note2.id, isNotEmpty);
    });

    test('should create care note with current timestamp', () {
      final before = DateTime.now();
      final note = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test note',
        noteType: CareNoteType.general,
      );
      final after = DateTime.now();

      expect(
        note.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        note.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should create care note with provided fields', () {
      final note = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test medical note',
        noteType: CareNoteType.medical,
        photoPath: '/path/to/photo.jpg',
        isImportant: true,
      );

      expect(note.squirrelId, equals('sq-1'));
      expect(note.content, equals('Test medical note'));
      expect(note.noteType, equals(CareNoteType.medical));
      expect(note.photoPath, equals('/path/to/photo.jpg'));
      expect(note.isImportant, isTrue);
    });

    test('should default isImportant to false when not provided', () {
      final note = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test note',
        noteType: CareNoteType.general,
      );

      expect(note.isImportant, isFalse);
    });

    test('should allow null photoPath', () {
      final note = CareNote.create(
        squirrelId: 'sq-1',
        content: 'Test note',
        noteType: CareNoteType.general,
      );

      expect(note.photoPath, isNull);
    });
  });

  group('CareNote - copyWith', () {
    late CareNote originalNote;

    setUp(() {
      originalNote = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Original content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 1),
        photoPath: '/original/path.jpg',
        isImportant: false,
      );
    });

    test('should create copy with updated content', () {
      final updated = originalNote.copyWith(content: 'Updated content');

      expect(updated.content, equals('Updated content'));
      expect(updated.id, equals(originalNote.id));
      expect(updated.squirrelId, equals(originalNote.squirrelId));
      expect(updated.noteType, equals(originalNote.noteType));
    });

    test('should create copy with updated noteType', () {
      final updated = originalNote.copyWith(noteType: CareNoteType.behavioral);

      expect(updated.noteType, equals(CareNoteType.behavioral));
      expect(updated.content, equals(originalNote.content));
    });

    test('should create copy with updated isImportant', () {
      final updated = originalNote.copyWith(isImportant: true);

      expect(updated.isImportant, isTrue);
      expect(originalNote.isImportant, isFalse); // Original unchanged
    });

    test('should create copy with updated photoPath', () {
      final updated = originalNote.copyWith(photoPath: '/new/path.jpg');

      expect(updated.photoPath, equals('/new/path.jpg'));
    });

    test('should create copy with multiple updated fields', () {
      final updated = originalNote.copyWith(
        content: 'New content',
        noteType: CareNoteType.development,
        isImportant: true,
      );

      expect(updated.content, equals('New content'));
      expect(updated.noteType, equals(CareNoteType.development));
      expect(updated.isImportant, isTrue);
      expect(updated.id, equals(originalNote.id)); // ID unchanged
    });

    test('should create exact copy when no parameters provided', () {
      final copy = originalNote.copyWith();

      expect(copy.id, equals(originalNote.id));
      expect(copy.squirrelId, equals(originalNote.squirrelId));
      expect(copy.content, equals(originalNote.content));
      expect(copy.noteType, equals(originalNote.noteType));
      expect(copy.createdAt, equals(originalNote.createdAt));
      expect(copy.photoPath, equals(originalNote.photoPath));
      expect(copy.isImportant, equals(originalNote.isImportant));
    });
  });

  group('CareNote - JSON Serialization', () {
    test('should serialize to JSON correctly with all fields', () {
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Test content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 15, 10, 30),
        photoPath: '/path/to/photo.jpg',
        isImportant: true,
      );

      final json = note.toJson();

      expect(json['id'], equals('note-1'));
      expect(json['squirrel_id'], equals('sq-1'));
      expect(json['content'], equals('Test content'));
      expect(json['note_type'], equals('medical'));
      expect(json['created_at'], equals('2025-01-15T10:30:00.000'));
      expect(json['photo_path'], equals('/path/to/photo.jpg'));
      expect(json['is_important'], isTrue);
    });

    test('should serialize to JSON correctly with null photoPath', () {
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Test content',
        noteType: CareNoteType.general,
        createdAt: DateTime(2025, 1, 15),
        isImportant: false,
      );

      final json = note.toJson();

      expect(json['photo_path'], isNull);
      expect(json['is_important'], isFalse);
    });

    test('should deserialize from JSON correctly with all fields', () {
      final json = {
        'id': 'note-1',
        'squirrel_id': 'sq-1',
        'content': 'Test content',
        'note_type': 'behavioral',
        'created_at': '2025-01-15T10:30:00.000',
        'photo_path': '/path/to/photo.jpg',
        'is_important': true,
      };

      final note = CareNote.fromJson(json);

      expect(note.id, equals('note-1'));
      expect(note.squirrelId, equals('sq-1'));
      expect(note.content, equals('Test content'));
      expect(note.noteType, equals(CareNoteType.behavioral));
      expect(note.createdAt, equals(DateTime(2025, 1, 15, 10, 30)));
      expect(note.photoPath, equals('/path/to/photo.jpg'));
      expect(note.isImportant, isTrue);
    });

    test('should deserialize from JSON with null photoPath', () {
      final json = {
        'id': 'note-1',
        'squirrel_id': 'sq-1',
        'content': 'Test content',
        'note_type': 'general',
        'created_at': '2025-01-15T10:30:00.000',
        'photo_path': null,
        'is_important': false,
      };

      final note = CareNote.fromJson(json);

      expect(note.photoPath, isNull);
      expect(note.isImportant, isFalse);
    });

    test('should default isImportant to false when missing from JSON', () {
      final json = {
        'id': 'note-1',
        'squirrel_id': 'sq-1',
        'content': 'Test content',
        'note_type': 'general',
        'created_at': '2025-01-15T10:30:00.000',
      };

      final note = CareNote.fromJson(json);

      expect(note.isImportant, isFalse);
    });

    test('should round-trip through JSON serialization correctly', () {
      final original = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Round trip test',
        noteType: CareNoteType.development,
        createdAt: DateTime(2025, 1, 15, 10, 30),
        photoPath: '/path/to/photo.jpg',
        isImportant: true,
      );

      final json = original.toJson();
      final deserialized = CareNote.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.squirrelId, equals(original.squirrelId));
      expect(deserialized.content, equals(original.content));
      expect(deserialized.noteType, equals(original.noteType));
      expect(deserialized.createdAt, equals(original.createdAt));
      expect(deserialized.photoPath, equals(original.photoPath));
      expect(deserialized.isImportant, equals(original.isImportant));
    });
  });

  group('CareNote - Equality and HashCode', () {
    test('should be equal when IDs match', () {
      final note1 = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Content 1',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 1),
      );

      final note2 = CareNote(
        id: 'note-1',
        squirrelId: 'sq-2',
        content: 'Content 2',
        noteType: CareNoteType.behavioral,
        createdAt: DateTime(2025, 1, 2),
      );

      expect(note1, equals(note2));
      expect(note1.hashCode, equals(note2.hashCode));
    });

    test('should not be equal when IDs differ', () {
      final note1 = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 1),
      );

      final note2 = CareNote(
        id: 'note-2',
        squirrelId: 'sq-1',
        content: 'Content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(note1, isNot(equals(note2)));
    });

    test('should be equal to itself', () {
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(note, equals(note));
      expect(identical(note, note), isTrue);
    });
  });

  group('CareNote - toString', () {
    test('should provide readable string representation', () {
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Test content',
        noteType: CareNoteType.medical,
        createdAt: DateTime(2025, 1, 15),
        isImportant: true,
      );

      final string = note.toString();

      expect(string, contains('note-1'));
      expect(string, contains('sq-1'));
      expect(string, contains('Medical'));
      expect(string, contains('true'));
    });
  });

  group('CareNote - Validation and Edge Cases', () {
    test('should handle empty content', () {
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: '',
        noteType: CareNoteType.general,
        createdAt: DateTime.now(),
      );

      expect(note.content, isEmpty);
    });

    test('should handle very long content', () {
      final longContent = 'A' * 10000;
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: longContent,
        noteType: CareNoteType.general,
        createdAt: DateTime.now(),
      );

      expect(note.content, equals(longContent));
      expect(note.content.length, equals(10000));
    });

    test('should handle special characters in content', () {
      final specialContent = 'Test\n\twith\r\nspecial "chars" & symbols: @#\$%';
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: specialContent,
        noteType: CareNoteType.general,
        createdAt: DateTime.now(),
      );

      expect(note.content, equals(specialContent));
    });

    test('should handle date edge cases', () {
      final veryOldDate = DateTime(1970, 1, 1);
      final note = CareNote(
        id: 'note-1',
        squirrelId: 'sq-1',
        content: 'Old note',
        noteType: CareNoteType.general,
        createdAt: veryOldDate,
      );

      expect(note.createdAt, equals(veryOldDate));

      final json = note.toJson();
      final deserialized = CareNote.fromJson(json);
      expect(deserialized.createdAt, equals(veryOldDate));
    });
  });
}
