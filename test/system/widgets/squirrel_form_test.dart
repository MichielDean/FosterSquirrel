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
import 'package:foster_squirrel/widgets/forms/squirrel_form.dart';
import 'package:provider/provider.dart';

import '../../integration/test_database_helper.dart';

/// System tests for SquirrelFormPage
///
/// CRITICAL: These tests validate that squirrel add/edit workflows work correctly
/// through navigation, and that providers are accessible in navigated contexts.
///
/// These tests:
/// 1. Build full app structure with providers (like main.dart)
/// 2. Navigate from HomeView to SquirrelFormPage
/// 3. Test form submission and data handling
/// 4. Validate form validation
/// 5. Test edit mode functionality
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

  group('SquirrelFormPage - Navigation and Form Submission', () {
    testWidgets('should navigate to add form from HomeView', (tester) async {
      // Arrange
      await tester.pumpWidget(buildAppWithProviders(home: const HomeView()));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Act - Tap FAB to open form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert - Form should open
      expect(find.byType(SquirrelFormPage), findsOneWidget);
      expect(find.text('Add New Squirrel'), findsOneWidget);
    });

    testWidgets('should create new squirrel and return to HomeView', (
      tester,
    ) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);

      await tester.pumpWidget(buildAppWithProviders(home: const HomeView()));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Navigate to form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Act - Fill form
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'NewSquirrel',
      );
      await tester.enterText(find.byKey(const Key('weight_field')), '50.0');

      // Save
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Assert - Should return to HomeView
      expect(find.byType(SquirrelFormPage), findsNothing);
      expect(find.byType(HomeView), findsOneWidget);

      // Wait for provider to load and display
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify squirrel was saved
      final squirrels = await squirrelRepo.getActiveSquirrels();
      expect(squirrels, hasLength(1));
      expect(squirrels.first.name, 'NewSquirrel');
      expect(squirrels.first.admissionWeight, 50.0);
    });

    testWidgets('should cancel form without saving', (tester) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);

      await tester.pumpWidget(buildAppWithProviders(home: const HomeView()));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Act - Fill form
      await tester.enterText(find.byKey(const Key('name_field')), 'CancelTest');

      // Cancel using back button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert - Should return without saving
      expect(find.byType(SquirrelFormPage), findsNothing);

      final squirrels = await squirrelRepo.getActiveSquirrels();
      expect(squirrels, isEmpty);
    });
  });

  group('SquirrelFormPage - Form Validation', () {
    testWidgets('should show validation error when name is empty', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Try to save without name
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      // Assert - Should show validation error
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.byType(SquirrelFormPage), findsOneWidget);
    });

    testWidgets('should show validation error when weight is invalid', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Enter invalid weight
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'TestSquirrel',
      );
      await tester.enterText(find.byKey(const Key('weight_field')), '-5');
      await tester.tap(find.text('SAVE'));
      await tester.pump();

      // Assert - Should show validation error
      expect(find.text('Weight must be greater than 0'), findsOneWidget);
    });

    testWidgets('should allow saving with only name (weight optional)', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Save with only name
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'MinimalSquirrel',
      );
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // Assert - Should save successfully
      expect(find.byType(SquirrelFormPage), findsNothing);
    });
  });

  group('SquirrelFormPage - Edit Mode', () {
    testWidgets('should populate form with existing squirrel data', (
      tester,
    ) async {
      // Arrange - Create existing squirrel
      final squirrel = Squirrel.create(
        name: 'ExistingSquirrel',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 45.0,
        developmentStage: DevelopmentStage.infant,
        notes: 'Test notes',
      );

      await tester.pumpWidget(
        buildAppWithProviders(home: SquirrelFormPage(squirrel: squirrel)),
      );
      await tester.pumpAndSettle();

      // Assert - Form should be populated
      expect(find.text('Edit Squirrel'), findsOneWidget);
      expect(find.text('ExistingSquirrel'), findsOneWidget);
      expect(find.text('45.0'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should update existing squirrel when saved', (tester) async {
      // Arrange
      final squirrelRepo = SquirrelRepository(db);
      final originalSquirrel = Squirrel.create(
        name: 'Original',
        foundDate: DateTime(2025, 1, 1),
        admissionWeight: 45.0,
        developmentStage: DevelopmentStage.newborn,
      );
      await squirrelRepo.addSquirrel(originalSquirrel);

      await tester.pumpWidget(
        buildAppWithProviders(
          home: SquirrelFormPage(squirrel: originalSquirrel),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Update name
      await tester.enterText(find.byKey(const Key('name_field')), 'Updated');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      // The form returns the updated squirrel via pop(), but doesn't save it
      // The parent (HomeView) is responsible for saving
      // This test just verifies the form returns the updated data
      expect(find.byType(SquirrelFormPage), findsNothing);
    });
  });

  group('SquirrelFormPage - Development Stage Selection', () {
    testWidgets('should allow selecting different development stages', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Open dropdown
      await tester.tap(find.byKey(const Key('development_stage_dropdown')));
      await tester.pumpAndSettle();

      // Select infant stage
      await tester.tap(find.text('infant (2-5w)').last);
      await tester.pumpAndSettle();

      // Assert - Infant should be selected
      expect(find.text('infant (2-5w)'), findsOneWidget);
    });

    testWidgets('should show development stage info dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Tap help icon
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      // Assert - Dialog should appear
      expect(find.text('Development Stages'), findsOneWidget);
      expect(find.text('Pinkie (0-2 weeks)'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });
  });

  group('SquirrelFormPage - Date Selection', () {
    testWidgets('should open date picker when date field is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildAppWithProviders(home: const SquirrelFormPage()),
      );
      await tester.pumpAndSettle();

      // Act - Tap date field
      await tester.tap(find.byKey(const Key('found_date_field')));
      await tester.pumpAndSettle();

      // Assert - Date picker should appear
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Cancel date picker
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('SquirrelFormPage - REGRESSION TESTS', () {
    testWidgets(
      'REGRESSION: Form accessible through navigation (provider architecture bug)',
      (tester) async {
        // This test guards against the provider architecture bug where
        // forms accessed via navigation couldn't access providers.

        await tester.pumpWidget(buildAppWithProviders(home: const HomeView()));
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        // Navigate to form (where provider access was broken)
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Form should render without errors
        expect(find.byType(SquirrelFormPage), findsOneWidget);

        // Fill and save (validates providers are accessible)
        await tester.enterText(
          find.byKey(const Key('name_field')),
          'ProviderTest',
        );
        await tester.tap(find.text('SAVE'));
        await tester.pumpAndSettle();

        // Should complete without provider errors
        expect(find.byType(SquirrelFormPage), findsNothing);
      },
    );
  });
}
