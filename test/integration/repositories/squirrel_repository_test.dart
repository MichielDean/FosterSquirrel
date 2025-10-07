import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/squirrel.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';

import '../test_database_helper.dart';
import '../../helpers/test_date_utils.dart';

/// Integration tests for SquirrelRepository (Drift version).
///
/// These tests use a real database (in-memory) to test the full stack
/// from repository through to actual database operations.
void main() {
  late AppDatabase database;
  late SquirrelRepository repository;

  setUp(() async {
    database = TestDatabaseHelper.createTestDatabase();
    repository = SquirrelRepository(database);
  });

  tearDown(() async {
    await TestDatabaseHelper.closeDatabase(database);
  });

  group('SquirrelRepository - Add and Retrieve', () {
    test('should add and retrieve squirrel successfully', () async {
      final squirrel = Squirrel.create(
        name: 'Nutkin',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
        developmentStage: DevelopmentStage.infant,
      );

      await repository.addSquirrel(squirrel);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(squirrel.id));
      expect(retrieved.name, equals('Nutkin'));
      expect(retrieved.admissionWeight, equals(50.0));
      expect(retrieved.developmentStage, equals(DevelopmentStage.infant));
    });

    test('should persist all squirrel fields correctly', () async {
      final squirrel = Squirrel(
        id: 'test-squirrel-1',
        name: 'Detailed Test',
        foundDate: daysFromNow(12),
        admissionWeight: 45.5,
        currentWeight: 52.3,
        status: SquirrelStatus.active,
        developmentStage: DevelopmentStage.juvenile,
        notes: 'Test notes about this squirrel',
        photoPath: '/path/to/photo.jpg',
        createdAt: dateWithTime(12, 8, 0),
        updatedAt: dateWithTime(12, 10, 0),
      );

      await repository.addSquirrel(squirrel);
      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.name, equals('Detailed Test'));
      // Check the foundDate matches what we set (use isSameDay-like comparison)
      expect(retrieved.foundDate.year, equals(squirrel.foundDate.year));
      expect(retrieved.foundDate.month, equals(squirrel.foundDate.month));
      expect(retrieved.foundDate.day, equals(squirrel.foundDate.day));
      expect(retrieved.admissionWeight, equals(45.5));
      expect(retrieved.currentWeight, equals(52.3));
      expect(retrieved.status, equals(SquirrelStatus.active));
      expect(retrieved.developmentStage, equals(DevelopmentStage.juvenile));
      expect(retrieved.notes, equals('Test notes about this squirrel'));
      expect(retrieved.photoPath, equals('/path/to/photo.jpg'));
    });

    test('should return null when squirrel not found', () async {
      final retrieved = await repository.getSquirrel('non-existent-id');

      expect(retrieved, isNull);
    });

    test('should add multiple squirrels independently', () async {
      final squirrel1 = Squirrel.create(
        name: 'Nutkin',
        foundDate: daysAgo(2),
      );

      final squirrel2 = Squirrel.create(
        name: 'Fluffy',
        foundDate: daysAgo(1),
      );

      await repository.addSquirrel(squirrel1);
      await repository.addSquirrel(squirrel2);

      final retrieved1 = await repository.getSquirrel(squirrel1.id);
      final retrieved2 = await repository.getSquirrel(squirrel2.id);

      expect(retrieved1, isNotNull);
      expect(retrieved2, isNotNull);
      expect(retrieved1!.id, equals(squirrel1.id));
      expect(retrieved2!.id, equals(squirrel2.id));
    });
  });

  group('SquirrelRepository - Update', () {
    test('should update squirrel successfully', () async {
      final original = Squirrel.create(
        name: 'Original Name',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      await repository.addSquirrel(original);

      final updated = original.copyWith(
        name: 'Updated Name',
        currentWeight: 65.0,
      );

      await repository.updateSquirrel(updated);

      final retrieved = await repository.getSquirrel(original.id);

      expect(retrieved!.name, equals('Updated Name'));
      expect(retrieved.currentWeight, equals(65.0));
      expect(
        retrieved.admissionWeight,
        equals(50.0),
      ); // Should remain unchanged
    });

    test('should update status correctly', () async {
      final squirrel = Squirrel.create(
        name: 'Test',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      await repository.addSquirrel(squirrel);

      final updated = squirrel.copyWith(status: SquirrelStatus.released);
      await repository.updateSquirrel(updated);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.status, equals(SquirrelStatus.released));
    });

    test('should update development stage correctly', () async {
      final squirrel = Squirrel.create(
        name: 'Growing',
        foundDate: daysAgo(2),
        developmentStage: DevelopmentStage.infant,
      );

      await repository.addSquirrel(squirrel);

      final updated = squirrel.copyWith(
        developmentStage: DevelopmentStage.juvenile,
      );
      await repository.updateSquirrel(updated);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.developmentStage, equals(DevelopmentStage.juvenile));
    });

    test('should update notes correctly', () async {
      final squirrel = Squirrel.create(
        name: 'Noted',
        foundDate: daysAgo(2),
        notes: 'Original notes',
      );

      await repository.addSquirrel(squirrel);

      final updated = squirrel.copyWith(notes: 'Updated notes');
      await repository.updateSquirrel(updated);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.notes, equals('Updated notes'));
    });
  });

  group('SquirrelRepository - Delete', () {
    test('should delete squirrel successfully', () async {
      final squirrel = Squirrel.create(
        name: 'ToDelete',
        foundDate: daysAgo(2),
      );

      await repository.addSquirrel(squirrel);
      expect(await repository.getSquirrel(squirrel.id), isNotNull);

      await repository.deleteSquirrel(squirrel.id);

      final retrieved = await repository.getSquirrel(squirrel.id);
      expect(retrieved, isNull);
    });

    test(
      'should throw exception when deleting non-existent squirrel',
      () async {
        expect(
          () => repository.deleteSquirrel('non-existent-id'),
          throwsA(isA<SquirrelRepositoryException>()),
        );
      },
    );

    test('should handle multiple deletes correctly', () async {
      final squirrels = [
        Squirrel.create(name: 'Squirrel1', foundDate: daysAgo(2)),
        Squirrel.create(name: 'Squirrel2', foundDate: daysAgo(1)),
        Squirrel.create(name: 'Squirrel3', foundDate: today),
      ];

      for (final squirrel in squirrels) {
        await repository.addSquirrel(squirrel);
      }

      await repository.deleteSquirrel(squirrels[1].id);

      expect(await repository.getSquirrel(squirrels[0].id), isNotNull);
      expect(await repository.getSquirrel(squirrels[1].id), isNull);
      expect(await repository.getSquirrel(squirrels[2].id), isNotNull);
    });
  });

  group('SquirrelRepository - Query Operations', () {
    test('should get all squirrels', () async {
      final squirrels = [
        Squirrel.create(name: 'Squirrel1', foundDate: daysAgo(2)),
        Squirrel.create(name: 'Squirrel2', foundDate: daysAgo(1)),
        Squirrel.create(name: 'Squirrel3', foundDate: today),
      ];

      for (final squirrel in squirrels) {
        await repository.addSquirrel(squirrel);
      }

      final all = await repository.getAllSquirrels();

      expect(all, hasLength(3));
      expect(
        all.map((s) => s.name).toList(),
        containsAll(['Squirrel1', 'Squirrel2', 'Squirrel3']),
      );
    });

    test('should get only active squirrels', () async {
      final active1 = Squirrel.create(
        name: 'Active1',
        foundDate: daysAgo(2),
      );

      final active2 = Squirrel.create(
        name: 'Active2',
        foundDate: daysAgo(1),
      );

      final released = Squirrel.create(
        name: 'Released',
        foundDate: today,
      );

      await repository.addSquirrel(active1);
      await repository.addSquirrel(active2);
      await repository.addSquirrel(released);

      // Update one to released status
      await repository.updateSquirrel(
        released.copyWith(status: SquirrelStatus.released),
      );

      final activeSquirrels = await repository.getActiveSquirrels();

      expect(activeSquirrels, hasLength(2));
      expect(
        activeSquirrels.every((s) => s.status == SquirrelStatus.active),
        isTrue,
      );
      expect(
        activeSquirrels.map((s) => s.name).toList(),
        containsAll(['Active1', 'Active2']),
      );
    });

    test('should get squirrels by status', () async {
      final active = Squirrel.create(
        name: 'Active',
        foundDate: daysAgo(2),
      );
      final released = Squirrel.create(
        name: 'Released',
        foundDate: daysAgo(1),
      );
      final deceased = Squirrel.create(
        name: 'Deceased',
        foundDate: today,
      );

      await repository.addSquirrel(active);
      await repository.addSquirrel(released);
      await repository.addSquirrel(deceased);

      await repository.updateSquirrel(
        released.copyWith(status: SquirrelStatus.released),
      );
      await repository.updateSquirrel(
        deceased.copyWith(status: SquirrelStatus.deceased),
      );

      final releasedList = await repository.getSquirrelsByStatus(
        SquirrelStatus.released,
      );
      final deceasedList = await repository.getSquirrelsByStatus(
        SquirrelStatus.deceased,
      );

      expect(releasedList, hasLength(1));
      expect(releasedList[0].name, equals('Released'));
      expect(deceasedList, hasLength(1));
      expect(deceasedList[0].name, equals('Deceased'));
    });

    test('should get correct squirrel count', () async {
      expect(await repository.getSquirrelCount(), equals(0));

      for (int i = 0; i < 5; i++) {
        await repository.addSquirrel(
          Squirrel.create(
            name: 'Squirrel$i',
            foundDate: daysAgo(2 - i),
          ),
        );
      }

      expect(await repository.getSquirrelCount(), equals(5));

      final squirrels = await repository.getAllSquirrels();
      await repository.deleteSquirrel(squirrels[0].id);

      expect(await repository.getSquirrelCount(), equals(4));
    });

    test('should return empty list when no squirrels exist', () async {
      final all = await repository.getAllSquirrels();
      final active = await repository.getActiveSquirrels();

      expect(all, isEmpty);
      expect(active, isEmpty);
    });
  });

  group('SquirrelRepository - Weight Updates', () {
    test('should update squirrel weight correctly', () async {
      final squirrel = Squirrel.create(
        name: 'Growing',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      await repository.addSquirrel(squirrel);

      await repository.updateSquirrelWeight(squirrel.id, 65.0);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.currentWeight, equals(65.0));
    });

    test('should handle multiple weight updates', () async {
      final squirrel = Squirrel.create(
        name: 'Growing',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      await repository.addSquirrel(squirrel);

      await repository.updateSquirrelWeight(squirrel.id, 55.0);
      await repository.updateSquirrelWeight(squirrel.id, 60.0);
      await repository.updateSquirrelWeight(squirrel.id, 65.0);

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.currentWeight, equals(65.0));
    });
  });

  group('SquirrelRepository - Squirrels Needing Attention', () {
    test('should identify squirrels without weight', () async {
      final withWeight = Squirrel.create(
        name: 'WithWeight',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      final withoutWeight = Squirrel.create(
        name: 'WithoutWeight',
        foundDate: daysAgo(1),
      );

      await repository.addSquirrel(withWeight);
      await repository.addSquirrel(withoutWeight);

      final needingAttention = await repository.getSquirrelsNeedingAttention();

      expect(needingAttention, hasLength(1));
      expect(needingAttention[0].name, equals('WithoutWeight'));
    });

    test('should only include active squirrels needing attention', () async {
      final activeNoWeight = Squirrel.create(
        name: 'ActiveNoWeight',
        foundDate: daysAgo(2),
      );

      final releasedNoWeight = Squirrel.create(
        name: 'ReleasedNoWeight',
        foundDate: daysAgo(1),
      );

      await repository.addSquirrel(activeNoWeight);
      await repository.addSquirrel(releasedNoWeight);

      await repository.updateSquirrel(
        releasedNoWeight.copyWith(status: SquirrelStatus.released),
      );

      final needingAttention = await repository.getSquirrelsNeedingAttention();

      expect(needingAttention, hasLength(1));
      expect(needingAttention[0].name, equals('ActiveNoWeight'));
    });
  });

  group('SquirrelRepository - Complex Scenarios', () {
    test('should handle rapid consecutive operations', () async {
      final squirrel = Squirrel.create(
        name: 'RapidTest',
        foundDate: daysAgo(2),
      );

      await repository.addSquirrel(squirrel);
      await repository.updateSquirrel(squirrel.copyWith(currentWeight: 50.0));
      await repository.updateSquirrel(squirrel.copyWith(currentWeight: 55.0));

      final retrieved = await repository.getSquirrel(squirrel.id);

      expect(retrieved!.currentWeight, equals(55.0));
    });

    test('should maintain data integrity across multiple operations', () async {
      // Add multiple squirrels
      final squirrels = List.generate(
        10,
        (i) => Squirrel.create(
          name: 'Squirrel$i',
          foundDate: daysAgo(2 - i),
          admissionWeight: 50.0 + i,
        ),
      );

      for (final squirrel in squirrels) {
        await repository.addSquirrel(squirrel);
      }

      // Update some
      for (int i = 0; i < 5; i++) {
        final updated = squirrels[i].copyWith(currentWeight: 60.0 + i);
        await repository.updateSquirrel(updated);
      }

      // Delete some
      await repository.deleteSquirrel(squirrels[5].id);
      await repository.deleteSquirrel(squirrels[6].id);

      // Verify remaining
      final remaining = await repository.getAllSquirrels();

      expect(remaining, hasLength(8));

      // Verify updated weights
      for (int i = 0; i < 5; i++) {
        final retrieved = await repository.getSquirrel(squirrels[i].id);
        expect(retrieved!.currentWeight, equals(60.0 + i));
      }
    });
  });
}
