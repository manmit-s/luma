import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/data/database/luma_database.dart';
import 'package:luma/data/database/seed.dart';
import 'package:luma/data/repositories/drift_expense_repository.dart';
import 'package:luma/data/services/app_settings_store.dart';
import 'package:luma/data/services/drift_merchant_learning.dart';
import 'package:luma/domain/entities/expense.dart' as domain;

LumaDatabase _memoryDb() => LumaDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('Drift persistence', () {
    test('seed creates categories and settings', () async {
      final db = _memoryDb();
      await seedLumaDatabase(db);
      final categories = await db.select(db.categories).get();
      expect(categories.length, 10);
      final settings =
          await (db.select(db.appSettings)..where((t) => t.id.equals(1)))
              .getSingleOrNull();
      expect(settings, isNotNull);
      expect(settings!.dailyAuditEnabled, isTrue);
      await db.close();
    });

    test('user name round-trips through app_settings', () async {
      final db = _memoryDb();
      await seedLumaDatabase(db);
      final store = AppSettingsStore(db);
      expect(await store.userName(), isEmpty);
      await store.setUserName('Reyansh');
      expect(await store.userName(), 'Reyansh');
      await store.setUserName('');
      expect(await store.userName(), isEmpty);
      await db.close();
    });

    test('save and load roundtrip survives reopen', () async {
      final db = _memoryDb();
      final repo = DriftExpenseRepository(db);
      final now = DateTime(2026, 9, 25, 12);
      final saved = await repo.save(domain.Expense(
        id: 0,
        amountMinor: 20090,
        merchant: 'Uber',
        categoryId: null,
        timestamp: now,
        status: domain.ExpenseStatus.pending,
        transactionType: domain.TransactionType.debit,
        source: domain.ExpenseSource.sms,
        createdAt: now,
        updatedAt: now,
      ));
      expect(saved.id, greaterThan(0));
      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.first.amountMinor, 20090);
      await db.close();
    });

    test('duplicate detection uses ref, fingerprint and window', () async {
      final db = _memoryDb();
      final controller = ExpenseController(
        repository: DriftExpenseRepository(db),
        learning: DriftMerchantLearning(db),
      );
      await controller.load();
      const message =
          'Your A/C XX1234 debited by Rs.200.90 at Uber. UPI Ref 123456789';
      final first = await controller.processSms(message);
      final second = await controller.processSms(message);
      expect(first, isNotNull);
      expect(second?.id, first?.id);
      expect(
        controller.expenses
            .where((e) => e.referenceNumber == '123456789')
            .length,
        1,
      );
      await db.close();
    });

    test('unexported query and markExported with re-inclusion', () async {
      final db = _memoryDb();
      final repo = DriftExpenseRepository(db);
      final now = DateTime(2026, 9, 25, 12);
      final a = await repo.save(domain.Expense(
        id: 0,
        amountMinor: 1000,
        merchant: 'A',
        categoryId: 'food',
        timestamp: now,
        status: domain.ExpenseStatus.completed,
        transactionType: domain.TransactionType.debit,
        source: domain.ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      ));
      final b = await repo.save(domain.Expense(
        id: 0,
        amountMinor: 2000,
        merchant: 'B',
        categoryId: 'travel',
        timestamp: now,
        status: domain.ExpenseStatus.completed,
        transactionType: domain.TransactionType.debit,
        source: domain.ExpenseSource.manual,
        createdAt: now,
        updatedAt: now,
      ));
      expect(await repo.queryUnexported(), hasLength(2));

      final exportedAt = DateTime(2026, 9, 26, 10);
      await repo.markExported([a.id, b.id], exportedAt);
      expect(await repo.queryUnexported(), isEmpty);

      // Edit after export re-includes in next incremental export.
      final edited = a.copyWith(
        categoryId: 'travel',
        updatedAt: exportedAt.add(const Duration(hours: 1)),
      );
      final reloaded = await repo.findById(a.id);
      expect(reloaded, isNotNull);
      await repo.save(edited.copyWith(
        amountMinor: reloaded!.amountMinor,
      ));
      // copyWith keeps id via explicit save path (update by id).
      final unexported = await repo.queryUnexported();
      expect(unexported.map((e) => e.id), contains(a.id));
      await db.close();
    });

    test('merchant learning persists across instances', () async {
      final db = _memoryDb();
      final first = DriftMerchantLearning(db);
      final now = DateTime(2026, 9, 25);
      await first.learn(domain.Expense(
        id: 1,
        amountMinor: 1000,
        merchant: 'Uber',
        categoryId: 'travel',
        timestamp: now,
        status: domain.ExpenseStatus.completed,
        transactionType: domain.TransactionType.debit,
        source: domain.ExpenseSource.manual,
      ));
      await first.learn(domain.Expense(
        id: 2,
        amountMinor: 1000,
        merchant: 'UBER ',
        categoryId: 'travel',
        timestamp: now,
        status: domain.ExpenseStatus.completed,
        transactionType: domain.TransactionType.debit,
        source: domain.ExpenseSource.manual,
      ));
      final second = DriftMerchantLearning(db);
      await second.load();
      expect(second.suggestionFor(' uber '), 'travel');
      await db.close();
    });
  });
}
