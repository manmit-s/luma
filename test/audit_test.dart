import 'package:flutter_test/flutter_test.dart';
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
  });

  group('DailyAuditService channel', () {
    test('schedule/cancel never throw off-device', () async {
      final service = DailyAuditService();
      await service.schedule(21, 0);
      await service.cancel();
    });
  });
}
