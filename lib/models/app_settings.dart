import '../utils/weight_converter.dart';

/// User settings and preferences for the squirrel feeding app
///
/// This stores configurable options like weight units, display preferences,
/// notification settings, etc.
class AppSettings {
  const AppSettings({
    this.defaultWeightUnit = WeightUnit.grams,
    this.showWeightInMultipleUnits = true,
    this.enableFeedingReminders = true,
    this.feedingReminderIntervalHours = 3,
    this.enableWeightAlerts = true,
    this.weightLossAlertThreshold = 5.0, // percentage
    this.darkMode = false,
    this.compactView = false,
    this.autoBackup = true,
    this.autoBackupIntervalDays = 7,
    this.showFeedingTips = true,
    this.confirmDeleteActions = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    DateTime? lastBackupDate,
  }) : _lastBackupDate = lastBackupDate;

  /// Default weight unit for display and input
  final WeightUnit defaultWeightUnit;

  /// Whether to show weights in multiple units simultaneously
  final bool showWeightInMultipleUnits;

  /// Whether to enable feeding reminder notifications
  final bool enableFeedingReminders;

  /// How often to remind about feeding (in hours)
  final int feedingReminderIntervalHours;

  /// Whether to enable weight loss alerts
  final bool enableWeightAlerts;

  /// Weight loss threshold for alerts (percentage)
  final double weightLossAlertThreshold;

  /// Use dark mode theme
  final bool darkMode;

  /// Use compact view for lists
  final bool compactView;

  /// Enable automatic backups
  final bool autoBackup;

  /// How often to backup (in days)
  final int autoBackupIntervalDays;

  /// Show feeding tips and guidance
  final bool showFeedingTips;

  /// Require confirmation for delete actions
  final bool confirmDeleteActions;

  /// Enable sound notifications
  final bool soundEnabled;

  /// Enable vibration for notifications
  final bool vibrationEnabled;

  /// Internal last backup timestamp
  final DateTime? _lastBackupDate;

  /// When the last backup was performed
  DateTime get lastBackupDate => _lastBackupDate ?? DateTime.now();

  /// Check if backup is overdue
  bool get isBackupOverdue {
    if (!autoBackup) return false;
    final daysSinceBackup = DateTime.now().difference(lastBackupDate).inDays;
    return daysSinceBackup >= autoBackupIntervalDays;
  }

  /// Get formatted weight display preferences
  String formatWeightWithPreferences(double weightInGrams) {
    if (showWeightInMultipleUnits) {
      final primary = WeightConverter.formatWeight(
        weightInGrams,
        defaultWeightUnit,
      );

      // Show secondary unit based on primary
      final WeightUnit secondaryUnit = defaultWeightUnit == WeightUnit.grams
          ? WeightUnit.ounces
          : WeightUnit.grams;
      final secondary = WeightConverter.formatWeight(
        weightInGrams,
        secondaryUnit,
      );

      return '$primary ($secondary)';
    } else {
      return WeightConverter.formatWeight(weightInGrams, defaultWeightUnit);
    }
  }

  /// Get feeding reminder text based on settings
  String getFeedingReminderText(String squirrelName) {
    if (!enableFeedingReminders) return '';

    final intervalText = feedingReminderIntervalHours == 1
        ? 'hour'
        : '$feedingReminderIntervalHours hours';

    return 'Time to feed $squirrelName! (Every $intervalText)';
  }

  /// Check if weight loss should trigger an alert
  bool shouldAlertForWeightLoss(double weightLossPercentage) {
    return enableWeightAlerts &&
        weightLossPercentage >= weightLossAlertThreshold;
  }

