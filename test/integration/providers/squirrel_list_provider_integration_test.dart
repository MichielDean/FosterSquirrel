import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/providers/squirrel_list_provider.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';

import '../test_database_helper.dart';

/// Integration tests for SquirrelListProvider with real repository and database.
///
/// These tests verify the provider works correctly with actual data persistence,
/// testing the full Provider → Repository → Database flow.
void main() {
  late AppDatabase database;
  late SquirrelRepository repository;
  late SquirrelListProvider provider;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    repository = SquirrelRepository(database);
    provider = SquirrelListProvider(repository);
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('SquirrelListProvider Integration - Load with Real Database', () {
    test('should load squirrels from database successfully', () async {
      // Arrange - Add squirrels to database
      final squirrel1 = Squirrel.create(
        name: 'Nutkin',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 50.0,
        developmentStage: DevelopmentStage.infant,
      );
      final squirrel2 = Squirrel.create(
        name: 'Fluffy',
        foundDate: DateTime(2025, 1, 2),
        admissionWeight: 55.0,
        developmentStage: DevelopmentStage.infant,
      );

      await repository.addSquirrel(squirrel1);
      await repository.addSquirrel(squirrel2);

      // Act
      await provider.loadSquirrels();

      // Assert
      expect(provider.squirrels, hasLength(2));
      expect(
        provider.squirrels.map((s) => s.name),
        containsAll(['Nutkin', 'Fluffy']),
      );
      expect(provider.hasData, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should load only active squirrels', () async {
      // Arrange
      final activeSquirrel = Squirrel.create(
        name: 'Active',
        foundDate: DateTime(2025, 1, 1),
      );
      final releasedSquirrel = Squirrel.create(
        name: 'Released',
        foundDate: DateTime(2025, 1, 1),
      ).copyWith(status: SquirrelStatus.released);

      await repository.addSquirrel(activeSquirrel);
      await repository.addSquirrel(releasedSquirrel);

      // Act
      await provider.loadSquirrels();

      // Assert
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels.first.name, equals('Active'));
    });

    test('should handle empty database gracefully', () async {
      // Act
      await provider.loadSquirrels();

      // Assert
      expect(provider.squirrels, isEmpty);
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
      await provider.loadSquirrels();

      // Assert - Should transition from loading to not loading
      expect(states, contains(true));
      expect(states.last, isFalse);
    });
  });

  group('SquirrelListProvider Integration - Add Squirrel', () {
    test('should add squirrel and persist to database', () async {
      // Arrange
      final squirrel = Squirrel.create(
        name: 'NewSquirrel',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 48.0,
      );

      // Act
      await provider.addSquirrel(squirrel);

      // Assert - Check provider state
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels.first.name, equals('NewSquirrel'));

      // Assert - Verify persistence in database
      final squirrels = await repository.getActiveSquirrels();
      expect(squirrels, hasLength(1));
      expect(squirrels.first.name, equals('NewSquirrel'));
      expect(squirrels.first.admissionWeight, equals(48.0));
    });

    test('should notify listeners when squirrel is added', () async {
      // Arrange
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: DateTime(2025, 1, 1),
      );

      // Act
      await provider.addSquirrel(squirrel);

      // Assert
      expect(notifyCount, greaterThan(0));
    });

    test('should add multiple squirrels independently', () async {
      // Arrange
      final squirrel1 = Squirrel.create(
        name: 'Squirrel1',
        foundDate: DateTime(2025, 1, 1),
      );
      final squirrel2 = Squirrel.create(
        name: 'Squirrel2',
        foundDate: DateTime(2025, 1, 2),
      );

      // Act
      await provider.addSquirrel(squirrel1);
      await provider.addSquirrel(squirrel2);

      // Assert
      expect(provider.squirrels, hasLength(2));
      expect(
        provider.squirrels.map((s) => s.name),
        containsAll(['Squirrel1', 'Squirrel2']),
      );

      // Verify in database
      final dbSquirrels = await repository.getActiveSquirrels();
      expect(dbSquirrels, hasLength(2));
    });
  });

  group('SquirrelListProvider Integration - Update Squirrel', () {
    test('should update squirrel and persist changes', () async {
      // Arrange - Add squirrel
      final original = Squirrel.create(
        name: 'Original',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 50.0,
      );
      await provider.addSquirrel(original);

      // Act - Update squirrel
      final updated = original.copyWith(name: 'Updated', admissionWeight: 55.0);
      await provider.updateSquirrel(updated);

      // Assert - Check provider state
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels.first.name, equals('Updated'));
      expect(provider.squirrels.first.admissionWeight, equals(55.0));

      // Assert - Verify persistence
      final fromDb = await repository.getSquirrel(original.id);
      expect(fromDb?.name, equals('Updated'));
      expect(fromDb?.admissionWeight, equals(55.0));
    });

    test('should update squirrel status correctly', () async {
      // Arrange
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: DateTime(2025, 1, 1),
      );
      await provider.addSquirrel(squirrel);

      // Act - Change status to released
      final released = squirrel.copyWith(status: SquirrelStatus.released);
      await provider.updateSquirrel(released);

      // Assert - Should still be in provider (provider doesn't filter on update)
      expect(provider.squirrels, hasLength(1));

      // Reload to get active squirrels only
      await provider.loadSquirrels();
      expect(provider.squirrels, isEmpty);

      // Verify in database
      final fromDb = await repository.getSquirrel(squirrel.id);
      expect(fromDb?.status, equals(SquirrelStatus.released));
    });

    test('should notify listeners when squirrel is updated', () async {
      // Arrange
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: DateTime(2025, 1, 1),
      );
      await provider.addSquirrel(squirrel);

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      final updated = squirrel.copyWith(name: 'Updated');
      await provider.updateSquirrel(updated);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('SquirrelListProvider Integration - Delete Squirrel', () {
    test('should delete squirrel and remove from database', () async {
      // Arrange
      final squirrel = Squirrel.create(
        name: 'ToDelete',
        foundDate: DateTime(2025, 1, 1),
      );
      await provider.addSquirrel(squirrel);
      expect(provider.squirrels, hasLength(1));

      // Act
      await provider.deleteSquirrel(squirrel.id);

      // Assert - Check provider state
      expect(provider.squirrels, isEmpty);

      // Assert - Verify deletion from database
      final fromDb = await repository.getSquirrel(squirrel.id);
      expect(fromDb, isNull);
    });

    test('should delete correct squirrel when multiple exist', () async {
      // Arrange
      final squirrel1 = Squirrel.create(
        name: 'Keep',
        foundDate: DateTime(2025, 1, 1),
      );
      final squirrel2 = Squirrel.create(
        name: 'Delete',
        foundDate: DateTime(2025, 1, 2),
      );

      await provider.addSquirrel(squirrel1);
      await provider.addSquirrel(squirrel2);

      // Act
      await provider.deleteSquirrel(squirrel2.id);

      // Assert
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels.first.name, equals('Keep'));

      // Verify in database
      final dbSquirrels = await repository.getActiveSquirrels();
      expect(dbSquirrels, hasLength(1));
      expect(dbSquirrels.first.name, equals('Keep'));
    });

    test('should notify listeners when squirrel is deleted', () async {
      // Arrange
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: DateTime(2025, 1, 1),
      );
      await provider.addSquirrel(squirrel);

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.deleteSquirrel(squirrel.id);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  // Note: Error handling for database errors is tested at the repository level
  // and in unit tests. Integration tests focus on successful data flows.

  group('SquirrelListProvider Integration - Data Consistency', () {
    test('should maintain consistency across multiple operations', () async {
      // Arrange & Act - Complex sequence of operations
      final squirrel1 = Squirrel.create(
        name: 'First',
        foundDate: DateTime(2025, 1, 1),
      );
      await provider.addSquirrel(squirrel1);

      final squirrel2 = Squirrel.create(
        name: 'Second',
        foundDate: DateTime(2025, 1, 2),
      );
      await provider.addSquirrel(squirrel2);

      final updated = squirrel1.copyWith(name: 'FirstUpdated');
      await provider.updateSquirrel(updated);

      await provider.deleteSquirrel(squirrel2.id);

      // Reload from database
      await provider.loadSquirrels();

      // Assert
      expect(provider.squirrels, hasLength(1));
      expect(provider.squirrels.first.name, equals('FirstUpdated'));

      // Verify database state
      final dbSquirrels = await repository.getActiveSquirrels();
      expect(dbSquirrels, hasLength(1));
      expect(dbSquirrels.first.name, equals('FirstUpdated'));
    });
  });
}
