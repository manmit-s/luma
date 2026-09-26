import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/format.dart';
import '../../data/database/luma_database.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../domain/repositories/expense_repository.dart';

enum ExportMode { full, incremental }

/// Stable column order (SPEC 31). Never reorder without a reason.
const exportColumns = [
  'Date',
  'Time',
  'Amount',
  'Merchant',
  'Category',
  'Note',
  'Transaction Type',
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
    Future<Directory> Function()? outputDir,
    Future<File> Function(Directory dir, String filename, List<int> bytes)?
        writeFile,
  })  : _outputDir = outputDir ?? getTemporaryDirectory,
        _writeFile = writeFile ?? _defaultWrite;

  final ExpenseRepository _repository;
  final LumaDatabase? _db;
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
    final expenses = mode == ExportMode.full
        ? await _repository.getAll()
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
    excel.appendRow(
      sheetName,
      exportColumns.map(TextCellValue.new).toList(),
    );
    for (final expense in ordered) {
      excel.appendRow(sheetName, [
        TextCellValue(_dateOf(expense.timestamp)),
        TextCellValue(_timeOf(expense.timestamp)),
        DoubleCellValue(expense.amountMinor / 100),
        TextCellValue(expense.merchant ?? ''),
        TextCellValue(categoryName(expense.categoryId)),
        TextCellValue(expense.note),
        TextCellValue(_txLabel(expense.transactionType)),
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
