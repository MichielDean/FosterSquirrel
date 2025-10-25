// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SquirrelsTable extends Squirrels
    with TableInfo<$SquirrelsTable, SquirrelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SquirrelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foundDateMeta = const VerificationMeta(
    'foundDate',
  );
  @override
  late final GeneratedColumn<String> foundDate = GeneratedColumn<String>(
    'found_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _admissionWeightMeta = const VerificationMeta(
    'admissionWeight',
  );
  @override
  late final GeneratedColumn<double> admissionWeight = GeneratedColumn<double>(
    'admission_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentWeightMeta = const VerificationMeta(
    'currentWeight',
  );
  @override
  late final GeneratedColumn<double> currentWeight = GeneratedColumn<double>(
    'current_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _developmentStageMeta = const VerificationMeta(
    'developmentStage',
  );
  @override
  late final GeneratedColumn<String> developmentStage = GeneratedColumn<String>(
    'development_stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('newborn'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    foundDate,
    admissionWeight,
    currentWeight,
    status,
    developmentStage,
    notes,
    photoPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'squirrels';
  @override
  VerificationContext validateIntegrity(
    Insertable<SquirrelData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('found_date')) {
      context.handle(
        _foundDateMeta,
        foundDate.isAcceptableOrUnknown(data['found_date']!, _foundDateMeta),
      );
    } else if (isInserting) {
      context.missing(_foundDateMeta);
    }
    if (data.containsKey('admission_weight')) {
      context.handle(
        _admissionWeightMeta,
        admissionWeight.isAcceptableOrUnknown(
          data['admission_weight']!,
          _admissionWeightMeta,
        ),
      );
    }
    if (data.containsKey('current_weight')) {
      context.handle(
        _currentWeightMeta,
        currentWeight.isAcceptableOrUnknown(
          data['current_weight']!,
          _currentWeightMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('development_stage')) {
      context.handle(
        _developmentStageMeta,
        developmentStage.isAcceptableOrUnknown(
          data['development_stage']!,
          _developmentStageMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SquirrelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SquirrelData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      foundDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}found_date'],
      )!,
      admissionWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}admission_weight'],
      ),
      currentWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_weight'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      developmentStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}development_stage'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SquirrelsTable createAlias(String alias) {
    return $SquirrelsTable(attachedDatabase, alias);
  }
}

class SquirrelData extends DataClass implements Insertable<SquirrelData> {
  /// Unique identifier (UUID)
  final String id;

  /// Human-readable name for the squirrel
  final String name;

  /// Date when the squirrel was found/rescued (stored as ISO 8601 string)
  final String foundDate;

  /// Weight in grams when first admitted
  final double? admissionWeight;

  /// Most recent weight in grams
  final double? currentWeight;

  /// Current status: 'active', 'released', 'deceased', 'transferred'
  final String status;

  /// Development stage: 'newborn', 'infant', 'juvenile', 'adolescent', 'adult'
  final String developmentStage;

  /// General notes about the squirrel
  final String? notes;

  /// Path to the squirrel's photo
  final String? photoPath;

  /// When this record was created (ISO 8601 string)
  final String createdAt;

  /// When this record was last updated (ISO 8601 string)
  final String updatedAt;
  const SquirrelData({
    required this.id,
    required this.name,
    required this.foundDate,
    this.admissionWeight,
    this.currentWeight,
    required this.status,
    required this.developmentStage,
    this.notes,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['found_date'] = Variable<String>(foundDate);
    if (!nullToAbsent || admissionWeight != null) {
      map['admission_weight'] = Variable<double>(admissionWeight);
    }
    if (!nullToAbsent || currentWeight != null) {
      map['current_weight'] = Variable<double>(currentWeight);
    }
    map['status'] = Variable<String>(status);
    map['development_stage'] = Variable<String>(developmentStage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SquirrelsCompanion toCompanion(bool nullToAbsent) {
    return SquirrelsCompanion(
      id: Value(id),
      name: Value(name),
      foundDate: Value(foundDate),
      admissionWeight: admissionWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(admissionWeight),
      currentWeight: currentWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(currentWeight),
      status: Value(status),
      developmentStage: Value(developmentStage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SquirrelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SquirrelData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      foundDate: serializer.fromJson<String>(json['foundDate']),
      admissionWeight: serializer.fromJson<double?>(json['admissionWeight']),
      currentWeight: serializer.fromJson<double?>(json['currentWeight']),
      status: serializer.fromJson<String>(json['status']),
      developmentStage: serializer.fromJson<String>(json['developmentStage']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'foundDate': serializer.toJson<String>(foundDate),
      'admissionWeight': serializer.toJson<double?>(admissionWeight),
      'currentWeight': serializer.toJson<double?>(currentWeight),
      'status': serializer.toJson<String>(status),
      'developmentStage': serializer.toJson<String>(developmentStage),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SquirrelData copyWith({
    String? id,
    String? name,
    String? foundDate,
    Value<double?> admissionWeight = const Value.absent(),
    Value<double?> currentWeight = const Value.absent(),
    String? status,
    String? developmentStage,
    Value<String?> notes = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => SquirrelData(
    id: id ?? this.id,
    name: name ?? this.name,
    foundDate: foundDate ?? this.foundDate,
    admissionWeight: admissionWeight.present
        ? admissionWeight.value
        : this.admissionWeight,
    currentWeight: currentWeight.present
        ? currentWeight.value
        : this.currentWeight,
    status: status ?? this.status,
    developmentStage: developmentStage ?? this.developmentStage,
    notes: notes.present ? notes.value : this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SquirrelData copyWithCompanion(SquirrelsCompanion data) {
    return SquirrelData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      foundDate: data.foundDate.present ? data.foundDate.value : this.foundDate,
      admissionWeight: data.admissionWeight.present
          ? data.admissionWeight.value
          : this.admissionWeight,
      currentWeight: data.currentWeight.present
          ? data.currentWeight.value
          : this.currentWeight,
      status: data.status.present ? data.status.value : this.status,
      developmentStage: data.developmentStage.present
          ? data.developmentStage.value
          : this.developmentStage,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SquirrelData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('foundDate: $foundDate, ')
          ..write('admissionWeight: $admissionWeight, ')
          ..write('currentWeight: $currentWeight, ')
          ..write('status: $status, ')
          ..write('developmentStage: $developmentStage, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    foundDate,
    admissionWeight,
    currentWeight,
    status,
    developmentStage,
    notes,
    photoPath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SquirrelData &&
          other.id == this.id &&
          other.name == this.name &&
          other.foundDate == this.foundDate &&
          other.admissionWeight == this.admissionWeight &&
          other.currentWeight == this.currentWeight &&
          other.status == this.status &&
          other.developmentStage == this.developmentStage &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SquirrelsCompanion extends UpdateCompanion<SquirrelData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> foundDate;
  final Value<double?> admissionWeight;
  final Value<double?> currentWeight;
  final Value<String> status;
  final Value<String> developmentStage;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SquirrelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.foundDate = const Value.absent(),
    this.admissionWeight = const Value.absent(),
    this.currentWeight = const Value.absent(),
    this.status = const Value.absent(),
    this.developmentStage = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SquirrelsCompanion.insert({
    required String id,
    required String name,
    required String foundDate,
    this.admissionWeight = const Value.absent(),
    this.currentWeight = const Value.absent(),
    this.status = const Value.absent(),
    this.developmentStage = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       foundDate = Value(foundDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SquirrelData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? foundDate,
    Expression<double>? admissionWeight,
    Expression<double>? currentWeight,
    Expression<String>? status,
    Expression<String>? developmentStage,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (foundDate != null) 'found_date': foundDate,
      if (admissionWeight != null) 'admission_weight': admissionWeight,
      if (currentWeight != null) 'current_weight': currentWeight,
      if (status != null) 'status': status,
      if (developmentStage != null) 'development_stage': developmentStage,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SquirrelsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? foundDate,
    Value<double?>? admissionWeight,
    Value<double?>? currentWeight,
    Value<String>? status,
    Value<String>? developmentStage,
    Value<String?>? notes,
    Value<String?>? photoPath,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return SquirrelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      foundDate: foundDate ?? this.foundDate,
      admissionWeight: admissionWeight ?? this.admissionWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      status: status ?? this.status,
      developmentStage: developmentStage ?? this.developmentStage,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (foundDate.present) {
      map['found_date'] = Variable<String>(foundDate.value);
    }
    if (admissionWeight.present) {
      map['admission_weight'] = Variable<double>(admissionWeight.value);
    }
    if (currentWeight.present) {
      map['current_weight'] = Variable<double>(currentWeight.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (developmentStage.present) {
      map['development_stage'] = Variable<String>(developmentStage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SquirrelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('foundDate: $foundDate, ')
          ..write('admissionWeight: $admissionWeight, ')
          ..write('currentWeight: $currentWeight, ')
          ..write('status: $status, ')
          ..write('developmentStage: $developmentStage, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedingRecordsTable extends FeedingRecords
    with TableInfo<$FeedingRecordsTable, FeedingRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _squirrelIdMeta = const VerificationMeta(
    'squirrelId',
  );
  @override
  late final GeneratedColumn<String> squirrelId = GeneratedColumn<String>(
    'squirrel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES squirrels (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _squirrelNameMeta = const VerificationMeta(
    'squirrelName',
  );
  @override
  late final GeneratedColumn<String> squirrelName = GeneratedColumn<String>(
    'squirrel_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedingTimeMeta = const VerificationMeta(
    'feedingTime',
  );
  @override
  late final GeneratedColumn<String> feedingTime = GeneratedColumn<String>(
    'feeding_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startingWeightGramsMeta =
      const VerificationMeta('startingWeightGrams');
  @override
  late final GeneratedColumn<double> startingWeightGrams =
      GeneratedColumn<double>(
        'starting_weight_grams',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actualFeedAmountMlMeta =
      const VerificationMeta('actualFeedAmountMl');
  @override
  late final GeneratedColumn<double> actualFeedAmountMl =
      GeneratedColumn<double>(
        'actual_feed_amount_ml',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endingWeightGramsMeta = const VerificationMeta(
    'endingWeightGrams',
  );
  @override
  late final GeneratedColumn<double> endingWeightGrams =
      GeneratedColumn<double>(
        'ending_weight_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodTypeMeta = const VerificationMeta(
    'foodType',
  );
  @override
  late final GeneratedColumn<String> foodType = GeneratedColumn<String>(
    'food_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Formula'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    squirrelId,
    squirrelName,
    feedingTime,
    startingWeightGrams,
    actualFeedAmountMl,
    endingWeightGrams,
    notes,
    foodType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedingRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('squirrel_id')) {
      context.handle(
        _squirrelIdMeta,
        squirrelId.isAcceptableOrUnknown(data['squirrel_id']!, _squirrelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_squirrelIdMeta);
    }
    if (data.containsKey('squirrel_name')) {
      context.handle(
        _squirrelNameMeta,
        squirrelName.isAcceptableOrUnknown(
          data['squirrel_name']!,
          _squirrelNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_squirrelNameMeta);
    }
    if (data.containsKey('feeding_time')) {
      context.handle(
        _feedingTimeMeta,
        feedingTime.isAcceptableOrUnknown(
          data['feeding_time']!,
          _feedingTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feedingTimeMeta);
    }
    if (data.containsKey('starting_weight_grams')) {
      context.handle(
        _startingWeightGramsMeta,
        startingWeightGrams.isAcceptableOrUnknown(
          data['starting_weight_grams']!,
          _startingWeightGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startingWeightGramsMeta);
    }
    if (data.containsKey('actual_feed_amount_ml')) {
      context.handle(
        _actualFeedAmountMlMeta,
        actualFeedAmountMl.isAcceptableOrUnknown(
          data['actual_feed_amount_ml']!,
          _actualFeedAmountMlMeta,
        ),
      );
    }
    if (data.containsKey('ending_weight_grams')) {
      context.handle(
        _endingWeightGramsMeta,
        endingWeightGrams.isAcceptableOrUnknown(
          data['ending_weight_grams']!,
          _endingWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('food_type')) {
      context.handle(
        _foodTypeMeta,
        foodType.isAcceptableOrUnknown(data['food_type']!, _foodTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingRecordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      squirrelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}squirrel_id'],
      )!,
      squirrelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}squirrel_name'],
      )!,
      feedingTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeding_time'],
      )!,
      startingWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}starting_weight_grams'],
      )!,
      actualFeedAmountMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_feed_amount_ml'],
      ),
      endingWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ending_weight_grams'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      foodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $FeedingRecordsTable createAlias(String alias) {
    return $FeedingRecordsTable(attachedDatabase, alias);
  }
}

class FeedingRecordData extends DataClass
    implements Insertable<FeedingRecordData> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to squirrels table
  final String squirrelId;

  /// Denormalized squirrel name for easier display
  final String squirrelName;

  /// When this feeding occurred (ISO 8601 string)
  final String feedingTime;

  /// Starting weight in grams before feeding
  final double startingWeightGrams;

  /// Actual amount fed in milliliters
  final double? actualFeedAmountMl;

  /// Ending weight in grams after feeding
  final double? endingWeightGrams;

  /// Notes about this feeding session
  final String? notes;

  /// Type of food: 'Formula', 'Solid food', 'Water', etc.
  final String foodType;

  /// When this record was created (ISO 8601 string)
  final String? createdAt;

  /// When this record was last updated (ISO 8601 string)
  final String? updatedAt;
  const FeedingRecordData({
    required this.id,
    required this.squirrelId,
    required this.squirrelName,
    required this.feedingTime,
    required this.startingWeightGrams,
    this.actualFeedAmountMl,
    this.endingWeightGrams,
    this.notes,
    required this.foodType,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['squirrel_id'] = Variable<String>(squirrelId);
    map['squirrel_name'] = Variable<String>(squirrelName);
    map['feeding_time'] = Variable<String>(feedingTime);
    map['starting_weight_grams'] = Variable<double>(startingWeightGrams);
    if (!nullToAbsent || actualFeedAmountMl != null) {
      map['actual_feed_amount_ml'] = Variable<double>(actualFeedAmountMl);
    }
    if (!nullToAbsent || endingWeightGrams != null) {
      map['ending_weight_grams'] = Variable<double>(endingWeightGrams);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['food_type'] = Variable<String>(foodType);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  FeedingRecordsCompanion toCompanion(bool nullToAbsent) {
    return FeedingRecordsCompanion(
      id: Value(id),
      squirrelId: Value(squirrelId),
      squirrelName: Value(squirrelName),
      feedingTime: Value(feedingTime),
      startingWeightGrams: Value(startingWeightGrams),
      actualFeedAmountMl: actualFeedAmountMl == null && nullToAbsent
          ? const Value.absent()
          : Value(actualFeedAmountMl),
      endingWeightGrams: endingWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(endingWeightGrams),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      foodType: Value(foodType),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory FeedingRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingRecordData(
      id: serializer.fromJson<String>(json['id']),
      squirrelId: serializer.fromJson<String>(json['squirrelId']),
      squirrelName: serializer.fromJson<String>(json['squirrelName']),
      feedingTime: serializer.fromJson<String>(json['feedingTime']),
      startingWeightGrams: serializer.fromJson<double>(
        json['startingWeightGrams'],
      ),
      actualFeedAmountMl: serializer.fromJson<double?>(
        json['actualFeedAmountMl'],
      ),
      endingWeightGrams: serializer.fromJson<double?>(
        json['endingWeightGrams'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      foodType: serializer.fromJson<String>(json['foodType']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'squirrelId': serializer.toJson<String>(squirrelId),
      'squirrelName': serializer.toJson<String>(squirrelName),
      'feedingTime': serializer.toJson<String>(feedingTime),
      'startingWeightGrams': serializer.toJson<double>(startingWeightGrams),
      'actualFeedAmountMl': serializer.toJson<double?>(actualFeedAmountMl),
      'endingWeightGrams': serializer.toJson<double?>(endingWeightGrams),
      'notes': serializer.toJson<String?>(notes),
      'foodType': serializer.toJson<String>(foodType),
      'createdAt': serializer.toJson<String?>(createdAt),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  FeedingRecordData copyWith({
    String? id,
    String? squirrelId,
    String? squirrelName,
    String? feedingTime,
    double? startingWeightGrams,
    Value<double?> actualFeedAmountMl = const Value.absent(),
    Value<double?> endingWeightGrams = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? foodType,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => FeedingRecordData(
    id: id ?? this.id,
    squirrelId: squirrelId ?? this.squirrelId,
    squirrelName: squirrelName ?? this.squirrelName,
    feedingTime: feedingTime ?? this.feedingTime,
    startingWeightGrams: startingWeightGrams ?? this.startingWeightGrams,
    actualFeedAmountMl: actualFeedAmountMl.present
        ? actualFeedAmountMl.value
        : this.actualFeedAmountMl,
    endingWeightGrams: endingWeightGrams.present
        ? endingWeightGrams.value
        : this.endingWeightGrams,
    notes: notes.present ? notes.value : this.notes,
    foodType: foodType ?? this.foodType,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  FeedingRecordData copyWithCompanion(FeedingRecordsCompanion data) {
    return FeedingRecordData(
      id: data.id.present ? data.id.value : this.id,
      squirrelId: data.squirrelId.present
          ? data.squirrelId.value
          : this.squirrelId,
      squirrelName: data.squirrelName.present
          ? data.squirrelName.value
          : this.squirrelName,
      feedingTime: data.feedingTime.present
          ? data.feedingTime.value
          : this.feedingTime,
      startingWeightGrams: data.startingWeightGrams.present
          ? data.startingWeightGrams.value
          : this.startingWeightGrams,
      actualFeedAmountMl: data.actualFeedAmountMl.present
          ? data.actualFeedAmountMl.value
          : this.actualFeedAmountMl,
      endingWeightGrams: data.endingWeightGrams.present
          ? data.endingWeightGrams.value
          : this.endingWeightGrams,
      notes: data.notes.present ? data.notes.value : this.notes,
      foodType: data.foodType.present ? data.foodType.value : this.foodType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingRecordData(')
          ..write('id: $id, ')
          ..write('squirrelId: $squirrelId, ')
          ..write('squirrelName: $squirrelName, ')
          ..write('feedingTime: $feedingTime, ')
          ..write('startingWeightGrams: $startingWeightGrams, ')
          ..write('actualFeedAmountMl: $actualFeedAmountMl, ')
          ..write('endingWeightGrams: $endingWeightGrams, ')
          ..write('notes: $notes, ')
          ..write('foodType: $foodType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    squirrelId,
    squirrelName,
    feedingTime,
    startingWeightGrams,
    actualFeedAmountMl,
    endingWeightGrams,
    notes,
    foodType,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingRecordData &&
          other.id == this.id &&
          other.squirrelId == this.squirrelId &&
          other.squirrelName == this.squirrelName &&
          other.feedingTime == this.feedingTime &&
          other.startingWeightGrams == this.startingWeightGrams &&
          other.actualFeedAmountMl == this.actualFeedAmountMl &&
          other.endingWeightGrams == this.endingWeightGrams &&
          other.notes == this.notes &&
          other.foodType == this.foodType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedingRecordsCompanion extends UpdateCompanion<FeedingRecordData> {
  final Value<String> id;
  final Value<String> squirrelId;
  final Value<String> squirrelName;
  final Value<String> feedingTime;
  final Value<double> startingWeightGrams;
  final Value<double?> actualFeedAmountMl;
  final Value<double?> endingWeightGrams;
  final Value<String?> notes;
  final Value<String> foodType;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const FeedingRecordsCompanion({
    this.id = const Value.absent(),
    this.squirrelId = const Value.absent(),
    this.squirrelName = const Value.absent(),
    this.feedingTime = const Value.absent(),
    this.startingWeightGrams = const Value.absent(),
    this.actualFeedAmountMl = const Value.absent(),
    this.endingWeightGrams = const Value.absent(),
    this.notes = const Value.absent(),
    this.foodType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedingRecordsCompanion.insert({
    required String id,
    required String squirrelId,
    required String squirrelName,
    required String feedingTime,
    required double startingWeightGrams,
    this.actualFeedAmountMl = const Value.absent(),
    this.endingWeightGrams = const Value.absent(),
    this.notes = const Value.absent(),
    this.foodType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       squirrelId = Value(squirrelId),
       squirrelName = Value(squirrelName),
       feedingTime = Value(feedingTime),
       startingWeightGrams = Value(startingWeightGrams);
  static Insertable<FeedingRecordData> custom({
    Expression<String>? id,
    Expression<String>? squirrelId,
    Expression<String>? squirrelName,
    Expression<String>? feedingTime,
    Expression<double>? startingWeightGrams,
    Expression<double>? actualFeedAmountMl,
    Expression<double>? endingWeightGrams,
    Expression<String>? notes,
    Expression<String>? foodType,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (squirrelId != null) 'squirrel_id': squirrelId,
      if (squirrelName != null) 'squirrel_name': squirrelName,
      if (feedingTime != null) 'feeding_time': feedingTime,
      if (startingWeightGrams != null)
        'starting_weight_grams': startingWeightGrams,
      if (actualFeedAmountMl != null)
        'actual_feed_amount_ml': actualFeedAmountMl,
      if (endingWeightGrams != null) 'ending_weight_grams': endingWeightGrams,
      if (notes != null) 'notes': notes,
      if (foodType != null) 'food_type': foodType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedingRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? squirrelId,
    Value<String>? squirrelName,
    Value<String>? feedingTime,
    Value<double>? startingWeightGrams,
    Value<double?>? actualFeedAmountMl,
    Value<double?>? endingWeightGrams,
    Value<String?>? notes,
    Value<String>? foodType,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return FeedingRecordsCompanion(
      id: id ?? this.id,
      squirrelId: squirrelId ?? this.squirrelId,
      squirrelName: squirrelName ?? this.squirrelName,
      feedingTime: feedingTime ?? this.feedingTime,
      startingWeightGrams: startingWeightGrams ?? this.startingWeightGrams,
      actualFeedAmountMl: actualFeedAmountMl ?? this.actualFeedAmountMl,
      endingWeightGrams: endingWeightGrams ?? this.endingWeightGrams,
      notes: notes ?? this.notes,
      foodType: foodType ?? this.foodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (squirrelId.present) {
      map['squirrel_id'] = Variable<String>(squirrelId.value);
    }
    if (squirrelName.present) {
      map['squirrel_name'] = Variable<String>(squirrelName.value);
    }
    if (feedingTime.present) {
      map['feeding_time'] = Variable<String>(feedingTime.value);
    }
    if (startingWeightGrams.present) {
      map['starting_weight_grams'] = Variable<double>(
        startingWeightGrams.value,
      );
    }
    if (actualFeedAmountMl.present) {
      map['actual_feed_amount_ml'] = Variable<double>(actualFeedAmountMl.value);
    }
    if (endingWeightGrams.present) {
      map['ending_weight_grams'] = Variable<double>(endingWeightGrams.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (foodType.present) {
      map['food_type'] = Variable<String>(foodType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('squirrelId: $squirrelId, ')
          ..write('squirrelName: $squirrelName, ')
          ..write('feedingTime: $feedingTime, ')
          ..write('startingWeightGrams: $startingWeightGrams, ')
          ..write('actualFeedAmountMl: $actualFeedAmountMl, ')
          ..write('endingWeightGrams: $endingWeightGrams, ')
          ..write('notes: $notes, ')
          ..write('foodType: $foodType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareNotesTable extends CareNotes
    with TableInfo<$CareNotesTable, CareNoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _squirrelIdMeta = const VerificationMeta(
    'squirrelId',
  );
  @override
  late final GeneratedColumn<String> squirrelId = GeneratedColumn<String>(
    'squirrel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES squirrels (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTypeMeta = const VerificationMeta(
    'noteType',
  );
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
    'note_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isImportantMeta = const VerificationMeta(
    'isImportant',
  );
  @override
  late final GeneratedColumn<int> isImportant = GeneratedColumn<int>(
    'is_important',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    squirrelId,
    content,
    noteType,
    photoPath,
    isImportant,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareNoteData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('squirrel_id')) {
      context.handle(
        _squirrelIdMeta,
        squirrelId.isAcceptableOrUnknown(data['squirrel_id']!, _squirrelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_squirrelIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('note_type')) {
      context.handle(
        _noteTypeMeta,
        noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_noteTypeMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('is_important')) {
      context.handle(
        _isImportantMeta,
        isImportant.isAcceptableOrUnknown(
          data['is_important']!,
          _isImportantMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareNoteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareNoteData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      squirrelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}squirrel_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      noteType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_type'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      isImportant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_important'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CareNotesTable createAlias(String alias) {
    return $CareNotesTable(attachedDatabase, alias);
  }
}

class CareNoteData extends DataClass implements Insertable<CareNoteData> {
  /// Unique identifier (UUID)
  final String id;

  /// Foreign key to squirrels table
  final String squirrelId;

  /// Content of the note
  final String content;

  /// Type/category: 'general', 'medical', 'behavior', 'feeding', 'development'
  final String noteType;

  /// Optional path to an attached photo
  final String? photoPath;

  /// Whether this note is marked as important
  final int isImportant;

  /// When this note was created (ISO 8601 string)
  final String createdAt;
  const CareNoteData({
    required this.id,
    required this.squirrelId,
    required this.content,
    required this.noteType,
    this.photoPath,
    required this.isImportant,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['squirrel_id'] = Variable<String>(squirrelId);
    map['content'] = Variable<String>(content);
    map['note_type'] = Variable<String>(noteType);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['is_important'] = Variable<int>(isImportant);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  CareNotesCompanion toCompanion(bool nullToAbsent) {
    return CareNotesCompanion(
      id: Value(id),
      squirrelId: Value(squirrelId),
      content: Value(content),
      noteType: Value(noteType),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      isImportant: Value(isImportant),
      createdAt: Value(createdAt),
    );
  }

  factory CareNoteData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareNoteData(
      id: serializer.fromJson<String>(json['id']),
      squirrelId: serializer.fromJson<String>(json['squirrelId']),
      content: serializer.fromJson<String>(json['content']),
      noteType: serializer.fromJson<String>(json['noteType']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      isImportant: serializer.fromJson<int>(json['isImportant']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'squirrelId': serializer.toJson<String>(squirrelId),
      'content': serializer.toJson<String>(content),
      'noteType': serializer.toJson<String>(noteType),
      'photoPath': serializer.toJson<String?>(photoPath),
      'isImportant': serializer.toJson<int>(isImportant),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  CareNoteData copyWith({
    String? id,
    String? squirrelId,
    String? content,
    String? noteType,
    Value<String?> photoPath = const Value.absent(),
    int? isImportant,
    String? createdAt,
  }) => CareNoteData(
    id: id ?? this.id,
    squirrelId: squirrelId ?? this.squirrelId,
    content: content ?? this.content,
    noteType: noteType ?? this.noteType,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    isImportant: isImportant ?? this.isImportant,
    createdAt: createdAt ?? this.createdAt,
  );
  CareNoteData copyWithCompanion(CareNotesCompanion data) {
    return CareNoteData(
      id: data.id.present ? data.id.value : this.id,
      squirrelId: data.squirrelId.present
          ? data.squirrelId.value
          : this.squirrelId,
      content: data.content.present ? data.content.value : this.content,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      isImportant: data.isImportant.present
          ? data.isImportant.value
          : this.isImportant,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareNoteData(')
          ..write('id: $id, ')
          ..write('squirrelId: $squirrelId, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('photoPath: $photoPath, ')
          ..write('isImportant: $isImportant, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    squirrelId,
    content,
    noteType,
    photoPath,
    isImportant,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareNoteData &&
          other.id == this.id &&
          other.squirrelId == this.squirrelId &&
          other.content == this.content &&
          other.noteType == this.noteType &&
          other.photoPath == this.photoPath &&
          other.isImportant == this.isImportant &&
          other.createdAt == this.createdAt);
}

class CareNotesCompanion extends UpdateCompanion<CareNoteData> {
  final Value<String> id;
  final Value<String> squirrelId;
  final Value<String> content;
  final Value<String> noteType;
  final Value<String?> photoPath;
  final Value<int> isImportant;
  final Value<String> createdAt;
  final Value<int> rowid;
  const CareNotesCompanion({
    this.id = const Value.absent(),
    this.squirrelId = const Value.absent(),
    this.content = const Value.absent(),
    this.noteType = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.isImportant = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareNotesCompanion.insert({
    required String id,
    required String squirrelId,
    required String content,
    required String noteType,
    this.photoPath = const Value.absent(),
    this.isImportant = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       squirrelId = Value(squirrelId),
       content = Value(content),
       noteType = Value(noteType),
       createdAt = Value(createdAt);
  static Insertable<CareNoteData> custom({
    Expression<String>? id,
    Expression<String>? squirrelId,
    Expression<String>? content,
    Expression<String>? noteType,
    Expression<String>? photoPath,
    Expression<int>? isImportant,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (squirrelId != null) 'squirrel_id': squirrelId,
      if (content != null) 'content': content,
      if (noteType != null) 'note_type': noteType,
      if (photoPath != null) 'photo_path': photoPath,
      if (isImportant != null) 'is_important': isImportant,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? squirrelId,
    Value<String>? content,
    Value<String>? noteType,
    Value<String?>? photoPath,
    Value<int>? isImportant,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return CareNotesCompanion(
      id: id ?? this.id,
      squirrelId: squirrelId ?? this.squirrelId,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      photoPath: photoPath ?? this.photoPath,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (squirrelId.present) {
      map['squirrel_id'] = Variable<String>(squirrelId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (isImportant.present) {
      map['is_important'] = Variable<int>(isImportant.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareNotesCompanion(')
          ..write('id: $id, ')
          ..write('squirrelId: $squirrelId, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('photoPath: $photoPath, ')
          ..write('isImportant: $isImportant, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SquirrelsTable squirrels = $SquirrelsTable(this);
  late final $FeedingRecordsTable feedingRecords = $FeedingRecordsTable(this);
  late final $CareNotesTable careNotes = $CareNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    squirrels,
    feedingRecords,
    careNotes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'squirrels',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feeding_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'squirrels',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('care_notes', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SquirrelsTableCreateCompanionBuilder =
    SquirrelsCompanion Function({
      required String id,
      required String name,
      required String foundDate,
      Value<double?> admissionWeight,
      Value<double?> currentWeight,
      Value<String> status,
      Value<String> developmentStage,
      Value<String?> notes,
      Value<String?> photoPath,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$SquirrelsTableUpdateCompanionBuilder =
    SquirrelsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> foundDate,
      Value<double?> admissionWeight,
      Value<double?> currentWeight,
      Value<String> status,
      Value<String> developmentStage,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$SquirrelsTableReferences
    extends BaseReferences<_$AppDatabase, $SquirrelsTable, SquirrelData> {
  $$SquirrelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FeedingRecordsTable, List<FeedingRecordData>>
  _feedingRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedingRecords,
    aliasName: $_aliasNameGenerator(
      db.squirrels.id,
      db.feedingRecords.squirrelId,
    ),
  );

  $$FeedingRecordsTableProcessedTableManager get feedingRecordsRefs {
    final manager = $$FeedingRecordsTableTableManager(
      $_db,
      $_db.feedingRecords,
    ).filter((f) => f.squirrelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedingRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CareNotesTable, List<CareNoteData>>
  _careNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.careNotes,
    aliasName: $_aliasNameGenerator(db.squirrels.id, db.careNotes.squirrelId),
  );

  $$CareNotesTableProcessedTableManager get careNotesRefs {
    final manager = $$CareNotesTableTableManager(
      $_db,
      $_db.careNotes,
    ).filter((f) => f.squirrelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_careNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SquirrelsTableFilterComposer
    extends Composer<_$AppDatabase, $SquirrelsTable> {
  $$SquirrelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foundDate => $composableBuilder(
    column: $table.foundDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get admissionWeight => $composableBuilder(
    column: $table.admissionWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get developmentStage => $composableBuilder(
    column: $table.developmentStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> feedingRecordsRefs(
    Expression<bool> Function($$FeedingRecordsTableFilterComposer f) f,
  ) {
    final $$FeedingRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingRecords,
      getReferencedColumn: (t) => t.squirrelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingRecordsTableFilterComposer(
            $db: $db,
            $table: $db.feedingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> careNotesRefs(
    Expression<bool> Function($$CareNotesTableFilterComposer f) f,
  ) {
    final $$CareNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careNotes,
      getReferencedColumn: (t) => t.squirrelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareNotesTableFilterComposer(
            $db: $db,
            $table: $db.careNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SquirrelsTableOrderingComposer
    extends Composer<_$AppDatabase, $SquirrelsTable> {
  $$SquirrelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foundDate => $composableBuilder(
    column: $table.foundDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get admissionWeight => $composableBuilder(
    column: $table.admissionWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get developmentStage => $composableBuilder(
    column: $table.developmentStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SquirrelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SquirrelsTable> {
  $$SquirrelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get foundDate =>
      $composableBuilder(column: $table.foundDate, builder: (column) => column);

  GeneratedColumn<double> get admissionWeight => $composableBuilder(
    column: $table.admissionWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentWeight => $composableBuilder(
    column: $table.currentWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get developmentStage => $composableBuilder(
    column: $table.developmentStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> feedingRecordsRefs<T extends Object>(
    Expression<T> Function($$FeedingRecordsTableAnnotationComposer a) f,
  ) {
    final $$FeedingRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feedingRecords,
      getReferencedColumn: (t) => t.squirrelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedingRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.feedingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> careNotesRefs<T extends Object>(
    Expression<T> Function($$CareNotesTableAnnotationComposer a) f,
  ) {
    final $$CareNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careNotes,
      getReferencedColumn: (t) => t.squirrelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.careNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SquirrelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SquirrelsTable,
          SquirrelData,
          $$SquirrelsTableFilterComposer,
          $$SquirrelsTableOrderingComposer,
          $$SquirrelsTableAnnotationComposer,
          $$SquirrelsTableCreateCompanionBuilder,
          $$SquirrelsTableUpdateCompanionBuilder,
          (SquirrelData, $$SquirrelsTableReferences),
          SquirrelData,
          PrefetchHooks Function({bool feedingRecordsRefs, bool careNotesRefs})
        > {
  $$SquirrelsTableTableManager(_$AppDatabase db, $SquirrelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SquirrelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SquirrelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SquirrelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> foundDate = const Value.absent(),
                Value<double?> admissionWeight = const Value.absent(),
                Value<double?> currentWeight = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> developmentStage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SquirrelsCompanion(
                id: id,
                name: name,
                foundDate: foundDate,
                admissionWeight: admissionWeight,
                currentWeight: currentWeight,
                status: status,
                developmentStage: developmentStage,
                notes: notes,
                photoPath: photoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String foundDate,
                Value<double?> admissionWeight = const Value.absent(),
                Value<double?> currentWeight = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> developmentStage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SquirrelsCompanion.insert(
                id: id,
                name: name,
                foundDate: foundDate,
                admissionWeight: admissionWeight,
                currentWeight: currentWeight,
                status: status,
                developmentStage: developmentStage,
                notes: notes,
                photoPath: photoPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SquirrelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({feedingRecordsRefs = false, careNotesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (feedingRecordsRefs) db.feedingRecords,
                    if (careNotesRefs) db.careNotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (feedingRecordsRefs)
                        await $_getPrefetchedData<
                          SquirrelData,
                          $SquirrelsTable,
                          FeedingRecordData
                        >(
                          currentTable: table,
                          referencedTable: $$SquirrelsTableReferences
                              ._feedingRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SquirrelsTableReferences(
                                db,
                                table,
                                p0,
                              ).feedingRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.squirrelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (careNotesRefs)
                        await $_getPrefetchedData<
                          SquirrelData,
                          $SquirrelsTable,
                          CareNoteData
                        >(
                          currentTable: table,
                          referencedTable: $$SquirrelsTableReferences
                              ._careNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SquirrelsTableReferences(
                                db,
                                table,
                                p0,
                              ).careNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.squirrelId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SquirrelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SquirrelsTable,
      SquirrelData,
      $$SquirrelsTableFilterComposer,
      $$SquirrelsTableOrderingComposer,
      $$SquirrelsTableAnnotationComposer,
      $$SquirrelsTableCreateCompanionBuilder,
      $$SquirrelsTableUpdateCompanionBuilder,
      (SquirrelData, $$SquirrelsTableReferences),
      SquirrelData,
      PrefetchHooks Function({bool feedingRecordsRefs, bool careNotesRefs})
    >;
typedef $$FeedingRecordsTableCreateCompanionBuilder =
    FeedingRecordsCompanion Function({
      required String id,
      required String squirrelId,
      required String squirrelName,
      required String feedingTime,
      required double startingWeightGrams,
      Value<double?> actualFeedAmountMl,
      Value<double?> endingWeightGrams,
      Value<String?> notes,
      Value<String> foodType,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$FeedingRecordsTableUpdateCompanionBuilder =
    FeedingRecordsCompanion Function({
      Value<String> id,
      Value<String> squirrelId,
      Value<String> squirrelName,
      Value<String> feedingTime,
      Value<double> startingWeightGrams,
      Value<double?> actualFeedAmountMl,
      Value<double?> endingWeightGrams,
      Value<String?> notes,
      Value<String> foodType,
      Value<String?> createdAt,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

final class $$FeedingRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $FeedingRecordsTable, FeedingRecordData> {
  $$FeedingRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SquirrelsTable _squirrelIdTable(_$AppDatabase db) =>
      db.squirrels.createAlias(
        $_aliasNameGenerator(db.feedingRecords.squirrelId, db.squirrels.id),
      );

  $$SquirrelsTableProcessedTableManager get squirrelId {
    final $_column = $_itemColumn<String>('squirrel_id')!;

    final manager = $$SquirrelsTableTableManager(
      $_db,
      $_db.squirrels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_squirrelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FeedingRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedingRecordsTable> {
  $$FeedingRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get squirrelName => $composableBuilder(
    column: $table.squirrelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedingTime => $composableBuilder(
    column: $table.feedingTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startingWeightGrams => $composableBuilder(
    column: $table.startingWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualFeedAmountMl => $composableBuilder(
    column: $table.actualFeedAmountMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endingWeightGrams => $composableBuilder(
    column: $table.endingWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodType => $composableBuilder(
    column: $table.foodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SquirrelsTableFilterComposer get squirrelId {
    final $$SquirrelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableFilterComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedingRecordsTable> {
  $$FeedingRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get squirrelName => $composableBuilder(
    column: $table.squirrelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedingTime => $composableBuilder(
    column: $table.feedingTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startingWeightGrams => $composableBuilder(
    column: $table.startingWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualFeedAmountMl => $composableBuilder(
    column: $table.actualFeedAmountMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endingWeightGrams => $composableBuilder(
    column: $table.endingWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodType => $composableBuilder(
    column: $table.foodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SquirrelsTableOrderingComposer get squirrelId {
    final $$SquirrelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableOrderingComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedingRecordsTable> {
  $$FeedingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get squirrelName => $composableBuilder(
    column: $table.squirrelName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedingTime => $composableBuilder(
    column: $table.feedingTime,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startingWeightGrams => $composableBuilder(
    column: $table.startingWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualFeedAmountMl => $composableBuilder(
    column: $table.actualFeedAmountMl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endingWeightGrams => $composableBuilder(
    column: $table.endingWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get foodType =>
      $composableBuilder(column: $table.foodType, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SquirrelsTableAnnotationComposer get squirrelId {
    final $$SquirrelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableAnnotationComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedingRecordsTable,
          FeedingRecordData,
          $$FeedingRecordsTableFilterComposer,
          $$FeedingRecordsTableOrderingComposer,
          $$FeedingRecordsTableAnnotationComposer,
          $$FeedingRecordsTableCreateCompanionBuilder,
          $$FeedingRecordsTableUpdateCompanionBuilder,
          (FeedingRecordData, $$FeedingRecordsTableReferences),
          FeedingRecordData,
          PrefetchHooks Function({bool squirrelId})
        > {
  $$FeedingRecordsTableTableManager(
    _$AppDatabase db,
    $FeedingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> squirrelId = const Value.absent(),
                Value<String> squirrelName = const Value.absent(),
                Value<String> feedingTime = const Value.absent(),
                Value<double> startingWeightGrams = const Value.absent(),
                Value<double?> actualFeedAmountMl = const Value.absent(),
                Value<double?> endingWeightGrams = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> foodType = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedingRecordsCompanion(
                id: id,
                squirrelId: squirrelId,
                squirrelName: squirrelName,
                feedingTime: feedingTime,
                startingWeightGrams: startingWeightGrams,
                actualFeedAmountMl: actualFeedAmountMl,
                endingWeightGrams: endingWeightGrams,
                notes: notes,
                foodType: foodType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String squirrelId,
                required String squirrelName,
                required String feedingTime,
                required double startingWeightGrams,
                Value<double?> actualFeedAmountMl = const Value.absent(),
                Value<double?> endingWeightGrams = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> foodType = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedingRecordsCompanion.insert(
                id: id,
                squirrelId: squirrelId,
                squirrelName: squirrelName,
                feedingTime: feedingTime,
                startingWeightGrams: startingWeightGrams,
                actualFeedAmountMl: actualFeedAmountMl,
                endingWeightGrams: endingWeightGrams,
                notes: notes,
                foodType: foodType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FeedingRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({squirrelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (squirrelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.squirrelId,
                                referencedTable: $$FeedingRecordsTableReferences
                                    ._squirrelIdTable(db),
                                referencedColumn:
                                    $$FeedingRecordsTableReferences
                                        ._squirrelIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FeedingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedingRecordsTable,
      FeedingRecordData,
      $$FeedingRecordsTableFilterComposer,
      $$FeedingRecordsTableOrderingComposer,
      $$FeedingRecordsTableAnnotationComposer,
      $$FeedingRecordsTableCreateCompanionBuilder,
      $$FeedingRecordsTableUpdateCompanionBuilder,
      (FeedingRecordData, $$FeedingRecordsTableReferences),
      FeedingRecordData,
      PrefetchHooks Function({bool squirrelId})
    >;
typedef $$CareNotesTableCreateCompanionBuilder =
    CareNotesCompanion Function({
      required String id,
      required String squirrelId,
      required String content,
      required String noteType,
      Value<String?> photoPath,
      Value<int> isImportant,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$CareNotesTableUpdateCompanionBuilder =
    CareNotesCompanion Function({
      Value<String> id,
      Value<String> squirrelId,
      Value<String> content,
      Value<String> noteType,
      Value<String?> photoPath,
      Value<int> isImportant,
      Value<String> createdAt,
      Value<int> rowid,
    });

final class $$CareNotesTableReferences
    extends BaseReferences<_$AppDatabase, $CareNotesTable, CareNoteData> {
  $$CareNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SquirrelsTable _squirrelIdTable(_$AppDatabase db) =>
      db.squirrels.createAlias(
        $_aliasNameGenerator(db.careNotes.squirrelId, db.squirrels.id),
      );

  $$SquirrelsTableProcessedTableManager get squirrelId {
    final $_column = $_itemColumn<String>('squirrel_id')!;

    final manager = $$SquirrelsTableTableManager(
      $_db,
      $_db.squirrels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_squirrelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CareNotesTableFilterComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SquirrelsTableFilterComposer get squirrelId {
    final $$SquirrelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableFilterComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteType => $composableBuilder(
    column: $table.noteType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SquirrelsTableOrderingComposer get squirrelId {
    final $$SquirrelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableOrderingComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareNotesTable> {
  $$CareNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get isImportant => $composableBuilder(
    column: $table.isImportant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SquirrelsTableAnnotationComposer get squirrelId {
    final $$SquirrelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.squirrelId,
      referencedTable: $db.squirrels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SquirrelsTableAnnotationComposer(
            $db: $db,
            $table: $db.squirrels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareNotesTable,
          CareNoteData,
          $$CareNotesTableFilterComposer,
          $$CareNotesTableOrderingComposer,
          $$CareNotesTableAnnotationComposer,
          $$CareNotesTableCreateCompanionBuilder,
          $$CareNotesTableUpdateCompanionBuilder,
          (CareNoteData, $$CareNotesTableReferences),
          CareNoteData,
          PrefetchHooks Function({bool squirrelId})
        > {
  $$CareNotesTableTableManager(_$AppDatabase db, $CareNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> squirrelId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> noteType = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> isImportant = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareNotesCompanion(
                id: id,
                squirrelId: squirrelId,
                content: content,
                noteType: noteType,
                photoPath: photoPath,
                isImportant: isImportant,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String squirrelId,
                required String content,
                required String noteType,
                Value<String?> photoPath = const Value.absent(),
                Value<int> isImportant = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CareNotesCompanion.insert(
                id: id,
                squirrelId: squirrelId,
                content: content,
                noteType: noteType,
                photoPath: photoPath,
                isImportant: isImportant,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CareNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({squirrelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (squirrelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.squirrelId,
                                referencedTable: $$CareNotesTableReferences
                                    ._squirrelIdTable(db),
                                referencedColumn: $$CareNotesTableReferences
                                    ._squirrelIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CareNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareNotesTable,
      CareNoteData,
      $$CareNotesTableFilterComposer,
      $$CareNotesTableOrderingComposer,
      $$CareNotesTableAnnotationComposer,
      $$CareNotesTableCreateCompanionBuilder,
      $$CareNotesTableUpdateCompanionBuilder,
      (CareNoteData, $$CareNotesTableReferences),
      CareNoteData,
      PrefetchHooks Function({bool squirrelId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SquirrelsTableTableManager get squirrels =>
      $$SquirrelsTableTableManager(_db, _db.squirrels);
  $$FeedingRecordsTableTableManager get feedingRecords =>
      $$FeedingRecordsTableTableManager(_db, _db.feedingRecords);
  $$CareNotesTableTableManager get careNotes =>
      $$CareNotesTableTableManager(_db, _db.careNotes);
}
