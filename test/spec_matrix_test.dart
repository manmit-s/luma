import 'package:flutter_test/flutter_test.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/core/utils/sms_fingerprint.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/services/merchant_learning.dart';
import 'package:luma/domain/services/merchant_normalizer.dart';
import 'package:luma/domain/services/sms_transaction_parser.dart';

/// SPEC 49 (unit-test matrix) + SPEC 51 (SMS matrix).
void main() {
  final parser = SmsTransactionParser();

  group('Amount parsing (SPEC 13)', () {
    test('supports Rs/Rs./INR/₹ with and without paise', () {
      expect(parser.parse('Paid Rs.200 at X')?.amountMinor, 20000);
      expect(parser.parse('Paid Rs 200 at X')?.amountMinor, 20000);
      expect(parser.parse('Paid INR 200 at X')?.amountMinor, 20000);
      expect(parser.parse('Paid ₹200 at X')?.amountMinor, 20000);
      expect(parser.parse('Paid ₹200.90 at X')?.amountMinor, 20090);
      expect(parser.parse('Paid INR 200.90 at X')?.amountMinor, 20090);
    });

    test('handles comma-grouped amounts', () {
      expect(
        parser.parse('Rs.1,250.50 debited from A/C XX1234')?.amountMinor,
        125050,
      );
    });

    test('rejects zero amounts', () {
      expect(parser.parse('Rs.0 debited from A/C XX1234'), isNull);
    });
  });

  group('Transaction classification (SPEC 12)', () {
    test('credit SMS is typed credit, never debit', () {
      final parsed = parser.parse(
        'Your A/C XX1234 credited with Rs.500.00 on 23-09-2026. Ref 987654',
      );
      expect(parsed?.transactionType, TransactionType.credit);
    });

    test('mixed credit+debit wording falls back to debit', () {
      final parsed = parser.parse(
        'Rs.100 debited; credit limit updated. Ref 112233',
      );
      expect(parsed?.transactionType, TransactionType.debit);
    });

    test('controller processes credit SMS and updates balance without inflating expenses', () async {
      final repo = MemoryExpenseRepository(seed: false);
      final controller = ExpenseController(repository: repo);
      controller.setInitialBalance(100000); // ₹1,000.00
      await controller.load();
      final before = controller.expenses.length;
      final result = await controller.processSms(
        'Your A/C XX1234 credited with Rs.500.00. Ref 987654',
      );
      expect(result, isNotNull);
      expect(result?.transactionType, TransactionType.credit);
      expect(controller.expenses.length, before + 1);
      // Balance increased by ₹500 (1000 + 500 = 1500)
      expect(controller.currentBalanceMinor, 150000);
      // Spending total is NOT inflated by credits
      expect(controller.monthTotal, 0);
    });
  });

  group('SMS robustness (SPEC 51)', () {
    test('unrelated SMS is ignored', () {
      expect(parser.parse('Your OTP is 482910'), isNull);
      expect(parser.parse('Sale! Flat 50% off this weekend'), isNull);
    });

    test('malformed SMS without an amount is ignored', () {
      expect(parser.parse('debited by Rs. at Uber'), isNull);
      expect(parser.parse('Rs. debited from your account'), isNull);
    });

    test('missing merchant yields null merchant, not invented text', () {
      final parsed = parser.parse(
        'Your A/C XX1234 debited by Rs.200.90 on 23-09-2026',
      );
      expect(parsed?.amountMinor, 20090);
      expect(parsed?.merchant, isNull);
    });

    test('missing reference yields null reference with lower confidence', () {
      final withRef = parser.parse(
        'Rs.200 debited from A/C XX1234. UPI Ref 123456789',
      );
      final withoutRef = parser.parse(
        'Rs.200 debited from A/C XX1234 on 23-09-2026',
      );
      expect(withRef?.referenceNumber, '123456789');
      expect(withRef?.confidence, 0.9);
      expect(withoutRef?.referenceNumber, isNull);
      expect(withoutRef?.confidence, 0.75);
    });

    test('multi-segment spacing differences share one fingerprint', () {
      const one = 'Your A/C XX1234 debited  by Rs.200.90. UPI Ref 123456789';
      const two = 'your  a/c xx1234 debited by rs.200.90. upi ref 123456789';
      expect(smsFingerprint(one), smsFingerprint(two));
    });

    test('duplicate window: 3 minutes matches, 10 minutes does not',
        () async {
      final repo = MemoryExpenseRepository()..clearForTest();
      final base = DateTime(2026, 9, 25, 12);
      await repo.save(Expense(
        id: 0,
        amountMinor: 10000,
        merchant: null,
        categoryId: null,
        timestamp: base,
        status: ExpenseStatus.pending,
        transactionType: TransactionType.debit,
        source: ExpenseSource.sms,
        createdAt: base,
        updatedAt: base,
      ));
      final near = await repo.findDuplicate(
        fingerprint: 'fp-other-1',
        amountMinor: 10000,
        merchant: null,
        timestamp: base.add(const Duration(minutes: 3)),
      );
      expect(near, isNotNull);
      final far = await repo.findDuplicate(
        fingerprint: 'fp-other-2',
        amountMinor: 10000,
        merchant: null,
        timestamp: base.add(const Duration(minutes: 10)),
      );
      expect(far, isNull);
    });
  });

  group('SBI bare-amount format (real-world regression)', () {
    // Exact shape reported from a live SBI debit SMS (account masked).
    const sbiSms =
        'Dear UPI user A/C X9937 debited by 1.00 on date 26Sep26 trf to '
        'JAGANNATH SAMAL Refno 626933738544 If not u? call-1800111109 for '
        'other services-18001234-SBI';

    test('parses amount, payee and reference without a currency marker',
        () {
      final parsed = parser.parse(sbiSms);
      expect(parsed, isNotNull);
      expect(parsed?.amountMinor, 100);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'JAGANNATH SAMAL');
      expect(parsed?.referenceNumber, '626933738544');
    });

    test('Refno/Ref No/Reference variants all resolve', () {
      expect(
        parser.parse('Rs.10 debited. Refno 1122334455')?.referenceNumber,
        '1122334455',
      );
      expect(
        parser.parse('Rs.10 debited. Ref No 1122334455')?.referenceNumber,
        '1122334455',
      );
      expect(
        parser.parse('Rs.10 debited. Ref: 1122334455')?.referenceNumber,
        '1122334455',
      );
    });

    test('bare amount requires the debit-verb shape (no phone/ref matches)',
        () {
      // Phone helplines and ref numbers must never parse as amounts.
      expect(parser.parse('If not u? call-1800111109 for help'), isNull);
      expect(parser.parse('Refno 626933738544 status ok'), isNull);
    });

    test('full controller flow creates a pending expense', () async {
      final controller = ExpenseController();
      await controller.load();
      final created = await controller.processSms(sbiSms);
      expect(created, isNotNull);
      expect(created?.status, ExpenseStatus.pending);
      expect(created?.merchant, 'JAGANNATH SAMAL');
      // Same SMS twice still dedupes.
      final again = await controller.processSms(sbiSms);
      expect(again?.id, created?.id);
    });
  });

  group('Merchant normalization (SPEC 25)', () {
    test('aggressive punctuation still maps to one key', () {
      final normalizer = MerchantNormalizer();
      expect(normalizer.normalize('Uber!!!'), 'uber');
      expect(normalizer.normalize('  UBER   TRIP  '), 'uber trip');
      expect(normalizer.normalize(null), isEmpty);
      expect(normalizer.normalize('   '), isEmpty);
    });
  });

  group('Category learning (SPEC 22-24)', () {
    test('suggestion only appears after user categorization', () async {
      final learning = MerchantLearning();
      expect(learning.suggestionFor('Swiggy'), isNull);
      final base = DateTime(2026, 9, 25);
      await learning.learn(Expense(
        id: 1,
        amountMinor: 1000,
        merchant: 'Swiggy',
        categoryId: 'food',
        timestamp: base,
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.manual,
      ));
      expect(learning.suggestionFor('swiggy'), 'food');
    });

    test('empty merchant or category teaches nothing', () async {
      final learning = MerchantLearning();
      final base = DateTime(2026, 9, 25);
      Expense at(String? merchant, String? category) => Expense(
            id: 1,
            amountMinor: 100,
            merchant: merchant,
            categoryId: category,
            timestamp: base,
            status: ExpenseStatus.completed,
            transactionType: TransactionType.debit,
            source: ExpenseSource.manual,
          );
      await learning.learn(at(null, 'food'));
      await learning.learn(at('Uber', null));
      await learning.learn(at('Uber', ''));
      expect(learning.suggestionFor('uber'), isNull);
    });

    test('controller learns the final choice, not its own suggestion',
        () async {
      final controller = ExpenseController();
      await controller.load();
      final created = await controller.processSms(
        'Rs.450.00 spent. UPI Ref LEARN999',
      );
      expect(created, isNotNull);
      // Suggestion path alone teaches nothing observable yet; completing with
      // a category must stick for the merchant profile.
      await controller.complete(
        created!,
        categoryId: 'shopping',
        note: '',
      );
      expect(
        controller.expenses
            .where((e) => e.id == created.id)
            .single
            .categoryId,
        'shopping',
      );
    });
  });
}
