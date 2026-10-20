import 'package:flutter_test/flutter_test.dart';

import 'package:luma/application/category_controller.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/data/repositories/memory_category_repository.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/domain/entities/category.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/app/widgets/category_icon.dart';

void main() {
  test('category reorder persists sort order and protects defaults', () async {
    final repository = MemoryCategoryRepository();
    final controller = CategoryController(repository: repository);

    await controller.reorder(0, 3);
    expect(controller.categories[0].id, 'travel');
    expect(controller.categories[2].id, 'food');
    expect(controller.categories[0].sortOrder, 0);
    expect(controller.categories[2].sortOrder, 2);

    await controller.delete(controller.categories.first);
    expect(controller.categories, hasLength(defaultCategories.length));
  });

  test('custom categories can be added and deleted', () async {
    final controller = CategoryController(repository: MemoryCategoryRepository());
    final custom = CategoryModel(
      id: controller.newId(),
      name: 'Pets',
      iconKey: 'other',
      colorValue: 0xFFE68A6B,
      sortOrder: 10,
      isDefault: false,
    );

    await controller.save(custom);
    expect(controller.byId(custom.id)?.name, 'Pets');
    await controller.delete(custom);
    expect(controller.byId(custom.id), isNull);
  });

  test('manual expense keeps the selected timestamp', () async {
    final repository = MemoryExpenseRepository(seed: false);
    final controller = ExpenseController(repository: repository);
    final timestamp = DateTime(2026, 10, 20, 14, 30);

    await controller.addManual(
      amountMinor: 1250,
      merchant: 'Cafe',
      categoryId: 'food',
      timestamp: timestamp,
    );

    expect(controller.expenses.single.timestamp, timestamp);
    expect(controller.expenses.single.source, ExpenseSource.manual);
  });

  test('icon search aliases gym to the dumbbell icon', () {
    final matches = categoryIconOptions
        .where((option) => option.matches('gym'))
        .toList();

    expect(matches.map((option) => option.key), contains('dumbbell'));
    expect(matches.single.label, 'Dumbbell');
  });
}
