// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MemoryObjectsTable extends MemoryObjects
    with TableInfo<$MemoryObjectsTable, MemoryObjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryObjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmationStatusMeta =
      const VerificationMeta('confirmationStatus');
  @override
  late final GeneratedColumn<int> confirmationStatus = GeneratedColumn<int>(
    'confirmation_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensitivityMeta = const VerificationMeta(
    'sensitivity',
  );
  @override
  late final GeneratedColumn<int> sensitivity = GeneratedColumn<int>(
    'sensitivity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _structuredDataMeta = const VerificationMeta(
    'structuredData',
  );
  @override
  late final GeneratedColumn<String> structuredData = GeneratedColumn<String>(
    'structured_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceUriMeta = const VerificationMeta(
    'sourceUri',
  );
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
    'source_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    category,
    sourceType,
    createdAt,
    updatedAt,
    eventDate,
    confidenceScore,
    confirmationStatus,
    sensitivity,
    structuredData,
    archived,
    sourceUri,
    rawText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_objects';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryObjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
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
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    }
    if (data.containsKey('confirmation_status')) {
      context.handle(
        _confirmationStatusMeta,
        confirmationStatus.isAcceptableOrUnknown(
          data['confirmation_status']!,
          _confirmationStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmationStatusMeta);
    }
    if (data.containsKey('sensitivity')) {
      context.handle(
        _sensitivityMeta,
        sensitivity.isAcceptableOrUnknown(
          data['sensitivity']!,
          _sensitivityMeta,
        ),
      );
    }
    if (data.containsKey('structured_data')) {
      context.handle(
        _structuredDataMeta,
        structuredData.isAcceptableOrUnknown(
          data['structured_data']!,
          _structuredDataMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('source_uri')) {
      context.handle(
        _sourceUriMeta,
        sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryObjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryObjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      ),
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_score'],
      ),
      confirmationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmation_status'],
      )!,
      sensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sensitivity'],
      )!,
      structuredData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structured_data'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sourceUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uri'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
    );
  }

  @override
  $MemoryObjectsTable createAlias(String alias) {
    return $MemoryObjectsTable(attachedDatabase, alias);
  }
}

class MemoryObjectRow extends DataClass implements Insertable<MemoryObjectRow> {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String sourceType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? eventDate;
  final double? confidenceScore;

  /// Stored as an int index into ConfirmationStatus — see
  /// domain/entities/memory_object.dart for the enum this mirrors.
  final int confirmationStatus;
  final int sensitivity;

  /// JSON-encoded Map<String, Object?> — category-specific fields.
  final String structuredData;
  final bool archived;

  /// Local filesystem path to the captured image, if any (Phase C).
  final String? sourceUri;

