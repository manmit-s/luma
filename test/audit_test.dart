import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/app.dart';
import 'package:luma/services/audit/daily_audit_service.dart';

void main() {
  group('DailyAuditService.nextAuditTime', () {
    test('same-day future time stays today', () {
      final from = DateTime(2026, 9, 25, 18, 30);
      expect(
        DailyAuditService.nextAuditTime(from, 21, 0),
        DateTime(2026, 9, 25, 21, 0),
      );
    });

    test('past time rolls to tomorrow', () {
      final from = DateTime(2026, 9, 25, 22, 10);
      expect(
        DailyAuditService.nextAuditTime(from, 21, 0),
        DateTime(2026, 9, 26, 21, 0),
      );
    });

    test('exact boundary rolls to tomorrow (strictly after)', () {
      final from = DateTime(2026, 9, 25, 21, 0);
      expect(
        DailyAuditService.nextAuditTime(from, 21, 0),
        DateTime(2026, 9, 26, 21, 0),
      );
    });

    test('month boundary rolls correctly', () {
      final from = DateTime(2026, 9, 30, 22, 0);
      expect(
        DailyAuditService.nextAuditTime(from, 21, 0),
        DateTime(2026, 10, 1, 21, 0),
      );
    });
    test('custom user audit time works for same-day and next-day', () {
      final morning = DateTime(2026, 9, 25, 8, 0);
      expect(
        DailyAuditService.nextAuditTime(morning, 20, 30),
        DateTime(2026, 9, 25, 20, 30),
      );

      final evening = DateTime(2026, 9, 25, 21, 0);
      expect(
        DailyAuditService.nextAuditTime(evening, 20, 30),
        DateTime(2026, 9, 26, 20, 30),
      );
    });
  });

  group('DailyAuditService channel', () {
    test('schedule/cancel never throw off-device', () async {
      final service = DailyAuditService();
      await service.schedule(21, 0);
      await service.schedule(20, 30);
      await service.cancel();
    });
  });

  testWidgets('Daily audit sheet shows default 9:00 PM and pending/uncategorized section', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: LumaApp(skipSplash: true)));
    await tester.pumpAndSettle();

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Check default subtitle on Settings row
    expect(find.text('Every day at 9:00 PM'), findsOneWidget);

    // Tap Daily audit row to open sheet
    await tester.tap(find.text('Daily audit'));
    await tester.pumpAndSettle();

    // Verify sheet elements
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Audit time'), findsOneWidget);
    expect(find.text('9:00 PM'), findsWidgets);
    expect(find.text('Pending & uncategorized'), findsOneWidget);
  });
}
