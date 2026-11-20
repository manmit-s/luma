import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/format.dart';
import '../../data/database/luma_database.dart';
import '../../data/services/app_settings_store.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../domain/entities/internal_transfer.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/source_repository.dart';
import '../../domain/repositories/subscription_repository.dart';

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
  'Payment Source',
  'Account ID',
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

class ImportResult {
  const ImportResult({
    required this.accountsRestored,
    required this.walletsRestored,
    required this.transfersRestored,
    required this.transactionsRestored,
    this.initialBalanceRestored = 0,
    this.isLegacyBackup = false,
  });

  final int accountsRestored;
  final int walletsRestored;
  final int transfersRestored;
  final int transactionsRestored;
  final int initialBalanceRestored;
  final bool isLegacyBackup;
}

/// Resolves the base export directory `Luma Expenses`.
///
/// On Android, attempts to create and use `/storage/emulated/0/Luma Expenses`
/// (visible directly under Internal Storage alongside Android, Download, Documents).
/// If not accessible due to scoped storage / missing permissions, falls back gracefully to
/// Documents/Luma Expenses, Download/Luma Expenses, or application documents storage.
Future<Directory> resolveLumaExpensesDirectory() async {
  if (Platform.isAndroid) {
    try {
      final rootDir = Directory('/storage/emulated/0/Luma Expenses');
      if (!rootDir.existsSync()) {
        rootDir.createSync(recursive: true);
      }
      final testFile = File(p.join(rootDir.path, '.probe'));
      testFile.writeAsStringSync('probe');
      testFile.deleteSync();
      return rootDir;
    } catch (_) {
      try {
        final docDir = Directory('/storage/emulated/0/Documents/Luma Expenses');
        if (!docDir.existsSync()) {
          docDir.createSync(recursive: true);
        }
        final testFile = File(p.join(docDir.path, '.probe'));
        testFile.writeAsStringSync('probe');
        testFile.deleteSync();
        return docDir;
      } catch (_) {
        try {
          final dlDir = Directory('/storage/emulated/0/Download/Luma Expenses');
          if (!dlDir.existsSync()) {
            dlDir.createSync(recursive: true);
          }
          final testFile = File(p.join(dlDir.path, '.probe'));
          testFile.writeAsStringSync('probe');
          testFile.deleteSync();
          return dlDir;
        } catch (_) {
          final appDoc = await getApplicationDocumentsDirectory();
          final fallback = Directory(p.join(appDoc.path, 'Luma Expenses'));
          if (!fallback.existsSync()) {
            fallback.createSync(recursive: true);
          }
          return fallback;
        }
      }
    }
  } else {
    try {
      final appDoc = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(appDoc.path, 'Luma Expenses'));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    } catch (_) {
      final temp = await getTemporaryDirectory();
      final dir = Directory(p.join(temp.path, 'Luma Expenses'));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    }
  }
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
    CategoryRepository? categoryRepository,
    SubscriptionRepository? subscriptionRepository,
    SourceRepository? sourceRepository,
    Future<Directory> Function()? outputDir,
    Future<File> Function(Directory dir, String filename, List<int> bytes)?
        writeFile,
  })  : _settingsStore = settingsStore ?? AppSettingsStore(_db),
        _categoryRepository = categoryRepository,
        _subscriptionRepository = subscriptionRepository,
        _sourceRepository = sourceRepository,
        _outputDir = outputDir ?? resolveLumaExpensesDirectory,
        _writeFile = writeFile ?? _defaultWrite;

  final ExpenseRepository _repository;
  final LumaDatabase? _db;
  final AppSettingsStore _settingsStore;
  final CategoryRepository? _categoryRepository;
  final SubscriptionRepository? _subscriptionRepository;
  final SourceRepository? _sourceRepository;
  final Future<Directory> Function() _outputDir;
  final Future<File> Function(Directory dir, String filename, List<int> bytes)
      _writeFile;

  /// Default writer: async flush + existence check.
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
    final categories = await _categoryRepository?.getAll();
    final initialBalanceMinor = await _settingsStore.initialBalanceMinor();
    final sources = await _sourceRepository?.getAllSources() ?? [];
    final transfers = await _sourceRepository?.getAllTransfers() ?? [];
    final sourcesMap = {for (final s in sources) s.id: s};

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

      final localTimestamp = expense.timestamp.toLocal();
      final source = expense.sourceId != null ? sourcesMap[expense.sourceId] : null;
      final sourceName = source?.displayName ??
          (expense.sourceId != null ? 'Source #${expense.sourceId}' : 'Unassigned');
      final sourceIdStr =
          expense.sourceId != null ? expense.sourceId.toString() : '';

      excel.appendRow(sheetName, [
        TextCellValue(_dateOf(localTimestamp)),
        TextCellValue(_timeOf(localTimestamp)),
        TextCellValue(expense.merchant ?? ''),
        TextCellValue(categoryName(expense.categoryId, categories)),
        TextCellValue(_txLabel(expense.transactionType)),
        DoubleCellValue(expense.amountMinor / 100),
        DoubleCellValue(runningBalance / 100),
        TextCellValue(expense.note),
        TextCellValue(expense.referenceNumber ?? ''),
        TextCellValue(sourceName),
        TextCellValue(sourceIdStr),
      ]);
    }

    // Worksheet: Accounts
    const accountsSheet = 'Accounts';
    excel[accountsSheet];
    excel.appendRow(accountsSheet, [
      TextCellValue('Account ID'),
      TextCellValue('Bank Name'),
      TextCellValue('Bank Identifier'),
      TextCellValue('Nickname'),
      TextCellValue('Account Number Last 4'),
      TextCellValue('Opening Balance'),
      TextCellValue('Is Active'),
      TextCellValue('Created At'),
    ]);
    for (final source in sources.where((s) => s.isBank)) {
      excel.appendRow(accountsSheet, [
        IntCellValue(source.id),
        TextCellValue(source.bankName ?? ''),
        TextCellValue(source.bankIdentifier ?? ''),
        TextCellValue(source.nickname ?? ''),
        TextCellValue(source.accountNumberLast4 ?? ''),
        DoubleCellValue(source.openingBalanceMinor / 100),
        TextCellValue(source.isActive ? 'Yes' : 'No'),
        TextCellValue(source.createdAt.toIso8601String()),
      ]);
    }

    // Worksheet: Wallets
    const walletsSheet = 'Wallets';
    excel[walletsSheet];
    excel.appendRow(walletsSheet, [
      TextCellValue('Wallet ID'),
      TextCellValue('Name'),
      TextCellValue('Opening Balance'),
      TextCellValue('Is Active'),
      TextCellValue('Created At'),
    ]);
    for (final source in sources.where((s) => s.isWallet)) {
      excel.appendRow(walletsSheet, [
        IntCellValue(source.id),
        TextCellValue(source.displayName),
        DoubleCellValue(source.openingBalanceMinor / 100),
        TextCellValue(source.isActive ? 'Yes' : 'No'),
        TextCellValue(source.createdAt.toIso8601String()),
      ]);
    }

    // Worksheet: Transfers
    const transfersSheet = 'Transfers';
    excel[transfersSheet];
    excel.appendRow(transfersSheet, [
      TextCellValue('Transfer ID'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('From Source ID'),
      TextCellValue('From Source'),
      TextCellValue('To Source ID'),
      TextCellValue('To Source'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
      TextCellValue('Created At'),
    ]);
    for (final trf in transfers) {
      final fromName = sourcesMap[trf.fromSourceId]?.displayName ??
          'Source #${trf.fromSourceId}';
      final toName =
          sourcesMap[trf.toSourceId]?.displayName ?? 'Source #${trf.toSourceId}';
      excel.appendRow(transfersSheet, [
        IntCellValue(trf.id),
        TextCellValue(_dateOf(trf.timestamp)),
        TextCellValue(_timeOf(trf.timestamp)),
        IntCellValue(trf.fromSourceId),
        TextCellValue(fromName),
        IntCellValue(trf.toSourceId),
        TextCellValue(toName),
        DoubleCellValue(trf.amountMinor / 100),
        TextCellValue(trf.note),
        TextCellValue(trf.createdAt.toIso8601String()),
      ]);
    }

    // Worksheet: Financial Summary
    const summarySheet = 'Financial Summary';
    excel[summarySheet];
    excel.appendRow(summarySheet, [
      TextCellValue('Source Name'),
      TextCellValue('Type'),
      TextCellValue('Opening Balance'),
      TextCellValue('Income'),
      TextCellValue('Expenses'),
      TextCellValue('Transfers Received'),
      TextCellValue('Transfers Sent'),
      TextCellValue('Closing Balance'),
    ]);

    var grandOpening = 0;
    var grandIncome = 0;
    var grandExpenses = 0;
    var grandTrfReceived = 0;
    var grandTrfSent = 0;

    for (final source in sources) {
      final opening = source.openingBalanceMinor;
      var income = 0;
      var expense = 0;
      for (final tx in allExpenses) {
        if (tx.sourceId == source.id &&
            tx.status == domain.ExpenseStatus.completed) {
          if (tx.transactionType == domain.TransactionType.credit) {
            income += tx.amountMinor;
          } else if (tx.transactionType == domain.TransactionType.debit) {
            expense += tx.amountMinor;
          }
        }
      }

      var trfReceived = 0;
      var trfSent = 0;
      for (final trf in transfers) {
        if (trf.toSourceId == source.id) trfReceived += trf.amountMinor;
        if (trf.fromSourceId == source.id) trfSent += trf.amountMinor;
      }

      final closing = opening + income - expense + trfReceived - trfSent;

      grandOpening += opening;
      grandIncome += income;
      grandExpenses += expense;
      grandTrfReceived += trfReceived;
      grandTrfSent += trfSent;

      excel.appendRow(summarySheet, [
        TextCellValue(source.displayName),
        TextCellValue(source.isBank ? 'Bank' : 'Cash Wallet'),
        DoubleCellValue(opening / 100),
        DoubleCellValue(income / 100),
        DoubleCellValue(expense / 100),
        DoubleCellValue(trfReceived / 100),
        DoubleCellValue(trfSent / 100),
        DoubleCellValue(closing / 100),
      ]);
    }

    final grandClosing = grandOpening +
        grandIncome -
        grandExpenses +
        grandTrfReceived -
        grandTrfSent;
    excel.appendRow(summarySheet, [
      TextCellValue('COMBINED TOTAL'),
      TextCellValue('All Sources'),
      DoubleCellValue(grandOpening / 100),
      DoubleCellValue(grandIncome / 100),
      DoubleCellValue(grandExpenses / 100),
      DoubleCellValue(grandTrfReceived / 100),
      DoubleCellValue(grandTrfSent / 100),
      DoubleCellValue(grandClosing / 100),
    ]);

    if (_subscriptionRepository != null) {
      final subs = await _subscriptionRepository.getAll();
      if (subs.isNotEmpty) {
        const subSheet = 'Subscriptions';
        excel[subSheet];
        excel.appendRow(subSheet, [
          TextCellValue('Name'),
          TextCellValue('Amount'),
          TextCellValue('Billing Cycle'),
          TextCellValue('Payment Method'),
          TextCellValue('Status'),
          TextCellValue('Start Date'),
          TextCellValue('Next Renewal'),
          TextCellValue('Trial End'),
          TextCellValue('Cancellation Reminder'),
        ]);
        for (final sub in subs) {
          excel.appendRow(subSheet, [
            TextCellValue(sub.name),
            DoubleCellValue(sub.amountMinor / 100),
            TextCellValue(sub.billingCycle.label),
            TextCellValue(sub.paymentMethod.label),
            TextCellValue(sub.status.label),
            TextCellValue(formatDayLabel(sub.startDate)),
            TextCellValue(formatDayLabel(sub.nextRenewalDate)),
            TextCellValue(sub.trialEndDate != null
                ? formatDayLabel(sub.trialEndDate!)
                : '-'),
            TextCellValue(sub.cancellationReminderEnabled
                ? '${sub.cancellationReminderDaysBefore} days before'
                : 'Disabled'),
          ]);
        }
      }
    }

    final bytes = excel.save();
    if (bytes == null || bytes.isEmpty) {
      throw ExportException('Could not create the Excel file.');
    }
    final baseDir = await _outputDir();
    final subfolderName =
        mode == ExportMode.full ? 'Full history' : 'Since Last Export';
    final targetDir = Directory(p.join(baseDir.path, subfolderName));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }
    final file = await _writeFile(targetDir, _filename(timestamp), bytes);

    if (mode == ExportMode.full) {
      final backupDir = Directory(p.join(baseDir.path, 'Backup'));
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }
      try {
        await _writeFile(backupDir, 'luma_backup_latest.xlsx', bytes);
      } catch (_) {
        // Backup copy failure must not break primary export.
      }
    }

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

  /// Restores accounts, wallets, transfers, and transactions from an Excel file bytes.
  ///
  /// Completely compatible with legacy backups that do not contain source information.
  Future<ImportResult> importExcel(List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);
    var accountsRestored = 0;
    var walletsRestored = 0;
    var transfersRestored = 0;
    var transactionsRestored = 0;
    var extractedInitialBalance = 0;

    final accountsTable = _findSheet(excel, 'Accounts');
    final walletsTable = _findSheet(excel, 'Wallets');
    final transfersTable = _findSheet(excel, 'Transfers');
    final txTable = _findSheet(excel, 'Expenses') ??
        _findSheet(excel, 'Transactions') ??
        _findSheet(excel, 'Sheet1') ??
        (excel.tables.isNotEmpty ? excel.tables.values.first : null);

    final isLegacyBackup = accountsTable == null && walletsTable == null;

    final existingSources = List<PaymentSource>.from(
      await _sourceRepository?.getAllSources() ?? [],
    );
    final sourceIdMap = <int, int>{}; // backupId -> restored/existing ID
    final sourceNameMap = <String, int>{};

    for (final s in existingSources) {
      sourceIdMap[s.id] = s.id;
      sourceNameMap[s.displayName.toLowerCase()] = s.id;
      if (s.nickname != null && s.nickname!.isNotEmpty) {
        sourceNameMap[s.nickname!.toLowerCase()] = s.id;
      }
      if (s.bankName != null && s.bankName!.isNotEmpty) {
        sourceNameMap[s.bankName!.toLowerCase()] = s.id;
      }
    }

    // 1. Restore Accounts sheet
    if (accountsTable != null && _sourceRepository != null) {
      for (var i = 1; i < accountsTable.rows.length; i++) {
        final row = accountsTable.rows[i];
        if (row.isEmpty) continue;
        final rawId = _toInt(row.elementAtOrNull(0));
        final bankName = _toStr(row.elementAtOrNull(1));
        final bankIdentifier = _toStr(row.elementAtOrNull(2));
        final nickname = _toStr(row.elementAtOrNull(3));
        final last4 = _toStr(row.elementAtOrNull(4));
        final opening = _toMinor(row.elementAtOrNull(5));
        final isActiveStr = _toStr(row.elementAtOrNull(6)).toLowerCase();
        final isActive = isActiveStr != 'no' && isActiveStr != 'false';
        final createdAtStr = _toStr(row.elementAtOrNull(7));
        final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

        if (bankName.isEmpty && bankIdentifier.isEmpty) continue;

        // Check if matching account already exists in existingSources
        PaymentSource? existing;
        for (final s in existingSources) {
          if (s.isBank &&
              (s.bankIdentifier == bankIdentifier ||
                  (s.bankName != null && bankName.isNotEmpty && s.bankName!.toLowerCase() == bankName.toLowerCase())) &&
              (last4.isEmpty || s.accountNumberLast4 == last4)) {
            existing = s;
            break;
          }
        }

        if (existing != null) {
          final updated = existing.copyWith(
            openingBalanceMinor: opening > 0 ? opening : existing.openingBalanceMinor,
            nickname: nickname.isNotEmpty ? nickname : existing.nickname,
            isActive: isActive,
          );
          final saved = await _sourceRepository.saveSource(updated);
          final idx = existingSources.indexWhere((s) => s.id == existing!.id);
          if (idx != -1) existingSources[idx] = saved;
          if (rawId != null) sourceIdMap[rawId] = saved.id;
          sourceNameMap[saved.displayName.toLowerCase()] = saved.id;
          if (saved.nickname != null && saved.nickname!.isNotEmpty) {
            sourceNameMap[saved.nickname!.toLowerCase()] = saved.id;
          }
          if (saved.bankName != null && saved.bankName!.isNotEmpty) {
            sourceNameMap[saved.bankName!.toLowerCase()] = saved.id;
          }
          accountsRestored++;
        } else {
          final newSource = PaymentSource(
            id: 0,
            type: PaymentSourceType.bank,
            bankName: bankName.isNotEmpty ? bankName : null,
            bankIdentifier: bankIdentifier.isNotEmpty ? bankIdentifier : null,
            nickname: nickname.isNotEmpty ? nickname : null,
            accountNumberLast4: last4.isNotEmpty ? last4 : null,
            openingBalanceMinor: opening,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: createdAt,
          );
          final saved = await _sourceRepository.saveSource(newSource);
          if (rawId != null) sourceIdMap[rawId] = saved.id;
          sourceNameMap[saved.displayName.toLowerCase()] = saved.id;
          if (saved.nickname != null && saved.nickname!.isNotEmpty) {
            sourceNameMap[saved.nickname!.toLowerCase()] = saved.id;
          }
          if (saved.bankName != null && saved.bankName!.isNotEmpty) {
            sourceNameMap[saved.bankName!.toLowerCase()] = saved.id;
          }
          existingSources.add(saved);
          accountsRestored++;
        }
      }
    }

    // 2. Restore Wallets sheet
    if (walletsTable != null && _sourceRepository != null) {
      for (var i = 1; i < walletsTable.rows.length; i++) {
        final row = walletsTable.rows[i];
        if (row.isEmpty) continue;
        final rawId = _toInt(row.elementAtOrNull(0));
        final name = _toStr(row.elementAtOrNull(1));
        final opening = _toMinor(row.elementAtOrNull(2));
        final isActiveStr = _toStr(row.elementAtOrNull(3)).toLowerCase();
        final isActive = isActiveStr != 'no' && isActiveStr != 'false';
        final createdAtStr = _toStr(row.elementAtOrNull(4));
        final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

        PaymentSource? existingWallet;
        for (final s in existingSources) {
          if (s.isWallet) {
            existingWallet = s;
            break;
          }
        }

        if (existingWallet != null) {
          final updated = existingWallet.copyWith(
            openingBalanceMinor: opening > 0 ? opening : existingWallet.openingBalanceMinor,
            isActive: isActive,
            nickname: name.isNotEmpty ? name : existingWallet.nickname,
          );
          final saved = await _sourceRepository.saveSource(updated);
          final idx = existingSources.indexWhere((s) => s.id == existingWallet!.id);
          if (idx != -1) existingSources[idx] = saved;
          if (rawId != null) sourceIdMap[rawId] = saved.id;
          sourceNameMap[saved.displayName.toLowerCase()] = saved.id;
          if (saved.nickname != null && saved.nickname!.isNotEmpty) {
            sourceNameMap[saved.nickname!.toLowerCase()] = saved.id;
          }
          walletsRestored++;
        } else {
          final newWallet = PaymentSource(
            id: 0,
            type: PaymentSourceType.wallet,
            bankIdentifier: 'cash_wallet',
            nickname: name.isNotEmpty ? name : 'Cash Wallet',
            openingBalanceMinor: opening,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: createdAt,
          );
          final saved = await _sourceRepository.saveSource(newWallet);
          if (rawId != null) sourceIdMap[rawId] = saved.id;
          sourceNameMap[saved.displayName.toLowerCase()] = saved.id;
          if (saved.nickname != null && saved.nickname!.isNotEmpty) {
            sourceNameMap[saved.nickname!.toLowerCase()] = saved.id;
          }
          existingSources.add(saved);
          walletsRestored++;
        }
      }
    }

    // 3. Restore Transfers sheet
    if (transfersTable != null && _sourceRepository != null) {
      final existingTransfers = await _sourceRepository.getAllTransfers();
      for (var i = 1; i < transfersTable.rows.length; i++) {
        final row = transfersTable.rows[i];
        if (row.isEmpty) continue;
        _toInt(row.elementAtOrNull(0));
        final dateStr = _toStr(row.elementAtOrNull(1));
        final timeStr = _toStr(row.elementAtOrNull(2));
        final rawFromId = _toInt(row.elementAtOrNull(3));
        final fromName = _toStr(row.elementAtOrNull(4)).toLowerCase();
        final rawToId = _toInt(row.elementAtOrNull(5));
        final toName = _toStr(row.elementAtOrNull(6)).toLowerCase();
        final amount = _toMinor(row.elementAtOrNull(7));
        final note = _toStr(row.elementAtOrNull(8));

        final fromId = (rawFromId != null ? sourceIdMap[rawFromId] : null) ??
            sourceNameMap[fromName];
        final toId = (rawToId != null ? sourceIdMap[rawToId] : null) ??
            sourceNameMap[toName];

        if (fromId == null || toId == null || amount <= 0) continue;

        final timestamp = _parseDateTime(dateStr, timeStr) ?? DateTime.now();
        final isDupe = existingTransfers.any((t) =>
            t.fromSourceId == fromId &&
            t.toSourceId == toId &&
            t.amountMinor == amount &&
            t.timestamp.difference(timestamp).abs().inMinutes < 2);

        if (!isDupe) {
          final transfer = InternalTransfer(
            id: 0,
            fromSourceId: fromId,
            toSourceId: toId,
            amountMinor: amount,
            timestamp: timestamp,
            note: note,
            createdAt: timestamp,
            updatedAt: timestamp,
          );
          await _sourceRepository.saveTransfer(transfer);
          transfersRestored++;
        }
      }
    }

    // 4. Restore Transactions from 'Expenses' or 'Transactions' sheet
    if (txTable != null) {
      var headerIndex = -1;
      var dateCol = -1;
      var timeCol = -1;
      var descCol = -1;
      var catCol = -1;
      var typeCol = -1;
      var amountCol = -1;
      var balanceCol = -1;
      var noteCol = -1;
      var refCol = -1;
      var sourceCol = -1;
      var sourceIdCol = -1;

      for (var r = 0; r < txTable.rows.length; r++) {
        final row = txTable.rows[r];
        final headers = row.map((c) => _toStr(c).toLowerCase().trim()).toList();
        if (headers.contains('date') && headers.contains('amount')) {
          headerIndex = r;
          dateCol = headers.indexOf('date');
          timeCol = headers.indexOf('time');
          descCol = headers.contains('description')
              ? headers.indexOf('description')
              : headers.indexOf('merchant');
          catCol = headers.indexOf('category');
          typeCol = headers.indexOf('type');
          amountCol = headers.indexOf('amount');
          balanceCol = headers.contains('balance')
              ? headers.indexOf('balance')
              : (headers.contains('running balance')
                  ? headers.indexOf('running balance')
                  : -1);
          noteCol = headers.indexOf('note');
          refCol = headers.contains('reference number')
              ? headers.indexOf('reference number')
              : headers.indexOf('reference');
          sourceCol = headers.indexOf('payment source');
          sourceIdCol = headers.contains('account id')
              ? headers.indexOf('account id')
              : headers.indexOf('source id');
          break;
        }
      }

      if (headerIndex >= 0 && amountCol >= 0 && dateCol >= 0) {
        // Extract initial / opening balance from legacy summary rows
        for (var r = 0; r < headerIndex; r++) {
          final row = txTable.rows[r];
          if (row.isEmpty) continue;
          final cell0 = _toStr(row.elementAtOrNull(0)).toLowerCase();
          if (cell0.contains('initial balance') || cell0.contains('opening balance')) {
            extractedInitialBalance = _toMinor(row.elementAtOrNull(1));
          }
          if (extractedInitialBalance == 0) {
            final rawCell0 = _toStr(row.elementAtOrNull(0));
            final match = RegExp(
              r'(?:initial|opening)\s*balance\s*:\s*([0-9.,]+)',
              caseSensitive: false,
            ).firstMatch(rawCell0);
            if (match != null) {
              final valStr = match.group(1)!.replaceAll(',', '').trim();
              final d = double.tryParse(valStr);
              if (d != null) extractedInitialBalance = (d * 100).round();
            }
          }
        }

        // If not found in summary, derive from the first transaction's running balance
        if (extractedInitialBalance == 0 && balanceCol >= 0) {
          for (var r = headerIndex + 1; r < txTable.rows.length; r++) {
            final row = txTable.rows[r];
            if (row.isEmpty) continue;
            if (balanceCol < row.length && amountCol < row.length) {
              final firstRunBalance = _toMinor(row[balanceCol]);
              final firstAmount = _toMinor(row[amountCol]);
              final firstTypeStr =
                  typeCol >= 0 && typeCol < row.length ? _toStr(row[typeCol]) : '';
              if (firstRunBalance > 0 && firstAmount > 0) {
                if (firstTypeStr.toLowerCase() == 'credit') {
                  extractedInitialBalance = firstRunBalance - firstAmount;
                } else {
                  extractedInitialBalance = firstRunBalance + firstAmount;
                }
                if (extractedInitialBalance < 0) extractedInitialBalance = 0;
                break;
              }
            }
          }
        }

        // In a legacy backup (pre multi-account), ensure default Cash Wallet is initialized
        // with this initial balance, and legacy transactions are assigned to it.
        PaymentSource? cashWallet;
        for (final s in existingSources) {
          if (s.isWallet) {
            cashWallet = s;
            break;
          }
        }

        if (_sourceRepository != null) {
          if (cashWallet == null) {
            final newWallet = PaymentSource(
              id: 0,
              type: PaymentSourceType.wallet,
              bankIdentifier: 'cash_wallet',
              nickname: 'Cash Wallet',
              openingBalanceMinor: extractedInitialBalance,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            cashWallet = await _sourceRepository.saveSource(newWallet);
            existingSources.add(cashWallet);
            sourceIdMap[cashWallet.id] = cashWallet.id;
            sourceNameMap[cashWallet.displayName.toLowerCase()] = cashWallet.id;
            walletsRestored++;
          } else if (isLegacyBackup && extractedInitialBalance > 0) {
            final updated = cashWallet.copyWith(
              openingBalanceMinor: extractedInitialBalance,
            );
            cashWallet = await _sourceRepository.saveSource(updated);
            final idx = existingSources.indexWhere((s) => s.id == cashWallet!.id);
            if (idx != -1) existingSources[idx] = cashWallet;
            walletsRestored++;
          }
        }

        final allCategories = await _categoryRepository?.getAll() ?? [];
        final categoryMap = {for (final c in allCategories) c.name.toLowerCase(): c.id};

        for (var r = headerIndex + 1; r < txTable.rows.length; r++) {
          final row = txTable.rows[r];
          if (row.isEmpty) continue;

          final dateStr = dateCol >= 0 && dateCol < row.length ? _toStr(row[dateCol]) : '';
          final timeStr =
              timeCol >= 0 && timeCol < row.length ? _toStr(row[timeCol]) : '';
          final desc =
              descCol >= 0 && descCol < row.length ? _toStr(row[descCol]) : '';
          final catName =
              catCol >= 0 && catCol < row.length ? _toStr(row[catCol]) : '';
          final typeStr =
              typeCol >= 0 && typeCol < row.length ? _toStr(row[typeCol]) : '';
          final amount = amountCol >= 0 && amountCol < row.length ? _toMinor(row[amountCol]) : 0;
          final note =
              noteCol >= 0 && noteCol < row.length ? _toStr(row[noteCol]) : '';
          final ref =
              refCol >= 0 && refCol < row.length
                  ? _toStr(row[refCol])
                  : null;
          final rawSource = sourceCol >= 0 && sourceCol < row.length
              ? _toStr(row[sourceCol])
              : '';
          final rawSourceId = sourceIdCol >= 0 && sourceIdCol < row.length
              ? _toInt(row[sourceIdCol])
              : null;

          if (amount <= 0 && desc.isEmpty) continue;

          final timestamp = _parseDateTime(dateStr, timeStr) ?? DateTime.now();
          final txType = typeStr.toLowerCase() == 'credit'
              ? domain.TransactionType.credit
              : domain.TransactionType.debit;

          // Map sourceId or look up by name
          int? matchedSourceId;
          if (rawSourceId != null) {
            matchedSourceId = sourceIdMap[rawSourceId];
          }
          if (matchedSourceId == null && rawSource.isNotEmpty && rawSource != 'Unassigned') {
            matchedSourceId = sourceNameMap[rawSource.toLowerCase()];
          }
          // Legacy backup fallback: if transaction has no source and this is a legacy backup,
          // assign to Cash Wallet so balance and ledger reflect accurately.
          if (matchedSourceId == null && isLegacyBackup && cashWallet != null) {
            matchedSourceId = cashWallet.id;
          }

          final categoryId = categoryMap[catName.toLowerCase()] ??
              (catName.isNotEmpty ? catName.toLowerCase() : null);

          // Check if already in repository
          final duplicate = await _repository.findDuplicate(
            referenceNumber: ref?.isNotEmpty == true ? ref : null,
            fingerprint: null,
            amountMinor: amount,
            merchant: desc.isNotEmpty ? desc : null,
            timestamp: timestamp,
          );

          if (duplicate == null) {
            final newTx = domain.Expense(
              id: 0,
              amountMinor: amount,
              merchant: desc.isNotEmpty ? desc : null,
              categoryId: categoryId,
              timestamp: timestamp,
              status: domain.ExpenseStatus.completed,
              transactionType: txType,
              source: domain.ExpenseSource.manual,
              sourceId: matchedSourceId,
              note: note,
              referenceNumber: ref?.isNotEmpty == true ? ref : null,
              createdAt: timestamp,
              updatedAt: timestamp,
            );
            await _repository.save(newTx);
            transactionsRestored++;
          } else if (duplicate.sourceId == null && matchedSourceId != null) {
            // Update legacy unassigned transaction with source
            final updated = duplicate.copyWith(sourceId: matchedSourceId);
            await _repository.save(updated);
          }
        }

        // In a legacy restore, also update any previously imported unassigned transactions
        // to belong to the Cash Wallet.
        if (isLegacyBackup && cashWallet != null) {
          final allExisting = await _repository.getAll();
          for (final e in allExisting) {
            if (e.sourceId == null) {
              await _repository.save(e.copyWith(sourceId: cashWallet.id));
            }
          }
        }
      }
    }

    return ImportResult(
      accountsRestored: accountsRestored,
      walletsRestored: walletsRestored,
      transfersRestored: transfersRestored,
      transactionsRestored: transactionsRestored,
      initialBalanceRestored: extractedInitialBalance,
      isLegacyBackup: isLegacyBackup,
    );
  }

  static Sheet? _findSheet(Excel excel, String name) {
    for (final key in excel.tables.keys) {
      if (key.trim().toLowerCase() == name.trim().toLowerCase()) {
        return excel.tables[key];
      }
    }
    return null;
  }

  static String _toStr(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final val = cell.value;
    if (val is TextCellValue) return val.value.toString().trim();
    if (val is DoubleCellValue) return val.value.toString();
    if (val is IntCellValue) return val.value.toString();
    if (val is BoolCellValue) return val.value ? 'Yes' : 'No';
    return val.toString().trim();
  }

  static int? _toInt(Data? cell) {
    if (cell == null || cell.value == null) return null;
    final val = cell.value;
    if (val is IntCellValue) return val.value;
    if (val is DoubleCellValue) return val.value.toInt();
    if (val is TextCellValue) return int.tryParse(val.value.toString().trim());
    return int.tryParse(val.toString().trim());
  }

  static int _toMinor(Data? cell) {
    if (cell == null || cell.value == null) return 0;
    final val = cell.value;
    if (val is DoubleCellValue) return (val.value * 100).round();
    if (val is IntCellValue) return val.value * 100;
    if (val is TextCellValue) {
      final parsed = double.tryParse(val.value.toString().replaceAll(',', '').trim());
      return parsed != null ? (parsed * 100).round() : 0;
    }
    final parsed = double.tryParse(val.toString().replaceAll(',', '').trim());
    return parsed != null ? (parsed * 100).round() : 0;
  }

  static DateTime? _parseDateTime(String dateStr, String timeStr) {
    if (dateStr.isEmpty) return null;
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    var hour = 12;
    var minute = 0;
    if (timeStr.isNotEmpty) {
      final tParts = timeStr.split(':');
      if (tParts.length >= 2) {
        hour = int.tryParse(tParts[0]) ?? 12;
        minute = int.tryParse(tParts[1]) ?? 0;
      }
    }
    return DateTime(year, month, day, hour, minute);
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

  /// Discovers all available Excel backup and export files across standard storage locations,
  /// sorting them so the latest auto-backup appears first.
  static Future<List<File>> findBackupCandidates() async {
    final scanDirs = <Directory>[];
    if (Platform.isAndroid) {
      for (final root in [
        '/storage/emulated/0/Luma Expenses',
        '/storage/emulated/0/Documents/Luma Expenses',
        '/storage/emulated/0/Download/Luma Expenses',
      ]) {
        scanDirs.add(Directory('$root/Backup'));
        scanDirs.add(Directory('$root/Full history'));
        scanDirs.add(Directory('$root/Since Last Export'));
        scanDirs.add(Directory(root));
      }
    }
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      scanDirs.add(Directory(p.join(docsDir.path, 'Luma Expenses', 'Backup')));
      scanDirs.add(Directory(p.join(docsDir.path, 'Luma Expenses', 'Full history')));
      scanDirs.add(Directory(p.join(docsDir.path, 'Luma Expenses', 'Since Last Export')));
      scanDirs.add(Directory(p.join(docsDir.path, 'Luma Expenses')));
      scanDirs.add(docsDir);
    } catch (_) {}
    try {
      final tempDir = await getTemporaryDirectory();
      scanDirs.add(Directory(p.join(tempDir.path, 'Luma Expenses', 'Backup')));
      scanDirs.add(Directory(p.join(tempDir.path, 'Luma Expenses', 'Full history')));
      scanDirs.add(Directory(p.join(tempDir.path, 'Luma Expenses', 'Since Last Export')));
      scanDirs.add(Directory(p.join(tempDir.path, 'Luma Expenses')));
      scanDirs.add(tempDir);
    } catch (_) {}

    final seenPaths = <String>{};
    final candidates = <File>[];
    for (final d in scanDirs) {
      try {
        if (d.existsSync()) {
          final list = d.listSync();
          for (final f in list) {
            if (f is File &&
                f.path.toLowerCase().endsWith('.xlsx') &&
                seenPaths.add(f.path)) {
              candidates.add(f);
            }
          }
        }
      } catch (_) {}
    }

    candidates.sort((a, b) {
      final aIsBackup = a.path.contains('Backup') || a.path.endsWith('luma_backup_latest.xlsx');
      final bIsBackup = b.path.contains('Backup') || b.path.endsWith('luma_backup_latest.xlsx');
      if (aIsBackup && !bIsBackup) return -1;
      if (!aIsBackup && bIsBackup) return 1;
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    });

    return candidates;
  }

  /// Resolves a user-entered path to a File, handling:
  /// - Missing leading slash (`storage/emulated/0/...` -> `/storage/emulated/0/...`)
  /// - URL prefixes (`file:///...` -> `/...`)
  /// - Quotes (`"path"` -> `path`)
  /// - Naming discrepancies (`Luma_Expenses` <-> `Luma Expenses`)
  /// - Directory paths (searches directory for `luma_backup_latest.xlsx` or any `.xlsx`)
  /// - Scoped storage redirects (`/storage/emulated/0/...` -> `/storage/emulated/0/Documents/...`)
  static File? resolveManualBackupFile(String input) {
    var raw = input.trim();
    if (raw.isEmpty) return null;

    // Strip wrapping quotes
    if ((raw.startsWith('"') && raw.endsWith('"')) ||
        (raw.startsWith("'") && raw.endsWith("'"))) {
      raw = raw.substring(1, raw.length - 1).trim();
    }
    // Strip file:// schema
    if (raw.startsWith('file://')) {
      raw = raw.substring(7);
    }
    if (raw.isEmpty) return null;

    // Prepend leading slash if omitted
    if (raw.startsWith('storage/') || raw.startsWith('sdcard/')) {
      raw = '/$raw';
    }

    final candidatePaths = <String>{
      raw,
      if (!raw.startsWith('/')) '/$raw',
      raw.replaceAll('Luma_Expenses', 'Luma Expenses'),
      raw.replaceAll('Luma Expenses', 'Luma_Expenses'),
      raw.replaceAll('_', ' '),
    };

    final extraPaths = <String>{};
    for (final p in candidatePaths) {
      if (p.startsWith('/storage/emulated/0/')) {
        final sub = p.substring('/storage/emulated/0/'.length);
        extraPaths.add('/storage/emulated/0/Documents/$sub');
        extraPaths.add('/storage/emulated/0/Download/$sub');
      } else if (p.startsWith('/sdcard/')) {
        final sub = p.substring('/sdcard/'.length);
        extraPaths.add('/storage/emulated/0/$sub');
        extraPaths.add('/storage/emulated/0/Documents/$sub');
        extraPaths.add('/storage/emulated/0/Download/$sub');
      }
    }
    candidatePaths.addAll(extraPaths);

    for (final candidate in candidatePaths) {
      try {
        final f = File(candidate);
        if (f.existsSync()) {
          return f;
        }
      } catch (_) {}
      try {
        final d = Directory(candidate);
        if (d.existsSync()) {
          final backupSub =
              File(p.join(d.path, 'Backup', 'luma_backup_latest.xlsx'));
          if (backupSub.existsSync()) return backupSub;

          final backupDirect =
              File(p.join(d.path, 'luma_backup_latest.xlsx'));
          if (backupDirect.existsSync()) return backupDirect;

          final entries = d.listSync(recursive: true);
          for (final entry in entries) {
            if (entry is File && entry.path.toLowerCase().endsWith('.xlsx')) {
              return entry;
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }
}
