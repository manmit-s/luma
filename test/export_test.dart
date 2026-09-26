import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
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
      expect(rows.length, 2);
      expect(
        rows.first.map((v) => '$v').toList(),
        exportColumns,
      );
      // Amount is a numeric spreadsheet value (SPEC 31).
      expect(rows[1][2], isA<num>());
      expect((rows[1][2] as num).toDouble(), 200.9);
      expect(rows[1][3], 'Uber');
      expect(rows[1][7], 'R1');
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
      expect(_rows(day1.file).length, 4);

      await _add(repo, amountMinor: 4000, merchant: 'D',
          at: DateTime(2026, 9, 25, 10));
      await _add(repo, amountMinor: 5000, merchant: 'E',
          at: DateTime(2026, 9, 25, 11));

      final day2 = await service.generate(ExportMode.incremental);
      expect(day2.count, 2);
      final rows = _rows(day2.file);
      expect(rows.length, 3);
      expect(rows[1][3], 'D');
      expect(rows[2][3], 'E');

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
      expect(_rows(next.file)[1][3], 'A');
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
      expect(rows[1][3], 'Early');
      expect(rows[2][3], 'Late');
    });
  });
}
