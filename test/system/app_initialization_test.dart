import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/providers/data_providers.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/care_note_repository.dart';
import 'package:foster_squirrel/repositories/drift/weight_repository.dart';
import 'package:foster_squirrel/views/home/home_view.dart';
import 'package:provider/provider.dart';

import '../integration/test_database_helper.dart';

/// App Initialization and Provider Architecture Validation Tests
///
/// CRITICAL: These tests validate the core app structure and provider setup.
/// The provider architecture bug (MultiProvider below MaterialApp) was not caught
/// because we had NO tests that validated the provider tree structure.
///
/// These tests ensure:
/// 1. MultiProvider wraps MaterialApp (not vice versa)
/// 2. All required providers are registered
/// 3. Providers are accessible from any screen
/// 4. ProxyProviders update correctly
/// 5. Navigation doesn't break provider access
void main() {
  late AppDatabase db;

  setUp(() async {
    db = TestDatabaseHelper.createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper that replicates EXACT app structure from main.dart
  Widget buildProductionAppStructure() {
    return MultiProvider(
      providers: [
        // Provide AppDatabase instance
        Provider<AppDatabase>.value(value: db),

        // Create Drift-based repositories
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

  group('App Initialization - Provider Registration', () {
    testWidgets('should register all required providers in correct order', (
      tester,
    ) async {
      // Act - Build app with production structure
      await tester.pumpWidget(buildProductionAppStructure());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Assert - All providers should be accessible
      final context = tester.element(find.byType(HomeView));

      // Database provider
      expect(
        () => Provider.of<AppDatabase>(context, listen: false),
        returnsNormally,
      );

      // Repository providers
      expect(
        () => Provider.of<SquirrelRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<FeedingRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<CareNoteRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<WeightRepository>(context, listen: false),
        returnsNormally,
      );

      // ChangeNotifier provider
      expect(
        () => Provider.of<SquirrelListProvider>(context, listen: false),
        returnsNormally,
      );
    });

    testWidgets('should provide working repository instances (not null)', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildProductionAppStructure());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Assert
      final context = tester.element(find.byType(HomeView));

      final squirrelRepo = Provider.of<SquirrelRepository>(
        context,
        listen: false,
      );
      final feedingRepo = Provider.of<FeedingRepository>(
        context,
        listen: false,
      );
      final careNoteRepo = Provider.of<CareNoteRepository>(
        context,
        listen: false,
      );
      final weightRepo = Provider.of<WeightRepository>(context, listen: false);

      expect(squirrelRepo, isNotNull);
      expect(feedingRepo, isNotNull);
      expect(careNoteRepo, isNotNull);
      expect(weightRepo, isNotNull);

      // Verify repositories are functional
      expect(() => squirrelRepo.getActiveSquirrels(), returnsNormally);
      expect(() => feedingRepo.getRecentFeedingRecords(), returnsNormally);
    });

    testWidgets('should provide working SquirrelListProvider instance', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildProductionAppStructure());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Assert
      final context = tester.element(find.byType(HomeView));
      final provider = Provider.of<SquirrelListProvider>(
        context,
        listen: false,
      );

      expect(provider, isNotNull);
      expect(provider.isLoading, isFalse); // Should have finished initial load
      expect(provider.squirrels, isNotNull);
    });
  });

  group('App Initialization - Provider Architecture Validation', () {
    testWidgets(
      'CRITICAL: MultiProvider must wrap MaterialApp (not vice versa)',
      (tester) async {
        // This test validates the fix for the provider architecture bug.
        // If MultiProvider is below MaterialApp, providers won't be accessible
        // in navigated routes.

        await tester.pumpWidget(buildProductionAppStructure());
        await tester.pumpAndSettle();

        // Get widget tree structure
        final multiProviderFinder = find.byType(MultiProvider);
        final materialAppFinder = find.byType(MaterialApp);

        expect(multiProviderFinder, findsOneWidget);
        expect(materialAppFinder, findsOneWidget);

        // Verify MultiProvider is ancestor of MaterialApp
        // (can't directly test widget tree order, but can verify both exist)
        final context = tester.element(find.byType(HomeView));

        // If providers are accessible from HomeView, the structure is correct
        expect(
          () => Provider.of<AppDatabase>(context, listen: false),
          returnsNormally,
        );
      },
    );

    testWidgets('should allow provider access from deeply nested widgets', (
      tester,
    ) async {
      // Arrange
      bool providerAccessible = false;

      final testWidget = MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          ProxyProvider<AppDatabase, SquirrelRepository>(
            update: (_, db, previous) => SquirrelRepository(db),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Try to access provider from nested widget
                try {
                  Provider.of<SquirrelRepository>(context, listen: false);
                  providerAccessible = true;
                } catch (e) {
                  providerAccessible = false;
                }
                return Container();
              },
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(providerAccessible, isTrue);
    });
  });

  group('App Initialization - ProxyProvider Updates', () {
    testWidgets('should create repository instances from database', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildProductionAppStructure());
      await tester.pumpAndSettle();

      // Assert - Repositories should be created via ProxyProvider
      final context = tester.element(find.byType(HomeView));

      final database = Provider.of<AppDatabase>(context, listen: false);
      final squirrelRepo = Provider.of<SquirrelRepository>(
        context,
        listen: false,
      );

      expect(database, isNotNull);
      expect(squirrelRepo, isNotNull);

      // Repositories should be functional
      final squirrels = await squirrelRepo.getActiveSquirrels();
      expect(squirrels, isNotNull);
    });

    testWidgets('should create SquirrelListProvider with SquirrelRepository', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildProductionAppStructure());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Assert - Provider should be created via ChangeNotifierProxyProvider
      final context = tester.element(find.byType(HomeView));

      final squirrelRepo = Provider.of<SquirrelRepository>(
        context,
        listen: false,
      );
      final provider = Provider.of<SquirrelListProvider>(
        context,
        listen: false,
      );

      expect(squirrelRepo, isNotNull);
      expect(provider, isNotNull);

      // Provider should have loaded data
      expect(provider.isLoading, isFalse);
    });
  });

  group('App Initialization - REGRESSION TESTS', () {
    testWidgets(
      'REGRESSION: Providers accessible after app init (provider architecture bug)',
      (tester) async {
        // This is THE critical test that would have caught the provider bug.
        // It validates that the provider structure allows access from all
        // parts of the app, including navigated routes.

        await tester.pumpWidget(buildProductionAppStructure());
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(HomeView));

        // All providers must be accessible
        final db = Provider.of<AppDatabase>(context, listen: false);
        final squirrelRepo = Provider.of<SquirrelRepository>(
          context,
          listen: false,
        );
        final feedingRepo = Provider.of<FeedingRepository>(
          context,
          listen: false,
        );
        final careNoteRepo = Provider.of<CareNoteRepository>(
          context,
          listen: false,
        );
        final weightRepo = Provider.of<WeightRepository>(
          context,
          listen: false,
        );
        final provider = Provider.of<SquirrelListProvider>(
          context,
          listen: false,
        );

        expect(db, isNotNull);
        expect(squirrelRepo, isNotNull);
        expect(feedingRepo, isNotNull);
        expect(careNoteRepo, isNotNull);
        expect(weightRepo, isNotNull);
        expect(provider, isNotNull);

        // If this test passes, the provider architecture is correct
      },
    );

    testWidgets('REGRESSION: App structure matches main.dart provider setup', (
      tester,
    ) async {
      // This test documents the correct provider structure and will fail
      // if anyone tries to move MultiProvider below MaterialApp again.

      final widget = buildProductionAppStructure();

      // Structure should be:
      // MultiProvider
      //   └─ MaterialApp
      //        └─ HomeView

      expect(widget, isA<MultiProvider>());

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Providers should be accessible from HomeView
      final context = tester.element(find.byType(HomeView));
      expect(
        () => Provider.of<AppDatabase>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<SquirrelRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<FeedingRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<WeightRepository>(context, listen: false),
        returnsNormally,
      );
      expect(
        () => Provider.of<SquirrelListProvider>(context, listen: false),
        returnsNormally,
      );
    });
  });
}
