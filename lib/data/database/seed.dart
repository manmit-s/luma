import 'package:drift/drift.dart';

import '../../domain/entities/category.dart';
import 'luma_database.dart';

Future<void> seedLumaDatabase(LumaDatabase db) async {
  for (final category in defaultCategories) {
    final existing = await (db.select(db.categories)
          ..where((t) => t.id.equals(category.id)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: category.id,
              name: category.name,
              icon: category.iconKey,
              iconKey: Value(category.iconKey),
              colorValue: Value(category.colorValue),
              sortOrder: category.sortOrder,
              isDefault: const Value(true),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } else if (existing.isDefault) {
      await (db.update(db.categories)
        ..where((row) => row.id.equals(category.id)))
          .write(
            CategoriesCompanion(
              name: Value(category.name),
              icon: Value(category.iconKey),
              iconKey: Value(category.iconKey),
              colorValue: Value(category.colorValue),
            ),
          );
    }
  }
  final settings =
      await (db.select(db.appSettings)..where((t) => t.id.equals(1)))
          .getSingleOrNull();
  if (settings == null) {
    await db.into(db.appSettings).insert(
          AppSettingsCompanion.insert(id: const Value(1)),
          mode: InsertMode.insertOrIgnore,
        );
  }
}
