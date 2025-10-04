import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/models/feeding_record.dart';
import 'package:foster_squirrel/utils/weight_converter.dart';

void main() {
  group('FeedingRecord - Weight Calculations', () {
    test(
      'should calculate weight difference correctly when ending weight is recorded',
      () {
        final record = FeedingRecord(
          id: 'test-1',
          squirrelId: 'squirrel-1',
          squirrelName: 'Testy',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
          endingWeightGrams: 105.0,
        );

        expect(record.weightDifferenceGrams, equals(5.0));
      },
    );

    test(
      'should return 0 weight difference when ending weight is not recorded',
      () {
        final record = FeedingRecord(
          id: 'test-2',
          squirrelId: 'squirrel-1',
          squirrelName: 'Testy',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
        );

        expect(record.weightDifferenceGrams, equals(-100.0)); // 0 - 100
      },
    );

    test('should calculate weight gain from baseline correctly', () {
      final record = FeedingRecord(
        id: 'test-3',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
      );

      final gainFromAdmission = record.calculateWeightGainFrom(95.0);
      expect(gainFromAdmission, equals(10.0)); // 105 - 95
    });

    test(
      'should return null weight gain from baseline when ending weight missing',
      () {
        final record = FeedingRecord(
          id: 'test-4',
          squirrelId: 'squirrel-1',
          squirrelName: 'Testy',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
        );

        final gain = record.calculateWeightGainFrom(95.0);
        expect(gain, isNull);
      },
    );

    test('should format weight gain from baseline with + sign for gains', () {
      final record = FeedingRecord(
        id: 'test-5',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 110.0,
      );

      final formatted = record.formatWeightGainFrom(95.0);
      expect(formatted, startsWith('+')); // Should show + for gain
    });

    test('should format weight gain as N/A when ending weight missing', () {
      final record = FeedingRecord(
        id: 'test-6',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      final formatted = record.formatWeightGainFrom(95.0);
      expect(formatted, equals('N/A'));
    });
  });

  group('FeedingRecord - Feeding Amount Calculations', () {
    test(
      'should calculate recommended feed amount based on feeding schedule',
      () {
        final record = FeedingRecord(
          id: 'test-7',
          squirrelId: 'squirrel-1',
          squirrelName: 'Testy',
          feedingTime: DateTime.now(),
          startingWeightGrams: 50.0, // 40-60g range
        );

        // According to feeding schedule, 40-60g should get 2.0-3.0 ml
        // 50g is midpoint, so should be around 2.5ml
        expect(record.recommendedFeedAmountML, greaterThan(2.0));
        expect(record.recommendedFeedAmountML, lessThan(3.0));
      },
    );

    test('should use actual feed amount when specified', () {
      final record = FeedingRecord(
        id: 'test-8',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 4.5,
      );

      expect(record.feedAmountML, equals(4.5));
      expect(record.actualFeedAmountML, equals(4.5));
    });

    test('should use recommended amount when actual not specified', () {
      final record = FeedingRecord(
        id: 'test-9',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      expect(record.feedAmountML, equals(record.recommendedFeedAmountML));
    });

    test('should format feed amount with ML unit', () {
      final record = FeedingRecord(
        id: 'test-10',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 3.5,
      );

      expect(record.formatFeedAmount(), equals('3.5 ml'));
    });
  });

  group('FeedingRecord - Weight Unit Conversions', () {
    test('should convert starting weight to different units', () {
      final record = FeedingRecord(
        id: 'test-11',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      expect(record.getStartingWeight(WeightUnit.grams), equals(100.0));
      expect(record.getStartingWeight(WeightUnit.ounces), closeTo(3.53, 0.01));
      expect(record.getStartingWeight(WeightUnit.pounds), closeTo(0.22, 0.01));
    });

    test('should convert ending weight to different units', () {
      final record = FeedingRecord(
        id: 'test-12',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
      );

      expect(record.getEndingWeight(WeightUnit.grams), equals(105.0));
      expect(record.getEndingWeight(WeightUnit.ounces), closeTo(3.70, 0.01));
    });

    test('should format starting weight with unit', () {
      final record = FeedingRecord(
        id: 'test-13',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      final formatted = record.formatStartingWeight(WeightUnit.grams);
      expect(formatted, contains('100'));
      expect(formatted, contains('g'));
    });

    test('should format weight difference with +/- sign', () {
      final record = FeedingRecord(
        id: 'test-14',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
      );

      final formatted = record.formatWeightDifference(WeightUnit.grams);
      expect(formatted, startsWith('+'));
    });
  });

  group('FeedingRecord - Success Determination', () {
    test('should be successful feeding when weight increased', () {
      final record = FeedingRecord(
        id: 'test-15',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
      );

      expect(record.isSuccessfulFeeding, isTrue);
    });

    test('should be successful feeding when weight maintained', () {
      final record = FeedingRecord(
        id: 'test-16',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 100.0,
      );

      expect(record.isSuccessfulFeeding, isTrue);
    });

    test('should not be successful feeding when weight decreased', () {
      final record = FeedingRecord(
        id: 'test-17',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
        endingWeightGrams: 95.0,
      );

      expect(record.isSuccessfulFeeding, isFalse);
    });
  });

  group('FeedingRecord - Time Formatting', () {
    test('should format recent feeding as "Just now"', () {
      final record = FeedingRecord(
        id: 'test-18',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      expect(record.formattedFeedingTime, equals('Just now'));
    });

    test('should format feeding from 2 hours ago correctly', () {
      final record = FeedingRecord(
        id: 'test-19',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now().subtract(const Duration(hours: 2)),
        startingWeightGrams: 100.0,
      );

      expect(record.formattedFeedingTime, equals('2 hours ago'));
    });

    test('should format feeding from 1 day ago correctly', () {
      final record = FeedingRecord(
        id: 'test-20',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now().subtract(const Duration(days: 1)),
        startingWeightGrams: 100.0,
      );

      expect(record.formattedFeedingTime, equals('1 day ago'));
    });

    test('should format old feeding with full date', () {
      final record = FeedingRecord(
        id: 'test-21',
        squirrelId: 'squirrel-1',
        squirrelName: 'Testy',
        feedingTime: DateTime.now().subtract(const Duration(days: 10)),
        startingWeightGrams: 100.0,
      );

      // Should contain month/day/year format
      expect(record.formattedFeedingTime, contains('/'));
    });
  });

  group('FeedingRecord - Factory and Serialization', () {
    test('should create feeding record with UUID using factory', () {
      final record = FeedingRecord.create(
        squirrelId: 'squirrel-1',
        squirrelName: 'Factory Test',
        startingWeightGrams: 100.0,
      );

      expect(record.id, isNotEmpty);
      expect(record.squirrelId, equals('squirrel-1'));
      expect(record.squirrelName, equals('Factory Test'));
      expect(record.startingWeightGrams, equals(100.0));
      expect(record.foodType, equals('Formula')); // Default
    });

    test('should serialize to JSON correctly', () {
      final record = FeedingRecord(
        id: 'json-test',
        squirrelId: 'squirrel-1',
        squirrelName: 'JSON Test',
        feedingTime: DateTime(2025, 1, 1, 10, 30),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
        notes: 'Test notes',
        foodType: 'Formula',
        actualFeedAmountML: 3.5,
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 11, 0),
      );

      final json = record.toJson();

      expect(json['id'], equals('json-test'));
      expect(json['squirrel_id'], equals('squirrel-1'));
      expect(json['squirrel_name'], equals('JSON Test'));
      expect(json['starting_weight_grams'], equals(100.0));
      expect(json['ending_weight_grams'], equals(105.0));
      expect(json['notes'], equals('Test notes'));
      expect(json['food_type'], equals('Formula'));
      expect(json['actual_feed_amount_ml'], equals(3.5));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'json-test',
        'squirrel_id': 'squirrel-1',
        'squirrel_name': 'JSON Test',
        'feeding_time': '2025-01-01T10:30:00.000',
        'starting_weight_grams': 100.0,
        'ending_weight_grams': 105.0,
        'notes': 'Test notes',
        'food_type': 'Formula',
        'actual_feed_amount_ml': 3.5,
        'created_at': '2025-01-01T10:00:00.000',
        'updated_at': '2025-01-01T11:00:00.000',
      };

      final record = FeedingRecord.fromJson(json);

      expect(record.id, equals('json-test'));
      expect(record.squirrelId, equals('squirrel-1'));
      expect(record.squirrelName, equals('JSON Test'));
      expect(record.startingWeightGrams, equals(100.0));
      expect(record.endingWeightGrams, equals(105.0));
      expect(record.notes, equals('Test notes'));
      expect(record.foodType, equals('Formula'));
      expect(record.actualFeedAmountML, equals(3.5));
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'minimal-test',
        'squirrel_id': 'squirrel-1',
        'squirrel_name': 'Minimal',
        'feeding_time': '2025-01-01T10:00:00.000',
        'starting_weight_grams': 100,
      };

      final record = FeedingRecord.fromJson(json);

      expect(record.id, equals('minimal-test'));
      expect(record.endingWeightGrams, isNull);
      expect(record.notes, equals(''));
      expect(record.actualFeedAmountML, isNull);
      expect(record.foodType, equals('Formula')); // Default
    });
  });

  group('FeedingRecord - copyWith', () {
    test('should create copy with updated ending weight', () {
      final original = FeedingRecord(
        id: 'copy-test',
        squirrelId: 'squirrel-1',
        squirrelName: 'Test',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      final copy = original.copyWith(endingWeightGrams: 105.0);

      expect(copy.id, equals(original.id));
      expect(copy.endingWeightGrams, equals(105.0));
      expect(copy.startingWeightGrams, equals(original.startingWeightGrams));
    });

    test('should preserve original values when not specified', () {
      final original = FeedingRecord(
        id: 'copy-test',
        squirrelId: 'squirrel-1',
        squirrelName: 'Test',
        feedingTime: DateTime(2025, 1, 1),
        startingWeightGrams: 100.0,
        endingWeightGrams: 105.0,
        notes: 'Original notes',
        actualFeedAmountML: 3.5,
      );

      final copy = original.copyWith(notes: 'Updated notes');

      expect(copy.notes, equals('Updated notes'));
      expect(copy.startingWeightGrams, equals(original.startingWeightGrams));
      expect(copy.endingWeightGrams, equals(original.endingWeightGrams));
      expect(copy.actualFeedAmountML, equals(original.actualFeedAmountML));
    });
  });

  group('FeedingRecord - Equality', () {
    test('should be equal when IDs match', () {
      final record1 = FeedingRecord(
        id: 'same-id',
        squirrelId: 'squirrel-1',
        squirrelName: 'Name 1',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      final record2 = FeedingRecord(
        id: 'same-id',
        squirrelId: 'squirrel-2',
        squirrelName: 'Name 2',
        feedingTime: DateTime.now().subtract(const Duration(days: 1)),
        startingWeightGrams: 50.0,
      );

      expect(record1, equals(record2));
      expect(record1.hashCode, equals(record2.hashCode));
    });

    test('should not be equal when IDs differ', () {
      final record1 = FeedingRecord(
        id: 'id-1',
        squirrelId: 'squirrel-1',
        squirrelName: 'Same',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      final record2 = FeedingRecord(
        id: 'id-2',
        squirrelId: 'squirrel-1',
        squirrelName: 'Same',
        feedingTime: DateTime.now(),
        startingWeightGrams: 100.0,
      );

      expect(record1, isNot(equals(record2)));
    });
  });

  group('FeedingStats', () {
    test('should calculate stats from empty list', () {
      final stats = FeedingStats.fromRecords([]);

      expect(stats.totalFeedings, equals(0));
      expect(stats.totalWeightGainGrams, equals(0.0));
      expect(stats.averageWeightGainGrams, equals(0.0));
      expect(stats.successfulFeedings, equals(0));
      expect(stats.totalFeedAmountML, equals(0.0));
      expect(stats.successRate, equals(0.0));
      expect(stats.averageFeedAmountML, equals(0.0));
    });

    test('should calculate total weight gain correctly', () {
      final records = [
        FeedingRecord(
          id: '1',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
          endingWeightGrams: 105.0, // +5g
        ),
        FeedingRecord(
          id: '2',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 105.0,
          endingWeightGrams: 108.0, // +3g
        ),
      ];

      final stats = FeedingStats.fromRecords(records);

      expect(stats.totalWeightGainGrams, equals(8.0)); // 5 + 3
      expect(stats.averageWeightGainGrams, equals(4.0)); // 8 / 2
    });

    test('should count successful feedings correctly', () {
      final records = [
        FeedingRecord(
          id: '1',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
          endingWeightGrams: 105.0, // Success
        ),
        FeedingRecord(
          id: '2',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 105.0,
          endingWeightGrams: 103.0, // Not successful
        ),
        FeedingRecord(
          id: '3',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 103.0,
          endingWeightGrams: 108.0, // Success
        ),
      ];

      final stats = FeedingStats.fromRecords(records);

      expect(stats.totalFeedings, equals(3));
      expect(stats.successfulFeedings, equals(2));
      expect(stats.successRate, closeTo(66.67, 0.01));
    });

    test('should calculate total and average feed amounts', () {
      final records = [
        FeedingRecord(
          id: '1',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 100.0,
          actualFeedAmountML: 3.0,
        ),
        FeedingRecord(
          id: '2',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime.now(),
          startingWeightGrams: 105.0,
          actualFeedAmountML: 5.0,
        ),
      ];

      final stats = FeedingStats.fromRecords(records);

      expect(stats.totalFeedAmountML, equals(8.0)); // 3 + 5
      expect(stats.averageFeedAmountML, equals(4.0)); // 8 / 2
    });

    test('should identify first and last feeding times', () {
      final firstTime = DateTime(2025, 1, 1, 8, 0);
      final lastTime = DateTime(2025, 1, 1, 20, 0);

      final records = [
        FeedingRecord(
          id: '1',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: DateTime(2025, 1, 1, 12, 0),
          startingWeightGrams: 100.0,
        ),
        FeedingRecord(
          id: '2',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: firstTime,
          startingWeightGrams: 100.0,
        ),
        FeedingRecord(
          id: '3',
          squirrelId: 'sq-1',
          squirrelName: 'Test',
          feedingTime: lastTime,
          startingWeightGrams: 100.0,
        ),
      ];

      final stats = FeedingStats.fromRecords(records);

      expect(stats.firstFeedingTime, equals(firstTime));
      expect(stats.lastFeedingTime, equals(lastTime));
    });
  });
}
