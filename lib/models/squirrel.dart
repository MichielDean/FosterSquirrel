import 'package:uuid/uuid.dart';

/// Development stages for baby squirrels based on care guidelines
enum DevelopmentStage {
  newborn('newborn', 0, 2), // 0-2 weeks, eyes closed, no fur
  infant('infant', 2, 5), // 2-5 weeks, eyes closed, some fur
  juvenile('juvenile', 5, 8), // 5-8 weeks, eyes open, solid food introduction
  adolescent('adolescent', 8, 12), // 8-12 weeks, weaning period
  adult('adult', 12, 999); // 12+ weeks, independent

  const DevelopmentStage(this.value, this.minWeeks, this.maxWeeks);

  final String value;
  final int minWeeks;
  final int maxWeeks;

  static DevelopmentStage fromString(String value) {
    return DevelopmentStage.values.firstWhere(
      (stage) => stage.value == value,
      orElse: () => DevelopmentStage.newborn,
    );
  }

  /// Calculate feeding frequency in hours based on development stage
  int get feedingFrequencyHours {
    switch (this) {
      case DevelopmentStage.newborn:
      case DevelopmentStage.infant:
        return 2; // Every 2-3 hours
      case DevelopmentStage.juvenile:
        return 3; // Every 3-4 hours
      case DevelopmentStage.adolescent:
        return 4; // Every 4-6 hours
      case DevelopmentStage.adult:
        return 8; // Minimal feeding, mostly solid food
    }
  }

  @override
  String toString() => value;
}

