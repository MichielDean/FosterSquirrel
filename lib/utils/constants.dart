/// Application constants and configuration values.
library;

/// Database related constants
class DatabaseConstants {
  static const String databaseName = 'squirrel_tracker.db';
  static const int databaseVersion = 1;

  // Table names
  static const String squirrelsTable = 'squirrels';
  static const String weightRecordsTable = 'weight_records';
  static const String feedingRecordsTable = 'feeding_records';
  static const String careNotesTable = 'care_notes';
}

/// App configuration constants
class AppConstants {
  static const String appName = 'FosterSquirrel';
  static const String appVersion = '1.0.0';

  // Weight units
  static const String defaultWeightUnit = 'grams';
  static const double gramsToOunces = 0.035274;

  // Feeding units
  static const String defaultFeedingUnit = 'ml';
  static const double mlToFluidOunces = 0.033814;

  // Default feeding interval in hours
  static const int defaultFeedingIntervalHours = 2;

  // Photo storage
  static const String photoDirectory = 'squirrel_photos';
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024; // 5MB

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Shared preferences keys
class PreferencesKeys {
  static const String firstLaunch = 'first_launch';
  static const String backupEnabled = 'backup_enabled';
  static const String backupFrequency = 'backup_frequency';
  static const String defaultWeightUnit = 'default_weight_unit';
  static const String defaultFeedingUnit = 'default_feeding_unit';
  static const String feedingReminderEnabled = 'feeding_reminder_enabled';
  static const String lastBackupDate = 'last_backup_date';
  static const String themeMode = 'theme_mode';
}
