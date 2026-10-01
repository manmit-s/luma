import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/widgets/balance_card.dart';
import 'package:luma/app/widgets/first_launch_flow.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/data/services/app_settings_store.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/services/export/export_service.dart';

void main() {
  group('FirstLaunchFlow Widget', () {
    testWidgets('completes 3-step serene onboarding and validates inputs',
        (tester) async {
      String? submittedName;
      int? submittedBalanceMinor;

      await tester.pumpWidget(
        MaterialApp(
          home: FirstLaunchFlow(
            onComplete: (name, balanceMinor) async {
              submittedName = name;
              submittedBalanceMinor = balanceMinor;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Welcome Screen
      expect(find.text('Luma'), findsOneWidget);
      expect(find.text('Remember where your money went.'), findsOneWidget);
      expect(
        find.text(
            'Luma keeps track of your spending as it happens, so you don\'t have to remember it later.'),
        findsOneWidget,
      );

      // Tap "Get started"
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      // Step 2: Name Screen
      expect(find.textContaining('What should Luma'), findsOneWidget);
      expect(find.text('Step 1 of 2'), findsOneWidget);

      // "Continue" button is disabled when name is empty
      final continueButtonFinder = find.widgetWithText(FilledButton, 'Continue');
      expect(tester.widget<FilledButton>(continueButtonFinder).onPressed, isNull);

      // Enter name
      await tester.enterText(find.byType(TextField), 'Manmit');
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(continueButtonFinder).onPressed,
        isNotNull,
      );

      // Tap "Continue"
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();

      // Step 3: Initial Balance Screen
      expect(find.textContaining('current balance?'), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(
        find.text(
            'Enter the balance in your account right now. Luma will update it as transactions are recorded.'),
        findsOneWidget,
      );

      final finishButtonFinder =
          find.widgetWithText(FilledButton, 'Start using Luma');
      // Empty balance is disabled
      expect(tester.widget<FilledButton>(finishButtonFinder).onPressed, isNull);

      // Enter invalid balance
      await tester.enterText(find.byType(TextField), '-50');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finishButtonFinder).onPressed, isNull);

      // Enter 0 (valid: user has 0 balance)
      await tester.enterText(find.byType(TextField), '0');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finishButtonFinder).onPressed, isNotNull);

      // Enter ₹3,000.50
      await tester.enterText(find.byType(TextField), '3000.50');
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finishButtonFinder).onPressed, isNotNull);

      // Tap "Start using Luma"
      await tester.tap(finishButtonFinder);
      await tester.pumpAndSettle();

      expect(submittedName, 'Manmit');
      expect(submittedBalanceMinor, 300050);
    });
  });

  group('Balance Semantics & Calculation', () {
    test('Current Balance = Initial Balance + Credits - Debits', () async {
      final repo = MemoryExpenseRepository(seed: false);
      final controller = ExpenseController(repository: repo);
      // User starts with ₹3,000
      controller.setInitialBalance(300000);
      await controller.load();

      expect(controller.initialBalanceMinor, 300000);
      expect(controller.currentBalanceMinor, 300000);
      expect(controller.monthTotal, 0);

      // Record a debit (expense) of ₹500
      await repo.save(Expense(
        id: 0,
        amountMinor: 50000,
        merchant: 'Groceries',
        categoryId: 'food',
        timestamp: DateTime.now(),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.manual,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await controller.load();

      // Current balance: 3000 - 500 = 2500
      expect(controller.currentBalanceMinor, 250000);
      // Monthly spending reflects the debit
      expect(controller.monthTotal, 50000);

      // Record a credit of ₹1,000 (e.g. UPI received / refund)
      await repo.save(Expense(
        id: 0,
        amountMinor: 100000,
        merchant: 'Salary / Refund',
        categoryId: 'other',
        timestamp: DateTime.now(),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.credit,
        source: ExpenseSource.manual,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await controller.load();

      // Current balance: 2500 + 1000 = 3500
      expect(controller.currentBalanceMinor, 350000);
      // Monthly spending remains ₹500 (credits are NOT counted as expenses)
      expect(controller.monthTotal, 50000);
    });
  });

  group('BalanceCard & Home Display', () {
    testWidgets('BalanceCard displays current balance and initial balance snapshot',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              currentBalanceMinor: 250000,
              initialBalanceMinor: 300000,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CURRENT BALANCE'), findsOneWidget);
      expect(find.textContaining('2,500'), findsOneWidget);
      expect(find.textContaining('Started with ₹3,000'), findsOneWidget);
    });
  });

  group('Export Balance Ledger', () {
    test('XLSX export includes summary header and chronological balance column',
        () async {
      final dir = await Directory.systemTemp.createTemp('luma_bal_test');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });

      final repo = MemoryExpenseRepository(seed: false);
      final store = AppSettingsStore(null);
      await store.setInitialBalanceMinor(200000); // ₹2,000 starting balance

      final service = ExportService(
        repo,
        null,
        settingsStore: store,
        outputDir: () async => dir,
      );

      // Debit ₹300 at 10 AM
      await repo.save(Expense(
        id: 1,
        amountMinor: 30000,
        merchant: 'Coffee',
        categoryId: 'food',
        timestamp: DateTime(2026, 9, 29, 10, 0),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.manual,
        createdAt: DateTime(2026, 9, 29, 10, 0),
        updatedAt: DateTime(2026, 9, 29, 10, 0),
      ));

      // Credit ₹500 at 12 PM
      await repo.save(Expense(
        id: 2,
        amountMinor: 50000,
        merchant: 'Cashback',
        categoryId: 'other',
        timestamp: DateTime(2026, 9, 29, 12, 0),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.credit,
        source: ExpenseSource.manual,
        createdAt: DateTime(2026, 9, 29, 12, 0),
        updatedAt: DateTime(2026, 9, 29, 12, 0),
      ));

      final result = await service.generate(ExportMode.full);
      final bytes = result.file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final table = excel.tables['Expenses']!;

      final rows = table.rows.map((r) => r.map((c) => c?.value).toList()).toList();

      num valOf(dynamic cell) {
        if (cell is DoubleCellValue) return cell.value;
        if (cell is IntCellValue) return cell.value;
        return (cell as dynamic).value as num;
      }

      // Top Summary
      expect(rows[0][0]?.toString(), 'LUMA EXPENSE SUMMARY');
      expect(rows[1][0]?.toString(), 'Initial Balance:');
      expect(valOf(rows[1][1]).toDouble(), 2000.0);
      expect(rows[2][0]?.toString(), 'Total Credits:');
      expect(valOf(rows[2][1]).toDouble(), 500.0);
      expect(rows[3][0]?.toString(), 'Total Debits:');
      expect(valOf(rows[3][1]).toDouble(), 300.0);
      expect(rows[4][0]?.toString(), 'Current Balance:');
      expect(valOf(rows[4][1]).toDouble(), 2200.0);

      // Table Header at row 6
      final headers = rows[6].map((c) => (c as TextCellValue).value.toString()).toList();
      expect(headers, contains('Balance'));

      // Row 7 (Coffee): 2000 - 300 = 1700
      expect(valOf(rows[7][5]).toDouble(), 300.0); // Amount
      expect(valOf(rows[7][6]).toDouble(), 1700.0); // Running Balance

      // Row 8 (Cashback): 1700 + 500 = 2200
      expect(valOf(rows[8][5]).toDouble(), 500.0); // Amount
      expect(valOf(rows[8][6]).toDouble(), 2200.0); // Running Balance
    });
  });
}
