import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/providers/feeding_list_provider.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';

import '../test_database_helper.dart';

/// Integration tests for FeedingListProvider with real repository and database.
///
/// These tests verify the provider works correctly with actual data persistence,
/// testing the full Provider → Repository → Database flow.
void main() {
  late AppDatabase database;
  late FeedingRepository feedingRepo;
  late SquirrelRepository squirrelRepo;
  late FeedingListProvider provider;
  late Squirrel testSquirrel;

  const admissionWeight = 50.0;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    feedingRepo = FeedingRepository(database);
    squirrelRepo = SquirrelRepository(database);

    // Create a test squirrel for all tests
    testSquirrel = Squirrel.create(
      name: 'TestSquirrel',
      foundDate: DateTime(2025, 1, 1),
      admissionWeight: admissionWeight,
    );
    await squirrelRepo.addSquirrel(testSquirrel);

    provider = FeedingListProvider(
      repository: feedingRepo,
      squirrelId: testSquirrel.id,
      admissionWeight: admissionWeight,
    );
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('FeedingListProvider Integration - Load with Real Database', () {
    test('should load feeding records from database successfully', () async {
      // Arrange - Add feeding records to database
      final feeding1 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 8, 0));

      final feeding2 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 11, 0));

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);

      // Act
      await provider.loadFeedingRecords();

      // Assert
      expect(provider.feedingRecords, hasLength(2));
      expect(provider.hasData, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should sort feeding records by time', () async {
      // Arrange - Add records in reverse chronological order
      final feeding2 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 11, 0));

      final feeding1 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 8, 0));

      await feedingRepo.addFeedingRecord(feeding2);
      await feedingRepo.addFeedingRecord(feeding1);

      // Act
      await provider.loadFeedingRecords();

      // Assert - Should be sorted chronologically
      expect(provider.sortedFeedingRecords, hasLength(2));
      expect(
        provider.sortedFeedingRecords[0].feedingTime.isBefore(
          provider.sortedFeedingRecords[1].feedingTime,
        ),
        isTrue,
      );
    });

    test('should precompute baseline weights correctly', () async {
      // Arrange
      final feeding1 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 50.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 8, 0),
            endingWeightGrams: 52.0,
          );

      final feeding2 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 52.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 11, 0),
            endingWeightGrams: 54.0,
          );

      await feedingRepo.addFeedingRecord(feeding1);
      await feedingRepo.addFeedingRecord(feeding2);

      // Act
      await provider.loadFeedingRecords();

      // Assert - First record uses admission weight
      expect(
        provider.baselineWeightCache[feeding1.id],
        equals(admissionWeight),
      );

      // Second record uses first record's ending weight
      expect(provider.baselineWeightCache[feeding2.id], equals(52.0));
    });

    test('should handle empty database gracefully', () async {
      // Act
      await provider.loadFeedingRecords();

      // Assert
      expect(provider.feedingRecords, isEmpty);
      expect(provider.sortedFeedingRecords, isEmpty);
      expect(provider.baselineWeightCache, isEmpty);
      expect(provider.hasData, isTrue);
      expect(provider.error, isNull);
    });

    test('should update state correctly during load', () async {
      // Arrange
      final states = <bool>[];
      provider.addListener(() {
        states.add(provider.isLoading);
      });

      // Act
      await provider.loadFeedingRecords();

      // Assert - Should transition from loading to not loading
      expect(states, contains(true));
      expect(states.last, isFalse);
    });
  });

  group('FeedingListProvider Integration - Add Feeding Record', () {
    test('should add feeding record and persist to database', () async {
      // Arrange
      final feeding = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );

      // Act
      await provider.addFeedingRecord(feeding);

      // Assert - Check provider state
      expect(provider.feedingRecords, hasLength(1));
      expect(provider.sortedFeedingRecords, hasLength(1));

      // Verify persistence in database
      final records = await feedingRepo.getFeedingRecords(testSquirrel.id);
      expect(records, hasLength(1));
      expect(records.first.startingWeightGrams, equals(50.0));
      expect(records.first.actualFeedAmountML, equals(5.0));
    });

    test('should recompute caches after adding record', () async {
      // Arrange - Add first feeding
      final feeding1 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 50.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 8, 0),
            endingWeightGrams: 52.0,
          );
      await provider.addFeedingRecord(feeding1);

      // Act - Add second feeding
      final feeding2 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 11, 0));
      await provider.addFeedingRecord(feeding2);

      // Assert - Baseline weights should be recomputed
      expect(provider.baselineWeightCache, hasLength(2));
      // Second feeding's baseline should be first feeding's ending weight
      final sortedRecords = provider.sortedFeedingRecords;
      expect(provider.baselineWeightCache[sortedRecords[1].id], equals(52.0));
    });

    test('should notify listeners when feeding is added', () async {
      // Arrange
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final feeding = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );

      // Act
      await provider.addFeedingRecord(feeding);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('FeedingListProvider Integration - Update Feeding Record', () {
    test('should update feeding record and persist changes', () async {
      // Arrange - Add feeding
      final original = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await provider.addFeedingRecord(original);

      // Act - Update feeding
      final updated = original.copyWith(
        startingWeightGrams: 55.0,
        actualFeedAmountML: 6.0,
      );
      await provider.updateFeedingRecord(updated);

      // Assert - Check provider state
      expect(provider.feedingRecords, hasLength(1));
      expect(provider.feedingRecords.first.startingWeightGrams, equals(55.0));
      expect(provider.feedingRecords.first.actualFeedAmountML, equals(6.0));

      // Verify persistence
      final records = await feedingRepo.getFeedingRecords(testSquirrel.id);
      expect(records.first.startingWeightGrams, equals(55.0));
      expect(records.first.actualFeedAmountML, equals(6.0));
    });

    test('should recompute caches after update', () async {
      // Arrange - Add two feedings
      final feeding1 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 50.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 8, 0),
            endingWeightGrams: 52.0,
          );

      final feeding2 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 11, 0));

      await provider.addFeedingRecord(feeding1);
      await provider.addFeedingRecord(feeding2);

      // Act - Update first feeding's ending weight
      final updated = feeding1.copyWith(endingWeightGrams: 53.0);
      await provider.updateFeedingRecord(updated);

      // Assert - Second feeding's baseline should update
      final sortedRecords = provider.sortedFeedingRecords;
      expect(provider.baselineWeightCache[sortedRecords[1].id], equals(53.0));
    });

    test('should notify listeners when feeding is updated', () async {
      // Arrange
      final feeding = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await provider.addFeedingRecord(feeding);

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      final updated = feeding.copyWith(actualFeedAmountML: 6.0);
      await provider.updateFeedingRecord(updated);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('FeedingListProvider Integration - Delete Feeding Record', () {
    test('should delete feeding record and remove from database', () async {
      // Arrange
      final feeding = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await provider.addFeedingRecord(feeding);
      expect(provider.feedingRecords, hasLength(1));

      // Act
      await provider.deleteFeedingRecord(feeding.id);

      // Assert - Check provider state
      expect(provider.feedingRecords, isEmpty);
      expect(provider.sortedFeedingRecords, isEmpty);
      expect(provider.baselineWeightCache, isEmpty);

      // Verify deletion from database
      final records = await feedingRepo.getFeedingRecords(testSquirrel.id);
      expect(records, isEmpty);
    });

    test('should recompute caches after deletion', () async {
      // Arrange - Add three feedings
      final feeding1 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 50.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 8, 0),
            endingWeightGrams: 52.0,
          );

      final feeding2 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 52.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 11, 0),
            endingWeightGrams: 54.0,
          );

      final feeding3 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 54.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 14, 0));

      await provider.addFeedingRecord(feeding1);
      await provider.addFeedingRecord(feeding2);
      await provider.addFeedingRecord(feeding3);

      // Act - Delete middle feeding
      await provider.deleteFeedingRecord(feeding2.id);

      // Assert - Third feeding's baseline should now use first feeding's ending weight
      expect(provider.sortedFeedingRecords, hasLength(2));
      final sortedRecords = provider.sortedFeedingRecords;
      expect(provider.baselineWeightCache[sortedRecords[1].id], equals(52.0));
    });

    test('should notify listeners when feeding is deleted', () async {
      // Arrange
      final feeding = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 50.0,
        actualFeedAmountML: 5.0,
      );
      await provider.addFeedingRecord(feeding);

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.deleteFeedingRecord(feeding.id);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  // Note: Error handling for database errors is tested at the repository level
  // and in unit tests. Integration tests focus on successful data flows.

  group('FeedingListProvider Integration - Data Consistency', () {
    test('should maintain consistency across multiple operations', () async {
      // Arrange & Act - Complex sequence of operations
      final feeding1 =
          FeedingRecord.create(
            squirrelId: testSquirrel.id,
            squirrelName: testSquirrel.name,
            startingWeightGrams: 50.0,
            actualFeedAmountML: 5.0,
          ).copyWith(
            feedingTime: DateTime(2025, 1, 1, 8, 0),
            endingWeightGrams: 52.0,
          );
      await provider.addFeedingRecord(feeding1);

      final feeding2 = FeedingRecord.create(
        squirrelId: testSquirrel.id,
        squirrelName: testSquirrel.name,
        startingWeightGrams: 52.0,
        actualFeedAmountML: 5.0,
      ).copyWith(feedingTime: DateTime(2025, 1, 1, 11, 0));
      await provider.addFeedingRecord(feeding2);

      final updated = feeding1.copyWith(endingWeightGrams: 53.0);
      await provider.updateFeedingRecord(updated);

      await provider.deleteFeedingRecord(feeding2.id);

      // Reload from database
      await provider.loadFeedingRecords();

      // Assert
      expect(provider.feedingRecords, hasLength(1));
      expect(provider.feedingRecords.first.endingWeightGrams, equals(53.0));

      // Verify database state
      final dbRecords = await feedingRepo.getFeedingRecords(testSquirrel.id);
      expect(dbRecords, hasLength(1));
      expect(dbRecords.first.endingWeightGrams, equals(53.0));
    });
  });
}
