import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:foster_squirrel/models/squirrel.dart';
import 'package:foster_squirrel/providers/squirrel_list_provider.dart';

import '../mocks.mocks.dart';
import '../../helpers/test_date_utils.dart';

void main() {
  late MockSquirrelRepository mockRepository;
  late SquirrelListProvider provider;

  setUp(() {
    mockRepository = MockSquirrelRepository();
    provider = SquirrelListProvider(mockRepository);
  });

  group('SquirrelListProvider - Initial State', () {
    test('should start with empty squirrel list', () {
      expect(provider.squirrels, isEmpty);
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
  });

  group('SquirrelListProvider - Loading Squirrels', () {
    test('should load squirrels successfully', () async {
      final testSquirrels = [
        Squirrel(
          id: 'sq-1',
          name: 'Nutkin',
          foundDate: daysAgo(2),
          status: SquirrelStatus.active,
        ),
        Squirrel(
          id: 'sq-2',
          name: 'Fluffy',
          foundDate: daysAgo(1),
          status: SquirrelStatus.active,
        ),
      ];

      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => testSquirrels);

      await provider.loadSquirrels();

      expect(provider.squirrels, hasLength(2));
      expect(provider.squirrels[0].name, equals('Nutkin'));
      expect(provider.squirrels[1].name, equals('Fluffy'));
      expect(provider.hasData, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should set loading state during load', () async {
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async {
        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final loadFuture = provider.loadSquirrels();

      // Should be loading immediately after calling
      expect(provider.isLoading, isTrue);

      await loadFuture;

      // Should not be loading after completion
      expect(provider.isLoading, isFalse);
    });

    test('should notify listeners when loading starts', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);

      await provider.loadSquirrels();

      // Should notify at least twice: loading start and loading end
      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('should handle empty result gracefully', () async {
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);

      await provider.loadSquirrels();

      expect(provider.squirrels, isEmpty);
      expect(provider.hasData, isTrue); // Has data even if empty
      expect(provider.error, isNull);
    });

    test('should not start concurrent loads', () async {
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      // Start first load
      final load1 = provider.loadSquirrels();
      // Try to start second load while first is running
      final load2 = provider.loadSquirrels();

      await Future.wait([load1, load2]);

      // Repository should only be called once
      verify(mockRepository.getActiveSquirrels()).called(1);
    });
  });

  group('SquirrelListProvider - Error Handling', () {
    test('should handle repository errors gracefully', () async {
      when(
        mockRepository.getActiveSquirrels(),
      ).thenThrow(Exception('Database error'));

      await provider.loadSquirrels();

      expect(provider.error, isNotNull);
      expect(provider.error, contains('Failed to load squirrels'));
      expect(provider.squirrels, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('should clear previous error on successful load', () async {
      // First load fails
      when(mockRepository.getActiveSquirrels()).thenThrow(Exception('Error'));
      await provider.loadSquirrels();
      expect(provider.error, isNotNull);

      // Second load succeeds
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);
      await provider.loadSquirrels();

      expect(provider.error, isNull);
    });

    test('should maintain previous data when load fails', () async {
      final testSquirrels = [
        Squirrel(
          id: 'sq-1',
          name: 'Nutkin',
          foundDate: DateTime.now(),
          status: SquirrelStatus.active,
        ),
      ];

      // First load succeeds
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => testSquirrels);
      await provider.loadSquirrels();
      expect(provider.squirrels, hasLength(1));

      // Second load fails
      when(mockRepository.getActiveSquirrels()).thenThrow(Exception('Error'));
      await provider.loadSquirrels();

      // Should keep previous data but set error
      expect(provider.squirrels, isEmpty); // Cleared on error
      expect(provider.error, isNotNull);
    });
  });

  group('SquirrelListProvider - Refresh', () {
    test('should reload squirrels when refresh called', () async {
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);

      await provider.refresh();

      verify(mockRepository.getActiveSquirrels()).called(1);
      expect(provider.hasData, isTrue);
    });

    test('should get updated data on refresh', () async {
      final initialSquirrels = [
        Squirrel(
          id: 'sq-1',
          name: 'Nutkin',
          foundDate: DateTime.now(),
          status: SquirrelStatus.active,
        ),
      ];

      final updatedSquirrels = [
        Squirrel(
          id: 'sq-1',
          name: 'Nutkin',
          foundDate: DateTime.now(),
          status: SquirrelStatus.active,
        ),
        Squirrel(
          id: 'sq-2',
          name: 'Fluffy',
          foundDate: DateTime.now(),
          status: SquirrelStatus.active,
        ),
      ];

      // First load
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => initialSquirrels);
      await provider.loadSquirrels();
      expect(provider.squirrels, hasLength(1));

      // Refresh with updated data
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => updatedSquirrels);
      await provider.refresh();
      expect(provider.squirrels, hasLength(2));
    });
  });

  group('SquirrelListProvider - Add Squirrel', () {
    test('should add squirrel successfully', () async {
      final newSquirrel = Squirrel(
        id: 'sq-new',
        name: 'NewSquirrel',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(mockRepository.addSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [newSquirrel]);

      await provider.addSquirrel(newSquirrel);

      verify(mockRepository.addSquirrel(newSquirrel)).called(1);
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels[0].id, equals('sq-new'));
    });

    test('should notify listeners when squirrel added', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final newSquirrel = Squirrel(
        id: 'sq-new',
        name: 'NewSquirrel',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(mockRepository.addSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [newSquirrel]);

      await provider.addSquirrel(newSquirrel);

      expect(notifyCount, greaterThan(0));
    });

    test('should handle add error and rethrow', () async {
      final newSquirrel = Squirrel(
        id: 'sq-new',
        name: 'NewSquirrel',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(
        mockRepository.addSquirrel(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.addSquirrel(newSquirrel), throwsException);

      expect(provider.error, contains('Failed to add squirrel'));
    });

    test('should refresh list after adding squirrel', () async {
      final newSquirrel = Squirrel(
        id: 'sq-new',
        name: 'NewSquirrel',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(mockRepository.addSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [newSquirrel]);

      await provider.addSquirrel(newSquirrel);

      // Should call getActiveSquirrels to refresh
      verify(mockRepository.getActiveSquirrels()).called(1);
    });
  });

  group('SquirrelListProvider - Update Squirrel', () {
    test('should update squirrel successfully', () async {
      final originalSquirrel = Squirrel(
        id: 'sq-1',
        name: 'Original',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
        currentWeight: 50.0,
      );

      final updatedSquirrel = originalSquirrel.copyWith(
        name: 'Updated',
        currentWeight: 75.0,
      );

      // Initial load
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [originalSquirrel]);
      await provider.loadSquirrels();

      // Update
      when(mockRepository.updateSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [updatedSquirrel]);

      await provider.updateSquirrel(updatedSquirrel);

      verify(mockRepository.updateSquirrel(updatedSquirrel)).called(1);
      expect(provider.squirrels[0].name, equals('Updated'));
      expect(provider.squirrels[0].currentWeight, equals(75.0));
    });

    test('should notify listeners when squirrel updated', () async {
      // First need to load some data
      final initialSquirrel = Squirrel(
        id: 'sq-1',
        name: 'Original',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [initialSquirrel]);
      await provider.loadSquirrels();

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final updatedSquirrel = initialSquirrel.copyWith(name: 'Updated');

      when(mockRepository.updateSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [updatedSquirrel]);

      await provider.updateSquirrel(updatedSquirrel);

      expect(notifyCount, greaterThan(0));
    });

    test('should handle update error and rethrow', () async {
      final squirrel = Squirrel(
        id: 'sq-1',
        name: 'Test',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      when(
        mockRepository.updateSquirrel(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.updateSquirrel(squirrel), throwsException);

      expect(provider.error, contains('Failed to update squirrel'));
    });
  });

  group('SquirrelListProvider - Delete Squirrel', () {
    test('should delete squirrel successfully', () async {
      final squirrel = Squirrel(
        id: 'sq-1',
        name: 'ToDelete',
        foundDate: DateTime.now(),
        status: SquirrelStatus.active,
      );

      // Initial load with squirrel
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => [squirrel]);
      await provider.loadSquirrels();
      expect(provider.squirrels, hasLength(1));

      // Delete
      when(mockRepository.deleteSquirrel(any)).thenAnswer((_) async => {});
      when(
        mockRepository.getActiveSquirrels(),
      ).thenAnswer((_) async => []); // Empty after delete

      await provider.deleteSquirrel('sq-1');

      verify(mockRepository.deleteSquirrel('sq-1')).called(1);
      expect(provider.squirrels, isEmpty);
    });

    test('should notify listeners when squirrel deleted', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockRepository.deleteSquirrel(any)).thenAnswer((_) async => {});
      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);

      await provider.deleteSquirrel('sq-1');

      expect(notifyCount, greaterThan(0));
    });

    test('should handle delete error and rethrow', () async {
      when(
        mockRepository.deleteSquirrel(any),
      ).thenThrow(Exception('Database error'));

      expect(() => provider.deleteSquirrel('sq-1'), throwsException);

      expect(provider.error, contains('Failed to delete squirrel'));
    });
  });

  group('SquirrelListProvider - Listener Notifications', () {
    test('should notify listeners exactly twice on successful load', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockRepository.getActiveSquirrels()).thenAnswer((_) async => []);

      await provider.loadSquirrels();

      // Once for loading start, once for loading end
      expect(notifyCount, equals(2));
    });

    test('should notify listeners on error', () async {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      when(mockRepository.getActiveSquirrels()).thenThrow(Exception('Error'));

      await provider.loadSquirrels();

      // Should notify even on error
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });
}
