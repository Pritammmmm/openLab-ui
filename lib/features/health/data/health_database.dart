import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../medicine/data/medicine_model.dart';
import 'drift_converters.dart';

part 'health_database.g.dart';

// ─────────────────────────────────────────────
// Tables
// ─────────────────────────────────────────────

class HealthMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  RealColumn get value => real()();
  RealColumn get value2 => real().nullable()();
  RealColumn get value3 => real().nullable()();
  RealColumn get value4 => real().nullable()();
  TextColumn get subType => text().nullable()();
  TextColumn get unit => text()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get notes => text().nullable()();
  TextColumn get profileId => text().nullable()();
  TextColumn get externalId => text().nullable()();
  BoolColumn get syncedToBackend =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class DailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dateKey => text().unique()();
  IntColumn get steps => integer().withDefault(const Constant(0))();
  IntColumn get caloriesConsumed =>
      integer().withDefault(const Constant(0))();
  IntColumn get caloriesBurned =>
      integer().withDefault(const Constant(0))();
  IntColumn get waterGlasses =>
      integer().withDefault(const Constant(0))();
  IntColumn get sleepMinutes =>
      integer().withDefault(const Constant(0))();
  TextColumn get sleepQuality => text().nullable()();
  TextColumn get profileId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get updatedAt => dateTime()();
}

class FoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get calories => integer()();
  RealColumn get protein => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get fiber => real().nullable()();
  TextColumn get mealType => text()();
  RealColumn get servingSize => real().nullable()();
  TextColumn get servingUnit => text().nullable()();
  TextColumn get profileId => text().nullable()();
  DateTimeColumn get consumedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

class HealthGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get metricType => text()();
  RealColumn get targetValue => real()();
  RealColumn get minValue => real().nullable()();
  RealColumn get maxValue => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get profileId => text().nullable()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

class SyncMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get platform => text()();
  TextColumn get dataType => text()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  BoolColumn get enabled =>
      boolean().withDefault(const Constant(false))();
}

class MedicineEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosage => text().nullable()();
  TextColumn get times =>
      text().map(const StringListConverter())();
  TextColumn get repeatDays =>
      text().map(const IntListConverter())();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

// ─────────────────────────────────────────────
// Database
// ─────────────────────────────────────────────

@DriftDatabase(tables: [
  HealthMetrics,
  DailyLogs,
  FoodEntries,
  HealthGoals,
  SyncMetadata,
  MedicineEntries,
])
class HealthDatabase extends _$HealthDatabase {
  HealthDatabase._() : super(_openConnection());

  static HealthDatabase? _instance;

