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
              icon: category.icon,
              sortOrder: category.sortOrder,
              isDefault: const Value(true),
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
        );
  }
}
