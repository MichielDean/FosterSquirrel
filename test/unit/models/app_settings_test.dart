import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/models/app_settings.dart';
import 'package:foster_squirrel/utils/weight_converter.dart';
import '../../helpers/test_date_utils.dart';

void main() {
  group('AppSettings - Defaults', () {
    test('should create settings with correct default values', () {
      const settings = AppSettings();

      expect(settings.defaultWeightUnit, equals(WeightUnit.grams));
      expect(settings.showWeightInMultipleUnits, isTrue);
      expect(settings.enableFeedingReminders, isTrue);
      expect(settings.feedingReminderIntervalHours, equals(3));
      expect(settings.enableWeightAlerts, isTrue);
      expect(settings.weightLossAlertThreshold, equals(5.0));
      expect(settings.darkMode, isFalse);
      expect(settings.compactView, isFalse);
      expect(settings.autoBackup, isTrue);
      expect(settings.autoBackupIntervalDays, equals(7));
      expect(settings.showFeedingTips, isTrue);
      expect(settings.confirmDeleteActions, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.vibrationEnabled, isTrue);
    });

    test('should create default settings via factory method', () {
      final settings = AppSettings.defaults();

      expect(settings.defaultWeightUnit, equals(WeightUnit.grams));
      expect(settings.enableFeedingReminders, isTrue);
      expect(settings.autoBackup, isTrue);
    });

    test('should use current time for lastBackupDate when null', () {
      final before = DateTime.now();
      const settings = AppSettings();
      final after = DateTime.now();

      expect(
        settings.lastBackupDate.isAfter(
          before.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        settings.lastBackupDate.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('AppSettings - copyWith', () {
    test('should create copy with updated weight unit', () {
      const original = AppSettings();
      final updated = original.copyWith(defaultWeightUnit: WeightUnit.ounces);

      expect(updated.defaultWeightUnit, equals(WeightUnit.ounces));
      expect(
        updated.enableFeedingReminders,
        equals(original.enableFeedingReminders),
      );
    });

    test('should create copy with updated boolean flags', () {
      const original = AppSettings();
      final updated = original.copyWith(
        darkMode: true,
        compactView: true,
        enableFeedingReminders: false,
      );

      expect(updated.darkMode, isTrue);
      expect(updated.compactView, isTrue);
      expect(updated.enableFeedingReminders, isFalse);
      expect(updated.autoBackup, equals(original.autoBackup)); // Unchanged
    });

    test('should create copy with updated numeric values', () {
      const original = AppSettings();
      final updated = original.copyWith(
        feedingReminderIntervalHours: 4,
        weightLossAlertThreshold: 10.0,
        autoBackupIntervalDays: 14,
      );

      expect(updated.feedingReminderIntervalHours, equals(4));
      expect(updated.weightLossAlertThreshold, equals(10.0));
      expect(updated.autoBackupIntervalDays, equals(14));
    });

    test('should create copy with updated lastBackupDate', () {
      const original = AppSettings();
      final newDate = daysFromNow(12);
      final updated = original.copyWith(lastBackupDate: newDate);

      expect(updated.lastBackupDate, equals(newDate));
    });

    test('should create exact copy when no parameters provided', () {
      const original = AppSettings(
        darkMode: true,
        feedingReminderIntervalHours: 5,
      );
      final copy = original.copyWith();

      expect(copy.darkMode, equals(original.darkMode));
      expect(
        copy.feedingReminderIntervalHours,
        equals(original.feedingReminderIntervalHours),
      );
    });
  });

  group('AppSettings - JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final settings = AppSettings(
        defaultWeightUnit: WeightUnit.ounces,
        darkMode: true,
        enableFeedingReminders: false,
        feedingReminderIntervalHours: 4,
        weightLossAlertThreshold: 10.0,
        autoBackupIntervalDays: 14,
        lastBackupDate: dateWithTime(12, 10, 30),
      );

      final json = settings.toJson();

      expect(json['default_weight_unit'], equals('ounces'));
      expect(json['dark_mode'], isTrue);
      expect(json['enable_feeding_reminders'], isFalse);
      expect(json['feeding_reminder_interval_hours'], equals(4));
      expect(json['weight_loss_alert_threshold'], equals(10.0));
      expect(json['auto_backup_interval_days'], equals(14));
      // Check date is serialized correctly (check format, not exact value)
      expect(
        json['last_backup_date'],
        equals(settings.lastBackupDate.toIso8601String()),
      );
    });

    test('should deserialize from JSON with all values', () {
      final json = {
        'default_weight_unit': 'pounds',
        'show_weight_in_multiple_units': false,
        'enable_feeding_reminders': false,
        'feeding_reminder_interval_hours': 6,
        'enable_weight_alerts': false,
        'weight_loss_alert_threshold': 8.0,
        'dark_mode': true,
        'compact_view': true,
        'auto_backup': false,
        'auto_backup_interval_days': 30,
        'show_feeding_tips': false,
        'confirm_delete_actions': false,
        'sound_enabled': false,
        'vibration_enabled': false,
        'last_backup_date': '2025-01-15T10:30:00.000',
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.defaultWeightUnit, equals(WeightUnit.pounds));
      expect(settings.showWeightInMultipleUnits, isFalse);
      expect(settings.enableFeedingReminders, isFalse);
      expect(settings.feedingReminderIntervalHours, equals(6));
      expect(settings.enableWeightAlerts, isFalse);
      expect(settings.weightLossAlertThreshold, equals(8.0));
      expect(settings.darkMode, isTrue);
      expect(settings.compactView, isTrue);
      expect(settings.autoBackup, isFalse);
      expect(settings.autoBackupIntervalDays, equals(30));
      expect(settings.showFeedingTips, isFalse);
      expect(settings.confirmDeleteActions, isFalse);
      expect(settings.soundEnabled, isFalse);
      expect(settings.vibrationEnabled, isFalse);
      // Deserialize date correctly from the JSON
      expect(
        settings.lastBackupDate,
        equals(DateTime.parse('2025-01-15T10:30:00.000')),
      );
    });

    test('should use defaults when JSON values are missing', () {
      final json = <String, dynamic>{};
      final settings = AppSettings.fromJson(json);

      expect(settings.defaultWeightUnit, equals(WeightUnit.grams));
      expect(settings.showWeightInMultipleUnits, isTrue);
      expect(settings.enableFeedingReminders, isTrue);
      expect(settings.feedingReminderIntervalHours, equals(3));
      expect(settings.darkMode, isFalse);
    });

    test('should round-trip through JSON correctly', () {
      final original = AppSettings(
        defaultWeightUnit: WeightUnit.pounds,
        darkMode: true,
        feedingReminderIntervalHours: 5,
        weightLossAlertThreshold: 7.5,
        lastBackupDate: dateWithTime(12, 10, 30),
      );

      final json = original.toJson();
      final deserialized = AppSettings.fromJson(json);

      expect(
        deserialized.defaultWeightUnit,
        equals(original.defaultWeightUnit),
      );
      expect(deserialized.darkMode, equals(original.darkMode));
      expect(
        deserialized.feedingReminderIntervalHours,
        equals(original.feedingReminderIntervalHours),
      );
      expect(
        deserialized.weightLossAlertThreshold,
        equals(original.weightLossAlertThreshold),
      );
      expect(deserialized.lastBackupDate, equals(original.lastBackupDate));
    });
  });

  group('AppSettings - Backup Management', () {
    test('should not be overdue when backup is disabled', () {
      final settings = AppSettings(
        autoBackup: false,
        lastBackupDate: DateTime.now().subtract(const Duration(days: 100)),
      );

      expect(settings.isBackupOverdue, isFalse);
    });

    test('should be overdue when days since backup >= interval', () {
      final settings = AppSettings(
        autoBackup: true,
        autoBackupIntervalDays: 7,
        lastBackupDate: DateTime.now().subtract(const Duration(days: 7)),
      );

      expect(settings.isBackupOverdue, isTrue);
    });

    test('should not be overdue when days since backup < interval', () {
      final settings = AppSettings(
        autoBackup: true,
        autoBackupIntervalDays: 7,
        lastBackupDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(settings.isBackupOverdue, isFalse);
    });

    test('should be overdue for very old backups', () {
      final settings = AppSettings(
        autoBackup: true,
        autoBackupIntervalDays: 7,
        lastBackupDate: DateTime.now().subtract(const Duration(days: 100)),
      );

      expect(settings.isBackupOverdue, isTrue);
    });

    test('should not be overdue for recent backup', () {
      final settings = AppSettings(
        autoBackup: true,
        autoBackupIntervalDays: 7,
        lastBackupDate: DateTime.now(),
      );

      expect(settings.isBackupOverdue, isFalse);
    });
  });

  group('AppSettings - Weight Formatting', () {
    test('should format weight in single unit when multi-unit disabled', () {
      const settings = AppSettings(
        defaultWeightUnit: WeightUnit.grams,
        showWeightInMultipleUnits: false,
      );

      final formatted = settings.formatWeightWithPreferences(100.0);

      expect(formatted, equals('100.0 g'));
      expect(formatted, isNot(contains('oz'))); // No secondary unit
    });

    test('should format weight in multiple units when enabled', () {
      const settings = AppSettings(
        defaultWeightUnit: WeightUnit.grams,
        showWeightInMultipleUnits: true,
      );

      final formatted = settings.formatWeightWithPreferences(100.0);

      expect(formatted, contains('g'));
      expect(formatted, contains('oz'));
      expect(formatted, contains('('));
      expect(formatted, contains(')'));
    });

    test('should show ounces primary with grams secondary', () {
      const settings = AppSettings(
        defaultWeightUnit: WeightUnit.ounces,
        showWeightInMultipleUnits: true,
      );

      final formatted = settings.formatWeightWithPreferences(100.0);

      expect(formatted, contains('oz'));
      expect(formatted, contains('g'));
    });

    test('should format zero weight correctly', () {
      const settings = AppSettings(showWeightInMultipleUnits: false);

      final formatted = settings.formatWeightWithPreferences(0.0);

      expect(formatted, equals('0.0 g'));
    });

    test('should format large weight values correctly', () {
      const settings = AppSettings(showWeightInMultipleUnits: false);

      final formatted = settings.formatWeightWithPreferences(10000.0);

      expect(formatted, contains('10000'));
    });
  });

  group('AppSettings - Feeding Reminders', () {
    test('should return empty string when reminders disabled', () {
      const settings = AppSettings(enableFeedingReminders: false);

      final text = settings.getFeedingReminderText('Nutkin');

      expect(text, isEmpty);
    });

    test('should return reminder text with squirrel name', () {
      const settings = AppSettings(
        enableFeedingReminders: true,
        feedingReminderIntervalHours: 3,
      );

      final text = settings.getFeedingReminderText('Nutkin');

      expect(text, contains('Nutkin'));
      expect(text, contains('3 hours'));
    });

    test('should use singular hour for 1 hour interval', () {
      const settings = AppSettings(
        enableFeedingReminders: true,
        feedingReminderIntervalHours: 1,
      );

      final text = settings.getFeedingReminderText('Nutkin');

      expect(text, contains('hour'));
      expect(text, isNot(contains('hours'))); // Should be singular
    });

    test('should use plural hours for multiple hour interval', () {
      const settings = AppSettings(
        enableFeedingReminders: true,
        feedingReminderIntervalHours: 4,
      );

      final text = settings.getFeedingReminderText('Fluffy');

      expect(text, contains('4 hours'));
      expect(text, contains('Fluffy'));
    });

    test('should handle empty squirrel name', () {
      const settings = AppSettings(enableFeedingReminders: true);

      final text = settings.getFeedingReminderText('');

      expect(text, isNotEmpty); // Should still generate text
      expect(text, contains('hour'));
    });
  });

  group('AppSettings - Weight Loss Alerts', () {
    test('should not alert when alerts disabled', () {
      const settings = AppSettings(
        enableWeightAlerts: false,
        weightLossAlertThreshold: 5.0,
      );

      expect(settings.shouldAlertForWeightLoss(10.0), isFalse);
    });

    test('should alert when weight loss >= threshold', () {
      const settings = AppSettings(
        enableWeightAlerts: true,
        weightLossAlertThreshold: 5.0,
      );

      expect(settings.shouldAlertForWeightLoss(5.0), isTrue);
      expect(settings.shouldAlertForWeightLoss(6.0), isTrue);
      expect(settings.shouldAlertForWeightLoss(10.0), isTrue);
    });

    test('should not alert when weight loss < threshold', () {
      const settings = AppSettings(
        enableWeightAlerts: true,
        weightLossAlertThreshold: 5.0,
      );

      expect(settings.shouldAlertForWeightLoss(4.9), isFalse);
      expect(settings.shouldAlertForWeightLoss(0.0), isFalse);
    });

    test('should handle zero threshold', () {
      const settings = AppSettings(
        enableWeightAlerts: true,
        weightLossAlertThreshold: 0.0,
      );

      expect(settings.shouldAlertForWeightLoss(0.0), isTrue);
      expect(settings.shouldAlertForWeightLoss(0.1), isTrue);
    });

    test('should handle high threshold values', () {
      const settings = AppSettings(
        enableWeightAlerts: true,
        weightLossAlertThreshold: 50.0,
      );

      expect(settings.shouldAlertForWeightLoss(49.9), isFalse);
      expect(settings.shouldAlertForWeightLoss(50.0), isTrue);
    });
  });

  group('AppSettings - Equality', () {
    test('should be equal when all fields match', () {
      final settings1 = AppSettings(
        darkMode: true,
        feedingReminderIntervalHours: 4,
        lastBackupDate: daysFromNow(12),
      );

      final settings2 = AppSettings(
        darkMode: true,
        feedingReminderIntervalHours: 4,
        lastBackupDate: daysFromNow(12),
      );

      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should not be equal when fields differ', () {
      const settings1 = AppSettings(darkMode: true);
      const settings2 = AppSettings(darkMode: false);

      expect(settings1, isNot(equals(settings2)));
    });

    test('should be equal to itself', () {
      const settings = AppSettings();

      expect(settings, equals(settings));
      expect(identical(settings, settings), isTrue);
    });
  });

  group('AppSettings - Edge Cases', () {
    test('should handle extreme interval values', () {
      const settings = AppSettings(
        feedingReminderIntervalHours: 24,
        autoBackupIntervalDays: 365,
      );

      expect(settings.feedingReminderIntervalHours, equals(24));
      expect(settings.autoBackupIntervalDays, equals(365));
    });

    test('should handle very small threshold values', () {
      const settings = AppSettings(weightLossAlertThreshold: 0.1);

      expect(settings.shouldAlertForWeightLoss(0.1), isTrue);
      expect(settings.shouldAlertForWeightLoss(0.09), isFalse);
    });

    test('should handle very large weight values in formatting', () {
      const settings = AppSettings(showWeightInMultipleUnits: false);

      final formatted = settings.formatWeightWithPreferences(999999.0);

      expect(formatted, contains('999999'));
    });
  });

  group('SettingsCategory', () {
    test('should have correct title and description', () {
      expect(SettingsCategory.display.title, equals('Display'));
      expect(SettingsCategory.feeding.title, equals('Feeding'));
      expect(SettingsCategory.data.title, equals('Data & Backup'));
      expect(SettingsCategory.notifications.title, equals('Notifications'));
      expect(SettingsCategory.advanced.title, equals('Advanced'));
    });

    test('should have non-empty descriptions', () {
      for (final category in SettingsCategory.values) {
        expect(category.description, isNotEmpty);
      }
    });
  });

  group('SettingItem', () {
    test('should create setting item with all properties', () {
      const item = SettingItem(
        key: 'dark_mode',
        title: 'Dark Mode',
        description: 'Enable dark theme',
        category: SettingsCategory.display,
        type: SettingType.toggle,
        currentValue: true,
        enabled: true,
      );

      expect(item.key, equals('dark_mode'));
      expect(item.title, equals('Dark Mode'));
      expect(item.description, equals('Enable dark theme'));
      expect(item.category, equals(SettingsCategory.display));
      expect(item.type, equals(SettingType.toggle));
      expect(item.currentValue, isTrue);
      expect(item.enabled, isTrue);
    });

    test('should create setting item with options for dropdown', () {
      const item = SettingItem(
        key: 'weight_unit',
        title: 'Weight Unit',
        description: 'Default weight unit',
        category: SettingsCategory.display,
        type: SettingType.dropdown,
        options: ['Grams', 'Ounces', 'Pounds'],
        currentValue: 'Grams',
      );

      expect(item.options, hasLength(3));
      expect(item.options, contains('Grams'));
    });

    test('should create setting item with min/max for slider', () {
      const item = SettingItem(
        key: 'interval',
        title: 'Interval',
        description: 'Feeding interval',
        category: SettingsCategory.feeding,
        type: SettingType.slider,
        min: 1.0,
        max: 24.0,
        currentValue: 3.0,
      );

      expect(item.min, equals(1.0));
      expect(item.max, equals(24.0));
      expect(item.currentValue, equals(3.0));
    });

    test('should support copyWith for updating properties', () {
      const original = SettingItem(
        key: 'test',
        title: 'Test',
        description: 'Test setting',
        category: SettingsCategory.advanced,
        type: SettingType.toggle,
      );

      final updated = original.copyWith(currentValue: true, enabled: false);

      expect(updated.currentValue, isTrue);
      expect(updated.enabled, isFalse);
      expect(updated.key, equals(original.key)); // Unchanged
    });
  });
}
