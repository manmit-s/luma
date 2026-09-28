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
    test('parses a debit amount and reference and merchant', () {
      final parsed = SmsTransactionParser().parse(
        'Your A/C XX1234 debited by Rs.200.90 at Uber on 23-09-2026. UPI Ref 123456789',
      );
      expect(parsed?.amountMinor, 20090);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'Uber');
      expect(parsed?.referenceNumber, '123456789');
    });

    test('parses HDFC VPA format', () {
      final parsed = SmsTransactionParser().parse(
        'Dear Customer, INR 450.00 debited from A/c **1234 on 28-SEP-26 to VPA swiggy@icici (UPI Ref No 123456789012). Avl Bal: INR 10,230.50 - HDFC Bank',
      );
      expect(parsed?.amountMinor, 45000);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant?.toLowerCase(), 'swiggy');
      expect(parsed?.referenceNumber, '123456789012');
    });

    test('parses ICICI credit card and POS format', () {
      final parsed = SmsTransactionParser().parse(
        "Alert: You've spent Rs. 1,499.00 on your ICICI Bank Credit Card XX1002 on 28-Sep-26 at AMAZON INDIA. Avl Lmt: Rs. 85,000.00.",
      );
      expect(parsed?.amountMinor, 149900);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'AMAZON INDIA');
    });

    test('parses ICICI Info format', () {
      final parsed = SmsTransactionParser().parse(
        'Dear Customer, your Ac XXXXX123 is debited with INR 850.00 on 28-Sep-26. Info: BIL*NETFLIX. Avail Bal: INR 12,000.00.',
      );
      expect(parsed?.amountMinor, 85000);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'NETFLIX');
    });

    test('parses Axis Bank UPI deep path format', () {
      final parsed = SmsTransactionParser().parse(
        'INR 320.00 debited from Axis Bank A/c no. XX1234 on 28-09-26 for UPI/P2M/426812345678/Zomato. Avl bal: INR 5,420.00',
      );
      expect(parsed?.amountMinor, 32000);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'Zomato');
      expect(parsed?.referenceNumber, '426812345678');
    });

    test('parses simple paid to merchant format', () {
      final parsed = SmsTransactionParser().parse(
        'Paid Rs. 200 to Starbucks on 28 Sep. UPI Ref: 426812345678.',
      );
      expect(parsed?.amountMinor, 20000);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'Starbucks');
      expect(parsed?.referenceNumber, '426812345678');
    });

    test('parses sent to person via UPI', () {
      final parsed = SmsTransactionParser().parse(
        'Sent Rs.150.00 from Kotak Bank AC X1234 to Ramesh Sharma on 28-09-26. UPI Ref 426812345678. Bal Rs 1200.',
      );
      expect(parsed?.amountMinor, 15000);
      expect(parsed?.transactionType, TransactionType.debit);
      expect(parsed?.merchant, 'Ramesh Sharma');
      expect(parsed?.referenceNumber, '426812345678');
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
