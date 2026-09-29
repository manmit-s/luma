import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/format.dart';
import '../../data/database/luma_database.dart';
import '../../data/services/app_settings_store.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../domain/repositories/expense_repository.dart';

enum ExportMode { full, incremental }

/// Stable column order for Luma account ledger export.
const exportColumns = [
  'Date',
  'Time',
  'Description',
  'Category',
  'Type',
  'Amount',
  'Balance',
  'Note',
  'Reference Number',
];

const xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

class ExportException implements Exception {
  ExportException(this.userMessage);
  final String userMessage;

  @override
  String toString() => 'ExportException: $userMessage';
}

class ExportResult {
  ExportResult({
    required this.file,
    required this.mode,
    required this.count,
    required this.totalMinor,
    required this.exportedAt,
  });

  final File file;
  final ExportMode mode;
  final int count;
  final int totalMinor;
  final DateTime exportedAt;
}

/// Generates real `.xlsx` files and shares them via Android's native sheet.
///
/// Sequence per SPEC 34: query → generate → verify → mark → share.
/// Luma itself is offline; the file leaves the device only when the user
/// picks an app (e.g. Gmail) in the share sheet.
class ExportService {
  ExportService(
    this._repository,
    this._db, {
    AppSettingsStore? settingsStore,
    Future<Directory> Function()? outputDir,
    Future<File> Function(Directory dir, String filename, List<int> bytes)?
        writeFile,
  })  : _settingsStore = settingsStore ?? AppSettingsStore(_db),
        _outputDir = outputDir ?? getTemporaryDirectory,
        _writeFile = writeFile ?? _defaultWrite;

  final ExpenseRepository _repository;
  final LumaDatabase? _db;
  final AppSettingsStore _settingsStore;
  final Future<Directory> Function() _outputDir;
  final Future<File> Function(Directory dir, String filename, List<int> bytes)
      _writeFile;

  /// Default writer: async flush + existence check. Injectable so widget
  /// tests (FakeAsync zone, where real dart:io awaits deadlock) can supply
  /// a synchronous writer instead. Production behavior is unchanged.
  static Future<File> _defaultWrite(
    Directory dir,
    String filename,
    List<int> bytes,
  ) async {
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    if (!await file.exists()) {
      throw ExportException('Could not create the Excel file.');
    }
    return file;
  }

