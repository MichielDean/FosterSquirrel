/// Weight unit conversions and formatting utilities for the squirrel feeding app
///
/// This handles conversions between grams, pounds, and ounces with proper
/// precision for small baby squirrel weights.
library;

enum WeightUnit {
  grams('g', 'Grams'),
  pounds('lbs', 'Pounds'),
  ounces('oz', 'Ounces');

  const WeightUnit(this.symbol, this.displayName);

  final String symbol;
  final String displayName;

  static WeightUnit fromString(String value) {
    return WeightUnit.values.firstWhere(
      (unit) => unit.name == value || unit.symbol == value,
      orElse: () => WeightUnit.grams,
    );
  }

  @override
  String toString() => symbol;
}

/// Utility class for weight conversions and formatting
///
/// All internal storage is in grams for consistency, with conversions
/// performed for display purposes.
class WeightConverter {
  // Conversion constants
  static const double _gramsPerPound = 453.592;
  static const double _gramsPerOunce = 28.3495;

  /// Convert weight from grams to the specified unit
  static double fromGrams(double grams, WeightUnit targetUnit) {
    switch (targetUnit) {
      case WeightUnit.grams:
        return grams;
      case WeightUnit.pounds:
        return grams / _gramsPerPound;
      case WeightUnit.ounces:
        return grams / _gramsPerOunce;
    }
  }

  /// Convert weight from the specified unit to grams
  static double toGrams(double weight, WeightUnit sourceUnit) {
    switch (sourceUnit) {
      case WeightUnit.grams:
        return weight;
      case WeightUnit.pounds:
        return weight * _gramsPerPound;
      case WeightUnit.ounces:
        return weight * _gramsPerOunce;
    }
  }

  /// Format weight with appropriate precision for the unit
  ///
  /// - Grams: 1 decimal place (e.g., "15.5 g")
  /// - Pounds: 3 decimal places (e.g., "0.034 lbs")
  /// - Ounces: 2 decimal places (e.g., "0.55 oz")
  static String formatWeight(
    double grams,
    WeightUnit displayUnit, {
    bool includeUnit = true,
  }) {
    final convertedWeight = fromGrams(grams, displayUnit);
    final String formatted;

    switch (displayUnit) {
      case WeightUnit.grams:
        formatted = convertedWeight.toStringAsFixed(1);
        break;
      case WeightUnit.pounds:
        formatted = convertedWeight.toStringAsFixed(3);
        break;
      case WeightUnit.ounces:
        formatted = convertedWeight.toStringAsFixed(2);
        break;
    }

    return includeUnit ? '$formatted ${displayUnit.symbol}' : formatted;
  }

  /// Format weight difference with +/- prefix
  ///
  /// Shows weight gain/loss clearly with appropriate sign
  static String formatWeightDifference(
    double gramsChange,
    WeightUnit displayUnit,
  ) {
    final formatted = formatWeight(
      gramsChange.abs(),
      displayUnit,
      includeUnit: true,
    );
    final sign = gramsChange >= 0 ? '+' : '-';
    return '$sign$formatted';
  }

  /// Get appropriate precision for weight input based on unit
  ///
  /// Returns number of decimal places to show in input fields
  static int getPrecisionForUnit(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.grams:
        return 1;
      case WeightUnit.pounds:
        return 3;
      case WeightUnit.ounces:
        return 2;
    }
  }

  /// Get step size for weight input controls
  ///
  /// Returns appropriate increment/decrement step for UI controls
  static double getStepSizeForUnit(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.grams:
        return 0.1; // 0.1 gram steps
      case WeightUnit.pounds:
        return 0.001; // 0.001 pound steps
      case WeightUnit.ounces:
        return 0.01; // 0.01 ounce steps
    }
  }

  /// Parse weight string input and convert to grams
  ///
  /// Handles various input formats and returns weight in grams
  /// Throws FormatException if input is invalid
  static double parseWeightToGrams(String input, WeightUnit inputUnit) {
    // Remove unit symbols and extra whitespace
    String cleanInput = input.replaceAll(RegExp(r'[a-zA-Z\s]'), '').trim();

    if (cleanInput.isEmpty) {
      throw const FormatException('Weight input cannot be empty');
    }

    final weight = double.tryParse(cleanInput);
    if (weight == null) {
      throw FormatException('Invalid weight format: $input');
    }

    if (weight < 0) {
      throw const FormatException('Weight cannot be negative');
    }

    return toGrams(weight, inputUnit);
  }

  /// Validate that weight is reasonable for baby squirrels
  ///
  /// Baby squirrels typically range from 5-200 grams depending on age
  static bool isValidSquirrelWeight(double grams) {
    return grams >= 0.1 && grams <= 1000.0; // 0.1g to 1kg range
  }

  /// Get suggested feeding amount in milligrams based on weight
  ///
  /// General guideline: 5-7% of body weight per feeding for baby squirrels
  /// Returns amount in milligrams
  static double getSuggestedFeedingAmount(double weightInGrams) {
    // Convert to milligrams and calculate 6% of body weight
    const double feedingPercentage = 0.06;
    return (weightInGrams * 1000) * feedingPercentage;
  }
}
