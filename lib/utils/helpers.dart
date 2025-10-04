/// Utility functions for formatting and data manipulation.
library;

import 'package:intl/intl.dart';

class DateTimeHelpers {
  /// Formats a DateTime to a human-readable date string.
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats a DateTime to a human-readable date and time string.
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  /// Formats a DateTime to a short time string.
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Formats a DateTime to a relative time string (e.g., "2 hours ago").
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if the date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if the date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

class WeightHelpers {
  /// Converts grams to ounces.
  static double gramsToOunces(double grams) {
    return grams * 0.035274;
  }

  /// Converts ounces to grams.
  static double ouncesToGrams(double ounces) {
    return ounces / 0.035274;
  }

  /// Formats weight with appropriate unit.
  static String formatWeight(double weightInGrams, {bool useOunces = false}) {
    if (useOunces) {
      final ounces = gramsToOunces(weightInGrams);
      return '${ounces.toStringAsFixed(2)} oz';
    } else {
      return '${weightInGrams.toStringAsFixed(1)} g';
    }
  }

  /// Calculates weight gain percentage.
  static double? calculateWeightGainPercentage(
    double? currentWeight,
    double? admissionWeight,
  ) {
    if (currentWeight == null ||
        admissionWeight == null ||
        admissionWeight == 0) {
      return null;
    }
    return ((currentWeight - admissionWeight) / admissionWeight) * 100;
  }

  /// Formats weight gain with appropriate sign and color coding.
  static String formatWeightGain(double? gain) {
    if (gain == null) return 'N/A';
    final sign = gain >= 0 ? '+' : '';
    return '$sign${gain.toStringAsFixed(1)} g';
  }
}

class FeedingHelpers {
  /// Converts milliliters to fluid ounces.
  static double mlToFluidOunces(double ml) {
    return ml * 0.033814;
  }

  /// Converts fluid ounces to milliliters.
  static double fluidOuncesToMl(double fluidOunces) {
    return fluidOunces / 0.033814;
  }

  /// Formats feeding amount with appropriate unit.
  static String formatFeedingAmount(double? amount, String unit) {
    if (amount == null) return 'N/A';

    switch (unit) {
      case 'ml':
        return '${amount.toStringAsFixed(1)} ml';
      case 'oz':
        return '${amount.toStringAsFixed(2)} fl oz';
      case 'g':
        return '${amount.toStringAsFixed(1)} g';
      case 'pieces':
        return '${amount.toInt()} pcs';
      default:
        return '${amount.toStringAsFixed(1)} $unit';
    }
  }

  /// Calculates recommended feeding amount based on weight and age.
  /// This is a simplified formula - real calculations would be more complex.
  static double calculateRecommendedFeedingAmount(
    double weightInGrams,
    int ageInDays,
  ) {
    // Very simplified formula for demonstration
    // Real formula would depend on species, health status, etc.
    double baseAmount = weightInGrams * 0.05; // 5% of body weight

    // Age factor: younger squirrels need more frequent, smaller amounts
    if (ageInDays < 14) {
      baseAmount *= 0.8; // Smaller amounts for very young
    } else if (ageInDays < 28) {
      baseAmount *= 1.0; // Standard amount
    } else {
      baseAmount *= 1.2; // Larger amounts for older squirrels
    }

    return baseAmount;
  }

  /// Calculates time until next feeding based on last feeding and interval.
  static Duration? timeUntilNextFeeding(
    DateTime? lastFeeding,
    int intervalHours,
  ) {
    if (lastFeeding == null) return null;

    final nextFeeding = lastFeeding.add(Duration(hours: intervalHours));
    final now = DateTime.now();

    if (nextFeeding.isBefore(now)) {
      return Duration.zero; // Feeding is overdue
    }

    return nextFeeding.difference(now);
  }
}

class ValidationHelpers {
  /// Validates that a string is not null or empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a weight value is positive.
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 1000) {
      return 'Weight seems too high (max 1000g)';
    }

    return null;
  }

  /// Validates that a feeding amount is positive.
  static String? validateFeedingAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Amount is optional
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 100) {
      return 'Amount seems too high (max 100ml)';
    }

    return null;
  }

  /// Validates that a date is not in the future.
  static String? validatePastDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Date cannot be in the future';
    }

    // Check if date is not too far in the past (more than 1 year)
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (date.isBefore(oneYearAgo)) {
      return 'Date cannot be more than 1 year ago';
    }

    return null;
  }
}

class StringHelpers {
  /// Capitalizes the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Truncates a string to a maximum length with ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formats a squirrel name for display.
  static String formatSquirrelName(String name) {
    return capitalize(name.trim());
  }
}