  Future<ExportResult> generate(ExportMode mode, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    final allExpenses = await _repository.getAll();
    final initialBalanceMinor = await _settingsStore.initialBalanceMinor();

    final expenses = mode == ExportMode.full
        ? allExpenses
        : await _repository.queryUnexported();
    final ordered = List<domain.Expense>.of(expenses)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (ordered.isEmpty) {
      throw ExportException(mode == ExportMode.full
          ? 'No expenses to export yet.'
          : 'Nothing new since the last export.');
    }

    final excel = Excel.createExcel();
    const sheetName = 'Expenses';
    excel.rename('Sheet1', sheetName);

    // Summary Section at top of spreadsheet
    int runningBalance;
    if (mode == ExportMode.full) {
      final totalCredits = ordered
          .where((e) => e.transactionType == domain.TransactionType.credit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final totalDebits = ordered
          .where((e) => e.transactionType == domain.TransactionType.debit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final currentBalance = initialBalanceMinor + totalCredits - totalDebits;

      excel.appendRow(sheetName, [TextCellValue('LUMA EXPENSE SUMMARY')]);
      excel.appendRow(sheetName, [
        TextCellValue('Initial Balance:'),
        DoubleCellValue(initialBalanceMinor / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('Total Credits:'),
        DoubleCellValue(totalCredits / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('Total Debits:'),
        DoubleCellValue(totalDebits / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('Current Balance:'),
        DoubleCellValue(currentBalance / 100),
      ]);
      excel.appendRow(sheetName, [TextCellValue('')]);

      runningBalance = initialBalanceMinor;
    } else {
      final unexportedIds = ordered.map((e) => e.id).toSet();
      final priorExpenses =
          allExpenses.where((e) => !unexportedIds.contains(e.id)).toList();
      final priorCredits = priorExpenses
          .where((e) => e.transactionType == domain.TransactionType.credit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final priorDebits = priorExpenses
          .where((e) => e.transactionType == domain.TransactionType.debit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final openingBalance = initialBalanceMinor + priorCredits - priorDebits;

      final newCredits = ordered
          .where((e) => e.transactionType == domain.TransactionType.credit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final newDebits = ordered
          .where((e) => e.transactionType == domain.TransactionType.debit)
          .fold(0, (sum, e) => sum + e.amountMinor);
      final closingBalance = openingBalance + newCredits - newDebits;

      excel.appendRow(sheetName, [TextCellValue('LUMA EXPENSE SUMMARY')]);
      excel.appendRow(sheetName, [
        TextCellValue('Opening Balance:'),
        DoubleCellValue(openingBalance / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('New Credits:'),
        DoubleCellValue(newCredits / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('New Debits:'),
        DoubleCellValue(newDebits / 100),
      ]);
      excel.appendRow(sheetName, [
        TextCellValue('Closing Balance:'),
        DoubleCellValue(closingBalance / 100),
      ]);
      excel.appendRow(sheetName, [TextCellValue('')]);

      runningBalance = openingBalance;
    }

    // Ledger table headers
    excel.appendRow(
      sheetName,
      exportColumns.map(TextCellValue.new).toList(),
    );

    // Chronological transactions with running balance
    for (final expense in ordered) {
      if (expense.transactionType == domain.TransactionType.credit) {
        runningBalance += expense.amountMinor;
      } else {
        runningBalance -= expense.amountMinor;
      }

      excel.appendRow(sheetName, [
        TextCellValue(_dateOf(expense.timestamp)),
        TextCellValue(_timeOf(expense.timestamp)),
        TextCellValue(expense.merchant ?? ''),
        TextCellValue(categoryName(expense.categoryId)),
        TextCellValue(_txLabel(expense.transactionType)),
        DoubleCellValue(expense.amountMinor / 100),
        DoubleCellValue(runningBalance / 100),
        TextCellValue(expense.note),
        TextCellValue(expense.referenceNumber ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null || bytes.isEmpty) {
      throw ExportException('Could not create the Excel file.');
    }
    final dir = await _outputDir();
    final file = await _writeFile(dir, _filename(timestamp), bytes);

    final ids = ordered.map((e) => e.id).toList();
    await _repository.markExported(ids, timestamp);
    await _recordExport(
      mode: mode,
      at: timestamp,
      fileName: p.basename(file.path),
      count: ordered.length,
    );

    return ExportResult(
      file: file,
      mode: mode,
      count: ordered.length,
      totalMinor: ordered.fold(0, (sum, e) => sum + e.amountMinor),
      exportedAt: timestamp,
    );
  }

  Future<void> share(ExportResult result) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            result.file.path,
            mimeType: xlsxMimeType,
            name: p.basename(result.file.path),
          ),
        ],
        text: result.mode == ExportMode.full
            ? 'Luma full expense history (${result.count} expenses)'
            : 'Luma expenses since last export (${result.count} expenses)',
      ),
    );
  }

  Future<void> _recordExport({
    required ExportMode mode,
    required DateTime at,
    required String fileName,
    required int count,
  }) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.into(db.exportRecords).insert(
            ExportRecordsCompanion.insert(
              type: mode == ExportMode.full ? 'full' : 'incremental',
              createdAt: at,
              fileName: fileName,
              count: count,
            ),
          );
    } catch (_) {
      // Export bookkeeping must never fail the export itself.
    }
  }

  String _filename(DateTime timestamp) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Luma_Expenses_${timestamp.year}-${two(timestamp.month)}-${two(timestamp.day)}'
        '_${two(timestamp.hour)}-${two(timestamp.minute)}.xlsx';
  }

  String _dateOf(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}';
  }

  String _timeOf(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}';
  }

  String _txLabel(domain.TransactionType type) => switch (type) {
        domain.TransactionType.debit => 'debit',
        domain.TransactionType.credit => 'credit',
        domain.TransactionType.unknown => 'unknown',
      };
}
