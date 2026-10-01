import 'package:flutter/foundation.dart';

import '../data/repositories/memory_expected_payment_repository.dart';
import '../data/repositories/memory_subscription_repository.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/expected_payment.dart';
import '../domain/entities/subscription.dart';
import '../domain/repositories/expected_payment_repository.dart';
import '../domain/repositories/subscription_repository.dart';
import '../domain/services/subscription_calculator.dart';
import '../domain/services/subscription_matcher.dart';
import '../domain/services/subscription_scheduler.dart';
import '../services/notification/notification_service.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController({
    SubscriptionRepository? subscriptionRepository,
    ExpectedPaymentRepository? expectedPaymentRepository,
    ExpectedPaymentGenerator? generator,
    SubscriptionMatcher? matcher,
    SubscriptionScheduler? scheduler,
  })  : _subRepo = subscriptionRepository ?? MemorySubscriptionRepository(),
        _paymentRepo =
            expectedPaymentRepository ?? MemoryExpectedPaymentRepository(),
        _generator = generator ??
            ExpectedPaymentGenerator(
              repository:
                  expectedPaymentRepository ?? MemoryExpectedPaymentRepository(),
            ),
        _matcher = matcher ?? const SubscriptionMatcher(),
        _scheduler = scheduler ?? SubscriptionScheduler();

  final SubscriptionRepository _subRepo;
  final ExpectedPaymentRepository _paymentRepo;
  final ExpectedPaymentGenerator _generator;
  final SubscriptionMatcher _matcher;
  final SubscriptionScheduler _scheduler;

  List<Subscription> subscriptions = [];
  List<ExpectedPayment> expectedPayments = [];
  bool isLoading = false;
  Object? error;

  List<Subscription> get activeSubscriptions =>
      subscriptions.where((s) => s.status.isOngoing).toList();

  List<ExpectedPayment> get upcomingPayments => expectedPayments
      .where((p) => p.status == ExpectedPaymentStatus.upcoming)
      .toList()
    ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

  List<ExpectedPayment> recentMatchedPayments(int subscriptionId) =>
      expectedPayments
          .where((p) =>
              p.subscriptionId == subscriptionId &&
              p.status == ExpectedPaymentStatus.matched)
          .toList()
        ..sort((a, b) => b.expectedDate.compareTo(a.expectedDate));

  Future<void> load({DateTime? now}) async {
    isLoading = true;
    notifyListeners();
    try {
      // Evaluate any missed payments first
      await _generator.evaluateMissedPayments(now: now);
      subscriptions = await _subRepo.getAll();
      expectedPayments = await _paymentRepo.getAll();
      // Check for any due reminders today
      await _scheduler.checkAndFireDueReminders(subscriptions, now: now);
      error = null;
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refresh() async {
    subscriptions = await _subRepo.getAll();
    expectedPayments = await _paymentRepo.getAll();
    notifyListeners();
  }

  /// Creates a new subscription and generates its forward horizon of expected payments.
  Future<Subscription> createSubscription({
    required String name,
    String? merchantPattern,
    required int amountMinor,
    BillingCycle billingCycle = BillingCycle.monthly,
    PaymentMethod paymentMethod = PaymentMethod.autopay,
    SubscriptionStatus status = SubscriptionStatus.active,
    required DateTime startDate,
    required DateTime nextRenewalDate,
    DateTime? trialEndDate,
    bool cancellationReminderEnabled = false,
    int cancellationReminderDaysBefore = 3,
    bool paymentReminderEnabled = false,
    int paymentReminderDaysBefore = 1,
  }) async {
    final now = DateTime.now();
    final draft = Subscription(
      id: 0,
      name: name,
      merchantPattern: merchantPattern,
      amountMinor: amountMinor,
      billingCycle: billingCycle,
      paymentMethod: paymentMethod,
      status: status,
      startDate: startDate,
      nextRenewalDate: nextRenewalDate,
      trialEndDate: trialEndDate,
      cancellationReminderEnabled: cancellationReminderEnabled,
      cancellationReminderDaysBefore: cancellationReminderDaysBefore,
      paymentReminderEnabled: paymentReminderEnabled,
      paymentReminderDaysBefore: paymentReminderDaysBefore,
      createdAt: now,
      updatedAt: now,
    );
    final saved = await _subRepo.save(draft);
    await _generator.syncHorizon(saved);
    await _refresh();
    return saved;
  }

  /// Updates an existing subscription.
  Future<void> updateSubscription(Subscription subscription) async {
    await _subRepo.save(subscription.copyWith(updatedAt: DateTime.now()));
    // Sync upcoming payments to reflect any amount or cycle changes
    if (subscription.status.isOngoing) {
      await _generator.syncHorizon(subscription);
    } else if (subscription.isCancelled || subscription.isExpired) {
      await _generator.cancelUpcomingForSubscription(subscription.id);
      await _scheduler.cancelReminders(subscription.id);
    }
    await _refresh();
  }

  /// Cancels a subscription: marks status = cancelled, cancels future expected payments,
  /// and cancels future reminders. Historical payments and expenses are preserved intact.
  Future<void> cancelSubscription(int id) async {
    final sub = await _subRepo.findById(id);
    if (sub == null) return;
    final updated = sub.copyWith(
      status: SubscriptionStatus.cancelled,
      endDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _subRepo.save(updated);
    await _generator.cancelUpcomingForSubscription(id);
    await _scheduler.cancelReminders(id);
    await _refresh();
  }

  /// Deletes a subscription and its expected payments.
  Future<void> deleteSubscription(int id) async {
    await _scheduler.cancelReminders(id);
    await _paymentRepo.deleteBySubscriptionId(id);
    await _subRepo.delete(id);
    await _refresh();
  }

  /// Evaluates an expense against subscriptions and upcoming payments.
  /// If high confidence match, links the payment and advances the subscription.
  Future<SubscriptionMatch> matchAndReconcile(Expense expense) async {
    final match = _matcher.match(
      expense: expense,
      subscriptions: subscriptions,
      upcomingPayments: expectedPayments,
    );

    if (match.isHighConfidence &&
        match.subscription != null &&
        match.expectedPayment != null) {
      final sub = match.subscription!;
      final payment = match.expectedPayment!;

      // 1. Mark expected payment as matched with real expense id
      await _paymentRepo.save(
        payment.copyWith(
          status: ExpectedPaymentStatus.matched,
          matchedExpenseId: expense.id,
          updatedAt: DateTime.now(),
        ),
      );

      // 2. Advance subscription nextRenewalDate
      final nextRenewal = SubscriptionDateUtils.addCycle(
        payment.expectedDate,
        sub.billingCycle,
      );
      final updatedSub = sub.copyWith(
        nextRenewalDate: nextRenewal,
        updatedAt: DateTime.now(),
      );
      await _subRepo.save(updatedSub);

      // 3. Generate the next upcoming occurrence
      await _generator.syncHorizon(updatedSub);

      // 4. Notification for matched subscription
      await notificationService.showSubscriptionMatched(
        sub.name,
        expense.amountMinor,
      );

      await _refresh();
    }

    return match;
  }

  /// Manually links an expense to an expected payment (e.g. for missed payments).
  Future<void> linkExpenseToExpectedPayment({
    required int expectedPaymentId,
    required int expenseId,
  }) async {
    final payment = await _paymentRepo.findById(expectedPaymentId);
    if (payment == null) return;

    await _paymentRepo.save(
      payment.copyWith(
        status: ExpectedPaymentStatus.matched,
        matchedExpenseId: expenseId,
        updatedAt: DateTime.now(),
      ),
    );

    final sub = await _subRepo.findById(payment.subscriptionId);
    if (sub != null && sub.status.isOngoing) {
      final nextRenewal = SubscriptionDateUtils.addCycle(
        payment.expectedDate,
        sub.billingCycle,
      );
      final updatedSub = sub.copyWith(
        nextRenewalDate: nextRenewal,
        updatedAt: DateTime.now(),
      );
      await _subRepo.save(updatedSub);
      await _generator.syncHorizon(updatedSub);
    }
    await _refresh();
  }

  /// Unlinks an incorrectly matched expected payment (user correction: "Not this subscription").
  Future<void> unlinkExpectedPayment(int expectedPaymentId) async {
    final payment = await _paymentRepo.findById(expectedPaymentId);
    if (payment == null) return;

    await _paymentRepo.save(
      payment.copyWith(
        status: ExpectedPaymentStatus.upcoming,
        matchedExpenseId: null,
        updatedAt: DateTime.now(),
      ),
    );
    await _refresh();
  }
}
