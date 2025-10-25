import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../utils/weight_converter.dart';

/// Repository for managing application settings and user preferences
///
/// Uses SharedPreferences for local storage of settings data
class SettingsRepository {
  static const String _settingsKey = 'app_settings';

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load settings from storage
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await _preferences;
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        // Return default settings if none exist
        return AppSettings.defaults();
      }

      final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
      return AppSettings.fromJson(settingsMap);
    } catch (e) {
      // If there's an error loading settings, return defaults
      return AppSettings.defaults();
    }
  }

  /// Save settings to storage
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await _preferences;
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw SettingsRepositoryException('Failed to save settings: $e');
    }
  }

  /// Update a specific setting value
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final currentSettings = await loadSettings();
      AppSettings updatedSettings;

      switch (key) {
        case 'defaultWeightUnit':
          updatedSettings = currentSettings.copyWith(
            defaultWeightUnit: WeightUnit.fromString(value.toString()),
          );
          break;
        case 'showWeightInMultipleUnits':
          updatedSettings = currentSettings.copyWith(
            showWeightInMultipleUnits: value as bool,
          );
          break;
        case 'enableFeedingReminders':
          updatedSettings = currentSettings.copyWith(
            enableFeedingReminders: value as bool,
          );
          break;
        case 'feedingReminderIntervalHours':
          updatedSettings = currentSettings.copyWith(
            feedingReminderIntervalHours: value as int,
          );
          break;
        case 'enableWeightAlerts':
          updatedSettings = currentSettings.copyWith(
            enableWeightAlerts: value as bool,
          );
          break;
        case 'weightLossAlertThreshold':
          updatedSettings = currentSettings.copyWith(
            weightLossAlertThreshold: (value as num).toDouble(),
          );
          break;
        case 'darkMode':
          updatedSettings = currentSettings.copyWith(darkMode: value as bool);
          break;
        case 'compactView':
          updatedSettings = currentSettings.copyWith(
            compactView: value as bool,
          );
          break;
        case 'autoBackup':
          updatedSettings = currentSettings.copyWith(autoBackup: value as bool);
          break;
        case 'autoBackupIntervalDays':
          updatedSettings = currentSettings.copyWith(
            autoBackupIntervalDays: value as int,
          );
          break;
        case 'showFeedingTips':
          updatedSettings = currentSettings.copyWith(
            showFeedingTips: value as bool,
          );
          break;
        case 'confirmDeleteActions':
          updatedSettings = currentSettings.copyWith(
            confirmDeleteActions: value as bool,
          );
          break;
        case 'soundEnabled':
          updatedSettings = currentSettings.copyWith(
            soundEnabled: value as bool,
          );
          break;
        case 'vibrationEnabled':
          updatedSettings = currentSettings.copyWith(
            vibrationEnabled: value as bool,
          );
          break;
        case 'lastBackupDate':
          updatedSettings = currentSettings.copyWith(
            lastBackupDate: value as DateTime,
          );
          break;
        default:
          throw SettingsRepositoryException('Unknown setting key: $key');
      }

      await saveSettings(updatedSettings);
    } catch (e) {
      throw SettingsRepositoryException('Failed to update setting $key: $e');
    }
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await saveSettings(AppSettings.defaults());
    } catch (e) {
      throw SettingsRepositoryException('Failed to reset settings: $e');
    }
  }

  /// Get all available setting items for building UI
  Future<List<SettingItem>> getSettingItems() async {
    final settings = await loadSettings();

    return [
      // Display settings
      SettingItem(
        key: 'defaultWeightUnit',
        title: 'Default Weight Unit',
        description: 'Primary unit for displaying weights',
        category: SettingsCategory.display,
        type: SettingType.dropdown,
        currentValue: settings.defaultWeightUnit.displayName,
        options: WeightUnit.values.map((unit) => unit.displayName).toList(),
      ),
      SettingItem(
        key: 'showWeightInMultipleUnits',
        title: 'Show Multiple Weight Units',
        description: 'Display weights in both primary and secondary units',
        category: SettingsCategory.display,
        type: SettingType.toggle,
        currentValue: settings.showWeightInMultipleUnits,
      ),
      SettingItem(
        key: 'darkMode',
        title: 'Dark Mode',
        description: 'Use dark theme for the app interface',
        category: SettingsCategory.display,
        type: SettingType.toggle,
        currentValue: settings.darkMode,
      ),
      SettingItem(
        key: 'compactView',
        title: 'Compact View',
        description: 'Use more condensed layouts to fit more information',
        category: SettingsCategory.display,
        type: SettingType.toggle,
        currentValue: settings.compactView,
      ),

      // Feeding settings
      SettingItem(
        key: 'enableFeedingReminders',
        title: 'Feeding Reminders',
        description: 'Get notifications when it\'s time to feed squirrels',
        category: SettingsCategory.feeding,
        type: SettingType.toggle,
        currentValue: settings.enableFeedingReminders,
      ),
      SettingItem(
        key: 'feedingReminderIntervalHours',
        title: 'Reminder Interval',
        description: 'Hours between feeding reminders',
        category: SettingsCategory.feeding,
        type: SettingType.slider,
        currentValue: settings.feedingReminderIntervalHours.toDouble(),
        min: 1.0,
        max: 12.0,
        enabled: settings.enableFeedingReminders,
      ),
      SettingItem(
        key: 'enableWeightAlerts',
        title: 'Weight Loss Alerts',
        description: 'Get alerts when squirrels lose significant weight',
        category: SettingsCategory.feeding,
        type: SettingType.toggle,
        currentValue: settings.enableWeightAlerts,
      ),
      SettingItem(
        key: 'weightLossAlertThreshold',
        title: 'Weight Loss Threshold',
        description: 'Percentage of weight loss that triggers an alert',
        category: SettingsCategory.feeding,
        type: SettingType.slider,
        currentValue: settings.weightLossAlertThreshold,
        min: 1.0,
        max: 20.0,
        enabled: settings.enableWeightAlerts,
      ),
      SettingItem(
        key: 'showFeedingTips',
        title: 'Show Feeding Tips',
        description: 'Display helpful tips and guidance',
        category: SettingsCategory.feeding,
        type: SettingType.toggle,
        currentValue: settings.showFeedingTips,
      ),

      // Data & Backup settings
      SettingItem(
        key: 'autoBackup',
        title: 'Automatic Backup',
        description: 'Automatically backup your data',
        category: SettingsCategory.data,
        type: SettingType.toggle,
        currentValue: settings.autoBackup,
      ),
      SettingItem(
        key: 'autoBackupIntervalDays',
        title: 'Backup Frequency',
        description: 'Days between automatic backups',
        category: SettingsCategory.data,
        type: SettingType.slider,
        currentValue: settings.autoBackupIntervalDays.toDouble(),
        min: 1.0,
        max: 30.0,
        enabled: settings.autoBackup,
      ),
      SettingItem(
        key: 'confirmDeleteActions',
        title: 'Confirm Deletions',
        description: 'Require confirmation before deleting data',
        category: SettingsCategory.data,
        type: SettingType.toggle,
        currentValue: settings.confirmDeleteActions,
      ),

      // Notification settings
      SettingItem(
        key: 'soundEnabled',
        title: 'Sound Notifications',
        description: 'Play sounds for alerts and reminders',
        category: SettingsCategory.notifications,
        type: SettingType.toggle,
        currentValue: settings.soundEnabled,
      ),
      SettingItem(
        key: 'vibrationEnabled',
        title: 'Vibration',
        description: 'Use vibration for notifications',
        category: SettingsCategory.notifications,
        type: SettingType.toggle,
        currentValue: settings.vibrationEnabled,
      ),
    ];
  }

  /// Get settings grouped by category
  Future<Map<SettingsCategory, List<SettingItem>>>
  getSettingsByCategory() async {
    final allSettings = await getSettingItems();
    final Map<SettingsCategory, List<SettingItem>> categorized = {};

    for (final setting in allSettings) {
      if (!categorized.containsKey(setting.category)) {
        categorized[setting.category] = [];
      }
      categorized[setting.category]!.add(setting);
    }

    return categorized;
  }

  /// Update the last backup date
  Future<void> updateLastBackupDate() async {
    await updateSetting('lastBackupDate', DateTime.now());
  }

  /// Check if any settings need attention (like overdue backups)
  Future<List<String>> getSettingsAlerts() async {
    final settings = await loadSettings();
    final List<String> alerts = [];

    if (settings.isBackupOverdue) {
      alerts.add(
        'Your data backup is overdue. Last backup: ${_formatDate(settings.lastBackupDate)}',
      );
    }

    return alerts;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Export settings as JSON string (for backup/sharing)
  Future<String> exportSettings() async {
    final settings = await loadSettings();
    return jsonEncode(settings.toJson());
  }

  /// Import settings from JSON string
  Future<void> importSettings(String settingsJson) async {
    try {
      final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
      final settings = AppSettings.fromJson(settingsMap);
      await saveSettings(settings);
    } catch (e) {
      throw SettingsRepositoryException('Invalid settings format: $e');
    }
  }

  /// Clear all settings (useful for testing or troubleshooting)
  Future<void> clearAllSettings() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw SettingsRepositoryException('Failed to clear settings: $e');
    }
  }
}

/// Exception thrown by SettingsRepository operations
class SettingsRepositoryException implements Exception {
  final String message;

  const SettingsRepositoryException(this.message);

  @override
  String toString() => 'SettingsRepositoryException: $message';
}
