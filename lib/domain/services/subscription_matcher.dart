import '../entities/expense.dart';
import '../entities/expected_payment.dart';
import '../entities/subscription.dart';

enum MatchConfidence {
  high,
  mismatchAmount,
  low,
  none,
}

class SubscriptionMatch {
  const SubscriptionMatch({
    required this.confidence,
    this.subscription,
    this.expectedPayment,
  });

  const SubscriptionMatch.none()
      : confidence = MatchConfidence.none,
        subscription = null,
        expectedPayment = null;

  final MatchConfidence confidence;
  final Subscription? subscription;
  final ExpectedPayment? expectedPayment;

  bool get isHighConfidence => confidence == MatchConfidence.high;
  bool get isAmountMismatch => confidence == MatchConfidence.mismatchAmount;
  bool get isMatch =>
      confidence == MatchConfidence.high ||
      confidence == MatchConfidence.mismatchAmount ||
      confidence == MatchConfidence.low;
}

class SubscriptionMatcher {
  const SubscriptionMatcher();

  /// Evaluates an actual [expense] against a list of [subscriptions] and their [upcomingPayments].
  ///
  /// Criteria:
  /// - Expense must be a DEBIT.
  /// - Matches merchant name or merchantPattern.
  /// - Matches date proximity (within [dateWindowDays], default 4 days).
  /// - Exact amount -> [MatchConfidence.high].
  /// - Differing amount -> [MatchConfidence.mismatchAmount].
  SubscriptionMatch match({
    required Expense expense,
    required List<Subscription> subscriptions,
    required List<ExpectedPayment> upcomingPayments,
    int dateWindowDays = 4,
  }) {
    if (expense.transactionType != TransactionType.debit) {
      return const SubscriptionMatch.none();
    }

    final rawMerchant = (expense.merchant ?? '').trim().toLowerCase();
    if (rawMerchant.isEmpty) {
      return const SubscriptionMatch.none();
    }

    SubscriptionMatch? bestMatch;

    for (final subscription in subscriptions) {
      if (!subscription.status.isOngoing) continue;

      final subName = subscription.name.trim().toLowerCase();
      final pattern = subscription.merchantPattern?.trim().toLowerCase();

      final matchesMerchant = _merchantMatches(
        rawMerchant: rawMerchant,
        subName: subName,
        pattern: pattern,
      );

      if (!matchesMerchant) continue;

      // Find upcoming expected payment for this subscription closest to expense timestamp
      final subPayments = upcomingPayments
          .where((p) =>
              p.subscriptionId == subscription.id &&
              p.status == ExpectedPaymentStatus.upcoming)
          .toList()
        ..sort((a, b) {
          final diffA =
              (a.expectedDate.difference(expense.timestamp)).inMilliseconds.abs();
          final diffB =
              (b.expectedDate.difference(expense.timestamp)).inMilliseconds.abs();
          return diffA.compareTo(diffB);
        });

      if (subPayments.isEmpty) {
        // No specific expected payment found in horizon, but matches subscription directly
        if (expense.amountMinor == subscription.amountMinor) {
          return SubscriptionMatch(
            confidence: MatchConfidence.low,
            subscription: subscription,
          );
        }
        continue;
      }

      final nearestPayment = subPayments.first;
      final daysDiff =
          (nearestPayment.expectedDate.difference(expense.timestamp)).inDays.abs();

      if (daysDiff <= dateWindowDays) {
        if (expense.amountMinor == nearestPayment.expectedAmountMinor) {
          // Exact amount & within date window -> HIGH CONFIDENCE!
          return SubscriptionMatch(
            confidence: MatchConfidence.high,
            subscription: subscription,
            expectedPayment: nearestPayment,
          );
        } else {
          // Amount differs, but merchant and date match -> AMOUNT MISMATCH
          bestMatch = SubscriptionMatch(
            confidence: MatchConfidence.mismatchAmount,
            subscription: subscription,
            expectedPayment: nearestPayment,
          );
        }
      }
    }

    return bestMatch ?? const SubscriptionMatch.none();
  }

  bool _merchantMatches({
    required String rawMerchant,
    required String subName,
    String? pattern,
  }) {
    if (pattern != null && pattern.isNotEmpty) {
      if (rawMerchant.contains(pattern) || pattern.contains(rawMerchant)) {
        return true;
      }
    }
    if (rawMerchant.contains(subName) || subName.contains(rawMerchant)) {
      return true;
    }

    // Tokenized check for partial names like "Google" or "YouTube" or "Netflix"
    final subTokens = subName.split(RegExp(r'\s+')).where((t) => t.length > 3);
    for (final token in subTokens) {
      if (rawMerchant.contains(token)) {
        return true;
      }
    }
    return false;
  }
}
