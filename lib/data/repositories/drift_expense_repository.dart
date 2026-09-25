import 'package:drift/drift.dart';

import '../../domain/entities/expense.dart' as domain;
import '../../domain/repositories/expense_repository.dart';
import '../database/luma_database.dart' as store;

int _txToInt(domain.TransactionType t) => switch (t) {
      domain.TransactionType.debit => 0,
      domain.TransactionType.credit => 1,
      domain.TransactionType.unknown => 2,
    };

domain.TransactionType _txFromInt(int v) => switch (v) {
      0 => domain.TransactionType.debit,
      1 => domain.TransactionType.credit,
      _ => domain.TransactionType.unknown,
    };

int _statusToInt(domain.ExpenseStatus s) => switch (s) {
      domain.ExpenseStatus.pending => 0,
      domain.ExpenseStatus.completed => 1,
      domain.ExpenseStatus.ignored => 2,
    };

domain.ExpenseStatus _statusFromInt(int v) => switch (v) {
      0 => domain.ExpenseStatus.pending,
      1 => domain.ExpenseStatus.completed,
      _ => domain.ExpenseStatus.ignored,
    };

int _sourceToInt(domain.ExpenseSource s) => switch (s) {
      domain.ExpenseSource.sms => 0,
      domain.ExpenseSource.manual => 1,
    };

domain.ExpenseSource _sourceFromInt(int v) =>
    v == 1 ? domain.ExpenseSource.manual : domain.ExpenseSource.sms;

domain.Expense _toEntity(store.Expense row) => domain.Expense(
      id: row.id,
      amountMinor: row.amountMinor,
      merchant: row.merchant,
      categoryId: row.categoryId,
      note: row.note,
      referenceNumber: row.referenceNumber,
      smsFingerprint: row.smsFingerprint,
      rawSms: row.rawSms,
      timestamp: row.timestamp,
      transactionType: _txFromInt(row.transactionType),
      status: _statusFromInt(row.status),
      source: _sourceFromInt(row.source),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastExportedAt: row.lastExportedAt,
    );

class DriftExpenseRepository implements ExpenseRepository {
  DriftExpenseRepository(this.database);

  final store.LumaDatabase database;

  @override
  Future<List<domain.Expense>> getAll() async {
    final rows = await (database.select(database.expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<domain.Expense?> findById(int id) async {
    final row = await (database.select(database.expenses)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<domain.Expense?> findDuplicate({
    String? referenceNumber,
    required String? fingerprint,
    required int amountMinor,
    required String? merchant,
    required DateTime timestamp,
  }) async {
    if (referenceNumber != null && referenceNumber.isNotEmpty) {
      final byRef = await (database.select(database.expenses)
            ..where((t) => t.referenceNumber.equals(referenceNumber)))
          .getSingleOrNull();
      if (byRef != null) return _toEntity(byRef);
    }
    if (fingerprint != null && fingerprint.isNotEmpty) {
      final byFp = await (database.select(database.expenses)
            ..where((t) => t.smsFingerprint.equals(fingerprint)))
          .getSingleOrNull();
      if (byFp != null) return _toEntity(byFp);
    }
    final windowStart = timestamp.subtract(const Duration(minutes: 5));
    final windowEnd = timestamp.add(const Duration(minutes: 5));
    final query = database.select(database.expenses)
      ..where((t) =>
          t.amountMinor.equals(amountMinor) &
          t.timestamp.isBiggerOrEqualValue(windowStart) &
          t.timestamp.isSmallerOrEqualValue(windowEnd));
    if (merchant == null) {
      query.where((t) => t.merchant.isNull());
    } else {
      query.where((t) => t.merchant.equals(merchant));
    }
    final match = await query.getSingleOrNull();
    return match == null ? null : _toEntity(match);
  }

  @override
  Future<domain.Expense> save(domain.Expense expense) async {
    if (expense.id <= 0) {
      final id = await database.into(database.expenses).insert(
            store.ExpensesCompanion.insert(
              amountMinor: expense.amountMinor,
              merchant: Value(expense.merchant),
              categoryId: Value(expense.categoryId),
              note: Value(expense.note),
              referenceNumber: Value(expense.referenceNumber),
              smsFingerprint: Value(expense.smsFingerprint),
              rawSms: Value(expense.rawSms),
              timestamp: expense.timestamp,
              transactionType: Value(_txToInt(expense.transactionType)),
              status: Value(_statusToInt(expense.status)),
              source: Value(_sourceToInt(expense.source)),
              createdAt: expense.createdAt,
              updatedAt: expense.updatedAt,
              lastExportedAt: Value(expense.lastExportedAt),
            ),
          );
      return domain.Expense(
        id: id,
        amountMinor: expense.amountMinor,
        merchant: expense.merchant,
        categoryId: expense.categoryId,
        timestamp: expense.timestamp,
        status: expense.status,
        transactionType: expense.transactionType,
        source: expense.source,
        note: expense.note,
        referenceNumber: expense.referenceNumber,
        smsFingerprint: expense.smsFingerprint,
        rawSms: expense.rawSms,
        lastExportedAt: expense.lastExportedAt,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
    }
    await (database.update(database.expenses)
          ..where((t) => t.id.equals(expense.id)))
        .write(
      store.ExpensesCompanion(
        amountMinor: Value(expense.amountMinor),
        merchant: Value(expense.merchant),
        categoryId: Value(expense.categoryId),
        note: Value(expense.note),
        referenceNumber: Value(expense.referenceNumber),
        smsFingerprint: Value(expense.smsFingerprint),
        rawSms: Value(expense.rawSms),
        timestamp: Value(expense.timestamp),
        transactionType: Value(_txToInt(expense.transactionType)),
        status: Value(_statusToInt(expense.status)),
        source: Value(_sourceToInt(expense.source)),
        updatedAt: Value(expense.updatedAt),
        lastExportedAt: Value(expense.lastExportedAt),
      ),
    );
    return expense;
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.expenses)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<domain.Expense>> queryUnexported() async {
    final rows = await (database.select(database.expenses)
          ..where((t) =>
              t.lastExportedAt.isNull() |
              t.updatedAt.isBiggerThan(t.lastExportedAt))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> markExported(List<int> ids, DateTime exportedAt) async {
    if (ids.isEmpty) return;
    await (database.update(database.expenses)
          ..where((t) => t.id.isIn(ids)))
        .write(
      store.ExpensesCompanion(lastExportedAt: Value(exportedAt)),
    );
  }
}
