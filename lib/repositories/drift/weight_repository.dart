import 'package:drift/drift.dart';
import '../../database/database.dart';

/// Simple data class for weight tracking points
class WeightDataPoint {
  final DateTime date;
  final double weight;

  WeightDataPoint({required this.date, required this.weight});
}

/// Repository for extracting weight trend data from feeding records.
///
/// Weight measurements are stored as ending_weight_grams in feeding records.
/// This repository provides a convenient interface for charting weight progress.
class WeightRepository {
  final AppDatabase _database;

  WeightRepository(this._database);

  /// Gets weight trend data for a squirrel from their feeding records.
  ///
  /// Extracts ending weight from each feeding record where it was recorded.
  /// Returns a list of weight data points sorted by date.
  Future<List<WeightDataPoint>> getWeightTrendData(String squirrelId) async {
    final query = _database.select(_database.feedingRecords)
      ..where((f) => f.squirrelId.equals(squirrelId))
      ..orderBy([(f) => OrderingTerm.asc(f.feedingTime)]);

    final records = await query.get();

    // Extract weight data points from feeding records
    final weightPoints = <WeightDataPoint>[];

    for (final record in records) {
      // Use ending weight if available, otherwise starting weight
      final weight = record.endingWeightGrams ?? record.startingWeightGrams;

      weightPoints.add(
        WeightDataPoint(
          date: DateTime.parse(record.feedingTime),
          weight: weight,
        ),
      );
    }

    return weightPoints;
  }

  /// Gets the latest weight measurement for a squirrel.
  Future<double?> getLatestWeight(String squirrelId) async {
    final query = _database.select(_database.feedingRecords)
      ..where((f) => f.squirrelId.equals(squirrelId))
      ..orderBy([(f) => OrderingTerm.desc(f.feedingTime)])
      ..limit(1);

    final record = await query.getSingleOrNull();

    if (record == null) return null;

    // Return ending weight if available, otherwise starting weight
    return record.endingWeightGrams ?? record.startingWeightGrams;
  }

  /// Gets average weight over a time period.
  Future<double?> getAverageWeight(
    String squirrelId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    final query = _database.select(_database.feedingRecords)
      ..where(
        (f) =>
            f.squirrelId.equals(squirrelId) &
            f.feedingTime.isBiggerOrEqualValue(startStr) &
            f.feedingTime.isSmallerOrEqualValue(endStr),
      );

    final records = await query.get();

    if (records.isEmpty) return null;

    final weights = <double>[];
    for (final record in records) {
      final weight = record.endingWeightGrams ?? record.startingWeightGrams;
      weights.add(weight);
    }

    if (weights.isEmpty) return null;

    return weights.reduce((a, b) => a + b) / weights.length;
  }

  /// Gets weight gain/loss between two dates.
  Future<double?> getWeightChange(
    String squirrelId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr = startDate.toIso8601String();
    final endStr = endDate.toIso8601String();

    // Get first weight in range
    final firstQuery = _database.select(_database.feedingRecords)
      ..where(
        (f) =>
            f.squirrelId.equals(squirrelId) &
            f.feedingTime.isBiggerOrEqualValue(startStr),
      )
      ..orderBy([(f) => OrderingTerm.asc(f.feedingTime)])
      ..limit(1);

    final firstRecord = await firstQuery.getSingleOrNull();

    // Get last weight in range
    final lastQuery = _database.select(_database.feedingRecords)
      ..where(
        (f) =>
            f.squirrelId.equals(squirrelId) &
            f.feedingTime.isSmallerOrEqualValue(endStr),
      )
      ..orderBy([(f) => OrderingTerm.desc(f.feedingTime)])
      ..limit(1);

    final lastRecord = await lastQuery.getSingleOrNull();

    if (firstRecord == null || lastRecord == null) return null;

    // Use starting weight for first measurement (beginning of period)
    // Use ending weight if available for last measurement (end of period)
    final firstWeight = firstRecord.startingWeightGrams;
    final lastWeight =
        lastRecord.endingWeightGrams ?? lastRecord.startingWeightGrams;

    return lastWeight - firstWeight;
  }
}
