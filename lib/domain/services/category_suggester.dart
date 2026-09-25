import '../entities/expense.dart';

abstract interface class CategorySuggester {
  String? suggestionFor(String? merchant);
  Future<void> learn(Expense expense);
}
