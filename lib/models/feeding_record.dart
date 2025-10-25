import 'package:uuid/uuid.dart';
import 'feeding_schedule.dart';
import '../utils/weight_converter.dart';

/// Represents a feeding record for a squirrel.
///
/// This tracks the essential information for each feeding session:
/// - Name, Time, Starting Weight (Grams), Calculated recommended amount
/// - Ending Weight (Grams), Weight Difference, Total Weight Gain, Notes
///
/// Feed amount is calculated based on the 5% rule: maximum 5% of body weight
/// For example: 100g squirrel → max 5g (5cc/ml) of formula
class FeedingRecord {
  const FeedingRecord({
    required this.id,
    required this.squirrelId,
    required this.squirrelName,
    required this.feedingTime,
    required this.startingWeightGrams,
    this.endingWeightGrams,
    this.notes,
    this.foodType = 'Formula',
    this.actualFeedAmountML,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : _createdAt = createdAt,
       _updatedAt = updatedAt;

  /// Unique identifier for this feeding record
  final String id;

  /// ID of the squirrel this feeding belongs to
  final String squirrelId;

  /// Name of the squirrel (denormalized for easier display)
  final String squirrelName;

  /// When this feeding occurred
  final DateTime feedingTime;

  /// Starting weight in grams before feeding
  final double startingWeightGrams;

  /// Ending weight in grams after feeding
  final double? endingWeightGrams;

  /// Notes about this feeding session
  final String? notes;

  /// Type of food given (e.g., "Formula", "Solid food", "Water")
  final String foodType;

  /// Actual amount fed in ML (optional - for tracking vs. recommended)
  final double? actualFeedAmountML;

  /// Internal created timestamp
  final DateTime? _createdAt;

  /// Internal updated timestamp
  final DateTime? _updatedAt;

  /// When this record was created
  DateTime get createdAt => _createdAt ?? DateTime.now();

  /// When this record was last updated
  DateTime get updatedAt => _updatedAt ?? DateTime.now();

  /// Weight difference for this feeding (ending - starting)
  /// Returns null if ending weight is not recorded
  double? get weightDifferenceGrams {
    if (endingWeightGrams == null) return null;
    return endingWeightGrams! - startingWeightGrams;
  }

  /// Calculate weight gain from a baseline weight (e.g., admission weight or previous feeding)
  /// Returns null if ending weight is not recorded
  double? calculateWeightGainFrom(double baselineWeight) {
    if (endingWeightGrams == null) return null;
    return endingWeightGrams! - baselineWeight;
  }

  /// Format weight gain from baseline for display with +/- sign
  String formatWeightGainFrom(
    double baselineWeight, {
    WeightUnit unit = WeightUnit.grams,
  }) {
    final gain = calculateWeightGainFrom(baselineWeight);
    if (gain == null) return 'N/A';

    final formattedGain = WeightConverter.formatWeightDifference(gain, unit);
    return formattedGain;
  }

  /// Calculate recommended feed amount in ML based on weight and age
  /// Uses the accurate feeding schedule table
  /// Calculates the recommended feed amount based on the feeding schedule
  double get recommendedFeedAmountML {
    final schedule = FeedingSchedule.getScheduleForWeight(startingWeightGrams);
    return schedule.getRecommendedAmountForWeight(startingWeightGrams);
  }

  /// Gets the feeding schedule for this record's weight
  FeedingSchedule get feedingSchedule {
    return FeedingSchedule.getScheduleForWeight(startingWeightGrams);
  }

  /// Get actual feed amount or recommended if not specified
  double get feedAmountML => actualFeedAmountML ?? recommendedFeedAmountML;

  /// Get starting weight in specified unit
  double getStartingWeight(WeightUnit unit) {
    return WeightConverter.fromGrams(startingWeightGrams, unit);
  }

  /// Get ending weight in specified unit
  /// Returns null if ending weight is not recorded
  double? getEndingWeight(WeightUnit unit) {
    if (endingWeightGrams == null) return null;
    return WeightConverter.fromGrams(endingWeightGrams!, unit);
  }

  /// Get weight difference in specified unit
  /// Returns null if ending weight is not recorded
  double? getWeightDifference(WeightUnit unit) {
    if (weightDifferenceGrams == null) return null;
    return WeightConverter.fromGrams(weightDifferenceGrams!, unit);
  }

  /// Format starting weight for display
  String formatStartingWeight(WeightUnit unit) {
    return WeightConverter.formatWeight(startingWeightGrams, unit);
  }

  /// Format ending weight for display
  /// Returns 'N/A' if ending weight is not recorded
  String formatEndingWeight(WeightUnit unit) {
    if (endingWeightGrams == null) return 'N/A';
    return WeightConverter.formatWeight(endingWeightGrams!, unit);
  }

  /// Format weight difference for display with +/- sign
  /// Returns 'N/A' if ending weight is not recorded
  String formatWeightDifference(WeightUnit unit) {
    if (weightDifferenceGrams == null) return 'N/A';
    return WeightConverter.formatWeightDifference(weightDifferenceGrams!, unit);
  }

  /// Format feeding amount for display (ML or CC)
  String formatFeedAmount() {
    return '${feedAmountML.toStringAsFixed(1)} ml';
  }

  /// Check if this was a successful feeding (weight gain or maintained)
  /// Returns true if ending weight is not recorded (benefit of the doubt)
  bool get isSuccessfulFeeding {
    if (weightDifferenceGrams == null) return true;
    return weightDifferenceGrams! >= 0;
  }

  /// Get feeding time formatted for display
  String get formattedFeedingTime {
    final now = DateTime.now();
    final difference = now.difference(feedingTime);

    if (difference.inDays > 7) {
      return '${feedingTime.month}/${feedingTime.day}/${feedingTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Creates a new FeedingRecord with a generated UUID
  factory FeedingRecord.create({
    String? id,
    required String squirrelId,
    required String squirrelName,
    DateTime? feedingTime,
    required double startingWeightGrams,
    double? endingWeightGrams,
    String? notes,
    String? foodType,
    double? actualFeedAmountML,
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();

    return FeedingRecord(
      id: id ?? uuid.v4(),
      squirrelId: squirrelId,
      squirrelName: squirrelName,
      feedingTime: feedingTime ?? now,
      startingWeightGrams: startingWeightGrams,
      endingWeightGrams: endingWeightGrams,
      notes: notes ?? '',
      foodType: foodType ?? 'Formula',
      actualFeedAmountML: actualFeedAmountML,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a copy of this feeding record with updated fields
  FeedingRecord copyWith({
    String? id,
    String? squirrelId,
    String? squirrelName,
    DateTime? feedingTime,
    double? startingWeightGrams,
    double? endingWeightGrams,
    String? notes,
    String? foodType,
    double? actualFeedAmountML,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedingRecord(
      id: id ?? this.id,
      squirrelId: squirrelId ?? this.squirrelId,
      squirrelName: squirrelName ?? this.squirrelName,
      feedingTime: feedingTime ?? this.feedingTime,
      startingWeightGrams: startingWeightGrams ?? this.startingWeightGrams,
      endingWeightGrams: endingWeightGrams ?? this.endingWeightGrams,
      notes: notes ?? this.notes,
      foodType: foodType ?? this.foodType,
      actualFeedAmountML: actualFeedAmountML ?? this.actualFeedAmountML,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a FeedingRecord from a JSON map
  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    return FeedingRecord(
      id: json['id'] as String? ?? '',
      squirrelId: json['squirrel_id'] as String? ?? '',
      squirrelName: json['squirrel_name'] as String? ?? '',
      feedingTime: json['feeding_time'] != null
          ? DateTime.parse(json['feeding_time'] as String)
          : DateTime.now(),
      startingWeightGrams: json['starting_weight_grams'] != null
          ? (json['starting_weight_grams'] as num).toDouble()
          : 0.0,
      endingWeightGrams: json['ending_weight_grams'] != null
          ? (json['ending_weight_grams'] as num).toDouble()
          : null,
      notes: json['notes'] as String? ?? '',
      foodType: json['food_type'] as String? ?? 'Formula',
      actualFeedAmountML: json['actual_feed_amount_ml'] != null
          ? (json['actual_feed_amount_ml'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this FeedingRecord to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'squirrel_id': squirrelId,
      'squirrel_name': squirrelName,
      'feeding_time': feedingTime.toIso8601String(),
      'starting_weight_grams': startingWeightGrams,
      'ending_weight_grams': endingWeightGrams,
      'notes': notes,
      'food_type': foodType,
      if (actualFeedAmountML != null)
        'actual_feed_amount_ml': actualFeedAmountML,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FeedingRecord(id: $id, squirrelName: $squirrelName, '
        'feedingTime: $feedingTime, weightChange: ${formatWeightDifference(WeightUnit.grams)})';
  }
}

/// Helper class for calculating feeding statistics and totals
class FeedingStats {
  const FeedingStats._({
    required this.totalFeedings,
    required this.totalWeightGainGrams,
    required this.averageWeightGainGrams,
    required this.successfulFeedings,
    required this.totalFeedAmountML,
    required this.lastFeedingTime,
    required this.firstFeedingTime,
  });

  final int totalFeedings;
  final double totalWeightGainGrams;
  final double averageWeightGainGrams;
  final int successfulFeedings;
  final double totalFeedAmountML;
  final DateTime? lastFeedingTime;
  final DateTime? firstFeedingTime;

  /// Success rate as percentage (0-100)
  double get successRate {
    if (totalFeedings == 0) return 0.0;
    return (successfulFeedings / totalFeedings) * 100;
  }

  /// Average feed amount in ML
  double get averageFeedAmountML {
    if (totalFeedings == 0) return 0.0;
    return totalFeedAmountML / totalFeedings;
  }

  /// Constructor that creates stats from records
  factory FeedingStats(List<FeedingRecord> records) {
    return FeedingStats.fromRecords(records);
  }

  /// Calculate stats from a list of feeding records
  factory FeedingStats.fromRecords(List<FeedingRecord> records) {
    if (records.isEmpty) {
      return const FeedingStats._(
        totalFeedings: 0,
        totalWeightGainGrams: 0.0,
        averageWeightGainGrams: 0.0,
        successfulFeedings: 0,
        totalFeedAmountML: 0.0,
        lastFeedingTime: null,
        firstFeedingTime: null,
      );
    }

    // Sort by feeding time to get first and last
    final sortedRecords = List<FeedingRecord>.from(records)
      ..sort((a, b) => a.feedingTime.compareTo(b.feedingTime));

    // Only include records with recorded ending weight in weight gain calculations
    final recordsWithEndingWeight = records
        .where((r) => r.endingWeightGrams != null)
        .toList();

    final totalWeightGain = recordsWithEndingWeight.fold<double>(
      0.0,
      (sum, record) => sum + record.weightDifferenceGrams!,
    );

    final successfulCount = records.where((r) => r.isSuccessfulFeeding).length;

    final totalFeedAmount = records.fold<double>(
      0.0,
      (sum, record) => sum + record.feedAmountML,
    );

    // Calculate average only from records with ending weight
    final averageWeightGain = recordsWithEndingWeight.isEmpty
        ? 0.0
        : totalWeightGain / recordsWithEndingWeight.length;

    return FeedingStats._(
      totalFeedings: records.length,
      totalWeightGainGrams: totalWeightGain,
      averageWeightGainGrams: averageWeightGain,
      successfulFeedings: successfulCount,
      totalFeedAmountML: totalFeedAmount,
      firstFeedingTime: sortedRecords.first.feedingTime,
      lastFeedingTime: sortedRecords.last.feedingTime,
    );
  }

  /// Format total weight gain for display
  String formatTotalWeightGain(WeightUnit unit) {
    return WeightConverter.formatWeightDifference(totalWeightGainGrams, unit);
  }

  /// Format average weight gain for display
  String formatAverageWeightGain(WeightUnit unit) {
    return WeightConverter.formatWeightDifference(averageWeightGainGrams, unit);
  }
}
