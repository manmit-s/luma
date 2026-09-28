import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class MemoryExpenseRepository implements ExpenseRepository {
  MemoryExpenseRepository({bool seed = true}) : _expenses = seed ? _seed() : [];

  final List<Expense> _expenses;

  @override
  Future<List<Expense>> getAll() async => List.unmodifiable(_expenses);

  @override
  Future<Expense?> findById(int id) async => _firstOrNull(_expenses.where((expense) => expense.id == id));

  @override
  Future<Expense?> findDuplicate({String? referenceNumber, required String? fingerprint, required int amountMinor, required String? merchant, required DateTime timestamp}) async {
    return _firstOrNull(_expenses.where((expense) {
      if (referenceNumber != null && referenceNumber.isNotEmpty && expense.referenceNumber == referenceNumber) return true;
      if (fingerprint != null && fingerprint.isNotEmpty && expense.smsFingerprint == fingerprint) return true;
      return expense.amountMinor == amountMinor && expense.merchant == merchant && expense.timestamp.difference(timestamp).abs() <= const Duration(minutes: 5);
    }));
  }

  @override
  Future<Expense> save(Expense expense) async {
    if (expense.id <= 0) {
      final nextId =
          _expenses.fold(0, (max, item) => item.id > max ? item.id : max) + 1;
      final created = Expense(
        id: nextId,
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
      _expenses.insert(0, created);
      return created;
    }
    final index = _expenses.indexWhere((item) => item.id == expense.id);
    if (index == -1) {
      _expenses.insert(0, expense);
    } else {
      _expenses[index] = expense;
    }
    return expense;
  }

  @override
  Future<void> delete(int id) async => _expenses.removeWhere((expense) => expense.id == id);

  @override
  Future<void> clearAll() async => _expenses.clear();

  /// Test-only helper: drop all expenses including seeds.
  void clearForTest() => _expenses.clear();

  @override
  Future<List<Expense>> queryUnexported() async => _expenses
      .where((expense) =>
          expense.lastExportedAt == null ||
          expense.updatedAt.isAfter(expense.lastExportedAt!))
      .toList();

  @override
  Future<void> markExported(List<int> ids, DateTime exportedAt) async {
    for (var i = 0; i < _expenses.length; i++) {
      if (ids.contains(_expenses[i].id)) {
        _expenses[i].lastExportedAt = exportedAt;
      }
    }
  }

  static List<Expense> _seed() => [
    Expense(id: 1, amountMinor: 129900, merchant: 'Urban Company', categoryId: 'personal', timestamp: DateTime(2026, 9, 25, 12, 42), status: ExpenseStatus.completed, transactionType: TransactionType.debit, source: ExpenseSource.sms, note: 'Monthly home service'),
    Expense(id: 2, amountMinor: 45900, merchant: 'Google India Dig', categoryId: 'subscriptions', timestamp: DateTime(2026, 9, 24, 20, 15), status: ExpenseStatus.completed, transactionType: TransactionType.debit, source: ExpenseSource.sms),
    Expense(id: 3, amountMinor: 28000, merchant: 'Uber', categoryId: null, timestamp: DateTime(2026, 9, 24, 9, 10), status: ExpenseStatus.pending, transactionType: TransactionType.debit, source: ExpenseSource.sms),
    Expense(id: 4, amountMinor: 8500, merchant: 'College Canteen', categoryId: 'food', timestamp: DateTime(2026, 9, 23, 13, 3), status: ExpenseStatus.completed, transactionType: TransactionType.debit, source: ExpenseSource.manual),
  ];

  static Expense? _firstOrNull(Iterable<Expense> values) => values.isEmpty ? null : values.first;
}
