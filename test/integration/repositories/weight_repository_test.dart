import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';
import 'package:foster_squirrel/repositories/drift/weight_repository.dart';

import '../test_database_helper.dart';
import '../../helpers/test_date_utils.dart';

/// Integration tests for WeightRepository (Drift version).
///
/// These tests use a real in-memory database to test weight tracking
/// from feeding records.
void main() {
  late AppDatabase database;
  late WeightRepository weightRepo;
  late FeedingRepository feedingRepo;
  late SquirrelRepository squirrelRepo;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    weightRepo = WeightRepository(database);
    feedingRepo = FeedingRepository(database);
    squirrelRepo = SquirrelRepository(database);
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('WeightRepository - Get Weight Trend Data', () {
    test('should get weight trend from feeding records', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add feeding records with weights
      final feeding1 = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 10, 0),
        startingWeightGrams: 50.0,
        endingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-2, 10, 0),
        updatedAt: dateWithTime(-2, 10, 0),
      );

      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-1, 10, 0),
        startingWeightGrams: 52.0,
        endingWeightGrams: 55.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-1, 10, 0),
        updatedAt: dateWithTime(-1, 10, 0),
      );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);

      final weightData = await weightRepo.getWeightTrendData(squirrel.id);

      expect(weightData, hasLength(2));
      expect(weightData[0].weight, equals(52.0)); // First ending weight
      expect(weightData[1].weight, equals(55.0)); // Second ending weight
    });

    test(
      'should use starting weight when ending weight not available',
      () async {
        final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
        await squirrelRepo.addSquirrel(squirrel);

        // Add feeding without ending weight
        final feeding = FeedingRecord(
          id: 'feed-1',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10, 0),
          startingWeightGrams: 50.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10, 0),
          updatedAt: dateWithTime(-2, 10, 0),
        );

        await feedingRepo.addFeedingRecord(feeding);

        final weightData = await weightRepo.getWeightTrendData(squirrel.id);

        expect(weightData, hasLength(1));
        expect(weightData[0].weight, equals(50.0)); // Used starting weight
      },
    );

    test('should return empty list when no feeding records', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final weightData = await weightRepo.getWeightTrendData(squirrel.id);

      expect(weightData, isEmpty);
    });

    test('should return data points sorted by date', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add feedings out of order
      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-1, 10, 0),
        startingWeightGrams: 55.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-1, 10, 0),
        updatedAt: dateWithTime(-1, 10, 0),
      );

      final feeding1 = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 10, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-2, 10, 0),
        updatedAt: dateWithTime(-2, 10, 0),
      );

      await feedingRepo.addFeedingRecord(feeding2);
      await feedingRepo.addFeedingRecord(feeding1);

      final weightData = await weightRepo.getWeightTrendData(squirrel.id);

      // Should be sorted by date ascending
      expect(weightData[0].weight, equals(50.0));
      expect(weightData[1].weight, equals(55.0));
    });
  });

  group('WeightRepository - Get Latest Weight', () {
    test('should get latest weight from most recent feeding', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add multiple feedings
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-1',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10, 0),
          updatedAt: dateWithTime(-2, 10, 0),
        ),
      );

      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-2',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-1, 10, 0),
          startingWeightGrams: 52.0,
          endingWeightGrams: 55.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-1, 10, 0),
          updatedAt: dateWithTime(-1, 10, 0),
        ),
      );

      final latestWeight = await weightRepo.getLatestWeight(squirrel.id);

      expect(latestWeight, equals(55.0));
    });

    test('should return null when no feeding records', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final latestWeight = await weightRepo.getLatestWeight(squirrel.id);

      expect(latestWeight, isNull);
    });
  });

  group('WeightRepository - Get Average Weight', () {
    test('should calculate average weight over date range', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add feedings with different weights
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-1',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(7, 10, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(7, 10, 0),
          updatedAt: dateWithTime(7, 10, 0),
        ),
      );

      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-2',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(12, 10, 0),
          startingWeightGrams: 54.0,
          endingWeightGrams: 56.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(12, 10, 0),
          updatedAt: dateWithTime(12, 10, 0),
        ),
      );

      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-3',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(17, 10, 0),
          startingWeightGrams: 58.0,
          endingWeightGrams: 60.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(17, 10, 0),
          updatedAt: dateWithTime(17, 10, 0),
        ),
      );

      // Average of feedings in 9-15 days from now range (only feeding2)
      final avgWeight = await weightRepo.getAverageWeight(
        squirrel.id,
        daysFromNow(9),
        daysFromNow(15),
      );

      expect(avgWeight, equals(56.0));
    });

    test('should return null when no records in range', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final avgWeight = await weightRepo.getAverageWeight(
        squirrel.id,
        daysFromNow(29),
        daysFromNow(56),
      );

      expect(avgWeight, isNull);
    });
  });

  group('WeightRepository - Get Weight Change', () {
    test('should calculate weight change between dates', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add feeding at start of range
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-1',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10, 0),
          updatedAt: dateWithTime(-2, 10, 0),
        ),
      );

      // Add feeding at end of range
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-2',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(7, 10, 0),
          startingWeightGrams: 60.0,
          endingWeightGrams: 62.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(7, 10, 0),
          updatedAt: dateWithTime(7, 10, 0),
        ),
      );

      final weightChange = await weightRepo.getWeightChange(
        squirrel.id,
        dateWithTime(-2, 0, 0), // Start of first day
        endOfDay(7), // End of day to include the 10 AM feeding
      );

      // Change from first starting weight (50.0) to last ending weight (62.0)
      expect(weightChange, equals(12.0));
    });

    test('should return null when no records in range', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      final weightChange = await weightRepo.getWeightChange(
        squirrel.id,
        daysFromNow(29),
        daysFromNow(56),
      );

      expect(weightChange, isNull);
    });

    test('should handle negative weight change', () async {
      final squirrel = Squirrel.create(name: 'Test', foundDate: daysAgo(2));
      await squirrelRepo.addSquirrel(squirrel);

      // Add feeding with higher starting weight
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-1',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10, 0),
          startingWeightGrams: 60.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10, 0),
          updatedAt: dateWithTime(-2, 10, 0),
        ),
      );

      // Add feeding with lower ending weight
      await feedingRepo.addFeedingRecord(
        FeedingRecord(
          id: 'feed-2',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(7, 10, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(7, 10, 0),
          updatedAt: dateWithTime(7, 10, 0),
        ),
      );

      final weightChange = await weightRepo.getWeightChange(
        squirrel.id,
        dateWithTime(-2, 0, 0), // Start of first day
        endOfDay(7), // End of day to include the 10 AM feeding
      );

      // Change from 60.0 to 52.0 = -8.0
      expect(weightChange, equals(-8.0));
    });
  });
}
