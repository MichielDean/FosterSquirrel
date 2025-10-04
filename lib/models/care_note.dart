import 'package:uuid/uuid.dart';

/// Represents a care note or observation for a squirrel.
///
/// This is an immutable data model with JSON serialization support.
/// Notes can be categorized and include photo attachments.
class CareNote {
  const CareNote({
    required this.id,
    required this.squirrelId,
    required this.content,
    required this.noteType,
    required this.createdAt,
    this.photoPath,
    this.isImportant = false,
  });

  /// Unique identifier for this care note
  final String id;

  /// ID of the squirrel this note belongs to
  final String squirrelId;

  /// Content of the note
  final String content;

  /// Type/category of the note
  final CareNoteType noteType;

  /// When this note was created
  final DateTime createdAt;

  /// Optional path to an attached photo
  final String? photoPath;

  /// Whether this note is marked as important
  final bool isImportant;

  /// Creates a new CareNote with a generated UUID
  factory CareNote.create({
    required String squirrelId,
    required String content,
    required CareNoteType noteType,
    String? photoPath,
    bool isImportant = false,
  }) {
    final uuid = const Uuid();
    final now = DateTime.now();

    return CareNote(
      id: uuid.v4(),
      squirrelId: squirrelId,
      content: content,
      noteType: noteType,
      createdAt: now,
      photoPath: photoPath,
      isImportant: isImportant,
    );
  }

  /// Creates a copy of this care note with updated fields
  CareNote copyWith({
    String? id,
    String? squirrelId,
    String? content,
    CareNoteType? noteType,
    DateTime? createdAt,
    String? photoPath,
    bool? isImportant,
  }) {
    return CareNote(
      id: id ?? this.id,
      squirrelId: squirrelId ?? this.squirrelId,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  /// Creates a CareNote from a JSON map
  factory CareNote.fromJson(Map<String, dynamic> json) {
    return CareNote(
      id: json['id'] as String,
      squirrelId: json['squirrel_id'] as String,
      content: json['content'] as String,
      noteType: CareNoteType.fromString(json['note_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      photoPath: json['photo_path'] as String?,
      isImportant: json['is_important'] as bool? ?? false,
    );
  }

  /// Converts this CareNote to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'squirrel_id': squirrelId,
      'content': content,
      'note_type': noteType.value,
      'created_at': createdAt.toIso8601String(),
      'photo_path': photoPath,
      'is_important': isImportant,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareNote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CareNote{id: $id, squirrelId: $squirrelId, noteType: $noteType, isImportant: $isImportant, createdAt: $createdAt}';
  }
}

/// Enumeration of care note types/categories
enum CareNoteType {
  medical('medical', 'Medical'),
  behavioral('behavioral', 'Behavioral'),
  feeding('feeding', 'Feeding'),
  development('development', 'Development'),
  general('general', 'General'),
  release('release', 'Release Prep');

  const CareNoteType(this.value, this.displayName);

  final String value;
  final String displayName;

  static CareNoteType fromString(String value) {
    return CareNoteType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CareNoteType.general,
    );
  }

  @override
  String toString() => displayName;
}
