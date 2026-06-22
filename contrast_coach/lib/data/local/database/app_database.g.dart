part of 'app_database.dart';

class SessionRow {
  final String id;
  final String? userId;
  final String protocolId;
  final String goal;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalPlannedDurationSec;
  final int totalActualDurationSec;
  final int roundsCompleted;
  final int protocolRounds;
  final double? recoveryScore;
  final String? notes;
  final String? healthDataSnapshot;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionRow({
    required this.id,
    this.userId,
    required this.protocolId,
    required this.goal,
    required this.startedAt,
    this.endedAt,
    required this.totalPlannedDurationSec,
    required this.totalActualDurationSec,
    required this.roundsCompleted,
    required this.protocolRounds,
    this.recoveryScore,
    this.notes,
    this.healthDataSnapshot,
    required this.isSynced,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
}

class PhaseRow {
  final String id;
  final String sessionId;
  final String type;
  final int orderIndex;
  final int plannedDurationSec;
  final int actualDurationSec;
  final double? targetTempC;
  final double? actualTempC;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool skipped;
  final String? voiceLog;

  const PhaseRow({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.orderIndex,
    required this.plannedDurationSec,
    required this.actualDurationSec,
    this.targetTempC,
    this.actualTempC,
    required this.startedAt,
    this.endedAt,
    required this.skipped,
    this.voiceLog,
  });
}

class StreakRow {
  final String date;
  final String sessionId;
  final int count;
  final DateTime createdAt;

  const StreakRow({
    required this.date,
    required this.sessionId,
    required this.count,
    required this.createdAt,
  });
}

class SettingRow {
  final String keyField;
  final String value;
  final DateTime updatedAt;

  const SettingRow({
    required this.keyField,
    required this.value,
    required this.updatedAt,
  });
}

class HealthSnapshotRow {
  final String id;
  final DateTime capturedAt;
  final int? sleepMinutes;
  final double? hrvRmssd7DayAvg;
  final double? hrvRmssdTrend7Day;
  final double? restingHr7DayAvg;
  final double? restingHrTrend7Day;
  final int? stepsYesterday;
  final DateTime? lastWorkoutAt;

  const HealthSnapshotRow({
    required this.id,
    required this.capturedAt,
    this.sleepMinutes,
    this.hrvRmssd7DayAvg,
    this.hrvRmssdTrend7Day,
    this.restingHr7DayAvg,
    this.restingHrTrend7Day,
    this.stepsYesterday,
    this.lastWorkoutAt,
  });
}

class CustomProtocolRow {
  final String id;
  final String name;
  final String description;
  final int rounds;
  final String phasesJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomProtocolRow({
    required this.id,
    required this.name,
    required this.description,
    required this.rounds,
    required this.phasesJson,
    required this.createdAt,
    required this.updatedAt,
  });
}

class SessionsCompanion {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> protocolId;
  final Value<String> goal;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> totalPlannedDurationSec;
  final Value<int> totalActualDurationSec;
  final Value<int> roundsCompleted;
  final Value<int> protocolRounds;
  final Value<double?> recoveryScore;
  final Value<String?> notes;
  final Value<String?> healthDataSnapshot;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;

  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.protocolId = const Value.absent(),
    this.goal = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalPlannedDurationSec = const Value.absent(),
    this.totalActualDurationSec = const Value.absent(),
    this.roundsCompleted = const Value.absent(),
    this.protocolRounds = const Value.absent(),
    this.recoveryScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.healthDataSnapshot = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });

  const SessionsCompanion.insert({
    required String id,
    Value<String?> userId = const Value.absent(),
    required String protocolId,
    required String goal,
    required DateTime startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    required int totalPlannedDurationSec,
    required int totalActualDurationSec,
    required int roundsCompleted,
    required int protocolRounds,
    Value<double?> recoveryScore = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> healthDataSnapshot = const Value.absent(),
    Value<bool> isSynced = const Value.absent(),
    Value<bool> isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = Value(id),
       userId = userId,
       protocolId = Value(protocolId),
       goal = Value(goal),
       startedAt = Value(startedAt),
       endedAt = endedAt,
       totalPlannedDurationSec = Value(totalPlannedDurationSec),
       totalActualDurationSec = Value(totalActualDurationSec),
       roundsCompleted = Value(roundsCompleted),
       protocolRounds = Value(protocolRounds),
       recoveryScore = recoveryScore,
       notes = notes,
       healthDataSnapshot = healthDataSnapshot,
       isSynced = isSynced,
       isDeleted = isDeleted,
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
}

class PhasesCompanion {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> type;
  final Value<int> orderIndex;
  final Value<int> plannedDurationSec;
  final Value<int> actualDurationSec;
  final Value<double?> targetTempC;
  final Value<double?> actualTempC;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> skipped;
  final Value<String?> voiceLog;

  const PhasesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.targetTempC = const Value.absent(),
    this.actualTempC = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.skipped = const Value.absent(),
    this.voiceLog = const Value.absent(),
  });

