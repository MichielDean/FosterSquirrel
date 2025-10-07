import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/providers/data_providers.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/care_note_repository.dart';
import 'package:foster_squirrel/repositories/drift/weight_repository.dart';
import 'package:foster_squirrel/views/squirrel_detail/squirrel_detail_view.dart';
import 'package:foster_squirrel/widgets/forms/feeding_record_form.dart';
import 'package:provider/provider.dart';

import '../../integration/test_database_helper.dart';
import '../../helpers/test_date_utils.dart';

/// System tests for FeedingRecordForm
///
/// CRITICAL: These tests validate provider accessibility through navigation.
/// The provider architecture bug was not caught because we had NO tests that
/// navigated to forms and attempted to save data using providers.
///
/// These tests:
/// 1. Build full app structure with providers (like main.dart)
/// 2. Navigate to SquirrelDetailView, then to FeedingRecordForm
/// 3. Verify FeedingRepository is accessible in navigated context
/// 4. Test form submission and navigation back
/// 5. Validate data persistence
void main() {
  late AppDatabase db;

  setUp(() async {
    db = TestDatabaseHelper.createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to build app with REAL provider structure (mimics main.dart)
  Widget buildAppWithProviders({required Widget home}) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ProxyProvider<AppDatabase, SquirrelRepository>(
          update: (_, db, previous) => SquirrelRepository(db),
        ),
        ProxyProvider<AppDatabase, FeedingRepository>(
          update: (_, db, previous) => FeedingRepository(db),
        ),
        ProxyProvider<AppDatabase, CareNoteRepository>(
          update: (_, db, previous) => CareNoteRepository(db),
        ),
        ProxyProvider<AppDatabase, WeightRepository>(
          update: (_, db, previous) => WeightRepository(db),
        ),
        ChangeNotifierProxyProvider<SquirrelRepository, SquirrelListProvider>(
          create: (context) => SquirrelListProvider(
            Provider.of<SquirrelRepository>(context, listen: false),
          ),
          update: (_, repository, previous) =>
              previous ?? SquirrelListProvider(repository),
        ),
      ],
      child: MaterialApp(home: home),
    );
  }

  group('FeedingRecordForm - Navigation and Provider Access', () {
    testWidgets(
      'should navigate to form and access FeedingRepository without errors',
      (tester) async {
        // Set larger viewport to accommodate full form
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Arrange - Create test squirrel
        final squirrelRepo = SquirrelRepository(db);
        final squirrel = Squirrel.create(
          name: 'TestSquirrel',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
          developmentStage: DevelopmentStage.newborn,
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Build app with SquirrelDetailView as home
        await tester.pumpWidget(
          buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
        );
        await tester.pumpAndSettle();

        // Act - Navigate to FeedingRecordForm (like user does via FAB)
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Assert - Form should render without provider errors
        expect(find.byType(FeedingRecordForm), findsOneWidget);
        expect(find.text('Add Feeding Record'), findsOneWidget);
      },
    );

    testWidgets(
      'should submit form and save feeding record using FeedingRepository',
      (tester) async {
        // Arrange
        final squirrelRepo = SquirrelRepository(db);
        final feedingRepo = FeedingRepository(db);
        final squirrel = Squirrel.create(
          name: 'Nutkin',
          foundDate: daysAgo(2),
          admissionWeight: 48.0,
          developmentStage: DevelopmentStage.newborn,
        );
        await squirrelRepo.addSquirrel(squirrel);

        await tester.pumpWidget(
          buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
        );
        await tester.pumpAndSettle();

        // Navigate to form
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Act - Fill form
        await tester.enterText(
          find.byKey(const Key('starting_weight_field')),
          '48.0',
        );
        await tester.enterText(
          find.byKey(const Key('ending_weight_field')),
          '49.0',
        );
        await tester.enterText(
          find.byKey(const Key('actual_feed_amount_field')),
          '2.0',
        );

        // Save (this requires FeedingRepository to be accessible)
        await tester.tap(find.text('SAVE'));
        await tester.pumpAndSettle();

        // Assert - Should navigate back to detail view
        expect(find.byType(FeedingRecordForm), findsNothing);
        expect(find.byType(SquirrelDetailView), findsOneWidget);

        // Verify feeding record was saved
        final records = await feedingRepo.getFeedingRecords(squirrel.id);
        expect(records, hasLength(1));
        expect(records.first.startingWeightGrams, 48.0);
        expect(records.first.endingWeightGrams, 49.0);
        expect(records.first.actualFeedAmountML, 2.0);
      },
    );

    testWidgets('should cancel form without saving data', (tester) async {
      // Set larger viewport to accommodate full form
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final feedingRepo = FeedingRepository(db);
      final squirrel = Squirrel.create(
        name: 'Rocky',
        foundDate: daysAgo(2),
        admissionWeight: 50.0,
        developmentStage: DevelopmentStage.infant,
      );
      await squirrelRepo.addSquirrel(squirrel);

      await tester.pumpWidget(
        buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
      );
      await tester.pumpAndSettle();

      // Navigate to form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Act - Fill form
      await tester.enterText(
        find.byKey(const Key('starting_weight_field')),
        '50.0',
      );

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - Should navigate back without saving
      expect(find.byType(FeedingRecordForm), findsNothing);
      expect(find.byType(SquirrelDetailView), findsOneWidget);

      // Verify no feeding record was saved
      final records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records, isEmpty);
    });
  });

  group('FeedingRecordForm - Form Validation', () {
    testWidgets('should show validation error when starting weight is empty', (
      tester,
    ) async {
      // Set larger viewport to accommodate full form
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final squirrel = Squirrel.create(
        name: 'Hazel',
        foundDate: daysAgo(2),
        admissionWeight: 45.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      await tester.pumpWidget(
        buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Act - Try to save without filling required field
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      // Assert - Should show validation error and stay on form
      expect(find.text('Pre-feeding weight is required'), findsOneWidget);
      expect(find.byType(FeedingRecordForm), findsOneWidget);
    });

    testWidgets(
      'should show validation error when ending weight is less than starting',
      (tester) async {
        // Set larger viewport to accommodate full form
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Arrange
        final squirrelRepo = SquirrelRepository(db);
        final squirrel = Squirrel.create(
          name: 'Chippy',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
          developmentStage: DevelopmentStage.newborn,
        );
        await squirrelRepo.addSquirrel(squirrel);

        await tester.pumpWidget(
          buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Act - Enter ending weight significantly less than starting (< 80%)
        await tester.enterText(
          find.byKey(const Key('starting_weight_field')),
          '50.0',
        );
        await tester.enterText(
          find.byKey(const Key('ending_weight_field')),
          '35.0', // 35 < 50 * 0.8 (40), triggers validation
        );
        await tester.tap(find.text('SAVE'));
        await tester.pump();

        // Assert - Should show validation error
        expect(
          find.text('Ending weight seems too low compared to starting weight'),
          findsOneWidget,
        );
        expect(find.byType(FeedingRecordForm), findsOneWidget);
      },
    );
  });

  group('FeedingRecordForm - Edit Mode', () {
    testWidgets('should populate form with existing record data', (
      tester,
    ) async {
      // Arrange - Create squirrel and feeding record
      final squirrelRepo = SquirrelRepository(db);
      final feedingRepo = FeedingRepository(db);

      final squirrel = Squirrel.create(
        name: 'Tails',
        foundDate: daysAgo(2),
        admissionWeight: 45.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      final existingRecord = FeedingRecord(
        id: 'existing-1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-1, 9, 0),
        startingWeightGrams: 45.0,
        endingWeightGrams: 46.0,
        actualFeedAmountML: 2.5,
        foodType: 'Formula',
        notes: 'Test notes',
      );
      await feedingRepo.addFeedingRecord(existingRecord);

      // Build form in edit mode
      await tester.pumpWidget(
        buildAppWithProviders(
          home: FeedingRecordForm(
            squirrel: squirrel,
            existingRecord: existingRecord,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Form should be populated
      expect(find.text('Edit Feeding Record'), findsOneWidget);
      expect(find.text('45.0'), findsOneWidget);
      expect(find.text('46.0'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should update existing record when saved', (tester) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final feedingRepo = FeedingRepository(db);

      final squirrel = Squirrel.create(
        name: 'Sonic',
        foundDate: daysAgo(2),
        admissionWeight: 48.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      final existingRecord = FeedingRecord(
        id: 'existing-2',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: dateWithTime(-1, 9, 0),
        startingWeightGrams: 48.0,
        endingWeightGrams: 49.0,
        actualFeedAmountML: 2.0,
      );
      await feedingRepo.addFeedingRecord(existingRecord);

      await tester.pumpWidget(
        buildAppWithProviders(
          home: FeedingRecordForm(
            squirrel: squirrel,
            existingRecord: existingRecord,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Update ending weight
      await tester.enterText(
        find.byKey(const Key('ending_weight_field')),
        '50.0',
      );
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Assert - Record should be updated
      final records = await feedingRepo.getFeedingRecords(squirrel.id);
      expect(records, hasLength(1));
      expect(records.first.id, existingRecord.id);
      expect(records.first.endingWeightGrams, 50.0);
    });
  });

  group('FeedingRecordForm - REGRESSION TESTS', () {
    testWidgets(
      'REGRESSION: Provider accessible in form after navigation (provider architecture bug)',
      (tester) async {
        // This test specifically guards against the provider architecture bug
        // where FeedingRepository was not accessible in navigated routes.

        final squirrelRepo = SquirrelRepository(db);
        final squirrel = Squirrel.create(
          name: 'BugTest',
          foundDate: daysAgo(2),
          admissionWeight: 50.0,
          developmentStage: DevelopmentStage.newborn,
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Start from detail view
        await tester.pumpWidget(
          buildAppWithProviders(home: SquirrelDetailView(squirrel: squirrel)),
        );
        await tester.pumpAndSettle();

        // Navigate to form (this is where provider access was broken)
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // If we get here without errors, the form rendered successfully
        expect(find.byType(FeedingRecordForm), findsOneWidget);

        // Now try to save (this accesses FeedingRepository)
        await tester.enterText(
          find.byKey(const Key('starting_weight_field')),
          '50.0',
        );
        await tester.tap(find.text('SAVE'));
        await tester.pumpAndSettle();

        // If this completes without provider errors, the bug is fixed
        expect(find.byType(FeedingRecordForm), findsNothing);
      },
    );
  });
}
