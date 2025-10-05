import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/models/models.dart';
import 'package:foster_squirrel/providers/data_providers.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/care_note_repository.dart';
import 'package:foster_squirrel/repositories/drift/weight_repository.dart';
import 'package:foster_squirrel/views/home/home_view.dart';
import 'package:foster_squirrel/views/squirrel_detail/squirrel_detail_view.dart';
import 'package:foster_squirrel/widgets/charts/weight_progress_chart.dart';
import 'package:provider/provider.dart';

import '../../integration/test_database_helper.dart';

/// System tests for SquirrelDetailView
///
/// CRITICAL: These tests validate provider accessibility through navigation.
/// The provider architecture bug (MultiProvider below MaterialApp) was not caught
/// because we had NO tests that actually navigated to SquirrelDetailView.
///
/// These tests:
/// 1. Build full app structure with providers (like main.dart)
/// 2. Navigate from HomeView to SquirrelDetailView (like real users)
/// 3. Verify providers are accessible in navigated context
/// 4. Test tab navigation and widget rendering
void main() {
  late AppDatabase db;

  setUp(() async {
    db = TestDatabaseHelper.createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to build app with REAL provider structure (mimics main.dart)
  /// This is CRITICAL - we must test with actual provider setup, not mocked
  Widget buildAppWithProviders() {
    return MultiProvider(
      providers: [
        // Provide AppDatabase instance
        Provider<AppDatabase>.value(value: db),

        // Create Drift-based repositories (exactly like main.dart)
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

        // Add the optimized list provider
        ChangeNotifierProxyProvider<SquirrelRepository, SquirrelListProvider>(
          create: (context) => SquirrelListProvider(
            Provider.of<SquirrelRepository>(context, listen: false),
          ),
          update: (_, repository, previous) =>
              previous ?? SquirrelListProvider(repository),
        ),
      ],
      child: const MaterialApp(home: HomeView()),
    );
  }

  group('SquirrelDetailView - Navigation and Provider Access', () {
    testWidgets('should navigate to detail view and access FeedingRepository', (
      tester,
    ) async {
      // Arrange - Create test squirrel
      final squirrelRepo = SquirrelRepository(db);
      final squirrel = Squirrel.create(
        name: 'Nutkin',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 50.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Build full app with providers
      await tester.pumpWidget(buildAppWithProviders());

      // Wait for initial load
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Act - Navigate to detail view (like real user does)
      await tester.tap(find.text('Nutkin'));
      await tester.pumpAndSettle();

      // Assert - Should successfully navigate without provider errors
      expect(find.byType(SquirrelDetailView), findsOneWidget);
      expect(find.text('Nutkin'), findsWidgets); // Name appears in app bar

      // Detail view should load feeding records (requires FeedingRepository)
      // If providers aren't accessible, this would throw an error
      // The view itself being rendered proves provider access worked
    });

    testWidgets('should display weight progress chart in Progress tab', (
      tester,
    ) async {
      // Arrange - Create squirrel with feeding data (for weight chart)
      final squirrelRepo = SquirrelRepository(db);
      final feedingRepo = FeedingRepository(db);

      final squirrel = Squirrel.create(
        name: 'Hazel',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 45.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Add feeding records for weight data
      final feeding = FeedingRecord(
        id: '1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: DateTime(2025, 1, 2),
        startingWeightGrams: 45.0,
        endingWeightGrams: 46.0,
        actualFeedAmountML: 2.0,
      );
      await feedingRepo.addFeedingRecord(feeding);

      // Build full app
      await tester.pumpWidget(buildAppWithProviders());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Navigate to detail view
      await tester.tap(find.text('Hazel'));
      await tester.pumpAndSettle();

      // Act - Navigate to Progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Assert - WeightProgressChart should render
      // THIS IS THE CRITICAL TEST - WeightProgressChart requires WeightRepository
      // If providers aren't accessible in navigated routes, this fails
      expect(find.byType(WeightProgressChart), findsOneWidget);
      expect(find.text('Weight Progress'), findsOneWidget);
    });

    testWidgets('should display feeding records in Feedings tab', (
      tester,
    ) async {
      // Arrange - Create squirrel with feeding records
      final squirrelRepo = SquirrelRepository(db);
      final feedingRepo = FeedingRepository(db);

      final squirrel = Squirrel.create(
        name: 'Rocky',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 50.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      final feeding = FeedingRecord(
        id: '1',
        squirrelId: squirrel.id,
        squirrelName: squirrel.name,
        feedingTime: DateTime(2025, 1, 2, 9, 0),
        startingWeightGrams: 50.0,
        endingWeightGrams: 51.0,
        actualFeedAmountML: 2.5,
      );
      await feedingRepo.addFeedingRecord(feeding);

      // Build full app
      await tester.pumpWidget(buildAppWithProviders());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Navigate to detail view
      await tester.tap(find.text('Rocky'));
      await tester.pumpAndSettle();

      // Act - Navigate to Feeding tab
      await tester.tap(find.text('Feeding'));
      await tester.pumpAndSettle();

      // Assert - Feeding records should display
      // SquirrelDetailView loads feedings using FeedingRepository
      expect(find.text('2.5 mL'), findsOneWidget);
      expect(find.text('50.0g → 51.0g'), findsOneWidget);
    });

    testWidgets('should display info tab with squirrel details', (
      tester,
    ) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final squirrel = Squirrel.create(
        name: 'Chippy',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 55.0,
        developmentStage: DevelopmentStage.infant,
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Build full app
      await tester.pumpWidget(buildAppWithProviders());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Navigate to detail view
      await tester.tap(find.text('Chippy'));
      await tester.pumpAndSettle();

      // Info tab should be selected by default
      // Assert - Squirrel details should display
      expect(find.text('Chippy'), findsWidgets);
      expect(find.text('55.0g'), findsOneWidget); // Admission weight with unit
      expect(find.textContaining('Furred'), findsOneWidget);
    });
  });

  group('SquirrelDetailView - Tab Navigation', () {
    testWidgets('should switch between tabs', (tester) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final squirrel = Squirrel.create(
        name: 'Tails',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 48.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(squirrel);

      // Build full app
      await tester.pumpWidget(buildAppWithProviders());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Navigate to detail view
      await tester.tap(find.text('Tails'));
      await tester.pumpAndSettle();

      // Act & Assert - Switch to Feeding tab
      await tester.tap(find.text('Feeding'));
      await tester.pumpAndSettle();
      expect(find.text('No feeding records yet'), findsOneWidget);

      // Switch to Progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.byType(WeightProgressChart), findsOneWidget);

      // Switch back to Info tab
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();
      expect(find.text('48.0'), findsOneWidget);
    });
  });

  group('SquirrelDetailView - Provider Error Prevention', () {
    testWidgets(
      'REGRESSION TEST: Providers accessible after navigation (provider architecture bug)',
      (tester) async {
        // This test specifically guards against the provider architecture bug
        // where MultiProvider was placed below MaterialApp, making providers
        // inaccessible in navigated routes.

        final squirrelRepo = SquirrelRepository(db);
        final squirrel = Squirrel.create(
          name: 'BugTest',
          foundDate: DateTime(2025, 1, 1),
          admissionWeight: 50.0,
          developmentStage: DevelopmentStage.newborn,
        );
        await squirrelRepo.addSquirrel(squirrel);

        // Build app - providers MUST be accessible
        await tester.pumpWidget(buildAppWithProviders());
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        // Navigate (this is where provider access was broken)
        await tester.tap(find.text('BugTest'));
        await tester.pumpAndSettle();

        // If we get here without errors, providers are accessible
        // Now test that each provider-dependent feature works:

        // 1. FeedingRepository (loaded in initState)
        expect(find.byType(SquirrelDetailView), findsOneWidget);

        // 2. WeightRepository (loaded when Progress tab rendered)
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();
        expect(find.byType(WeightProgressChart), findsOneWidget);

        // If this test passes, the provider architecture is correct
      },
    );
  });
}
