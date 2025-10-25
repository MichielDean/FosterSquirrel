/// Represents the feeding schedule requirements for a baby squirrel
/// based on accurate veterinary guidelines
class FeedingSchedule {
  const FeedingSchedule({
    required this.ageWeeks,
    required this.weightRangeGrams,
    required this.feedingIntervalHours,
    required this.amountPerFeedingML,
    required this.requiresNightFeeding,
    required this.maxNightGapHours,
    required this.additionalComments,
  });

  /// Approximate age in weeks
  final String ageWeeks;

  /// Weight range for this schedule (min-max grams)
  final (double min, double max) weightRangeGrams;

  /// Hours between feedings during the day
  final double feedingIntervalHours;

  /// Amount per feeding in ML/CC
  final (double min, double max) amountPerFeedingML;

  /// Whether night feedings are required
  final bool requiresNightFeeding;

  /// Maximum hours between feedings at night
  final int maxNightGapHours;

  /// Additional care instructions
  final String additionalComments;

  /// Get the feeding schedule for a given weight
  static FeedingSchedule getScheduleForWeight(double weightGrams) {
    // Based on the accurate feeding table
    if (weightGrams >= 10 && weightGrams <= 20) {
      return const FeedingSchedule(
        ageWeeks: '0-1 weeks',
        weightRangeGrams: (10, 20),
        feedingIntervalHours: 2.5, // every 2-3 hours
        amountPerFeedingML: (0.5, 0.5),
        requiresNightFeeding: true,
        maxNightGapHours: 6,
        additionalComments: 'At least one feeding at night',
      );
    } else if (weightGrams >= 20 && weightGrams <= 40) {
      return const FeedingSchedule(
        ageWeeks: '1-2 weeks',
        weightRangeGrams: (20, 40),
        feedingIntervalHours: 2.5, // every 2-3 hours
        amountPerFeedingML: (0.75, 1.0),
        requiresNightFeeding: true,
        maxNightGapHours: 6,
        additionalComments: 'At least one feeding at night',
      );
    } else if (weightGrams >= 40 && weightGrams <= 60) {
      return const FeedingSchedule(
        ageWeeks: '2-3 weeks',
        weightRangeGrams: (40, 60),
        feedingIntervalHours: 3.0, // every 3 hours
        amountPerFeedingML: (2.0, 3.0),
        requiresNightFeeding: true,
        maxNightGapHours: 6,
        additionalComments: 'Night feedings until umbilical cord heals',
      );
    } else if (weightGrams >= 60 && weightGrams <= 80) {
      return const FeedingSchedule(
        ageWeeks: '3-4 weeks',
        weightRangeGrams: (60, 80),
        feedingIntervalHours: 3.5, // every 3-4 hours
        amountPerFeedingML: (3.0, 4.0),
        requiresNightFeeding: true,
        maxNightGapHours: 6,
        additionalComments: 'Night feedings until umbilical cord heals',
      );
    } else if (weightGrams >= 80 && weightGrams <= 120) {
      return const FeedingSchedule(
        ageWeeks: '4-5 weeks',
        weightRangeGrams: (80, 120),
        feedingIntervalHours: 4.0, // every 4 hours
        amountPerFeedingML: (4.0, 5.0),
        requiresNightFeeding: true,
        maxNightGapHours: 8,
        additionalComments:
            'Can go up to 8 hours at night if umbilical cord healed',
      );
    } else if (weightGrams >= 120 && weightGrams <= 160) {
      return const FeedingSchedule(
        ageWeeks: '5-7 weeks',
        weightRangeGrams: (120, 160),
        feedingIntervalHours: 4.5, // every 4-5 hours
        amountPerFeedingML: (6.0, 8.0),
        requiresNightFeeding: false,
        maxNightGapHours: 8,
        additionalComments: 'Can go up to 8 hours at night',
      );
    } else if (weightGrams >= 160 && weightGrams <= 240) {
      return const FeedingSchedule(
        ageWeeks: '7-8 weeks',
        weightRangeGrams: (160, 240),
        feedingIntervalHours: 8.0, // 3x per day
        amountPerFeedingML: (8.0, 12.0),
        requiresNightFeeding: false,
        maxNightGapHours: 10,
        additionalComments:
            'Free feed solid food. Offer fresh solid food and water',
      );
    } else if (weightGrams >= 240 && weightGrams <= 400) {
      return const FeedingSchedule(
        ageWeeks: '8-10 weeks',
        weightRangeGrams: (240, 400),
        feedingIntervalHours: 12.0, // 1-2x per day
        amountPerFeedingML: (15.0, 20.0),
        requiresNightFeeding: false,
        maxNightGapHours: 12,
        additionalComments: 'Start weaning. Offer fresh food and water',
      );
    } else if (weightGrams >= 400) {
      return const FeedingSchedule(
        ageWeeks: '10-12+ weeks',
        weightRangeGrams: (400, 600),
        feedingIntervalHours: 24.0, // 0-1x per day
        amountPerFeedingML: (0.0, 5.0),
        requiresNightFeeding: false,
        maxNightGapHours: 24,
        additionalComments: 'Wean. Always supply fresh food and water',
      );
    } else {
      // Very small squirrel - treat as newborn
      return const FeedingSchedule(
        ageWeeks: '0-1 weeks',
        weightRangeGrams: (5, 10),
        feedingIntervalHours: 2.0, // every 2 hours
        amountPerFeedingML: (0.25, 0.5),
        requiresNightFeeding: true,
        maxNightGapHours: 3,
        additionalComments: 'Very small baby - frequent feedings required',
      );
    }
  }

