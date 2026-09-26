import 'package:drift/drift.dart';

import '../database/luma_database.dart';

/// Reads/writes the single `app_settings` row (id = 1).
///
/// Null database (tests, fallback) behaves as "already onboarded" so widget
/// tests never see the onboarding sheet.
class AppSettingsStore {
  AppSettingsStore(this._db);

  final LumaDatabase? _db;
  bool _memoryOnboardingDone = true;

  Future<bool> isOnboardingDone() async {
    final db = _db;
    if (db == null) return _memoryOnboardingDone;
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      return row?.onboardingDone ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> markOnboardingDone() async {
    final db = _db;
    if (db == null) {
      _memoryOnboardingDone = true;
      return;
    }
    try {
      await db.into(db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(id: const Value(1)),
          );
      await (db.update(db.appSettings)..where((t) => t.id.equals(1))).write(
        const AppSettingsCompanion(onboardingDone: Value(true)),
      );
    } catch (_) {
      // Best effort: onboarding is UX, never crash for it.
    }
  }

  Future<bool> isDailyAuditEnabled() async {
    final db = _db;
    if (db == null) return _memoryAuditEnabled;
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      return row?.dailyAuditEnabled ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setDailyAuditEnabled(bool enabled) async {
    final db = _db;
    if (db == null) {
      _memoryAuditEnabled = enabled;
      return;
    }
    try {
      await db.into(db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              id: const Value(1),
              dailyAuditEnabled: Value(enabled),
            ),
          );
      await (db.update(db.appSettings)..where((t) => t.id.equals(1))).write(
        AppSettingsCompanion(dailyAuditEnabled: Value(enabled)),
      );
    } catch (_) {
      // Best effort.
    }
  }

  bool _memoryAuditEnabled = true;
  String _memoryUserName = '';

  /// Display name for the greeting. Empty means "not set".
  Future<String> userName() async {
    final db = _db;
    if (db == null) return _memoryUserName;
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      return row?.userName?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    final db = _db;
    if (db == null) {
      _memoryUserName = trimmed;
      return;
    }
    try {
      await db.into(db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(id: const Value(1)),
          );
      await (db.update(db.appSettings)..where((t) => t.id.equals(1))).write(
        AppSettingsCompanion(userName: Value(trimmed.isEmpty ? null : trimmed)),
      );
    } catch (_) {
      // Best effort.
    }
  }

  /// [hour], [minute] default to 21:00 (SPEC 42). Null-DB default matches.
  Future<(int, int)> auditTime() async {
    final db = _db;
    if (db == null) return (21, 0);
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      if (row == null) return (21, 0);
      return (row.auditHour, row.auditMinute);
    } catch (_) {
      return (21, 0);
    }
  }
}