  const PhasesCompanion.insert({
    required String id,
    required String sessionId,
    required String type,
    required int orderIndex,
    required int plannedDurationSec,
    required int actualDurationSec,
    Value<double?> targetTempC = const Value.absent(),
    Value<double?> actualTempC = const Value.absent(),
    required DateTime startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<bool> skipped = const Value.absent(),
    Value<String?> voiceLog = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       type = Value(type),
       orderIndex = Value(orderIndex),
       plannedDurationSec = Value(plannedDurationSec),
       actualDurationSec = Value(actualDurationSec),
       targetTempC = targetTempC,
       actualTempC = actualTempC,
       startedAt = Value(startedAt),
       endedAt = endedAt,
       skipped = skipped,
       voiceLog = voiceLog;
}

class CustomProtocolsCompanion {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> rounds;
  final Value<String> phasesJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;

  const CustomProtocolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rounds = const Value.absent(),
    this.phasesJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });

  const CustomProtocolsCompanion.insert({
    required String id,
    required String name,
    required String description,
    required int rounds,
    required String phasesJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       rounds = Value(rounds),
       phasesJson = Value(phasesJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
}

mixin $SessionsMixin on DatabaseAccessor<AppDatabase> {
  $SessionsTable get sessions => attachedDatabase.sessions;
}
mixin $PhasesMixin on DatabaseAccessor<AppDatabase> {
  $PhasesTable get phases => attachedDatabase.phases;
}
mixin $StreaksMixin on DatabaseAccessor<AppDatabase> {
  $StreaksTable get streaks => attachedDatabase.streaks;
}
mixin $SettingsMixin on DatabaseAccessor<AppDatabase> {
  $SettingsTable get settings => attachedDatabase.settings;
}
mixin $HealthSnapshotsMixin on DatabaseAccessor<AppDatabase> {
  $HealthSnapshotsTable get healthSnapshots => attachedDatabase.healthSnapshots;
}
mixin $CustomProtocolsMixin on DatabaseAccessor<AppDatabase> {
  $CustomProtocolsTable get customProtocols => attachedDatabase.customProtocols;
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, SessionRow> {
  @override
  bool get isGenerated => true;

  @override
  String get actualTableName => 'sessions';

  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: data['${prefix}id'] as String,
      userId: data['${prefix}user_id'] as String?,
      protocolId: data['${prefix}protocol_id'] as String,
      goal: data['${prefix}goal'] as String,
      startedAt: data['${prefix}started_at'] as DateTime,
      endedAt: data['${prefix}ended_at'] as DateTime?,
      totalPlannedDurationSec: data['${prefix}total_planned_duration_sec'] as int,
      totalActualDurationSec: data['${prefix}total_actual_duration_sec'] as int,
      roundsCompleted: data['${prefix}rounds_completed'] as int,
      protocolRounds: data['${prefix}protocol_rounds'] as int,
      recoveryScore: data['${prefix}recovery_score'] as double?,
      notes: data['${prefix}notes'] as String?,
      healthDataSnapshot: data['${prefix}health_data_snapshot'] as String?,
      isSynced: data['${prefix}is_synced'] as bool,
      isDeleted: data['${prefix}is_deleted'] as bool,
      createdAt: data['${prefix}created_at'] as DateTime,
      updatedAt: data['${prefix}updated_at'] as DateTime,
    );
  }

  @override
  $SessionsTable createAlias(String alias) => $SessionsTable();

  @override
  bool get dontWriteConstraints => false;

  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {
    id, userId, protocolId, goal, startedAt, endedAt,
    totalPlannedDurationSec, totalActualDurationSec,
    roundsCompleted, protocolRounds, recoveryScore, notes,
    healthDataSnapshot, isSynced, isDeleted, createdAt, updatedAt,
  };

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}

class $PhasesTable extends Phases with TableInfo<$PhasesTable, PhaseRow> {
  @override
  bool get isGenerated => true;

  @override
  String get actualTableName => 'phases';

  @override
  PhaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseRow(
      id: data['${prefix}id'] as String,
      sessionId: data['${prefix}session_id'] as String,
      type: data['${prefix}type'] as String,
      orderIndex: data['${prefix}order_index'] as int,
      plannedDurationSec: data['${prefix}planned_duration_sec'] as int,
      actualDurationSec: data['${prefix}actual_duration_sec'] as int,
      targetTempC: data['${prefix}target_temp_c'] as double?,
      actualTempC: data['${prefix}actual_temp_c'] as double?,
      startedAt: data['${prefix}started_at'] as DateTime,
      endedAt: data['${prefix}ended_at'] as DateTime?,
      skipped: data['${prefix}skipped'] as bool,
      voiceLog: data['${prefix}voice_log'] as String?,
    );
  }

  @override
  $PhasesTable createAlias(String alias) => $PhasesTable();

  @override
  bool get dontWriteConstraints => false;
  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {
    id, sessionId, type, orderIndex, plannedDurationSec,
    actualDurationSec, targetTempC, actualTempC, startedAt,
    endedAt, skipped, voiceLog,
  };

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [];
}

class $StreaksTable extends Streaks with TableInfo<$StreaksTable, StreakRow> {
  @override
  bool get isGenerated => true;
  @override
  String get actualTableName => 'streaks';

