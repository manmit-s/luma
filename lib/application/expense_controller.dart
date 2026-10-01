import 'package:flutter/foundation.dart';

import '../core/utils/sms_fingerprint.dart';
import '../data/repositories/memory_expense_repository.dart';
import '../domain/entities/expense.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/services/category_suggester.dart';
import '../domain/services/merchant_learning.dart';
import '../domain/services/sms_transaction_parser.dart';

class ExpenseController extends ChangeNotifier {
  ExpenseController(
      {ExpenseRepository? repository, CategorySuggester? learning})
      : _repository = repository ?? MemoryExpenseRepository(),
        _learning = learning ?? MerchantLearning();

  final ExpenseRepository _repository;
  final CategorySuggester _learning;
  List<Expense> expenses = [];
  bool isLoading = false;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      expenses = await _repository.getAll();
      error = null;
    } catch (exception) {
      error = exception;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int _initialBalanceMinor = 0;
  int get initialBalanceMinor => _initialBalanceMinor;

  void setInitialBalance(int minor) {
    _initialBalanceMinor = minor;
    notifyListeners();
  }

  int get totalCreditsMinor => expenses
      .where((expense) => expense.transactionType == TransactionType.credit)
      .fold(0, (sum, expense) => sum + expense.amountMinor);

  int get totalDebitsMinor => expenses
      .where((expense) => expense.transactionType == TransactionType.debit)
      .fold(0, (sum, expense) => sum + expense.amountMinor);

  int get currentBalanceMinor =>
      _initialBalanceMinor + totalCreditsMinor - totalDebitsMinor;

  int get monthTotal {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.transactionType == TransactionType.debit &&
            expense.timestamp.year == now.year &&
            expense.timestamp.month == now.month)
        .fold(0, (sum, expense) => sum + expense.amountMinor);
  }

  int get todayTotal {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
            expense.transactionType == TransactionType.debit &&
            expense.timestamp.year == now.year &&
            expense.timestamp.month == now.month &&
            expense.timestamp.day == now.day)
        .fold(0, (sum, expense) => sum + expense.amountMinor);
  }

  List<Expense> get pending => expenses.where((expense) => expense.isPending).toList();

  List<Expense> get unexported => expenses
      .where((expense) =>
          expense.lastExportedAt == null ||
          expense.updatedAt.isAfter(expense.lastExportedAt!))
      .toList();

  Future<void> _refresh() async {
    expenses = await _repository.getAll();
    notifyListeners();
  }

  Future<void> complete(Expense expense,
      {required String categoryId,
      String note = '',
      TransactionType? transactionType}) async {
    final updated = expense.copyWith(
        categoryId: categoryId,
        note: note,
        transactionType: transactionType ?? expense.transactionType,
        status: ExpenseStatus.completed,
        updatedAt: DateTime.now());
    await _repository.save(updated);
    await _learning.learn(updated);
    await _refresh();
  }

  Future<void> updateExpense(Expense expense) async {
    final updated = expense.copyWith(updatedAt: DateTime.now());
    await _repository.save(updated);
    if (updated.categoryId != null && updated.status == ExpenseStatus.completed) {
      await _learning.learn(updated);
    }
    await _refresh();
  }

  Future<void> deleteExpense(int id) async {
    await _repository.delete(id);
    await _refresh();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    await _refresh();
  }

  Future<void> markExported(List<int> ids, DateTime exportedAt) async {
    await _repository.markExported(ids, exportedAt);
    await _refresh();
  }

  Future<void> addManual(
      {required int amountMinor,
      required String merchant,
      required String categoryId,
      String note = '',
      TransactionType transactionType = TransactionType.debit}) async {
    final now = DateTime.now();
    final draft = Expense(
        id: 0,
        amountMinor: amountMinor,
        merchant: merchant.isEmpty ? null : merchant,
        categoryId: categoryId,
        note: note,
        timestamp: now,
        status: ExpenseStatus.completed,
        transactionType: transactionType,
        source: ExpenseSource.manual,
        createdAt: now,
        updatedAt: now);
    final saved = await _repository.save(draft);
    await _learning.learn(saved);
    await _refresh();
  }

  Future<Expense?> processSms(String message, {DateTime? receivedAt}) async {
    final parsed =
        SmsTransactionParser().parse(message, receivedAt: receivedAt);
    if (parsed == null || parsed.transactionType == TransactionType.unknown) {
      return null;
    }
    final fingerprint = smsFingerprint(message);
    final duplicate = await _repository.findDuplicate(
        referenceNumber: parsed.referenceNumber,
        fingerprint: fingerprint,
        amountMinor: parsed.amountMinor,
        merchant: parsed.merchant,
        timestamp: parsed.timestamp ?? receivedAt ?? DateTime.now());
    if (duplicate != null) return duplicate;
    final now = DateTime.now();
    final draft = Expense(
        id: 0,
        amountMinor: parsed.amountMinor,
        merchant: parsed.merchant,
        categoryId: _learning.suggestionFor(parsed.merchant),
        timestamp: parsed.timestamp ?? receivedAt ?? now,
        status: ExpenseStatus.pending,
        transactionType: parsed.transactionType,
        referenceNumber: parsed.referenceNumber,
        rawSms: parsed.rawMessage,
        smsFingerprint: fingerprint,
        source: ExpenseSource.sms,
        createdAt: now,
        updatedAt: now);
    final saved = await _repository.save(draft);
    await _refresh();
    return saved;
  }
}
