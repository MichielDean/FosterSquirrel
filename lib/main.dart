import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'database/database.dart';
import 'repositories/drift/squirrel_repository.dart';
import 'repositories/drift/feeding_repository.dart';
import 'repositories/drift/care_note_repository.dart';
import 'repositories/drift/weight_repository.dart';
import 'providers/data_providers.dart';
import 'views/home/home_view.dart';
import 'widgets/common/optimized_images.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Don't block the main thread - initialize database asynchronously
  runApp(const SquirrelTrackerApp());
}

class SquirrelTrackerApp extends StatelessWidget {
  const SquirrelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FosterSquirrel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 6,
        ),
      ),
      // PERFORMANCE: Optimized splash screen with proper image sizing
      home: AnimatedSplashScreen(
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Larger splash image - using Column to control size better
            Image.asset(
              'assets/images/foster_squirrel.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              // PERFORMANCE: Cache at display resolution to avoid expensive decoding
              cacheWidth: (300 * 3).round(), // 3x for high DPI screens
              cacheHeight: (300 * 3).round(),
              filterQuality: FilterQuality.medium,
              // Preload reduces jank
              gaplessPlayback: true,
            ),
          ],
        ),
        nextScreen: const AppInitializer(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: const Color(0xFFFFD19B),
        duration: 2000,
        centered: true,
        splashIconSize: 300,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Handles async app initialization without showing a custom splash screen
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppDatabase? _database;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // PERFORMANCE CRITICAL: Initialize database AFTER first frame
    // This allows Flutter to render the UI first, preventing frame drops
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });

    // Show UI immediately - database will initialize in background
    _showUIImmediately();
  }

  /// Show UI immediately without waiting for database
  /// PERFORMANCE: Prevents blocking the main thread during database init
  void _showUIImmediately() {
    // Create AppDatabase instance immediately (lightweight)
    _database = AppDatabase();

    // Set initialized to true so UI renders
    // Database will actually initialize in background via addPostFrameCallback
    setState(() {
      _isInitialized = true;
    });
  }

  /// Initialize database AFTER UI is shown
  /// PERFORMANCE: Database init happens after first frame, preventing stutter
  Future<void> _initializeApp() async {
    try {
      // Trigger database initialization in background
      // Drift/sqflite runs this on a background thread
      // Run a simple query to force initialization
      await _database!.select(_database!.squirrels).get();

      // PERFORMANCE: Add small delay before building provider tree
      // This lets the UI thread catch up after database init completes
      await Future.delayed(const Duration(milliseconds: 100));

      // Database is ready - force refresh of providers if needed
      if (mounted) {
        // No setState needed - database is ready, providers will load data
        debugPrint('Drift database initialized successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize database: $e';
          _isInitialized = false; // Show error state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if initialization failed
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OptimizedImages.errorSquirrel,
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state while initialization is in progress
    // Loading indicator while initializing
    if (!_isInitialized || _database == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Once initialized, show the main app with providers
    return MultiProvider(
      providers: [
        // Provide AppDatabase instance
        Provider<AppDatabase>.value(value: _database!),

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

        // Add the optimized list provider to prevent FutureBuilder antipattern
        ChangeNotifierProxyProvider<SquirrelRepository, SquirrelListProvider>(
          create: (context) => SquirrelListProvider(
            Provider.of<SquirrelRepository>(context, listen: false),
          ),
          update: (_, repository, previous) =>
              previous ?? SquirrelListProvider(repository),
        ),
      ],
      child: const HomeView(),
    );
  }
}
