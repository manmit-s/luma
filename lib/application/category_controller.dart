import 'package:flutter/foundation.dart';

import '../data/repositories/memory_category_repository.dart';
import '../domain/entities/category.dart';
import '../domain/repositories/category_repository.dart';

class CategoryController extends ChangeNotifier {
  CategoryController({CategoryRepository? repository})
      : _repository = repository ?? MemoryCategoryRepository(),
        categories = List<CategoryModel>.from(defaultCategories);

  final CategoryRepository _repository;
  List<CategoryModel> categories;
  bool isLoading = false;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      final loaded = await _repository.getAll();
      categories = [...loaded]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      error = null;
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  CategoryModel? byId(String? id) {
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<void> save(CategoryModel category) async {
    await _repository.save(category);
    final index = categories.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      categories = [...categories, category];
    } else {
      final updated = [...categories];
      updated[index] = category;
      categories = updated;
    }
    _sortAndNotify();
  }

  Future<void> delete(CategoryModel category) async {
    if (category.isDefault) return;
    await _repository.delete(category.id);
    categories = categories.where((item) => item.id != category.id).toList();
    _sortAndNotify();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final updated = [...categories];
    if (oldIndex < newIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    categories = [
      for (var index = 0; index < updated.length; index++)
        updated[index].copyWith(sortOrder: index),
    ];
    notifyListeners();
    for (final category in categories) {
      await _repository.save(category);
    }
  }

  void _sortAndNotify() {
    categories = [...categories]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    notifyListeners();
  }

  String newId() => 'custom_${DateTime.now().microsecondsSinceEpoch}';
}
