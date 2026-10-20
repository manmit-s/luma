import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class MemoryCategoryRepository implements CategoryRepository {
  MemoryCategoryRepository({List<CategoryModel>? seed})
      : _categories = List<CategoryModel>.from(seed ?? defaultCategories);

  final List<CategoryModel> _categories;

  @override
  Future<List<CategoryModel>> getAll() async => List<CategoryModel>.from(_categories);

  @override
  Future<void> save(CategoryModel category) async {
    final index = _categories.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      _categories.add(category);
    } else {
      _categories[index] = category;
    }
  }

  @override
  Future<void> delete(String id) async {
    _categories.removeWhere((category) => category.id == id);
  }
}
