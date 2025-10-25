import 'package:drift/native.dart';
import 'package:foster_squirrel/database/database.dart';

/// Helper class for creating test databases using Drift.
///
/// This uses Drift's in-memory database for fast, isolated testing.
class TestDatabaseHelper {
  /// Creates a fresh Drift database for testing.
  ///
  /// Each test gets an isolated in-memory database that's automatically
  /// cleaned up when the connection is closed.
  static AppDatabase createTestDatabase() {
    // Create an in-memory database connection
    // This runs entirely in-memory and is perfect for tests
    return AppDatabase.forTesting(NativeDatabase.memory());
  }

  /// Clears all data from all tables in the database.
  /// This ensures each test starts with a clean slate.
  static Future<void> clearAllData(AppDatabase db) async {
    // Delete all data from all tables
    await db.delete(db.careNotes).go();
    await db.delete(db.feedingRecords).go();
    await db.delete(db.squirrels).go();
  }

  /// Closes and cleans up the database.
  static Future<void> closeDatabase(AppDatabase db) async {
    await db.close();
  }
}
