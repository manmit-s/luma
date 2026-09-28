import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> getAll();
  Future<Expense?> findById(int id);
  Future<Expense?> findDuplicate({String? referenceNumber, required String? fingerprint, required int amountMinor, required String? merchant, required DateTime timestamp});
  Future<Expense> save(Expense expense);
  Future<void> delete(int id);
  Future<void> clearAll();
  Future<List<Expense>> queryUnexported();
  Future<void> markExported(List<int> ids, DateTime exportedAt);
}
