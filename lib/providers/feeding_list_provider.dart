import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/drift/feeding_repository.dart';

/// A ChangeNotifier that manages feeding records for a squirrel with caching.
///
/// This provider:
/// - Caches feeding records to avoid repeated database queries
/// - Precomputes expensive calculations (sorting, baseline weights)
/// - Notifies listeners only when data changes
/// - Prevents expensive operations in build() methods
class FeedingListProvider with ChangeNotifier {
  final FeedingRepository _repository;
  final String squirrelId;
  final double? admissionWeight;

  List<FeedingRecord> _feedingRecords = [];
  List<FeedingRecord> _sortedFeedingRecords = [];
  Map<String, double?> _baselineWeightCache = {};
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  FeedingListProvider({
    required FeedingRepository repository,
    required this.squirrelId,
    required this.admissionWeight,
  }) : _repository = repository;

  /// Get the cached list of feeding records (unsorted)
  List<FeedingRecord> get feedingRecords => _feedingRecords;

  /// Get the pre-sorted list of feeding records
  List<FeedingRecord> get sortedFeedingRecords => _sortedFeedingRecords;

  /// Get precomputed baseline weights
  Map<String, double?> get baselineWeightCache => _baselineWeightCache;

  /// Check if data is currently being loaded
  bool get isLoading => _isLoading;

  /// Get any error that occurred during loading
  String? get error => _error;

  /// Check if data has been loaded at least once
  bool get hasData => _lastRefresh != null;

  /// Load feeding records from the repository.
  /// This method is called explicitly from initState, not from build() methods.
  Future<void> loadFeedingRecords() async {
    if (_isLoading) return; // Prevent concurrent loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final records = await _repository.getFeedingRecords(squirrelId);

      // Pre-sort records to avoid expensive operations during build
      _sortedFeedingRecords = List<FeedingRecord>.from(records)
        ..sort((a, b) => a.feedingTime.compareTo(b.feedingTime));

      // Pre-calculate baseline weights for all records
      _baselineWeightCache = _calculateBaselineWeights(_sortedFeedingRecords);

      _feedingRecords = records;
      _lastRefresh = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to load feeding records: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Precompute baseline weights to avoid doing this in build() methods
  Map<String, double?> _calculateBaselineWeights(List<FeedingRecord> sorted) {
    final cache = <String, double?>{};

    for (int i = 0; i < sorted.length; i++) {
      final record = sorted[i];
      double? baselineWeight;

      if (i == 0) {
        // First feeding record uses admission weight
        baselineWeight = admissionWeight;
      } else {
        // Use the ending weight from the previous feeding record
        final previousRecord = sorted[i - 1];
        baselineWeight =
            previousRecord.endingWeightGrams ??
            previousRecord.startingWeightGrams;
      }

      cache[record.id] = baselineWeight;
    }

    return cache;
  }

  /// Refresh the feeding records (called explicitly by user action)
  Future<void> refresh() async {
    await loadFeedingRecords();
  }

  /// Add a feeding record and update the cached list
  Future<void> addFeedingRecord(FeedingRecord record) async {
    try {
      await _repository.addFeedingRecord(record);
      // Refresh to get updated data and recompute caches
      await loadFeedingRecords();
    } catch (e) {
      _error = 'Failed to add feeding record: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update a feeding record in the cached list
  Future<void> updateFeedingRecord(FeedingRecord record) async {
    try {
      await _repository.updateFeedingRecord(record);
      await loadFeedingRecords(); // Refresh to recompute caches
    } catch (e) {
      _error = 'Failed to update feeding record: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a feeding record from the cached list
  Future<void> deleteFeedingRecord(String id) async {
    try {
      await _repository.deleteFeedingRecord(id);
      await loadFeedingRecords(); // Refresh to recompute caches
    } catch (e) {
      _error = 'Failed to delete feeding record: $e';
      notifyListeners();
      rethrow;
    }
  }
}
