import '../entities/expense.dart';
import 'category_suggester.dart';
import 'merchant_normalizer.dart';

class MerchantLearning implements CategorySuggester {
  MerchantLearning({MerchantNormalizer? normalizer}) : _normalizer = normalizer ?? MerchantNormalizer();

  final MerchantNormalizer _normalizer;
  final Map<String, Map<String, int>> _counts = {};

  @override
  String? suggestionFor(String? merchant) {
    final counts = _counts[_normalizer.normalize(merchant)];
    if (counts == null || counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Future<void> learn(Expense expense) async {
    final merchant = _normalizer.normalize(expense.merchant);
    final category = expense.categoryId;
    if (merchant.isEmpty || category == null || category.isEmpty) return;
    final counts = _counts.putIfAbsent(merchant, () => {});
    counts[category] = (counts[category] ?? 0) + 1;
  }
}
