import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/models/squirrel.dart';
import '../../helpers/test_date_utils.dart';

void main() {
  group('DevelopmentStage', () {
    test('should return correct feeding frequency hours for newborn', () {
      expect(DevelopmentStage.newborn.feedingFrequencyHours, equals(2));
    });

    test('should return correct feeding frequency hours for infant', () {
      expect(DevelopmentStage.infant.feedingFrequencyHours, equals(2));
    });

    test('should return correct feeding frequency hours for juvenile', () {
      expect(DevelopmentStage.juvenile.feedingFrequencyHours, equals(3));
    });

    test('should return correct feeding frequency hours for adolescent', () {
      expect(DevelopmentStage.adolescent.feedingFrequencyHours, equals(4));
    });

    test('should return correct feeding frequency hours for adult', () {
      expect(DevelopmentStage.adult.feedingFrequencyHours, equals(8));
    });

    test('should parse valid development stage from string', () {
      expect(
        DevelopmentStage.fromString('newborn'),
        equals(DevelopmentStage.newborn),
      );
      expect(
        DevelopmentStage.fromString('infant'),
        equals(DevelopmentStage.infant),
      );
      expect(
        DevelopmentStage.fromString('juvenile'),
        equals(DevelopmentStage.juvenile),
      );
      expect(
        DevelopmentStage.fromString('adolescent'),
        equals(DevelopmentStage.adolescent),
      );
      expect(
        DevelopmentStage.fromString('adult'),
        equals(DevelopmentStage.adult),
      );
    });

    test('should default to newborn for invalid stage string', () {
      expect(
        DevelopmentStage.fromString('invalid'),
        equals(DevelopmentStage.newborn),
      );
      expect(DevelopmentStage.fromString(''), equals(DevelopmentStage.newborn));
    });

    test('should convert to string correctly', () {
      expect(DevelopmentStage.newborn.toString(), equals('newborn'));
      expect(DevelopmentStage.infant.toString(), equals('infant'));
      expect(DevelopmentStage.juvenile.toString(), equals('juvenile'));
      expect(DevelopmentStage.adolescent.toString(), equals('adolescent'));
      expect(DevelopmentStage.adult.toString(), equals('adult'));
    });
  });

  group('SquirrelStatus', () {
    test('should parse valid status from string', () {
      expect(
        SquirrelStatus.fromString('active'),
        equals(SquirrelStatus.active),
      );
      expect(
        SquirrelStatus.fromString('released'),
        equals(SquirrelStatus.released),
      );
      expect(
        SquirrelStatus.fromString('deceased'),
        equals(SquirrelStatus.deceased),
      );
      expect(
        SquirrelStatus.fromString('transferred'),
        equals(SquirrelStatus.transferred),
      );
    });

    test('should default to active for invalid status string', () {
      expect(
        SquirrelStatus.fromString('invalid'),
        equals(SquirrelStatus.active),
      );
      expect(SquirrelStatus.fromString(''), equals(SquirrelStatus.active));
    });

    test('should convert to string correctly', () {
      expect(SquirrelStatus.active.toString(), equals('active'));
      expect(SquirrelStatus.released.toString(), equals('released'));
      expect(SquirrelStatus.deceased.toString(), equals('deceased'));
      expect(SquirrelStatus.transferred.toString(), equals('transferred'));
    });
  });

  group('Squirrel - Age Calculations', () {
    test(
      'should calculate estimated birth date for newborn found 5 days ago',
      () {
        final foundDate = daysFromNow(7);
        final squirrel = Squirrel(
          id: 'test-1',
          name: 'Testy',
          foundDate: foundDate,
          developmentStage: DevelopmentStage.newborn, // 0-2 weeks, avg 1 week
        );

        // Newborn stage is 0-2 weeks, midpoint is 1 week = 7 days
        // If found on Jan 10 and was ~7 days old, birth was ~Jan 3
        final expectedBirthDate = foundDate.subtract(const Duration(days: 7));
        expect(squirrel.estimatedBirthDate.day, equals(expectedBirthDate.day));
      },
    );

    test('should calculate estimated birth date for infant', () {
      final foundDate = daysFromNow(17);
      final squirrel = Squirrel(
        id: 'test-2',
        name: 'Testy',
        foundDate: foundDate,
        developmentStage: DevelopmentStage.infant, // 2-5 weeks, avg 3.5 weeks
      );

      // Infant stage is 2-5 weeks, midpoint is 3.5 weeks = 24.5 days
      final expectedDaysOld = (24.5).round();
      final expectedBirthDate = foundDate.subtract(
        Duration(days: expectedDaysOld),
      );
      expect(squirrel.estimatedBirthDate.day, equals(expectedBirthDate.day));
    });

    test('should calculate current development stage based on actual age', () {
      // Create squirrel that was found 30 days ago as newborn
      final foundDate = DateTime.now().subtract(const Duration(days: 30));
      final squirrel = Squirrel(
        id: 'test-3',
        name: 'Testy',
        foundDate: foundDate,
        developmentStage: DevelopmentStage.newborn,
      );

      // Found 30 days ago as newborn (1 week old)
      // Now should be ~37 days old = ~5.3 weeks
      // Should be in juvenile stage (5-8 weeks)
      expect(
        squirrel.currentDevelopmentStage,
        equals(DevelopmentStage.juvenile),
      );
    });

    test('should calculate days since found correctly', () {
      final foundDate = DateTime.now().subtract(const Duration(days: 10));
      final squirrel = Squirrel(
        id: 'test-4',
        name: 'Testy',
        foundDate: foundDate,
        developmentStage: DevelopmentStage.newborn,
      );

      // Allow for small timing differences in test execution
      expect(squirrel.daysSinceFound, greaterThanOrEqualTo(9));
      expect(squirrel.daysSinceFound, lessThanOrEqualTo(10));
    });

    test('should calculate weeks since found correctly', () {
      final foundDate = DateTime.now().subtract(const Duration(days: 14));
      final squirrel = Squirrel(
        id: 'test-5',
        name: 'Testy',
        foundDate: foundDate,
        developmentStage: DevelopmentStage.newborn,
      );

      // Allow for small timing differences in test execution
      expect(squirrel.weeksSinceFound, greaterThanOrEqualTo(1.8));
      expect(squirrel.weeksSinceFound, lessThanOrEqualTo(2.0));
    });
  });

  group('Squirrel - Weight Calculations', () {
    test('should calculate weight gain when both weights are present', () {
      final squirrel = Squirrel(
        id: 'test-6',
        name: 'Testy',
        foundDate: DateTime.now(),
        admissionWeight: 50.0,
        currentWeight: 75.0,
      );

      expect(squirrel.weightGain, equals(25.0));
    });

    test('should return null weight gain when admission weight is missing', () {
      final squirrel = Squirrel(
        id: 'test-7',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 75.0,
      );

      expect(squirrel.weightGain, isNull);
    });

    test('should return null weight gain when current weight is missing', () {
      final squirrel = Squirrel(
        id: 'test-8',
        name: 'Testy',
        foundDate: DateTime.now(),
        admissionWeight: 50.0,
      );

      expect(squirrel.weightGain, isNull);
    });

    test('should handle negative weight gain', () {
      final squirrel = Squirrel(
        id: 'test-9',
        name: 'Testy',
        foundDate: DateTime.now(),
        admissionWeight: 75.0,
        currentWeight: 50.0,
      );

      expect(squirrel.weightGain, equals(-25.0));
    });
  });

  group('Squirrel - Feeding Calculations', () {
    test('should calculate recommended feeding amount for newborn', () {
      final squirrel = Squirrel(
        id: 'test-10',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 100.0,
        developmentStage: DevelopmentStage.newborn,
      );

      // Newborn: 6% of body weight
      expect(squirrel.recommendedFeedingAmount, equals(6.0));
    });

    test('should calculate recommended feeding amount for infant', () {
      final squirrel = Squirrel(
        id: 'test-11',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 100.0,
        developmentStage: DevelopmentStage.infant,
      );

      // Infant: 6% of body weight
      expect(squirrel.recommendedFeedingAmount, equals(6.0));
    });

    test('should calculate recommended feeding amount for juvenile', () {
      final squirrel = Squirrel(
        id: 'test-12',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 100.0,
        developmentStage: DevelopmentStage.juvenile,
      );

      // Juvenile: 5% of body weight
      expect(squirrel.recommendedFeedingAmount, equals(5.0));
    });

    test('should calculate recommended feeding amount for adolescent', () {
      final squirrel = Squirrel(
        id: 'test-13',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 100.0,
        developmentStage: DevelopmentStage.adolescent,
      );

      // Adolescent: 3% of body weight
      expect(squirrel.recommendedFeedingAmount, equals(3.0));
    });

    test('should return 0 feeding amount for adult', () {
      final squirrel = Squirrel(
        id: 'test-14',
        name: 'Testy',
        foundDate: DateTime.now(),
        currentWeight: 100.0,
        developmentStage: DevelopmentStage.adult,
      );

      // Adult: should be on solid food only
      expect(squirrel.recommendedFeedingAmount, equals(0));
    });

    test(
      'should return null recommended feeding amount when no current weight',
      () {
        final squirrel = Squirrel(
          id: 'test-15',
          name: 'Testy',
          foundDate: DateTime.now(),
          developmentStage: DevelopmentStage.newborn,
        );

        expect(squirrel.recommendedFeedingAmount, isNull);
      },
    );
  });

  group('Squirrel - Factory and Serialization', () {
    test('should create squirrel with UUID using factory', () {
      final squirrel = Squirrel.create(
        name: 'Factory Test',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
      );

      expect(squirrel.id, isNotEmpty);
      expect(squirrel.name, equals('Factory Test'));
      expect(squirrel.admissionWeight, equals(50.0));
      expect(
        squirrel.currentWeight,
        equals(50.0),
      ); // Should initialize to admission weight
      expect(
        squirrel.developmentStage,
        equals(DevelopmentStage.newborn),
      ); // Default
    });

    test('should create squirrel with specified development stage', () {
      final squirrel = Squirrel.create(
        name: 'Stage Test',
        foundDate: daysAgo(2),
        developmentStage: DevelopmentStage.juvenile,
      );

      expect(squirrel.developmentStage, equals(DevelopmentStage.juvenile));
    });

    test('should serialize to JSON correctly', () {
      final squirrel = Squirrel(
        id: 'json-test-id',
        name: 'JSON Test',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
        currentWeight: 75.0,
        status: SquirrelStatus.active,
        developmentStage: DevelopmentStage.infant,
        notes: 'Test notes',
        photoPath: '/path/to/photo.jpg',
        createdAt: dateWithTime(-2, 10, 0),
        updatedAt: dateWithTime(-2, 11, 0),
      );

      final json = squirrel.toJson();

      expect(json['id'], equals('json-test-id'));
      expect(json['name'], equals('JSON Test'));
      // Check date is serialized correctly (check format, not exact value)
      expect(json['found_date'], equals(squirrel.foundDate.toIso8601String()));
      expect(json['admission_weight'], equals(50.0));
      expect(json['current_weight'], equals(75.0));
      expect(json['status'], equals('active'));
      expect(json['development_stage'], equals('infant'));
      expect(json['notes'], equals('Test notes'));
      expect(json['photo_path'], equals('/path/to/photo.jpg'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'json-test-id',
        'name': 'JSON Test',
        'found_date': '2025-01-01T00:00:00.000',
        'admission_weight': 50.0,
        'current_weight': 75.0,
        'status': 'active',
        'development_stage': 'infant',
        'notes': 'Test notes',
        'photo_path': '/path/to/photo.jpg',
        'created_at': '2025-01-01T10:00:00.000',
        'updated_at': '2025-01-01T11:00:00.000',
      };

      final squirrel = Squirrel.fromJson(json);

      expect(squirrel.id, equals('json-test-id'));
      expect(squirrel.name, equals('JSON Test'));
      // Deserialize date correctly from the JSON
      expect(squirrel.foundDate, equals(DateTime.parse('2025-01-01T00:00:00.000')));
      expect(squirrel.admissionWeight, equals(50.0));
      expect(squirrel.currentWeight, equals(75.0));
      expect(squirrel.status, equals(SquirrelStatus.active));
      expect(squirrel.developmentStage, equals(DevelopmentStage.infant));
      expect(squirrel.notes, equals('Test notes'));
      expect(squirrel.photoPath, equals('/path/to/photo.jpg'));
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'minimal-test',
        'name': 'Minimal',
        'found_date': '2025-01-01T00:00:00.000',
      };

      final squirrel = Squirrel.fromJson(json);

      expect(squirrel.id, equals('minimal-test'));
      expect(squirrel.name, equals('Minimal'));
      expect(squirrel.admissionWeight, isNull);
      expect(squirrel.currentWeight, isNull);
      expect(squirrel.notes, isNull);
      expect(squirrel.photoPath, isNull);
      expect(squirrel.status, equals(SquirrelStatus.active)); // Default
      expect(
        squirrel.developmentStage,
        equals(DevelopmentStage.newborn),
      ); // Default
    });
  });

  group('Squirrel - copyWith', () {
    test('should create copy with updated name', () {
      final original = Squirrel(
        id: 'copy-test',
        name: 'Original Name',
        foundDate: daysAgo(2),
      );

      final copy = original.copyWith(name: 'New Name');

      expect(copy.id, equals(original.id));
      expect(copy.name, equals('New Name'));
      expect(copy.foundDate, equals(original.foundDate));
    });

    test('should create copy with updated weight', () {
      final original = Squirrel(
        id: 'copy-test',
        name: 'Test',
        foundDate: daysAgo(2),
        currentWeight: 50.0,
      );

      final copy = original.copyWith(currentWeight: 75.0);

      expect(copy.currentWeight, equals(75.0));
      expect(copy.name, equals(original.name));
    });

    test('should create copy with updated status', () {
      final original = Squirrel(
        id: 'copy-test',
        name: 'Test',
        foundDate: daysAgo(2),
        status: SquirrelStatus.active,
      );

      final copy = original.copyWith(status: SquirrelStatus.released);

      expect(copy.status, equals(SquirrelStatus.released));
    });

    test('should preserve original values when not specified', () {
      final original = Squirrel(
        id: 'copy-test',
        name: 'Original',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
        currentWeight: 75.0,
        developmentStage: DevelopmentStage.infant,
        notes: 'Original notes',
      );

      final copy = original.copyWith(name: 'New Name');

      expect(copy.name, equals('New Name'));
      expect(copy.admissionWeight, equals(original.admissionWeight));
      expect(copy.currentWeight, equals(original.currentWeight));
      expect(copy.developmentStage, equals(original.developmentStage));
      expect(copy.notes, equals(original.notes));
    });
  });

  group('Squirrel - Equality', () {
    test('should be equal when IDs match', () {
      final squirrel1 = Squirrel(
        id: 'same-id',
        name: 'Name 1',
        foundDate: daysAgo(2),
      );

      final squirrel2 = Squirrel(
        id: 'same-id',
        name: 'Name 2',
        foundDate: daysAgo(1),
      );

      expect(squirrel1, equals(squirrel2));
      expect(squirrel1.hashCode, equals(squirrel2.hashCode));
    });

    test('should not be equal when IDs differ', () {
      final squirrel1 = Squirrel(
        id: 'id-1',
        name: 'Same Name',
        foundDate: daysAgo(2),
      );

      final squirrel2 = Squirrel(
        id: 'id-2',
        name: 'Same Name',
        foundDate: daysAgo(2),
      );

      expect(squirrel1, isNot(equals(squirrel2)));
      expect(squirrel1.hashCode, isNot(equals(squirrel2.hashCode)));
    });
  });
}
