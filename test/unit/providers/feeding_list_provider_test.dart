import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:foster_squirrel/models/feeding_record.dart';
import 'package:foster_squirrel/providers/feeding_list_provider.dart';

import '../mocks.mocks.dart';
import '../../helpers/test_date_utils.dart';

void main() {
  late MockFeedingRepository mockRepository;
  late FeedingListProvider provider;
  const testSquirrelId = 'sq-1';
  const admissionWeight = 50.0;

  setUp(() {
    mockRepository = MockFeedingRepository();
    provider = FeedingListProvider(
      repository: mockRepository,
      squirrelId: testSquirrelId,
      admissionWeight: admissionWeight,
    );
  });

  group('FeedingListProvider - Initial State', () {
    test('should start with empty feeding records', () {
      expect(provider.feedingRecords, isEmpty);
      expect(provider.sortedFeedingRecords, isEmpty);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, isFalse);
    });

    test('should have no error initially', () {
      expect(provider.error, isNull);
    });

    test('should not have data initially', () {
      expect(provider.hasData, isFalse);
    });

    test('should have empty baseline weight cache initially', () {
      expect(provider.baselineWeightCache, isEmpty);
    });

    test('should store squirrel ID correctly', () {
      expect(provider.squirrelId, equals(testSquirrelId));
    });

    test('should store admission weight correctly', () {
      expect(provider.admissionWeight, equals(admissionWeight));
    });
  });

  group('FeedingListProvider - Loading Records', () {
    test('should load feeding records successfully', () async {
      final testRecords = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
          endingWeightGrams: 54.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => testRecords);

      await provider.loadFeedingRecords();

      expect(provider.feedingRecords, hasLength(2));
      expect(provider.sortedFeedingRecords, hasLength(2));
      expect(provider.hasData, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should sort feeding records by time', () async {
      final testRecords = [
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: todayAt(11, 0), // Later
          startingWeightGrams: 52.0,
        ),
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: todayAt(8, 0), // Earlier
          startingWeightGrams: 50.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => testRecords);

      await provider.loadFeedingRecords();

      // Sorted records should be in chronological order
      expect(provider.sortedFeedingRecords[0].id, equals('feed-1'));
      expect(provider.sortedFeedingRecords[1].id, equals('feed-2'));
      expect(
        provider.sortedFeedingRecords[0].feedingTime.isBefore(
          provider.sortedFeedingRecords[1].feedingTime,
        ),
        isTrue,
      );
    });

    test('should precompute baseline weights correctly', () async {
      final testRecords = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
          endingWeightGrams: 54.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => testRecords);

      await provider.loadFeedingRecords();

      // First record should use admission weight as baseline
      expect(provider.baselineWeightCache['feed-1'], equals(admissionWeight));

      // Second record should use previous ending weight as baseline
      expect(provider.baselineWeightCache['feed-2'], equals(52.0));
    });

    test('should use starting weight if ending weight missing', () async {
      final testRecords = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          // No ending weight
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 50.0, // Same as previous starting
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => testRecords);

      await provider.loadFeedingRecords();

      // Second record should use previous starting weight if ending missing
      expect(provider.baselineWeightCache['feed-2'], equals(50.0));
    });

    test('should set loading state during load', () async {
      when(mockRepository.getFeedingRecords(testSquirrelId)).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final loadFuture = provider.loadFeedingRecords();

      expect(provider.isLoading, isTrue);

      await loadFuture;

      expect(provider.isLoading, isFalse);
    });

    test('should notify listeners when loading', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.loadFeedingRecords();

      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('should handle empty records gracefully', () async {
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.loadFeedingRecords();

      expect(provider.feedingRecords, isEmpty);
      expect(provider.sortedFeedingRecords, isEmpty);
      expect(provider.baselineWeightCache, isEmpty);
      expect(provider.hasData, isTrue);
      expect(provider.error, isNull);
    });

    test('should not start concurrent loads', () async {
      when(mockRepository.getFeedingRecords(testSquirrelId)).thenAnswer((
        _,
      ) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final load1 = provider.loadFeedingRecords();
      final load2 = provider.loadFeedingRecords();

      await Future.wait([load1, load2]);

      verify(mockRepository.getFeedingRecords(testSquirrelId)).called(1);
    });
  });

  group('FeedingListProvider - Error Handling', () {
    test('should handle repository errors gracefully', () async {
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenThrow(Exception('Database error'));

      await provider.loadFeedingRecords();

      expect(provider.error, isNotNull);
      expect(provider.error, contains('Failed to load feeding records'));
      expect(provider.isLoading, isFalse);
    });

    test('should clear previous error on successful load', () async {
      // First load fails
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenThrow(Exception('Error'));
      await provider.loadFeedingRecords();
      expect(provider.error, isNotNull);

      // Second load succeeds
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);
      await provider.loadFeedingRecords();

      expect(provider.error, isNull);
    });
  });

  group('FeedingListProvider - Refresh', () {
    test('should reload records when refresh called', () async {
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.refresh();

      verify(mockRepository.getFeedingRecords(testSquirrelId)).called(1);
      expect(provider.hasData, isTrue);
    });

    test('should get updated data on refresh', () async {
      final initialRecords = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
        ),
      ];

      final updatedRecords = [
        ...initialRecords,
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => initialRecords);
      await provider.loadFeedingRecords();
      expect(provider.feedingRecords, hasLength(1));

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => updatedRecords);
      await provider.refresh();
      expect(provider.feedingRecords, hasLength(2));
    });
  });

  group('FeedingListProvider - Add Record', () {
    test('should add feeding record successfully', () async {
      final newRecord = FeedingRecord(
        id: 'feed-new',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: dateWithTime(-2, 8, 0),
        startingWeightGrams: 50.0,
      );

      when(mockRepository.addFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [newRecord]);

      await provider.addFeedingRecord(newRecord);

      verify(mockRepository.addFeedingRecord(newRecord)).called(1);
      expect(provider.feedingRecords, hasLength(1));
      expect(provider.feedingRecords[0].id, equals('feed-new'));
    });

    test('should refresh after adding record', () async {
      final newRecord = FeedingRecord(
        id: 'feed-new',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(mockRepository.addFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [newRecord]);

      await provider.addFeedingRecord(newRecord);

      verify(mockRepository.getFeedingRecords(testSquirrelId)).called(1);
    });

    test('should handle add error and rethrow', () async {
      final newRecord = FeedingRecord(
        id: 'feed-new',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(
        mockRepository.addFeedingRecord(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.addFeedingRecord(newRecord), throwsException);

      expect(provider.error, contains('Failed to add feeding record'));
    });

    test('should notify listeners when record added', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final newRecord = FeedingRecord(
        id: 'feed-new',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(mockRepository.addFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [newRecord]);

      await provider.addFeedingRecord(newRecord);

      expect(notifyCount, greaterThan(0));
    });
  });

  group('FeedingListProvider - Update Record', () {
    test('should update feeding record successfully', () async {
      final originalRecord = FeedingRecord(
        id: 'feed-1',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: dateWithTime(-2, 8, 0),
        startingWeightGrams: 50.0,
      );

      final updatedRecord = originalRecord.copyWith(endingWeightGrams: 52.0);

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [originalRecord]);
      await provider.loadFeedingRecords();

      when(mockRepository.updateFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [updatedRecord]);

      await provider.updateFeedingRecord(updatedRecord);

      verify(mockRepository.updateFeedingRecord(updatedRecord)).called(1);
      expect(provider.feedingRecords[0].endingWeightGrams, equals(52.0));
    });

    test('should refresh and recompute caches after update', () async {
      final record = FeedingRecord(
        id: 'feed-1',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(mockRepository.updateFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [record]);

      await provider.updateFeedingRecord(record);

      verify(mockRepository.getFeedingRecords(testSquirrelId)).called(1);
    });

    test('should handle update error and rethrow', () async {
      final record = FeedingRecord(
        id: 'feed-1',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(
        mockRepository.updateFeedingRecord(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.updateFeedingRecord(record), throwsException);

      expect(provider.error, contains('Failed to update feeding record'));
    });

    test('should notify listeners when record updated', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final record = FeedingRecord(
        id: 'feed-1',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(mockRepository.updateFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [record]);

      await provider.updateFeedingRecord(record);

      expect(notifyCount, greaterThan(0));
    });
  });

  group('FeedingListProvider - Delete Record', () {
    test('should delete feeding record successfully', () async {
      final record = FeedingRecord(
        id: 'feed-1',
        squirrelId: testSquirrelId,
        squirrelName: 'Nutkin',
        feedingTime: DateTime.now(),
        startingWeightGrams: 50.0,
      );

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => [record]);
      await provider.loadFeedingRecords();
      expect(provider.feedingRecords, hasLength(1));

      when(mockRepository.deleteFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.deleteFeedingRecord('feed-1');

      verify(mockRepository.deleteFeedingRecord('feed-1')).called(1);
      expect(provider.feedingRecords, isEmpty);
    });

    test('should refresh and recompute caches after delete', () async {
      when(mockRepository.deleteFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.deleteFeedingRecord('feed-1');

      verify(mockRepository.getFeedingRecords(testSquirrelId)).called(1);
    });

    test('should handle delete error and rethrow', () async {
      when(
        mockRepository.deleteFeedingRecord(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.deleteFeedingRecord('feed-1'), throwsException);

      expect(provider.error, contains('Failed to delete feeding record'));
    });

    test('should notify listeners when record deleted', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockRepository.deleteFeedingRecord(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => []);

      await provider.deleteFeedingRecord('feed-1');

      expect(notifyCount, greaterThan(0));
    });
  });

  group('FeedingListProvider - Baseline Weight Cache', () {
    test('should use admission weight for first record baseline', () async {
      final records = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => records);

      await provider.loadFeedingRecords();

      expect(provider.baselineWeightCache['feed-1'], equals(admissionWeight));
    });

    test('should chain baseline weights through multiple records', () async {
      final records = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
          endingWeightGrams: 54.0,
        ),
        FeedingRecord(
          id: 'feed-3',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 14, 0),
          startingWeightGrams: 54.0,
          endingWeightGrams: 56.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => records);

      await provider.loadFeedingRecords();

      expect(
        provider.baselineWeightCache['feed-1'],
        equals(admissionWeight),
      ); // 50.0
      expect(provider.baselineWeightCache['feed-2'], equals(52.0));
      expect(provider.baselineWeightCache['feed-3'], equals(54.0));
    });

    test('should handle null admission weight', () async {
      final providerNoWeight = FeedingListProvider(
        repository: mockRepository,
        squirrelId: testSquirrelId,
        admissionWeight: null,
      );

      final records = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => records);

      await providerNoWeight.loadFeedingRecords();

      expect(providerNoWeight.baselineWeightCache['feed-1'], isNull);
    });
  });

  group('FeedingListProvider - Complex Scenarios', () {
    test('should handle records with gaps in ending weights', () async {
      final records = [
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
          endingWeightGrams: 52.0,
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
          // No ending weight
        ),
        FeedingRecord(
          id: 'feed-3',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 14, 0),
          startingWeightGrams: 52.0,
          endingWeightGrams: 54.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => records);

      await provider.loadFeedingRecords();

      // feed-2 has no ending weight, so feed-3 should use feed-2's starting weight
      expect(provider.baselineWeightCache['feed-3'], equals(52.0));
    });

    test('should maintain sort order with unsorted input', () async {
      final records = [
        FeedingRecord(
          id: 'feed-3',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 14, 0),
          startingWeightGrams: 54.0,
        ),
        FeedingRecord(
          id: 'feed-1',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 8, 0),
          startingWeightGrams: 50.0,
        ),
        FeedingRecord(
          id: 'feed-2',
          squirrelId: testSquirrelId,
          squirrelName: 'Nutkin',
          feedingTime: dateWithTime(-2, 11, 0),
          startingWeightGrams: 52.0,
        ),
      ];

      when(
        mockRepository.getFeedingRecords(testSquirrelId),
      ).thenAnswer((_) async => records);

      await provider.loadFeedingRecords();

      // Should be sorted chronologically
      expect(provider.sortedFeedingRecords[0].id, equals('feed-1'));
      expect(provider.sortedFeedingRecords[1].id, equals('feed-2'));
      expect(provider.sortedFeedingRecords[2].id, equals('feed-3'));
    });
  });
}
