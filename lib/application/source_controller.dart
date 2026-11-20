import 'package:flutter/foundation.dart';

import '../data/repositories/memory_source_repository.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/internal_transfer.dart';
import '../domain/entities/payment_source.dart';
import '../domain/repositories/source_repository.dart';

class SourceBreakdown {
  const SourceBreakdown({
    required this.combinedBalanceMinor,
    required this.totalBankBalanceMinor,
    required this.cashBalanceMinor,
    required this.individualBalances,
  });

  final int combinedBalanceMinor;
  final int totalBankBalanceMinor;
  final int cashBalanceMinor;
  final Map<int, int> individualBalances;
}

class SourceFinancialSummary {
  const SourceFinancialSummary({
    required this.source,
    required this.openingBalanceMinor,
    required this.incomeMinor,
    required this.expensesMinor,
    required this.transfersReceivedMinor,
    required this.transfersSentMinor,
    required this.closingBalanceMinor,
  });

  final PaymentSource source;
  final int openingBalanceMinor;
  final int incomeMinor;
  final int expensesMinor;
  final int transfersReceivedMinor;
  final int transfersSentMinor;
  final int closingBalanceMinor;
}

class SourceController extends ChangeNotifier {
  SourceController({SourceRepository? repository})
      : _repository = repository ?? MemorySourceRepository();

  final SourceRepository _repository;

  List<PaymentSource> sources = [];
  List<InternalTransfer> transfers = [];
  List<Expense> _expenses = [];
  bool isLoading = false;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      sources = await _repository.getAllSources();
      transfers = await _repository.getAllTransfers();
      error = null;
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  PaymentSource? get cashWallet {
    for (final s in sources) {
      if (s.isWallet) return s;
    }
    return null;
  }

  List<PaymentSource> get activeSources =>
      sources.where((s) => s.isActive).toList();

  List<PaymentSource> get activeBankSources =>
      sources.where((s) => s.isActive && s.isBank).toList();

