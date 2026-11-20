import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';

import 'package:luma/app/widgets/balance_card.dart';
import 'package:luma/app/widgets/expense_sheets.dart';
import 'package:luma/application/source_controller.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/data/repositories/memory_source_repository.dart';
import 'package:luma/domain/entities/expense.dart';
import 'package:luma/domain/entities/internal_transfer.dart';
import 'package:luma/domain/entities/payment_source.dart';
import 'package:luma/domain/services/sms_transaction_parser.dart';
import 'package:luma/services/export/export_service.dart';

void main() {
  group('Bank Catalogue', () {
    test('contains popular Indian banks across all three tiers', () {
      expect(indianBankCatalogue.length, greaterThanOrEqualTo(30));

      final majorBanks = indianBankCatalogue
          .where((b) => b.tier == BankTier.major)
          .toList();
      final midTierBanks = indianBankCatalogue
          .where((b) => b.tier == BankTier.midTier)
          .toList();
      final smallFinanceBanks = indianBankCatalogue
          .where((b) => b.tier == BankTier.smallFinance)
          .toList();

      expect(majorBanks.isNotEmpty, isTrue);
      expect(midTierBanks.isNotEmpty, isTrue);
      expect(smallFinanceBanks.isNotEmpty, isTrue);

      // Verify key banks exist
      expect(findBankInCatalogue('sbi'), isNotNull);
      expect(findBankInCatalogue('hdfc'), isNotNull);
      expect(findBankInCatalogue('icici'), isNotNull);
      expect(findBankInCatalogue('axis'), isNotNull);
      expect(findBankInCatalogue('kotak'), isNotNull);
      expect(findBankInCatalogue('au_sf'), isNotNull);
      expect(findBankInCatalogue('equitas_sf'), isNotNull);
    });

    test('findBankInCatalogue finds by identifier or partial name', () {
      final sbi = findBankInCatalogue('State Bank of India');
      expect(sbi, isNotNull);
      expect(sbi!.id, 'sbi');

      final hdfc = findBankInCatalogue('HDFC BANK');
      expect(hdfc, isNotNull);
      expect(hdfc!.id, 'hdfc');

      final unknown = findBankInCatalogue('NonExistentBankXYZ');
      expect(unknown, isNull);
    });
  });

  group('SMS Parsing & Automatic Source Identification', () {
    final parser = SmsTransactionParser();

    test('extracts bank name, account number suffix, and sender ID', () {
      const sms =
          'Dear SBI User, your A/C ending 4567 debited by Rs.1,500.00 on 12-Oct-26 by UPI:Swiggy. Ref: 6283921738';
      final parsed = parser.parse(sms, sender: 'SBIINB');

      expect(parsed, isNotNull);
      expect(parsed!.amountMinor, 150000);
      expect(parsed.transactionType, TransactionType.debit);
      expect(parsed.accountNumberSuffix, '4567');
      expect(parsed.bankIdentifier, 'sbi');
      expect(parsed.senderId, 'SBIINB');
    });

    test('distinguishes UPI payment provider from debited bank account', () {
      const gpaySms =
          'Paid Rs.350 to Chai Point via Google Pay from HDFC Bank A/c *8899. Ref: UPI/678912';
      final parsed = parser.parse(gpaySms, sender: 'HDFCBK');

      expect(parsed, isNotNull);
      expect(parsed!.amountMinor, 35000);
      expect(parsed.accountNumberSuffix, '8899');
      // Must identify HDFC as the bank, not Google Pay or any other provider
      expect(parsed.bankIdentifier, 'hdfc');
    });

    test('matches configured source confidently when account suffix matches', () {
      final hdfcAccount = PaymentSource(
        id: 10,
        type: PaymentSourceType.bank,
        bankName: 'HDFC Bank',
        bankIdentifier: 'hdfc',
        accountNumberLast4: '8899',
        openingBalanceMinor: 500000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final sbiAccount = PaymentSource(
        id: 11,
        type: PaymentSourceType.bank,
        bankName: 'State Bank of India',
        bankIdentifier: 'sbi',
        accountNumberLast4: '4567',
        openingBalanceMinor: 200000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sources = [hdfcAccount, sbiAccount];

      const sms =
          'Sent Rs.450.00 from HDFC Bank A/C **8899 to Zomato UPI. Ref 123456';
      final parsed = parser.parse(sms, sender: 'HDFCBK')!;

      final matched = SmsTransactionParser.matchConfiguredSource(
        parsed: parsed,
        sources: sources,
      );
      expect(matched, 10);
    });

    test('leaves source unresolved when bank cannot be matched or multiple accounts match without suffix', () {
      final hdfcAcc1 = PaymentSource(
        id: 10,
        type: PaymentSourceType.bank,
        bankName: 'HDFC Bank',
        bankIdentifier: 'hdfc',
        accountNumberLast4: '1111',
        openingBalanceMinor: 100000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final hdfcAcc2 = PaymentSource(
        id: 11,
        type: PaymentSourceType.bank,
        bankName: 'HDFC Bank',
        bankIdentifier: 'hdfc',
        accountNumberLast4: '2222',
        openingBalanceMinor: 100000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sources = [hdfcAcc1, hdfcAcc2];

      // SMS mentions HDFC but no account number suffix
      const sms = 'Dear Customer, Rs.500 spent on HDFC Bank Card. Ref 998877';
      final parsed = parser.parse(sms, sender: 'HDFCBK')!;

      final matched = SmsTransactionParser.matchConfiguredSource(
        parsed: parsed,
        sources: sources,
      );
      // Multiple HDFC accounts exist without suffix -> unresolved (null)
      expect(matched, isNull);
    });
  });

  group('Balance Management & Ledger Calculations', () {
    late MemorySourceRepository sourceRepo;
    late SourceController sourceController;

    setUp(() async {
      sourceRepo = MemorySourceRepository();
      sourceController = SourceController(repository: sourceRepo);
      await sourceController.load();
    });

    test('initializes default physical cash wallet', () {
      expect(sourceController.sources.length, 1);
      final wallet = sourceController.cashWallet;
      expect(wallet, isNotNull);
      expect(wallet!.type, PaymentSourceType.wallet);
      expect(wallet.bankIdentifier, 'cash_wallet');
      expect(wallet.openingBalanceMinor, 0);
      expect(wallet.isActive, isTrue);
    });

    test('ledger balance calculates opening + income - expenses + transfers', () async {
      // Add bank account with 10,000 opening balance (1,000,000 minor)
      final bankCatalogue = findBankInCatalogue('sbi')!;
      final sbi = await sourceController.addBankSource(
        bank: bankCatalogue,
        accountNumberLast4: '4567',
        openingBalanceMinor: 1000000,
      );

      // Add 2,000 opening balance to cash wallet (200,000 minor)
      var wallet = sourceController.cashWallet!;
      wallet = await sourceController.saveSource(wallet.copyWith(openingBalanceMinor: 200000));

      // Create transactions
      final expenses = <Expense>[
        // Completed expense of Rs. 1,000 from SBI
        Expense(
          id: 1,
          amountMinor: 100000,
          merchant: 'Swiggy',
          categoryId: 'food',
          status: ExpenseStatus.completed,
          transactionType: TransactionType.debit,
          sourceId: sbi.id,
          timestamp: DateTime(2026, 10, 1),
          source: ExpenseSource.sms,
        ),
        // Completed income of Rs. 5,000 to SBI
        Expense(
          id: 2,
          amountMinor: 500000,
          merchant: 'Client Payment',
          categoryId: 'salary',
          status: ExpenseStatus.completed,
          transactionType: TransactionType.credit,
          sourceId: sbi.id,
          timestamp: DateTime(2026, 10, 2),
          source: ExpenseSource.sms,
        ),
        // Completed expense of Rs. 300 from Cash Wallet
        Expense(
          id: 3,
          amountMinor: 30000,
          merchant: 'Groceries',
          categoryId: 'groceries',
          status: ExpenseStatus.completed,
          transactionType: TransactionType.debit,
          sourceId: wallet.id,
          timestamp: DateTime(2026, 10, 3),
          source: ExpenseSource.manual,
        ),
        // Pending transaction (must NOT affect balance)
        Expense(
          id: 4,
          amountMinor: 50000,
          merchant: 'Pending Store',
          categoryId: 'shopping',
          status: ExpenseStatus.pending,
          transactionType: TransactionType.debit,
          sourceId: sbi.id,
          timestamp: DateTime(2026, 10, 4),
          source: ExpenseSource.sms,
        ),
        // Ignored transaction (must NOT affect balance)
        Expense(
          id: 5,
          amountMinor: 80000,
          merchant: 'Ignored Shop',
          categoryId: 'shopping',
          status: ExpenseStatus.ignored,
          transactionType: TransactionType.debit,
          sourceId: wallet.id,
          timestamp: DateTime(2026, 10, 5),
          source: ExpenseSource.manual,
        ),
      ];

      // Perform internal transfer of Rs. 1,500 from SBI to Cash Wallet (ATM withdrawal)
      await sourceController.createTransfer(
        fromSourceId: sbi.id,
        toSourceId: wallet.id,
        amountMinor: 150000,
        note: 'ATM cash withdrawal',
      );

      final breakdown = sourceController.breakdownFor(expenses);

      // SBI calculation:
      // Opening (10,000) + Income (5,000) - Expenses (1,000) - TransferOut (1,500) = 12,500 (1,250,000 minor)
      expect(breakdown.individualBalances[sbi.id], 1250000);

      // Cash Wallet calculation:
      // Opening (2,000) - Expenses (300) + TransferIn (1,500) = 3,200 (320,000 minor)
      expect(breakdown.individualBalances[wallet.id], 320000);

      // Total Bank Balance
      expect(breakdown.totalBankBalanceMinor, 1250000);

      // Cash Balance
      expect(breakdown.cashBalanceMinor, 320000);

      // Combined active balance: 12,500 + 3,200 = 15,700 (1,570,000 minor)
      expect(breakdown.combinedBalanceMinor, 1570000);

      // Verify internal transfer does not count as income or expense in summary
      final sbiSummary = sourceController.summaryFor(sbi, expenses);
      expect(sbiSummary.openingBalanceMinor, 1000000);
      expect(sbiSummary.incomeMinor, 500000);
      expect(sbiSummary.expensesMinor, 100000);
      expect(sbiSummary.transfersSentMinor, 150000);
      expect(sbiSummary.transfersReceivedMinor, 0);
      expect(sbiSummary.closingBalanceMinor, 1250000);

      final walletSummary = sourceController.summaryFor(wallet, expenses);
      expect(walletSummary.openingBalanceMinor, 200000);
      expect(walletSummary.incomeMinor, 0);
      expect(walletSummary.expensesMinor, 30000);
      expect(walletSummary.transfersSentMinor, 0);
      expect(walletSummary.transfersReceivedMinor, 150000);
      expect(walletSummary.closingBalanceMinor, 320000);
    });

    test('updateExpenses updates balance dynamically and supports balance < payment amount', () async {
      final repo = MemorySourceRepository();
      final sourceController = SourceController(repository: repo);
      await sourceController.load();

      final sbi = await repo.saveSource(
        PaymentSource(
          id: 0,
          type: PaymentSourceType.bank,
          bankName: 'State Bank of India',
          bankIdentifier: 'sbi',
          accountNumberLast4: '1234',
          openingBalanceMinor: 10000, // Rs. 100 opening balance
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await sourceController.load();

      // Initially balance equals opening balance
      expect(sourceController.balanceFor(sbi.id), 10000);

      // Add payment of Rs. 500 (50,000 minor) which is greater than Rs. 100 balance
      final largeExpense = Expense(
        id: 1,
        amountMinor: 50000,
        merchant: 'Major Store',
        categoryId: 'shopping',
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        sourceId: sbi.id,
        timestamp: DateTime.now(),
        source: ExpenseSource.manual,
      );

      // Calling updateExpenses notifies listeners and recalculates balanceFor
      var notified = false;
      sourceController.addListener(() => notified = true);
      sourceController.updateExpenses([largeExpense]);

      expect(notified, isTrue);
      // Balance allows becoming negative without restriction: 10,000 - 50,000 = -40,000 (-Rs. 400)
      expect(sourceController.balanceFor(sbi.id), -40000);
    });
  });

  group('Excel Export & Import Roundtrip', () {
    late Directory tempDir;
    late MemoryExpenseRepository expenseRepo;
    late MemorySourceRepository sourceRepo;
    late ExportService exportService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('luma_source_test');
      expenseRepo = MemoryExpenseRepository();
      sourceRepo = MemorySourceRepository();
      exportService = ExportService(
        expenseRepo,
        null,
        sourceRepository: sourceRepo,
        outputDir: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('generates multi-sheet workbook with Accounts, Wallets, Transfers, Financial Summary', () async {
      final sbi = await sourceRepo.saveSource(PaymentSource(
        id: 0,
        type: PaymentSourceType.bank,
        bankName: 'State Bank of India',
        bankIdentifier: 'sbi',
        nickname: 'Salary A/c',
        accountNumberLast4: '9988',
        openingBalanceMinor: 500000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final wallet = (await sourceRepo.getAllSources()).firstWhere((s) => s.isWallet);

      await sourceRepo.saveTransfer(InternalTransfer(
        id: 0,
        fromSourceId: sbi.id,
        toSourceId: wallet.id,
        amountMinor: 50000,
        timestamp: DateTime(2026, 10, 10, 14, 0),
        note: 'Cash out',
        createdAt: DateTime.now(),
      ));

      await expenseRepo.save(Expense(
        id: 101,
        amountMinor: 12000,
        merchant: 'BookStore',
        categoryId: 'education',
        timestamp: DateTime(2026, 10, 11, 10, 0),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.manual,
        sourceId: sbi.id,
      ));

      final result = await exportService.generate(ExportMode.full);
      final file = result.file;
      expect(await file.exists(), isTrue);

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Verify all required worksheets exist
      expect(excel.tables.containsKey('Expenses'), isTrue);
      expect(excel.tables.containsKey('Accounts'), isTrue);
      expect(excel.tables.containsKey('Wallets'), isTrue);
      expect(excel.tables.containsKey('Transfers'), isTrue);
      expect(excel.tables.containsKey('Financial Summary'), isTrue);

      // Verify Payment Source column header in Expenses
      final expenseRows = excel.tables['Expenses']!.rows;
      // Header row is index 6 (after 6 summary rows)
      final headers = expenseRows[6].map((c) => c?.value?.toString()).toList();
      expect(headers.contains('Payment Source'), isTrue);
      expect(headers.contains('Account ID'), isTrue);

      // Verify source row in Accounts sheet
      final accountRows = excel.tables['Accounts']!.rows;
      expect(accountRows.length, greaterThanOrEqualTo(2)); // Header + SBI row
    });

    test('importExcel successfully restores sources and source associations', () async {
      final sbi = await sourceRepo.saveSource(PaymentSource(
        id: 0,
        type: PaymentSourceType.bank,
        bankName: 'HDFC Bank',
        bankIdentifier: 'hdfc',
        accountNumberLast4: '1234',
        openingBalanceMinor: 300000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await expenseRepo.save(Expense(
        id: 201,
        amountMinor: 8500,
        merchant: 'Tea Stall',
        categoryId: 'food',
        timestamp: DateTime(2026, 10, 12, 11, 0),
        status: ExpenseStatus.completed,
        transactionType: TransactionType.debit,
        source: ExpenseSource.manual,
        sourceId: sbi.id,
      ));

      final result = await exportService.generate(ExportMode.full);
      final exportFile = result.file;

      // Clear existing state in a fresh repo pair
      final newExpenseRepo = MemoryExpenseRepository()..clearAll();
      final newSourceRepo = MemorySourceRepository();
      final newExportService = ExportService(
        newExpenseRepo,
        null,
        sourceRepository: newSourceRepo,
        outputDir: () async => tempDir,
      );

      final importResult = await newExportService.importExcel(await exportFile.readAsBytes());
      expect(importResult.accountsRestored, greaterThanOrEqualTo(1));
      expect(importResult.transactionsRestored, greaterThanOrEqualTo(1));

      final restoredSources = await newSourceRepo.getAllSources();
      expect(restoredSources.any((s) => s.bankIdentifier == 'hdfc'), isTrue);

      final restoredExpenses = await newExpenseRepo.getAll();
      final expense = restoredExpenses.firstWhere((e) => e.merchant == 'Tea Stall');
      expect(expense.sourceId, sbi.id);
    });

    test('legacy Excel file without Payment Source imports smoothly into Cash Wallet', () async {
      // Create a legacy Excel with only standard columns
      final excel = Excel.createExcel();
      final sheet = excel['Expenses'];
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Date'),
        TextCellValue('Time'),
        TextCellValue('Type'),
        TextCellValue('Amount'),
        TextCellValue('Category'),
        TextCellValue('Merchant'),
        TextCellValue('Note'),
      ]);
      sheet.appendRow([
        TextCellValue('301'),
        TextCellValue('2026-09-01'),
        TextCellValue('12:00'),
        TextCellValue('debit'),
        TextCellValue('50.00'),
        TextCellValue('food'),
        TextCellValue('Old Cafe'),
        TextCellValue('Legacy item'),
      ]);

      final dir = Directory.systemTemp.createTempSync('luma_legacy_test');
      final legacyFile = File('${dir.path}/legacy_backup.xlsx');
      final bytes = excel.encode()!;
      await legacyFile.writeAsBytes(bytes);

      final freshExpenseRepo = MemoryExpenseRepository()..clearAll();
      final freshSourceRepo = MemorySourceRepository();
      final service = ExportService(
        freshExpenseRepo,
        null,
        sourceRepository: freshSourceRepo,
        outputDir: () async => dir,
      );

      final importResult = await service.importExcel(await legacyFile.readAsBytes());
      expect(importResult.transactionsRestored, 1);
      expect(importResult.isLegacyBackup, isTrue);

      final imported = await freshExpenseRepo.getAll();
      expect(imported.first.merchant, 'Old Cafe');
      // In legacy backups, transactions are assigned to default Cash Wallet
      final cashWallet = (await freshSourceRepo.getAllSources()).firstWhere((s) => s.isWallet);
      expect(imported.first.sourceId, cashWallet.id);

      legacyFile.deleteSync();
      dir.deleteSync();
    });
  });

  group('BalanceCard Bezier Animation', () {
    testWidgets(
      'expands and collapses with bezier animation when tapping view individual accounts',
      (tester) async {
        final bank = PaymentSource(
          id: 1,
          type: PaymentSourceType.bank,
          bankName: 'HDFC Bank',
          bankIdentifier: 'hdfc',
          nickname: 'Salary Account',
          accountNumberLast4: '1234',
          openingBalanceMinor: 500000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BalanceCard(
                currentBalanceMinor: 500000,
                initialBalanceMinor: 500000,
                sources: [bank],
                sourceBalances: {bank.id: 500000},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('View individual accounts'), findsOneWidget);
        expect(find.byType(SizeTransition), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(BalanceCard),
            matching: find.byType(RotationTransition),
          ),
          findsOneWidget,
        );

        // Initially closed
        final sizeTransitionBefore =
            tester.widget<SizeTransition>(find.byType(SizeTransition));
        expect(sizeTransitionBefore.sizeFactor.value, 0.0);

        // Tap to expand
        await tester.tap(find.text('View individual accounts'));
        await tester.pump();
        // Mid-animation check (animating along bezier curve)
        await tester.pump(const Duration(milliseconds: 160));
        final sizeTransitionMid =
            tester.widget<SizeTransition>(find.byType(SizeTransition));
        expect(sizeTransitionMid.sizeFactor.value, greaterThan(0.0));
        expect(sizeTransitionMid.sizeFactor.value, lessThan(1.0));

        await tester.pumpAndSettle();
        expect(find.text('Hide account breakdown'), findsOneWidget);
        expect(find.text(bank.displayName), findsOneWidget);
        final sizeTransitionOpen =
            tester.widget<SizeTransition>(find.byType(SizeTransition));
        expect(sizeTransitionOpen.sizeFactor.value, 1.0);

        // Tap to collapse
        await tester.tap(find.text('Hide account breakdown'));
        await tester.pumpAndSettle();
        expect(find.text('View individual accounts'), findsOneWidget);
        final sizeTransitionClosed =
            tester.widget<SizeTransition>(find.byType(SizeTransition));
        expect(sizeTransitionClosed.sizeFactor.value, 0.0);
      },
    );
  });

  group('Insufficient Balance Confirmation Popup', () {
    testWidgets('shows confirmation dialog when payment exceeds source balance',
        (tester) async {
      final bank = PaymentSource(
        id: 1,
        type: PaymentSourceType.bank,
        bankName: 'HDFC Bank',
        bankIdentifier: 'hdfc',
        openingBalanceMinor: 10000, // Rs. 100 balance
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await confirmInsufficientBalance(
                    context: context,
                    source: bank,
                    currentBalanceMinor: 10000,
                    amountMinor: 50000, // Rs. 500 payment
                  );
                },
                child: const Text('Pay'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap pay
      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      // Verify dialog is shown with details
      expect(find.text('Balance Lower Than Payment'), findsOneWidget);
      expect(find.text('Change Source'), findsOneWidget);
      expect(find.text('Proceed Anyway'), findsOneWidget);
      expect(find.text('Resulting balance:'), findsOneWidget);

      // Tap Change Source -> returns false
      await tester.tap(find.text('Change Source'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.text('Balance Lower Than Payment'), findsNothing);

      // Tap pay again and choose Proceed Anyway
      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Balance Lower Than Payment'), findsOneWidget);
      await tester.tap(find.text('Proceed Anyway'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Balance Lower Than Payment'), findsNothing);
    });
  });
}
