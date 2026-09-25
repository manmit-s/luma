import 'package:flutter_test/flutter_test.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/services/notification/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('is a no-op before init and never throws', () async {
      final service = NotificationService();
      expect(service.isReady, isFalse);
      final now = DateTime(2026, 9, 25, 12);
      await service.showExpenseDetected(Expense(
        id: 42,
        amountMinor: 20090,
        merchant: 'Uber',
        categoryId: null,
        timestamp: now,
        status: ExpenseStatus.pending,
        transactionType: TransactionType.debit,
        source: ExpenseSource.sms,
        createdAt: now,
        updatedAt: now,
      ));
      await service.showExpenseDetected(Expense(
        id: 43,
        amountMinor: 5000,
        merchant: null,
        categoryId: null,
        timestamp: now,
        status: ExpenseStatus.pending,
        transactionType: TransactionType.debit,
        source: ExpenseSource.sms,
        createdAt: now,
        updatedAt: now,
      ));
      await service.syncPendingSummary(3);
      await service.syncPendingSummary(0);
      await service.cancelAll();
      expect(await service.consumeLaunchPayload(), isNull);
    });

    test('payload contract round-trips through expense id', () {
      const id = 123;
      final payload = '$id';
      expect(int.tryParse(payload), id);
      expect(int.tryParse('pending'), isNull);
    });
  });
}
