// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_database.dart';

// ignore_for_file: type=lint
class $HealthMetricsTable extends HealthMetrics
    with TableInfo<$HealthMetricsTable, HealthMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _value2Meta = const VerificationMeta('value2');
  @override
  late final GeneratedColumn<double> value2 = GeneratedColumn<double>(
    'value2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _value3Meta = const VerificationMeta('value3');
  @override
  late final GeneratedColumn<double> value3 = GeneratedColumn<double>(
    'value3',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _value4Meta = const VerificationMeta('value4');
  @override
  late final GeneratedColumn<double> value4 = GeneratedColumn<double>(
    'value4',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subTypeMeta = const VerificationMeta(
    'subType',
  );
  @override
  late final GeneratedColumn<String> subType = GeneratedColumn<String>(
    'sub_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedToBackendMeta = const VerificationMeta(
    'syncedToBackend',
  );
  @override
  late final GeneratedColumn<bool> syncedToBackend = GeneratedColumn<bool>(
    'synced_to_backend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced_to_backend" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    value,
    value2,
    value3,
    value4,
    subType,
    unit,
    recordedAt,
    source,
    notes,
    profileId,
    externalId,
    syncedToBackend,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('value2')) {
      context.handle(
        _value2Meta,
        value2.isAcceptableOrUnknown(data['value2']!, _value2Meta),
      );
    }
    if (data.containsKey('value3')) {
      context.handle(
        _value3Meta,
        value3.isAcceptableOrUnknown(data['value3']!, _value3Meta),
      );
    }
    if (data.containsKey('value4')) {
      context.handle(
        _value4Meta,
        value4.isAcceptableOrUnknown(data['value4']!, _value4Meta),
      );
    }
    if (data.containsKey('sub_type')) {
      context.handle(
        _subTypeMeta,
        subType.isAcceptableOrUnknown(data['sub_type']!, _subTypeMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('synced_to_backend')) {
      context.handle(
        _syncedToBackendMeta,
        syncedToBackend.isAcceptableOrUnknown(
          data['synced_to_backend']!,
          _syncedToBackendMeta,
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
  HealthMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      value2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value2'],
      ),
      value3: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value3'],
      ),
      value4: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value4'],
      ),
      subType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_type'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      syncedToBackend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced_to_backend'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HealthMetricsTable createAlias(String alias) {
    return $HealthMetricsTable(attachedDatabase, alias);
  }
}

class HealthMetric extends DataClass implements Insertable<HealthMetric> {
  final int id;
  final String type;
  final double value;
  final double? value2;
  final double? value3;
  final double? value4;
  final String? subType;
  final String unit;
  final DateTime recordedAt;
  final String source;
  final String? notes;
  final String? profileId;
  final String? externalId;
  final bool syncedToBackend;
  final DateTime createdAt;
  const HealthMetric({
    required this.id,
    required this.type,
    required this.value,
    this.value2,
    this.value3,
    this.value4,
    this.subType,
    required this.unit,
    required this.recordedAt,
    required this.source,
    this.notes,
    this.profileId,
    this.externalId,
    required this.syncedToBackend,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || value2 != null) {
      map['value2'] = Variable<double>(value2);
    }
    if (!nullToAbsent || value3 != null) {
      map['value3'] = Variable<double>(value3);
    }
    if (!nullToAbsent || value4 != null) {
      map['value4'] = Variable<double>(value4);
    }
    if (!nullToAbsent || subType != null) {
      map['sub_type'] = Variable<String>(subType);
    }
    map['unit'] = Variable<String>(unit);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    map['synced_to_backend'] = Variable<bool>(syncedToBackend);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthMetricsCompanion toCompanion(bool nullToAbsent) {
    return HealthMetricsCompanion(
      id: Value(id),
      type: Value(type),
      value: Value(value),
      value2: value2 == null && nullToAbsent
          ? const Value.absent()
          : Value(value2),
      value3: value3 == null && nullToAbsent
          ? const Value.absent()
          : Value(value3),
      value4: value4 == null && nullToAbsent
          ? const Value.absent()
          : Value(value4),
      subType: subType == null && nullToAbsent
          ? const Value.absent()
          : Value(subType),
      unit: Value(unit),
      recordedAt: Value(recordedAt),
      source: Value(source),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      syncedToBackend: Value(syncedToBackend),
      createdAt: Value(createdAt),
    );
  }

  factory HealthMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthMetric(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<double>(json['value']),
      value2: serializer.fromJson<double?>(json['value2']),
      value3: serializer.fromJson<double?>(json['value3']),
      value4: serializer.fromJson<double?>(json['value4']),
      subType: serializer.fromJson<String?>(json['subType']),
      unit: serializer.fromJson<String>(json['unit']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      source: serializer.fromJson<String>(json['source']),
      notes: serializer.fromJson<String?>(json['notes']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      syncedToBackend: serializer.fromJson<bool>(json['syncedToBackend']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<double>(value),
      'value2': serializer.toJson<double?>(value2),
      'value3': serializer.toJson<double?>(value3),
      'value4': serializer.toJson<double?>(value4),
      'subType': serializer.toJson<String?>(subType),
      'unit': serializer.toJson<String>(unit),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'source': serializer.toJson<String>(source),
      'notes': serializer.toJson<String?>(notes),
      'profileId': serializer.toJson<String?>(profileId),
      'externalId': serializer.toJson<String?>(externalId),
      'syncedToBackend': serializer.toJson<bool>(syncedToBackend),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthMetric copyWith({
    int? id,
    String? type,
    double? value,
    Value<double?> value2 = const Value.absent(),
    Value<double?> value3 = const Value.absent(),
    Value<double?> value4 = const Value.absent(),
    Value<String?> subType = const Value.absent(),
    String? unit,
    DateTime? recordedAt,
    String? source,
    Value<String?> notes = const Value.absent(),
    Value<String?> profileId = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
    bool? syncedToBackend,
    DateTime? createdAt,
  }) => HealthMetric(
    id: id ?? this.id,
    type: type ?? this.type,
    value: value ?? this.value,
    value2: value2.present ? value2.value : this.value2,
    value3: value3.present ? value3.value : this.value3,
    value4: value4.present ? value4.value : this.value4,
    subType: subType.present ? subType.value : this.subType,
    unit: unit ?? this.unit,
    recordedAt: recordedAt ?? this.recordedAt,
    source: source ?? this.source,
    notes: notes.present ? notes.value : this.notes,
    profileId: profileId.present ? profileId.value : this.profileId,
    externalId: externalId.present ? externalId.value : this.externalId,
    syncedToBackend: syncedToBackend ?? this.syncedToBackend,
    createdAt: createdAt ?? this.createdAt,
  );
  HealthMetric copyWithCompanion(HealthMetricsCompanion data) {
    return HealthMetric(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      value2: data.value2.present ? data.value2.value : this.value2,
      value3: data.value3.present ? data.value3.value : this.value3,
      value4: data.value4.present ? data.value4.value : this.value4,
      subType: data.subType.present ? data.subType.value : this.subType,
      unit: data.unit.present ? data.unit.value : this.unit,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      source: data.source.present ? data.source.value : this.source,
      notes: data.notes.present ? data.notes.value : this.notes,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      syncedToBackend: data.syncedToBackend.present
          ? data.syncedToBackend.value
          : this.syncedToBackend,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthMetric(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('value2: $value2, ')
          ..write('value3: $value3, ')
          ..write('value4: $value4, ')
          ..write('subType: $subType, ')
          ..write('unit: $unit, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('profileId: $profileId, ')
          ..write('externalId: $externalId, ')
          ..write('syncedToBackend: $syncedToBackend, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    value,
    value2,
    value3,
    value4,
    subType,
    unit,
    recordedAt,
    source,
    notes,
    profileId,
    externalId,
    syncedToBackend,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthMetric &&
          other.id == this.id &&
          other.type == this.type &&
          other.value == this.value &&
          other.value2 == this.value2 &&
          other.value3 == this.value3 &&
          other.value4 == this.value4 &&
          other.subType == this.subType &&
          other.unit == this.unit &&
          other.recordedAt == this.recordedAt &&
          other.source == this.source &&
          other.notes == this.notes &&
          other.profileId == this.profileId &&
          other.externalId == this.externalId &&
          other.syncedToBackend == this.syncedToBackend &&
          other.createdAt == this.createdAt);
}

class HealthMetricsCompanion extends UpdateCompanion<HealthMetric> {
  final Value<int> id;
  final Value<String> type;
  final Value<double> value;
  final Value<double?> value2;
  final Value<double?> value3;
  final Value<double?> value4;
  final Value<String?> subType;
  final Value<String> unit;
  final Value<DateTime> recordedAt;
  final Value<String> source;
  final Value<String?> notes;
  final Value<String?> profileId;
  final Value<String?> externalId;
  final Value<bool> syncedToBackend;
  final Value<DateTime> createdAt;
  const HealthMetricsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.value2 = const Value.absent(),
    this.value3 = const Value.absent(),
    this.value4 = const Value.absent(),
    this.subType = const Value.absent(),
    this.unit = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.profileId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.syncedToBackend = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthMetricsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required double value,
    this.value2 = const Value.absent(),
    this.value3 = const Value.absent(),
    this.value4 = const Value.absent(),
    this.subType = const Value.absent(),
    required String unit,
    required DateTime recordedAt,
    this.source = const Value.absent(),
    this.notes = const Value.absent(),
    this.profileId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.syncedToBackend = const Value.absent(),
    required DateTime createdAt,
  }) : type = Value(type),
       value = Value(value),
       unit = Value(unit),
       recordedAt = Value(recordedAt),
       createdAt = Value(createdAt);
  static Insertable<HealthMetric> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<double>? value,
    Expression<double>? value2,
    Expression<double>? value3,
    Expression<double>? value4,
    Expression<String>? subType,
    Expression<String>? unit,
    Expression<DateTime>? recordedAt,
    Expression<String>? source,
    Expression<String>? notes,
    Expression<String>? profileId,
    Expression<String>? externalId,
    Expression<bool>? syncedToBackend,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (value2 != null) 'value2': value2,
      if (value3 != null) 'value3': value3,
      if (value4 != null) 'value4': value4,
      if (subType != null) 'sub_type': subType,
      if (unit != null) 'unit': unit,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (source != null) 'source': source,
      if (notes != null) 'notes': notes,
      if (profileId != null) 'profile_id': profileId,
      if (externalId != null) 'external_id': externalId,
      if (syncedToBackend != null) 'synced_to_backend': syncedToBackend,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthMetricsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<double>? value,
    Value<double?>? value2,
    Value<double?>? value3,
    Value<double?>? value4,
    Value<String?>? subType,
    Value<String>? unit,
    Value<DateTime>? recordedAt,
    Value<String>? source,
    Value<String?>? notes,
    Value<String?>? profileId,
    Value<String?>? externalId,
    Value<bool>? syncedToBackend,
    Value<DateTime>? createdAt,
  }) {
    return HealthMetricsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      value2: value2 ?? this.value2,
      value3: value3 ?? this.value3,
      value4: value4 ?? this.value4,
      subType: subType ?? this.subType,
      unit: unit ?? this.unit,
      recordedAt: recordedAt ?? this.recordedAt,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      profileId: profileId ?? this.profileId,
      externalId: externalId ?? this.externalId,
      syncedToBackend: syncedToBackend ?? this.syncedToBackend,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (value2.present) {
      map['value2'] = Variable<double>(value2.value);
    }
    if (value3.present) {
      map['value3'] = Variable<double>(value3.value);
    }
    if (value4.present) {
      map['value4'] = Variable<double>(value4.value);
    }
    if (subType.present) {
      map['sub_type'] = Variable<String>(subType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (syncedToBackend.present) {
      map['synced_to_backend'] = Variable<bool>(syncedToBackend.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthMetricsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('value2: $value2, ')
          ..write('value3: $value3, ')
          ..write('value4: $value4, ')
          ..write('subType: $subType, ')
          ..write('unit: $unit, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('source: $source, ')
          ..write('notes: $notes, ')
          ..write('profileId: $profileId, ')
          ..write('externalId: $externalId, ')
          ..write('syncedToBackend: $syncedToBackend, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caloriesConsumedMeta = const VerificationMeta(
    'caloriesConsumed',
  );
  @override
  late final GeneratedColumn<int> caloriesConsumed = GeneratedColumn<int>(
    'calories_consumed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<int> caloriesBurned = GeneratedColumn<int>(
    'calories_burned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _waterGlassesMeta = const VerificationMeta(
    'waterGlasses',
  );
  @override
  late final GeneratedColumn<int> waterGlasses = GeneratedColumn<int>(
    'water_glasses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepMinutesMeta = const VerificationMeta(
    'sleepMinutes',
  );
  @override
  late final GeneratedColumn<int> sleepMinutes = GeneratedColumn<int>(
    'sleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<String> sleepQuality = GeneratedColumn<String>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateKey,
    steps,
    caloriesConsumed,
    caloriesBurned,
    waterGlasses,
    sleepMinutes,
    sleepQuality,
    profileId,
    source,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('calories_consumed')) {
      context.handle(
        _caloriesConsumedMeta,
        caloriesConsumed.isAcceptableOrUnknown(
          data['calories_consumed']!,
          _caloriesConsumedMeta,
        ),
      );
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    }
    if (data.containsKey('water_glasses')) {
      context.handle(
        _waterGlassesMeta,
        waterGlasses.isAcceptableOrUnknown(
          data['water_glasses']!,
          _waterGlassesMeta,
        ),
      );
    }
    if (data.containsKey('sleep_minutes')) {
      context.handle(
        _sleepMinutesMeta,
        sleepMinutes.isAcceptableOrUnknown(
          data['sleep_minutes']!,
          _sleepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
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
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      caloriesConsumed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_consumed'],
      )!,
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_burned'],
      )!,
      waterGlasses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}water_glasses'],
      )!,
      sleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_minutes'],
      )!,
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sleep_quality'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final int id;
  final String dateKey;
  final int steps;
  final int caloriesConsumed;
  final int caloriesBurned;
  final int waterGlasses;
  final int sleepMinutes;
  final String? sleepQuality;
  final String? profileId;
  final String source;
  final DateTime updatedAt;
  const DailyLog({
    required this.id,
    required this.dateKey,
    required this.steps,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.waterGlasses,
    required this.sleepMinutes,
    this.sleepQuality,
    this.profileId,
    required this.source,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_key'] = Variable<String>(dateKey);
    map['steps'] = Variable<int>(steps);
    map['calories_consumed'] = Variable<int>(caloriesConsumed);
    map['calories_burned'] = Variable<int>(caloriesBurned);
    map['water_glasses'] = Variable<int>(waterGlasses);
    map['sleep_minutes'] = Variable<int>(sleepMinutes);
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<String>(sleepQuality);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      id: Value(id),
      dateKey: Value(dateKey),
      steps: Value(steps),
      caloriesConsumed: Value(caloriesConsumed),
      caloriesBurned: Value(caloriesBurned),
      waterGlasses: Value(waterGlasses),
      sleepMinutes: Value(sleepMinutes),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      source: Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      id: serializer.fromJson<int>(json['id']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      steps: serializer.fromJson<int>(json['steps']),
      caloriesConsumed: serializer.fromJson<int>(json['caloriesConsumed']),
      caloriesBurned: serializer.fromJson<int>(json['caloriesBurned']),
      waterGlasses: serializer.fromJson<int>(json['waterGlasses']),
      sleepMinutes: serializer.fromJson<int>(json['sleepMinutes']),
      sleepQuality: serializer.fromJson<String?>(json['sleepQuality']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateKey': serializer.toJson<String>(dateKey),
      'steps': serializer.toJson<int>(steps),
      'caloriesConsumed': serializer.toJson<int>(caloriesConsumed),
      'caloriesBurned': serializer.toJson<int>(caloriesBurned),
      'waterGlasses': serializer.toJson<int>(waterGlasses),
      'sleepMinutes': serializer.toJson<int>(sleepMinutes),
      'sleepQuality': serializer.toJson<String?>(sleepQuality),
      'profileId': serializer.toJson<String?>(profileId),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyLog copyWith({
    int? id,
    String? dateKey,
    int? steps,
    int? caloriesConsumed,
    int? caloriesBurned,
    int? waterGlasses,
    int? sleepMinutes,
    Value<String?> sleepQuality = const Value.absent(),
    Value<String?> profileId = const Value.absent(),
    String? source,
    DateTime? updatedAt,
  }) => DailyLog(
    id: id ?? this.id,
    dateKey: dateKey ?? this.dateKey,
    steps: steps ?? this.steps,
    caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    waterGlasses: waterGlasses ?? this.waterGlasses,
    sleepMinutes: sleepMinutes ?? this.sleepMinutes,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    profileId: profileId.present ? profileId.value : this.profileId,
    source: source ?? this.source,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyLog copyWithCompanion(DailyLogsCompanion data) {
    return DailyLog(
      id: data.id.present ? data.id.value : this.id,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      steps: data.steps.present ? data.steps.value : this.steps,
      caloriesConsumed: data.caloriesConsumed.present
          ? data.caloriesConsumed.value
          : this.caloriesConsumed,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      waterGlasses: data.waterGlasses.present
          ? data.waterGlasses.value
          : this.waterGlasses,
      sleepMinutes: data.sleepMinutes.present
          ? data.sleepMinutes.value
          : this.sleepMinutes,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('steps: $steps, ')
          ..write('caloriesConsumed: $caloriesConsumed, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('waterGlasses: $waterGlasses, ')
          ..write('sleepMinutes: $sleepMinutes, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dateKey,
    steps,
    caloriesConsumed,
    caloriesBurned,
    waterGlasses,
    sleepMinutes,
    sleepQuality,
    profileId,
    source,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.id == this.id &&
          other.dateKey == this.dateKey &&
          other.steps == this.steps &&
          other.caloriesConsumed == this.caloriesConsumed &&
          other.caloriesBurned == this.caloriesBurned &&
          other.waterGlasses == this.waterGlasses &&
          other.sleepMinutes == this.sleepMinutes &&
          other.sleepQuality == this.sleepQuality &&
          other.profileId == this.profileId &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<int> id;
  final Value<String> dateKey;
  final Value<int> steps;
  final Value<int> caloriesConsumed;
  final Value<int> caloriesBurned;
  final Value<int> waterGlasses;
  final Value<int> sleepMinutes;
  final Value<String?> sleepQuality;
  final Value<String?> profileId;
  final Value<String> source;
  final Value<DateTime> updatedAt;
  const DailyLogsCompanion({
    this.id = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.steps = const Value.absent(),
    this.caloriesConsumed = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.waterGlasses = const Value.absent(),
    this.sleepMinutes = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.id = const Value.absent(),
    required String dateKey,
    this.steps = const Value.absent(),
    this.caloriesConsumed = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.waterGlasses = const Value.absent(),
    this.sleepMinutes = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.profileId = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime updatedAt,
  }) : dateKey = Value(dateKey),
       updatedAt = Value(updatedAt);
  static Insertable<DailyLog> custom({
    Expression<int>? id,
    Expression<String>? dateKey,
    Expression<int>? steps,
    Expression<int>? caloriesConsumed,
    Expression<int>? caloriesBurned,
    Expression<int>? waterGlasses,
    Expression<int>? sleepMinutes,
    Expression<String>? sleepQuality,
    Expression<String>? profileId,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateKey != null) 'date_key': dateKey,
      if (steps != null) 'steps': steps,
      if (caloriesConsumed != null) 'calories_consumed': caloriesConsumed,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (waterGlasses != null) 'water_glasses': waterGlasses,
      if (sleepMinutes != null) 'sleep_minutes': sleepMinutes,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (profileId != null) 'profile_id': profileId,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? dateKey,
    Value<int>? steps,
    Value<int>? caloriesConsumed,
    Value<int>? caloriesBurned,
    Value<int>? waterGlasses,
    Value<int>? sleepMinutes,
    Value<String?>? sleepQuality,
    Value<String?>? profileId,
    Value<String>? source,
    Value<DateTime>? updatedAt,
  }) {
    return DailyLogsCompanion(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      steps: steps ?? this.steps,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      profileId: profileId ?? this.profileId,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (caloriesConsumed.present) {
      map['calories_consumed'] = Variable<int>(caloriesConsumed.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<int>(caloriesBurned.value);
    }
    if (waterGlasses.present) {
      map['water_glasses'] = Variable<int>(waterGlasses.value);
    }
    if (sleepMinutes.present) {
      map['sleep_minutes'] = Variable<int>(sleepMinutes.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<String>(sleepQuality.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('steps: $steps, ')
          ..write('caloriesConsumed: $caloriesConsumed, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('waterGlasses: $waterGlasses, ')
          ..write('sleepMinutes: $sleepMinutes, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('profileId: $profileId, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FoodEntriesTable extends FoodEntries
    with TableInfo<$FoodEntriesTable, FoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
    'serving_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingUnitMeta = const VerificationMeta(
    'servingUnit',
  );
  @override
  late final GeneratedColumn<String> servingUnit = GeneratedColumn<String>(
    'serving_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consumedAtMeta = const VerificationMeta(
    'consumedAt',
  );
  @override
  late final GeneratedColumn<DateTime> consumedAt = GeneratedColumn<DateTime>(
    'consumed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    mealType,
    servingSize,
    servingUnit,
    profileId,
    consumedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('serving_unit')) {
      context.handle(
        _servingUnitMeta,
        servingUnit.isAcceptableOrUnknown(
          data['serving_unit']!,
          _servingUnitMeta,
        ),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('consumed_at')) {
      context.handle(
        _consumedAtMeta,
        consumedAt.isAcceptableOrUnknown(data['consumed_at']!, _consumedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_consumedAtMeta);
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
  FoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_size'],
      ),
      servingUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_unit'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      consumedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}consumed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodEntriesTable createAlias(String alias) {
    return $FoodEntriesTable(attachedDatabase, alias);
  }
}

class FoodEntry extends DataClass implements Insertable<FoodEntry> {
  final int id;
  final String name;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;
  final String mealType;
  final double? servingSize;
  final String? servingUnit;
  final String? profileId;
  final DateTime consumedAt;
  final DateTime createdAt;
  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    required this.mealType,
    this.servingSize,
    this.servingUnit,
    this.profileId,
    required this.consumedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<int>(calories);
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<double>(servingSize);
    }
    if (!nullToAbsent || servingUnit != null) {
      map['serving_unit'] = Variable<String>(servingUnit);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['consumed_at'] = Variable<DateTime>(consumedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodEntriesCompanion(
      id: Value(id),
      name: Value(name),
      calories: Value(calories),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      fiber: fiber == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber),
      mealType: Value(mealType),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      servingUnit: servingUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(servingUnit),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      consumedAt: Value(consumedAt),
      createdAt: Value(createdAt),
    );
  }

  factory FoodEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      fat: serializer.fromJson<double?>(json['fat']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      mealType: serializer.fromJson<String>(json['mealType']),
      servingSize: serializer.fromJson<double?>(json['servingSize']),
      servingUnit: serializer.fromJson<String?>(json['servingUnit']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      consumedAt: serializer.fromJson<DateTime>(json['consumedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<double?>(protein),
      'carbs': serializer.toJson<double?>(carbs),
      'fat': serializer.toJson<double?>(fat),
      'fiber': serializer.toJson<double?>(fiber),
      'mealType': serializer.toJson<String>(mealType),
      'servingSize': serializer.toJson<double?>(servingSize),
      'servingUnit': serializer.toJson<String?>(servingUnit),
      'profileId': serializer.toJson<String?>(profileId),
      'consumedAt': serializer.toJson<DateTime>(consumedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodEntry copyWith({
    int? id,
    String? name,
    int? calories,
    Value<double?> protein = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
    String? mealType,
    Value<double?> servingSize = const Value.absent(),
    Value<String?> servingUnit = const Value.absent(),
    Value<String?> profileId = const Value.absent(),
    DateTime? consumedAt,
    DateTime? createdAt,
  }) => FoodEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    protein: protein.present ? protein.value : this.protein,
    carbs: carbs.present ? carbs.value : this.carbs,
    fat: fat.present ? fat.value : this.fat,
    fiber: fiber.present ? fiber.value : this.fiber,
    mealType: mealType ?? this.mealType,
    servingSize: servingSize.present ? servingSize.value : this.servingSize,
    servingUnit: servingUnit.present ? servingUnit.value : this.servingUnit,
    profileId: profileId.present ? profileId.value : this.profileId,
    consumedAt: consumedAt ?? this.consumedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodEntry copyWithCompanion(FoodEntriesCompanion data) {
    return FoodEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      servingUnit: data.servingUnit.present
          ? data.servingUnit.value
          : this.servingUnit,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      consumedAt: data.consumedAt.present
          ? data.consumedAt.value
          : this.consumedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('mealType: $mealType, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('profileId: $profileId, ')
          ..write('consumedAt: $consumedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    mealType,
    servingSize,
    servingUnit,
    profileId,
    consumedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.mealType == this.mealType &&
          other.servingSize == this.servingSize &&
          other.servingUnit == this.servingUnit &&
          other.profileId == this.profileId &&
          other.consumedAt == this.consumedAt &&
          other.createdAt == this.createdAt);
}

class FoodEntriesCompanion extends UpdateCompanion<FoodEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> calories;
  final Value<double?> protein;
  final Value<double?> carbs;
  final Value<double?> fat;
  final Value<double?> fiber;
  final Value<String> mealType;
  final Value<double?> servingSize;
  final Value<String?> servingUnit;
  final Value<String?> profileId;
  final Value<DateTime> consumedAt;
  final Value<DateTime> createdAt;
  const FoodEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.mealType = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.servingUnit = const Value.absent(),
    this.profileId = const Value.absent(),
    this.consumedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int calories,
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    required String mealType,
    this.servingSize = const Value.absent(),
    this.servingUnit = const Value.absent(),
    this.profileId = const Value.absent(),
    required DateTime consumedAt,
    required DateTime createdAt,
  }) : name = Value(name),
       calories = Value(calories),
       mealType = Value(mealType),
       consumedAt = Value(consumedAt),
       createdAt = Value(createdAt);
  static Insertable<FoodEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<String>? mealType,
    Expression<double>? servingSize,
    Expression<String>? servingUnit,
    Expression<String>? profileId,
    Expression<DateTime>? consumedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (mealType != null) 'meal_type': mealType,
      if (servingSize != null) 'serving_size': servingSize,
      if (servingUnit != null) 'serving_unit': servingUnit,
      if (profileId != null) 'profile_id': profileId,
      if (consumedAt != null) 'consumed_at': consumedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? calories,
    Value<double?>? protein,
    Value<double?>? carbs,
    Value<double?>? fat,
    Value<double?>? fiber,
    Value<String>? mealType,
    Value<double?>? servingSize,
    Value<String?>? servingUnit,
    Value<String?>? profileId,
    Value<DateTime>? consumedAt,
    Value<DateTime>? createdAt,
  }) {
    return FoodEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      profileId: profileId ?? this.profileId,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (servingUnit.present) {
      map['serving_unit'] = Variable<String>(servingUnit.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (consumedAt.present) {
      map['consumed_at'] = Variable<DateTime>(consumedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('mealType: $mealType, ')
          ..write('servingSize: $servingSize, ')
          ..write('servingUnit: $servingUnit, ')
          ..write('profileId: $profileId, ')
          ..write('consumedAt: $consumedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HealthGoalsTable extends HealthGoals
    with TableInfo<$HealthGoalsTable, HealthGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _metricTypeMeta = const VerificationMeta(
    'metricType',
  );
  @override
  late final GeneratedColumn<String> metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minValueMeta = const VerificationMeta(
    'minValue',
  );
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
    'min_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxValueMeta = const VerificationMeta(
    'maxValue',
  );
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
    'max_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    metricType,
    targetValue,
    minValue,
    maxValue,
    unit,
    profileId,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('metric_type')) {
      context.handle(
        _metricTypeMeta,
        metricType.isAcceptableOrUnknown(data['metric_type']!, _metricTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricTypeMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('min_value')) {
      context.handle(
        _minValueMeta,
        minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta),
      );
    }
    if (data.containsKey('max_value')) {
      context.handle(
        _maxValueMeta,
        maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  HealthGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      metricType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      minValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_value'],
      ),
      maxValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_value'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HealthGoalsTable createAlias(String alias) {
    return $HealthGoalsTable(attachedDatabase, alias);
  }
}

class HealthGoal extends DataClass implements Insertable<HealthGoal> {
  final int id;
  final String metricType;
  final double targetValue;
  final double? minValue;
  final double? maxValue;
  final String unit;
  final String? profileId;
  final bool isActive;
  final DateTime createdAt;
  const HealthGoal({
    required this.id,
    required this.metricType,
    required this.targetValue,
    this.minValue,
    this.maxValue,
    required this.unit,
    this.profileId,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['metric_type'] = Variable<String>(metricType);
    map['target_value'] = Variable<double>(targetValue);
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<double>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<double>(maxValue);
    }
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<String>(profileId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthGoalsCompanion toCompanion(bool nullToAbsent) {
    return HealthGoalsCompanion(
      id: Value(id),
      metricType: Value(metricType),
      targetValue: Value(targetValue),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      unit: Value(unit),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory HealthGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthGoal(
      id: serializer.fromJson<int>(json['id']),
      metricType: serializer.fromJson<String>(json['metricType']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      minValue: serializer.fromJson<double?>(json['minValue']),
      maxValue: serializer.fromJson<double?>(json['maxValue']),
      unit: serializer.fromJson<String>(json['unit']),
      profileId: serializer.fromJson<String?>(json['profileId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'metricType': serializer.toJson<String>(metricType),
      'targetValue': serializer.toJson<double>(targetValue),
      'minValue': serializer.toJson<double?>(minValue),
      'maxValue': serializer.toJson<double?>(maxValue),
      'unit': serializer.toJson<String>(unit),
      'profileId': serializer.toJson<String?>(profileId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthGoal copyWith({
    int? id,
    String? metricType,
    double? targetValue,
    Value<double?> minValue = const Value.absent(),
    Value<double?> maxValue = const Value.absent(),
    String? unit,
    Value<String?> profileId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => HealthGoal(
    id: id ?? this.id,
    metricType: metricType ?? this.metricType,
    targetValue: targetValue ?? this.targetValue,
    minValue: minValue.present ? minValue.value : this.minValue,
    maxValue: maxValue.present ? maxValue.value : this.maxValue,
    unit: unit ?? this.unit,
    profileId: profileId.present ? profileId.value : this.profileId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  HealthGoal copyWithCompanion(HealthGoalsCompanion data) {
    return HealthGoal(
      id: data.id.present ? data.id.value : this.id,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthGoal(')
          ..write('id: $id, ')
          ..write('metricType: $metricType, ')
          ..write('targetValue: $targetValue, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('unit: $unit, ')
          ..write('profileId: $profileId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    metricType,
    targetValue,
    minValue,
    maxValue,
    unit,
    profileId,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthGoal &&
          other.id == this.id &&
          other.metricType == this.metricType &&
          other.targetValue == this.targetValue &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.unit == this.unit &&
          other.profileId == this.profileId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class HealthGoalsCompanion extends UpdateCompanion<HealthGoal> {
  final Value<int> id;
  final Value<String> metricType;
  final Value<double> targetValue;
  final Value<double?> minValue;
  final Value<double?> maxValue;
  final Value<String> unit;
  final Value<String?> profileId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const HealthGoalsCompanion({
    this.id = const Value.absent(),
    this.metricType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.profileId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String metricType,
    required double targetValue,
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    required String unit,
    this.profileId = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : metricType = Value(metricType),
       targetValue = Value(targetValue),
       unit = Value(unit),
       createdAt = Value(createdAt);
  static Insertable<HealthGoal> custom({
    Expression<int>? id,
    Expression<String>? metricType,
    Expression<double>? targetValue,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<String>? unit,
    Expression<String>? profileId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricType != null) 'metric_type': metricType,
      if (targetValue != null) 'target_value': targetValue,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (unit != null) 'unit': unit,
      if (profileId != null) 'profile_id': profileId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? metricType,
    Value<double>? targetValue,
    Value<double?>? minValue,
    Value<double?>? maxValue,
    Value<String>? unit,
    Value<String?>? profileId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return HealthGoalsCompanion(
      id: id ?? this.id,
      metricType: metricType ?? this.metricType,
      targetValue: targetValue ?? this.targetValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      unit: unit ?? this.unit,
      profileId: profileId ?? this.profileId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(metricType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthGoalsCompanion(')
          ..write('id: $id, ')
          ..write('metricType: $metricType, ')
          ..write('targetValue: $targetValue, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('unit: $unit, ')
          ..write('profileId: $profileId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    platform,
    dataType,
    lastSyncAt,
    lastError,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final int id;
  final String platform;
  final String dataType;
  final DateTime? lastSyncAt;
  final String? lastError;
  final bool enabled;
  const SyncMetadataData({
    required this.id,
    required this.platform,
    required this.dataType,
    this.lastSyncAt,
    this.lastError,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['platform'] = Variable<String>(platform);
    map['data_type'] = Variable<String>(dataType);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      platform: Value(platform),
      dataType: Value(dataType),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      enabled: Value(enabled),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      platform: serializer.fromJson<String>(json['platform']),
      dataType: serializer.fromJson<String>(json['dataType']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'platform': serializer.toJson<String>(platform),
      'dataType': serializer.toJson<String>(dataType),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastError': serializer.toJson<String?>(lastError),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  SyncMetadataData copyWith({
    int? id,
    String? platform,
    String? dataType,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    bool? enabled,
  }) => SyncMetadataData(
    id: id ?? this.id,
    platform: platform ?? this.platform,
    dataType: dataType ?? this.dataType,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    enabled: enabled ?? this.enabled,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      platform: data.platform.present ? data.platform.value : this.platform,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('dataType: $dataType, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastError: $lastError, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, platform, dataType, lastSyncAt, lastError, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.id == this.id &&
          other.platform == this.platform &&
          other.dataType == this.dataType &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastError == this.lastError &&
          other.enabled == this.enabled);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<int> id;
  final Value<String> platform;
  final Value<String> dataType;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> lastError;
  final Value<bool> enabled;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.platform = const Value.absent(),
    this.dataType = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    required String platform,
    required String dataType,
    this.lastSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : platform = Value(platform),
       dataType = Value(dataType);
  static Insertable<SyncMetadataData> custom({
    Expression<int>? id,
    Expression<String>? platform,
    Expression<String>? dataType,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? lastError,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platform != null) 'platform': platform,
      if (dataType != null) 'data_type': dataType,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastError != null) 'last_error': lastError,
      if (enabled != null) 'enabled': enabled,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<String>? platform,
    Value<String>? dataType,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? lastError,
    Value<bool>? enabled,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      dataType: dataType ?? this.dataType,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError ?? this.lastError,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('dataType: $dataType, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastError: $lastError, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $MedicineEntriesTable extends MedicineEntries
    with TableInfo<$MedicineEntriesTable, MedicineEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> times =
      GeneratedColumn<String>(
        'times',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($MedicineEntriesTable.$convertertimes);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> repeatDays =
      GeneratedColumn<String>(
        'repeat_days',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($MedicineEntriesTable.$converterrepeatDays);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    dosage,
    times,
    repeatDays,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicine_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  MedicineEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      ),
      times: $MedicineEntriesTable.$convertertimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}times'],
        )!,
      ),
      repeatDays: $MedicineEntriesTable.$converterrepeatDays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat_days'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicineEntriesTable createAlias(String alias) {
    return $MedicineEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertimes =
      const StringListConverter();
  static TypeConverter<List<int>, String> $converterrepeatDays =
      const IntListConverter();
}

class MedicineEntry extends DataClass implements Insertable<MedicineEntry> {
  final int id;
  final String name;
  final String? dosage;
  final List<String> times;
  final List<int> repeatDays;
  final bool isActive;
  final DateTime createdAt;
  const MedicineEntry({
    required this.id,
    required this.name,
    this.dosage,
    required this.times,
    required this.repeatDays,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    {
      map['times'] = Variable<String>(
        $MedicineEntriesTable.$convertertimes.toSql(times),
      );
    }
    {
      map['repeat_days'] = Variable<String>(
        $MedicineEntriesTable.$converterrepeatDays.toSql(repeatDays),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicineEntriesCompanion toCompanion(bool nullToAbsent) {
    return MedicineEntriesCompanion(
      id: Value(id),
      name: Value(name),
      dosage: dosage == null && nullToAbsent
          ? const Value.absent()
          : Value(dosage),
      times: Value(times),
      repeatDays: Value(repeatDays),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory MedicineEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      times: serializer.fromJson<List<String>>(json['times']),
      repeatDays: serializer.fromJson<List<int>>(json['repeatDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String?>(dosage),
      'times': serializer.toJson<List<String>>(times),
      'repeatDays': serializer.toJson<List<int>>(repeatDays),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicineEntry copyWith({
    int? id,
    String? name,
    Value<String?> dosage = const Value.absent(),
    List<String>? times,
    List<int>? repeatDays,
    bool? isActive,
    DateTime? createdAt,
  }) => MedicineEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    dosage: dosage.present ? dosage.value : this.dosage,
    times: times ?? this.times,
    repeatDays: repeatDays ?? this.repeatDays,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicineEntry copyWithCompanion(MedicineEntriesCompanion data) {
    return MedicineEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      times: data.times.present ? data.times.value : this.times,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('times: $times, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, dosage, times, repeatDays, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.times == this.times &&
          other.repeatDays == this.repeatDays &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class MedicineEntriesCompanion extends UpdateCompanion<MedicineEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> dosage;
  final Value<List<String>> times;
  final Value<List<int>> repeatDays;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const MedicineEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.times = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicineEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.dosage = const Value.absent(),
    required List<String> times,
    required List<int> repeatDays,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       times = Value(times),
       repeatDays = Value(repeatDays),
       createdAt = Value(createdAt);
  static Insertable<MedicineEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? times,
    Expression<String>? repeatDays,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (times != null) 'times': times,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicineEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? dosage,
    Value<List<String>>? times,
    Value<List<int>>? repeatDays,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return MedicineEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      repeatDays: repeatDays ?? this.repeatDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(
        $MedicineEntriesTable.$convertertimes.toSql(times.value),
      );
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(
        $MedicineEntriesTable.$converterrepeatDays.toSql(repeatDays.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('times: $times, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$HealthDatabase extends GeneratedDatabase {
  _$HealthDatabase(QueryExecutor e) : super(e);
  $HealthDatabaseManager get managers => $HealthDatabaseManager(this);
  late final $HealthMetricsTable healthMetrics = $HealthMetricsTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $FoodEntriesTable foodEntries = $FoodEntriesTable(this);
  late final $HealthGoalsTable healthGoals = $HealthGoalsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $MedicineEntriesTable medicineEntries = $MedicineEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    healthMetrics,
    dailyLogs,
    foodEntries,
    healthGoals,
    syncMetadata,
    medicineEntries,
  ];
}

typedef $$HealthMetricsTableCreateCompanionBuilder =
    HealthMetricsCompanion Function({
      Value<int> id,
      required String type,
      required double value,
      Value<double?> value2,
      Value<double?> value3,
      Value<double?> value4,
      Value<String?> subType,
      required String unit,
      required DateTime recordedAt,
      Value<String> source,
      Value<String?> notes,
      Value<String?> profileId,
      Value<String?> externalId,
      Value<bool> syncedToBackend,
      required DateTime createdAt,
    });
typedef $$HealthMetricsTableUpdateCompanionBuilder =
    HealthMetricsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<double> value,
      Value<double?> value2,
      Value<double?> value3,
      Value<double?> value4,
      Value<String?> subType,
      Value<String> unit,
      Value<DateTime> recordedAt,
      Value<String> source,
      Value<String?> notes,
      Value<String?> profileId,
      Value<String?> externalId,
      Value<bool> syncedToBackend,
      Value<DateTime> createdAt,
    });

class $$HealthMetricsTableFilterComposer
    extends Composer<_$HealthDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value2 => $composableBuilder(
    column: $table.value2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value3 => $composableBuilder(
    column: $table.value3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value4 => $composableBuilder(
    column: $table.value4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subType => $composableBuilder(
    column: $table.subType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncedToBackend => $composableBuilder(
    column: $table.syncedToBackend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthMetricsTableOrderingComposer
    extends Composer<_$HealthDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value2 => $composableBuilder(
    column: $table.value2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value3 => $composableBuilder(
    column: $table.value3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value4 => $composableBuilder(
    column: $table.value4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subType => $composableBuilder(
    column: $table.subType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncedToBackend => $composableBuilder(
    column: $table.syncedToBackend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthMetricsTableAnnotationComposer
    extends Composer<_$HealthDatabase, $HealthMetricsTable> {
  $$HealthMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get value2 =>
      $composableBuilder(column: $table.value2, builder: (column) => column);

  GeneratedColumn<double> get value3 =>
      $composableBuilder(column: $table.value3, builder: (column) => column);

  GeneratedColumn<double> get value4 =>
      $composableBuilder(column: $table.value4, builder: (column) => column);

  GeneratedColumn<String> get subType =>
      $composableBuilder(column: $table.subType, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncedToBackend => $composableBuilder(
    column: $table.syncedToBackend,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthMetricsTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $HealthMetricsTable,
          HealthMetric,
          $$HealthMetricsTableFilterComposer,
          $$HealthMetricsTableOrderingComposer,
          $$HealthMetricsTableAnnotationComposer,
          $$HealthMetricsTableCreateCompanionBuilder,
          $$HealthMetricsTableUpdateCompanionBuilder,
          (
            HealthMetric,
            BaseReferences<_$HealthDatabase, $HealthMetricsTable, HealthMetric>,
          ),
          HealthMetric,
          PrefetchHooks Function()
        > {
  $$HealthMetricsTableTableManager(
    _$HealthDatabase db,
    $HealthMetricsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<double?> value2 = const Value.absent(),
                Value<double?> value3 = const Value.absent(),
                Value<double?> value4 = const Value.absent(),
                Value<String?> subType = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<bool> syncedToBackend = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthMetricsCompanion(
                id: id,
                type: type,
                value: value,
                value2: value2,
                value3: value3,
                value4: value4,
                subType: subType,
                unit: unit,
                recordedAt: recordedAt,
                source: source,
                notes: notes,
                profileId: profileId,
                externalId: externalId,
                syncedToBackend: syncedToBackend,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required double value,
                Value<double?> value2 = const Value.absent(),
                Value<double?> value3 = const Value.absent(),
                Value<double?> value4 = const Value.absent(),
                Value<String?> subType = const Value.absent(),
                required String unit,
                required DateTime recordedAt,
                Value<String> source = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<bool> syncedToBackend = const Value.absent(),
                required DateTime createdAt,
              }) => HealthMetricsCompanion.insert(
                id: id,
                type: type,
                value: value,
                value2: value2,
                value3: value3,
                value4: value4,
                subType: subType,
                unit: unit,
                recordedAt: recordedAt,
                source: source,
                notes: notes,
                profileId: profileId,
                externalId: externalId,
                syncedToBackend: syncedToBackend,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $HealthMetricsTable,
      HealthMetric,
      $$HealthMetricsTableFilterComposer,
      $$HealthMetricsTableOrderingComposer,
      $$HealthMetricsTableAnnotationComposer,
      $$HealthMetricsTableCreateCompanionBuilder,
      $$HealthMetricsTableUpdateCompanionBuilder,
      (
        HealthMetric,
        BaseReferences<_$HealthDatabase, $HealthMetricsTable, HealthMetric>,
      ),
      HealthMetric,
      PrefetchHooks Function()
    >;
typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      required String dateKey,
      Value<int> steps,
      Value<int> caloriesConsumed,
      Value<int> caloriesBurned,
      Value<int> waterGlasses,
      Value<int> sleepMinutes,
      Value<String?> sleepQuality,
      Value<String?> profileId,
      Value<String> source,
      required DateTime updatedAt,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> id,
      Value<String> dateKey,
      Value<int> steps,
      Value<int> caloriesConsumed,
      Value<int> caloriesBurned,
      Value<int> waterGlasses,
      Value<int> sleepMinutes,
      Value<String?> sleepQuality,
      Value<String?> profileId,
      Value<String> source,
      Value<DateTime> updatedAt,
    });

class $$DailyLogsTableFilterComposer
    extends Composer<_$HealthDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesConsumed => $composableBuilder(
    column: $table.caloriesConsumed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waterGlasses => $composableBuilder(
    column: $table.waterGlasses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepMinutes => $composableBuilder(
    column: $table.sleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$HealthDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesConsumed => $composableBuilder(
    column: $table.caloriesConsumed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waterGlasses => $composableBuilder(
    column: $table.waterGlasses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepMinutes => $composableBuilder(
    column: $table.sleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$HealthDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get caloriesConsumed => $composableBuilder(
    column: $table.caloriesConsumed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get waterGlasses => $composableBuilder(
    column: $table.waterGlasses,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepMinutes => $composableBuilder(
    column: $table.sleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $DailyLogsTable,
          DailyLog,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (
            DailyLog,
            BaseReferences<_$HealthDatabase, $DailyLogsTable, DailyLog>,
          ),
          DailyLog,
          PrefetchHooks Function()
        > {
  $$DailyLogsTableTableManager(_$HealthDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<int> caloriesConsumed = const Value.absent(),
                Value<int> caloriesBurned = const Value.absent(),
                Value<int> waterGlasses = const Value.absent(),
                Value<int> sleepMinutes = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyLogsCompanion(
                id: id,
                dateKey: dateKey,
                steps: steps,
                caloriesConsumed: caloriesConsumed,
                caloriesBurned: caloriesBurned,
                waterGlasses: waterGlasses,
                sleepMinutes: sleepMinutes,
                sleepQuality: sleepQuality,
                profileId: profileId,
                source: source,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dateKey,
                Value<int> steps = const Value.absent(),
                Value<int> caloriesConsumed = const Value.absent(),
                Value<int> caloriesBurned = const Value.absent(),
                Value<int> waterGlasses = const Value.absent(),
                Value<int> sleepMinutes = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime updatedAt,
              }) => DailyLogsCompanion.insert(
                id: id,
                dateKey: dateKey,
                steps: steps,
                caloriesConsumed: caloriesConsumed,
                caloriesBurned: caloriesBurned,
                waterGlasses: waterGlasses,
                sleepMinutes: sleepMinutes,
                sleepQuality: sleepQuality,
                profileId: profileId,
                source: source,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $DailyLogsTable,
      DailyLog,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (DailyLog, BaseReferences<_$HealthDatabase, $DailyLogsTable, DailyLog>),
      DailyLog,
      PrefetchHooks Function()
    >;
typedef $$FoodEntriesTableCreateCompanionBuilder =
    FoodEntriesCompanion Function({
      Value<int> id,
      required String name,
      required int calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> fat,
      Value<double?> fiber,
      required String mealType,
      Value<double?> servingSize,
      Value<String?> servingUnit,
      Value<String?> profileId,
      required DateTime consumedAt,
      required DateTime createdAt,
    });
typedef $$FoodEntriesTableUpdateCompanionBuilder =
    FoodEntriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> fat,
      Value<double?> fiber,
      Value<String> mealType,
      Value<double?> servingSize,
      Value<String?> servingUnit,
      Value<String?> profileId,
      Value<DateTime> consumedAt,
      Value<DateTime> createdAt,
    });

class $$FoodEntriesTableFilterComposer
    extends Composer<_$HealthDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodEntriesTableOrderingComposer
    extends Composer<_$HealthDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodEntriesTableAnnotationComposer
    extends Composer<_$HealthDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingUnit => $composableBuilder(
    column: $table.servingUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<DateTime> get consumedAt => $composableBuilder(
    column: $table.consumedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodEntriesTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $FoodEntriesTable,
          FoodEntry,
          $$FoodEntriesTableFilterComposer,
          $$FoodEntriesTableOrderingComposer,
          $$FoodEntriesTableAnnotationComposer,
          $$FoodEntriesTableCreateCompanionBuilder,
          $$FoodEntriesTableUpdateCompanionBuilder,
          (
            FoodEntry,
            BaseReferences<_$HealthDatabase, $FoodEntriesTable, FoodEntry>,
          ),
          FoodEntry,
          PrefetchHooks Function()
        > {
  $$FoodEntriesTableTableManager(_$HealthDatabase db, $FoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingUnit = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<DateTime> consumedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodEntriesCompanion(
                id: id,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                mealType: mealType,
                servingSize: servingSize,
                servingUnit: servingUnit,
                profileId: profileId,
                consumedAt: consumedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int calories,
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                required String mealType,
                Value<double?> servingSize = const Value.absent(),
                Value<String?> servingUnit = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                required DateTime consumedAt,
                required DateTime createdAt,
              }) => FoodEntriesCompanion.insert(
                id: id,
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                mealType: mealType,
                servingSize: servingSize,
                servingUnit: servingUnit,
                profileId: profileId,
                consumedAt: consumedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $FoodEntriesTable,
      FoodEntry,
      $$FoodEntriesTableFilterComposer,
      $$FoodEntriesTableOrderingComposer,
      $$FoodEntriesTableAnnotationComposer,
      $$FoodEntriesTableCreateCompanionBuilder,
      $$FoodEntriesTableUpdateCompanionBuilder,
      (
        FoodEntry,
        BaseReferences<_$HealthDatabase, $FoodEntriesTable, FoodEntry>,
      ),
      FoodEntry,
      PrefetchHooks Function()
    >;
typedef $$HealthGoalsTableCreateCompanionBuilder =
    HealthGoalsCompanion Function({
      Value<int> id,
      required String metricType,
      required double targetValue,
      Value<double?> minValue,
      Value<double?> maxValue,
      required String unit,
      Value<String?> profileId,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$HealthGoalsTableUpdateCompanionBuilder =
    HealthGoalsCompanion Function({
      Value<int> id,
      Value<String> metricType,
      Value<double> targetValue,
      Value<double?> minValue,
      Value<double?> maxValue,
      Value<String> unit,
      Value<String?> profileId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$HealthGoalsTableFilterComposer
    extends Composer<_$HealthDatabase, $HealthGoalsTable> {
  $$HealthGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthGoalsTableOrderingComposer
    extends Composer<_$HealthDatabase, $HealthGoalsTable> {
  $$HealthGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minValue => $composableBuilder(
    column: $table.minValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxValue => $composableBuilder(
    column: $table.maxValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthGoalsTableAnnotationComposer
    extends Composer<_$HealthDatabase, $HealthGoalsTable> {
  $$HealthGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthGoalsTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $HealthGoalsTable,
          HealthGoal,
          $$HealthGoalsTableFilterComposer,
          $$HealthGoalsTableOrderingComposer,
          $$HealthGoalsTableAnnotationComposer,
          $$HealthGoalsTableCreateCompanionBuilder,
          $$HealthGoalsTableUpdateCompanionBuilder,
          (
            HealthGoal,
            BaseReferences<_$HealthDatabase, $HealthGoalsTable, HealthGoal>,
          ),
          HealthGoal,
          PrefetchHooks Function()
        > {
  $$HealthGoalsTableTableManager(_$HealthDatabase db, $HealthGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> metricType = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> profileId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthGoalsCompanion(
                id: id,
                metricType: metricType,
                targetValue: targetValue,
                minValue: minValue,
                maxValue: maxValue,
                unit: unit,
                profileId: profileId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String metricType,
                required double targetValue,
                Value<double?> minValue = const Value.absent(),
                Value<double?> maxValue = const Value.absent(),
                required String unit,
                Value<String?> profileId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => HealthGoalsCompanion.insert(
                id: id,
                metricType: metricType,
                targetValue: targetValue,
                minValue: minValue,
                maxValue: maxValue,
                unit: unit,
                profileId: profileId,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $HealthGoalsTable,
      HealthGoal,
      $$HealthGoalsTableFilterComposer,
      $$HealthGoalsTableOrderingComposer,
      $$HealthGoalsTableAnnotationComposer,
      $$HealthGoalsTableCreateCompanionBuilder,
      $$HealthGoalsTableUpdateCompanionBuilder,
      (
        HealthGoal,
        BaseReferences<_$HealthDatabase, $HealthGoalsTable, HealthGoal>,
      ),
      HealthGoal,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      required String platform,
      required String dataType,
      Value<DateTime?> lastSyncAt,
      Value<String?> lastError,
      Value<bool> enabled,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<int> id,
      Value<String> platform,
      Value<String> dataType,
      Value<DateTime?> lastSyncAt,
      Value<String?> lastError,
      Value<bool> enabled,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$HealthDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$HealthDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$HealthDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<
              _$HealthDatabase,
              $SyncMetadataTable,
              SyncMetadataData
            >,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$HealthDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                platform: platform,
                dataType: dataType,
                lastSyncAt: lastSyncAt,
                lastError: lastError,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String platform,
                required String dataType,
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                platform: platform,
                dataType: dataType,
                lastSyncAt: lastSyncAt,
                lastError: lastError,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$HealthDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$MedicineEntriesTableCreateCompanionBuilder =
    MedicineEntriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> dosage,
      required List<String> times,
      required List<int> repeatDays,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$MedicineEntriesTableUpdateCompanionBuilder =
    MedicineEntriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> dosage,
      Value<List<String>> times,
      Value<List<int>> repeatDays,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$MedicineEntriesTableFilterComposer
    extends Composer<_$HealthDatabase, $MedicineEntriesTable> {
  $$MedicineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get repeatDays =>
      $composableBuilder(
        column: $table.repeatDays,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicineEntriesTableOrderingComposer
    extends Composer<_$HealthDatabase, $MedicineEntriesTable> {
  $$MedicineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicineEntriesTableAnnotationComposer
    extends Composer<_$HealthDatabase, $MedicineEntriesTable> {
  $$MedicineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get repeatDays =>
      $composableBuilder(
        column: $table.repeatDays,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MedicineEntriesTableTableManager
    extends
        RootTableManager<
          _$HealthDatabase,
          $MedicineEntriesTable,
          MedicineEntry,
          $$MedicineEntriesTableFilterComposer,
          $$MedicineEntriesTableOrderingComposer,
          $$MedicineEntriesTableAnnotationComposer,
          $$MedicineEntriesTableCreateCompanionBuilder,
          $$MedicineEntriesTableUpdateCompanionBuilder,
          (
            MedicineEntry,
            BaseReferences<
              _$HealthDatabase,
              $MedicineEntriesTable,
              MedicineEntry
            >,
          ),
          MedicineEntry,
          PrefetchHooks Function()
        > {
  $$MedicineEntriesTableTableManager(
    _$HealthDatabase db,
    $MedicineEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicineEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicineEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicineEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> dosage = const Value.absent(),
                Value<List<String>> times = const Value.absent(),
                Value<List<int>> repeatDays = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicineEntriesCompanion(
                id: id,
                name: name,
                dosage: dosage,
                times: times,
                repeatDays: repeatDays,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> dosage = const Value.absent(),
                required List<String> times,
                required List<int> repeatDays,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => MedicineEntriesCompanion.insert(
                id: id,
                name: name,
                dosage: dosage,
                times: times,
                repeatDays: repeatDays,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicineEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$HealthDatabase,
      $MedicineEntriesTable,
      MedicineEntry,
      $$MedicineEntriesTableFilterComposer,
      $$MedicineEntriesTableOrderingComposer,
      $$MedicineEntriesTableAnnotationComposer,
      $$MedicineEntriesTableCreateCompanionBuilder,
      $$MedicineEntriesTableUpdateCompanionBuilder,
      (
        MedicineEntry,
        BaseReferences<_$HealthDatabase, $MedicineEntriesTable, MedicineEntry>,
      ),
      MedicineEntry,
      PrefetchHooks Function()
    >;

class $HealthDatabaseManager {
  final _$HealthDatabase _db;
  $HealthDatabaseManager(this._db);
  $$HealthMetricsTableTableManager get healthMetrics =>
      $$HealthMetricsTableTableManager(_db, _db.healthMetrics);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$FoodEntriesTableTableManager get foodEntries =>
      $$FoodEntriesTableTableManager(_db, _db.foodEntries);
  $$HealthGoalsTableTableManager get healthGoals =>
      $$HealthGoalsTableTableManager(_db, _db.healthGoals);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$MedicineEntriesTableTableManager get medicineEntries =>
      $$MedicineEntriesTableTableManager(_db, _db.medicineEntries);
}