  static HealthDatabase get instance {
    _instance ??= HealthDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(medicineEntries);
          }
        },
      );

  // ─── Health Metrics ───

  Stream<List<HealthMetric>> watchMetricsByType(
    String type, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    final query = select(healthMetrics)
      ..where((t) => t.type.equals(type))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
      ]);
    if (from != null) {
      query.where((t) => t.recordedAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.recordedAt.isSmallerOrEqualValue(to));
    }
    if (limit != null) query.limit(limit);
    return query.watch();
  }

  Future<List<HealthMetric>> getMetricsByType(
    String type, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    final query = select(healthMetrics)
      ..where((t) => t.type.equals(type))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
      ]);
    if (from != null) {
      query.where((t) => t.recordedAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.recordedAt.isSmallerOrEqualValue(to));
    }
    if (limit != null) query.limit(limit);
    return query.get();
  }

  Future<HealthMetric?> getLatestMetric(String type) async {
    final query = select(healthMetrics)
      ..where((t) => t.type.equals(type))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Stream<HealthMetric?> watchLatestMetric(String type) {
    final query = select(healthMetrics)
      ..where((t) => t.type.equals(type))
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)
      ])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<int> insertMetric(HealthMetricsCompanion entry) =>
      into(healthMetrics).insert(entry);

  Future<bool> updateMetric(HealthMetricsCompanion entry) =>
      update(healthMetrics).replace(entry);

  Future<HealthMetric?> getMetricByExternalId(String externalId) {
    final query = select(healthMetrics)
      ..where((t) => t.externalId.equals(externalId))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> deleteMetric(int id) =>
      (delete(healthMetrics)..where((t) => t.id.equals(id))).go();

  // ─── Daily Logs ───

  Stream<DailyLog?> watchDailyLog(String dateKey) {
    final query = select(dailyLogs)
      ..where((t) => t.dateKey.equals(dateKey));
    return query.watchSingleOrNull();
  }

  Future<DailyLog?> getDailyLog(String dateKey) {
    final query = select(dailyLogs)
      ..where((t) => t.dateKey.equals(dateKey));
    return query.getSingleOrNull();
  }

  Future<void> upsertDailyLog(DailyLogsCompanion entry) =>
      into(dailyLogs).insert(
        entry,
        onConflict: DoUpdate((old) => entry, target: [dailyLogs.dateKey]),
      );

  Future<List<DailyLog>> getDailyLogRange(String fromKey, String toKey) {
    final query = select(dailyLogs)
      ..where((t) =>
          t.dateKey.isBiggerOrEqualValue(fromKey) &
          t.dateKey.isSmallerOrEqualValue(toKey))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dateKey, mode: OrderingMode.asc)
      ]);
    return query.get();
  }

  Stream<List<DailyLog>> watchDailyLogRange(String fromKey, String toKey) {
    final query = select(dailyLogs)
      ..where((t) =>
          t.dateKey.isBiggerOrEqualValue(fromKey) &
          t.dateKey.isSmallerOrEqualValue(toKey))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dateKey, mode: OrderingMode.asc)
      ]);
    return query.watch();
  }

  // ─── Food Entries ───

  Stream<List<FoodEntry>> watchFoodEntries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final query = select(foodEntries)
      ..where(
          (t) => t.consumedAt.isBiggerOrEqualValue(start) & t.consumedAt.isSmallerThanValue(end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.consumedAt, mode: OrderingMode.desc)
      ]);
    return query.watch();
  }

  Future<List<FoodEntry>> getFoodEntriesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final query = select(foodEntries)
      ..where(
          (t) => t.consumedAt.isBiggerOrEqualValue(start) & t.consumedAt.isSmallerThanValue(end));
    return query.get();
  }

  Future<int> insertFoodEntry(FoodEntriesCompanion entry) =>
      into(foodEntries).insert(entry);

  Future<int> deleteFoodEntry(int id) =>
      (delete(foodEntries)..where((t) => t.id.equals(id))).go();

  // ─── Goals ───

  Stream<List<HealthGoal>> watchGoals() {
    final query = select(healthGoals)
      ..where((t) => t.isActive.equals(true));
    return query.watch();
  }

  Future<HealthGoal?> getGoalForMetric(String metricType) {
    final query = select(healthGoals)
      ..where(
          (t) => t.metricType.equals(metricType) & t.isActive.equals(true))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> insertGoal(HealthGoalsCompanion entry) =>
      into(healthGoals).insert(entry);

  Future<bool> updateGoal(HealthGoalsCompanion entry) =>
      update(healthGoals).replace(entry);

  Future<int> deleteGoal(int id) =>
      (delete(healthGoals)..where((t) => t.id.equals(id))).go();

  // ─── Sync Metadata ───

  Future<SyncMetadataData?> getSyncMeta(String platform, String dataType) {
    final query = select(syncMetadata)
      ..where(
          (t) => t.platform.equals(platform) & t.dataType.equals(dataType))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> upsertSyncMeta(SyncMetadataCompanion entry) async {
    final platform = entry.platform.value;
    final dataType = entry.dataType.value;
    final existing = await getSyncMeta(platform, dataType);

    if (existing != null) {
      await (update(syncMetadata)..where((t) => t.id.equals(existing.id)))
          .write(entry);
    } else {
      await into(syncMetadata).insert(entry);
    }
  }

  // Medicine Reminders

  Stream<List<Medicine>> watchMedicines() {
    final query = select(medicineEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_mapMedicineRow).toList());
  }

  Future<List<Medicine>> getAllMedicines() async {
    final query = select(medicineEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    return rows.map(_mapMedicineRow).toList(growable: false);
  }

  Future<Medicine?> getMedicineById(int id) async {
    final query = select(medicineEntries)
      ..where((t) => t.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapMedicineRow(row);
  }

  Future<int> insertMedicine(Medicine medicine) {
    return into(medicineEntries).insert(_medicineToCompanion(medicine));
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await (update(medicineEntries)..where((t) => t.id.equals(medicine.id)))
        .write(_medicineToCompanion(medicine, includeId: false));
  }

  Future<bool> deleteMedicine(int id) {
    return (delete(medicineEntries)..where((t) => t.id.equals(id))).go().then(
          (count) => count > 0,
        );
  }

  Medicine _mapMedicineRow(MedicineEntry row) {
    return Medicine(
      id: row.id,
      name: row.name,
      dosage: row.dosage,
      times: List.unmodifiable(row.times),
      repeatDays: List.unmodifiable(row.repeatDays),
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }

  MedicineEntriesCompanion _medicineToCompanion(
    Medicine medicine, {
    bool includeId = true,
  }) {
    return MedicineEntriesCompanion(
      id: includeId ? Value(medicine.id) : const Value.absent(),
      name: Value(medicine.name),
      dosage: Value(medicine.dosage),
      times: Value(List<String>.from(medicine.times)),
      repeatDays: Value(List<int>.from(medicine.repeatDays)),
      isActive: Value(medicine.isActive),
      createdAt: Value(medicine.createdAt),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'health.db'));
    return NativeDatabase.createInBackground(file);
  });
}
