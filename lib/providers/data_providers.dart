import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/drift/squirrel_repository.dart';
import '../repositories/drift/feeding_repository.dart';
import '../utils/performance_monitor.dart';

// Export the new optimized providers
export 'squirrel_list_provider.dart';
export 'feeding_list_provider.dart';
export 'care_note_list_provider.dart';

/// Provider for managing squirrel data with proper async patterns.
///
/// Ensures all database operations are async and don't block the main thread.
/// Uses proper state management patterns to avoid manual setState calls.
class SquirrelDataProvider extends ChangeNotifier {
  final SquirrelRepository _repository;

  List<Squirrel> _squirrels = [];
  bool _isLoading = false;
  String? _error;

  SquirrelDataProvider(this._repository);

  List<Squirrel> get squirrels => _squirrels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads active squirrels asynchronously without blocking the main thread
  Future<void> loadActiveSquirrels() async {
    PerformanceMonitor.logExpensiveOperation('Loading active squirrels');
    final stopwatch = Stopwatch()..start();

    _setLoading(true);
    _error = null;

    try {
      // This repository call is async and won't block the main thread
      final squirrels = await _repository.getActiveSquirrels();

      _squirrels = squirrels;
      _error = null;
    } catch (e) {
      _error = 'Failed to load squirrels: $e';
      _squirrels = [];
    } finally {
      _setLoading(false);
      stopwatch.stop();
      PerformanceMonitor.logOperationComplete(
        'Loading active squirrels',
        stopwatch.elapsed,
      );
    }
  }

  /// Adds a squirrel and refreshes the list
  Future<void> addSquirrel(Squirrel squirrel) async {
    PerformanceMonitor.logExpensiveOperation('Adding squirrel');
    final stopwatch = Stopwatch()..start();

    try {
      await _repository.addSquirrel(squirrel);
      await loadActiveSquirrels(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add squirrel: $e';
      notifyListeners();
      rethrow;
    } finally {
      stopwatch.stop();
      PerformanceMonitor.logOperationComplete(
        'Adding squirrel',
        stopwatch.elapsed,
      );
    }
  }

  /// Refreshes the squirrel list
  Future<void> refresh() async {
    return loadActiveSquirrels();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}

/// Provider for managing feeding records with proper async patterns
class FeedingDataProvider extends ChangeNotifier {
  final FeedingRepository _repository;

  final Map<String, List<FeedingRecord>> _feedingRecordsBySquirrel = {};
  final Map<String, Map<String, double?>> _baselineWeightCache = {};
  final Set<String> _loadingSquirrels = {};
  final Map<String, String> _errors = {};

  FeedingDataProvider(this._repository);

  List<FeedingRecord> getFeedingRecords(String squirrelId) {
    return _feedingRecordsBySquirrel[squirrelId] ?? [];
  }

  double? getBaselineWeight(String squirrelId, String recordId) {
    return _baselineWeightCache[squirrelId]?[recordId];
  }

  bool isLoading(String squirrelId) => _loadingSquirrels.contains(squirrelId);
  String? getError(String squirrelId) => _errors[squirrelId];

  /// Loads feeding records for a squirrel asynchronously
  Future<void> loadFeedingRecords(String squirrelId) async {
    PerformanceMonitor.logExpensiveOperation(
      'Loading feeding records for $squirrelId',
    );
    final stopwatch = Stopwatch()..start();

    _loadingSquirrels.add(squirrelId);
    _errors.remove(squirrelId);
    notifyListeners();

    try {
      final records = await _repository.getFeedingRecords(squirrelId);

      // Pre-sort and cache baseline weights to avoid expensive operations during build
      final sortedRecords = List<FeedingRecord>.from(records)
        ..sort((a, b) => a.feedingTime.compareTo(b.feedingTime));

      _feedingRecordsBySquirrel[squirrelId] = sortedRecords;
      _cacheBaselineWeights(squirrelId, sortedRecords);

      _errors.remove(squirrelId);
    } catch (e) {
      _errors[squirrelId] = 'Failed to load feeding records: $e';
    } finally {
      _loadingSquirrels.remove(squirrelId);
      notifyListeners();
      stopwatch.stop();
      PerformanceMonitor.logOperationComplete(
        'Loading feeding records for $squirrelId',
        stopwatch.elapsed,
      );
    }
  }

  /// Pre-calculates baseline weights to avoid expensive operations during UI rendering
  void _cacheBaselineWeights(
    String squirrelId,
    List<FeedingRecord> sortedRecords,
  ) {
    final cache = <String, double?>{};

    for (int i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];

      // Use previous record's ending weight as baseline, or starting weight if first record
      final baselineWeight =
          i > 0 && sortedRecords[i - 1].endingWeightGrams != null
          ? sortedRecords[i - 1].endingWeightGrams!
          : record.startingWeightGrams;

      cache[record.id] = baselineWeight;
    }

    _baselineWeightCache[squirrelId] = cache;
  }

  /// Adds a feeding record and refreshes the list
  Future<void> addFeedingRecord(FeedingRecord record) async {
    PerformanceMonitor.logExpensiveOperation('Adding feeding record');
    final stopwatch = Stopwatch()..start();

    try {
      await _repository.addFeedingRecord(record);
      await loadFeedingRecords(record.squirrelId); // Refresh the list
    } catch (e) {
      _errors[record.squirrelId] = 'Failed to add feeding record: $e';
      notifyListeners();
      rethrow;
    } finally {
      stopwatch.stop();
      PerformanceMonitor.logOperationComplete(
        'Adding feeding record',
        stopwatch.elapsed,
      );
    }
  }
}
