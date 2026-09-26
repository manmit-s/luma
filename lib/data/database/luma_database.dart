import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'luma_database.g.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMinor => integer()();
  TextColumn get merchant => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get smsFingerprint => text().nullable()();
  TextColumn get rawSms => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  // 0 = debit, 1 = credit, 2 = unknown
  IntColumn get transactionType => integer().withDefault(const Constant(0))();
  // 0 = pending, 1 = completed, 2 = ignored
  IntColumn get status => integer().withDefault(const Constant(0))();
  // 0 = sms, 1 = manual
  IntColumn get source => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastExportedAt => dateTime().nullable()();
}

class MerchantProfiles extends Table {
  TextColumn get normalizedMerchant => text()();
  TextColumn get displayMerchant => text()();
  // JSON-encoded {categoryId: count}
  TextColumn get categoryCounts => text().withDefault(const Constant('{}'))();
  TextColumn get lastUsedCategory => text().nullable()();
  IntColumn get totalTransactions => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {normalizedMerchant};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get dailyAuditEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get auditHour => integer().withDefault(const Constant(21))();
  IntColumn get auditMinute => integer().withDefault(const Constant(0))();
  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExportRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get fileName => text()();
  IntColumn get count => integer()();
}

@DriftDatabase(
  tables: [Expenses, MerchantProfiles, Categories, AppSettings, ExportRecords],
)
class LumaDatabase extends _$LumaDatabase {
  LumaDatabase() : super(_openConnection());

  LumaDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Raw SQL: drift 2.26's addColumn has a raw-generic signature
            // that rejects typed columns under current inference.
            await m.database.customStatement(
              'ALTER TABLE app_settings ADD COLUMN user_name TEXT NULL',
            );
          }
        },
      );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'luma.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
