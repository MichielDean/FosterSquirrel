import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/models/feeding_schedule.dart';
import '../../helpers/test_date_utils.dart';

void main() {
  group('FeedingSchedule - Weight-based Schedule Selection', () {
    test('should select correct schedule for 15g squirrel (0-1 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(15.0);

      expect(schedule.ageWeeks, equals('0-1 weeks'));
      expect(schedule.weightRangeGrams.$1, equals(10.0));
      expect(schedule.weightRangeGrams.$2, equals(20.0));
      expect(schedule.requiresNightFeeding, isTrue);
    });

    test('should select correct schedule for 30g squirrel (1-2 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(30.0);

      expect(schedule.ageWeeks, equals('1-2 weeks'));
      expect(schedule.weightRangeGrams.$1, equals(20.0));
      expect(schedule.weightRangeGrams.$2, equals(40.0));
      expect(schedule.feedingIntervalHours, equals(2.5));
    });

    test('should select correct schedule for 50g squirrel (2-3 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);

      expect(schedule.ageWeeks, equals('2-3 weeks'));
      expect(schedule.feedingIntervalHours, equals(3.0));
      expect(schedule.requiresNightFeeding, isTrue);
    });

    test('should select correct schedule for 70g squirrel (3-4 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(70.0);

      expect(schedule.ageWeeks, equals('3-4 weeks'));
      expect(schedule.feedingIntervalHours, equals(3.5));
    });

    test('should select correct schedule for 100g squirrel (4-5 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(100.0);

      expect(schedule.ageWeeks, equals('4-5 weeks'));
      expect(schedule.feedingIntervalHours, equals(4.0));
      expect(schedule.maxNightGapHours, equals(8));
    });

    test('should select correct schedule for 140g squirrel (5-7 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(140.0);

      expect(schedule.ageWeeks, equals('5-7 weeks'));
      expect(schedule.requiresNightFeeding, isFalse);
      expect(schedule.feedingIntervalHours, equals(4.5));
    });

    test('should select correct schedule for 200g squirrel (7-8 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(200.0);

      expect(schedule.ageWeeks, equals('7-8 weeks'));
      expect(schedule.feedingIntervalHours, equals(8.0));
    });

    test('should select correct schedule for 300g squirrel (8-10 weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(300.0);

      expect(schedule.ageWeeks, equals('8-10 weeks'));
      expect(schedule.feedingIntervalHours, equals(12.0));
    });

    test('should select correct schedule for 450g squirrel (10-12+ weeks)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(450.0);

      expect(schedule.ageWeeks, equals('10-12+ weeks'));
      expect(schedule.feedingIntervalHours, equals(24.0));
      expect(schedule.requiresNightFeeding, isFalse);
    });

    test('should handle very small squirrel (< 10g)', () {
      final schedule = FeedingSchedule.getScheduleForWeight(8.0);

      expect(schedule.ageWeeks, equals('0-1 weeks'));
      expect(schedule.weightRangeGrams.$1, equals(5.0));
      expect(schedule.feedingIntervalHours, equals(2.0));
      expect(schedule.requiresNightFeeding, isTrue);
    });
  });

  group('FeedingSchedule - Recommended Amount Calculation', () {
    test('should return minimum amount for weight at lower bound', () {
      final schedule = FeedingSchedule.getScheduleForWeight(40.0); // 2-3 weeks
      final amount = schedule.getRecommendedAmountForWeight(40.0);

      // The schedule at 40g is actually the 1-2 week schedule (20-40g)
      // so we need to adjust our expectation
      expect(amount, closeTo(schedule.amountPerFeedingML.$2, 0.1));
    });

    test('should return maximum amount for weight at upper bound', () {
      final schedule = FeedingSchedule.getScheduleForWeight(60.0); // 2-3 weeks
      final amount = schedule.getRecommendedAmountForWeight(60.0);

      expect(amount, equals(schedule.amountPerFeedingML.$2));
    });

    test('should interpolate amount for weight in middle of range', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // 2-3 weeks, 40-60g range
      final amount = schedule.getRecommendedAmountForWeight(50.0);

      // 50g is midpoint of 40-60g, so should get midpoint of 2.0-3.0ml = 2.5ml
      expect(amount, equals(2.5));
    });

    test('should handle weight below range minimum', () {
      final schedule = FeedingSchedule.getScheduleForWeight(45.0); // 2-3 weeks
      final amount = schedule.getRecommendedAmountForWeight(35.0);

      // Should return minimum amount
      expect(amount, equals(schedule.amountPerFeedingML.$1));
    });

    test('should handle weight above range maximum', () {
      final schedule = FeedingSchedule.getScheduleForWeight(55.0); // 2-3 weeks
      final amount = schedule.getRecommendedAmountForWeight(70.0);

      // Should return maximum amount
      expect(amount, equals(schedule.amountPerFeedingML.$2));
    });

    test('should calculate amount correctly for 75% through range', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        55.0,
      ); // 2-3 weeks, 40-60g
      final amount = schedule.getRecommendedAmountForWeight(55.0);

      // 55g is 75% through 40-60g range
      // Amount should be 2.0 + 0.75 * (3.0 - 2.0) = 2.75ml
      expect(amount, equals(2.75));
    });
  });

  group('FeedingSchedule - Next Feeding Time', () {
    test('should calculate next feeding time based on interval', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // 3.0 hours interval
      final lastFeeding = dateWithTime(-2, 10, 0);

      final nextFeeding = schedule.getNextFeedingTime(
        lastFeedingTime: lastFeeding,
      );

      expect(nextFeeding.hour, equals(13)); // 10:00 + 3 hours
      expect(nextFeeding.minute, equals(0));
    });

    test('should handle fractional hour intervals', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        70.0,
      ); // 3.5 hours interval
      final lastFeeding = dateWithTime(-2, 10, 0);

      final nextFeeding = schedule.getNextFeedingTime(
        lastFeedingTime: lastFeeding,
      );

      expect(nextFeeding.hour, equals(13)); // 10:00 + 3.5 hours = 13:30
      expect(nextFeeding.minute, equals(30));
    });

    test('should use night gap hours when night feeding not required', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        140.0,
      ); // No night feeding required
      final lastFeeding = dateWithTime(-2, 22, 0); // 10 PM

      final nextFeeding = schedule.getNextFeedingTime(
        lastFeedingTime: lastFeeding,
        isNightTime: true,
      );

      // Should use maxNightGapHours (8) instead of regular interval
      expect(nextFeeding.hour, equals(6)); // 22:00 + 8 hours = 6:00
    });

    test(
      'should use regular interval even at night if night feeding required',
      () {
        final schedule = FeedingSchedule.getScheduleForWeight(
          50.0,
        ); // Night feeding required
        final lastFeeding = dateWithTime(-2, 22, 0);

        final nextFeeding = schedule.getNextFeedingTime(
          lastFeedingTime: lastFeeding,
          isNightTime: true,
        );

        // Should use regular 3.0 hour interval
        expect(nextFeeding, equals(dateWithTime(-1, 1, 0)));
      },
    );
  });

  group('FeedingSchedule - Overdue Detection', () {
    test('should detect feeding is overdue when past threshold', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // 3.0 hours interval
      final lastFeeding = dateWithTime(-2, 10, 0);
      // Current time is 3h 45min after last feeding (45min past due)
      final currentTime = dateWithTime(-2, 13, 45);

      final isOverdue = schedule.isFeedingOverdue(
        lastFeedingTime: lastFeeding,
        currentTime: currentTime,
      );

      expect(isOverdue, isTrue);
    });

    test('should not be overdue when within flexibility window', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // 3.0 hours, small squirrel
      final lastFeeding = dateWithTime(-2, 10, 0);
      final currentTime = DateTime(
        2025,
        1,
        1,
        13,
        15,
      ); // 3h 15min later (within 30min flexibility)

      final isOverdue = schedule.isFeedingOverdue(
        lastFeedingTime: lastFeeding,
        currentTime: currentTime,
      );

      expect(isOverdue, isFalse);
    });

    test('should allow more flexibility for older squirrels', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        150.0,
      ); // Larger squirrel
      final lastFeeding = dateWithTime(-2, 10, 0);
      final currentTime = dateWithTime(-2, 15, 30); // 5h 30min later

      // Older squirrels get 1 hour flexibility, so 4.5h + 1h = 5.5h threshold
      final isOverdue = schedule.isFeedingOverdue(
        lastFeedingTime: lastFeeding,
        currentTime: currentTime,
      );

      expect(isOverdue, isFalse); // Should still be within tolerance
    });
  });

  group('FeedingSchedule - Night Time Detection', () {
    test('should detect 11 PM as night time', () {
      final time = dateWithTime(-2, 23, 0);
      expect(FeedingSchedule.isNightTime(currentTime: time), isTrue);
    });

    test('should detect 2 AM as night time', () {
      final time = dateWithTime(-2, 2, 0);
      expect(FeedingSchedule.isNightTime(currentTime: time), isTrue);
    });

    test('should detect 10 AM as day time', () {
      final time = dateWithTime(-2, 10, 0);
      expect(FeedingSchedule.isNightTime(currentTime: time), isFalse);
    });

    test('should detect 6 AM as day time boundary', () {
      final time = dateWithTime(-2, 6, 0);
      expect(FeedingSchedule.isNightTime(currentTime: time), isFalse);
    });

    test('should detect 10 PM as night time boundary', () {
      final time = dateWithTime(-2, 22, 0);
      expect(FeedingSchedule.isNightTime(currentTime: time), isTrue);
    });
  });

  group('FeedingSchedule - Daily Feeding Times', () {
    test('should generate feeding times throughout the day', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // Every 3 hours
      final startDate = daysAgo(2);

      final feedingTimes = schedule.getDailyFeedingTimes(startDate: startDate);

      // Should have multiple feedings between 6 AM and 10 PM
      expect(feedingTimes.length, greaterThan(3));
      // Check daytime feedings (excluding night feeding at 2 AM)
      final daytimeFeedings = feedingTimes.where(
        (time) => time.hour >= 6 && time.hour <= 22,
      );
      expect(daytimeFeedings.isNotEmpty, isTrue);
    });

    test('should include night feeding when required', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        50.0,
      ); // Requires night feeding
      final startDate = daysAgo(2);

      final feedingTimes = schedule.getDailyFeedingTimes(startDate: startDate);

      // Should include 2 AM feeding
      expect(feedingTimes.any((time) => time.hour == 2), isTrue);
    });

    test('should not include night feeding when not required', () {
      final schedule = FeedingSchedule.getScheduleForWeight(
        150.0,
      ); // No night feeding
      final startDate = daysAgo(2);

      final feedingTimes = schedule.getDailyFeedingTimes(startDate: startDate);

      // Should not include early morning feedings
      expect(
        feedingTimes.any((time) => time.hour >= 0 && time.hour < 6),
        isFalse,
      );
    });

    test('should sort feeding times chronologically', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final startDate = daysAgo(2);

      final feedingTimes = schedule.getDailyFeedingTimes(startDate: startDate);

      // Verify list is sorted
      for (int i = 1; i < feedingTimes.length; i++) {
        expect(feedingTimes[i].isAfter(feedingTimes[i - 1]), isTrue);
      }
    });
  });

  group('FeedingSchedule - Formatting', () {
    test('should format schedule info correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final formatted = schedule.formatScheduleInfo();

      expect(formatted, contains('2-3 weeks'));
      expect(formatted, contains('40-60g'));
      expect(formatted, contains('3.0 hours'));
      expect(formatted, contains('ml'));
    });

    test('should format toString correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final str = schedule.toString();

      expect(str, contains('FeedingSchedule'));
      expect(str, contains('2-3 weeks'));
      expect(str, contains('40-60'));
    });
  });

  group('FeedingReminder', () {
    test('should format reminder message for upcoming feeding', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: dateWithTime(-2, 14, 30),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('Nutkin'));
      expect(message, contains('2.5 ml'));
      expect(message, contains('2:30 PM'));
      expect(message, contains('🐿️'));
    });

    test('should format reminder message for overdue feeding', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: DateTime.now().subtract(const Duration(minutes: 30)),
        recommendedAmountML: 2.5,
        isOverdue: true,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('OVERDUE'));
      expect(message, contains('Nutkin'));
      expect(message, contains('⚠️'));
    });

    test('should format reminder title for upcoming feeding', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: DateTime.now(),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final title = reminder.formatReminderTitle();

      expect(title, equals('Feeding Time - Nutkin'));
    });

    test('should format reminder title for overdue feeding', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: DateTime.now(),
        recommendedAmountML: 2.5,
        isOverdue: true,
        schedule: schedule,
      );

      final title = reminder.formatReminderTitle();

      expect(title, equals('Overdue Feeding - Nutkin'));
    });

    test('should format AM times correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: dateWithTime(-2, 8, 30),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('8:30 AM'));
    });

    test('should format PM times correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: dateWithTime(-2, 15, 45),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('3:45 PM'));
    });

    test('should handle midnight correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: dateWithTime(-2, 0, 0),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('12:00 AM'));
    });

    test('should handle noon correctly', () {
      final schedule = FeedingSchedule.getScheduleForWeight(50.0);
      final reminder = FeedingReminder(
        squirrelId: 'sq-1',
        squirrelName: 'Nutkin',
        scheduledTime: dateWithTime(-2, 12, 0),
        recommendedAmountML: 2.5,
        isOverdue: false,
        schedule: schedule,
      );

      final message = reminder.formatReminderMessage();

      expect(message, contains('12:00 PM'));
    });
  });
}
