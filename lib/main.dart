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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Don't block the main thread - initialize database asynchronously
  runApp(const SquirrelTrackerApp());
}

class SquirrelTrackerApp extends StatefulWidget {
  const SquirrelTrackerApp({super.key});

  @override
  State<SquirrelTrackerApp> createState() => _SquirrelTrackerAppState();
}

class _SquirrelTrackerAppState extends State<SquirrelTrackerApp> {
  AppDatabase? _database;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _database = AppDatabase();
      // Run a simple query to force initialization
      await _database!.select(_database!.squirrels).get();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize database: $e');
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If database not ready, show loading
    if (!_isInitialized || _database == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/foster_squirrel.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    // CRITICAL: MultiProvider wraps MaterialApp so providers are available in ALL routes
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
      child: MaterialApp(
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
          nextScreen: const HomeView(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: const Color(0xFFFFCE83),
          duration: 2000,
          centered: true,
          splashIconSize: 300,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
