import 'package:drift/drift.dart';

import '../../database/database.dart';
import '../../models/models.dart';

/// Repository for managing squirrel data using Drift.
///
/// Provides a high-level interface for squirrel-related database operations,
/// with type-safe queries and compile-time validation.
class SquirrelRepository {
  final AppDatabase _db;

  SquirrelRepository(this._db);

  /// Adds a new squirrel to the database
  Future<void> addSquirrel(Squirrel squirrel) async {
    try {
      await _db
          .into(_db.squirrels)
          .insert(
            SquirrelsCompanion(
              id: Value(squirrel.id),
              name: Value(squirrel.name),
              foundDate: Value(squirrel.foundDate.toIso8601String()),
              admissionWeight: Value(squirrel.admissionWeight),
              currentWeight: Value(squirrel.currentWeight),
              status: Value(squirrel.status.value),
              developmentStage: Value(squirrel.developmentStage.value),
              notes: Value(squirrel.notes),
              photoPath: Value(squirrel.photoPath),
              createdAt: Value(squirrel.createdAt.toIso8601String()),
              updatedAt: Value(squirrel.updatedAt.toIso8601String()),
            ),
          );
    } catch (e) {
      throw SquirrelRepositoryException('Failed to add squirrel: $e');
    }
  }

  /// Updates an existing squirrel in the database
  Future<void> updateSquirrel(Squirrel squirrel) async {
    try {
      await (_db.update(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(squirrel.id))).write(
        SquirrelsCompanion(
          name: Value(squirrel.name),
          foundDate: Value(squirrel.foundDate.toIso8601String()),
          admissionWeight: Value(squirrel.admissionWeight),
          currentWeight: Value(squirrel.currentWeight),
          status: Value(squirrel.status.value),
          developmentStage: Value(squirrel.developmentStage.value),
          notes: Value(squirrel.notes),
          photoPath: Value(squirrel.photoPath),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    } catch (e) {
      throw SquirrelRepositoryException('Failed to update squirrel: $e');
    }
  }

  /// Deletes a squirrel from the database
  /// Note: Cascade delete will automatically remove associated feeding records and care notes
  Future<void> deleteSquirrel(String id) async {
    try {
      final count = await (_db.delete(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (count == 0) {
        throw SquirrelRepositoryException('Squirrel not found with ID: $id');
      }
    } catch (e) {
      if (e is SquirrelRepositoryException) {
        rethrow;
      }
      throw SquirrelRepositoryException('Failed to delete squirrel: $e');
    }
  }

  /// Gets a single squirrel by ID
  Future<Squirrel?> getSquirrel(String id) async {
    try {
      final data = await (_db.select(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      return data != null ? _squirrelFromData(data) : null;
    } catch (e) {
      throw SquirrelRepositoryException('Failed to get squirrel: $e');
    }
  }

  /// Gets all squirrels
  Future<List<Squirrel>> getAllSquirrels() async {
    try {
      final data = await _db.select(_db.squirrels).get();
      return data.map(_squirrelFromData).toList();
    } catch (e) {
      throw SquirrelRepositoryException('Failed to get all squirrels: $e');
    }
  }

  /// Gets all active squirrels
  Future<List<Squirrel>> getActiveSquirrels() async {
    return getSquirrelsByStatus(SquirrelStatus.active);
  }

  /// Gets squirrels filtered by status
  Future<List<Squirrel>> getSquirrelsByStatus(SquirrelStatus status) async {
    try {
      final data = await (_db.select(
        _db.squirrels,
      )..where((tbl) => tbl.status.equals(status.value))).get();

      return data.map(_squirrelFromData).toList();
    } catch (e) {
      throw SquirrelRepositoryException(
        'Failed to get squirrels by status: $e',
      );
    }
  }

  /// Gets the total count of squirrels
  Future<int> getSquirrelCount() async {
    try {
      final count = await _db.select(_db.squirrels).get();
      return count.length;
    } catch (e) {
      throw SquirrelRepositoryException('Failed to get squirrel count: $e');
    }
  }

  /// Updates a squirrel's current weight
  Future<void> updateSquirrelWeight(String squirrelId, double weight) async {
    try {
      await (_db.update(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(squirrelId))).write(
        SquirrelsCompanion(
          currentWeight: Value(weight),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    } catch (e) {
      throw SquirrelRepositoryException('Failed to update squirrel weight: $e');
    }
  }

  /// Gets squirrels that need attention (e.g., no recent weight records)
  Future<List<Squirrel>> getSquirrelsNeedingAttention() async {
    try {
      final data =
          await (_db.select(_db.squirrels)..where(
                (tbl) =>
                    tbl.status.equals('active') & tbl.currentWeight.isNull(),
              ))
              .get();

      return data.map(_squirrelFromData).toList();
    } catch (e) {
      throw SquirrelRepositoryException(
        'Failed to get squirrels needing attention: $e',
      );
    }
  }

  /// Converts Drift SquirrelData to domain model Squirrel
  Squirrel _squirrelFromData(SquirrelData data) {
    return Squirrel(
      id: data.id,
      name: data.name,
      foundDate: DateTime.parse(data.foundDate),
      admissionWeight: data.admissionWeight,
      currentWeight: data.currentWeight,
      status: SquirrelStatus.fromString(data.status),
      developmentStage: DevelopmentStage.fromString(data.developmentStage),
      notes: data.notes,
      photoPath: data.photoPath,
      createdAt: DateTime.parse(data.createdAt),
      updatedAt: DateTime.parse(data.updatedAt),
    );
  }

  /// Watch all squirrels (returns a stream for reactive UI)
  Stream<List<Squirrel>> watchAllSquirrels() {
    return _db
        .select(_db.squirrels)
        .watch()
        .map((dataList) => dataList.map(_squirrelFromData).toList());
  }

  /// Watch active squirrels (returns a stream for reactive UI)
  Stream<List<Squirrel>> watchActiveSquirrels() {
    return (_db.select(_db.squirrels)
          ..where((tbl) => tbl.status.equals('active')))
        .watch()
        .map((dataList) => dataList.map(_squirrelFromData).toList());
  }

  /// Watch a single squirrel by ID (returns a stream for reactive UI)
  Stream<Squirrel?> watchSquirrel(String id) {
    return (_db.select(_db.squirrels)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull()
        .map((data) => data != null ? _squirrelFromData(data) : null);
  }
}

/// Exception thrown by SquirrelRepository operations.
class SquirrelRepositoryException implements Exception {
  final String message;

  const SquirrelRepositoryException(this.message);

  @override
  String toString() => 'SquirrelRepositoryException: $message';
}