  /// Copy settings with updated values
  AppSettings copyWith({
    WeightUnit? defaultWeightUnit,
    bool? showWeightInMultipleUnits,
    bool? enableFeedingReminders,
    int? feedingReminderIntervalHours,
    bool? enableWeightAlerts,
    double? weightLossAlertThreshold,
    bool? darkMode,
    bool? compactView,
    bool? autoBackup,
    int? autoBackupIntervalDays,
    bool? showFeedingTips,
    bool? confirmDeleteActions,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? lastBackupDate,
  }) {
    return AppSettings(
      defaultWeightUnit: defaultWeightUnit ?? this.defaultWeightUnit,
      showWeightInMultipleUnits:
          showWeightInMultipleUnits ?? this.showWeightInMultipleUnits,
      enableFeedingReminders:
          enableFeedingReminders ?? this.enableFeedingReminders,
      feedingReminderIntervalHours:
          feedingReminderIntervalHours ?? this.feedingReminderIntervalHours,
      enableWeightAlerts: enableWeightAlerts ?? this.enableWeightAlerts,
      weightLossAlertThreshold:
          weightLossAlertThreshold ?? this.weightLossAlertThreshold,
      darkMode: darkMode ?? this.darkMode,
      compactView: compactView ?? this.compactView,
      autoBackup: autoBackup ?? this.autoBackup,
      autoBackupIntervalDays:
          autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      showFeedingTips: showFeedingTips ?? this.showFeedingTips,
      confirmDeleteActions: confirmDeleteActions ?? this.confirmDeleteActions,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'default_weight_unit': defaultWeightUnit.name,
      'show_weight_in_multiple_units': showWeightInMultipleUnits,
      'enable_feeding_reminders': enableFeedingReminders,
      'feeding_reminder_interval_hours': feedingReminderIntervalHours,
      'enable_weight_alerts': enableWeightAlerts,
      'weight_loss_alert_threshold': weightLossAlertThreshold,
      'dark_mode': darkMode,
      'compact_view': compactView,
      'auto_backup': autoBackup,
      'auto_backup_interval_days': autoBackupIntervalDays,
      'show_feeding_tips': showFeedingTips,
      'confirm_delete_actions': confirmDeleteActions,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'last_backup_date': lastBackupDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultWeightUnit: WeightUnit.fromString(
        json['default_weight_unit'] as String? ?? 'grams',
      ),
      showWeightInMultipleUnits:
          json['show_weight_in_multiple_units'] as bool? ?? true,
      enableFeedingReminders: json['enable_feeding_reminders'] as bool? ?? true,
      feedingReminderIntervalHours:
          json['feeding_reminder_interval_hours'] as int? ?? 3,
      enableWeightAlerts: json['enable_weight_alerts'] as bool? ?? true,
      weightLossAlertThreshold:
          (json['weight_loss_alert_threshold'] as num?)?.toDouble() ?? 5.0,
      darkMode: json['dark_mode'] as bool? ?? false,
      compactView: json['compact_view'] as bool? ?? false,
      autoBackup: json['auto_backup'] as bool? ?? true,
      autoBackupIntervalDays: json['auto_backup_interval_days'] as int? ?? 7,
      showFeedingTips: json['show_feeding_tips'] as bool? ?? true,
      confirmDeleteActions: json['confirm_delete_actions'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      lastBackupDate: json['last_backup_date'] != null
          ? DateTime.parse(json['last_backup_date'] as String)
          : null,
    );
  }

  /// Create default settings
  factory AppSettings.defaults() {
    return const AppSettings();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.defaultWeightUnit == defaultWeightUnit &&
        other.showWeightInMultipleUnits == showWeightInMultipleUnits &&
        other.enableFeedingReminders == enableFeedingReminders &&
        other.feedingReminderIntervalHours == feedingReminderIntervalHours &&
        other.enableWeightAlerts == enableWeightAlerts &&
        other.weightLossAlertThreshold == weightLossAlertThreshold &&
        other.darkMode == darkMode &&
        other.compactView == compactView &&
        other.autoBackup == autoBackup &&
        other.autoBackupIntervalDays == autoBackupIntervalDays &&
        other.showFeedingTips == showFeedingTips &&
        other.confirmDeleteActions == confirmDeleteActions &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.lastBackupDate == lastBackupDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      defaultWeightUnit,
      showWeightInMultipleUnits,
      enableFeedingReminders,
      feedingReminderIntervalHours,
      enableWeightAlerts,
      weightLossAlertThreshold,
      darkMode,
      compactView,
      autoBackup,
      autoBackupIntervalDays,
      showFeedingTips,
      confirmDeleteActions,
      soundEnabled,
      vibrationEnabled,
      lastBackupDate,
    );
  }

  @override
  String toString() {
    return 'AppSettings(defaultWeightUnit: $defaultWeightUnit, darkMode: $darkMode, feedingReminders: $enableFeedingReminders)';
  }
}

/// Settings category for organizing preferences in UI
enum SettingsCategory {
  display('Display', 'Theme, units, and visual preferences'),
  feeding('Feeding', 'Reminders, alerts, and feeding settings'),
  data('Data & Backup', 'Storage, backup, and data management'),
  notifications('Notifications', 'Sounds, alerts, and reminders'),
  advanced('Advanced', 'Advanced options and troubleshooting');

  const SettingsCategory(this.title, this.description);

  final String title;
  final String description;
}

/// Individual setting item for building settings UI
class SettingItem {
  const SettingItem({
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.currentValue,
    this.options,
    this.min,
    this.max,
    this.enabled = true,
  });

  final String key;
  final String title;
  final String description;
  final SettingsCategory category;
  final SettingType type;
  final dynamic currentValue;
  final List<String>? options; // For dropdown/radio settings
  final double? min; // For slider/number settings
  final double? max; // For slider/number settings
  final bool enabled;

  SettingItem copyWith({
    String? key,
    String? title,
    String? description,
    SettingsCategory? category,
    SettingType? type,
    dynamic currentValue,
    List<String>? options,
    double? min,
    double? max,
    bool? enabled,
  }) {
    return SettingItem(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      options: options ?? this.options,
      min: min ?? this.min,
      max: max ?? this.max,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// Types of setting controls
enum SettingType {
  toggle, // Switch/checkbox
  dropdown, // Dropdown/picker
  slider, // Numeric slider
  text, // Text input
  button, // Action button
}
