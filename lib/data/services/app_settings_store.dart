import 'package:drift/drift.dart';

import '../database/luma_database.dart';

/// Reads/writes the single `app_settings` row (id = 1).
///
/// Null database (tests, fallback) behaves as "already onboarded" so widget
/// tests never see the onboarding sheet.
class AppSettingsStore {
  AppSettingsStore(this._db, {bool memoryOnboardingDone = true})
      : _memoryOnboardingDone = memoryOnboardingDone;

  final LumaDatabase? _db;
  bool _memoryOnboardingDone;
  int _memoryInitialBalanceMinor = 0;

  Future<bool> isOnboardingDone() async {
    final db = _db;
    if (db == null) return _memoryOnboardingDone;
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      return row?.onboardingDone ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _updateSettings(AppSettingsCompanion companion) async {
    final db = _db;
    if (db == null) return;
    try {
      final updated = await (db.update(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .write(companion);
      if (updated == 0) {
        await db.into(db.appSettings).insert(
              companion.copyWith(id: const Value(1)),
            );
      }
    } catch (_) {
      // Best effort
    }
  }

  Future<void> markOnboardingDone() async {
    final db = _db;
    if (db == null) {
      _memoryOnboardingDone = true;
      return;
    }
    await _updateSettings(const AppSettingsCompanion(onboardingDone: Value(true)));
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
    await _updateSettings(
      AppSettingsCompanion(dailyAuditEnabled: Value(enabled)),
    );
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
    await _updateSettings(
      AppSettingsCompanion(userName: Value(trimmed.isEmpty ? null : trimmed)),
    );
  }

  /// Initial account balance snapshot (minor units, e.g. 100 = 1.00).
  Future<int> initialBalanceMinor() async {
    final db = _db;
    if (db == null) return _memoryInitialBalanceMinor;
    try {
      final row = await (db.select(db.appSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      return row?.initialBalanceMinor ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> setInitialBalanceMinor(int minor) async {
    final db = _db;
    if (db == null) {
      _memoryInitialBalanceMinor = minor;
      return;
    }
    await _updateSettings(
      AppSettingsCompanion(initialBalanceMinor: Value(minor)),
    );
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