  PaymentSource? byId(int? id) {
    if (id == null) return null;
    for (final s in sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Reliable ledger-based calculation for an individual source.
  int balanceFor(int sourceId, [List<Expense>? expenses]) {
    final source = byId(sourceId);
    if (source == null) return 0;

    final opening = source.openingBalanceMinor;
    var income = 0;
    var expense = 0;
    final txList = expenses ?? _expenses;

    for (final tx in txList) {
      if (tx.sourceId == sourceId && tx.status == ExpenseStatus.completed) {
        if (tx.transactionType == TransactionType.credit) {
          income += tx.amountMinor;
        } else if (tx.transactionType == TransactionType.debit) {
          expense += tx.amountMinor;
        }
      }
    }

    var transfersReceived = 0;
    var transfersSent = 0;
    for (final trf in transfers) {
      if (trf.toSourceId == sourceId) {
        transfersReceived += trf.amountMinor;
      }
      if (trf.fromSourceId == sourceId) {
        transfersSent += trf.amountMinor;
      }
    }

    return opening + income - expense + transfersReceived - transfersSent;
  }

  SourceFinancialSummary summaryFor(PaymentSource source, [List<Expense>? expenses]) {
    final opening = source.openingBalanceMinor;
    var income = 0;
    var expense = 0;
    final txList = expenses ?? _expenses;

    for (final tx in txList) {
      if (tx.sourceId == source.id && tx.status == ExpenseStatus.completed) {
        if (tx.transactionType == TransactionType.credit) {
          income += tx.amountMinor;
        } else if (tx.transactionType == TransactionType.debit) {
          expense += tx.amountMinor;
        }
      }
    }

    var transfersReceived = 0;
    var transfersSent = 0;
    for (final trf in transfers) {
      if (trf.toSourceId == source.id) {
        transfersReceived += trf.amountMinor;
      }
      if (trf.fromSourceId == source.id) {
        transfersSent += trf.amountMinor;
      }
    }

    final closing =
        opening + income - expense + transfersReceived - transfersSent;

    return SourceFinancialSummary(
      source: source,
      openingBalanceMinor: opening,
      incomeMinor: income,
      expensesMinor: expense,
      transfersReceivedMinor: transfersReceived,
      transfersSentMinor: transfersSent,
      closingBalanceMinor: closing,
    );
  }

  /// Total combined balance across all active sources.
  int combinedBalanceMinor([List<Expense>? expenses]) {
    var total = 0;
    for (final s in activeSources) {
      total += balanceFor(s.id, expenses);
    }
    return total;
  }

  /// Total balance across active bank accounts.
  int totalBankBalanceMinor([List<Expense>? expenses]) {
    var total = 0;
    for (final s in activeBankSources) {
      total += balanceFor(s.id, expenses);
    }
    return total;
  }

  /// Balance for active cash wallet.
  int cashBalanceMinor([List<Expense>? expenses]) {
    var total = 0;
    for (final s in activeSources) {
      if (s.isWallet) {
        total += balanceFor(s.id, expenses);
      }
    }
    return total;
  }

  SourceBreakdown breakdownFor([List<Expense>? expenses]) {
    final txList = expenses ?? _expenses;
    final individual = <int, int>{};
    for (final s in sources) {
      individual[s.id] = balanceFor(s.id, txList);
    }
    return SourceBreakdown(
      combinedBalanceMinor: combinedBalanceMinor(txList),
      totalBankBalanceMinor: totalBankBalanceMinor(txList),
      cashBalanceMinor: cashBalanceMinor(txList),
      individualBalances: individual,
    );
  }

  SourceBreakdown get breakdown => breakdownFor(_expenses);

  Future<PaymentSource> addBankSource({
    required BankCatalogueItem bank,
    String? nickname,
    String? accountNumberLast4,
    int openingBalanceMinor = 0,
    bool isActive = true,
  }) async {
    final now = DateTime.now();
    final source = PaymentSource(
      id: 0,
      type: PaymentSourceType.bank,
      bankName: bank.name,
      bankIdentifier: bank.id,
      nickname: nickname?.trim().isEmpty == true ? null : nickname?.trim(),
      accountNumberLast4: accountNumberLast4?.trim().isEmpty == true
          ? null
          : accountNumberLast4?.trim(),
      openingBalanceMinor: openingBalanceMinor,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
    final saved = await _repository.saveSource(source);
    sources = await _repository.getAllSources();
    notifyListeners();
    return saved;
  }

  Future<PaymentSource> saveSource(PaymentSource source) async {
    final saved = await _repository.saveSource(source);
    sources = await _repository.getAllSources();
    notifyListeners();
    return saved;
  }

  Future<void> toggleSourceActive(int sourceId) async {
    final source = byId(sourceId);
    if (source == null) return;
    final updated = source.copyWith(isActive: !source.isActive);
    await saveSource(updated);
  }

  Future<void> deleteSource(int sourceId) async {
    await _repository.deleteSource(sourceId);
    sources = await _repository.getAllSources();
    notifyListeners();
  }

  Future<InternalTransfer> createTransfer({
    required int fromSourceId,
    required int toSourceId,
    required int amountMinor,
    String note = '',
    DateTime? timestamp,
  }) async {
    final now = DateTime.now();
    final transfer = InternalTransfer(
      id: 0,
      fromSourceId: fromSourceId,
      toSourceId: toSourceId,
      amountMinor: amountMinor,
      timestamp: timestamp ?? now,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final saved = await _repository.saveTransfer(transfer);
    transfers = await _repository.getAllTransfers();
    notifyListeners();
    return saved;
  }

  Future<void> deleteTransfer(int transferId) async {
    await _repository.deleteTransfer(transferId);
    transfers = await _repository.getAllTransfers();
    notifyListeners();
  }
}
