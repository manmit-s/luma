import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/application/subscription_controller.dart';
import 'package:luma/data/repositories/memory_expected_payment_repository.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/data/repositories/memory_subscription_repository.dart';
import 'package:luma/domain/entities/expected_payment.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/entities/subscription.dart';
import 'package:luma/domain/services/subscription_calculator.dart';
import 'package:luma/domain/services/subscription_matcher.dart';
import 'package:luma/services/export/export_service.dart';

void main() {
  group('Subscription Date Utils & Calendar Arithmetic', () {
    test('monthly addition clamps to month end correctly (Jan 31 -> Feb 28)', () {
      final jan31 = DateTime(2026, 1, 31);
      final next = SubscriptionDateUtils.addCycle(jan31, BillingCycle.monthly);
      expect(next.year, 2026);
      expect(next.month, 2);
      expect(next.day, 28);
    });

    test('monthly addition respects leap year (Jan 31, 2024 -> Feb 29, 2024)', () {
      final jan31Leap = DateTime(2024, 1, 31);
      final next = SubscriptionDateUtils.addCycle(jan31Leap, BillingCycle.monthly);
      expect(next.year, 2024);
      expect(next.month, 2);
      expect(next.day, 29);
    });

    test('30-day month to 31-day month preserves day (Nov 30 -> Dec 30)', () {
      final nov30 = DateTime(2026, 11, 30);
      final next = SubscriptionDateUtils.addCycle(nov30, BillingCycle.monthly);
      expect(next.year, 2026);
      expect(next.month, 12);
      expect(next.day, 30);
    });

    test('yearly cycle adds exactly one calendar year', () {
      final start = DateTime(2026, 3, 15);
      final next = SubscriptionDateUtils.addCycle(start, BillingCycle.yearly);
      expect(next.year, 2027);
      expect(next.month, 3);
      expect(next.day, 15);
    });
  });

  group('Expected Payment Generation', () {
    test('maintains a 3-occurrence forward horizon', () async {
      final paymentRepo = MemoryExpectedPaymentRepository();
      final generator = ExpectedPaymentGenerator(repository: paymentRepo);

      final sub = Subscription(
        id: 1,
        name: 'Spotify',
        amountMinor: 11900,
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 15),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      final generated = await generator.syncHorizon(sub, horizonCount: 3);
      expect(generated.length, 3);
      expect(generated[0].expectedDate, DateTime(2026, 10, 15));
      expect(generated[1].expectedDate, DateTime(2026, 11, 15));
      expect(generated[2].expectedDate, DateTime(2026, 12, 15));
      expect(generated[0].expectedAmountMinor, 11900);
      expect(generated[0].status, ExpectedPaymentStatus.upcoming);
    });
  });

  group('Subscription Matching & Reconciliation (Tests 1 - 7)', () {
    late MemorySubscriptionRepository subRepo;
    late MemoryExpectedPaymentRepository paymentRepo;
    late MemoryExpenseRepository expenseRepo;
    late ExpenseController expenseController;
    late SubscriptionController subController;

    setUp(() async {
      subRepo = MemorySubscriptionRepository();
      paymentRepo = MemoryExpectedPaymentRepository();
      expenseRepo = MemoryExpenseRepository(seed: false);
      expenseController = ExpenseController(repository: expenseRepo);
      subController = SubscriptionController(
        subscriptionRepository: subRepo,
        expectedPaymentRepository: paymentRepo,
      );
      await subController.load();
      await expenseController.load();
    });

    test('Test 1: Balance unchanged by expected payment; drops only on actual debit', () async {
      // 1. Initial balance ₹3000
      expenseController.setInitialBalance(300000);
      expect(expenseController.currentBalanceMinor, 300000);

      // 2. Create subscription with upcoming expected payment of ₹129
      final sub = await subController.createSubscription(
        name: 'YouTube Premium',
        amountMinor: 12900,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 12),
      );

      expect(subController.expectedPayments.length, 3);
      // Expected payments MUST NOT affect account balance!
      expect(expenseController.currentBalanceMinor, 300000);

      // 3. An actual debit SMS arrives: ₹129 on 12 Oct
      final expense = await expenseController.processSms(
        'Your A/C XX1234 debited by Rs.129.00 at YouTube on 12-10-2026. UPI Ref 998877',
        receivedAt: DateTime(2026, 10, 12),
      );
      expect(expense, isNotNull);
      expect(expenseController.currentBalanceMinor, 300000 - 12900); // Balance drops to ₹2871!

      // 4. Auto-reconcile
      final match = await subController.matchAndReconcile(expense!);
      expect(match.isHighConfidence, isTrue);
      expect(match.subscription?.id, sub.id);

      // Verify the expected payment status is matched and linked to expense id
      final payments = subController.expectedPayments
          .where((p) => p.subscriptionId == sub.id)
          .toList();
      final matchedPayment = payments.firstWhere((p) => p.isMatched);
      expect(matchedPayment.matchedExpenseId, expense.id);

      // Verify subscription renewal date was advanced by 1 month
      final updatedSub = await subRepo.findById(sub.id);
      expect(updatedSub?.nextRenewalDate, DateTime(2026, 11, 12));

      // Balance remains ₹2871 (no double deduction)
      expect(expenseController.currentBalanceMinor, 287100);
    });

    test('Test 2: Amount mismatch surfaced; actual expense retains actual amount', () async {
      await subController.createSubscription(
        name: 'YouTube Premium',
        amountMinor: 12900,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 12),
      );

      // Bank debited ₹149 instead of ₹129 (price hike)
      final expense = await expenseController.processSms(
        'Your A/C XX1234 debited by Rs.149.00 at YouTube on 12-10-2026. UPI Ref 112233',
        receivedAt: DateTime(2026, 10, 12),
      );
      expect(expense, isNotNull);
      expect(expense!.amountMinor, 14900);

      final matcher = SubscriptionMatcher();
      final match = matcher.match(
        expense: expense,
        subscriptions: subController.subscriptions,
        upcomingPayments: subController.expectedPayments,
      );

      expect(match.isAmountMismatch, isTrue);
      final diff = (match.expectedPayment!.expectedAmountMinor - expense.amountMinor).abs();
      expect(diff, 2000); // ₹20 difference
      // Actual expense record still records ₹149
      expect(expense.amountMinor, 14900);
    });

    test('Test 3: Cancellation stops future payments and reminders; historical expenses remain', () async {
      // 1. Setup subscription and simulate 1 historical payment
      final sub = await subController.createSubscription(
        name: 'Netflix',
        amountMinor: 64900,
        startDate: DateTime(2026, 9, 1),
        nextRenewalDate: DateTime(2026, 10, 1),
      );

      // Past expense
      await expenseController.addManual(
        amountMinor: 64900,
        merchant: 'Netflix',
        categoryId: 'subscriptions',
      );
      expect(expenseController.expenses.length, 1);

      // 2. Cancel subscription
      await subController.cancelSubscription(sub.id);

      final cancelledSub = await subRepo.findById(sub.id);
      expect(cancelledSub?.isCancelled, isTrue);

      // Verify future expected payments are cancelled
      final upcoming = subController.expectedPayments
          .where((p) => p.subscriptionId == sub.id && p.isUpcoming)
          .toList();
      expect(upcoming, isEmpty);

      // Historical expenses MUST NOT be deleted
      expect(expenseController.expenses.length, 1);
      expect(expenseController.expenses.first.merchant, 'Netflix');
    });

    test('Test 4: Manual subscription with no payment causes zero balance change and no fabricated expense', () async {
      expenseController.setInitialBalance(500000);

      // Create manual subscription
      await subController.createSubscription(
        name: 'Gym Membership',
        amountMinor: 200000,
        paymentMethod: PaymentMethod.manual,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 5),
      );

      // No SMS received, no payment made
      expect(expenseController.expenses, isEmpty);
      expect(expenseController.currentBalanceMinor, 500000);
    });

    test('Test 5: Duplicate SMS deduplication results in single expense and single match', () async {
      final sub = await subController.createSubscription(
        name: 'iCloud',
        amountMinor: 7500,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 10),
      );

      const smsText =
          'Your A/C XX1234 debited by Rs.75.00 at Apple iCloud on 10-10-2026. UPI Ref 556677';

      // First SMS arrival
      final first = await expenseController.processSms(
        smsText,
        receivedAt: DateTime(2026, 10, 10),
      );
      expect(first, isNotNull);
      expect(expenseController.expenses.length, 1);

      await subController.matchAndReconcile(first!);

      // Duplicate SMS arrival with exact same text/ref
      final second = await expenseController.processSms(
        smsText,
        receivedAt: DateTime(2026, 10, 10),
      );
      expect(second?.id, first.id); // deduplicated to same expense
      expect(expenseController.expenses.length, 1); // No new expense created

      // Subscriptions should still only have 1 matched payment
      final matchedCount = subController.expectedPayments
          .where((p) => p.subscriptionId == sub.id && p.isMatched)
          .length;
      expect(matchedCount, 1);
    });

    test('Test 6: Merchant matching with pattern and normalization', () {
      final matcher = SubscriptionMatcher();
      final sub = Subscription(
        id: 1,
        name: 'Google One',
        merchantPattern: 'GOOGLE',
        amountMinor: 13000,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 20),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      final payment = ExpectedPayment(
        id: 1,
        subscriptionId: 1,
        expectedDate: DateTime(2026, 10, 20),
        expectedAmountMinor: 13000,
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      final exp = Expense(
        id: 10,
        amountMinor: 13000,
        merchant: 'GOOGLE INDIA SERVICES MUMBAI',
        categoryId: null,
        timestamp: DateTime(2026, 10, 20),
        status: ExpenseStatus.pending,
        transactionType: TransactionType.debit,
        source: ExpenseSource.sms,
        createdAt: DateTime(2026, 10, 20),
        updatedAt: DateTime(2026, 10, 20),
      );

      final match = matcher.match(
        expense: exp,
        subscriptions: [sub],
        upcomingPayments: [payment],
      );

      expect(match.isHighConfidence, isTrue);
      expect(match.subscription?.name, 'Google One');
      expect(match.isAmountMismatch, isFalse);
    });

    test('Test 7: Export service generates Sheet 2 without corrupting Sheet 1 ledger', () async {
      final expense = Expense(
        id: 1,
        amountMinor: 12900,
        merchant: 'YouTube',
        categoryId: 'subscriptions',
        timestamp: DateTime(2026, 10, 12),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.sms,
        createdAt: DateTime(2026, 10, 12),
        updatedAt: DateTime(2026, 10, 12),
      );

      final sub = Subscription(
        id: 1,
        name: 'YouTube Premium',
        amountMinor: 12900,
        billingCycle: BillingCycle.monthly,
        paymentMethod: PaymentMethod.autopay,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 11, 12),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      await expenseRepo.save(expense);
      await subRepo.save(sub);

      final tempDir = Directory.systemTemp.createTempSync('luma_test_');
      final exportService = ExportService(
        expenseRepo,
        null,
        subscriptionRepository: subRepo,
        outputDir: () async => tempDir,
      );

      final result = await exportService.generate(ExportMode.full);
      expect(result.file.existsSync(), isTrue);
      expect(result.count, 1);

      // Verify Excel contents
      final bytes = result.file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.containsKey('Expenses'), isTrue);
      expect(excel.tables.containsKey('Subscriptions'), isTrue);

      final subSheet = excel.tables['Subscriptions']!;
      expect(subSheet.rows.length, greaterThanOrEqualTo(2)); // Header + 1 subscription row
      expect(subSheet.rows[1][0]?.value.toString(), 'YouTube Premium');

      tempDir.deleteSync(recursive: true);
    });
  });
}
