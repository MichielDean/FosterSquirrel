// This file generates mock classes for testing using mockito
// Run: dart run build_runner build
import 'package:mockito/annotations.dart';
import 'package:foster_squirrel/database/database.dart';
import 'package:foster_squirrel/repositories/drift/squirrel_repository.dart';
import 'package:foster_squirrel/repositories/drift/feeding_repository.dart';
import 'package:foster_squirrel/repositories/drift/care_note_repository.dart';
import 'package:foster_squirrel/repositories/drift/weight_repository.dart';

@GenerateMocks([
  AppDatabase,
  SquirrelRepository,
  FeedingRepository,
  CareNoteRepository,
  WeightRepository,
])
void main() {}
