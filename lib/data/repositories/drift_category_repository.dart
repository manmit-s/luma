import 'package:drift/drift.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/luma_database.dart';

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._db);

  final LumaDatabase _db;

  @override
  Future<List<CategoryModel>> getAll() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([(category) => OrderingTerm.asc(category.sortOrder)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<void> save(CategoryModel category) async {
    await _db.into(_db.categories).insertOnConflictUpdate(
          CategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            icon: category.iconKey,
            iconKey: Value(category.iconKey),
            colorValue: Value(category.colorValue),
            sortOrder: category.sortOrder,
            isDefault: Value(category.isDefault),
          ),
        );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.categories)..where((category) => category.id.equals(id))).go();
  }

  CategoryModel _toModel(Category row) => CategoryModel(
        id: row.id,
        name: row.name,
        iconKey: row.iconKey,
        colorValue: row.colorValue,
        sortOrder: row.sortOrder,
        isDefault: row.isDefault,
      );
}
