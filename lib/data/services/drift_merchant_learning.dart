import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/expense.dart' as domain;
import '../../domain/services/category_suggester.dart';
import '../../domain/services/merchant_normalizer.dart';
import '../database/luma_database.dart';

/// Frequency-based learning persisted in `merchant_profiles`.
///
/// Keeps a sync in-memory cache for `suggestionFor` (used on the SMS hot
/// path) and writes through to Drift on every `learn`.
class DriftMerchantLearning implements CategorySuggester {
  DriftMerchantLearning(this.db, {MerchantNormalizer? normalizer})
      : _normalizer = normalizer ?? MerchantNormalizer();

  final LumaDatabase db;
  final MerchantNormalizer _normalizer;
  final Map<String, Map<String, int>> _counts = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final rows = await db.select(db.merchantProfiles).get();
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row.categoryCounts) as Map<String, dynamic>;
        _counts[row.normalizedMerchant] = {
          for (final e in decoded.entries) e.key: (e.value as num).toInt(),
        };
      } catch (_) {
        _counts[row.normalizedMerchant] = {};
      }
    }
    _loaded = true;
  }

  @override
  String? suggestionFor(String? merchant) {
    final counts = _counts[_normalizer.normalize(merchant)];
    if (counts == null || counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Future<void> learn(domain.Expense expense) async {
    final normalized = _normalizer.normalize(expense.merchant);
    final category = expense.categoryId;
    if (normalized.isEmpty || category == null || category.isEmpty) return;
    await load();
    final counts = _counts.putIfAbsent(normalized, () => {});
    counts[category] = (counts[category] ?? 0) + 1;

    final existing = await (db.select(db.merchantProfiles)
          ..where((t) => t.normalizedMerchant.equals(normalized)))
        .getSingleOrNull();
    final now = DateTime.now();
    if (existing == null) {
      await db.into(db.merchantProfiles).insert(
            MerchantProfilesCompanion.insert(
              normalizedMerchant: normalized,
              displayMerchant: (expense.merchant ?? normalized).trim(),
              categoryCounts: Value(jsonEncode(counts)),
              lastUsedCategory: Value(category),
              totalTransactions: const Value(1),
              updatedAt: now,
            ),
          );
    } else {
      await (db.update(db.merchantProfiles)
            ..where((t) => t.normalizedMerchant.equals(normalized)))
          .write(
        MerchantProfilesCompanion(
          categoryCounts: Value(jsonEncode(counts)),
          lastUsedCategory: Value(category),
          totalTransactions: Value(existing.totalTransactions + 1),
          updatedAt: Value(now),
        ),
      );
    }
  }
}
