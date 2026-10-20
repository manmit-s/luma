import '../entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<CategoryModel>> getAll();
  Future<void> save(CategoryModel category);
  Future<void> delete(String id);
}