  /// Verbatim OCR output (Phase D). Untrusted input — see
  /// docs/SECURITY.md.
  final String? rawText;
  const MemoryObjectRow({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.sourceType,
    required this.createdAt,
    required this.updatedAt,
    this.eventDate,
    this.confidenceScore,
    required this.confirmationStatus,
    required this.sensitivity,
    required this.structuredData,
    required this.archived,
    this.sourceUri,
    this.rawText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    map['source_type'] = Variable<String>(sourceType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || eventDate != null) {
      map['event_date'] = Variable<DateTime>(eventDate);
    }
    if (!nullToAbsent || confidenceScore != null) {
      map['confidence_score'] = Variable<double>(confidenceScore);
    }
    map['confirmation_status'] = Variable<int>(confirmationStatus);
    map['sensitivity'] = Variable<int>(sensitivity);
    map['structured_data'] = Variable<String>(structuredData);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || sourceUri != null) {
      map['source_uri'] = Variable<String>(sourceUri);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    return map;
  }

  MemoryObjectsCompanion toCompanion(bool nullToAbsent) {
    return MemoryObjectsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      sourceType: Value(sourceType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      eventDate: eventDate == null && nullToAbsent
          ? const Value.absent()
          : Value(eventDate),
      confidenceScore: confidenceScore == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceScore),
      confirmationStatus: Value(confirmationStatus),
      sensitivity: Value(sensitivity),
      structuredData: Value(structuredData),
      archived: Value(archived),
      sourceUri: sourceUri == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUri),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
    );
  }

  factory MemoryObjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryObjectRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      eventDate: serializer.fromJson<DateTime?>(json['eventDate']),
      confidenceScore: serializer.fromJson<double?>(json['confidenceScore']),
      confirmationStatus: serializer.fromJson<int>(json['confirmationStatus']),
      sensitivity: serializer.fromJson<int>(json['sensitivity']),
      structuredData: serializer.fromJson<String>(json['structuredData']),
      archived: serializer.fromJson<bool>(json['archived']),
      sourceUri: serializer.fromJson<String?>(json['sourceUri']),
      rawText: serializer.fromJson<String?>(json['rawText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'sourceType': serializer.toJson<String>(sourceType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'eventDate': serializer.toJson<DateTime?>(eventDate),
      'confidenceScore': serializer.toJson<double?>(confidenceScore),
      'confirmationStatus': serializer.toJson<int>(confirmationStatus),
      'sensitivity': serializer.toJson<int>(sensitivity),
      'structuredData': serializer.toJson<String>(structuredData),
      'archived': serializer.toJson<bool>(archived),
      'sourceUri': serializer.toJson<String?>(sourceUri),
      'rawText': serializer.toJson<String?>(rawText),
    };
  }

  MemoryObjectRow copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? category,
    String? sourceType,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> eventDate = const Value.absent(),
    Value<double?> confidenceScore = const Value.absent(),
    int? confirmationStatus,
    int? sensitivity,
    String? structuredData,
    bool? archived,
    Value<String?> sourceUri = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
  }) => MemoryObjectRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category ?? this.category,
    sourceType: sourceType ?? this.sourceType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    eventDate: eventDate.present ? eventDate.value : this.eventDate,
    confidenceScore: confidenceScore.present
        ? confidenceScore.value
        : this.confidenceScore,
    confirmationStatus: confirmationStatus ?? this.confirmationStatus,
    sensitivity: sensitivity ?? this.sensitivity,
    structuredData: structuredData ?? this.structuredData,
    archived: archived ?? this.archived,
    sourceUri: sourceUri.present ? sourceUri.value : this.sourceUri,
    rawText: rawText.present ? rawText.value : this.rawText,
  );
  MemoryObjectRow copyWithCompanion(MemoryObjectsCompanion data) {
    return MemoryObjectRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      confirmationStatus: data.confirmationStatus.present
          ? data.confirmationStatus.value
          : this.confirmationStatus,
      sensitivity: data.sensitivity.present
          ? data.sensitivity.value
          : this.sensitivity,
      structuredData: data.structuredData.present
          ? data.structuredData.value
          : this.structuredData,
      archived: data.archived.present ? data.archived.value : this.archived,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryObjectRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('sourceType: $sourceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('eventDate: $eventDate, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('confirmationStatus: $confirmationStatus, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('structuredData: $structuredData, ')
          ..write('archived: $archived, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    sourceType,
    createdAt,
    updatedAt,
    eventDate,
    confidenceScore,
    confirmationStatus,
    sensitivity,
    structuredData,
    archived,
    sourceUri,
    rawText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryObjectRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.sourceType == this.sourceType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.eventDate == this.eventDate &&
          other.confidenceScore == this.confidenceScore &&
          other.confirmationStatus == this.confirmationStatus &&
          other.sensitivity == this.sensitivity &&
          other.structuredData == this.structuredData &&
          other.archived == this.archived &&
          other.sourceUri == this.sourceUri &&
          other.rawText == this.rawText);
}

class MemoryObjectsCompanion extends UpdateCompanion<MemoryObjectRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> category;
  final Value<String> sourceType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> eventDate;
  final Value<double?> confidenceScore;
  final Value<int> confirmationStatus;
  final Value<int> sensitivity;
  final Value<String> structuredData;
  final Value<bool> archived;
  final Value<String?> sourceUri;
  final Value<String?> rawText;
  final Value<int> rowid;
  const MemoryObjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.confirmationStatus = const Value.absent(),
    this.sensitivity = const Value.absent(),
    this.structuredData = const Value.absent(),
    this.archived = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.rawText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryObjectsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String category,
    required String sourceType,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.eventDate = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    required int confirmationStatus,
    this.sensitivity = const Value.absent(),
    this.structuredData = const Value.absent(),
    this.archived = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.rawText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       sourceType = Value(sourceType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       confirmationStatus = Value(confirmationStatus);
  static Insertable<MemoryObjectRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? sourceType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? eventDate,
    Expression<double>? confidenceScore,
    Expression<int>? confirmationStatus,
    Expression<int>? sensitivity,
    Expression<String>? structuredData,
    Expression<bool>? archived,
    Expression<String>? sourceUri,
    Expression<String>? rawText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (sourceType != null) 'source_type': sourceType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (eventDate != null) 'event_date': eventDate,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (confirmationStatus != null) 'confirmation_status': confirmationStatus,
      if (sensitivity != null) 'sensitivity': sensitivity,
      if (structuredData != null) 'structured_data': structuredData,
      if (archived != null) 'archived': archived,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (rawText != null) 'raw_text': rawText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryObjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? category,
    Value<String>? sourceType,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? eventDate,
    Value<double?>? confidenceScore,
    Value<int>? confirmationStatus,
    Value<int>? sensitivity,
    Value<String>? structuredData,
    Value<bool>? archived,
    Value<String?>? sourceUri,
    Value<String?>? rawText,
    Value<int>? rowid,
  }) {
    return MemoryObjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventDate: eventDate ?? this.eventDate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
      sensitivity: sensitivity ?? this.sensitivity,
      structuredData: structuredData ?? this.structuredData,
      archived: archived ?? this.archived,
      sourceUri: sourceUri ?? this.sourceUri,
      rawText: rawText ?? this.rawText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (confirmationStatus.present) {
      map['confirmation_status'] = Variable<int>(confirmationStatus.value);
    }
    if (sensitivity.present) {
      map['sensitivity'] = Variable<int>(sensitivity.value);
    }
    if (structuredData.present) {
      map['structured_data'] = Variable<String>(structuredData.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryObjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('sourceType: $sourceType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('eventDate: $eventDate, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('confirmationStatus: $confirmationStatus, ')
          ..write('sensitivity: $sensitivity, ')
          ..write('structuredData: $structuredData, ')
          ..write('archived: $archived, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('rawText: $rawText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_objects (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerTimeMeta = const VerificationMeta(
    'triggerTime',
  );
  @override
  late final GeneratedColumn<DateTime> triggerTime = GeneratedColumn<DateTime>(
    'trigger_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysBeforeMeta = const VerificationMeta(
    'daysBefore',
  );
  @override
  late final GeneratedColumn<int> daysBefore = GeneratedColumn<int>(
    'days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId,
    triggerTime,
    timezone,
    status,
    createdAt,
    daysBefore,
    notificationId,
    acknowledgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('trigger_time')) {
      context.handle(
        _triggerTimeMeta,
        triggerTime.isAcceptableOrUnknown(
          data['trigger_time']!,
          _triggerTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTimeMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('days_before')) {
      context.handle(
        _daysBeforeMeta,
        daysBefore.isAcceptableOrUnknown(data['days_before']!, _daysBeforeMeta),
      );
    } else if (isInserting) {
      context.missing(_daysBeforeMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      triggerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trigger_time'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      daysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_before'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;

  /// `onDelete: KeyAction.cascade` so deleting a memory cannot leave
  /// reminders pointing at a row that no longer exists. Enforced only
  /// because `PRAGMA foreign_keys = ON` is set in beforeOpen.
  final String memoryId;
  final DateTime triggerTime;
  final String timezone;
  final int status;
  final DateTime createdAt;
  final int daysBefore;

  /// Stable platform notification id, so a reminder can still be
  /// cancelled after an app restart.
  final int notificationId;

  /// Set only when the user taps the notification — the sole delivery
  /// signal the platform provides. There is deliberately no
  /// `deliveredAt`: nothing could set it truthfully. See
  /// domain/entities/reminder.dart.
  final DateTime? acknowledgedAt;
  const ReminderRow({
    required this.id,
    required this.memoryId,
    required this.triggerTime,
    required this.timezone,
    required this.status,
    required this.createdAt,
    required this.daysBefore,
    required this.notificationId,
    this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['trigger_time'] = Variable<DateTime>(triggerTime);
    map['timezone'] = Variable<String>(timezone);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['days_before'] = Variable<int>(daysBefore);
    map['notification_id'] = Variable<int>(notificationId);
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      triggerTime: Value(triggerTime),
      timezone: Value(timezone),
      status: Value(status),
      createdAt: Value(createdAt),
      daysBefore: Value(daysBefore),
      notificationId: Value(notificationId),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      triggerTime: serializer.fromJson<DateTime>(json['triggerTime']),
      timezone: serializer.fromJson<String>(json['timezone']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      daysBefore: serializer.fromJson<int>(json['daysBefore']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      acknowledgedAt: serializer.fromJson<DateTime?>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'triggerTime': serializer.toJson<DateTime>(triggerTime),
      'timezone': serializer.toJson<String>(timezone),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'daysBefore': serializer.toJson<int>(daysBefore),
      'notificationId': serializer.toJson<int>(notificationId),
      'acknowledgedAt': serializer.toJson<DateTime?>(acknowledgedAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? memoryId,
    DateTime? triggerTime,
    String? timezone,
    int? status,
    DateTime? createdAt,
    int? daysBefore,
    int? notificationId,
    Value<DateTime?> acknowledgedAt = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    triggerTime: triggerTime ?? this.triggerTime,
    timezone: timezone ?? this.timezone,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    daysBefore: daysBefore ?? this.daysBefore,
    notificationId: notificationId ?? this.notificationId,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      triggerTime: data.triggerTime.present
          ? data.triggerTime.value
          : this.triggerTime,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      daysBefore: data.daysBefore.present
          ? data.daysBefore.value
          : this.daysBefore,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('triggerTime: $triggerTime, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('notificationId: $notificationId, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memoryId,
    triggerTime,
    timezone,
    status,
    createdAt,
    daysBefore,
    notificationId,
    acknowledgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.triggerTime == this.triggerTime &&
          other.timezone == this.timezone &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.daysBefore == this.daysBefore &&
          other.notificationId == this.notificationId &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<DateTime> triggerTime;
  final Value<String> timezone;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<int> daysBefore;
  final Value<int> notificationId;
  final Value<DateTime?> acknowledgedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.triggerTime = const Value.absent(),
    this.timezone = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.daysBefore = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String memoryId,
    required DateTime triggerTime,
    required String timezone,
    required int status,
    required DateTime createdAt,
    required int daysBefore,
    required int notificationId,
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoryId = Value(memoryId),
       triggerTime = Value(triggerTime),
       timezone = Value(timezone),
       status = Value(status),
       createdAt = Value(createdAt),
       daysBefore = Value(daysBefore),
       notificationId = Value(notificationId);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<DateTime>? triggerTime,
    Expression<String>? timezone,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? daysBefore,
    Expression<int>? notificationId,
    Expression<DateTime>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (triggerTime != null) 'trigger_time': triggerTime,
      if (timezone != null) 'timezone': timezone,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (daysBefore != null) 'days_before': daysBefore,
      if (notificationId != null) 'notification_id': notificationId,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? memoryId,
    Value<DateTime>? triggerTime,
    Value<String>? timezone,
    Value<int>? status,
    Value<DateTime>? createdAt,
    Value<int>? daysBefore,
    Value<int>? notificationId,
    Value<DateTime?>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      triggerTime: triggerTime ?? this.triggerTime,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      daysBefore: daysBefore ?? this.daysBefore,
      notificationId: notificationId ?? this.notificationId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (triggerTime.present) {
      map['trigger_time'] = Variable<DateTime>(triggerTime.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (daysBefore.present) {
      map['days_before'] = Variable<int>(daysBefore.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('triggerTime: $triggerTime, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('notificationId: $notificationId, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MemoryObjectsTable memoryObjects = $MemoryObjectsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    memoryObjects,
    reminders,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memory_objects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MemoryObjectsTableCreateCompanionBuilder =
    MemoryObjectsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required String category,
      required String sourceType,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> eventDate,
      Value<double?> confidenceScore,
      required int confirmationStatus,
      Value<int> sensitivity,
      Value<String> structuredData,
      Value<bool> archived,
      Value<String?> sourceUri,
      Value<String?> rawText,
      Value<int> rowid,
    });
typedef $$MemoryObjectsTableUpdateCompanionBuilder =
    MemoryObjectsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String> category,
      Value<String> sourceType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> eventDate,
      Value<double?> confidenceScore,
      Value<int> confirmationStatus,
      Value<int> sensitivity,
      Value<String> structuredData,
      Value<bool> archived,
      Value<String?> sourceUri,
      Value<String?> rawText,
      Value<int> rowid,
    });

final class $$MemoryObjectsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MemoryObjectsTable, MemoryObjectRow> {
  $$MemoryObjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'memory_objects__id__reminders__memory_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.memoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryObjectsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryObjectsTable> {
  $$MemoryObjectsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmationStatus => $composableBuilder(
    column: $table.confirmationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structuredData => $composableBuilder(
    column: $table.structuredData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryObjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryObjectsTable> {
  $$MemoryObjectsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmationStatus => $composableBuilder(
    column: $table.confirmationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structuredData => $composableBuilder(
    column: $table.structuredData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryObjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryObjectsTable> {
  $$MemoryObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confirmationStatus => $composableBuilder(
    column: $table.confirmationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sensitivity => $composableBuilder(
    column: $table.sensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structuredData => $composableBuilder(
    column: $table.structuredData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.memoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryObjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryObjectsTable,
          MemoryObjectRow,
          $$MemoryObjectsTableFilterComposer,
          $$MemoryObjectsTableOrderingComposer,
          $$MemoryObjectsTableAnnotationComposer,
          $$MemoryObjectsTableCreateCompanionBuilder,
          $$MemoryObjectsTableUpdateCompanionBuilder,
          (MemoryObjectRow, $$MemoryObjectsTableReferences),
          MemoryObjectRow,
          PrefetchHooks Function({bool remindersRefs})
        > {
  $$MemoryObjectsTableTableManager(_$AppDatabase db, $MemoryObjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryObjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryObjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryObjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> eventDate = const Value.absent(),
                Value<double?> confidenceScore = const Value.absent(),
                Value<int> confirmationStatus = const Value.absent(),
                Value<int> sensitivity = const Value.absent(),
                Value<String> structuredData = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> sourceUri = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryObjectsCompanion(
                id: id,
                title: title,
                description: description,
                category: category,
                sourceType: sourceType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                eventDate: eventDate,
                confidenceScore: confidenceScore,
                confirmationStatus: confirmationStatus,
                sensitivity: sensitivity,
                structuredData: structuredData,
                archived: archived,
                sourceUri: sourceUri,
                rawText: rawText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required String category,
                required String sourceType,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> eventDate = const Value.absent(),
                Value<double?> confidenceScore = const Value.absent(),
                required int confirmationStatus,
                Value<int> sensitivity = const Value.absent(),
                Value<String> structuredData = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> sourceUri = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryObjectsCompanion.insert(
                id: id,
                title: title,
                description: description,
                category: category,
                sourceType: sourceType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                eventDate: eventDate,
                confidenceScore: confidenceScore,
                confirmationStatus: confirmationStatus,
                sensitivity: sensitivity,
                structuredData: structuredData,
                archived: archived,
                sourceUri: sourceUri,
                rawText: rawText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryObjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (remindersRefs) db.reminders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<
                      MemoryObjectRow,
                      $MemoryObjectsTable,
                      ReminderRow
                    >(
                      currentTable: table,
                      referencedTable: $$MemoryObjectsTableReferences
                          ._remindersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MemoryObjectsTableReferences(
                            db,
                            table,
                            p0,
                          ).remindersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.memoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MemoryObjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryObjectsTable,
      MemoryObjectRow,
      $$MemoryObjectsTableFilterComposer,
      $$MemoryObjectsTableOrderingComposer,
      $$MemoryObjectsTableAnnotationComposer,
      $$MemoryObjectsTableCreateCompanionBuilder,
      $$MemoryObjectsTableUpdateCompanionBuilder,
      (MemoryObjectRow, $$MemoryObjectsTableReferences),
      MemoryObjectRow,
      PrefetchHooks Function({bool remindersRefs})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String memoryId,
      required DateTime triggerTime,
      required String timezone,
      required int status,
      required DateTime createdAt,
      required int daysBefore,
      required int notificationId,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> memoryId,
      Value<DateTime> triggerTime,
      Value<String> timezone,
      Value<int> status,
      Value<DateTime> createdAt,
      Value<int> daysBefore,
      Value<int> notificationId,
      Value<DateTime?> acknowledgedAt,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryObjectsTable _memoryIdTable(_$AppDatabase db) =>
      db.memoryObjects.createAlias('reminders__memory_id__memory_objects__id');

  $$MemoryObjectsTableProcessedTableManager get memoryId {
    final $_column = $_itemColumn<String>('memory_id')!;

    final manager = $$MemoryObjectsTableTableManager(
      $_db,
      $_db.memoryObjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryObjectsTableFilterComposer get memoryId {
    final $$MemoryObjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memoryObjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryObjectsTableFilterComposer(
            $db: $db,
            $table: $db.memoryObjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryObjectsTableOrderingComposer get memoryId {
    final $$MemoryObjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memoryObjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryObjectsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryObjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );

  $$MemoryObjectsTableAnnotationComposer get memoryId {
    final $$MemoryObjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoryId,
      referencedTable: $db.memoryObjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryObjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryObjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool memoryId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<DateTime> triggerTime = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> daysBefore = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                memoryId: memoryId,
                triggerTime: triggerTime,
                timezone: timezone,
                status: status,
                createdAt: createdAt,
                daysBefore: daysBefore,
                notificationId: notificationId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoryId,
                required DateTime triggerTime,
                required String timezone,
                required int status,
                required DateTime createdAt,
                required int daysBefore,
                required int notificationId,
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                memoryId: memoryId,
                triggerTime: triggerTime,
                timezone: timezone,
                status: status,
                createdAt: createdAt,
                daysBefore: daysBefore,
                notificationId: notificationId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryId = false}) {
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
                    if (memoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memoryId,
                                referencedTable: $$RemindersTableReferences
                                    ._memoryIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._memoryIdTable(db)
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

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool memoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MemoryObjectsTableTableManager get memoryObjects =>
      $$MemoryObjectsTableTableManager(_db, _db.memoryObjects);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
