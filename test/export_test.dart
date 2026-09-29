import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/data/services/app_settings_store.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/services/export/export_service.dart';

ExportService _service(
  MemoryExpenseRepository repo,
  Directory dir,
) =>
    ExportService(repo, null, outputDir: () async => dir);

Future<Expense> _add(
  MemoryExpenseRepository repo, {
  required int amountMinor,
  required String merchant,
  String categoryId = 'food',
  DateTime? at,
  String? ref,
}) async {
  final timestamp = at ?? DateTime(2026, 9, 25, 12);
  return repo.save(Expense(
    id: 0,
    amountMinor: amountMinor,
    merchant: merchant,
    categoryId: categoryId,
    timestamp: timestamp,
    status: ExpenseStatus.completed,
    transactionType: TransactionType.debit,
    source: ExpenseSource.manual,
    referenceNumber: ref,
    createdAt: timestamp,
    updatedAt: timestamp,
  ));
}

List<List<dynamic>> _rows(File file) {
  final bytes = file.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  final table = excel.tables['Expenses'];
  expect(table, isNotNull, reason: 'Expenses sheet must exist');
  return table!.rows
      .map((row) => row.map(_unwrap).toList())
      .toList();
}

dynamic _unwrap(Data? cell) {
  final value = cell?.value;
  if (value is TextCellValue) return value.value.toString();
  if (value is DoubleCellValue) return value.value;
  if (value is IntCellValue) return value.value;
  if (value is BoolCellValue) return value.value;
  return value?.toString();
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('luma_export_test');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  group('ExportService', () {
    test('empty history throws without marking anything', () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      final service = _service(repo, dir);
      expect(
        () => service.generate(ExportMode.full),
        throwsA(isA<ExportException>()),
      );
      expect(
        () => service.generate(ExportMode.incremental),
        throwsA(isA<ExportException>()),
      );
    });

    test('single expense produces a readable file with stable columns',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      await _add(repo, amountMinor: 20090, merchant: 'Uber', ref: 'R1');
      final service = _service(repo, dir);

      final result = await service.generate(
        ExportMode.full,
        now: DateTime(2026, 9, 25, 20, 15),
      );

      expect(result.count, 1);
      expect(result.totalMinor, 20090);
      expect(result.file.existsSync(), isTrue);
      expect(
        result.file.path,
        endsWith('Luma_Expenses_2026-09-25_20-15.xlsx'),
      );
      final rows = _rows(result.file);
      // 6 summary rows + 1 header row + 1 data row = 8 rows
      expect(rows.length, 8);
      expect(
        rows[6].map((v) => '$v').toList(),
        exportColumns,
      );
      // Description is index 2, Type is index 4, Amount is index 5, Balance is index 6, Ref is index 8
      expect(rows[7][2], 'Uber');
      expect(rows[7][4], 'debit');
      expect(rows[7][5], isA<num>());
      expect((rows[7][5] as num).toDouble(), 200.9);
      expect(rows[7][6], isA<num>());
      expect(rows[7][8], 'R1');
      // Export marks persisted only after successful generation.
      expect(await repo.queryUnexported(), isEmpty);
    });

    test('incremental export excludes previously exported expenses',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      await _add(repo, amountMinor: 1000, merchant: 'A',
          at: DateTime(2026, 9, 23, 10));
      await _add(repo, amountMinor: 2000, merchant: 'B',
          at: DateTime(2026, 9, 24, 10));
      await _add(repo, amountMinor: 3000, merchant: 'C',
          at: DateTime(2026, 9, 24, 12));
      final service = _service(repo, dir);

      final day1 = await service.generate(ExportMode.incremental);
      expect(day1.count, 3);
      // 6 summary rows + 1 header + 3 data rows = 10 rows
      expect(_rows(day1.file).length, 10);

      await _add(repo, amountMinor: 4000, merchant: 'D',
          at: DateTime(2026, 9, 25, 10));
      await _add(repo, amountMinor: 5000, merchant: 'E',
          at: DateTime(2026, 9, 25, 11));

      final day2 = await service.generate(ExportMode.incremental);
      expect(day2.count, 2);
      final rows = _rows(day2.file);
      // 6 summary rows + 1 header + 2 data rows = 9 rows
      expect(rows.length, 9);
      expect(rows[7][2], 'D');
      expect(rows[8][2], 'E');

      // Full history still contains everything.
      final full = await service.generate(ExportMode.full);
      expect(full.count, 5);
    });

    test('edited expense reappears in the next incremental export',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      final saved = await _add(repo, amountMinor: 1000, merchant: 'A');
      final service = _service(repo, dir);

      final stamp = DateTime(2026, 9, 26, 10);
      await service.generate(ExportMode.incremental, now: stamp);
      expect(await repo.queryUnexported(), isEmpty);

      final edited = saved.copyWith(
        categoryId: 'travel',
        updatedAt: stamp.add(const Duration(hours: 1)),
      );
      // copyWith preserves the id; save updates in place.
      final reloaded = await repo.findById(saved.id);
      expect(reloaded, isNotNull);
      await repo.save(edited);

      final next = await service.generate(ExportMode.incremental);
      expect(next.count, 1);
      expect(_rows(next.file)[7][2], 'A');
    });

    test('rows are ordered oldest-first regardless of insert order',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      await _add(repo, amountMinor: 3000, merchant: 'Late',
          at: DateTime(2026, 9, 25, 18));
      await _add(repo, amountMinor: 1000, merchant: 'Early',
          at: DateTime(2026, 9, 25, 8));
      final service = _service(repo, dir);

      final result = await service.generate(ExportMode.full);
      final rows = _rows(result.file);
      expect(rows[7][2], 'Early');
      expect(rows[8][2], 'Late');
    });

    test('running balance calculates correctly with initial balance, credits, and debits',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      final store = AppSettingsStore(null);
      await store.setInitialBalanceMinor(300000); // ₹3,000.00
      final service = ExportService(
        repo,
        null,
        settingsStore: store,
        outputDir: () async => dir,
      );

      // Add a debit of ₹500
      await _add(repo, amountMinor: 50000, merchant: 'Store', at: DateTime(2026, 9, 23, 10));
      // Add a credit of ₹1,000
      await repo.save(Expense(
        id: 0,
        amountMinor: 100000,
        merchant: 'Salary',
        categoryId: 'other',
        timestamp: DateTime(2026, 9, 23, 12),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.credit,
        source: ExpenseSource.manual,
        createdAt: DateTime(2026, 9, 23, 12),
        updatedAt: DateTime(2026, 9, 23, 12),
      ));

      final result = await service.generate(ExportMode.full);
      final rows = _rows(result.file);
      // Summary checks
      expect(rows[1][0], 'Initial Balance:');
      expect((rows[1][1] as num).toDouble(), 3000.0);
      expect(rows[2][0], 'Total Credits:');
      expect((rows[2][1] as num).toDouble(), 1000.0);
      expect(rows[3][0], 'Total Debits:');
      expect((rows[3][1] as num).toDouble(), 500.0);
      expect(rows[4][0], 'Current Balance:');
      expect((rows[4][1] as num).toDouble(), 3500.0);

      // Running balances in table:
      // After debit ₹500: 3000 - 500 = 2500
      expect((rows[7][6] as num).toDouble(), 2500.0);
      // After credit ₹1000: 2500 + 1000 = 3500
      expect((rows[8][6] as num).toDouble(), 3500.0);
    });
  });
}