/// Represents a baby squirrel being tracked in the rehabilitation center.
///
/// This is an immutable data model with JSON serialization support.
/// All timestamps are stored as ISO 8601 strings for consistency.
class Squirrel {
  Squirrel({
    required this.id,
    required this.name,
    required this.foundDate,
    this.admissionWeight,
    this.currentWeight,
    this.status = SquirrelStatus.active,
    this.developmentStage = DevelopmentStage.newborn,
    this.notes,
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : _createdAt = createdAt,
       _updatedAt = updatedAt;

  /// Unique identifier for the squirrel
  final String id;

  /// Human-readable name for the squirrel
  final String name;

  /// Date when the squirrel was found/rescued
  final DateTime foundDate;

  /// Weight in grams when first admitted
  final double? admissionWeight;

  /// Most recent weight in grams
  final double? currentWeight;

  /// Current status of the squirrel
  final SquirrelStatus status;

  /// Current development stage based on age and milestones
  final DevelopmentStage developmentStage;

  /// General notes about the squirrel
  final String? notes;

  /// Path to the squirrel's photo
  final String? photoPath;

  /// Internal created timestamp
  final DateTime? _createdAt;

  /// Internal updated timestamp
  final DateTime? _updatedAt;

  /// When this record was created
  DateTime get createdAt => _createdAt ?? _getCachedNow();

  /// When this record was last updated
  DateTime get updatedAt => _updatedAt ?? _getCachedNow();

  // Centralized cache for expensive calculations
  DateTime? _cachedTime;
  DateTime? _cachedEstimatedBirthDate;
  int? _cachedActualAgeInDays;
  double? _cachedActualAgeInWeeks;
  DevelopmentStage? _cachedCurrentDevelopmentStage;
  int? _cachedDaysSinceFound;
  double? _cachedWeeksSinceFound;

  // Cache duration - use longer cache since age calculations don't need to be real-time
  static const _cacheDurationMinutes = 30; // Extended cache duration
  static DateTime? _lastNowCall; // Global cache for DateTime.now()
  static const _nowCacheDurationSeconds = 10; // Cache DateTime.now() calls

  /// Get current time with caching to avoid expensive DateTime.now() calls during UI updates
  static DateTime _getCachedNow() {
    final now = DateTime.now();

    // Only update cached time if enough time has passed
    if (_lastNowCall == null ||
        now.difference(_lastNowCall!).inSeconds >= _nowCacheDurationSeconds) {
      _lastNowCall = now;
    }

    return _lastNowCall!;
  }

  /// Check if cache is valid and refresh all cached values if needed
  void _refreshCacheIfNeeded() {
    final now = _getCachedNow();

    // If cache is still valid, return early - NO expensive operations
    if (_cachedTime != null &&
        now.difference(_cachedTime!).inMinutes < _cacheDurationMinutes) {
      return;
    }

    // Cache is invalid, recalculate all values
    _cachedTime = now;

    // Calculate estimated birth date
    final stageAtFound = developmentStage;
    final estimatedWeeksOldWhenFound =
        (stageAtFound.minWeeks + stageAtFound.maxWeeks) / 2;
    final estimatedDaysOldWhenFound = (estimatedWeeksOldWhenFound * 7).round();
    _cachedEstimatedBirthDate = foundDate.subtract(
      Duration(days: estimatedDaysOldWhenFound),
    );

    // Calculate age values using cached now
    final ageInDays = now.difference(_cachedEstimatedBirthDate!).inDays;
    _cachedActualAgeInDays = ageInDays;
    _cachedActualAgeInWeeks = ageInDays / 7.0;

    // Cache daysSinceFound and weeksSinceFound to avoid repeated calculations
    _cachedDaysSinceFound = now.difference(foundDate).inDays;
    _cachedWeeksSinceFound = _cachedDaysSinceFound! / 7.0;

    // Calculate current development stage
    final ageInWeeks = _cachedActualAgeInWeeks!;
    _cachedCurrentDevelopmentStage = DevelopmentStage.values.lastWhere(
      (stage) => ageInWeeks >= stage.minWeeks,
      orElse: () => DevelopmentStage.newborn,
    );
  }

  /// Estimated birth date based on development stage when found
  /// Uses the midpoint of the development stage age range
  DateTime get estimatedBirthDate {
    _refreshCacheIfNeeded();
    return _cachedEstimatedBirthDate!;
  }

  /// Actual developmental age in days (from estimated birth)
  int get actualAgeInDays {
    _refreshCacheIfNeeded();
    return _cachedActualAgeInDays!;
  }

  /// Actual developmental age in weeks (from estimated birth)
  double get actualAgeInWeeks {
    _refreshCacheIfNeeded();
    return _cachedActualAgeInWeeks!;
  }

  /// Current development stage based on actual age
  /// This automatically progresses as the squirrel ages
  DevelopmentStage get currentDevelopmentStage {
    _refreshCacheIfNeeded();
    return _cachedCurrentDevelopmentStage!;
  }

  /// Days since being found (for tracking purposes)
  int get daysSinceFound {
    _refreshCacheIfNeeded();
    return _cachedDaysSinceFound!;
  }

  /// Weeks since being found (for tracking purposes)
  double get weeksSinceFound {
    _refreshCacheIfNeeded();
    return _cachedWeeksSinceFound!;
  }

  /// Legacy getter for backward compatibility
  /// Now returns actual developmental age instead of days since found
  @Deprecated('Use actualAgeInDays instead')
  int get ageInDays => actualAgeInDays;

  /// Legacy getter for backward compatibility
  /// Now returns actual developmental age instead of weeks since found
  @Deprecated('Use actualAgeInWeeks instead')
  double get ageInWeeks => actualAgeInWeeks;

  /// Weight gain since admission (null if no weights recorded)
  double? get weightGain {
    if (admissionWeight == null || currentWeight == null) return null;
    return currentWeight! - admissionWeight!;
  }

  /// Calculate recommended feeding amount in ml based on current weight and current development stage
  /// Formula: 5-7% of body weight for babies under 5 weeks
  double? get recommendedFeedingAmount {
    if (currentWeight == null) return null;

    switch (currentDevelopmentStage) {
      case DevelopmentStage.newborn:
      case DevelopmentStage.infant:
        return currentWeight! * 0.06; // 6% of body weight
      case DevelopmentStage.juvenile:
        return currentWeight! * 0.05; // 5% of body weight
      case DevelopmentStage.adolescent:
        return currentWeight! *
            0.03; // 3% of body weight, transitioning to solid food
      case DevelopmentStage.adult:
        return 0; // Should be on solid food only
    }
  }

  /// Get the next feeding time based on current development stage
  DateTime get nextFeedingTime {
    final now = _getCachedNow();
    return now.add(
      Duration(hours: currentDevelopmentStage.feedingFrequencyHours),
    );
  }

  /// Check if it's time for feeding based on development stage
  bool get needsFeeding {
    // This would be calculated based on last feeding time in practice
    // For now, return true as placeholder
    return true;
  }

  /// Creates a new Squirrel with a generated UUID
  factory Squirrel.create({
    required String name,
    required DateTime foundDate,
    double? admissionWeight,
    DevelopmentStage? developmentStage,
    String? notes,
    String? photoPath,
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();

    return Squirrel(
      id: uuid.v4(),
      name: name,
      foundDate: foundDate,
      admissionWeight: admissionWeight,
      currentWeight: admissionWeight, // Initially same as admission weight
      developmentStage: developmentStage ?? DevelopmentStage.newborn,
      notes: notes,
      photoPath: photoPath,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a copy of this squirrel with updated fields
  Squirrel copyWith({
    String? id,
    String? name,
    DateTime? foundDate,
    double? admissionWeight,
    double? currentWeight,
    SquirrelStatus? status,
    DevelopmentStage? developmentStage,
    Object? notes = _copyWithNotProvided,
    Object? photoPath = _copyWithNotProvided,
    DateTime? updatedAt,
  }) {
    return Squirrel(
      id: id ?? this.id,
      name: name ?? this.name,
      foundDate: foundDate ?? this.foundDate,
      admissionWeight: admissionWeight ?? this.admissionWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      status: status ?? this.status,
      developmentStage: developmentStage ?? this.developmentStage,
      notes: notes == _copyWithNotProvided ? this.notes : notes as String?,
      photoPath: photoPath == _copyWithNotProvided
          ? this.photoPath
          : photoPath as String?,
      createdAt: _createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static const _copyWithNotProvided = Object();

  /// Creates a Squirrel from a JSON map
  factory Squirrel.fromJson(Map<String, dynamic> json) {
    return Squirrel(
      id: json['id'] as String,
      name: json['name'] as String,
      foundDate: DateTime.parse(json['found_date'] as String),
      admissionWeight: json['admission_weight'] as double?,
      currentWeight: json['current_weight'] as double?,
      status: SquirrelStatus.fromString(json['status'] as String? ?? 'active'),
      developmentStage: DevelopmentStage.fromString(
        json['development_stage'] as String? ?? 'newborn',
      ),
      notes: json['notes'] as String?,
      photoPath: json['photo_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this Squirrel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'found_date': foundDate.toIso8601String(),
      'admission_weight': admissionWeight,
      'current_weight': currentWeight,
      'status': status.value,
      'development_stage': developmentStage.value,
      'notes': notes,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Squirrel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Squirrel{id: $id, name: $name, status: $status, ageInDays: $actualAgeInDays}';
  }
}

/// Enumeration of possible squirrel status values
enum SquirrelStatus {
  active('active'),
  released('released'),
  deceased('deceased'),
  transferred('transferred');

  const SquirrelStatus(this.value);

  final String value;

  static SquirrelStatus fromString(String value) {
    return SquirrelStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SquirrelStatus.active,
    );
  }

  @override
  String toString() => value;
}
