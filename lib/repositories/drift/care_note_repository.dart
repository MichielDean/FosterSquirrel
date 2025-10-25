import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../models/models.dart';

/// Repository for managing care note data using Drift.
///
/// Provides type-safe database operations for care notes with reactive streams
/// for real-time UI updates.
class CareNoteRepository {
  final AppDatabase _database;

  CareNoteRepository(this._database);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Adds a new care note to the database.
  ///
  /// Validates that the squirrel exists before creating the note.
  /// Returns the ID of the newly created care note.
  ///
  /// Throws [ArgumentError] if the squirrel doesn't exist.
  Future<String> addCareNote(CareNote note) async {
    // Verify squirrel exists
    final squirrel = await (_database.select(
      _database.squirrels,
    )..where((s) => s.id.equals(note.squirrelId))).getSingleOrNull();

    if (squirrel == null) {
      throw ArgumentError('Squirrel with ID ${note.squirrelId} not found');
    }

    final companion = CareNotesCompanion.insert(
      id: note.id,
      squirrelId: note.squirrelId,
      content: note.content,
      noteType: note.noteType.name,
      photoPath: Value(note.photoPath),
      isImportant: Value(note.isImportant ? 1 : 0),
      createdAt: note.createdAt.toIso8601String(),
    );

    await _database.into(_database.careNotes).insert(companion);
    return note.id;
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Gets a single care note by ID.
  ///
  /// Returns null if not found.
  Future<CareNote?> getCareNote(String id) async {
    final careNoteData = await (_database.select(
      _database.careNotes,
    )..where((n) => n.id.equals(id))).getSingleOrNull();

    return careNoteData != null ? _careNoteFromData(careNoteData) : null;
  }

  /// Gets all care notes for a specific squirrel.
  ///
  /// Returns notes ordered by creation date (newest first).
  Future<List<CareNote>> getCareNotes(String squirrelId) async {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.squirrelId.equals(squirrelId))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets care notes filtered by note type for a specific squirrel.
  Future<List<CareNote>> getCareNotesByType(
    String squirrelId,
    CareNoteType type,
  ) async {
    final query = _database.select(_database.careNotes)
      ..where(
        (n) => n.squirrelId.equals(squirrelId) & n.noteType.equals(type.name),
      )
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets all important care notes for a specific squirrel.
  Future<List<CareNote>> getImportantCareNotes(String squirrelId) async {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.squirrelId.equals(squirrelId) & n.isImportant.equals(1))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets the most recent care notes across all squirrels.
  ///
  /// [limit] defaults to 20 notes.
  Future<List<CareNote>> getRecentCareNotes({int limit = 20}) async {
    final query = _database.select(_database.careNotes)
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets care notes within a date range for a specific squirrel.
  Future<List<CareNote>> getCareNotesInRange(
    String squirrelId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();
    final query = _database.select(_database.careNotes)
      ..where(
        (n) =>
            n.squirrelId.equals(squirrelId) &
            n.createdAt.isBiggerOrEqualValue(startStr) &
            n.createdAt.isSmallerOrEqualValue(endStr),
      )
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Searches care notes by content for a specific squirrel.
  ///
  /// Uses case-insensitive LIKE query.
  Future<List<CareNote>> searchCareNotes(
    String squirrelId,
    String searchQuery,
  ) async {
    final query = _database.select(_database.careNotes)
      ..where(
        (n) =>
            n.squirrelId.equals(squirrelId) & n.content.like('%$searchQuery%'),
      )
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Searches care notes across all squirrels.
  Future<List<CareNote>> searchAllCareNotes(String searchQuery) async {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.content.like('%$searchQuery%'))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets care notes with photos for a specific squirrel.
  Future<List<CareNote>> getCareNotesWithPhotos(String squirrelId) async {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.squirrelId.equals(squirrelId) & n.photoPath.isNotNull())
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    final results = await query.get();
    return results.map(_careNoteFromData).toList();
  }

  /// Gets count of care notes by type for a squirrel.
  Future<Map<CareNoteType, int>> getCareNoteCountsByType(
    String squirrelId,
  ) async {
    final notes = await getCareNotes(squirrelId);
    final Map<CareNoteType, int> counts = {};

    for (final note in notes) {
      counts[note.noteType] = (counts[note.noteType] ?? 0) + 1;
    }

    return counts;
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Updates an existing care note.
  ///
  /// Returns true if the update was successful, false if the note wasn't found.
  Future<bool> updateCareNote(CareNote note) async {
    final companion = CareNotesCompanion(
      id: Value(note.id),
      squirrelId: Value(note.squirrelId),
      content: Value(note.content),
      noteType: Value(note.noteType.name),
      photoPath: Value(note.photoPath),
      isImportant: Value(note.isImportant ? 1 : 0),
      createdAt: Value(note.createdAt.toIso8601String()),
    );

    final rowsAffected = await (_database.update(
      _database.careNotes,
    )..where((n) => n.id.equals(note.id))).write(companion);

    return rowsAffected > 0;
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Deletes a care note by ID.
  ///
  /// Returns true if the note was deleted, false if it wasn't found.
  Future<bool> deleteCareNote(String id) async {
    final rowsAffected = await (_database.delete(
      _database.careNotes,
    )..where((n) => n.id.equals(id))).go();

    return rowsAffected > 0;
  }

  /// Deletes all care notes for a specific squirrel.
  ///
  /// Returns the number of notes deleted.
  Future<int> deleteCareNotesForSquirrel(String squirrelId) async {
    return await (_database.delete(
      _database.careNotes,
    )..where((n) => n.squirrelId.equals(squirrelId))).go();
  }

  // ============================================================================
  // REACTIVE STREAMS (for real-time UI updates)
  // ============================================================================

  /// Watches all care notes for a specific squirrel.
  ///
  /// Returns a stream that emits updated lists whenever data changes.
  Stream<List<CareNote>> watchCareNotes(String squirrelId) {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.squirrelId.equals(squirrelId))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    return query.watch().map((rows) => rows.map(_careNoteFromData).toList());
  }

  /// Watches important care notes for a specific squirrel.
  Stream<List<CareNote>> watchImportantCareNotes(String squirrelId) {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.squirrelId.equals(squirrelId) & n.isImportant.equals(1))
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);

    return query.watch().map((rows) => rows.map(_careNoteFromData).toList());
  }

  /// Watches recent care notes across all squirrels.
  Stream<List<CareNote>> watchRecentCareNotes({int limit = 20}) {
    final query = _database.select(_database.careNotes)
      ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
      ..limit(limit);

    return query.watch().map((rows) => rows.map(_careNoteFromData).toList());
  }

  /// Watches a single care note by ID.
  Stream<CareNote?> watchCareNote(String id) {
    final query = _database.select(_database.careNotes)
      ..where((n) => n.id.equals(id));

    return query.watchSingleOrNull().map(
      (row) => row != null ? _careNoteFromData(row) : null,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Converts Drift's CareNoteData to our domain model CareNote.
  CareNote _careNoteFromData(CareNoteData data) {
    return CareNote(
      id: data.id,
      squirrelId: data.squirrelId,
      content: data.content,
      noteType: CareNoteType.values.firstWhere(
        (type) => type.name == data.noteType,
        orElse: () => CareNoteType.general,
      ),
      photoPath: data.photoPath,
      isImportant: data.isImportant == 1,
      createdAt: DateTime.parse(data.createdAt),
    );
  }
}
