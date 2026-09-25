import 'package:flutter_test/flutter_test.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/services/merchant_learning.dart';
import 'package:luma/domain/services/merchant_normalizer.dart';
import 'package:luma/domain/services/sms_transaction_parser.dart';
import 'package:luma/application/expense_controller.dart';

void main() {
  group('MerchantNormalizer', () {
    test('maps casing, punctuation, and whitespace to one key', () {
      final normalizer = MerchantNormalizer();
      expect(normalizer.normalize(' Google India Dig '), 'google india dig');
      expect(normalizer.normalize('GOOGLE-INDIA DIG'), 'google india dig');
    });
  });

  group('SmsTransactionParser', () {
    test('parses a debit amount and reference', () {
      final parsed = SmsTransactionParser().parse('Your A/C XX1234 debited by Rs.200.90 at Uber on 23-09-2026. UPI Ref 123456789');
      expect(parsed?.amountMinor, 20090);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.referenceNumber, '123456789');
    });

    test('ignores unrelated messages', () {
      expect(SmsTransactionParser().parse('Your OTP is 482910'), isNull);
    });
  });

  test('merchant learning returns the highest frequency category', () {
    final learning = MerchantLearning();
    final base = DateTime(2026, 9, 25);
    for (var index = 0; index < 2; index++) {
      learning.learn(Expense(id: index, amountMinor: 1000, merchant: 'Uber', categoryId: 'travel', timestamp: base, status: ExpenseStatus.completed, transactionType: TransactionType.debit, source: ExpenseSource.manual));
    }
    learning.learn(Expense(id: 3, amountMinor: 1000, merchant: 'UBER', categoryId: 'food', timestamp: base, status: ExpenseStatus.completed, transactionType: TransactionType.debit, source: ExpenseSource.manual));
    expect(learning.suggestionFor(' uber '), 'travel');
  });

  test('processing the same SMS twice does not create a duplicate', () async {
    final controller = ExpenseController();
    final message = 'Your A/C XX1234 debited by Rs.200.90 at Uber. UPI Ref 123456789';
    final first = await controller.processSms(message);
    final second = await controller.processSms(message);
    expect(first?.status, ExpenseStatus.pending);
    expect(second?.id, first?.id);
    expect(controller.expenses.where((expense) => expense.referenceNumber == '123456789'), hasLength(1));
  });
}
