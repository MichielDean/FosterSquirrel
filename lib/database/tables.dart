import 'package:drift/drift.dart';

/// Squirrels table - tracks baby squirrels being rehabilitated
@DataClassName('SquirrelData')
class Squirrels extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Human-readable name for the squirrel
  TextColumn get name => text()();

  /// Date when the squirrel was found/rescued (stored as ISO 8601 string)
  TextColumn get foundDate => text()();

  /// Weight in grams when first admitted
  RealColumn get admissionWeight => real().nullable()();

  /// Most recent weight in grams
  RealColumn get currentWeight => real().nullable()();

  /// Current status: 'active', 'released', 'deceased', 'transferred'
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Development stage: 'newborn', 'infant', 'juvenile', 'adolescent', 'adult'
  TextColumn get developmentStage =>
      text().withDefault(const Constant('newborn'))();

  /// General notes about the squirrel
  TextColumn get notes => text().nullable()();

  /// Path to the squirrel's photo
  TextColumn get photoPath => text().nullable()();

  /// When this record was created (ISO 8601 string)
  TextColumn get createdAt => text()();

  /// When this record was last updated (ISO 8601 string)
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Feeding records table - tracks individual feeding sessions
@DataClassName('FeedingRecordData')
class FeedingRecords extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to squirrels table
  TextColumn get squirrelId =>
      text().references(Squirrels, #id, onDelete: KeyAction.cascade)();

  /// Denormalized squirrel name for easier display
  TextColumn get squirrelName => text()();

  /// When this feeding occurred (ISO 8601 string)
  TextColumn get feedingTime => text()();

  /// Starting weight in grams before feeding
  RealColumn get startingWeightGrams => real()();

  /// Actual amount fed in milliliters
  RealColumn get actualFeedAmountMl => real().nullable()();

  /// Ending weight in grams after feeding
  RealColumn get endingWeightGrams => real().nullable()();

  /// Notes about this feeding session
  TextColumn get notes => text().nullable()();

  /// Type of food: 'Formula', 'Solid food', 'Water', etc.
  TextColumn get foodType => text().withDefault(const Constant('Formula'))();

  /// When this record was created (ISO 8601 string)
  TextColumn get createdAt => text().nullable()();

  /// When this record was last updated (ISO 8601 string)
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Care notes table - tracks observations and care notes
@DataClassName('CareNoteData')
class CareNotes extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Foreign key to squirrels table
  TextColumn get squirrelId =>
      text().references(Squirrels, #id, onDelete: KeyAction.cascade)();

  /// Content of the note
  TextColumn get content => text()();

  /// Type/category: 'general', 'medical', 'behavior', 'feeding', 'development'
  TextColumn get noteType => text()();

  /// Optional path to an attached photo
  TextColumn get photoPath => text().nullable()();

  /// Whether this note is marked as important
  IntColumn get isImportant => integer().withDefault(const Constant(0))();

  /// When this note was created (ISO 8601 string)
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
