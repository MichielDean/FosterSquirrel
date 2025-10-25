import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/drift/care_note_repository.dart';

/// A ChangeNotifier that manages care notes for a squirrel with caching.
///
/// This provider eliminates the FutureBuilder antipattern by:
/// - Loading data once in a controlled manner
/// - Caching results to avoid repeated database queries
/// - Notifying listeners only when data actually changes
/// - Preventing expensive operations in build() methods
class CareNoteListProvider with ChangeNotifier {
  final CareNoteRepository _repository;
  final String squirrelId;

  List<CareNote> _careNotes = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  CareNoteListProvider({
    required CareNoteRepository repository,
    required this.squirrelId,
  }) : _repository = repository;

  /// Get the cached list of care notes
  List<CareNote> get careNotes => _careNotes;

  /// Check if data is currently being loaded
  bool get isLoading => _isLoading;

  /// Get any error that occurred during loading
  String? get error => _error;

  /// Check if data has been loaded at least once
  bool get hasData => _lastRefresh != null;

  /// Load care notes from the repository.
  /// This method is called explicitly, not from build() methods.
  Future<void> loadCareNotes() async {
    if (_isLoading) return; // Prevent concurrent loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // PERFORMANCE: Repository call is async and uses sqflite
      // which automatically runs on background thread
      _careNotes = await _repository.getCareNotes(squirrelId);
      _lastRefresh = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to load care notes: $e';
      debugPrint('CareNoteListProvider Error: $_error');
      // If database isn't ready, care notes stay empty (graceful degradation)
      _careNotes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the care notes list (called explicitly by user action)
  Future<void> refresh() async {
    await loadCareNotes();
  }

  /// Add a care note and update the cached list
  Future<void> addCareNote(CareNote note) async {
    try {
      await _repository.addCareNote(note);
      // Optimistically add to list without full reload
      _careNotes.insert(0, note); // Add to beginning (newest first)
      notifyListeners();
      // Then refresh to ensure consistency
      await loadCareNotes();
    } catch (e) {
      _error = 'Failed to add care note: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update a care note in the cached list
  Future<void> updateCareNote(CareNote note) async {
    try {
      final success = await _repository.updateCareNote(note);
      if (success) {
        final index = _careNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _careNotes[index] = note;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to update care note: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Remove a care note from the cached list
  Future<void> deleteCareNote(String id) async {
    try {
      final success = await _repository.deleteCareNote(id);
      if (success) {
        _careNotes.removeWhere((n) => n.id == id);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to delete care note: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Filter care notes by type
  List<CareNote> getCareNotesByType(CareNoteType type) {
    return _careNotes.where((note) => note.noteType == type).toList();
  }

  /// Get only important care notes
  List<CareNote> getImportantCareNotes() {
    return _careNotes.where((note) => note.isImportant).toList();
  }

  /// Get care notes with photos
  List<CareNote> getCareNotesWithPhotos() {
    return _careNotes.where((note) => note.photoPath != null).toList();
  }
}
