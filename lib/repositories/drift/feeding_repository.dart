import 'package:drift/drift.dart';

import '../../database/database.dart';
import '../../models/models.dart';

/// Repository for managing feeding record data using Drift.
///
/// Provides type-safe queries for feeding-related database operations,
/// including feeding history and analytics.
class FeedingRepository {
  final AppDatabase _db;

  FeedingRepository(this._db);

  /// Adds a new feeding record to the database
  Future<void> addFeedingRecord(FeedingRecord record) async {
    try {
      // Validate that the squirrel exists
      final squirrel = await (_db.select(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(record.squirrelId))).getSingleOrNull();

      if (squirrel == null) {
        throw FeedingRepositoryException(
          'Squirrel not found with ID: ${record.squirrelId}',
        );
      }

      await _db
          .into(_db.feedingRecords)
          .insert(
            FeedingRecordsCompanion(
              id: Value(record.id),
              squirrelId: Value(record.squirrelId),
              squirrelName: Value(record.squirrelName),
              feedingTime: Value(record.feedingTime.toIso8601String()),
              startingWeightGrams: Value(record.startingWeightGrams),
              actualFeedAmountMl: Value(record.actualFeedAmountML),
              endingWeightGrams: Value(record.endingWeightGrams),
              notes: Value(record.notes),
              foodType: Value(record.foodType),
              createdAt: Value(record.createdAt.toIso8601String()),
              updatedAt: Value(record.updatedAt.toIso8601String()),
            ),
          );

      // Update squirrel's current weight if ending weight is provided
      if (record.endingWeightGrams != null) {
        await (_db.update(
          _db.squirrels,
        )..where((tbl) => tbl.id.equals(record.squirrelId))).write(
          SquirrelsCompanion(
            currentWeight: Value(record.endingWeightGrams),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        );
      }
    } catch (e) {
      if (e is FeedingRepositoryException) rethrow;
      throw FeedingRepositoryException('Failed to add feeding record: $e');
    }
  }

  /// Updates an existing feeding record
  Future<void> updateFeedingRecord(FeedingRecord record) async {
    try {
      await (_db.update(
        _db.feedingRecords,
      )..where((tbl) => tbl.id.equals(record.id))).write(
        FeedingRecordsCompanion(
          squirrelId: Value(record.squirrelId),
          squirrelName: Value(record.squirrelName),
          feedingTime: Value(record.feedingTime.toIso8601String()),
          startingWeightGrams: Value(record.startingWeightGrams),
          actualFeedAmountMl: Value(record.actualFeedAmountML),
          endingWeightGrams: Value(record.endingWeightGrams),
          notes: Value(record.notes),
          foodType: Value(record.foodType),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );

      // Check if this is the most recent feeding record and update squirrel's current weight
      if (record.endingWeightGrams != null) {
        final feedingRecords =
            await (_db.select(_db.feedingRecords)
                  ..where((tbl) => tbl.squirrelId.equals(record.squirrelId))
                  ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)]))
                .get();

        // If this is the most recent record, update the squirrel's current weight
        if (feedingRecords.isNotEmpty && feedingRecords.first.id == record.id) {
          await (_db.update(
            _db.squirrels,
          )..where((tbl) => tbl.id.equals(record.squirrelId))).write(
            SquirrelsCompanion(
              currentWeight: Value(record.endingWeightGrams),
              updatedAt: Value(DateTime.now().toIso8601String()),
            ),
          );
        }
      }
    } catch (e) {
      throw FeedingRepositoryException('Failed to update feeding record: $e');
    }
  }

  /// Deletes a feeding record
  Future<void> deleteFeedingRecord(String id) async {
    try {
      await (_db.delete(
        _db.feedingRecords,
      )..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw FeedingRepositoryException('Failed to delete feeding record: $e');
    }
  }

  /// Gets all feeding records for a specific squirrel
  Future<List<FeedingRecord>> getFeedingRecords(String squirrelId) async {
    try {
      // Validate that the squirrel exists
      final squirrel = await (_db.select(
        _db.squirrels,
      )..where((tbl) => tbl.id.equals(squirrelId))).getSingleOrNull();

      if (squirrel == null) {
        throw FeedingRepositoryException(
          'Squirrel not found with ID: $squirrelId',
        );
      }

      final data =
          await (_db.select(_db.feedingRecords)
                ..where((tbl) => tbl.squirrelId.equals(squirrelId))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)]))
              .get();

      return data.map(_feedingRecordFromData).toList();
    } catch (e) {
      if (e is FeedingRepositoryException) rethrow;
      throw FeedingRepositoryException('Failed to get feeding records: $e');
    }
  }

  /// Gets the most recent feeding records across all squirrels
  Future<List<FeedingRecord>> getRecentFeedingRecords({int limit = 10}) async {
    try {
      final data =
          await (_db.select(_db.feedingRecords)
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)])
                ..limit(limit))
              .get();

      return data.map(_feedingRecordFromData).toList();
    } catch (e) {
      throw FeedingRepositoryException(
        'Failed to get recent feeding records: $e',
      );
    }
  }

  /// Gets the last feeding record for a specific squirrel
  Future<FeedingRecord?> getLastFeedingRecord(String squirrelId) async {
    try {
      final data =
          await (_db.select(_db.feedingRecords)
                ..where((tbl) => tbl.squirrelId.equals(squirrelId))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)])
                ..limit(1))
              .getSingleOrNull();

      return data != null ? _feedingRecordFromData(data) : null;
    } catch (e) {
      throw FeedingRepositoryException('Failed to get last feeding record: $e');
    }
  }

  /// Gets feeding records within a date range for a specific squirrel
  Future<List<FeedingRecord>> getFeedingRecordsInRange(
    String squirrelId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();

      final data =
          await (_db.select(_db.feedingRecords)
                ..where(
                  (tbl) =>
                      tbl.squirrelId.equals(squirrelId) &
                      tbl.feedingTime.isBiggerOrEqualValue(startStr) &
                      tbl.feedingTime.isSmallerOrEqualValue(endStr),
                )
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)]))
              .get();

      return data.map(_feedingRecordFromData).toList();
    } catch (e) {
      throw FeedingRepositoryException(
        'Failed to get feeding records in range: $e',
      );
    }
  }

  /// Gets feeding frequency (count by food type) for a squirrel
  Future<Map<String, int>> getFeedingFrequency(String squirrelId) async {
    try {
      final records = await getFeedingRecords(squirrelId);
      final Map<String, int> frequency = {};

      for (final record in records) {
        final foodType = record.foodType;
        frequency[foodType] = (frequency[foodType] ?? 0) + 1;
      }

      return frequency;
    } catch (e) {
      throw FeedingRepositoryException('Failed to get feeding frequency: $e');
    }
  }

  /// Gets feeding records for today for a specific squirrel
  Future<List<FeedingRecord>> getTodaysFeedingRecords(String squirrelId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getFeedingRecordsInRange(squirrelId, startOfDay, endOfDay);
    } catch (e) {
      throw FeedingRepositoryException(
        'Failed to get today\'s feeding records: $e',
      );
    }
  }

  /// Converts Drift FeedingRecordData to domain model FeedingRecord
  FeedingRecord _feedingRecordFromData(FeedingRecordData data) {
    return FeedingRecord(
      id: data.id,
      squirrelId: data.squirrelId,
      squirrelName: data.squirrelName,
      feedingTime: DateTime.parse(data.feedingTime),
      startingWeightGrams: data.startingWeightGrams,
      actualFeedAmountML: data.actualFeedAmountMl,
      endingWeightGrams: data.endingWeightGrams,
      notes: data.notes,
      foodType: data.foodType,
      createdAt: data.createdAt != null
          ? DateTime.parse(data.createdAt!)
          : null,
      updatedAt: data.updatedAt != null
          ? DateTime.parse(data.updatedAt!)
          : null,
    );
  }

  /// Watch all feeding records for a squirrel (reactive stream)
  Stream<List<FeedingRecord>> watchFeedingRecords(String squirrelId) {
    return (_db.select(_db.feedingRecords)
          ..where((tbl) => tbl.squirrelId.equals(squirrelId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)]))
        .watch()
        .map((dataList) => dataList.map(_feedingRecordFromData).toList());
  }

  /// Watch recent feeding records across all squirrels (reactive stream)
  Stream<List<FeedingRecord>> watchRecentFeedingRecords({int limit = 10}) {
    return (_db.select(_db.feedingRecords)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.feedingTime)])
          ..limit(limit))
        .watch()
        .map((dataList) => dataList.map(_feedingRecordFromData).toList());
  }
}

/// Exception thrown by FeedingRepository operations
class FeedingRepositoryException implements Exception {
  final String message;

  const FeedingRepositoryException(this.message);

  @override
  String toString() => 'FeedingRepositoryException: $message';
}
