import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';

import '../test_database_helper.dart';
import '../../helpers/test_date_utils.dart';

/// Integration tests for FeedingRepository (Drift version).
///
/// These tests use a real in-memory database to test the full stack
/// from repository through to actual database operations.
void main() {
  late AppDatabase database;
  late FeedingRepository feedingRepo;
  late SquirrelRepository squirrelRepo;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    feedingRepo = FeedingRepository(database);
    squirrelRepo = SquirrelRepository(database);
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('FeedingRepository - Add Feeding Record', () {
    test('should add feeding record successfully', () async {
      // Add squirrel first
      final squirrel = Squirrel.create(
        name: 'Nutkin',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Add feeding record
      final feeding = FeedingRecord.create(
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        startingWeightGrams: 50.0,
        endingWeightGrams: 55.0,
        actualFeedAmountML: 5.0,
        notes: 'First feeding',
      );

      await feedingRepo.addFeedingRecord(feeding);

      // Verify
      final records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records, hasLength(1));
      expect(records.first.id, equals(feeding.id));
      expect(records.first.squirrelName, equals('Nutkin'));
      expect(records.first.startingWeightGrams, equals(50.0));
      expect(records.first.endingWeightGrams, equals(55.0));
    });

    test(
      'should update squirrel current weight when ending weight provided',
      () async {
        // Add squirrel
        final squirrel = Squirrel.create(
          name: 'Test',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Add feeding with ending weight
        final feeding = FeedingRecord.create(
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          startingWeightGrams: 50.0,
          endingWeightGrams: 56.0,
          actualFeedAmountML: 5.0,
        );
        await feedingRepo.addFeedingRecord(feeding);

        // Verify squirrel's current weight was updated
        final updatedSquirrel = await squirrelRepo.getSquirrel(squirrel.id);
        expect(updatedSquirrel!.currentWeight, equals(56.0));
      },
    );

    test(
      'should not update squirrel weight when ending weight is null',
      () async {
        // Add squirrel
        var squirrel = Squirrel.create(
          name: 'Test',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
        );
        squirrel = squirrel.copyWith(currentWeight: 52.0);
        await squirrelRepo.addSquirrel(squirrel);

        // Add feeding without ending weight
        final feeding = FeedingRecord.create(
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          startingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
        );
        await feedingRepo.addFeedingRecord(feeding);

        // Verify squirrel's current weight unchanged
        final updatedSquirrel = await squirrelRepo.getSquirrel(squirrel.id);
        expect(updatedSquirrel!.currentWeight, equals(52.0));
      },
    );

    test('should throw exception when squirrel does not exist', () async {
      final feeding = FeedingRecord.create(
        squirrelId: 'non-existent-id',
        squirrelName: 'Ghost',
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );

      expect(
        () => feedingRepo.addFeedingRecord(feeding),
        throwsA(isA<FeedingRepositoryException>()),
      );
    });

    test('should persist all feeding record fields correctly', () async {
      final squirrel = Squirrel.create(
        name: 'Detailed Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final feedingTime = dateWithTime(12, 10, 30);
      final feeding = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: 'Detailed Test',
        feedingTime: feedingTime,
        startingWeightGrams: 45.5,
        actualFeedAmountML: 4.5,
        endingWeightGrams: 49.0,
        notes: 'Test notes',
        foodType: 'Formula',
        createdAt: feedingTime,
        updatedAt: feedingTime,
      );

      await feedingRepo.addFeedingRecord(feeding);

      final records = await feedingRepo.getFeedingRecords(squirrel.id);
      final retrieved = records.first;

      expect(retrieved.id, equals('feed-1'));
      expect(retrieved.feedingTime, equals(feedingTime));
      expect(retrieved.startingWeightGrams, equals(45.5));
      expect(retrieved.actualFeedAmountML, equals(4.5));
      expect(retrieved.endingWeightGrams, equals(49.0));
      expect(retrieved.notes, equals('Test notes'));
      expect(retrieved.foodType, equals('Formula'));
    });
  });

  group('FeedingRepository - Update Feeding Record', () {
    test('should update feeding record successfully', () async {
      // Setup
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final original = FeedingRecord.create(
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        notes: 'Original notes',
      );
      await feedingRepo.addFeedingRecord(original);

      // Update
      final updated = original.copyWith(
        actualFeedAmountML: 6.0,
        notes: 'Updated notes',
        endingWeightGrams: 55.0,
      );
      await feedingRepo.updateFeedingRecord(updated);

      // Verify
      final records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records.first.actualFeedAmountML, equals(6.0));
      expect(records.first.notes, equals('Updated notes'));
      expect(records.first.endingWeightGrams, equals(55.0));
    });

    test(
      'should update squirrel weight when updating most recent feeding',
      () async {
        var squirrel = Squirrel.create(
          name: 'Test',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
        );
        squirrel = squirrel.copyWith(currentWeight: 50.0);
        await squirrelRepo.addSquirrel(squirrel);

        final feeding = FeedingRecord.create(
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
        );
        await feedingRepo.addFeedingRecord(feeding);

        // Update with new ending weight
        final updated = feeding.copyWith(endingWeightGrams: 54.0);
        await feedingRepo.updateFeedingRecord(updated);

        // Verify squirrel weight updated
        final updatedSquirrel = await squirrelRepo.getSquirrel(squirrel.id);
        expect(updatedSquirrel!.currentWeight, equals(54.0));
      },
    );

    test(
      'should not update squirrel weight when updating old feeding',
      () async {
        final squirrel = Squirrel.create(
          name: 'Test',
          foundDate: daysAgo(2),
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Add two feedings
        final oldFeeding = FeedingRecord(
          id: 'old-feed',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10, 0),
          updatedAt: dateWithTime(-2, 10, 0),
        );

        final newFeeding = FeedingRecord(
          id: 'new-feed',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 14, 0), // Later time
          startingWeightGrams: 52.0,
          endingWeightGrams: 54.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 14, 0),
          updatedAt: dateWithTime(-2, 14, 0),
        );

        await feedingRepo.addFeedingRecord(oldFeeding);
        await feedingRepo.addFeedingRecord(newFeeding);

        // Update the old feeding
        final updated = oldFeeding.copyWith(endingWeightGrams: 53.0);
        await feedingRepo.updateFeedingRecord(updated);

        // Squirrel weight should still be from most recent feeding
        final updatedSquirrel = await squirrelRepo.getSquirrel(squirrel.id);
        expect(updatedSquirrel!.currentWeight, equals(54.0));
      },
    );
  });

  group('FeedingRepository - Delete Feeding Record', () {
    test('should delete feeding record successfully', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final feeding = FeedingRecord.create(
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await feedingRepo.addFeedingRecord(feeding);

      // Verify exists
      var records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records, hasLength(1));

      // Delete
      await feedingRepo.deleteFeedingRecord(feeding.id);

      // Verify deleted
      records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records, isEmpty);
    });

    test('should not throw when deleting non-existent record', () async {
      // Should not throw
      await feedingRepo.deleteFeedingRecord('non-existent-id');
    });
  });

  group('FeedingRepository - Query Feeding Records', () {
    test(
      'should get all feeding records for squirrel ordered by time',
      () async {
        final squirrel = Squirrel.create(
          name: 'Test',
          foundDate: daysAgo(2),
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Add multiple feedings
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

        final feeding2 = FeedingRecord(
          id: 'feed-2',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 14, 0),
          startingWeightGrams: 52.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 14, 0),
          updatedAt: dateWithTime(-2, 14, 0),
        );

        await feedingRepo.addFeedingRecord(feeding1);
        await feedingRepo.addFeedingRecord(feeding2);

        final records = await feedingRepo.getFeedingRecords(squirrel.id);

        expect(records, hasLength(2));
        // Should be ordered newest first
        expect(records[0].id, equals('feed-2'));
        expect(records[1].id, equals('feed-1'));
      },
    );

    test('should return empty list when squirrel has no feedings', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final records = await feedingRepo.getFeedingRecords(squirrel.id);

      expect(records, isEmpty);
    });

    test(
      'should throw when getting feedings for non-existent squirrel',
      () async {
        expect(
          () => feedingRepo.getFeedingRecords('non-existent-id'),
          throwsA(isA<FeedingRepositoryException>()),
        );
      },
    );

    test('should get last feeding record for squirrel', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

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

      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 14, 0),
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-2, 14, 0),
        updatedAt: dateWithTime(-2, 14, 0),
      );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);

      final lastFeeding = await feedingRepo.getLastFeedingRecord(squirrel.id);

      expect(lastFeeding, isNotNull);
      expect(lastFeeding!.id, equals('feed-2')); // Most recent
    });

    test('should return null when squirrel has no feedings', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final lastFeeding = await feedingRepo.getLastFeedingRecord(squirrel.id);

      expect(lastFeeding, isNull);
    });

    test('should get recent feeding records across all squirrels', () async {
      // Add two squirrels
      final squirrel1 = Squirrel.create(
        name: 'Squirrel 1',
        foundDate: daysAgo(2),
      );
      final squirrel2 = Squirrel.create(
        name: 'Squirrel 2',
        foundDate: daysAgo(2),
      );

      await squirrelRepo.addSquirrel(squirrel1);
      await squirrelRepo.addSquirrel(squirrel2);

      // Add feedings for both
      final feeding1 = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel1.id,
        squirrelName: squirrel1.name,
        feedingTime: dateWithTime(-2, 10, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-2, 10, 0),
        updatedAt: dateWithTime(-2, 10, 0),
      );

      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel2.id,
        squirrelName: squirrel2.name,
        feedingTime: dateWithTime(-2, 14, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(-2, 14, 0),
        updatedAt: dateWithTime(-2, 14, 0),
      );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);

      final recentRecords = await feedingRepo.getRecentFeedingRecords(
        limit: 10,
      );

      expect(recentRecords, hasLength(2));
      // Should be ordered newest first
      expect(recentRecords[0].squirrelName, equals('Squirrel 2'));
      expect(recentRecords[1].squirrelName, equals('Squirrel 1'));
    });

    test('should respect limit when getting recent records', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Add 5 feedings
      for (int i = 0; i < 5; i++) {
        final feeding = FeedingRecord(
          id: 'feed-$i',
          squirrelId: squirrel.id,
          squirrelName: squirrel.name,
          feedingTime: dateWithTime(-2, 10 + i, 0),
          startingWeightGrams: 50.0,
          actualFeedAmountML: 5.0,
          createdAt: dateWithTime(-2, 10 + i, 0),
          updatedAt: dateWithTime(-2, 10 + i, 0),
        );
        await feedingRepo.addFeedingRecord(feeding);
      }

      final recentRecords = await feedingRepo.getRecentFeedingRecords(limit: 3);

      expect(recentRecords, hasLength(3));
    });
  });

  group('FeedingRepository - Date Range Queries', () {
    test('should get feeding records within date range', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Add feedings on different days
      final feeding1 = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(7, 10, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(7, 10, 0),
        updatedAt: dateWithTime(7, 10, 0),
      );

      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(12, 10, 0),
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(12, 10, 0),
        updatedAt: dateWithTime(12, 10, 0),
      );

      final feeding3 = FeedingRecord(
        id: 'feed-3',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(17, 10, 0),
        startingWeightGrams: 54.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(17, 10, 0),
        updatedAt: dateWithTime(17, 10, 0),
      );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);
      await feedingRepo.addFeedingRecord(feeding3);

      // Query for records between Jan 12 and Jan 18
      final records = await feedingRepo.getFeedingRecordsInRange(
        squirrel.id,
        daysFromNow(9),
        daysFromNow(15),
      );

      expect(records, hasLength(1));
      expect(records.first.id, equals('feed-2'));
    });

    test('should return empty list when no records in range', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final feeding = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(7, 10, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: dateWithTime(7, 10, 0),
        updatedAt: dateWithTime(7, 10, 0),
      );

      await feedingRepo.addFeedingRecord(feeding);

      // Query for different date range
      final records = await feedingRepo.getFeedingRecordsInRange(
        squirrel.id,
        daysFromNow(29),
        daysFromNow(56),
      );

      expect(records, isEmpty);
    });

    test('should get today\'s feeding records', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final now = DateTime.now();

      // Add today's feeding
      final todayFeeding = FeedingRecord(
        id: 'feed-today',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: now,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: now,
        updatedAt: now,
      );

      // Add yesterday's feeding
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayFeeding = FeedingRecord(
        id: 'feed-yesterday',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: yesterday,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      await feedingRepo.addFeedingRecord(todayFeeding);
      await feedingRepo.addFeedingRecord(yesterdayFeeding);

      final todaysRecords = await feedingRepo.getTodaysFeedingRecords(
        squirrel.id,
      );

      expect(todaysRecords, hasLength(1));
      expect(todaysRecords.first.id, equals('feed-today'));
    });
  });

  group('FeedingRepository - Analytics', () {
    test('should calculate feeding frequency by food type', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Add feedings with different food types
      final feeding1 = FeedingRecord(
        id: 'feed-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 10, 0),
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
        foodType: 'Formula',
        createdAt: dateWithTime(-2, 10, 0),
        updatedAt: dateWithTime(-2, 10, 0),
      );

      final feeding2 = FeedingRecord(
        id: 'feed-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 12, 0),
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
        foodType: 'Formula',
        createdAt: dateWithTime(-2, 12, 0),
        updatedAt: dateWithTime(-2, 12, 0),
      );

      final feeding3 = FeedingRecord(
        id: 'feed-3',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-2, 14, 0),
        startingWeightGrams: 54.0,
        actualFeedAmountML: 3.0,
        foodType: 'Solid Food',
        createdAt: dateWithTime(-2, 14, 0),
        updatedAt: dateWithTime(-2, 14, 0),
      );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);
      await feedingRepo.addFeedingRecord(feeding3);

      final frequency = await feedingRepo.getFeedingFrequency(squirrel.id);

      expect(frequency['Formula'], equals(2));
      expect(frequency['Solid Food'], equals(1));
    });

    test('should return empty map when no feedings', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final frequency = await feedingRepo.getFeedingFrequency(squirrel.id);

      expect(frequency, isEmpty);
    });
  });

  group('FeedingRepository - Reactive Streams', () {
    test('should watch feeding records for squirrel', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final stream = feedingRepo.watchFeedingRecords(squirrel.id);

      // Listen to stream
      final records = <List<FeedingRecord>>[];
      final subscription = stream.listen((data) {
        records.add(data);
      });

      // Wait for initial empty state
      await Future.delayed(const Duration(milliseconds: 100));
      expect(records.last, isEmpty);

      // Add a feeding
      final feeding = FeedingRecord.create(
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await feedingRepo.addFeedingRecord(feeding);

      // Wait for stream update
      await Future.delayed(const Duration(milliseconds: 100));
      expect(records.last, hasLength(1));

      await subscription.cancel();
    });

    test('should watch recent feeding records across all squirrels', () async {
      final stream = feedingRepo.watchRecentFeedingRecords(limit: 10);

      final records = <List<FeedingRecord>>[];
      final subscription = stream.listen((data) {
        records.add(data);
      });

      // Wait for initial state
      await Future.delayed(const Duration(milliseconds: 100));
      expect(records.last, isEmpty);

      // Add squirrel and feeding
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
      );
      await squirrelRepo.addSquirrel(squirrel);

      final feeding = FeedingRecord.create(
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await feedingRepo.addFeedingRecord(feeding);

      // Wait for stream update
      await Future.delayed(const Duration(milliseconds: 100));
      expect(records.last, hasLength(1));

      await subscription.cancel();
    });
  });
}
