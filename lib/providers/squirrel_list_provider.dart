import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/drift/squirrel_repository.dart';

/// A ChangeNotifier that manages the list of squirrels with caching.
///
/// This provider eliminates the FutureBuilder antipattern by:
/// - Loading data once in a controlled manner
/// - Caching results to avoid repeated database queries
/// - Notifying listeners only when data actually changes
/// - Preventing expensive operations in build() methods
class SquirrelListProvider with ChangeNotifier {
  final SquirrelRepository _repository;

  List<Squirrel> _squirrels = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  SquirrelListProvider(this._repository);

  /// Get the cached list of squirrels
  List<Squirrel> get squirrels => _squirrels;

  /// Check if data is currently being loaded
  bool get isLoading => _isLoading;

  /// Get any error that occurred during loading
  String? get error => _error;

  /// Check if data has been loaded at least once
  bool get hasData => _lastRefresh != null;

  /// Load active squirrels from the repository.
  /// This method is called explicitly, not from build() methods.
  Future<void> loadSquirrels() async {
    if (_isLoading) return; // Prevent concurrent loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // PERFORMANCE: Repository call is async and uses sqflite
      // which automatically runs on background thread
      _squirrels = await _repository.getActiveSquirrels();
      _lastRefresh = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to load squirrels: $e';
      debugPrint('SquirrelListProvider Error: $_error');
      // If database isn't ready, squirrels stay empty (graceful degradation)
      _squirrels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the squirrel list (called explicitly by user action)
  Future<void> refresh() async {
    await loadSquirrels();
  }

  /// Add a squirrel and update the cached list
  Future<void> addSquirrel(Squirrel squirrel) async {
    try {
      await _repository.addSquirrel(squirrel);
      // Optimistically add to list without full reload
      _squirrels.add(squirrel);
      notifyListeners();
      // Then refresh to ensure consistency
      await loadSquirrels();
    } catch (e) {
      _error = 'Failed to add squirrel: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update a squirrel in the cached list
  Future<void> updateSquirrel(Squirrel squirrel) async {
    try {
      await _repository.updateSquirrel(squirrel);
      final index = _squirrels.indexWhere((s) => s.id == squirrel.id);
      if (index != -1) {
        _squirrels[index] = squirrel;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update squirrel: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a squirrel from the cached list
  Future<void> deleteSquirrel(String id) async {
    try {
      await _repository.deleteSquirrel(id);
      _squirrels.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete squirrel: $e';
      notifyListeners();
      rethrow;
    }
  }
}
