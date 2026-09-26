import 'package:flutter_test/flutter_test.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/core/utils/format.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/services/merchant_learning.dart';

ExpenseController _controller() => ExpenseController(
      repository: MemoryExpenseRepository(),
      learning: MerchantLearning(),
    );

void main() {
  group('Expense management', () {
    test('updateExpense persists edits and refreshes list', () async {
      final controller = _controller();
      await controller.load();
      final original =
          controller.expenses.firstWhere((e) => e.id == 1);
      final updated = Expense(
        id: original.id,
        amountMinor: 99900,
        merchant: 'Edited Merchant',
        categoryId: 'travel',
        note: 'edited note',
        timestamp: original.timestamp,
        transactionType: original.transactionType,
        status: original.status,
        referenceNumber: original.referenceNumber,
        smsFingerprint: original.smsFingerprint,
        rawSms: original.rawSms,
        source: original.source,
        createdAt: original.createdAt,
        updatedAt: DateTime.now(),
        lastExportedAt: original.lastExportedAt,
      );
      await controller.updateExpense(updated);
      final reloaded =
          controller.expenses.firstWhere((e) => e.id == 1);
      expect(reloaded.amountMinor, 99900);
      expect(reloaded.merchant, 'Edited Merchant');
      expect(reloaded.categoryId, 'travel');
      expect(reloaded.note, 'edited note');
    });

    test('edited completed expense reappears in unexported', () async {
      final controller = _controller();
      await controller.load();
      final stamp = DateTime(2026, 9, 26, 10);
      final ids = controller.expenses.map((e) => e.id).toList();
      await controller.markExported(ids, stamp);
      expect(controller.unexported, isEmpty);

      final target = controller.expenses.first;
      await controller.updateExpense(target);
      expect(
        controller.unexported.map((e) => e.id),
        contains(target.id),
      );
    });

    test('deleteExpense removes the record', () async {
      final controller = _controller();
      await controller.load();
      final count = controller.expenses.length;
      await controller.deleteExpense(1);
      expect(controller.expenses.length, count - 1);
      expect(
        controller.expenses.where((e) => e.id == 1),
        isEmpty,
      );
    });
  });

  group('groupExpensesByDay', () {
    Expense at(int id, DateTime timestamp) => Expense(
          id: id,
          amountMinor: 100,
          merchant: 'M$id',
          categoryId: 'food',
          timestamp: timestamp,
          status: ExpenseStatus.completed,
          transactionType: TransactionType.debit,
          source: ExpenseSource.manual,
        );

    test('groups newest-first input preserving order', () {
      final groups = groupExpensesByDay([
        at(1, DateTime(2026, 9, 25, 18)),
        at(2, DateTime(2026, 9, 25, 8)),
        at(3, DateTime(2026, 9, 24, 12)),
      ]);
      expect(groups.length, 2);
      expect(groups[0].$1, DateTime(2026, 9, 25));
      expect(groups[0].$2.map((e) => e.id).toList(), [1, 2]);
      expect(groups[1].$1, DateTime(2026, 9, 24));
    });

    test('empty input yields no groups', () {
      expect(groupExpensesByDay([]), isEmpty);
    });
  });
}