  /// Calculate the recommended amount for a specific weight within the range
  double getRecommendedAmountForWeight(double weightGrams) {
    final (minWeight, maxWeight) = weightRangeGrams;
    final (minAmount, maxAmount) = amountPerFeedingML;

    if (weightGrams <= minWeight) return minAmount;
    if (weightGrams >= maxWeight) return maxAmount;

    // Linear interpolation within the range
    final ratio = (weightGrams - minWeight) / (maxWeight - minWeight);
    return minAmount + (ratio * (maxAmount - minAmount));
  }

  /// Get next feeding time based on current time and schedule
  DateTime getNextFeedingTime({
    DateTime? currentTime,
    DateTime? lastFeedingTime,
    bool isNightTime = false,
  }) {
    final now = currentTime ?? DateTime.now();
    final lastFeeding = lastFeedingTime ?? now;

    // Calculate interval based on time of day
    double intervalHours = feedingIntervalHours;

    // Adjust for night time if applicable
    if (isNightTime && !requiresNightFeeding) {
      intervalHours = maxNightGapHours.toDouble();
    }

    return lastFeeding.add(
      Duration(
        hours: intervalHours.floor(),
        minutes: ((intervalHours - intervalHours.floor()) * 60).round(),
      ),
    );
  }

  /// Check if feeding is overdue
  bool isFeedingOverdue({
    required DateTime lastFeedingTime,
    DateTime? currentTime,
    bool isNightTime = false,
  }) {
    final now = currentTime ?? DateTime.now();
    final nextFeedingTime = getNextFeedingTime(
      currentTime: now,
      lastFeedingTime: lastFeedingTime,
      isNightTime: isNightTime,
    );

    // Allow some flexibility: +/- 30 minutes for young squirrels, +/- 1 hour for older
    final flexibilityMinutes = weightRangeGrams.$2 < 120 ? 30 : 60;
    final overdueThreshold = nextFeedingTime.add(
      Duration(minutes: flexibilityMinutes),
    );

    return now.isAfter(overdueThreshold);
  }

  /// Check if it's currently night time (for feeding schedule purposes)
  static bool isNightTime({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    // Consider 10 PM to 6 AM as night time
    return hour >= 22 || hour < 6;
  }

  /// Format the feeding schedule for display
  String formatScheduleInfo() {
    final (minAmount, maxAmount) = amountPerFeedingML;
    final amountStr = minAmount == maxAmount
        ? '${minAmount.toStringAsFixed(1)} ml'
        : '${minAmount.toStringAsFixed(1)}-${maxAmount.toStringAsFixed(1)} ml';

    return '$ageWeeks (${weightRangeGrams.$1.toInt()}-${weightRangeGrams.$2.toInt()}g): '
        'Every ${feedingIntervalHours.toStringAsFixed(1)} hours, $amountStr';
  }

  /// Get feeding reminders for the day
  List<DateTime> getDailyFeedingTimes({
    DateTime? startDate,
    DateTime? lastFeedingTime,
  }) {
    final start = startDate ?? DateTime.now();
    final dayStart = DateTime(
      start.year,
      start.month,
      start.day,
      6,
    ); // Start at 6 AM
    final dayEnd = DateTime(
      start.year,
      start.month,
      start.day,
      22,
    ); // End at 10 PM

    final feedingTimes = <DateTime>[];
    DateTime currentFeedingTime = lastFeedingTime ?? dayStart;

    // Generate feeding times for the day
    while (currentFeedingTime.isBefore(dayEnd)) {
      if (currentFeedingTime.isAfter(dayStart)) {
        feedingTimes.add(currentFeedingTime);
      }

      currentFeedingTime = getNextFeedingTime(
        currentTime: currentFeedingTime,
        lastFeedingTime: currentFeedingTime,
        isNightTime: false,
      );
    }

    // Add night feeding if required
    if (requiresNightFeeding) {
      final nightFeeding = DateTime(
        start.year,
        start.month,
        start.day,
        2,
      ); // 2 AM
      feedingTimes.add(nightFeeding);
    }

    return feedingTimes..sort();
  }

  @override
  String toString() {
    return 'FeedingSchedule($ageWeeks, ${weightRangeGrams.$1.toInt()}-${weightRangeGrams.$2.toInt()}g, '
        'every ${feedingIntervalHours}h, ${amountPerFeedingML.$1}-${amountPerFeedingML.$2}ml)';
  }
}

/// Feeding reminder notification details
class FeedingReminder {
  const FeedingReminder({
    required this.squirrelId,
    required this.squirrelName,
    required this.scheduledTime,
    required this.recommendedAmountML,
    required this.isOverdue,
    required this.schedule,
    this.lastFeedingTime,
  });

  final String squirrelId;
  final String squirrelName;
  final DateTime scheduledTime;
  final double recommendedAmountML;
  final bool isOverdue;
  final FeedingSchedule schedule;
  final DateTime? lastFeedingTime;

  /// Format reminder message for notification
  String formatReminderMessage() {
    final timeStr = _formatTime(scheduledTime);
    final amountStr = '${recommendedAmountML.toStringAsFixed(1)} ml';

    if (isOverdue) {
      final overdueMinutes = DateTime.now().difference(scheduledTime).inMinutes;
      return '⚠️ OVERDUE: $squirrelName feeding was due at $timeStr '
          '($overdueMinutes min ago) - $amountStr';
    } else {
      return '🐿️ Time to feed $squirrelName! Due: $timeStr - $amountStr';
    }
  }

  /// Format reminder title for notification
  String formatReminderTitle() {
    return isOverdue
        ? 'Overdue Feeding - $squirrelName'
        : 'Feeding Time - $squirrelName';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