  @override
  StreakRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakRow(
      date: data['${prefix}date'] as String,
      sessionId: data['${prefix}session_id'] as String,
      count: data['${prefix}count'] as int,
      createdAt: data['${prefix}created_at'] as DateTime,
    );
  }

  @override
  $StreaksTable createAlias(String alias) => $StreaksTable();
  @override
  bool get dontWriteConstraints => false;
  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {date, sessionId, count, createdAt};
  @override
  Set<Column> get primaryKey => {date};
  @override
  List<Set<Column>> get uniqueKeys => [];
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, SettingRow> {
  @override
  bool get isGenerated => true;
  @override
  String get actualTableName => 'settings';

  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      keyField: data['${prefix}key_field'] as String,
      value: data['${prefix}value'] as String,
      updatedAt: data['${prefix}updated_at'] as DateTime,
    );
  }

  @override
  $SettingsTable createAlias(String alias) => $SettingsTable();
  @override
  bool get dontWriteConstraints => false;
  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {keyField, value, updatedAt};
  @override
  Set<Column> get primaryKey => {keyField};
  @override
  List<Set<Column>> get uniqueKeys => [];
}

class $HealthSnapshotsTable extends HealthSnapshots with TableInfo<$HealthSnapshotsTable, HealthSnapshotRow> {
  @override
  bool get isGenerated => true;
  @override
  String get actualTableName => 'health_snapshots';

  @override
  HealthSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthSnapshotRow(
      id: data['${prefix}id'] as String,
      capturedAt: data['${prefix}captured_at'] as DateTime,
      sleepMinutes: data['${prefix}sleep_minutes'] as int?,
      hrvRmssd7DayAvg: data['${prefix}hrv_rmssd7_day_avg'] as double?,
      hrvRmssdTrend7Day: data['${prefix}hrv_rmssd_trend7_day'] as double?,
      restingHr7DayAvg: data['${prefix}resting_hr7_day_avg'] as double?,
      restingHrTrend7Day: data['${prefix}resting_hr_trend7_day'] as double?,
      stepsYesterday: data['${prefix}steps_yesterday'] as int?,
      lastWorkoutAt: data['${prefix}last_workout_at'] as DateTime?,
    );
  }

  @override
  $HealthSnapshotsTable createAlias(String alias) => $HealthSnapshotsTable();
  @override
  bool get dontWriteConstraints => false;
  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {
    id, capturedAt, sleepMinutes, hrvRmssd7DayAvg,
    hrvRmssdTrend7Day, restingHr7DayAvg, restingHrTrend7Day,
    stepsYesterday, lastWorkoutAt,
  };
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [];
}

class $CustomProtocolsTable extends CustomProtocols with TableInfo<$CustomProtocolsTable, CustomProtocolRow> {
  @override
  bool get isGenerated => true;
  @override
  String get actualTableName => 'custom_protocols';

  @override
  CustomProtocolRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomProtocolRow(
      id: data['${prefix}id'] as String,
      name: data['${prefix}name'] as String,
      description: data['${prefix}description'] as String,
      rounds: data['${prefix}rounds'] as int,
      phasesJson: data['${prefix}phases_json'] as String,
      createdAt: data['${prefix}created_at'] as DateTime,
      updatedAt: data['${prefix}updated_at'] as DateTime,
    );
  }

  @override
  $CustomProtocolsTable createAlias(String alias) => $CustomProtocolsTable();
  @override
  bool get dontWriteConstraints => false;
  @override
  String get filePath => 'app_database.dart';

  @override
  Set<Column> get $columns => {
    id, name, description, rounds, phasesJson, createdAt, updatedAt,
  };
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [];
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);

  late final $SessionsTable sessions = $SessionsTable();
  late final $PhasesTable phases = $PhasesTable();
  late final $StreaksTable streaks = $StreaksTable();
  late final $SettingsTable settings = $SettingsTable();
  late final $HealthSnapshotsTable healthSnapshots = $HealthSnapshotsTable();
  late final $CustomProtocolsTable customProtocols = $CustomProtocolsTable();

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => [
    sessions,
    phases,
    streaks,
    settings,
    healthSnapshots,
    customProtocols,
  ];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
