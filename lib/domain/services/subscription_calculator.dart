import '../entities/expected_payment.dart';
import '../entities/subscription.dart';
import '../repositories/expected_payment_repository.dart';

/// Calendar-aware date arithmetic functions.
/// Avoids naive date + 30 days drift.
class SubscriptionDateUtils {
  const SubscriptionDateUtils._();

  /// Adds [months] to [date], clamping to the last valid day of the target month.
  /// Example: Jan 31 + 1 month = Feb 28 (or 29 in leap years).
  static DateTime addMonths(DateTime date, int months) {
    var year = date.year;
    var month = date.month + months;
    while (month > 12) {
      year += 1;
      month -= 12;
    }
    while (month < 1) {
      year -= 1;
      month += 12;
    }
    final maxDaysInMonth = daysInMonth(year, month);
    final day = date.day > maxDaysInMonth ? maxDaysInMonth : date.day;
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
    );
  }

  /// Adds [years] to [date], clamping Feb 29 to Feb 28 in non-leap years.
  static DateTime addYears(DateTime date, int years) {
    final year = date.year + years;
    final maxDaysInMonth = daysInMonth(year, date.month);
    final day = date.day > maxDaysInMonth ? maxDaysInMonth : date.day;
    return DateTime(
      year,
      date.month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
    );
  }

  /// Advances [date] by [cycle].
  static DateTime addCycle(DateTime date, BillingCycle cycle, {int count = 1}) =>
      switch (cycle) {
        BillingCycle.monthly => addMonths(date, count),
        BillingCycle.yearly => addYears(date, count),
      };

  /// Returns the number of days in [month] of [year].
  static int daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  /// True if two dates share the same calendar day (year, month, day).
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Generates and manages the forward horizon of ExpectedPayment records.
class ExpectedPaymentGenerator {
  ExpectedPaymentGenerator({required ExpectedPaymentRepository repository})
      : _repository = repository;

  final ExpectedPaymentRepository _repository;

  /// Generates the next [horizonCount] (default 3) expected payments for [subscription].
  ///
  /// Skips generation if subscription is cancelled or expired.
  /// If existing upcoming payments already exist, only generates missing occurrences
  /// up to [horizonCount].
  Future<List<ExpectedPayment>> syncHorizon(
    Subscription subscription, {
    int horizonCount = 3,
  }) async {
    if (!subscription.status.isOngoing) {
      return [];
    }

    final existing = await _repository.getBySubscriptionId(subscription.id);

    final generated = <ExpectedPayment>[];
    var currentDate = subscription.nextRenewalDate;
    final now = DateTime.now();

    for (var i = 0; i < horizonCount; i++) {
      // Check if an upcoming or matched payment already exists on this day
      final alreadyExists = existing.any((p) =>
          SubscriptionDateUtils.isSameDay(p.expectedDate, currentDate) &&
          p.status != ExpectedPaymentStatus.cancelled);

      if (!alreadyExists) {
        final payment = ExpectedPayment(
          id: 0,
          subscriptionId: subscription.id,
          expectedDate: currentDate,
          expectedAmountMinor: subscription.amountMinor,
          status: ExpectedPaymentStatus.upcoming,
          createdAt: now,
          updatedAt: now,
        );
        final saved = await _repository.save(payment);
        generated.add(saved);
      }

      currentDate = SubscriptionDateUtils.addCycle(
        currentDate,
        subscription.billingCycle,
      );
    }

    return generated;
  }

  /// Cancels all future upcoming expected payments for [subscriptionId].
  /// Used when a subscription is cancelled or deleted.
  Future<void> cancelUpcomingForSubscription(int subscriptionId) async {
    final payments = await _repository.getBySubscriptionId(subscriptionId);
    for (final payment in payments) {
      if (payment.status == ExpectedPaymentStatus.upcoming) {
        await _repository.save(
          payment.copyWith(
            status: ExpectedPaymentStatus.cancelled,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  /// Marks missed payments: any upcoming payment where expectedDate is older
  /// than [now] minus [gracePeriodDays] (default 2 days) becomes `missed`.
  Future<int> evaluateMissedPayments({
    DateTime? now,
    int gracePeriodDays = 2,
  }) async {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(Duration(days: gracePeriodDays));
    final upcoming = await _repository.getUpcoming();
    var markedCount = 0;

    for (final payment in upcoming) {
      if (payment.expectedDate.isBefore(cutoff)) {
        await _repository.save(
          payment.copyWith(
            status: ExpectedPaymentStatus.missed,
            updatedAt: reference,
          ),
        );
        markedCount++;
      }
    }
    return markedCount;
  }
}
