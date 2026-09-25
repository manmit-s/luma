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
}
