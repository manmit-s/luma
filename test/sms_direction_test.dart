import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/providers.dart';
import 'package:luma/app/widgets/expense_sheets.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/application/subscription_controller.dart';
import 'package:luma/data/repositories/memory_expected_payment_repository.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/data/repositories/memory_subscription_repository.dart';
import 'package:luma/domain/entities/expected_payment.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/entities/subscription.dart';
import 'package:luma/domain/services/sms_transaction_parser.dart';
import 'package:luma/domain/services/subscription_matcher.dart';

void main() {
  final parser = SmsTransactionParser();

  group('SMS Direction Parser Tests', () {
    test('TEST 1 — SBI credit parses as CREDIT with amountMinor = 200 and merchant YouTube', () {
      const sms =
          'Dear SBI User, your A/c X9937-credited by Rs.2.00 on 01Oct26 transfer from YouTube Ref No 6XXXXX03XX2746 -SBI';
      final parsed = parser.parse(sms);

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, TransactionType.credit);
      expect(parsed.amountMinor, 200);
      expect(parsed.merchant, 'YouTube');
      expect(parsed.referenceNumber, '6XXXXX03XX2746');
    });

    test('TEST 2 — SBI debit parses as DEBIT with amountMinor = 20000', () {
      const sms =
          'Dear SBI User, your A/c X9937-debited by Rs.200.00 on 01Oct26 at Swiggy Ref No 123456789 -SBI';
      final parsed = parser.parse(sms);

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, TransactionType.debit);
      expect(parsed.amountMinor, 20000);
      expect(parsed.merchant, 'Swiggy');
    });

    test('TEST 3 — Explicit credit wording produces CREDIT', () {
      final samples = [
        'A/c credited by Rs.500.00 on 01-10-2026. Ref 112233',
        'Amount credited Rs.1,200 to your account from Salary. Ref 998877',
        'Your account credited with INR 350.00. Ref 554433',
        'Rs.150.00 received from Rahul via UPI. Ref 332211',
        'Rs.499.00 deposited into A/C XX1234. Ref 887766',
        'Cashback of Rs.50 credited for recharge. Ref 445566',
        'Refund of Rs.299.00 credited to your account. Ref 778899',
      ];

      for (final sms in samples) {
        final parsed = parser.parse(sms);
        expect(parsed, isNotNull, reason: 'Failed to parse: $sms');
        expect(parsed!.transactionType, TransactionType.credit,
            reason: 'Expected CREDIT for: $sms');
      }
    });

    test('TEST 4 — Explicit debit wording produces DEBIT', () {
      final samples = [
        'A/c debited by Rs.500.00 at Starbucks on 01-10-2026. Ref 112233',
        'Amount debited Rs.1,200 for Uber ride. Ref 998877',
        'Rs.250 spent on your ICICI Credit Card at Dominos. Ref 554433',
        'Rs.1,000 withdrawn from ATM XX1234. Ref 332211',
        'Paid Rs.150.00 to Swiggy using UPI. Ref 887766',
        'Rs.100 debited; credit limit updated. Ref 445566',
      ];

      for (final sms in samples) {
        final parsed = parser.parse(sms);
        expect(parsed, isNotNull, reason: 'Failed to parse: $sms');
        expect(parsed!.transactionType, TransactionType.debit,
            reason: 'Expected DEBIT for: $sms');
      }
    });

    test('TEST 5 — Unknown direction produces UNKNOWN and not silently DEBIT', () {
      const sms = 'Rs.500 at Starbucks on 01-10-2026. Ref 123456';
      final parsed = parser.parse(sms);

      expect(parsed, isNotNull);
      expect(parsed!.transactionType, TransactionType.unknown);
      expect(parsed.amountMinor, 50000);
      expect(parsed.merchant, 'Starbucks');
    });

    test('TEST 6 — Subscription mismatch: CREDIT never matches an expected subscription DEBIT', () {
      final matcher = const SubscriptionMatcher();

      final sub = Subscription(
        id: 1,
        name: 'YouTube Premium',
        amountMinor: 12900,
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2026, 10, 1),
        nextRenewalDate: DateTime(2026, 10, 12),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      final payment = ExpectedPayment(
        id: 1,
        subscriptionId: 1,
        expectedDate: DateTime(2026, 10, 12),
        expectedAmountMinor: 12900,
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );

      // Incoming transaction is a CREDIT of ₹129 from YouTube
      final creditExpense = Expense(
        id: 99,
        amountMinor: 12900,
        merchant: 'YouTube',
        categoryId: null,
        timestamp: DateTime(2026, 10, 12),
        status: ExpenseStatus.pending,
        transactionType: TransactionType.credit, // CREDIT!
        source: ExpenseSource.sms,
        createdAt: DateTime(2026, 10, 12),
        updatedAt: DateTime(2026, 10, 12),
      );

      final match = matcher.match(
        expense: creditExpense,
        subscriptions: [sub],
        upcomingPayments: [payment],
      );

      // Must NOT match because it is a CREDIT!
      expect(match.isMatch, isFalse);
      expect(match.isHighConfidence, isFalse);
      expect(match.subscription, isNull);
    });
  });

  group('Balance Integration Tests', () {
    test('Incoming ₹2 credit increases initial ₹3000 to ₹3002, not ₹2998', () async {
      final repo = MemoryExpenseRepository(seed: false);
      final controller = ExpenseController(repository: repo);
      controller.setInitialBalance(300000); // ₹3,000.00
      await controller.load();

      expect(controller.currentBalanceMinor, 300000);

      // Process the real SBI credit SMS
      final expense = await controller.processSms(
        'Dear SBI User, your A/c X9937-credited by Rs.2.00 on 01Oct26 transfer from YouTube Ref No 6XXXXX03XX2746 -SBI',
      );

      expect(expense, isNotNull);
      expect(expense!.transactionType, TransactionType.credit);
      expect(expense.amountMinor, 200);

      // Balance = 300,000 + 200 = 300,200 (₹3,002.00)
      expect(controller.totalCreditsMinor, 200);
      expect(controller.totalDebitsMinor, 0);
      expect(controller.currentBalanceMinor, 300200);
    });
  });

  group('UI Categorization Screen Tests', () {
    testWidgets('Complete expense sheet opens with Credit selected for credit expense', (tester) async {
      final repo = MemoryExpenseRepository(seed: false);
      final expenseController = ExpenseController(repository: repo);
      final subRepo = MemorySubscriptionRepository();
      final paymentRepo = MemoryExpectedPaymentRepository();
      final subController = SubscriptionController(
        subscriptionRepository: subRepo,
        expectedPaymentRepository: paymentRepo,
      );

      final creditExpense = Expense(
        id: 1,
        amountMinor: 200,
        merchant: 'YouTube',
        categoryId: null,
        timestamp: DateTime(2026, 10, 1),
        status: ExpenseStatus.pending,
        transactionType: TransactionType.credit,
        source: ExpenseSource.sms,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseControllerProvider.overrideWith((_) => expenseController),
            subscriptionControllerProvider.overrideWith((_) => subController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () => showCompleteExpense(context, ref, creditExpense),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Check that 'Save credit' button is present
      expect(find.text('Save credit'), findsOneWidget);
      expect(find.text('Credit (Income)'), findsOneWidget);
      expect(find.text('Debit (Expense)'), findsOneWidget);
    });
  });
}
