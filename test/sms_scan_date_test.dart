import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/app.dart';
import 'package:luma/app/providers.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/services/sms/sms_ingest.dart';

void main() {
  const smsChannel = MethodChannel('luma/sms');

  group('scanInboxSms with cutoff date', () {
    late MemoryExpenseRepository repo;

    final cutoffDay = DateTime(2026, 9, 20); // 2026-09-20
    final beforeDateMs =
        DateTime(2026, 9, 19, 14, 30).millisecondsSinceEpoch;
    final onDateMsEarlier =
        DateTime(2026, 9, 20, 8, 15).millisecondsSinceEpoch;
    final onDateMsLater =
        DateTime(2026, 9, 20, 23, 45).millisecondsSinceEpoch; // late on cutoff day
    final afterDateMs =
        DateTime(2026, 9, 21, 10, 0).millisecondsSinceEpoch;

    final smsBefore = {
      'body': 'Your A/C XX1234 debited by Rs.100.00 on 19-Sep-26 at Store A. Ref 10001',
      'date': beforeDateMs,
    };
    final smsOnEarlier = {
      'body': 'Your A/C XX1234 debited by Rs.200.00 on 20-Sep-26 at Store B. Ref 10002',
      'date': onDateMsEarlier,
    };
    final smsOnLater = {
      'body': 'Your A/C XX1234 debited by Rs.300.00 on 20-Sep-26 at Store C. Ref 10003',
      'date': onDateMsLater,
    };
    final smsAfter = {
      'body': 'Your A/C XX1234 debited by Rs.400.00 on 21-Sep-26 at Store D. Ref 10004',
      'date': afterDateMs,
    };

    setUp(() {
      repo = MemoryExpenseRepository();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, null);
    });

    Future<WidgetRef> pumpTestScope(WidgetTester tester) async {
      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseControllerProvider.overrideWith((ref) => ExpenseController(repository: repo)),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return capturedRef;
    }

    testWidgets('processes messages before and on cutoff date (inclusive), excludes messages after', (tester) async {
      int? capturedBeforeDate;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, (call) async {
        if (call.method == 'scanInboxSms') {
          final args = call.arguments as Map;
          capturedBeforeDate = args['beforeDate'] as int?;
          // Return simulated inbox (including candidate after cutoff to test Dart-level safety too)
          return [smsAfter, smsOnLater, smsOnEarlier, smsBefore];
        }
        return null;
      });

      final ref = await pumpTestScope(tester);
      final result = await scanInboxSms(ref, cutoffDate: cutoffDay);

      // Captured beforeDate passed to platform channel must be end of day 23:59:59.999
      expect(capturedBeforeDate, isNotNull);
      final expectedEndOfDay =
          DateTime(2026, 9, 20, 23, 59, 59, 999).millisecondsSinceEpoch;
      expect(capturedBeforeDate, expectedEndOfDay);

      // 3 messages eligible (onDateLater, onDateEarlier, before), 1 excluded (after)
      expect(result.validParsed, 3);
      expect(result.newlyCreated, 3);

      final controller = ref.read(expenseControllerProvider);
      final amounts = controller.expenses.map((e) => e.amountMinor).toSet();
      expect(amounts.contains(30000), isTrue); // onDateLater
      expect(amounts.contains(20000), isTrue); // onDateEarlier
      expect(amounts.contains(10000), isTrue); // before
      expect(amounts.contains(40000), isFalse); // after must NOT be present
    });

    testWidgets('prevents duplicate expenses on re-scan', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, (call) async {
        if (call.method == 'scanInboxSms') {
          return [smsOnEarlier, smsBefore];
        }
        return null;
      });

      final ref = await pumpTestScope(tester);
      final result1 = await scanInboxSms(ref, cutoffDate: cutoffDay);
      expect(result1.newlyCreated, 2);

      // Second scan with same messages
      final result2 = await scanInboxSms(ref, cutoffDate: cutoffDay);
      expect(result2.validParsed, 2);
      expect(result2.newlyCreated, 0); // No duplicates created
    });

    testWidgets('handles empty inbox or no matching transaction SMS', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, (call) async {
        if (call.method == 'scanInboxSms') {
          return <dynamic>[];
        }
        return null;
      });

      final ref = await pumpTestScope(tester);
      final result = await scanInboxSms(ref, cutoffDate: cutoffDay);
      expect(result.validParsed, 0);
      expect(result.newlyCreated, 0);
    });

    testWidgets('count-based scan works without cutoffDate (regression verification)', (tester) async {
      int? capturedLimit;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, (call) async {
        if (call.method == 'scanInboxSms') {
          final args = call.arguments as Map;
          expect(args.containsKey('beforeDate'), isFalse);
          capturedLimit = args['limit'] as int?;
          return [smsAfter, smsOnLater, smsOnEarlier, smsBefore];
        }
        return null;
      });

      final ref = await pumpTestScope(tester);
      final result = await scanInboxSms(ref, targetCount: 2);
      expect(capturedLimit, isNotNull);
      // Stops exactly at targetCount = 2
      expect(result.validParsed, 2);
      expect(result.newlyCreated, 2);
    });
  });

  testWidgets('Scan dialog allows switching between count mode and date cutoff mode', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(smsChannel, (call) async {
      if (call.method == 'scanInboxSms') return [];
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, null);
    });

    await tester.pumpWidget(const ProviderScope(child: LumaApp(skipSplash: true)));
    await tester.pumpAndSettle();

    // Navigate to Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Open SMS diagnostics
    await tester.tap(find.text('SMS diagnostics'));
    await tester.pumpAndSettle();

    // Tap Scan recent button to open dialog
    await tester.tap(find.text('Scan recent'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Recent SMS'), findsOneWidget);
    // Count mode is default
    expect(find.text('By count'), findsOneWidget);
    expect(find.text('Up to date'), findsOneWidget);
    expect(find.text('4 SMS'), findsOneWidget);

    // Switch to 'Up to date' mode
    await tester.tap(find.text('Up to date'));
    await tester.pumpAndSettle();

    expect(find.text('Select cutoff date'), findsOneWidget);
    expect(find.text('Scan up to date'), findsOneWidget);

    // Cancel closes the dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Scan Recent SMS'), findsNothing);
  });
}
